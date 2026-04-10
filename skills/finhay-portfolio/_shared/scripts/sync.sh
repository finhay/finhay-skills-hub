#!/usr/bin/env bash
set -euo pipefail

SKILL="${1:-}"; [[ -n "$SKILL" ]] || { echo "Usage: sync.sh <skill>" >&2; exit 1; }

REPO="finhay/finhay-skills-hub"; BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API="https://api.github.com/repos/${REPO}"
TTL=$((12*3600))
REF_ENV="$HOME/.finhay/ref/.env"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [[ "$(basename "$ROOT")" != "skills" ]]; do
  P="$(dirname "$ROOT")"; [[ "$P" != "$ROOT" ]] || { echo "ERROR: skills/ not found" >&2; exit 1; }
  ROOT="$P"
done

[[ -f "${ROOT}/${SKILL}/SKILL.md" ]] || { echo "ERROR: skill not found: $SKILL" >&2; exit 1; }

[[ -f "$REF_ENV" ]] && { set -a; source "$REF_ENV"; set +a; } || true

now=$(date -u +%s)
TOKEN=$(tr '[:lower:]' '[:upper:]' <<<"$SKILL" | tr -c 'A-Z0-9' '_')
SK="SKILL_${TOKEN}_SYNC_AT"

shared_stale=$(( now - ${SHARED_SYNC_AT:-0} > TTL ))
skill_stale=$(( now - ${!SK:-0} > TTL ))

(( shared_stale || skill_stale )) || { echo "$SKILL: up-to-date"; exit 0; }

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq required" >&2; exit 1; }

TREE=$(curl -sf "${API}/git/trees/${BRANCH}?recursive=1")

list_blobs() {
  jq -r --arg p "skills/$1/" '
    .tree[]
    | select(.type=="blob" and (.path | startswith($p)))
    | "\(.mode)\t\(.path)"
  ' <<<"$TREE"
}

sync_component() {
  local name="$1" dest="$2" prefix="$3" tmp ver
  ver=$(curl -sf "${RAW}/skills/${prefix}/.version" || echo "unknown")
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN

  while IFS=$'\t' read -r mode file; do
    out="${tmp}/${file#skills/}"
    mkdir -p "$(dirname "$out")"
    if [[ "$mode" == "120000" ]]; then
      ln -s "$(curl -sf "${RAW}/${file}")" "$out"
    else
      curl -sf "${RAW}/${file}" -o "$out"
    fi
  done < <(list_blobs "$prefix")

  rm -rf "$dest"
  cp -a "${tmp}/${prefix}" "$dest"
  find "$dest" -type f -name "*.sh" -exec chmod +x {} +
  echo "${name}: synced (${ver})"
}

(( shared_stale )) && sync_component "_shared" "${ROOT}/_shared" "_shared"
(( skill_stale  )) && sync_component "$SKILL"  "${ROOT}/${SKILL}" "$SKILL"

TMPREF=$(mktemp)
trap 'rm -f "$TMPREF"' EXIT

[[ -f "$REF_ENV" ]] && grep -vE "^(SHARED_SYNC_AT|${SK})=" "$REF_ENV" > "$TMPREF" || true
(( shared_stale )) && echo "SHARED_SYNC_AT=$now" >> "$TMPREF"
(( skill_stale  )) && echo "${SK}=$now" >> "$TMPREF"

mv "$TMPREF" "$REF_ENV"