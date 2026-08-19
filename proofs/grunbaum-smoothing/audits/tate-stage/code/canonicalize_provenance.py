#!/usr/bin/env python3
"""Validate and canonicalize the provenance extractor's sparse output."""
from __future__ import annotations

import pathlib
import sys
from collections import Counter
from fractions import Fraction

if len(sys.argv) != 3:
    raise SystemExit("usage: canonicalize_provenance.py SOURCE TARGET")

source = pathlib.Path(sys.argv[1])
target = pathlib.Path(sys.argv[2])
raw = source.read_bytes()
if b"\r" in raw:
    raise SystemExit("source must use LF line endings")
lines = raw.decode("ascii").splitlines()
prefix = [
    "format\ttate-stage-sparse-v1",
    "ring\tQQ[x_1,x_2,x_3,x_4,x_5,x_6,x_7,x_8]\tGRevLex",
    "basis_E1\te_1,...,e_16",
    "basis_E2\tf_1,...,f_30; e_i*e_j lexicographic i<j",
    "matrix\tF\t1\t16",
    "matrix\tR\t16\t30",
    "matrix\tZ\t150\t136",
]
if lines[:7] != prefix or not lines or lines[-1] != "end\ttate-stage-sparse-v1":
    raise SystemExit("wrong sparse-format header, declarations, or end marker")

shapes = {"F": (1, 16), "R": (16, 30), "Z": (150, 136)}
records = []
gdegrees = []
for lineno, line in enumerate(lines[7:-1], 8):
    fields = line.split("\t")
    if fields[0] == "term":
        if len(fields) != 13:
            raise SystemExit(f"bad term at line {lineno}")
        name = fields[1]
        if name not in shapes:
            raise SystemExit(f"bad matrix name at line {lineno}")
        row, column = int(fields[2]), int(fields[3])
        rows, columns = shapes[name]
        if not (0 <= row < rows and 0 <= column < columns):
            raise SystemExit(f"out-of-range matrix index at line {lineno}")
        coefficient = Fraction(fields[4])
        exponents = tuple(map(int, fields[5:]))
        if coefficient == 0 or len(exponents) != 8 or min(exponents) < 0:
            raise SystemExit(f"bad coefficient or exponent at line {lineno}")
        records.append((name,row,column,coefficient,exponents))
    elif fields[0] == "gdegree":
        if len(fields) != 3:
            raise SystemExit(f"bad gdegree at line {lineno}")
        gdegrees.append((int(fields[1]),int(fields[2])))
    else:
        raise SystemExit(f"unexpected record at line {lineno}")

order = {"F":0,"R":1,"Z":2}
records.sort(key=lambda item:(order[item[0]],item[1],item[2],item[4]))
if len({(a,b,c,e) for a,b,c,d,e in records}) != len(records):
    raise SystemExit("duplicate sparse keys")
if Counter(record[0] for record in records) != Counter({"F": 16, "R": 60, "Z": 439}):
    raise SystemExit("unexpected nonzero-monomial counts")
if sorted(gdegrees) != [(i,5 if i<16 else 6) for i in range(136)]:
    raise SystemExit("wrong g degrees")

out = prefix.copy()
for name,row,column,coefficient,exponents in records:
    coeff = str(coefficient.numerator)
    if coefficient.denominator != 1:
        coeff += "/"+str(coefficient.denominator)
    out.append("\t".join(["term",name,str(row),str(column),coeff,*map(str,exponents)]))
for index,degree in sorted(gdegrees):
    out.append(f"gdegree\t{index}\t{degree}")
out.append("end\ttate-stage-sparse-v1")
target.write_text("\n".join(out)+"\n",encoding="ascii")
