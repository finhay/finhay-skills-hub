#!/bin/bash

set -e

CREDS_DIR="$HOME/.finhay/credentials"
CREDS_FILE="$CREDS_DIR/.env"
REPO="finhay/finhay-skills-hub"
BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API="https://api.github.com/repos/${REPO}"

_REQ() {
    local METHOD="$1"
    local ENDPOINT="$2"
    local QUERY="${3:-}"
    local BODY="${4:-}"
    
    local AK="${FINHAY_API_KEY:-$(grep "^FINHAY_API_KEY=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    local AS="${FINHAY_API_SECRET:-$(grep "^FINHAY_API_SECRET=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    local BU="${FINHAY_BASE_URL:-$(grep "^FINHAY_BASE_URL=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    local UI="${USER_ID:-$(grep "^USER_ID=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"

    [ -z "$AK" ] && { echo "ERROR: FINHAY_API_KEY not found. Run ./finhay.sh auth first." >&2; return 1; }
    [ -z "$AS" ] && { echo "ERROR: FINHAY_API_SECRET not found. Run ./finhay.sh auth first." >&2; return 1; }
    [ -z "$BU" ] && BU="https://open-api.fhsc.com.vn"

    local TS=$(( $(date -u +%s) * 1000 ))
    local NONCE=$(openssl rand -hex 16)
    
    local SIG
    if [ -n "$BODY" ]; then
        SIG=$(printf "%s\n%s\n%s\n%s\n" "$TS" "$METHOD" "$ENDPOINT" "$BODY" | openssl dgst -sha256 -hmac "$AS" -binary | xxd -p -c 256)
    else
        SIG=$(printf "%s\n%s\n%s\n" "$TS" "$METHOD" "$ENDPOINT" | openssl dgst -sha256 -hmac "$AS" -binary | xxd -p -c 256)
    fi

    local URL="${BU}${ENDPOINT}"
    if [ -n "$QUERY" ]; then
        ENCODED_QUERY=$(printf '%s' "$QUERY" | sed 's/ /%20/g; s/\[/%5B/g; s/\]/%5D/g')
        URL="${URL}?${ENCODED_QUERY}"
    fi

    local TMP=$(mktemp)
    local CODE=$(curl -sS -X "$METHOD" "$URL" \
        -H "X-FH-APIKEY: $AK" \
        -H "X-FH-USER-ID: $UI" \
        -H "X-FH-TIMESTAMP: $TS" \
        -H "X-FH-NONCE: $NONCE" \
        -H "X-FH-SIGNATURE: $SIG" \
        -H "User-Agent: finhay-openapi (Skill)" \
        -H "Content-Type: application/json" \
        -d "$BODY" -o "$TMP" -w "%{http_code}")

    if [ "$CODE" -ge 400 ]; then
        echo "ERROR: HTTP $CODE" >&2
        cat "$TMP" >&2
        rm -f "$TMP"
        return 1
    fi
    cat "$TMP"
    rm -f "$TMP"
}

CMD_AUTH() {
    echo "Finhay OpenAPI Authentication"
    if [ -f "$CREDS_FILE" ]; then
        read -p "Credentials already exist at $CREDS_FILE. Overwrite? (y/N): " confirm
        [[ ! "$confirm" =~ ^[Yy]$ ]] && return 0
    fi

    mkdir -p "$CREDS_DIR"
    read -p "Enter API Key: " ak
    
    printf "Enter Secret Key: "
    as=""
    while IFS= read -r -s -n1 char; do
        if [[ -z $char ]]; then
            echo ""
            break
        fi
        if [[ $char == $'\177' ]]; then
            if [ -n "$as" ]; then
                as="${as%?}"
                printf "\b \b"
            fi
        else
            as+="$char"
            printf "*"
        fi
    done
    
    cat << EOF > "$CREDS_FILE"
FINHAY_API_KEY=$ak
FINHAY_API_SECRET=$as
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
EOF
    chmod 600 "$CREDS_FILE"
    echo "Saved to $CREDS_FILE"
    echo "Successfully authenticated."
}

