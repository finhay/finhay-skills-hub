#!/bin/bash

set -e

CREDS_DIR="$HOME/.finhay/credentials"
CREDS_FILE="$CREDS_DIR/.env"
REPO="finhay/finhay-skills-hub"
BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API="https://api.github.com/repos/${REPO}"

SKILL_DIR="${BASH_SOURCE[0]%/*}"
SKILL="${SKILL_DIR##*/}"
VER=unknown
[ -r "$SKILL_DIR/.version" ] && read -r VER < "$SKILL_DIR/.version"
OS=$(uname -srm)

DEPS=(
    "Node.js|node|--version|node|nodejs|https://nodejs.org/en/download"
)

_INPUT_SRC() {
    if [ -t 0 ]; then
        echo "/dev/stdin"
    elif [ -c /dev/tty ] && [ -w /dev/tty ]; then
        echo "/dev/tty"
    else
        echo "/dev/stdin"
    fi
}

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
    local AGENT="${AGENT_NAME:-unknown}"

    local SIG
    local BODY_HASH=""
    if [ -n "$BODY" ]; then
        BODY_HASH=$(printf '%s' "$BODY" | openssl dgst -sha256 -binary | xxd -p -c 256)
        SIG=$(printf "%s\n%s\n%s\n%s" "$TS" "$METHOD" "$ENDPOINT" "$BODY_HASH" | openssl dgst -sha256 -hmac "$AS" -binary | xxd -p -c 256)
    else
        SIG=$(printf "%s\n%s\n%s\n" "$TS" "$METHOD" "$ENDPOINT" | openssl dgst -sha256 -hmac "$AS" -binary | xxd -p -c 256)
    fi

    local URL="${BU}${ENDPOINT}"
    if [ -n "$QUERY" ]; then
        ENCODED_QUERY=$(printf '%s' "$QUERY" | sed 's/ /%20/g; s/\[/%5B/g; s/\]/%5D/g')
        URL="${URL}?${ENCODED_QUERY}"
    fi

    local BODYHASH_HEADER=()
    [ -n "$BODY_HASH" ] && BODYHASH_HEADER=(-H "X-FH-BODYHASH: $BODY_HASH")

    local TMP=$(mktemp)
    local CODE=$(curl -sS -X "$METHOD" "$URL" \
        -H "X-FH-APIKEY: $AK" \
        -H "X-FH-USER-ID: $UI" \
        -H "X-FH-TIMESTAMP: $TS" \
        -H "X-FH-NONCE: $NONCE" \
        -H "X-FH-SIGNATURE: $SIG" \
        "${BODYHASH_HEADER[@]}" \
        -H "X-FH-OPENAPI-SKILL-VERSION: $VER" \
        -H "X-FH-OPENAPI-OS: $OS" \
        -H "X-FH-OPENAPI-AGENT: $AGENT" \
        -H "User-Agent: finhay-skills-hub/${SKILL}@${VER} (${AGENT}; ${OS})" \
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
    echo "=== Xac thuc ket noi tai khoan FHSC ==="
    local input_src
    input_src=$(_INPUT_SRC)
    local existing_creds=false
    if [ -f "$CREDS_FILE" ]; then
        local ak as
        ak=$(grep "^FINHAY_API_KEY=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)
        as=$(grep "^FINHAY_API_SECRET=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)
        if [ -n "$ak" ] && [ -n "$as" ]; then
            existing_creds=true
            printf "Tim thay thong tin Credentials %s\n" "$CREDS_FILE"
            printf "  API Key    : %s********\n" "${ak:0:8}"
            printf "  Secret Key : ****************\n"
            printf "Ban co muon thay the khong? [y/N]: "
            read -r confirm < "$input_src"
            [[ ! "$confirm" =~ ^[Yy]$ ]] && return 0
        fi
    fi

    mkdir -p "$CREDS_DIR"
    local prompt_suffix=""
    [ "$existing_creds" = true ] && prompt_suffix=" moi"
    printf "Nhap API Key%s: " "$prompt_suffix"
    read -r ak < "$input_src"

    printf "Nhap Secret Key%s: " "$prompt_suffix"
    trap 'stty echo < /dev/tty 2>/dev/null' EXIT INT
    stty -echo < /dev/tty 2>/dev/null
    as=""
    while IFS= read -r -n1 c < "$input_src"; do
        [[ -z $c ]] && break
        if [[ $c == $'\177' || $c == $'\b' ]]; then
            [ -n "$as" ] && { as="${as%?}"; printf "\b \b"; }
        else
            as+="$c"; printf "*"
        fi
    done
    stty echo < /dev/tty 2>/dev/null
    trap - EXIT INT
    echo

    cat << EOF > "$CREDS_FILE"
FINHAY_API_KEY=$ak
FINHAY_API_SECRET=$as
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
EOF
    chmod 600 "$CREDS_FILE"

    if [ "$existing_creds" = true ]; then
        echo "Cap nhat Credentials thanh cong. Hay khoi dong lai Agent de su dung."
    else
        echo "Tao Credentials thanh cong tai $CREDS_FILE"
        echo "Hay khoi dong lai Agent de su dung."
    fi
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

INSTALL_DEP() {
    local NAME="$1" BREW_ID="$2" APT_ID="$3" URL="$4"
    if command -v brew >/dev/null 2>&1; then
        echo "Installing $NAME via Homebrew..."
        brew install "$BREW_ID"
    elif command -v apt-get >/dev/null 2>&1; then
        echo "Installing $NAME via apt..."
        sudo apt-get update && sudo apt-get install -y "$APT_ID"
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installing $NAME via dnf..."
        sudo dnf install -y "$APT_ID"
    elif command -v pacman >/dev/null 2>&1; then
        echo "Installing $NAME via pacman..."
        sudo pacman -S --noconfirm "$APT_ID"
    else
        echo "No supported package manager found. Install manually from $URL"
    fi
}

CHECK_DEP() {
    IFS='|' read -r NAME CMD VARG BREW_ID APT_ID URL <<< "$1"
    if command -v "$CMD" >/dev/null 2>&1; then
        echo "✅ $NAME: $("$CMD" "$VARG" 2>/dev/null)"
        return
    fi
    echo "❌ $NAME: MISSING"
    printf "Install %s now? [y/N]: " "$NAME"
    read -r confirm < "$(_INPUT_SRC)"
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        INSTALL_DEP "$NAME" "$BREW_ID" "$APT_ID" "$URL"
    else
        echo "Install manually from $URL"
    fi
}

CMD_DEPS() {
    for dep in "${DEPS[@]}"; do CHECK_DEP "$dep"; done
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
    deps) CMD_DEPS ;;
    infer) CMD_INFER ;;
    request) shift; _REQ "$@" ;;
    sync) CMD_SYNC "$2" ;;
    *) echo "Usage: ./finhay.sh {auth|doctor|deps|infer|request|sync}"; exit 1 ;;
esac
