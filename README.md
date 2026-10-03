# jankurai-conformance

<!-- jankurai-badge:start -->
[![Jankurai score: 91/100](agent/jankurai-badge.svg)](agent/jankurai-badge.json)
<!-- jankurai-badge:end -->

[![jankurai score](https://img.shields.io/badge/jankurai%20score-pass-brightgreen)](.jankurai/repo-score.md)

Conformance fixtures, expected reports, and acceptance corpus data for the
**jankurai** auditor. This repository is one member of the Jankurai split
family; read [`SPLIT.md`](SPLIT.md) for the family contract and
[`AGENTS.md`](AGENTS.md) for agent routing rules.

## Stack

This is a data/corpus repository, not a product surface. It ships the versioned
test corpus the jankurai auditor (Rust core + TypeScript/React/Vite product
surface + PostgreSQL truth + generated contracts + exception-only Python
AI/data service) is replayed against. See
[`docs/architecture.md`](docs/architecture.md) for how the corpus is organized.

## Quick start

```bash
# One-command setup (verify the corpus is present, stage output tree).
just setup

# Deterministic fast lane (corpus check + jankurai self-audit).
just fast

# Full local check: setup, fast, security, and self-audit.
just check
```

The full command surface lives in the root [`Justfile`](Justfile). GitHub is a
publishing mirror only: continuous integration runs the same lanes on the forge
and our own hosts.

## Layout

| Path | Role |
| --- | --- |
| `conformance/fixtures` | deliberately-failing and passing seed repositories |
| `conformance/expected` | expected repo-score and merge-witness reports per fixture |
| `schemas/` | JSON Schema for the conformance results artifact |
| `agent/` | machine-readable owner, test, generated-zone, and policy maps |
| `docs/` | architecture, testing, boundaries, release, and exception docs |
| `ops/` | pinned CI script entrypoints |
| `scripts/` | local CI helper |

## Documentation

- [Architecture](docs/architecture.md)
- [Testing](docs/testing.md)
- [Boundaries](docs/boundaries.md)
- [Release process](docs/release.md)
- [Agent exceptions and overrides](docs/exceptions.md)

## Versioning

The current corpus version is recorded in [`VERSION`](VERSION) and the change
history in [`CHANGELOG.md`](CHANGELOG.md). Release mechanics are documented in
[`docs/release.md`](docs/release.md).

## License

See [`LICENSE`](LICENSE).
