PRIME = 32003
K = GF(PRIME)

raw = load("cache/raw_obstruction_data.sobj")
sec = load("cache/second_syzygies.sobj")

B = raw["B"]
Q0 = raw["Q0"]
rank_B = raw["rank_B"]
order2_row = raw["order2_row"]
f_exps = raw["f_exps"]

M2 = sec["M2"]

def exp_tuple(e):
    return tuple(int(a) for a in e)

def add_exp(a, b):
    return tuple(x + y for x, y in zip(a, b))

def monomial_divides(a, b):
    return all(x <= y for x, y in zip(a, b))

def monomial_in_I(e):
    return any(monomial_divides(g, e) for g in f_exps)

def poly_terms(poly):
    out = {}
    for e, c in poly.dict().items():
        c = K(c)
        if c != 0:
            out[exp_tuple(e)] = c
    return out

def add_to_entries(entries, key, val):
    val = K(val)
    if val == 0:
        return
    entries[key] = entries.get(key, K(0)) + val
    if entries[key] == 0:
        del entries[key]

C_row = {}
C_row_count = 0
C_entries = {}

def get_C_row(q, e):
    global C_row_count
    key = (q, e)
    if key not in C_row:
        C_row[key] = C_row_count
        C_row_count += 1
    return C_row[key]

print("Building C from second syzygies...")
print("B size =", B.nrows(), "x", B.ncols())
print("Q0 size =", Q0.nrows(), "x", Q0.ncols())
print("M2 size =", M2.nrows(), "x", M2.ncols())
print("order2 target rows =", len(order2_row))
print()

assert B.nrows() == len(order2_row)
assert M2.nrows() == 38

for (r, e), col in order2_row.items():
    for q in range(M2.ncols()):
        for ce, cc in poly_terms(M2[r, q]).items():
            ee = add_exp(e, ce)
            if monomial_in_I(ee):
                continue
            row = get_C_row(q, ee)
            add_to_entries(C_entries, (row, col), cc)

C = matrix(K, C_row_count, B.nrows(), C_entries, sparse=True)

print("C size =", C.nrows(), "x", C.ncols())
print("nonzero entries in C =", len(C_entries))
print()

print("Computing ranks...")
rank_C = C.rank()
print("rank B =", rank_B)
print("rank C =", rank_C)
print("C * B = 0:", (C * B).is_zero())

true_target_dim = C.ncols() - rank_C - rank_B
print("dim ker(C)/im(B) =", true_target_dim)
print()

print("Checking whether Q0 is already a cocycle...")
CQ0 = C * Q0
print("C * Q0 = 0:", CQ0.is_zero())
print("rank(C * Q0) =", CQ0.rank())

save(
    {
        "C": C,
        "C_row": C_row,
        "rank_C": rank_C,
        "true_target_dim": true_target_dim,
        "CQ0": CQ0,
    },
    "cache/second_syzygy_map.sobj"
)

print("Wrote cache/second_syzygy_map.sobj")
