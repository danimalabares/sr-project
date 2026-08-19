#!/usr/bin/env python3
"""Reject partial/stale CAS runs and summarize the exact replay verdict."""

from __future__ import annotations

import hashlib
import json
import os
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
VERIFICATION = ROOT / "verification"

EXPECTED_CANDIDATE_SHA256 = (
    "9e0691837d69ba2027cca1fef52e0598dcd83f0bc65e2c88379061bce9caa396"
)
EXPECTED_GENERATED_M2_SHA256 = (
    "7525d9311a966afb1c543c83b586d1452fd584d00cd7b52eea24c0289aa1f492"
)
EXPECTED_GENERATED_SINGULAR_SHA256 = (
    "c3b9ce4a6f71601abe28b1d051e49bbcb0cb761ba6f024e3d23c0877541c307b"
)
EXPECTED_INPUT_LOG = """candidate_sha256=9e0691837d69ba2027cca1fef52e0598dcd83f0bc65e2c88379061bce9caa396
candidate_format=tate-stage-sparse-v1
matrix_shapes=F:1x16,R:16x30,Z:150x136
"""
EXPECTED_M2_SUMMARY = {
    "verdict": "certified",
    "field": "QQ",
    "D1_shape": "1x16",
    "D2_shape": "16x150",
    "D3_shape": "150x1040",
    "Z_shape": "150x136",
    "B_shape": "150x1176",
    "D1_D2_zero": "true",
    "D2_D3_zero": "true",
    "D2_Z_zero": "true",
    "ker_D1_equals_im_D2": "true",
    "ker_D2_equals_im_D3_Z": "true",
    "K1_generators": "30",
    "K2_generators": "136",
    "certificate": "verification/m2_lifts.generated.m2",
}
EXPECTED_M2_FULL_LOG = """MACAULAY2_LOW_TATE_STAGE_CERTIFIED
K1_generators=30
K2_generators=136
certificate=verification/m2_lifts.generated.m2
"""
EXPECTED_M2_RETAINED_LOG = "RETAINED_MACAULAY2_LIFTS_VERIFIED\n"
EXPECTED_SINGULAR_FULL_LOG = """SINGULAR_LOW_TATE_STAGE_CERTIFIED
K1_generators=31
K2_generators=141
L1_shape=150x31
L2_shape=1176x141
"""
EXPECTED_SINGULAR_RETAINED_LOG = "RETAINED_SINGULAR_LIFTS_VERIFIED\n"


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def read_exact(relative: str, expected: str) -> None:
    observed = (ROOT / relative).read_text(encoding="utf-8")
    if observed != expected:
        raise RuntimeError(f"unexpected semantic output in {relative}: {observed!r}")


