#!/usr/bin/env python3
"""Replay all 8 x 35 exact Grassmann-incidence memberships over QQ.

Each worker first asks Macaulay2 for a degree-six partial Groebner basis.  A
nonzero remainder is only inconclusive, so that pair is retried at degree
eight.  A zero remainder is an exact membership certificate even for a
partial basis: every computed basis element is an exact combination of the
input columns.
"""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import os
from pathlib import Path
import subprocess
import sys


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
CHECKER = HERE / "verify_grassmann_mod_s3.m2"
TWO_JET = HERE / "universal_2jet_QQ.txt"
CERTIFICATE = HERE / "certificates/grassmann_mod_s3_QQ.txt"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run_m2(x_chart: int, grassmann_chart: int, degree_limit: int,
           verify_lift: bool = False) -> subprocess.CompletedProcess[str]:
    environment = os.environ.copy()
    environment.pop("SCOUT_GF", None)
    environment["X_CHART"] = str(x_chart)
    environment["GRASSMANN_CHART"] = str(grassmann_chart)
    environment["DEGREE_LIMIT"] = str(degree_limit)
    if verify_lift:
        environment["VERIFY_LIFT"] = "1"
    else:
        environment.pop("VERIFY_LIFT", None)
    return subprocess.run(
        ["M2", "--script", str(CHECKER.relative_to(ROOT))],
        cwd=ROOT,
        env=environment,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=600,
        check=False,
    )


def validate_common_output(output: str, x_chart: int, grassmann_chart: int,
                           degree_limit: int) -> None:
    required = (
        f"x_chart={x_chart}",
        f"pivot_chart={grassmann_chart}",
        "coefficient_field=QQ",
        "incidence_generators=80",
        "module_columns=240",
        f"degree_limit={degree_limit}",
    )
    missing = [line for line in required if line not in output]
    if missing:
        raise RuntimeError(
            "malformed checker output for (%d,%d): missing %s\n%s"
            % (x_chart, grassmann_chart, missing, output)
        )


def prove_pair(pair: tuple[int, int]) -> tuple[int, int, int]:
    x_chart, grassmann_chart = pair
    for degree_limit in (6, 8):
        result = run_m2(x_chart, grassmann_chart, degree_limit)
        validate_common_output(
            result.stdout, x_chart, grassmann_chart, degree_limit
        )
        if result.returncode == 0:
            if ("remainder_zero=true" not in result.stdout
                    or "membership_proved=true" not in result.stdout):
                raise RuntimeError(
                    "checker exited zero without membership proof:\n"
                    + result.stdout
                )
            return x_chart, grassmann_chart, degree_limit
        if (result.returncode != 2
                or "membership_proved=false" not in result.stdout):
            raise RuntimeError(
                "checker failed for (%d,%d) at degree %d (exit %d):\n%s"
                % (x_chart, grassmann_chart, degree_limit,
                   result.returncode, result.stdout)
            )
    raise RuntimeError(
        "membership not proved for x-chart %d, Grassmann chart %d"
        % pair
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument(
        "--skip-lift-spot-check", action="store_true",
        help="skip the slower ChangeMatrix identity check on chart (1,1)",
    )
    parser.add_argument(
        "--certificate", type=Path, default=CERTIFICATE,
        help="summary certificate path",
    )
    arguments = parser.parse_args()
    if arguments.jobs < 1:
        parser.error("--jobs must be positive")

    pairs = [(x_chart, grassmann_chart)
             for x_chart in range(1, 9)
             for grassmann_chart in range(1, 36)]
    results: list[tuple[int, int, int]] = []
    with ThreadPoolExecutor(max_workers=arguments.jobs) as executor:
        futures = {executor.submit(prove_pair, pair): pair for pair in pairs}
        for completed, future in enumerate(as_completed(futures), 1):
            result = future.result()
            results.append(result)
            if completed % 20 == 0 or completed == len(pairs):
                print("proved %d/%d chart pairs" % (completed, len(pairs)),
                      flush=True)

    results.sort()
    if [(x, p) for x, p, _ in results] != pairs:
        raise RuntimeError("chart-pair coverage mismatch")
    degree_eight = [(x, p) for x, p, degree in results if degree == 8]

    lift_spot_check = "skipped"
    lift_nonzero = "not_computed"
    if not arguments.skip_lift_spot_check:
        result = run_m2(1, 1, 6, verify_lift=True)
        validate_common_output(result.stdout, 1, 1, 6)
        if (result.returncode != 0
                or "membership_proved=true" not in result.stdout
                or "lift_verified=true" not in result.stdout):
            raise RuntimeError("exact lift spot-check failed:\n" + result.stdout)
        lift_spot_check = "x1_grassmann1"
        for line in result.stdout.splitlines():
            if line.startswith("lift_nonzero_coefficients="):
                lift_nonzero = line.split("=", 1)[1]
                break
        if lift_nonzero == "not_computed":
            raise RuntimeError("lift coefficient count missing")

    version = subprocess.run(
        ["M2", "--version"], cwd=ROOT, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=True,
    ).stdout.strip().replace("\n", " ")
    certificate_lines = [
        "field=QQ",
        "macaulay2_version=%s" % version,
        "two_jet_sha256=%s" % sha256(TWO_JET),
        "checker_sha256=%s" % sha256(CHECKER),
        "x_charts=8",
        "grassmann_charts_per_x_chart=35",
        "chart_pairs=280",
        "incidence_generators_per_pair=80",
        "module_columns_per_pair=240",
        "degree_limit_6_passes=%d" % (280 - len(degree_eight)),
        "degree_limit_8_passes=%d" % len(degree_eight),
        "degree_limit_8_pairs=%s" % degree_eight,
        "all_s2_memberships_proved=true",
        "lift_spot_check=%s" % lift_spot_check,
        "lift_nonzero_coefficients=%s" % lift_nonzero,
    ]
    certificate = "\n".join(certificate_lines) + "\n"
    certificate_path = arguments.certificate
    if not certificate_path.is_absolute():
        certificate_path = ROOT / certificate_path
    certificate_path.parent.mkdir(parents=True, exist_ok=True)
    temporary = certificate_path.with_suffix(certificate_path.suffix + ".tmp")
    temporary.write_text(certificate)
    temporary.replace(certificate_path)
    print(certificate, end="")
    print("certificate=%s" % certificate_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
