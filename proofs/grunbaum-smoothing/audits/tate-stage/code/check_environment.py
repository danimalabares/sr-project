#!/usr/bin/env python3
"""Pin the exact public-CAS environment used for this audit."""

from __future__ import annotations

import hashlib
import pathlib
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "verification" / "environment.txt"
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
EXPECTED_SINGULAR_VERSION = "4.4.1"
EXPECTED_SINGULAR_BANNER = (
    "Singular for x86_64-Darwin version 4.4.1 "
    "(44103, 64 bit) Sep 29 2025 21:38:55"
)
EXPECTED_SINGULAR_SHA256 = (
    "7ca798755d93968a33b27ab6c3da2e39fb4e0519074c8f3a4c92144d860077c6"
)
EXPECTED_PYTHON_SHA256 = (
    "2a28ba20062e3a264e0e22d0c5c34f760a16ce3fb41a08d22922bee8fc322a91"
)


def output(command: list[str]) -> str:
    return subprocess.run(
        command,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    ).stdout


def digest(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    m2_path_text = shutil.which("M2")
    singular_path_text = shutil.which("Singular")
    if not m2_path_text or not singular_path_text:
        raise RuntimeError("both M2 and Singular must be on PATH")
    m2_path = pathlib.Path(m2_path_text).resolve()
    m2_binary = m2_path.with_name("M2-binary")
    observed_m2 = {path.name: digest(path) for path in (m2_path, m2_binary)}
    if observed_m2 != EXPECTED_M2_HASHES:
        raise RuntimeError(f"wrong Macaulay2 executable bytes: {observed_m2}")
    if output([str(m2_path), "--version"]).strip() != "1.20":
        raise RuntimeError("wrong Macaulay2 version")
    query = (
        'print version#"git description"; print version#"build"; '
        'print version#"compile time"; print version#"compiler"; exit 0'
    )
    build = tuple(output([
        str(m2_path), "--no-preload", "--no-randomize", "--no-readline",
        "--no-threads", "--no-time", "--no-tty", "--silent", "--stop",
        "-q", "-e", query,
    ]).splitlines())
    if build != EXPECTED_M2_BUILD:
        raise RuntimeError(f"wrong Macaulay2 build: {build!r}")
    loaded_packages = output([
        str(m2_path), "--no-preload", "--no-randomize", "--no-readline",
        "--no-threads", "--no-time", "--no-tty", "--silent", "--stop",
        "-q", "-e", "print toString loadedPackages; exit 0",
    ]).strip()
    if loaded_packages != "{Core}":
        raise RuntimeError(f"unexpected Macaulay2 preloaded packages: {loaded_packages!r}")

    singular_path = pathlib.Path(singular_path_text).resolve()
    singular_version = output([
        str(singular_path), "--dump-versiontuple",
    ]).strip()
    singular_banner = output([
        str(singular_path), "--version",
    ]).splitlines()[0]
    singular_sha = digest(singular_path)
    if singular_version != EXPECTED_SINGULAR_VERSION:
        raise RuntimeError(f"wrong Singular version: {singular_version!r}")
    if singular_banner != EXPECTED_SINGULAR_BANNER:
        raise RuntimeError(f"wrong Singular build banner: {singular_banner!r}")
    if singular_sha != EXPECTED_SINGULAR_SHA256:
        raise RuntimeError(f"wrong Singular executable bytes: {singular_sha}")
    if sys.version_info[:3] != (3, 13, 7):
        raise RuntimeError(f"wrong Python version: {sys.version}")
    python_path = pathlib.Path(sys.executable).resolve()
    python_sha = digest(python_path)
    if python_sha != EXPECTED_PYTHON_SHA256:
        raise RuntimeError(f"wrong Python executable bytes: {python_sha}")

    lines = [
        "Python=3.13.7",
        "Macaulay2=1.20",
        f"Macaulay2_git_description={build[0]}",
        f"Macaulay2_build={build[1]}",
        f"Macaulay2_compile_time={build[2]}",
        f"Macaulay2_compiler={build[3]}",
        f"M2_launcher_sha256={observed_m2['M2']}",
        f"M2_binary_sha256={observed_m2['M2-binary']}",
        "Macaulay2_noncore_packages_loaded=none",
        f"Singular={singular_version}",
        f"Singular_build_banner={singular_banner}",
        f"Singular_executable_sha256={singular_sha}",
        f"Python_executable_sha256={python_sha}",
    ]
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
