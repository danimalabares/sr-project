import os
import json
import pickle


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__)) if "__file__" in globals() else os.getcwd()
ROOT_DIR = os.path.dirname(SCRIPT_DIR)

PICKLE_FILE = os.path.join(ROOT_DIR, "part-1.pkl")
INPUT_JSON = os.path.join(ROOT_DIR, "order2", "cache", "cubic_family_QQ_data.json")
OUTPUT_REPORT = os.path.join(SCRIPT_DIR, "first_order_coefficients_report.txt")


def rational_from_json(pair):
    return QQ(ZZ(pair[0])) / QQ(ZZ(pair[1]))


def sparse_rational_data_to_vector(items, length):
    v = vector(QQ, length)
    for idx, pair in items:
        v[int(idx)] = rational_from_json(pair)
    return v


def degree_exps(nvars, degree):
    if nvars == 1:
        yield (degree,)
        return
    for a in range(degree + 1):
        for rest in degree_exps(nvars - 1, degree - a):
            yield (a,) + rest


def total_degree(e):
    return sum(int(a) for a in e)


def coeff_str(c):
    c = QQ(c)
    if c.denominator() == 1:
        return str(c.numerator())
    return "%s/%s" % (c.numerator(), c.denominator())


def monomial_str(mon):
    return str(mon)


def exp_to_monomial(R, e):
    return R.monomial(*tuple(int(a) for a in e))


def param_letter(gen_idx):
    return chr(ord("a") + gen_idx)


def param_name(gen_idx, mon_idx):
    return "%s%d" % (param_letter(gen_idx), mon_idx + 1)


def raw_index_to_pair(idx, n_mons):
    return int(idx) // n_mons, int(idx) % n_mons


def syz_row_relation_str(R, syz, f_list, row_idx):
    pieces = []
    for j in range(syz.ncols()):
        coeff = R(syz[row_idx, j])
        if coeff == 0:
            continue
        pieces.append("(%s) * f%d" % (coeff, j + 1))
    if not pieces:
        return "0"
    return " + ".join(pieces)


print("Loading", PICKLE_FILE)
with open(PICKLE_FILE, "rb") as f:
    data = pickle.load(f)

print("Loading", INPUT_JSON)
with open(INPUT_JSON, "r") as f:
    cubic = json.load(f)

if cubic.get("base_field") != "QQ":
    raise RuntimeError("expected QQ cubic data")

R = data["R"]
I = data["I"]
syz = data["syz"]
nonzero_monomials = list(data["nonzero_monomials"])
def_params = list(data["def_params"])

x = R.gens()
f_list = list(I.gens())
nvars = len(x)
n_gens = len(f_list)
n_mons = len(nonzero_monomials)
n_params = n_gens * n_mons

assert n_gens == 16
assert n_mons == 104
assert n_params == int(cubic["n_params"])

G1 = sparse_rational_data_to_vector(cubic["G"]["1"], n_params)

g_polys = [R.zero() for _ in range(n_gens)]
g_support = []
turned_on = []

for idx in range(n_params):
    coeff = QQ(G1[idx])
    if coeff == 0:
        continue
    gen_idx, mon_idx = raw_index_to_pair(idx, n_mons)
    mon = R(nonzero_monomials[mon_idx])
    g_polys[gen_idx] += coeff * mon
    info = {
        "raw_index": idx,
        "generator_index": gen_idx,
        "monomial_index": mon_idx,
        "param_name": param_name(gen_idx, mon_idx),
        "coefficient": coeff,
        "monomial": mon,
    }
    g_support.append(info)
    turned_on.append(info["param_name"])

assert len(g_support) == len(cubic["G"]["1"])

# Reconstruct the A_1 coordinate system exactly as in the order2 scripts.
syz_degrees = []
for r in range(syz.nrows()):
    degrees = set()
    for j in range(n_gens):
        coeff = R(syz[r, j])
        if coeff == 0:
            continue
        degrees.add(coeff.degree() + f_list[j].degree())
    if len(degrees) != 1:
        raise RuntimeError("syzygy row %d is not homogeneous" % r)
    syz_degrees.append(list(degrees)[0])

