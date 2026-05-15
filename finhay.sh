#!/bin/bash

set -e

CREDS_DIR="$HOME/.finhay/credentials"
CREDS_FILE="$CREDS_DIR/.env"
SESSION_2FA_FILE="$CREDS_DIR/.2fa-session"
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

_LOAD_2FA_TOKEN() {
    [ -f "$SESSION_2FA_FILE" ] || return 0
    local token exp_epoch now_epoch
    token=$(grep "^session_token=" "$SESSION_2FA_FILE" 2>/dev/null | cut -d'=' -f2-)
    exp_epoch=$(grep "^expires_at_epoch=" "$SESSION_2FA_FILE" 2>/dev/null | cut -d'=' -f2-)
    [ -z "$token" ] && return 0
    [ -z "$exp_epoch" ] && return 0
    now_epoch=$(date -u +%s)
    if [ "$exp_epoch" -gt "$now_epoch" ]; then
        echo "$token"
    fi
}

_SAVE_2FA_TOKEN() {
    local token="$1" exp_iso="$2" exp_epoch="$3"
    [ -d "$CREDS_DIR" ] || mkdir -p "$CREDS_DIR"
    cat > "$SESSION_2FA_FILE" <<EOF
session_token=$token
expires_at=$exp_iso
expires_at_epoch=$exp_epoch
EOF
    chmod 600 "$SESSION_2FA_FILE"
}

_CLEAR_2FA_TOKEN() {
    rm -f "$SESSION_2FA_FILE"
}

_2FA_INTERACTIVE_FLOW() {
    local input_src
    input_src=$(_INPUT_SRC)

    local resp ticket masked
    resp=$(_REQ POST /auth/v1/openapi/2fa/request '' "{\"channel\":\"EMAIL\"}") || return 1
    ticket=$(printf '%s' "$resp" | jq -r '.ticket_id // empty')
    masked=$(printf '%s' "$resp" | jq -r '.masked_destination // empty')
    [ -z "$ticket" ] && { echo "ERROR: 2FA request failed: $resp" >&2; return 1; }

    echo "📨 OTP đã gửi tới ${masked:-destination}. Hết hạn sau 5 phút." >&2
    printf "Nhập OTP 6 số: " >&2
    local otp=""
    read -r otp < "$input_src" || true
    [ -z "$otp" ] && { echo "ERROR: OTP rỗng." >&2; return 1; }

    resp=$(_REQ POST /auth/v1/openapi/2fa/verify '' "{\"ticket_id\":\"$ticket\",\"otp_code\":\"$otp\"}") || return 1
    local token exp_iso exp_epoch
    token=$(printf '%s' "$resp" | jq -r '.session_token // empty')
    exp_iso=$(printf '%s' "$resp" | jq -r '.expires_at // empty')
    exp_epoch=$(printf '%s' "$resp" | jq -r '.expires_at_epoch // empty')
    [ -z "$token" ] && { echo "ERROR: 2FA verify failed: $resp" >&2; return 1; }

    _SAVE_2FA_TOKEN "$token" "$exp_iso" "$exp_epoch"
    echo "✅ 2FA session đã được lưu, hết hạn $exp_iso" >&2
    return 0
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

    local METHOD_UPPER=$(printf '%s' "$METHOD" | tr '[:lower:]' '[:upper:]')

    local ENCODED_QUERY=""
    if [ -n "$QUERY" ]; then
        ENCODED_QUERY=$(printf '%s' "$QUERY" | sed 's/ /%20/g; s/\[/%5B/g; s/\]/%5D/g')
    fi

    local SIGN_PATH="$ENDPOINT"
    [ -n "$ENCODED_QUERY" ] && SIGN_PATH="${SIGN_PATH}?${ENCODED_QUERY}"

    local SIG
    local BODY_HASH=""
    if [ -n "$BODY" ]; then
        BODY_HASH=$(printf '%s' "$BODY" | openssl dgst -sha256 -binary | xxd -p -c 256)
        SIG=$(printf "%s\n%s\n%s\n%s" "$TS" "$METHOD_UPPER" "$SIGN_PATH" "$BODY_HASH" | openssl dgst -sha256 -hmac "$AS" -binary | xxd -p -c 256)
    else
        SIG=$(printf "%s\n%s\n%s\n" "$TS" "$METHOD_UPPER" "$SIGN_PATH" | openssl dgst -sha256 -hmac "$AS" -binary | xxd -p -c 256)
    fi

    local URL="${BU}${ENDPOINT}"
    [ -n "$ENCODED_QUERY" ] && URL="${URL}?${ENCODED_QUERY}"

    local BODYHASH_HEADER=()
    [ -n "$BODY_HASH" ] && BODYHASH_HEADER=(-H "X-FH-BODYHASH: $BODY_HASH")

    local TOKEN_2FA=""
    TOKEN_2FA=$(_LOAD_2FA_TOKEN || true)
    local TWOFA_HEADER=()
    [ -n "$TOKEN_2FA" ] && TWOFA_HEADER=(-H "X-FH-2FA-TOKEN: $TOKEN_2FA")

    local TMP=$(mktemp)
    local CODE=$(curl -sS -X "$METHOD" "$URL" \
        -H "X-FH-APIKEY: $AK" \
        -H "X-FH-USER-ID: $UI" \
        -H "X-FH-TIMESTAMP: $TS" \
        -H "X-FH-NONCE: $NONCE" \
        -H "X-FH-SIGNATURE: $SIG" \
        "${BODYHASH_HEADER[@]}" \
        "${TWOFA_HEADER[@]}" \
        -H "X-FH-OPENAPI-SKILL-VERSION: $VER" \
        -H "X-FH-OPENAPI-OS: $OS" \
        -H "X-FH-OPENAPI-AGENT: $AGENT" \
        -H "User-Agent: finhay-skills-hub/${SKILL}@${VER} (${AGENT}; ${OS})" \
        -H "Content-Type: application/json" \
        -d "$BODY" -o "$TMP" -w "%{http_code}")

    if [ "$CODE" -ge 400 ]; then
        if [ "$CODE" = "403" ] && [ -z "${_IN_2FA_RECOVERY:-}" ]; then
            local err_code=""
            err_code=$(jq -r '.error_code // empty' < "$TMP" 2>/dev/null || true)
            case "$err_code" in
                OTP_SESSION_REQUIRED|OTP_SESSION_EXPIRED|OTP_SESSION_INVALID|OTP_SESSION_REVOKED)
                    _CLEAR_2FA_TOKEN
                    rm -f "$TMP"
                    echo "🔐 Cần xác thực OTP cho thao tác này (error: $err_code)." >&2
                    _IN_2FA_RECOVERY=1
                    if ! _2FA_INTERACTIVE_FLOW; then
                        unset _IN_2FA_RECOVERY
                        return 1
                    fi
                    echo "🔁 Retry lệnh gốc..." >&2
                    local rc=0
                    _REQ "$METHOD" "$ENDPOINT" "$QUERY" "$BODY" || rc=$?
                    unset _IN_2FA_RECOVERY
                    return $rc
                    ;;
            esac
        fi
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

