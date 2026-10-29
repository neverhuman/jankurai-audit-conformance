#!/usr/bin/env bash
# Hosted setup, followed by the unchanged offline required proof. Fresh runner
# slots have no node_modules; acquire exactly the committed lock before proof.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"

log "hosted setup: locked Node development dependencies"
npm ci --include=dev --ignore-scripts --no-audit --no-fund
exec bash scripts/ci-local.sh required
