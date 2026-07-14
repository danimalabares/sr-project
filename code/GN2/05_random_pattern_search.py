"""
Step 5.  Search single-variable 4x4 pattern matrices V (entries in
x1..x8) for one whose 16 cubic 3x3 minors admit a single weight omega
making ALL 16 SR generators the (strict) omega-leading terms -- i.e. a
system of distinct representatives (minor -> SR gen) that is LP-feasible.

A hit would give a candidate monomial "skeleton" matrix. One would then
test whether a perturbation by lower-weight generic linear forms has
initial ideal I_SR and smooth generic fibre; neither conclusion is assumed.

We compute 3x3 minors of a single-variable matrix combinatorially (no CAS)
and reuse the incremental matching+LP from gn_common.

Run:  python3 05_random_pattern_search.py [n_trials] [seed]
"""

import sys
import random
from itertools import combinations, permutations
from gn_common import SR_NAME_EXP, lp_weight

ROWS = list(combinations(range(4), 3))
COLS = list(combinations(range(4), 3))
PERMS = list(permutations(range(3)))


def sign(perm):
    s = 1
    for i in range(3):
        for j in range(i + 1, 3):
            if perm[i] > perm[j]:
                s = -s
    return s


SR_EXP = {}                       # exp tuple -> name
for name, exp in SR_NAME_EXP.items():
    SR_EXP[exp] = name
SR_EXPS = set(SR_EXP)
ALL_SR = [f'f{i}' for i in range(1, 17)]


def minors_support(V):
    """
    V: 4x4 list of var indices (0..7).
    Returns list of 16 dicts {exp_tuple: net_coeff} (after sign-cancellation).
    """
    out = []
    for R in ROWS:
        for C in COLS:
            terms = {}
            for p in PERMS:
                vis = sorted(V[R[k]][C[p[k]]] for k in range(3))
                e = [0] * 8
                for v in vis:
                    e[v] += 1
                e = tuple(e)
                terms[e] = terms.get(e, 0) + sign(p)
            terms = {e: c for e, c in terms.items() if c != 0}
            out.append(terms)
    return out


def sr_candidates(minor_supports):
    return [[SR_EXP[e] for e in supp if e in SR_EXPS]
            for supp in minor_supports]


def try_full_match(minor_supports):
    """
    Incremental SDR + LP requiring ALL 16 SR gens covered (one per minor).
    Returns (assign, omega, margin) or None.
    """
    cand = sr_candidates(minor_supports)
    # quick reject: every SR gen must appear somewhere
    reachable = set(c for cs in cand for c in cs)
    if len(reachable) < 16:
        return None

    n = len(minor_supports)            # 16
    order = sorted(range(n), key=lambda i: len(cand[i]) or 99)

    best = [None]

    def cons_for(i, name):
        astar = SR_NAME_EXP[name]
        cons = []
        for e in minor_supports[i]:
            if e == astar:
                continue
            cons.append(tuple(astar[k] - e[k] for k in range(8)))
        return cons

    def bt(pos, used, acc, assign):
        if best[0] is not None:
            return
        if pos == n:
            if len(assign) == 16:
                feas, om, mg = lp_weight(acc)
                if feas:
                    best[0] = (dict(assign), om, mg)
            return
        i = order[pos]
        for name in cand[i]:
            if name in used:
                continue
            newcons = acc + cons_for(i, name)
            feas, _, _ = lp_weight(newcons)
            if not feas:
                continue
            used.add(name)
            assign[i] = name
            bt(pos + 1, used, newcons, assign)
            del assign[i]
            used.discard(name)

    bt(0, set(), [], {})
    return best[0]


def random_pattern(rng):
    # random 4x4 over {0..7}; bias slightly so all 8 vars tend to appear
    V = [[rng.randrange(8) for _ in range(4)] for _ in range(4)]
    return V


def main():
    n_trials = int(sys.argv[1]) if len(sys.argv) > 1 else 20000
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    rng = random.Random(seed)

    print(f"Random single-variable pattern search: {n_trials} trials, "
          f"seed {seed}")
    best_cov = 0
    checked = 0
    for t in range(n_trials):
        V = random_pattern(rng)
        supp = minors_support(V)
        cand = sr_candidates(supp)
        reach = set(c for cs in cand for c in cs)
        if len(reach) < 16:
            continue
        checked += 1
        res = try_full_match(supp)
        if res:
            assign, om, mg = res
            print("\n*** FULL 16/16 HIT ***")
            print("pattern V (rows):")
            for r in range(4):
                print("   [" + ", ".join(f"x{V[r][c]+1}" for c in range(4))
                      + "]")
            print("matching minor->SR and omega found; margin =", round(mg, 4))
            print("omega =", [round(w, 4) for w in om])
            save_hit(V, assign, om, mg, seed, t)
            return
        cov = len(reach)
        if cov > best_cov:
            best_cov = cov
    print(f"\nNo 16/16 hit. trials with all-16-reachable supports: {checked}. "
          f"best reachable coverage: {best_cov}")
    print("=> single-variable patterns with a SINGLE consistent weight seem "
          "too rigid; move to richer entries / direct in_omega search (step 6).")


def save_hit(V, assign, om, mg, seed, t):
    import json
    rows = list(combinations(range(4), 3))
    cols = list(combinations(range(4), 3))
    minor_labels = [f"{R}|{C}" for R in rows for C in cols]
    data = {
        "V": V, "omega": om, "margin": mg, "seed": seed, "trial": t,
        "assign": {minor_labels[i]: assign[i] for i in assign},
    }
    with open("cache/05_pattern_hit.json", "w") as f:
        json.dump(data, f, indent=2)
    print("saved cache/05_pattern_hit.json")


if __name__ == "__main__":
    main()