CMD_2FA() {
    local sub="$1"; shift || true
    case "$sub" in
        request)
            _REQ POST /auth/v1/openapi/2fa/request '' "{\"channel\":\"EMAIL\"}"
            ;;
        verify)
            local ticket="$1" otp="$2"
            [ -z "$ticket" ] || [ -z "$otp" ] && { echo "Usage: 2fa verify <ticket_id> <otp_code>" >&2; return 1; }
            local resp token exp_iso exp_epoch
            resp=$(_REQ POST /auth/v1/openapi/2fa/verify '' "{\"ticket_id\":\"$ticket\",\"otp_code\":\"$otp\"}") || return 1
            token=$(printf '%s' "$resp" | jq -r '.session_token // empty')
            exp_iso=$(printf '%s' "$resp" | jq -r '.expires_at // empty')
            exp_epoch=$(printf '%s' "$resp" | jq -r '.expires_at_epoch // empty')
            [ -z "$token" ] && { echo "ERROR: verify failed: $resp" >&2; return 1; }
            _SAVE_2FA_TOKEN "$token" "$exp_iso" "$exp_epoch"
            echo "✅ 2FA session đã lưu vào $SESSION_2FA_FILE, hết hạn $exp_iso"
            ;;
        status)
            if [ ! -f "$SESSION_2FA_FILE" ]; then
                echo "❌ Chưa có 2FA session. Chạy write request hoặc './finhay.sh 2fa request' để bắt đầu."
                return 0
            fi
            local exp_iso exp_epoch now_epoch
            exp_iso=$(grep "^expires_at=" "$SESSION_2FA_FILE" | cut -d'=' -f2-)
            exp_epoch=$(grep "^expires_at_epoch=" "$SESSION_2FA_FILE" | cut -d'=' -f2-)
            now_epoch=$(date -u +%s)
            if [ -n "$exp_epoch" ] && [ "$exp_epoch" -gt "$now_epoch" ]; then
                echo "✅ 2FA session đang hoạt động, hết hạn $exp_iso"
            else
                echo "⚠ 2FA session đã hết hạn ($exp_iso). Lần write tiếp theo sẽ tự kích hoạt OTP."
            fi
            ;;
        revoke)
            local token
            token=$(_LOAD_2FA_TOKEN || true)
            if [ -z "$token" ]; then
                _CLEAR_2FA_TOKEN
                echo "Không có session active để revoke. File local đã được xoá."
                return 0
            fi
            _REQ POST /auth/v1/openapi/2fa/revoke '' "{\"session_token\":\"$token\"}" > /dev/null || true
            _CLEAR_2FA_TOKEN
            echo "✅ 2FA session đã revoke (cả server + local)."
            ;;
        ""|help|*)
            cat >&2 <<EOF
Usage: ./finhay.sh 2fa <subcommand>
  request                        Yêu cầu OTP qua email
  verify <ticket_id> <otp_code>  Verify OTP và lưu session JWT
  status                         Xem trạng thái session hiện tại
  revoke                         Huỷ session (xoá cả server + local)

Khi gọi write request (place/modify/cancel order), skill sẽ tự
detect 403 OTP_SESSION_REQUIRED và chạy interactive flow.
EOF
            return 1
            ;;
    esac
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
    2fa) shift; CMD_2FA "$@" ;;
    sync) CMD_SYNC "$2" ;;
    *) echo "Usage: ./finhay.sh {auth|doctor|deps|infer|request|2fa|sync}"; exit 1 ;;
esac
