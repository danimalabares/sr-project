# Provenance

This directory was assembled on 2026-08-19 as an organization-only copy of
existing frozen evidence. No scientific source, certificate, verification
output, or audit text was revised.

## Source-to-destination map

| Original source | Destination | Preservation check |
| --- | --- | --- |
| `/Users/daniel/github/grunbaum-smoothing-referee/` | `referee-packet/` | 20/20 manifest entries passed; source and destination manifest SHA-256 `ffc6cb2dbc77a1c0d8e71c8828a3f5e729598db4a94754e56f5426ec09176ce9` |
| `/Users/daniel/github/grunbaum-tate-stage-audit/` | `audits/tate-stage/` | 33/33 manifest entries passed; source and destination manifest SHA-256 `18cc574e3c914e0a44789e3c900e7fae7c8c6b056fcc7504773e07785b549829` |
| `/Users/daniel/github/TERMINOLOGY_AND_FOUNDATIONS_AUDIT.md` | `audits/terminology-and-foundations.md` | byte-for-byte copy; SHA-256 `00f9dc9a19935f780184a0b092e5d31977d374952b8e6e17a03e01db7b8703cf` |

The directories were copied recursively with preservation enabled, and the
standalone audit was copied as a single preserved file. No source was moved or
deleted. The two source directories contain no symlinks or unmanifested files;
their only file beyond the covered entries is each manifest itself.

## Pre-copy verification

Before copying:

- every entry in both source manifests passed `shasum -a 256 -c`;
- the referee packet's lightweight result checker reported
  `all_exact_checks_passed=true`;
- the Tate-stage audit's lightweight result checker reported
  `AUDIT_REPLAY_CERTIFIED`;
- the Tate candidate input SHA-256 was
  `9e0691837d69ba2027cca1fef52e0598dcd83f0bc65e2c88379061bce9caa396`;
- the referee construction file `code/verify_aq_bracket.m2` had SHA-256
  `7b49da5c17ccbff951b94384b547adcd6c73f8b151a95d8a78c3afa5d6b39f18`,
  matching both its manifest and the Tate audit provenance; and
- the referee two-jet `data/universal_2jet_QQ.txt` had SHA-256
  `40e64e61674b6a4e61f1ea6822dc79327bf4ba397285f84ed8738c4c18cd1795`,
  matching its recorded replay output.

These were integrity checks only. The expensive CAS computations were not
rerun.

## Release archive

The external release archive
`/Users/daniel/github/grunbaum-smoothing-referee.tar.gz` has SHA-256

```text
8244ef6272f895d787c9b21fe9f757e8a1ad67db9dde96ad7be774289193c57b
```

This agrees with the release-archive digest frozen in
`audits/tate-stage/data/provenance.json`. The archive's embedded manifest has
SHA-256
`ffc6cb2dbc77a1c0d8e71c8828a3f5e729598db4a94754e56f5426ec09176ce9`,
and all 20 archived payload members passed that manifest in a streaming
pre-copy check. The archive is therefore a duplicate transport container and
has deliberately not been copied into this repository.

The exact historical archive has now been copied byte-for-byte into the
tracked snapshot
`snapshots/grunbaum-smoothing-referee.tar.gz`. Its SHA-256 is still
`8244ef6272f895d787c9b21fe9f757e8a1ad67db9dde96ad7be774289193c57b`; a direct
`cmp` against the external archive passed. This snapshot is the preserved
release container; the regeneration recipe below is for producing a new
release container later and is not expected to reproduce historical gzip/tar
metadata exactly.

To regenerate a release archive later without modifying the preserved packet,
stage a copy under the original top-level directory name and archive it:

```sh
repo=/Users/daniel/github/sr-project
staging_dir="$(mktemp -d)"
archive_out=/desired/new/location/grunbaum-smoothing-referee.tar.gz
cp -pR "$repo/proofs/grunbaum-smoothing/referee-packet" \
  "$staging_dir/grunbaum-smoothing-referee"
(
  cd "$staging_dir"
  env COPYFILE_DISABLE=1 tar -czf "$archive_out" grunbaum-smoothing-referee
)
shasum -a 256 "$archive_out"
```

Then extract into a fresh temporary directory and run
`shasum -a 256 -c MANIFEST.sha256` from its packet root. The payload manifest,
not equality with the historical archive digest, is the reliable regeneration
check: gzip/tar metadata and compressor differences can change the container
SHA-256 while leaving every packet byte unchanged. The historical digest
above identifies the original release archive exactly.
