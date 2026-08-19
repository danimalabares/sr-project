#!/usr/bin/env python3
"""Check the semantic outputs of every exact replay stage."""

import hashlib
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
VERIFICATION = ROOT / "verification"


def fields(name):
    result = {}
    for line in (VERIFICATION / name).read_text().splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            result[key] = value
    return result


def require(observed, expected):
    for key, value in expected.items():
        assert observed.get(key) == value, (
            key, observed.get(key), value,
        )


def main():
    two_jet = ROOT / "data/universal_2jet_QQ.txt"
    two_jet_hash = hashlib.sha256(two_jet.read_bytes()).hexdigest()
    assert two_jet_hash == (
        "40e64e61674b6a4e61f1ea6822dc79327bf4ba397285f84ed8738c4c18cd1795"
    )

    require(fields("environment.txt"), {
        "Macaulay2": "1.20",
        "Macaulay2_git_description": "version-1.20-6-a156a3cd4-dirty",
        "Macaulay2_build": "x86_64-apple-darwin21.4.0",
        "VersalDeformations": "3.0",
        "DGAlgebras": "1.1.0",
        "Python": "3.13.7",
        "latexmk": "4.79",
        "pdfTeX": "3.141592653-2.6-1.40.25",
        "TeX_Live": "2023",
    })

    require(fields("combinatorics_QQ.txt"), {
        "vertices": "8",
        "tetrahedral_facets": "20",
        "minimal_nonfaces": "16",
        "pure_dimension": "3",
        "faces_checked_for_reisner": "97",
        "all_links_lower_reduced_homology_zero": "true",
        "whole_complex_reduced_betti": "(0, 0, 0, 1)",
        "stanley_reisner_ring_cohen_macaulay": "true",
    })
    require(fields("formal_data_QQ.txt"), {
        "field": "QQ",
        "VersalDeformations_version": "3.0",
        "T1_degree_zero_dimension": "53",
        "T2_degree_zero_dimension": "27",
        "minimal_quadratic_base_equations": "27",
        "quadratic_kuranishi_at_y_zero": "true",
        "cubic_kuranishi_at_y_zero": "true",
        "rank_Dq_y": "15",
        "base_arc_two_jet": "s*y",
        "two_jet_rows": "16",
    })
    require(fields("aq_bracket_QQ.txt"), {
        "field": "QQ",
        "DGAlgebras_version": "1.1.0",
        "VersalDeformations_version": "3.0",
        "degree1_generators": "16",
        "degree2_generators": "30",
        "degree3_internal5_generators": "16",
        "degree3_internal6_generators": "120",
        "T2_degree_zero_dimension": "27",
        "relation_change_determinant": "1",
        "T2_columns_closed": "true",
        "T2_independent_classes_mod_boundaries": "27",
        "T2_remaining_degree_zero_cocycles": "0",
        "rank_commutator_columns_mod_delta2": "12",
        "rank_Dq_y": "15",
        "commutator_composed_Dq_y_zero": "true",
        "primary_bracket_plus_Dq_y_zero": "true",
    })
    require(fields("incidence_all_QQ.txt"), {
        "field": "QQ",
        "macaulay2_version": "1.20",
        "two_jet_sha256": two_jet_hash,
        "x_charts": "8",
        "grassmann_charts_per_x_chart": "35",
        "chart_pairs": "280",
        "incidence_generators_per_pair": "80",
        "module_columns_per_pair": "240",
        "degree_limit_6_passes": "277",
        "degree_limit_8_passes": "3",
        "degree_limit_8_pairs": "[(2, 7), (6, 12), (8, 16)]",
        "all_s2_memberships_proved": "true",
        "lift_spot_check": "x1_grassmann1",
        "lift_nonzero_coefficients": "8",
    })

    summary = "\n".join((
        "all_exact_checks_passed=true",
        "special_fibre_CM_and_pure=true",
        "computed_formal_arc_input_checks=true",
        "computed_commutator_rank_mod_delta2=12",
        "incidence_memberships=280/280",
        "universal_two_jet_sha256=%s" % two_jet_hash,
    )) + "\n"
    (VERIFICATION / "replay_summary.txt").write_text(summary)
    print(summary, end="")


if __name__ == "__main__":
    main()