alpha_col = {}
col_count = n_params
for r in range(syz.nrows()):
    corr_deg = syz_degrees[r] - 3
    if corr_deg < 0:
        raise RuntimeError("negative correction degree in row %d" % r)
    for j in range(n_gens):
        for q_exp in degree_exps(nvars, corr_deg):
            alpha_col[(r, j, tuple(int(a) for a in q_exp))] = col_count
            col_count += 1

n_corr = col_count - n_params
assert n_corr == int(cubic["n_corr"])

A1 = sparse_rational_data_to_vector(cubic["A"]["1"], n_corr)
A1_entries = []
A1_matrix = [[R.zero() for _ in range(n_gens)] for _ in range(syz.nrows())]

for (r, j, q_exp), col in alpha_col.items():
    coeff = QQ(A1[col - n_params])
    if coeff == 0:
        continue
    q_mon = exp_to_monomial(R, q_exp)
    A1_matrix[r][j] += coeff * q_mon
    A1_entries.append({
        "row": r,
        "col": j,
        "monomial": q_mon,
        "coefficient": coeff,
        "corr_degree": total_degree(q_exp),
    })

A1_entries.sort(key=lambda item: (item["row"], item["col"], str(item["monomial"])))

# Exact first-order verification in the polynomial ring R over QQ.
bad_rows = []
row_expressions = []
for r in range(syz.nrows()):
    expr = R.zero()
    for j in range(n_gens):
        expr += R(syz[r, j]) * g_polys[j]
        expr += A1_matrix[r][j] * R(f_list[j])
    row_expressions.append(expr)
    if expr != 0:
        bad_rows.append((r, expr))

report_lines = []
report_lines.append("First-order coefficient recovery for the QQ cubic family")
report_lines.append("")
report_lines.append("Inputs")
report_lines.append("  part-1.pkl = %s" % PICKLE_FILE)
report_lines.append("  cubic JSON = %s" % INPUT_JSON)
report_lines.append("")
report_lines.append("Basic data")
report_lines.append("  number of SR generators = %d" % n_gens)
report_lines.append("  number of degree-3 quotient monomials = %d" % n_mons)
report_lines.append("  raw deformation parameters = %d = %d x %d" % (n_params, n_gens, n_mons))
report_lines.append("  syzygy rows = %d" % syz.nrows())
report_lines.append("  A_1 correction coordinates = %d" % n_corr)
report_lines.append("")
report_lines.append("Generator order from part-1.sage")
for j, f in enumerate(f_list):
    report_lines.append("  F%d corresponds to %s1-%s%d and starts from f%d = %s" % (
        j + 1, param_letter(j), param_letter(j), n_mons, j + 1, f
    ))
report_lines.append("")
report_lines.append("Exact raw-index to old-parameter convention")
report_lines.append("  raw index idx is 0-based in the order2 JSON.")
report_lines.append("  Write idx = gen_idx * 104 + mon_idx with 0 <= gen_idx <= 15 and 0 <= mon_idx <= 103.")
report_lines.append("  Then idx corresponds to the old parameter letter(gen_idx) followed by mon_idx + 1, where")
report_lines.append("    gen_idx = 0,1,...,15 means letters a,b,...,p,")
report_lines.append("    mon_idx + 1 is the monomial slot in the list below.")
report_lines.append("  Examples: raw 0 = a1, raw 103 = a104, raw 104 = b1, raw 1663 = p104.")
report_lines.append("")
report_lines.append("Degree-3 monomial order used by part-1.sage and by all order2 raw indices")
for mon_idx, mon in enumerate(nonzero_monomials, start=1):
    report_lines.append("  %3d -> %s" % (mon_idx, mon))
