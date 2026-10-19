#!/bin/bash
# Mochi modification: the upstream installer is replaced by the local Mochi build.
# This wrapper cannot replace /Applications/Mochi.app.
set -euo pipefail
exec "$(dirname "$0")/make-mochi.sh" "$@"
