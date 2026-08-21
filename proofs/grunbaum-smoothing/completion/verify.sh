#!/bin/sh
set -eu

cd "$(dirname "$0")"

# Reuse the frozen packet's exact executable and package-source pin.
if command -v python3.13 >/dev/null 2>&1; then
  completion_python="$(command -v python3.13)"
else
  completion_python="$(command -v python3)"
fi
"$completion_python" ../referee-packet/code/check_environment.py >/dev/null
M2 --script verify_starting_jet.m2 --no-randomize
"$completion_python" check_results.py
shasum -a 256 -c MANIFEST.sha256