CMD_DOCTOR() {
    local AK="${FINHAY_API_KEY:-$(grep "^FINHAY_API_KEY=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    local AS="${FINHAY_API_SECRET:-$(grep "^FINHAY_API_SECRET=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    
    if [ -n "$AK" ] && [ -n "$AS" ]; then
        echo "✅ Credentials: OK"
        echo "🌐 Base URL: ${BU:-https://open-api.fhsc.com.vn}"
    else
        echo "❌ Credentials: MISSING (Set environment variables or run auth)"
    fi
    for c in curl jq openssl xxd; do
        command -v "$c" >/dev/null 2>&1 && echo "✅ $c: OK" || echo "❌ $c: MISSING"
    done
}

CMD_INFER() {
    local DATA=$(_REQ GET /users/v1/users/me)
    USER_ID=$(echo "$DATA" | jq -r '.data.user_id // empty')
    
    if [ -z "$USER_ID" ]; then
        echo "ERROR: Could not resolve USER_ID. Check your credentials." >&2
        [ -n "$DATA" ] && echo "$DATA" >&2
        return 1
    fi

    SBA=$(_REQ GET "/users/v1/users/${USER_ID}/sub-accounts")
    
    [ ! -d "$CREDS_DIR" ] && mkdir -p "$CREDS_DIR"
    TMP=$(mktemp)
    [ -f "$CREDS_FILE" ] && grep -vE '^(USER_ID|SUB_ACCOUNT_)' "$CREDS_FILE" > "$TMP" || true
    
    echo "USER_ID=$USER_ID" >> "$TMP"
    echo "export USER_ID=\"$USER_ID\""
    
    jq -r '(.result // .data // [])[]? | [.type, .id, .sub_account_ext] | @tsv' <<<"$SBA" |
    while IFS=$'\t' read -r TYPE ID EXT; do
        [ -z "$TYPE" ] && continue
        UPPER_TYPE=$(echo "$TYPE" | tr '[:lower:]' '[:upper:]')
        echo "SUB_ACCOUNT_${UPPER_TYPE}=${ID}" >> "$TMP"
        echo "SUB_ACCOUNT_EXT_${UPPER_TYPE}=${EXT}" >> "$TMP"
        echo "export SUB_ACCOUNT_${UPPER_TYPE}=\"$ID\""
        echo "export SUB_ACCOUNT_EXT_${UPPER_TYPE}=\"$EXT\""
    done
    cat "$TMP" > "$CREDS_FILE"
    rm -f "$TMP"
    echo "✅ Account IDs resolved and saved to $CREDS_FILE"
}

CMD_SYNC() {
    SKILL="$1"; [ -z "$SKILL" ] && exit 1
    FILES=$(curl -sf "${API}/git/trees/${BRANCH}?recursive=1" | jq -r --arg p "skills/$SKILL/" '.tree[] | select(.path | startswith($p)) | select(.type == "blob") | .path')
    [ -z "$FILES" ] && { echo "ERROR: Skill $SKILL not found on remote." >&2; return 1; }
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    while IFS= read -r f; do
        out="${tmp}/${f#skills/}"
        mkdir -p "$(dirname "$out")"
        curl -sf "${RAW}/${f}" -o "$out"
    done <<< "$FILES"
    rm -rf "skills/$SKILL"; mkdir -p "skills/$SKILL"
    cp -a "$tmp/$SKILL/." "skills/$SKILL/"
    curl -sf "${RAW}/finhay.sh" -o "skills/$SKILL/finhay.sh"
    curl -sf "${RAW}/finhay.ps1" -o "skills/$SKILL/finhay.ps1"
    chmod +x "skills/$SKILL/finhay.sh"
    echo "✅ $SKILL synced."
}

case "$1" in
    auth) CMD_AUTH ;;
    doctor) CMD_DOCTOR ;;
    infer) CMD_INFER ;;
    request) shift; _REQ "$@" ;;
    sync) CMD_SYNC "$2" ;;
    *) echo "Usage: ./finhay.sh {auth|doctor|infer|request|sync}"; exit 1 ;;
esac
