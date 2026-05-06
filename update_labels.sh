#!/usr/bin/env bash
# Apply unified label colors across all private repos.
set -u

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
  ["github_actions"]="2088ff"
  ["devcontainers_package_manager"]="ededed"
  ["kubernetes"]="326ce5"
  ["notebook"]="da5b0b"
  ["ios"]="999999"
  ["android"]="3ddc84"
  ["go"]="00add8"
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
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      *) printf -v hex '%%%02X' "'$c"; out+="$hex" ;;
    esac
  done
  printf '%s' "$out"
}

updated=0; skipped=0; missing=0; failed=0
while IFS=$'\t' read -r repo name cur desc; do
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
done < /tmp/all_labels.tsv

echo
echo "updated=$updated skipped=$skipped missing=$missing failed=$failed"
