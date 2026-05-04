#!/usr/bin/env bash
# Launch VIA 1.3.1 under Wine.
# Expects ./via-app/VIA.exe at the repo root (extract from the installer first;
# see linux/README.md). This script lives in linux/, hence the ../via-app.
set -e
cd "$(dirname "$0")/../via-app"
export WINEDEBUG=-all
exec wine VIA.exe "$@"
