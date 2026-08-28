#!/usr/bin/env python3
"""Check the new strict-source contract and its controller certificate."""

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parent
PROOF_FILES = [ROOT / "PROOF_DGLA.tex", ROOT / "DG_LIE_INDUCTION.tex"]

# These patterns are forbidden in the proof sources.  AUDIT.md necessarily
# names the superseded machinery and is intentionally outside this scan.
BANNED = {
    "infinity algebra notation": re.compile(r"L\s*[_^]\\?infty", re.I),
    "homotopy transfer": re.compile(r"homotopy\s+transfer", re.I),
    "minimal infinity model": re.compile(r"minimal\s+.*model", re.I),
    "higher bracket": re.compile(r"higher\s+bracket", re.I),
    "ell-operation notation": re.compile(r"\\ell_[a-z0-9]", re.I),
}

for path in PROOF_FILES:
    text = path.read_text(encoding="utf-8")
    for label, pattern in BANNED.items():
        match = pattern.search(text)
        if match:
            raise AssertionError(f"{path.name}: forbidden {label}: {match.group(0)!r}")
    assert r"\partial\alpha+\frac12[\alpha,\alpha]" in text
    assert r"\partial\mathcal F(\gamma)+[\gamma,\mathcal F(\gamma)]=0" in text

expected = {
    "field": "QQ",
    "VersalDeformations_version": "3.0",
    "relative_H1_dimension": "109",
    "coordinate_boundary_image_dimension": "56",
    "absolute_H1_dimension": "53",
    "relative_minus_coordinate_equals_absolute": "true",
    "starting_mc_linear_e_values_equal_T1_y": "true",
}
certificate_path = ROOT / "verification" / "controller_QQ.txt"
observed = dict(
    line.split("=", 1)
    for line in certificate_path.read_text(encoding="utf-8").splitlines()
    if line
)
assert observed == expected, observed

print("strict_source_scan_passed=true")
print("relative_controller_certificate_passed=true")
