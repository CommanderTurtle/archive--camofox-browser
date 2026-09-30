#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$root"

for command_name in bun git; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  }
done
for required in package.json bun.lock server.js lib/config.js audit.sh \
  doctor.sh integrate.sh update.sh; do
  [[ -f "$required" ]] || {
    printf 'Missing Camofox Browser owner file: %s/%s\n' "$root" "$required" >&2
    exit 1
  }
done

bash -n audit.sh doctor.sh integrate.sh update.sh
bun -e '
  const pkg = await Bun.file("package.json").json();
  for (const name of ["build", "start", "fetch-bin"]) {
    if (!pkg.scripts?.[name]) throw new Error(`missing package script: ${name}`);
  }
  process.env.BROWSER_IDLE_TIMEOUT_MS = "0";
  const { loadConfig } = await import(`./lib/config.js?doctor=${Date.now()}`);
  const config = loadConfig();
  if (config.browserIdleTimeoutMs !== 0) {
    throw new Error("BROWSER_IDLE_TIMEOUT_MS=0 must disable idle shutdown");
  }
'
grep -F 'BROWSER_IDLE_TIMEOUT_MS <= 0' server.js >/dev/null || {
  printf 'Camofox Browser no-idle-shutdown guard is missing.\n' >&2
  exit 1
}
[[ -f dist/plugin.js ]] || {
  printf 'Camofox Browser build is absent; run ./integrate.sh.\n' >&2
  exit 1
}
printf 'Camofox Browser source, Bun lock, build, and no-idle contract are healthy.\n'
