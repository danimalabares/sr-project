#!/usr/bin/env python3
"""Lightweight semantic and integrity check for the fixed-jet completion."""

from hashlib import sha256
from pathlib import Path


ROOT = Path(__file__).resolve().parent
EXPECTED_TWO_JET_SHA256 = (
    "40e64e61674b6a4e61f1ea6822dc79327bf4ba397285f84ed8738c4c18cd1795"
)
EXPECTED_CERTIFICATE = {
    "field": "QQ",
    "macaulay2_required": "1.20",
    "VersalDeformations_version": "3.0",
    "base": "QQ[s]/(s^4)",
    "family_generators": "16",
    "complete_special_first_syzygies": "30",
    "quadratic_and_cubic_base_terms_at_y_zero": "true",
    "specialized_family_times_relations_zero": "true",
    "reduction_mod_s3_is_exported_two_jet": "true",
    "two_jet_sha256": EXPECTED_TWO_JET_SHA256,
}


def digest(path: Path) -> str:
    return sha256(path.read_bytes()).hexdigest()


certificate_path = ROOT / "verification" / "starting_jet_QQ.txt"
certificate = dict(
    line.split("=", 1)
    for line in certificate_path.read_text().splitlines()
    if line
)
assert certificate == EXPECTED_CERTIFICATE, certificate

generated = ROOT / "verification" / "starting_twojet_QQ.txt"
frozen = ROOT.parent / "referee-packet" / "data" / "universal_2jet_QQ.txt"
assert generated.read_bytes() == frozen.read_bytes()
assert digest(generated) == EXPECTED_TWO_JET_SHA256
assert digest(frozen) == EXPECTED_TWO_JET_SHA256

environment = dict(
    line.split("=", 1)
    for line in (ROOT.parent / "referee-packet" / "verification" / "environment.txt")
    .read_text()
    .splitlines()
    if line
)
assert environment["Macaulay2"] == "1.20"
assert environment["VersalDeformations"] == "3.0"
assert environment["VersalDeformations_source_sha256"] == (
    "3363126cce0237f2c3a7ab8a8438372c5adcf83a6fb5be1fb84e7cea9bd61c3a"
)

print("starting_deformation_flatness_inputs_verified=true")
print("starting_two_jet_matches_frozen_input=true")
print(f"universal_two_jet_sha256={EXPECTED_TWO_JET_SHA256}")
