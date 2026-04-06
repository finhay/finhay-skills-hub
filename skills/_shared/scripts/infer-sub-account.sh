#!/usr/bin/env bash
set -euo pipefail

CREDS="${HOME}/.finhay/credentials/.env"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$CREDS" ]] || { echo "ERROR: $CREDS not found" >&2; exit 1; }

set -a
source "$CREDS"
set +a

if [[ -n "${USER_ID:-}" && ( -n "${SUB_ACCOUNT_NORMAL:-}" || -n "${SUB_ACCOUNT_MARGIN:-}" ) ]]; then
  echo "✅ Credentials already set"
  exit 0
fi

[[ -n "${FINHAY_API_KEY:-}" && -n "${FINHAY_API_SECRET:-}" ]] \
  || { echo "ERROR: FINHAY_API_KEY and FINHAY_API_SECRET required" >&2; exit 1; }

command -v jq >/dev/null 2>&1 \
  || { echo "ERROR: jq is required but not installed" >&2; exit 1; }

req() { bash "$DIR/request.sh" "$@"; }

USER_ID="$(req GET /users/v1/users/me | jq -r '.data.user_id // empty')"
[[ -n "$USER_ID" ]] || { echo "ERROR: user_id missing in response" >&2; exit 1; }

SBA="$(req GET "/users/v1/users/${USER_ID}/sub-accounts")"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

grep -vE '^(USER_ID|SUB_ACCOUNT_)' "$CREDS" > "$TMP" || true
echo "USER_ID=$USER_ID" >> "$TMP"

jq -r '.data[]? | [.type, .id, .sub_account_ext] | @tsv' <<<"$SBA" |
while IFS=$'\t' read -r TYPE ID EXT; do
  TYPE="${TYPE^^}"
  [[ -z "$TYPE" ]] && continue
  {
    echo "SUB_ACCOUNT_${TYPE}=${ID}"
    echo "SUB_ACCOUNT_EXT_${TYPE}=${EXT}"
  } >> "$TMP"
done

mv "$TMP" "$CREDS"
echo "✅ Credentials updated successfully"