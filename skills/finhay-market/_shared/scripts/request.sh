#!/usr/bin/env bash
set -euo pipefail

[[ $# -ge 2 ]] || { echo "Usage: request.sh METHOD ENDPOINT [QUERY] [BODY]" >&2; exit 1; }

METHOD="$1"
ENDPOINT="$2"
QUERY="${3:-}"
BODY="${4:-}"

CREDS="$HOME/.finhay/credentials/.env"
[[ -f "$CREDS" ]] || { echo "ERROR: $CREDS not found" >&2; exit 1; }

set -a; source "$CREDS"; set +a

[[ -n "${FINHAY_API_KEY:-}" ]]    || { echo "ERROR: FINHAY_API_KEY required." >&2; exit 1; }
[[ -n "${FINHAY_API_SECRET:-}" ]] || { echo "ERROR: FINHAY_API_SECRET required." >&2; exit 1; }

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq required" >&2; exit 1; }

SKILL_NAME="finhay-market"
SKILL_VERSION="1.0.3"

TS=$(( $(date -u +%s) * 1000 ))
NONCE=$(openssl rand -hex 16)

PAYLOAD="${TS}
${METHOD}
${ENDPOINT}
"
[[ -n "$BODY" ]] && PAYLOAD+="${BODY}
"

SIG=$(printf '%s' "$PAYLOAD" |
  openssl dgst -sha256 -hmac "$FINHAY_API_SECRET" -binary | xxd -p -c 256)

URL="${FINHAY_BASE_URL:-https://open-api.fhsc.com.vn}${ENDPOINT}"
[[ -n "$QUERY" ]] && URL="${URL}?${QUERY}"

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

CURL_ARGS=(
  -sS --max-time 30 -o "$TMP" -w "%{http_code}"
  -X "$METHOD"
  -H "User-Agent: $SKILL_NAME/$SKILL_VERSION"
  -H "X-FH-APIKEY: $FINHAY_API_KEY"
  -H "X-FH-TIMESTAMP: $TS"
  -H "X-FH-NONCE: $NONCE"
  -H "X-FH-SIGNATURE: $SIG"
  -H "X-Origin-Method: $METHOD"
  -H "X-Origin-Path: $ENDPOINT"
  -H "X-Origin-Query: $QUERY"
)

if [[ -n "$BODY" ]]; then
  CURL_ARGS+=(
    -H "Content-Type: application/json"
    --data "$BODY"
  )
fi

CODE=$(curl "${CURL_ARGS[@]}" "$URL")

(( CODE < 400 )) || { echo "ERROR: HTTP $CODE" >&2; cat "$TMP" >&2; exit 1; }

EC=$(jq -r '.error_code // empty' "$TMP")
[[ -z "$EC" || "$EC" == "0" ]] || {
  echo "ERROR: error_code=$EC" >&2
  cat "$TMP" >&2
  exit 1
}

cat "$TMP"