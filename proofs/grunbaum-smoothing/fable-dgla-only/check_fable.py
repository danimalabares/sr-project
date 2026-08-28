#!/usr/bin/env python3
"""Strict-source contract and certificate check for fable-dgla-only.

1. The two proof sources must not contain any of the superseded
   higher-operation constructs (AUDIT.md deliberately names them and is
   outside this scan).
2. They must contain the ordinary Maurer-Cartan and strict Bianchi
   formulas.
3. The certificate written by verify_fable_dgla.m2 must contain exactly
   the expected semantic lines.
"""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent
PROOF_FILES = [ROOT / "PROOF_DGLA.tex", ROOT / "DG_LIE_INDUCTION.tex"]

BANNED = {
    "L-infinity notation": re.compile(r"\bL\s*[_^]\s*\\?infty"),
    "homotopy transfer": re.compile(r"homotopy[\s-]+transfer", re.I),
    "minimal model": re.compile(r"minimal\s+(L?[- ]?infinity\s+)?model", re.I),
    "higher bracket": re.compile(r"higher\s+bracket", re.I),
    "ell_n operation notation": re.compile(r"\\ell_[a-zA-Z0-9]", re.I),
    "A-infinity": re.compile(r"\bA\s*[_^]\s*\\?infty"),
}

for path in PROOF_FILES:
    text = path.read_text(encoding="utf-8")
    for label, pattern in BANNED.items():
        match = pattern.search(text)
        if match:
            raise AssertionError(
                f"{path.name}: forbidden {label}: {match.group(0)!r}")
    assert r"\partial\alpha+\tfrac12[\alpha,\alpha]" in text \
        or r"\partial\gamma+\tfrac12[\gamma,\gamma]" in text, path.name

# The strict Bianchi identity must appear in both sources.
for path in PROOF_FILES:
    text = path.read_text(encoding="utf-8")
    assert re.search(
        r"\\partial\\mathcal F\(\\gamma\)\+\[\\gamma,\\mathcal F\(\\gamma\)\]=0",
        text), f"{path.name}: strict Bianchi identity not found"

expected = {
    "field": "QQ",
    "VersalDeformations_version": "3.0",
    "relative_H1_dimension": "109",
    "coordinate_boundary_image_dimension": "56",
    "absolute_H1_dimension": "53",
    "relative_minus_coordinate_equals_absolute": "true",
    "T2_degree_zero_dimension": "27",
    "base_equations_vanish_at_y_through_order_three": "true",
    "specialized_family_times_relations_zero": "true",
    "complete_special_first_syzygies": "30",
    "family_corrections_homogeneous_x_degree_3": "true",
    "relation_corrections_homogeneous_x_degree_1": "true",
    "starting_mc_linear_e_values_equal_T1_y": "true",
    "two_jet_matches_frozen_input": "true",
}
certificate_path = ROOT / "verification" / "fable_dgla_QQ.txt"
observed = dict(
    line.split("=", 1)
    for line in certificate_path.read_text(encoding="utf-8").splitlines()
    if line
)
assert observed == expected, observed

# The regenerated two-jet must be byte-identical to the frozen input.
frozen = ROOT.parent / "referee-packet" / "data" / "universal_2jet_QQ.txt"
regenerated = ROOT / "verification" / "fable_twojet_QQ.txt"
assert regenerated.read_bytes() == frozen.read_bytes()

print("fable_source_scan_passed=true")
print("fable_certificate_passed=true")
print("fable_twojet_bytes_match_frozen=true")
