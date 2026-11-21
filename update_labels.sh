#!/usr/bin/env bash
# Apply unified label colors to repos.
# Usage:
#   ./update_labels.sh                  # all private repos owned by current user
#   ./update_labels.sh owner/repo       # specific repo
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
  echo "ERROR: Bash 4+ required for associative arrays (you have $BASH_VERSION)." >&2
  echo "On macOS: brew install bash, then run with: /opt/homebrew/bin/bash $0 $*" >&2
  exit 1
fi

set -u

# Requires bash 4+ (associative arrays, ${var,,}). macOS ships bash 3.2.
if (( BASH_VERSINFO[0] < 4 )); then
  for alt in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    if [[ -x "$alt" ]]; then exec "$alt" "$0" "$@"; fi
  done
  echo "ERROR: bash 4+ required (found $BASH_VERSION). Install with: brew install bash" >&2
  exit 1
fi

declare -A C=(
  ["bug"]="d73a4a"
  ["documentation"]="0075ca"
  ["duplicate"]="8c8c8c"
  ["enhancement"]="10739e"
  ["good first issue"]="7057ff"
  ["help wanted"]="008672"
  ["invalid"]="b7b731"
  ["question"]="d876e3"
  ["wontfix"]="999999"
  ["status: blocked"]="b60205"
  ["status: confirmed"]="0e8a16"
  ["status: duplicate"]="8c8c8c"
  ["status: help wanted"]="008672"
  ["status: invalid"]="b7b731"
  ["status: need feedback"]="fbca04"
  ["status: needs more info"]="fbca04"
  ["status: on hold"]="cccccc"
  ["status: won't do/fix"]="999999"
  ["status: can't reproduce"]="b7b731"
  ["future maybe"]="5879c7"
  ["component: backend"]="1a9641"
  ["component: infra"]="5319e7"
  ["component: ui"]="1d76db"
  ["priority: critical"]="b60205"
  ["priority: high"]="d93f0b"
  ["priority: medium"]="fbca04"
  ["priority: low"]="cccccc"
  ["dependencies"]="0366d6"
  ["dependency"]="0366d6"
  ["feature"]="1a85ff"
  ["development"]="fbca04"
  ["infrastructure"]="5319e7"
  ["source"]="0e8a16"
  ["frontend"]="1d76db"
  ["backend"]="1a9641"
  ["deployment"]="b60205"
  ["release"]="0e8a16"
  ["ready"]="0e8a16"
  ["in progress"]="fbca04"
  ["epic"]="3e4b9e"
  ["must-have"]="b60205"
  ["should-have"]="d93f0b"
  ["could-have"]="fbca04"
  ["wont-have"]="cccccc"
  ["template"]="589df6"
  ["static"]="5879c7"
  ["submodules"]="8c8c8c"
  ["kind/bug"]="d73a4a"
  ["kind/enhancement"]="10739e"
  ["kind/doc"]="0075ca"
  ["kind/question"]="d876e3"
  ["type/blocker"]="b60205"
  ["future/maybe"]="5879c7"
  ["status/blocked"]="b60205"
  ["status/confirmed"]="0e8a16"
  ["status/duplicate"]="8c8c8c"
  ["status/help wanted"]="008672"
  ["status/invalid"]="b7b731"
  ["status/need feedback"]="fbca04"
  ["status/needs more info"]="fbca04"
  ["status/on hold"]="cccccc"
  ["status/won't do/fix"]="999999"
  ["status/wontfix"]="999999"
  ["type/bug"]="d73a4a"
  ["type/build"]="5319e7"
  ["type/chore"]="8c8c8c"
  ["type/ci"]="2088ff"
  ["type/discussion"]="d876e3"
  ["type/documentation"]="0075ca"
  ["type/enhancement"]="10739e"
  ["type/feature request"]="1a85ff"
  ["type/investigate"]="d93f0b"
  ["type/perf"]="0e8a16"
  ["type/question"]="d876e3"
  ["type/refactor"]="fbca04"
  ["type/security"]="b60205"
  ["type/test"]="589df6"
  ["type: bug"]="d73a4a"
  ["type: build"]="5319e7"
  ["type: chore"]="8c8c8c"
  ["type: ci"]="2088ff"
  ["type: discussion"]="d876e3"
  ["type: documentation"]="0075ca"
  ["type: enhancement"]="10739e"
  ["type: feature request"]="1a85ff"
  ["type: investigate"]="d93f0b"
  ["type: perf"]="0e8a16"
  ["type: question"]="d876e3"
  ["type: refactor"]="fbca04"
  ["type: security"]="b60205"
  ["type: test"]="589df6"
  ["component/backend"]="1a9641"
  ["component/infra"]="5319e7"
  ["component/ui"]="1d76db"
  ["priority/critical"]="b60205"
  ["priority/high"]="d93f0b"
  ["priority/medium"]="fbca04"
  ["priority/low"]="cccccc"
  ["status/can't reproduce"]="b7b731"
  ["github_actions"]="2088ff"
  ["devcontainers_package_manager"]="8c8c8c"
  ["kubernetes"]="326ce5"
  ["notebook"]="da5b0b"
  ["ios"]="999999"
  ["android"]="34a853"
  ["accessibility"]="f143ab"
  ["adapter"]="bf0d28"
  ["api"]="168249"
  ["app"]="52189b"
  ["bench"]="0e8a16"
  ["core"]="0b9fc7"
  ["database"]="8f0bb8"
  ["email"]="0f0272"
  ["engine"]="240a28"
  ["infra"]="5319e7"
  ["ingest"]="2ea44f"
  ["manifest"]="795d4d"
  ["migration"]="839239"
  ["store"]="a2ba08"
  ["ui"]="1d76db"
  ["web"]="089ebd"
  ["go"]="00add8"
  ["golang"]="00add8"
  ["rust"]="c75124"
  ["java"]="b07219"
  ["kotlin"]="a97bff"
  ["javascript"]="c8a415"
  ["typescript"]="3178c6"
  ["react"]="149e9c"
  ["python"]="3572a5"
  ["html"]="e34c26"
  ["css"]="563d7c"
  ["dart"]="00b4ab"
  ["csharp"]="178600"
  ["svelte"]="ff3e00"
  ["shell"]="57a426"
  ["astro"]="ff5a03"
)

