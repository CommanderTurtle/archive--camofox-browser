#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$root"

bun install --no-save
bun run build
chmod +x -- audit.sh doctor.sh integrate.sh update.sh
"$root/doctor.sh"
printf 'Camofox Browser is built and diagnosed. No browser process was started.\n'
