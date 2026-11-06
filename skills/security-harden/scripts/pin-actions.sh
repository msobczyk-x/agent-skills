#!/usr/bin/env bash
# Resolve every `uses: owner/repo[/path]@ref` in the given workflow files to a full
# commit SHA, and report the latest release tag, so actions can be pinned as
#   uses: owner/repo@<sha> # vX.Y.Z
# Usage: pin-actions.sh [workflow.yml ...]   (defaults to .github/workflows/*)
# Requires: gh (authenticated), jq. Prints JSON to stdout; progress to stderr.
set -euo pipefail

command -v gh >/dev/null || { echo "gh CLI is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

if [ "$#" -eq 0 ]; then
  set -- .github/workflows/*.yml .github/workflows/*.yaml .github/actions/*/action.yml .github/actions/*/action.yaml
fi

# Collect unique "action@ref" pairs, skipping local (./) and docker:// references.
refs="$(for f in "$@"; do [ -f "$f" ] && cat "$f"; done \
  | sed -nE 's/^[[:space:]-]*uses:[[:space:]]*["'\'']?([^"'\''[:space:]#]+).*/\1/p' \
  | grep -v '^\./' | grep -v '^docker://' | grep '@' | sort -u || true)"

resolve_sha() {
  # Tags may be annotated: follow the tag object to its commit.
  local repo="$1" ref="$2" obj type sha
  if obj="$(gh api "repos/$repo/git/ref/tags/$ref" 2>/dev/null)"; then
    type="$(jq -r '.object.type' <<<"$obj")"
    sha="$(jq -r '.object.sha' <<<"$obj")"
    if [ "$type" = "tag" ]; then
      sha="$(gh api "repos/$repo/git/tags/$sha" --jq '.object.sha')"
    fi
    echo "$sha"
    return
  fi
  gh api "repos/$repo/commits/$ref" --jq '.sha' 2>/dev/null || echo ""
}

results="[]"
while IFS= read -r entry; do
  [ -z "$entry" ] && continue
  action="${entry%@*}"
  ref="${entry##*@}"
  repo="$(cut -d/ -f1-2 <<<"$action")"
  echo "Resolving $action@$ref..." >&2

  pinned=false
  if [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then pinned=true; fi

  current_sha="$ref"
  if [ "$pinned" = false ]; then current_sha="$(resolve_sha "$repo" "$ref")"; fi

  # Newest stable vX.Y.Z release; repos like codeql-action also publish unrelated bundle releases.
  latest_tag="$(gh api "repos/$repo/releases?per_page=50" \
    --jq '[.[] | select((.prerelease | not) and (.draft | not) and (.tag_name | test("^v[0-9]")))][0].tag_name // ""' \
    2>/dev/null || echo "")"
  if [ -z "$latest_tag" ]; then
    latest_tag="$(gh api "repos/$repo/releases/latest" --jq '.tag_name' 2>/dev/null || echo "")"
  fi
  latest_sha=""
  if [ -n "$latest_tag" ]; then latest_sha="$(resolve_sha "$repo" "$latest_tag")"; fi

  results="$(jq -c \
    --arg action "$action" --arg ref "$ref" --argjson pinned "$pinned" \
    --arg currentSha "$current_sha" --arg latestTag "$latest_tag" --arg latestSha "$latest_sha" \
    '. + [{
      action: $action,
      ref: $ref,
      pinned: $pinned,
      currentSha: ($currentSha | select(. != "") // null),
      latestTag: ($latestTag | select(. != "") // null),
      latestSha: ($latestSha | select(. != "") // null),
      suggestion: (if $latestSha != "" then "\($action)@\($latestSha) # \($latestTag)" else null end)
    }]' <<<"$results")"
done <<<"$refs"

jq . <<<"$results"