def read_key_values(relative: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in (ROOT / relative).read_text(encoding="utf-8").splitlines():
        if line.count("=") != 1:
            raise RuntimeError(f"malformed key/value line in {relative}: {line!r}")
        key, value = line.split("=", 1)
        if not key or key in result:
            raise RuntimeError(f"empty or duplicate key in {relative}: {key!r}")
        result[key] = value
    return result


def reject_symlinks() -> None:
    for directory, names, files in os.walk(ROOT, followlinks=False):
        for name in names + files:
            path = pathlib.Path(directory, name)
            if path.is_symlink():
                raise RuntimeError(f"packet contains a symbolic link: {path.relative_to(ROOT)}")


def verify_manifest() -> None:
    manifest_path = ROOT / "MANIFEST.sha256"
    raw = manifest_path.read_bytes()
    if b"\r" in raw or not raw.endswith(b"\n"):
        raise RuntimeError("manifest must use LF lines and end with a newline")
    records: list[tuple[str, str]] = []
    for lineno, line in enumerate(raw.decode("utf-8").splitlines(), 1):
        match = re.fullmatch(r"([0-9a-f]{64})  ([^/].*)", line)
        if not match:
            raise RuntimeError(f"malformed manifest line {lineno}")
        digest, relative = match.groups()
        parts = pathlib.PurePosixPath(relative).parts
        if not parts or any(part in {"", ".", ".."} for part in parts):
            raise RuntimeError(f"non-normal manifest path: {relative!r}")
        records.append((relative, digest))
    paths = [relative for relative, _ in records]
    if paths != sorted(paths) or len(paths) != len(set(paths)):
        raise RuntimeError("manifest paths are unsorted or duplicated")

    inventory: list[str] = []
    for directory, _, files in os.walk(ROOT, followlinks=False):
        for name in files:
            path = pathlib.Path(directory, name)
            relative = path.relative_to(ROOT).as_posix()
            if relative != "MANIFEST.sha256":
                inventory.append(relative)
    inventory.sort()
    if paths != inventory:
        missing = sorted(set(inventory) - set(paths))
        extra = sorted(set(paths) - set(inventory))
        raise RuntimeError(f"manifest inventory mismatch: missing={missing}, extra={extra}")
    for relative, expected in records:
        observed = sha256(ROOT / relative)
        if observed != expected:
            raise RuntimeError(f"manifest digest mismatch for {relative}")


def main() -> int:
    reject_symlinks()
    failure = VERIFICATION / "FAILED_CLASS.m2"
    if failure.exists():
        raise RuntimeError(f"failure witness exists: {failure.relative_to(ROOT)}")

    provenance = json.loads((ROOT / "data/provenance.json").read_text(encoding="utf-8"))
    frozen = provenance["frozen_input"]
    candidate_sha = sha256(ROOT / "data/tate_candidate.tsv")
    if candidate_sha != EXPECTED_CANDIDATE_SHA256:
        raise RuntimeError(f"wrong frozen-candidate digest: {candidate_sha}")
    if frozen["canonical_input_sha256"] != candidate_sha:
        raise RuntimeError("provenance and frozen-candidate digests disagree")
    if provenance["source_packet"] != {
        "observed_root": "/Users/daniel/github/grunbaum-smoothing-referee",
        "release_archive_sha256": "8244ef6272f895d787c9b21fe9f757e8a1ad67db9dde96ad7be774289193c57b",
        "manifest_sha256": "ffc6cb2dbc77a1c0d8e71c8828a3f5e729598db4a94754e56f5426ec09176ce9",
        "manifest_all_entries_verified": True,
        "construction_file": "code/verify_aq_bracket.m2",
        "construction_file_sha256": "7b49da5c17ccbff951b94384b547adcd6c73f8b151a95d8a78c3afa5d6b39f18",
        "construction_file_manifest_sha256": "7b49da5c17ccbff951b94384b547adcd6c73f8b151a95d8a78c3afa5d6b39f18",
    }:
        raise RuntimeError("unexpected source-packet provenance")
    method = provenance["observation_method"]
    if method["extractor_sha256"] != sha256(ROOT / method["extractor"]):
        raise RuntimeError("provenance extractor digest disagrees with packet")
    if method["canonicalizer_sha256"] != sha256(ROOT / method["canonicalizer"]):
        raise RuntimeError("provenance canonicalizer digest disagrees with packet")
    if provenance["separation_of_roles"]["certification_uses_DGAlgebras_or_killCycles"]:
        raise RuntimeError("provenance incorrectly says certification uses DG code")

    read_exact("verification/input_validation.txt", EXPECTED_INPUT_LOG)
    if sha256(VERIFICATION / "generated_input.m2") != EXPECTED_GENERATED_M2_SHA256:
        raise RuntimeError("unexpected generated Macaulay2 input")
    if sha256(ROOT / "data/tate_input.sing") != EXPECTED_GENERATED_SINGULAR_SHA256:
        raise RuntimeError("unexpected generated Singular input")

    observed_summary = read_key_values("verification/m2_summary.txt")
    if observed_summary != EXPECTED_M2_SUMMARY:
        raise RuntimeError(f"unexpected Macaulay2 summary: {observed_summary!r}")

    read_exact("verification/macaulay2_full.txt", EXPECTED_M2_FULL_LOG)
    read_exact("verification/macaulay2_retained.txt", EXPECTED_M2_RETAINED_LOG)
    read_exact("verification/singular_summary.txt", EXPECTED_SINGULAR_FULL_LOG)
    read_exact("verification/singular_retained.txt", EXPECTED_SINGULAR_RETAINED_LOG)
    read_exact(
        "verification/environment_check.txt",
        (VERIFICATION / "environment.txt").read_text(encoding="utf-8"),
    )

    generated = VERIFICATION / "m2_lifts.generated.m2"
    retained = ROOT / "data/m2_lift_certificate.m2"
    if generated.read_bytes() != retained.read_bytes():
        raise RuntimeError("fresh Macaulay2 certificate differs from frozen certificate")
    if generated.stat().st_size < 100_000:
        raise RuntimeError("Macaulay2 certificate is unexpectedly small")
    singular_generated = VERIFICATION / "singular_lifts.generated.dump"
    singular_retained = ROOT / "data/singular_lift_certificate.dump"
    if singular_generated.read_bytes() != singular_retained.read_bytes():
        raise RuntimeError("fresh Singular certificate differs from frozen certificate")
    if singular_retained.stat().st_size < 100_000:
        raise RuntimeError("Singular certificate dump is unexpectedly small")

    lines = [
        "verdict=certified",
        "field=QQ",
        f"candidate_sha256={candidate_sha}",
        f"m2_certificate_sha256={sha256(retained)}",
        f"singular_certificate_sha256={sha256(singular_retained)}",
        "macaulay2_full_syzygy_recomputation=passed",
        "macaulay2_retained_lifts=passed",
        "singular_full_syzygy_recomputation=passed",
        "singular_retained_lifts=passed",
        "ker_D1_equals_im_D2=true",
        "ker_D2_equals_im_D3_Z=true",
    ]
    summary = "\n".join(lines) + "\n"
    (VERIFICATION / "replay_summary.txt").write_text(summary, encoding="utf-8")
    verify_manifest()
    print("AUDIT_REPLAY_CERTIFIED")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (KeyError, OSError, UnicodeError, ValueError, json.JSONDecodeError, RuntimeError) as error:
        print(f"AUDIT_REPLAY_FAILED: {error}", file=sys.stderr)
        raise SystemExit(2)