urlencode() {
  local s="$1" out="" i c
  for (( i=0; i<${#s}; i++ )); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_:/-]) out+="$c" ;;
      ' ') out+="%20" ;;
      *) printf -v hex '%%%02X' "'$c"; out+="$hex" ;;
    esac
  done
  printf '%s' "$out"
}

TARGET_REPO="${1:-}"
TSV=$(mktemp)
trap 'rm -f "$TSV"' EXIT

if [[ -n "$TARGET_REPO" ]]; then
  if [[ "$TARGET_REPO" != */* ]]; then
    echo "ERROR: repo must be in 'owner/name' format" >&2
    exit 1
  fi
  echo "Fetching labels for $TARGET_REPO..."
  gh api --paginate "repos/$TARGET_REPO/labels" \
    --jq ".[] | [\"$TARGET_REPO\", .name, .color, (.description // \"\")] | @tsv" \
    > "$TSV"
else
  echo "Fetching labels for all private repos..."
  repos=$(gh repo list --limit 1000 --visibility private --no-archived --json nameWithOwner --jq '.[].nameWithOwner')
  while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    gh api --paginate "repos/$repo/labels" \
      --jq ".[] | [\"$repo\", .name, .color, (.description // \"\")] | @tsv" \
      >> "$TSV" 2>/dev/null || true
  done <<< "$repos"
fi

updated=0; skipped=0; missing=0; failed=0
while IFS=$'\t' read -r repo name cur desc; do
  [[ -z "$repo" ]] && continue
  key=$(echo "$name" | tr '[:upper:]' '[:lower:]')
  want="${C[$key]+${C[$key]}}"
  if [[ -z "$want" ]]; then
    missing=$((missing+1)); echo "MISS $repo :: $name"; continue
  fi
  if [[ "${cur,,}" == "$want" ]]; then
    skipped=$((skipped+1)); continue
  fi
  enc=$(urlencode "$name")
  if err=$(gh api -X PATCH "repos/$repo/labels/$enc" -f color="$want" --silent 2>&1); then
    updated=$((updated+1))
    echo "OK  $repo :: $name -> $want"
  else
    failed=$((failed+1))
    echo "FAIL $repo :: $name :: $err"
  fi
done < "$TSV"

echo
echo "updated=$updated skipped=$skipped missing=$missing failed=$failed"