report_lines.append("")
report_lines.append("Nonzero coefficients of the chosen first-order direction G_1")
report_lines.append("  These are exactly the raw coordinates stored in order2/cache/cubic_family_QQ_data.json.")
for item in sorted(g_support, key=lambda entry: entry["raw_index"]):
    report_lines.append(
        "  raw %4d -> %-4s = %-8s   (generator F%d, monomial #%d = %s)" % (
            item["raw_index"],
            item["param_name"],
            coeff_str(item["coefficient"]),
            item["generator_index"] + 1,
            item["monomial_index"] + 1,
            item["monomial"],
        )
    )
report_lines.append("")
report_lines.append("Turned-on old deformation parameters")
for item in sorted(g_support, key=lambda entry: entry["param_name"]):
    report_lines.append("  %s = %s" % (item["param_name"], coeff_str(item["coefficient"])))
report_lines.append("")
report_lines.append("First-order correction polynomials g_i")
for j in range(n_gens):
    report_lines.append("  g_%d = %s" % (j + 1, g_polys[j]))
report_lines.append("")
report_lines.append("First-order deformed generators F_i = f_i + epsilon * g_i")
for j in range(n_gens):
    report_lines.append("  F_%d = %s + epsilon*(%s)" % (j + 1, f_list[j], g_polys[j]))
report_lines.append("")
report_lines.append("Nonzero A_1 coefficients")
report_lines.append("  A_1 is a 38 x 16 matrix of correction polynomials.")
report_lines.append("  Each entry below means: in syzygy row r, column j, add coeff * monomial.")
for item in A1_entries:
    report_lines.append(
        "  row %2d, col %2d: %s * %s" % (
            item["row"] + 1,
            item["col"] + 1,
            coeff_str(item["coefficient"]),
            item["monomial"],
        )
    )
report_lines.append("")
report_lines.append("Grouped A_1 entries by syzygy row")
for r in range(syz.nrows()):
    nonzero_cols = [j for j in range(n_gens) if A1_matrix[r][j] != 0]
    if not nonzero_cols:
        continue
    report_lines.append("  Row %d syzygy: %s" % (r + 1, syz_row_relation_str(R, syz, f_list, r)))
    for j in nonzero_cols:
        report_lines.append("    A_1[%d,%d] = %s" % (r + 1, j + 1, A1_matrix[r][j]))
report_lines.append("")
report_lines.append("Exact first-order verification")
report_lines.append("  Checked in the polynomial ring QQ[x1,...,x8], not modulo I.")
report_lines.append("  Condition: s G_1 + A_1 f = 0.")
report_lines.append("  Number of bad rows = %d" % len(bad_rows))
if bad_rows:
    for r, expr in bad_rows:
        report_lines.append("  BAD row %d: %s" % (r + 1, expr))
else:
    report_lines.append("  All 38 syzygy rows vanish exactly.")
report_lines.append("")
report_lines.append("Why this is a first-order flat deformation in Michele's sense")
report_lines.append("  The deformed generators f_i + epsilon*g_i satisfy the first-order syzygy equations")
report_lines.append("      s G_1 + A_1 f = 0")
report_lines.append("  exactly over QQ.")
report_lines.append("  So the original syzygies lift over QQ[epsilon]/(epsilon^2), which is precisely the")
report_lines.append("  first-order deformation criterion implemented in part-1.sage / the Artin-Michele setup.")
report_lines.append("  Equivalently, G_1 defines a class in Hom_S(I,S/I)_0, hence an embedded first-order")
report_lines.append("  deformation of the SR ideal over the dual numbers.")
report_lines.append("")
report_lines.append("Short summary")
report_lines.append("  Turned-on parameters: %s" % ", ".join(
    item["param_name"] for item in sorted(g_support, key=lambda entry: (entry["generator_index"], entry["monomial_index"]))
))
report_lines.append("  nnz(G_1) = %d" % len(g_support))
report_lines.append("  nnz(A_1) = %d" % len(A1_entries))

with open(OUTPUT_REPORT, "w") as f:
    f.write("\n".join(report_lines) + "\n")

print("Wrote", OUTPUT_REPORT)
print("nnz(G_1) =", len(g_support))
print("nnz(A_1) =", len(A1_entries))
print("bad order-1 rows =", len(bad_rows))
if bad_rows:
    raise RuntimeError("first-order identity failed")
