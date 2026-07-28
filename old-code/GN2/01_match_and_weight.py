"""
Step 1.  For a given 4x4 matrix of linear forms, search for
    - a system of distinct representatives  (minor -> SR generator
      appearing as one of its terms), and
    - a single weight vector omega in R^8
such that for every matched minor, the chosen SR monomial is the strict
omega-leading term of that minor.

This is the LP that REPLACES the intractable Groebner-fan computation:
we never enumerate the fan, we just solve for one omega realising one
target initial ideal.

Run:  python3 01_match_and_weight.py
"""

import sys
from gn_common import (given_matrix, minors_3x3, poly_support, sr_terms_in,
                       SR_NAME_EXP, lp_weight)


def build_minor_data(M):
    data = []
    for label, poly in minors_3x3(M):
        supp = poly_support(poly)
        cand = sr_terms_in(supp)            # SR gens that are terms here
        data.append({'label': label, 'support': supp, 'cand': cand})
    return data


def search(minor_data, require_all_sr=False, max_leaves=200000):
    """
    Backtracking SDR + incremental LP feasibility.

    Assign to each minor (that has candidates) a distinct SR generator,
    accumulating separation constraints  omega.(a* - a) >= margin  for
    every other term a of that minor.  Prune whenever the accumulated
    constraint set becomes LP-infeasible.  Return the assignment with
    the most matched minors that is LP-feasible, together with omega.
    """
    n = len(minor_data)
    best = {'size': -1, 'assign': None, 'omega': None, 'margin': 0.0}
    leaves = [0]

    # order minors by fewest candidates first (fail fast)
    order = sorted(range(n), key=lambda i: (len(minor_data[i]['cand']) or 99))

    def constraints_for(i, sr_name):
        astar = SR_NAME_EXP[sr_name]
        supp = minor_data[i]['support']
        cons = []
        for e in supp:
            if e == astar:
                continue
            cons.append(tuple(astar[k] - e[k] for k in range(8)))
        return cons

    def bt(pos, used, acc_cons, assign):
        if leaves[0] > max_leaves:
            return
        if pos == len(order):
            feas, omega, margin = lp_weight(acc_cons)
            if feas and len(assign) > best['size']:
                best.update(size=len(assign), assign=dict(assign),
                            omega=omega, margin=margin)
            leaves[0] += 1
            return

        i = order[pos]
        cands = [c for c in minor_data[i]['cand'] if c not in used]

        # branch: try to match minor i to each available SR gen ...
        for sr_name in cands:
            new_cons = acc_cons + constraints_for(i, sr_name)
            feas, _, _ = lp_weight(new_cons)
            if feas:
                used.add(sr_name)
                assign[i] = sr_name
                bt(pos + 1, used, new_cons, assign)
                del assign[i]
                used.discard(sr_name)

        # ... or leave minor i unmatched (only if we don't require all)
        if not require_all_sr:
            bt(pos + 1, used, acc_cons, assign)

    bt(0, set(), [], {})
    return best


def main():
    M = given_matrix()
    print("Matrix:")
    sp_print(M)
    data = build_minor_data(M)

    print("\nSR monomials appearing as a term of each minor")
    print("-" * 48)
    all_sr = set()
    for d in data:
        all_sr.update(d['cand'])
        print(f"  minor {d['label']}: {d['cand'] if d['cand'] else 'NONE'}")
    print(f"\nDistinct SR gens reachable: {len(all_sr)} / 16")
    missing = [f'f{i}' for i in range(1, 17) if f'f{i}' not in all_sr]
    print(f"Unreachable SR gens: {missing}")

    print("\nSearching for best LP-feasible matching ...")
    best = search(data, require_all_sr=False)
    print(f"\nBest matched minors with a consistent weight: {best['size']}")
    if best['assign'] is not None:
        for i in sorted(best['assign']):
            print(f"  minor {data[i]['label']} -> {best['assign'][i]}")
        matched_sr = set(best['assign'].values())
        print(f"  SR gens covered: {len(matched_sr)} / 16")
        print(f"  unmatched SR gens: "
              f"{[f'f{i}' for i in range(1,17) if f'f{i}' not in matched_sr]}")
        print(f"  margin = {best['margin']:.4f}")
        print(f"  omega = {[round(w,4) for w in best['omega']]}")


def sp_print(M):
    for r in range(M.rows):
        print("   [" + ", ".join(str(M[r, c]) for c in range(M.cols)) + "]")


if __name__ == "__main__":
    main()
