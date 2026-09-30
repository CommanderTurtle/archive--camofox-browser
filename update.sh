#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_args=()
owner_args=()
for argument in "$@"; do
  if [[ "$argument" == "--dry-run" ]]; then
    repository_args+=("$argument")
  else
    owner_args+=("$argument")
  fi
done
exec sandwich repository update \
  --root="$root" \
  --source-remote="${CAMOFOX_BROWSER_SOURCE_REMOTE:-upstream}" \
  --source-url="${CAMOFOX_BROWSER_SOURCE_URL:-https://github.com/jo-inc/camofox-browser.git}" \
  --source-branch="${CAMOFOX_BROWSER_SOURCE_BRANCH:-master}" \
  --fork-remote="${CAMOFOX_BROWSER_FORK_REMOTE:-fork}" \
  --fork-url="${CAMOFOX_BROWSER_FORK_URL:-https://github.com/CommanderTurtle/archive--camofox-browser.git}" \
  --fork-branch="${CAMOFOX_BROWSER_FORK_BRANCH:-master}" \
  --publish-mode=ff \
  --verify=integrate.sh \
  --commit-message="chore: refresh Camofox Browser dependencies" \
  "${repository_args[@]}" -- "${owner_args[@]}"
