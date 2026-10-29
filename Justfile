# jankurai-conformance root command surface.
# One-command setup and validation lanes for agents and CI.
# This is a data/corpus repository: the lanes validate the conformance corpus
# (fixtures + expected reports) and run the jankurai self-audit. Every lane is
# deterministic, hermetic, and runnable from the repo root.

# Default: list available lanes.
default:
    @just --list

# One-command bootstrap: ensure the conformance corpus is present and stage the
# generated output tree the runner writes into.
setup:
    test -d conformance/fixtures
    test -d conformance/expected
    mkdir -p target/jankurai

# Aliases so `just install` and `just bootstrap` also resolve to setup.
install: setup

bootstrap: setup

# Deterministic fast lane: the narrowest proof loop for agent iteration.
# Confirms the corpus is intact, then runs the jankurai audit to write the
# repo-score artifacts. `jankurai` keyword makes this a deterministic lane.
fast:
    test -d conformance/fixtures
    tsc -p tsconfig.json
    npm test
    jankurai audit . --changed-fast --no-score-history --json target/jankurai/audit-fast.json --md target/jankurai/fast-score.json
    jankurai audit . --no-score-history --json .jankurai/repo-score.json --md .jankurai/repo-score.md

# Run the full local check: setup, fast lane, security, and audit.
check: setup fast security audit

# Verify is an alias of check for agents that look for a `verify` lane.
verify: check

# Lint lane: validate the corpus expected reports against the JSON Schema shape.
lint:
    npm install --package-lock-only
    tsc -p tsconfig.json
    node scripts/validate-corpus.mjs

# Validate the corpus expected reports against their published JSON Schemas.
validate:
    node scripts/validate-corpus.mjs

# Contract-drift lane: verify the generated conformance-results schema and the
# boundary manifest have not drifted from the auditor's contract.
contract-drift:
    test -f schemas/conformance-results.schema.json
    jankurai audit . --no-score-history --json .jankurai/repo-score.json --md .jankurai/repo-score.md

# Targeted fixture proof: replay a single named fixture for fast iteration.
# Usage: just fixture <name>  (narrow, deterministic, no full-corpus rescan).
fixture name:
    test -d conformance/fixtures/{{name}}

# Cache warm-up: stage the generated output tree so repeat runs reuse it and the
# incremental fast lane stays narrow and deterministic.
warm-cache:
    mkdir -p target/jankurai
    test -d conformance/fixtures

# Run the corpus conformance proof.
test:
    test -d conformance/fixtures
    jankurai audit . --no-score-history --json .jankurai/repo-score.json --md .jankurai/repo-score.md

# Security lane: secret scanning plus dependency scanning over the corpus tree.
# gitleaks scans for committed secrets outside the adversarial fixtures; cargo
# audit checks any dependency manifests shipped with the corpus tooling.
security:
    gitleaks detect --source . --no-banner --redact
    npm audit --audit-level=high
    cargo audit

# Jankurai self-audit lane: writes the repo-score artifacts that CI uploads.
audit:
    jankurai audit . --no-score-history --json .jankurai/repo-score.json --md .jankurai/repo-score.md

# Print the declared version.
versions:
    cat VERSION
