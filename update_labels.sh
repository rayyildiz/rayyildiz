#!/usr/bin/env bash
# Apply unified label colors to repos.
# Usage:
#   ./update_labels.sh                  # all private repos owned by current user
#   ./update_labels.sh owner/repo       # specific repo
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
  ["duplicate"]="cfd3d7"
  ["enhancement"]="a2eeef"
  ["good first issue"]="7057ff"
  ["help wanted"]="008672"
  ["invalid"]="e4e669"
  ["question"]="d876e3"
  ["wontfix"]="ffffff"
  ["dependencies"]="0366d6"
  ["dependency"]="0366d6"
  ["feature"]="84b6eb"
  ["development"]="fbca04"
  ["infrastructure"]="5319e7"
  ["source"]="0e8a16"
  ["frontend"]="1d76db"
  ["backend"]="c2e0c6"
  ["deployment"]="b60205"
  ["release"]="0e8a16"
  ["ready"]="0e8a16"
  ["in progress"]="fbca04"
  ["epic"]="3e4b9e"
  ["must-have"]="b60205"
  ["should-have"]="d93f0b"
  ["could-have"]="fbca04"
  ["wont-have"]="cccccc"
  ["template"]="c5def5"
  ["static"]="bfd4f2"
  ["submodules"]="ededed"
  ["kind/bug"]="d73a4a"
  ["kind/enhancement"]="a2eeef"
  ["kind/doc"]="0075ca"
  ["kind/question"]="d876e3"
  ["type/blocker"]="b60205"
  ["status/wontfix"]="ffffff"
  ["status/invalid"]="e4e669"
  ["status/duplicate"]="cfd3d7"
  ["status/blocked"]="b60205"
  ["status/confirmed"]="0e8a16"
  ["status/help wanted"]="008672"
  ["status/need feedback"]="fbca04"
  ["status/needs more info"]="fbca04"
  ["status/on hold"]="cccccc"
  ["status/won't do/fix"]="ffffff"
  ["status/can't reproduce"]="e4e669"
  ["future/maybe"]="bfd4f2"
  ["component/backend"]="c2e0c6"
  ["component/infra"]="5319e7"
  ["component/ui"]="1d76db"
  ["priority/critical"]="b60205"
  ["priority/high"]="d93f0b"
  ["priority/medium"]="fbca04"
  ["priority/low"]="cccccc"
  ["type/bug"]="d73a4a"
  ["type/build"]="5319e7"
  ["type/chore"]="ededed"
  ["type/ci"]="2088ff"
  ["type/discussion"]="d876e3"
  ["type/documentation"]="0075ca"
  ["type/enhancement"]="a2eeef"
  ["type/feature request"]="84b6eb"
  ["type/investigate"]="d93f0b"
  ["type/perf"]="0e8a16"
  ["type/question"]="d876e3"
  ["type/refactor"]="fbca04"
  ["type/security"]="b60205"
  ["type/test"]="c5def5"
  ["status: blocked"]="b60205"
  ["status: confirmed"]="0e8a16"
  ["status: duplicate"]="cfd3d7"
  ["status: help wanted"]="008672"
  ["status: invalid"]="e4e669"
  ["status: need feedback"]="fbca04"
  ["status: needs more info"]="fbca04"
  ["status: on hold"]="cccccc"
  ["status: won't do/fix"]="ffffff"
  ["status: can't reproduce"]="e4e669"
  ["future maybe"]="bfd4f2"
  ["component: backend"]="c2e0c6"
  ["component: infra"]="5319e7"
  ["component: ui"]="1d76db"
  ["priority: critical"]="b60205"
  ["priority: high"]="d93f0b"
  ["priority: medium"]="fbca04"
  ["priority: low"]="cccccc"
  ["type: bug"]="d73a4a"
  ["type: build"]="5319e7"
  ["type: chore"]="ededed"
  ["type: ci"]="2088ff"
  ["type: discussion"]="d876e3"
  ["type: documentation"]="0075ca"
  ["type: enhancement"]="a2eeef"
  ["type: feature request"]="84b6eb"
  ["type: investigate"]="d93f0b"
  ["type: perf"]="0e8a16"
  ["type: question"]="d876e3"
  ["type: refactor"]="fbca04"
  ["type: security"]="b60205"
  ["type: test"]="c5def5"
  ["github_actions"]="2088ff"
  ["devcontainers_package_manager"]="ededed"
  ["kubernetes"]="326ce5"
  ["notebook"]="da5b0b"
  ["ios"]="999999"
  ["android"]="3ddc84"
  ["go"]="00add8"
  ["golang"]="00add8"
  ["rust"]="dea584"
  ["kotlin"]="a97bff"
  ["javascript"]="f1e05a"
  ["typescript"]="3178c6"
  ["python"]="3572a5"
  ["html"]="e34c26"
  ["css"]="563d7c"
  ["dart"]="00b4ab"
  ["csharp"]="178600"
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
  repos=$(gh repo list --limit 1000 --visibility private --json nameWithOwner --jq '.[].nameWithOwner')
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
  want="${C[$key]:-}"
  if [[ -z "$want" ]]; then
    missing=$((missing+1)); echo "MISS $repo :: $name"; continue
  fi
  if [[ "${cur,,}" == "$want" ]]; then
    skipped=$((skipped+1)); continue
  fi
  enc=$(urlencode "$name")
  if gh api -X PATCH "repos/$repo/labels/$enc" -f color="$want" --silent 2>/dev/null; then
    updated=$((updated+1))
    echo "OK  $repo :: $name -> $want"
  else
    failed=$((failed+1))
    echo "FAIL $repo :: $name"
  fi
done < "$TSV"

echo
echo "updated=$updated skipped=$skipped missing=$missing failed=$failed"
