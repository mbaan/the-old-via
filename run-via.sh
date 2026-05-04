#!/usr/bin/env bash
# Launch VIA 1.3.1 under Wine
set -e
cd "$(dirname "$0")/via-app"
export WINEDEBUG=-all
# Block the auto-updater's network calls so it doesn't try to "upgrade" to v3
exec wine VIA.exe "$@"
