#!/usr/bin/env bash
# Deterministic fast lane: the narrowest proof loop for agent iteration.
# Confirms the conformance corpus is intact, then runs the jankurai self-audit
# to write the repo-score artifacts. The identical command set is exposed
# locally via `just fast` and `bash scripts/ci-local.sh fast`.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"
require_auditor

log "fast lane: corpus check + targeted validation + jankurai audit"
test -d conformance/fixtures
test -d conformance/expected
mkdir -p .jankurai target/jankurai
# Targeted type-check of the validation script, then corpus schema validation.
tsc -p tsconfig.json
npm test
# Targeted, changed-only fast pass writes target-only fast-score artifacts so
# repeat runs stay narrow and deterministic.
"$JANKURAI_BIN" audit . --changed-fast --changed-from origin/main --no-score-history --json target/jankurai/audit-fast.json --md target/jankurai/fast-score.json
"$JANKURAI_BIN" audit . --no-score-history --json .jankurai/repo-score.json --md .jankurai/repo-score.md --full
