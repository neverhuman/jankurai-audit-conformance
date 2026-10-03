# ops/ Agent Instructions

This cell owns the pinned CI entrypoints for jankurai-conformance.

## Owns

- `ops/ci/*.sh` — the lane scripts (`lib.sh`, `required.sh`, `fast.sh`,
  `security.sh`, `audit.sh`, `tool-adoption.sh`, `quality-gates.sh`) that both
  local runs and the forge CI call.
- `ops/git-hooks/pre-push` — the mandatory pre-push gate.

## Forbidden

- Do not add GitHub Actions workflows. GitHub is a publishing mirror only; CI
  runs on the forge and our own hosts and delegates to `ops/ci/<lane>.sh` so
  local and CI runs never drift.
- Do not hard-code absolute paths or secrets; resolve the repo root via
  `ops/ci/lib.sh` and read tool version pins from there.
- Do not edit the corpus under `conformance/fixtures` or `conformance/expected`
  from a CI lane; those trees are read-only test data.

## Proof lane

Run `bash scripts/ci-local.sh all` (or `just check`) to execute every lane this
cell owns. The narrow loop is `bash ops/ci/fast.sh` (corpus check + jankurai
self-audit).
