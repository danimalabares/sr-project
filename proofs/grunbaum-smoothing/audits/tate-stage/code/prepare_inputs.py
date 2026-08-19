#!/usr/bin/env python3
"""Validate the frozen sparse Tate-stage input and emit CAS-specific literals.

This is deliberately a format translator only.  It performs no homology
calculation.  The exact input is a canonical list of rational monomial terms
shared by Macaulay2 and Singular.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import re
import sys
from collections import defaultdict
from fractions import Fraction

MATRIX_SHAPES = {"F": (1, 16), "R": (16, 30), "Z": (150, 136)}
MATRIX_ORDER = {"F": 0, "R": 1, "Z": 2}
VARIABLES = tuple(f"x_{i}" for i in range(1, 9))


def sha256(path: pathlib.Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def parse_sparse(path: pathlib.Path):
    raw = path.read_bytes()
    if b"\r" in raw:
        raise ValueError("input must use LF line endings")
    text = raw.decode("ascii")
    lines = text.splitlines()
    if not lines or lines[0] != "format\ttate-stage-sparse-v1":
        raise ValueError("bad or missing format header")
    if lines[-1] != "end\ttate-stage-sparse-v1":
        raise ValueError("bad or missing end marker")

    declared = {}
    expected_metadata = {
        "ring": ["QQ[x_1,x_2,x_3,x_4,x_5,x_6,x_7,x_8]", "GRevLex"],
        "basis_E1": ["e_1,...,e_16"],
        "basis_E2": ["f_1,...,f_30; e_i*e_j lexicographic i<j"],
    }
    seen_metadata = set()
    records = []
    gdegrees = {}
    values = {
        name: defaultdict(Fraction) for name in MATRIX_SHAPES
    }
    for lineno, line in enumerate(lines[1:-1], 2):
        fields = line.split("\t")
        kind = fields[0]
        if kind in expected_metadata:
            if fields[1:] != expected_metadata[kind] or kind in seen_metadata:
                raise ValueError(f"line {lineno}: wrong/duplicate {kind} metadata")
            seen_metadata.add(kind)
            continue
        if kind == "matrix":
            if len(fields) != 4 or fields[1] not in MATRIX_SHAPES:
                raise ValueError(f"line {lineno}: malformed matrix declaration")
            name = fields[1]
            shape = (int(fields[2]), int(fields[3]))
            if shape != MATRIX_SHAPES[name] or name in declared:
                raise ValueError(f"line {lineno}: wrong/duplicate shape for {name}")
            declared[name] = shape
            continue
        if kind == "gdegree":
            if len(fields) != 3:
                raise ValueError(f"line {lineno}: malformed gdegree")
            column, degree = int(fields[1]), int(fields[2])
            if not 0 <= column < 136 or degree not in {5, 6} or column in gdegrees:
                raise ValueError(f"line {lineno}: invalid/duplicate gdegree")
            gdegrees[column] = degree
            continue
        if kind != "term" or len(fields) != 13:
            raise ValueError(f"line {lineno}: malformed term record")
        name = fields[1]
        if name not in MATRIX_SHAPES:
            raise ValueError(f"line {lineno}: unknown matrix {name}")
        row, column = int(fields[2]), int(fields[3])
        rows, columns = MATRIX_SHAPES[name]
        if not (0 <= row < rows and 0 <= column < columns):
            raise ValueError(f"line {lineno}: out-of-range index")
        coefficient = Fraction(fields[4])
        exponents = tuple(int(value) for value in fields[5:])
        if coefficient == 0 or len(exponents) != 8 or min(exponents) < 0:
            raise ValueError(f"line {lineno}: invalid coefficient/exponent")
        key = (row, column, exponents)
        if key in values[name]:
            raise ValueError(f"line {lineno}: duplicate monomial entry")
        values[name][key] = coefficient
        records.append((name, row, column, coefficient, exponents))

    if declared != MATRIX_SHAPES:
        raise ValueError("not all matrix declarations are present")
    if seen_metadata != set(expected_metadata):
        raise ValueError("not all ring/basis metadata are present")
    if gdegrees != {i: (5 if i < 16 else 6) for i in range(136)}:
        raise ValueError("candidate source shifts are not 5^16 followed by 6^120")
    canonical = sorted(
        records,
        key=lambda item: (MATRIX_ORDER[item[0]], item[1], item[2], item[4]),
    )
    if records != canonical:
        raise ValueError("term records are not in canonical order")
    return values, gdegrees


def monomial(coefficient: Fraction, exponents, dialect: str) -> str:
    factors = []
    if coefficient == -1 and any(exponents):
        prefix = "-"
    elif coefficient == 1 and any(exponents):
        prefix = ""
    elif coefficient.denominator == 1:
        prefix = str(coefficient.numerator)
    else:
        prefix = f"({coefficient.numerator}/{coefficient.denominator})"
    for variable, exponent in zip(VARIABLES, exponents):
        if exponent == 1:
            factors.append(variable)
        elif exponent:
            factors.append(f"{variable}^{exponent}")
    if not factors:
        return prefix
    joiner = "*"
    body = joiner.join(factors)
    if prefix in {"", "-"}:
        return prefix + body
    return prefix + "*" + body


def matrix_entries(values, name: str, dialect: str):
    rows, columns = MATRIX_SHAPES[name]
    by_entry = defaultdict(list)
    for (row, column, exponents), coefficient in values[name].items():
        by_entry[(row, column)].append((exponents, coefficient))
    output = []
    for row in range(rows):
        row_entries = []
        for column in range(columns):
            terms = sorted(by_entry[(row, column)])
            expression = ""
            for exponents, coefficient in terms:
                rendered = monomial(coefficient, exponents, dialect)
                if expression and not rendered.startswith("-"):
                    expression += "+"
                expression += rendered
            row_entries.append(expression or "0")
        output.append(row_entries)
    return output


def write_m2(path: pathlib.Path, values, gdegrees):
    lines = ["-- generated from data/tate_candidate.tsv; exact QQ data"]
    for name in ("F", "R", "Z"):
        rows = matrix_entries(values, name, "m2")
        lines.append(name + "Input = matrix {")
        for index, row in enumerate(rows):
            comma = "," if index + 1 < len(rows) else ""
            lines.append("  {" + ",".join(row) + "}" + comma)
        lines.append("};")
    lines.append("gInternalDegrees = {" + ",".join(str(gdegrees[i]) for i in range(136)) + "};")
    path.write_text("\n".join(lines) + "\n", encoding="ascii")


def write_singular(path: pathlib.Path, values, gdegrees):
    lines = ["// generated from data/tate_candidate.tsv; exact QQ data"]
    for name in ("F", "R", "Z"):
        rows, columns = MATRIX_SHAPES[name]
        lines.append(f"matrix {name}[{rows}][{columns}];")
        entries = matrix_entries(values, name, "singular")
        for row in range(rows):
            for column in range(columns):
                expression = entries[row][column]
                if expression != "0":
                    lines.append(f"{name}[{row + 1},{column + 1}]={expression};")
    lines.append("intvec gInternalDegrees=" + ",".join(str(gdegrees[i]) for i in range(136)) + ";")
    path.write_text("\n".join(lines) + "\n", encoding="ascii")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=pathlib.Path, required=True)
    parser.add_argument("--provenance", type=pathlib.Path, required=True)
    parser.add_argument("--m2-output", type=pathlib.Path, required=True)
    parser.add_argument("--singular-output", type=pathlib.Path, required=True)
    args = parser.parse_args()

    provenance = json.loads(args.provenance.read_text(encoding="utf-8"))
    if not isinstance(provenance, dict):
        raise ValueError("provenance JSON must be an object")
    if provenance.get("format") != "tate-stage-provenance-v1":
        raise ValueError("wrong provenance format")
    frozen = provenance.get("frozen_input")
    if not isinstance(frozen, dict):
        raise ValueError("provenance has no frozen_input object")
    expected = frozen.get("canonical_input_sha256")
    observed = sha256(args.input)
    if not re.fullmatch(r"[0-9a-f]{64}", expected or "") or observed != expected:
        raise SystemExit(f"candidate digest mismatch: expected {expected}, got {observed}")
    values, gdegrees = parse_sparse(args.input)
    args.m2_output.parent.mkdir(parents=True, exist_ok=True)
    args.singular_output.parent.mkdir(parents=True, exist_ok=True)
    write_m2(args.m2_output, values, gdegrees)
    write_singular(args.singular_output, values, gdegrees)
    print(f"candidate_sha256={observed}")
    print("candidate_format=tate-stage-sparse-v1")
    print("matrix_shapes=F:1x16,R:16x30,Z:150x136")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (
        OSError, UnicodeError, ValueError, ZeroDivisionError,
        json.JSONDecodeError,
    ) as error:
        print(f"INPUT_VALIDATION_FAILED: {error}", file=sys.stderr)
        raise SystemExit(2)
