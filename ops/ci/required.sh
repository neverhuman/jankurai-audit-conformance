#!/usr/bin/env bash
# Required corpus check: confirm the conformance fixtures and expected reports
# are present and the generated output tree can be staged. This is the smallest
# proof that the corpus is intact before any audit lane replays it.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"

log "required lane: ci-local lane contract"
bash scripts/ci-local-lanes-test.sh

log "required lane: conformance corpus presence check"
test -d conformance/fixtures
test -d conformance/expected
mkdir -p target/jankurai
npm test
npm run typecheck
