# Changelog

All notable changes to jankurai-conformance are documented in this file. The
format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
The authoritative version string lives in [`VERSION`](VERSION).

## [Unreleased]

### Removed

- GitHub Actions workflows, the GitHub-only job aggregator
  (`ops/ci/aggregate.sh`), and the zizmor/actionlint workflow scans. GitHub is a
  publishing mirror only; CI runs on the forge and our own hosts, and releases
  are built and signed on our servers.

### Added

- Root `Justfile` command surface with `setup`, `fast`, `check`, `security`, and
  `audit` lanes for one-command setup and validation of the conformance corpus.
- GitHub Actions CI (`.github/workflows/ci.yml`) with build/fast, security, and
  jankurai audit jobs, all third-party actions pinned to commit SHAs.
- `ops/ci/` lane scripts (`lib.sh`, `required.sh`, `fast.sh`, `security.sh`,
  `audit.sh`, `quality-gates.sh`) shared by local runs and CI.
- Agent-readable documentation: `README.md`, `docs/architecture.md`,
  `docs/boundaries.md`, `docs/release.md`, and `docs/exceptions.md`.
- `agent/audit-policy.toml` excluding the adversarial `conformance/fixtures` and
  `conformance/expected` corpus trees from self-audit scoring.
- `agent/boundaries.toml` declaring this repo as a data/corpus boundary.
- `VERSION` and this changelog for release tracking.

### Changed

- Re-scoped `agent/owner-map.json`, `agent/test-map.json`, and
  `agent/generated-zones.toml` to the paths that actually exist in this repo.

## [1.7.0] - 2026-06-12

### Added

- Initial split-family extraction of the jankurai conformance corpus: seed
  fixtures, expected reports, and the conformance-results JSON Schema.
