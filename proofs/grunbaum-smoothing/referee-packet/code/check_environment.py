#!/usr/bin/env python3
"""Fail unless the proof-critical software is the audited build."""

import hashlib
from pathlib import Path
import re
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "verification/environment.txt"
EXPECTED_PACKAGE_HASHES = {
    "VersalDeformations.m2":
        "3363126cce0237f2c3a7ab8a8438372c5adcf83a6fb5be1fb84e7cea9bd61c3a",
    "DGAlgebras.m2":
        "72adff5eb889703562b7cedfce10c93490fda171f5f9dd90a998eb69b7d433b0",
}
EXPECTED_M2_HASHES = {
    "M2": "a768799d25c404f5cd33ef445c37c7c83a28ca86b6d3124ac5a8d6997fe8dfbe",
    "M2-binary": "c6f0c89e69d18334031c78217ddb6b383d5a729bde32aeb5f70ee2da0eec9b6c",
}
EXPECTED_M2_BUILD = (
    "version-1.20-6-a156a3cd4-dirty",
    "x86_64-apple-darwin21.4.0",
    "May 14 2022, 00:16:18",
    "clang 13.1.6 (clang-1316.0.21.2.3)",
)


def output(command):
    return subprocess.run(
        command, text=True, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, check=True,
    ).stdout


def main():
    m2_version = output(["M2", "--version"]).strip()
    assert m2_version == "1.20", m2_version
    build_query = (
        'print version#"git description"; print version#"build"; '
        'print version#"compile time"; print version#"compiler"; exit 0'
    )
    m2_build = tuple(output([
        "M2", "--no-readline", "--silent", "-q", "-e", build_query,
    ]).splitlines())
    assert m2_build == EXPECTED_M2_BUILD, m2_build
    m2_path = Path(shutil.which("M2")).resolve()
    m2_binary_path = m2_path.with_name("M2-binary")
    observed_m2_hashes = {
        path.name: hashlib.sha256(path.read_bytes()).hexdigest()
        for path in (m2_path, m2_binary_path)
    }
    assert observed_m2_hashes == EXPECTED_M2_HASHES, observed_m2_hashes
    package_query = (
        'needsPackage "VersalDeformations"; '
        'print VersalDeformations#"source file"; '
        'needsPackage "DGAlgebras"; '
        'print DGAlgebras#"source file"; exit 0'
    )
    package_output = output([
        "M2", "--no-readline", "--silent", "-q", "-e", package_query,
    ])
    package_paths = [Path(line.strip()) for line in package_output.splitlines()
                     if line.strip().endswith(".m2")]
    assert len(package_paths) == 2, package_output
    observed_hashes = {}
    for path in package_paths:
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        expected = EXPECTED_PACKAGE_HASHES[path.name]
        assert digest == expected, (path, digest, expected)
        observed_hashes[path.name] = digest

    assert sys.version_info[:3] == (3, 13, 7), sys.version
    latexmk_text = output(["latexmk", "-v"])
    latexmk_match = re.search(r"Version ([0-9.]+)", latexmk_text)
    assert latexmk_match and latexmk_match.group(1) == "4.79", latexmk_text
    pdftex_first = output(["pdflatex", "--version"]).splitlines()[0]
    assert "pdfTeX 3.141592653-2.6-1.40.25 (TeX Live 2023)" in pdftex_first

    lines = [
        "Macaulay2=%s" % m2_version,
        "Macaulay2_git_description=%s" % m2_build[0],
        "Macaulay2_build=%s" % m2_build[1],
        "Macaulay2_compile_time=%s" % m2_build[2],
        "Macaulay2_compiler=%s" % m2_build[3],
        "M2_launcher_sha256=%s" % observed_m2_hashes["M2"],
        "M2_binary_sha256=%s" % observed_m2_hashes["M2-binary"],
        "VersalDeformations=3.0",
        "VersalDeformations_source_sha256=%s"
        % observed_hashes["VersalDeformations.m2"],
        "DGAlgebras=1.1.0",
        "DGAlgebras_source_sha256=%s" % observed_hashes["DGAlgebras.m2"],
        "Python=%d.%d.%d" % sys.version_info[:3],
        "latexmk=%s" % latexmk_match.group(1),
        "pdfTeX=3.141592653-2.6-1.40.25",
        "TeX_Live=2023",
    ]
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text("\n".join(lines) + "\n")
    print("\n".join(lines))
    print("certificate=%s" % OUTPUT)


if __name__ == "__main__":
    main()
