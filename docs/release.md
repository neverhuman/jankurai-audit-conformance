# Release process

This document is the release control surface for jankurai-conformance. It covers
the version source, the changelog, the release automation, integrity and SBOM
evidence, and rollback. Launch gates require every section below to be backed by
a real artifact or command.

## Version source

The single source of truth for the corpus version is the [`VERSION`](../VERSION)
file at the repository root. Any release tag MUST match `VERSION`. Tags follow
the family pattern `jankurai-conformance-v<MAJOR.MINOR.PATCH>-split.<N>` as
described in [`SPLIT.md`](../SPLIT.md) and `agent/split-member.toml`.

## Changelog

[`CHANGELOG.md`](../CHANGELOG.md) is written when a release is cut: its notes
are generated from the commits since the previous release (their subjects and
`Todo:` trailers), under a heading that matches the new `VERSION`. Changes do not
add entries by hand. The `Unreleased` section is rolled up into the dated version
heading at tag time.

The release preparer runs this command before creating the release PR. Set
`PREVIOUS_RELEASE_TAG` to the last published release tag; `VERSION` must already
name the candidate version:

```sh
(
  set -eu
  : "${PREVIOUS_RELEASE_TAG:?set the previous published release tag}"
  tag_ref="refs/tags/$PREVIOUS_RELEASE_TAG"
  git rev-parse --verify --quiet "$tag_ref^{commit}" >/dev/null
  git merge-base --is-ancestor "$tag_ref" HEAD
  version=$(cat VERSION)
  mkdir -p target/release-notes
  notes=$(mktemp "target/release-notes/.$version.XXXXXX")
  trap 'rm -f "$notes"' EXIT
  {
    printf '## %s\n\n' "$version"
    git log --reverse --no-merges --format='- %s%n%(trailers:key=Todo)' "$tag_ref..HEAD"
  } > "$notes"
  mv "$notes" "target/release-notes/$version.md"
)
```

The command runs as a subshell with `set -eu`, so any failing step stops it
before the notes file is touched. It uses the full `refs/tags/` ref throughout,
so a branch with the same name as the tag cannot be picked up by mistake, and it
writes to a temporary file that replaces `target/release-notes/<version>.md`
only after `git log` succeeds. A missing tag, a tag that is not an ancestor of
`HEAD`, or an unset `PREVIOUS_RELEASE_TAG` leaves any earlier notes file as it
was. `scripts/release-notes-test.sh` runs this exact block against valid,
missing, non-ancestor and branch-shadowed tags.

Review that generated file for compatibility changes and rollback commits, then
insert the version block into `CHANGELOG.md` in the release PR. Preserve all
historical entries and carry existing pending `Unreleased` notes into the
release they describe. The command above performs generation; publication does
not invoke an implicit generator. Record rollback details in the revert commit
so the same command includes them in the next release.

## Release automation

GitHub is a publishing mirror only. CI runs on the forge and our own hosts, and
releases are built and signed on our servers. A separate change introduces
key-based release signing.

1. Bump [`VERSION`](../VERSION), generate the release notes from the commits
   since the previous release tag, and roll the `Unreleased` section of
   [`CHANGELOG.md`](../CHANGELOG.md) under the new version heading.
2. Run the full local gate: `just check` (setup, fast lane, security,
   self-audit) or `bash scripts/ci-local.sh all`.
3. Push the version commit through a forge pull request. The forge CI runs the
   build/fast, security, and jankurai audit lanes and keeps the `repo-score`
   artifacts.
4. Tag the release commit with `jankurai-conformance-v<version>-split.<N>`. The
   tag mirror in [`.jeryu/repo.toml`](../.jeryu/repo.toml) publishes the
   immutable tag to the public GitHub mirror.

Release builds depend on immutable tags, never branches.

## Integrity, provenance, and SBOM

- **Corpus integrity**: each fixture carries a `jankurai-fixture.toml` manifest
  and a matching `conformance/expected/*.json` report, so any released corpus
  state is reproducible by replaying the runner and diffing against the expected
  reports.
- **SBOM**: the corpus ships no third-party runtime dependencies of its own; the
  software bill of materials for any tooling is produced by the hub auditor's
  `jankurai security run` (CycloneDX JSON) and attached to the release as
  `sbom.json`.
- **Provenance**: the security job runs `gitleaks detect` for secret scanning
  (the adversarial fixtures are excluded so their deliberate test secrets do not
  mask real leaks) and the audit job publishes the `repo-score` artifacts that
  prove the release passed the jankurai gate.

## Launch-gate evidence

Every release of the corpus must clear the following launch gates, each backed
by a real command or artifact (not prose):

- **Security**: `bash ops/ci/security.sh` runs `gitleaks detect` (secret
  scanning) and `cargo audit` (dependency advisories); the adversarial fixtures
  are excluded so their deliberate test secrets do not mask real leaks. The
  jankurai self-audit (`just audit`) must report zero hard findings.
- **Backups**: the corpus is its own backup of record. Every fixture is pinned
  by its `jankurai-fixture.toml` manifest and a matching
  `conformance/expected/*.json` report, and the authoritative copy lives in the
  Jeryu repo (`root/jankurai-conformance`) with the GitHub mirror as a second
  durable copy. Any release state is recoverable by checking out its immutable
  tag.
- **Monitoring**: the audit lane publishes `.jankurai/repo-score.json` and
  `.jankurai/repo-score.md` on every CI run, and the score history is tracked so
  a regression in detected/expected parity is observable before tagging.
- **Rollback**: documented below; tags are immutable and every fixture pins its
  expected report, so any prior corpus release replays bit-for-bit.
- **Abuse controls**: the deliberately-failing fixtures (leaked secrets,
  destructive migrations, unsafe rendering, overbroad agency) are the abuse and
  misuse cases the auditor must keep detecting. They are corpus data, scored as
  detection evidence, never merged into the product surface; the scan exclusion
  in [`agent/audit-policy.toml`](../agent/audit-policy.toml) keeps them quarantined
  from this repo's own score.

## Rollback

If a corpus release regresses:

1. Identify the last known-good tag
   (`jankurai-conformance-v<version>-split.<N>`).
2. Re-point consumers at that immutable tag; tags are never moved or deleted.
3. Open a revert commit that restores the previous `VERSION` and
   `CHANGELOG.md` state, with a commit subject that says the release was rolled
   back; the next release's notes pick it up.
4. Re-run `just check` to confirm the rolled-back tree is green before
   re-publishing.

Because tags are immutable and every fixture pins its expected report, any prior
corpus release can be replayed and verified bit-for-bit from its tag.
