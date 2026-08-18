#!/usr/bin/env sage
"""Verify formal arcs on the exported versal base, exactly over GF(32003).

The Macaulay2 export has one line per obstruction equation and homogeneous
degree::

    group_index|row_index|polynomial

Here ``group_index == 0`` denotes the quadratic part.  If

    t(s) = s*y + v_2*s^2 + v_3*s^3 + ...,

then at order n the new coefficient occurs only as ``A*v_(n-1)``, where
``A = D(g_2)_y``.  This verifier retains every element of ``ker(A)`` as a
new named parameter and records the exact left-kernel compatibility
conditions.  It never interprets failure of one chosen lift as an intrinsic
obstruction.

By default the script emits two order-five certificates: the fully generic
arc over the all-ones tangent and the simpler slice with v_2=0.
"""

from pathlib import Path
import argparse
import hashlib


FIELD_ORDER = 32003
N_PARAMETERS = 53
N_EQUATIONS = 27
PROOF_DIRECTORY = Path(__file__).resolve().parent


def proof_path(value):
    path = Path(value)
    return path if path.is_absolute() else PROOF_DIRECTORY / path


def load_export(path):
    path = Path(path)
    contents = path.read_bytes()
    digest = hashlib.sha256(contents).hexdigest()
    K = GF(FIELD_ORDER)
    T = PolynomialRing(K, ["t_%d" % i for i in range(1, N_PARAMETERS + 1)])
    raw = {}
    for line_number, raw_line in enumerate(contents.decode("utf-8").splitlines(), 1):
        if not raw_line.strip():
            continue
        pieces = raw_line.split("|", 2)
        if len(pieces) != 3:
            raise ValueError("malformed export line %d: %r" % (line_number, raw_line))
        group_index, row_index = map(int, pieces[:2])
        degree = group_index + 2
        raw.setdefault(degree, {})[row_index] = T(pieces[2])

    groups = {}
    for degree, rows in sorted(raw.items()):
        if set(rows) != set(range(N_EQUATIONS)):
            missing = sorted(set(range(N_EQUATIONS)).difference(rows))
            raise ValueError(
                "homogeneous degree %d is incomplete; missing rows %s"
                % (degree, missing)
            )
        groups[degree] = tuple(rows[i] for i in range(N_EQUATIONS))
        for row, polynomial in enumerate(groups[degree]):
            monomial_degrees = set(sum(exponents) for exponents in polynomial.dict())
            if monomial_degrees and monomial_degrees != {degree}:
                raise ValueError(
                    "entry degree %d row %d has monomial degrees %s"
                    % (degree, row, sorted(monomial_degrees))
                )
    if 2 not in groups:
        raise ValueError("the quadratic group G#0 is missing")
    return K, T, groups, digest


def exact_splitting(A):
    """Return a partial right inverse, both kernels, and a minor certificate."""
    K = A.base_ring()
    pivot_columns = tuple(A.pivots())
    column_basis = A.matrix_from_columns(pivot_columns)
    pivot_rows = tuple(column_basis.transpose().pivots())
    minor = column_basis.matrix_from_rows(pivot_rows)
    assert minor.nrows() == minor.ncols() == A.rank()
    assert minor.det() != 0

    inverse = minor.inverse()
    P = zero_matrix(K, A.ncols(), A.nrows())
    for local_column, global_column in enumerate(pivot_columns):
        for local_row, global_row in enumerate(pivot_rows):
            P[global_column, global_row] = inverse[local_column, local_row]

    N = A.right_kernel().basis_matrix().transpose()
    L = A.left_kernel().basis_matrix()
    assert A * N == 0
    assert L * A == 0
    assert A * P * A == A
    return P, N, L, pivot_rows, pivot_columns, minor.det()


def multiply_series(left, right, cutoff, R):
    answer = [R.zero()] * (cutoff + 1)
    for i, left_coefficient in enumerate(left):
        if left_coefficient == 0:
            continue
        for j, right_coefficient in enumerate(right[: cutoff + 1 - i]):
            if right_coefficient != 0:
                answer[i + j] += left_coefficient * right_coefficient
    return answer


def variable_powers(coefficients, cutoff, maximum_power, R):
    """Return powers of all coordinate series, truncated at s^cutoff."""
    result = []
    one = [R.zero()] * (cutoff + 1)
    one[0] = R.one()
    for coordinate in range(N_PARAMETERS):
        first_power = [R.zero()] * (cutoff + 1)
        for order, vector_coefficient in coefficients.items():
            if order <= cutoff:
                first_power[order] = vector_coefficient[coordinate]
        powers = [one, first_power]
        for exponent in range(2, maximum_power + 1):
            powers.append(multiply_series(powers[-1], first_power, cutoff, R))
        result.append(powers)
    return result


def base_coefficient(groups, coefficients, order, R):
    """Return [s^order] sum_d g_d(t(s)) as an exact 27-vector."""
    available_degrees = [degree for degree in groups if degree <= order]
    maximum_power = max(available_degrees, default=1)
    powers = variable_powers(coefficients, order, maximum_power, R)
    answer = [R.zero()] * N_EQUATIONS

    for degree in available_degrees:
        for row, polynomial in enumerate(groups[degree]):
            total = R.zero()
            for exponents, scalar in polynomial.dict().items():
                monomial_series = [R.zero()] * (order + 1)
                monomial_series[0] = R(scalar)
                for coordinate, exponent in enumerate(exponents):
                    if exponent:
                        monomial_series = multiply_series(
                            monomial_series,
                            powers[coordinate][int(exponent)],
                            order,
                            R,
                        )
                total += monomial_series[order]
            answer[row] += total
    return vector(R, answer)


def nonzero_entries(vector_value, one_based=True):
    offset = 1 if one_based else 0
    return tuple(
        (index + offset, value)
        for index, value in enumerate(vector_value)
        if value != 0
    )


def degree_profile(polynomials):
    profile = {}
    for polynomial in polynomials:
        if polynomial == 0:
            continue
        degree = polynomial.total_degree()
        profile[degree] = profile.get(degree, 0) + 1
    return tuple(sorted(profile.items()))


def build_symbolic_arc(groups, horizon, fix_v2_zero=False):
    K = next(iter(groups.values()))[0].base_ring()
    T = next(iter(groups.values()))[0].parent()
    tvars = T.gens()
    y = vector(K, [1] * N_PARAMETERS)
    y_substitution = dict(zip(tvars, y))

    A = matrix(
        K,
        [
            [polynomial.derivative(variable).subs(y_substitution) for variable in tvars]
            for polynomial in groups[2]
        ],
    )
    P, N, L, pivot_rows, pivot_columns, minor_det = exact_splitting(A)

    first_free_order = 3 if fix_v2_zero else 2
    free_orders = tuple(range(first_free_order, horizon))
    names = [
        "z%d_%d" % (coefficient_order, kernel_index + 1)
        for coefficient_order in free_orders
        for kernel_index in range(N.ncols())
    ]
    if names:
        R = PolynomialRing(K, names, order="degrevlex")
        generators = R.gens()
    else:
        R = K
        generators = ()

    parameter_vectors = {}
    cursor = 0
    for coefficient_order in free_orders:
        parameter_vectors[coefficient_order] = vector(
            R, generators[cursor : cursor + N.ncols()]
        )
        cursor += N.ncols()

    coefficients = {1: vector(R, [1] * N_PARAMETERS)}
    if fix_v2_zero:
        coefficients[2] = vector(R, [0] * N_PARAMETERS)
    constraints_by_order = {}
    residuals = {}
    full_equations = {}

    tangent_equation = base_coefficient(groups, coefficients, 2, R)
    if tangent_equation != 0:
        raise ValueError(
            "the all-ones tangent is not in the quadratic cone: %s"
            % (nonzero_entries(tangent_equation),)
        )
    if fix_v2_zero:
        cubic_equation = base_coefficient(groups, coefficients, 3, R)
        if cubic_equation != 0:
            raise ValueError(
                "v2=0 does not solve the order-three equation: %s"
                % (nonzero_entries(cubic_equation),)
            )

    PR = P.change_ring(R)
    NR = N.change_ring(R)
    LR = L.change_ring(R)
    start_order = 4 if fix_v2_zero else 3
    for order in range(start_order, horizon + 1):
        # At this point coefficients ends at v_(order-2), so this is r_order.
        residual = base_coefficient(groups, coefficients, order, R)
        residuals[order] = residual
        compatibility = LR * residual
        constraints = tuple(value for value in compatibility if value != 0)
        constraints_by_order[order] = constraints

        coefficient_order = order - 1
        z = parameter_vectors[coefficient_order]
        coefficients[coefficient_order] = -PR * residual + NR * z
        full_equations[order] = base_coefficient(groups, coefficients, order, R)

        # P kills the selected independent rows.  If all left-kernel
        # conditions vanish, compatibility is exact and all 27 rows vanish.
        assert all(full_equations[order][row] == 0 for row in pivot_rows)
        if not constraints:
            assert full_equations[order] == 0

    return {
        "ring": R,
        "A": A,
        "P": P,
        "N": N,
        "L": L,
        "pivot_rows": pivot_rows,
        "pivot_columns": pivot_columns,
        "minor_det": minor_det,
        "coefficients": coefficients,
        "constraints_by_order": constraints_by_order,
        "residuals": residuals,
        "full_equations": full_equations,
    }


def verify_sparse_order_four_arc(groups):
    """Verify the previously found sparse v3 coefficient independently."""
    K = next(iter(groups.values()))[0].base_ring()
    b = vector(K, [0] * N_PARAMETERS)
    b[0], b[10], b[15], b[25] = 1, 2, 1, -1
    coefficients = {
        1: vector(K, [1] * N_PARAMETERS),
        2: vector(K, [0] * N_PARAMETERS),
        3: b,
    }
    assert base_coefficient(groups, coefficients, 2, K) == 0
    assert base_coefficient(groups, coefficients, 3, K) == 0
    assert base_coefficient(groups, coefficients, 4, K) == 0
    return b


def preview_next_known_contribution(groups, data, horizon):
    """Project the next coefficient contributed by already exported terms.

    If degree horizon+1 is absent, the actual compatibility vector also has
    the unknown summand L*g_(horizon+1)(y).  This is only a diagnostic and is
    explicitly labelled as such in the certificate.
    """
    R = data["ring"]
    residual = base_coefficient(groups, data["coefficients"], horizon + 1, R)
    return data["L"].change_ring(R) * residual


def write_certificate(
    path,
    data,
    groups,
    horizon,
    fix_v2_zero,
    input_digest,
    sparse_b,
    preview=None,
):
    lines = []
    lines.append("field=GF(%d)" % FIELD_ORDER)
    lines.append("input_sha256=%s" % input_digest)
    lines.append("exported_degrees=%s" % (tuple(sorted(groups)),))
    lines.append("horizon=%d" % horizon)
    lines.append("fix_v2_zero=%s" % fix_v2_zero)
    lines.append("rank_A=%d" % data["A"].rank())
    lines.append("right_kernel_dimension=%d" % data["N"].ncols())
    lines.append("left_kernel_dimension=%d" % data["L"].nrows())
    lines.append("pivot_rows_1based=%s" % (tuple(i + 1 for i in data["pivot_rows"]),))
    lines.append(
        "pivot_columns_1based=%s"
        % (tuple(i + 1 for i in data["pivot_columns"]),)
    )
    lines.append("pivot_minor_determinant=%s" % data["minor_det"])
    lines.append("sparse_v3_nonzero=%s" % (nonzero_entries(sparse_b),))

    for order in sorted(data["constraints_by_order"]):
        equations = data["constraints_by_order"][order]
        lines.append(
            "order_%d_nonzero_compatibility_count=%d" % (order, len(equations))
        )
        lines.append(
            "order_%d_compatibility_degree_profile=%s"
            % (order, degree_profile(equations))
        )
        lines.append(
            "order_%d_full_coefficient_zero=%s"
            % (order, data["full_equations"][order] == 0)
        )
        for index, equation in enumerate(equations, 1):
            lines.append("E_%d_%d=%s" % (order, index, equation))

    if preview is not None:
        lines.append(
            "order_%d_known_only_projected_count=%d"
            % (horizon + 1, sum(value != 0 for value in preview))
        )
        lines.append(
            "order_%d_known_only_projected_degree_profile=%s"
            % (horizon + 1, degree_profile(preview))
        )
        for index, equation in enumerate(preview, 1):
            lines.append(
                "known_only_E_%d_%d=%s" % (horizon + 1, index, equation)
            )

    for coefficient_order in sorted(data["coefficients"]):
        vector_value = data["coefficients"][coefficient_order]
        lines.append(
            "v_%d_nonzero_count=%d"
            % (coefficient_order, sum(value != 0 for value in vector_value))
        )
        for coordinate, value in nonzero_entries(vector_value):
            lines.append("v_%d_%d=%s" % (coefficient_order, coordinate, value))

    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n")


def run_mode(label, fix_v2_zero, groups, digest, horizon, output_path, preview_next):
    data = build_symbolic_arc(groups, horizon, fix_v2_zero=fix_v2_zero)
    sparse_b = verify_sparse_order_four_arc(groups)
    preview = (
        preview_next_known_contribution(groups, data, horizon)
        if preview_next
        else None
    )
    write_certificate(
        output_path,
        data,
        groups,
        horizon,
        fix_v2_zero,
        digest,
        sparse_b,
        preview=preview,
    )
    print("mode", label)
    for order, equations in sorted(data["constraints_by_order"].items()):
        print(
            "  order", order,
            "nonzero compatibility equations", len(equations),
            "full coefficient zero", data["full_equations"][order] == 0,
        )
    if preview is not None:
        print(
            "  order", horizon + 1,
            "known-only projected equations", sum(value != 0 for value in preview),
            "degree profile", degree_profile(preview),
        )
    print("  certificate", output_path)
    return data


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input", default="generated/versal_base_GF32003.txt",
        help="absolute path or path relative to this proof directory",
    )
    parser.add_argument("--horizon", type=int, default=5)
    parser.add_argument("--mode", choices=("both", "generic", "a0"), default="both")
    parser.add_argument(
        "--certificate-dir", default="certificates",
        help="absolute path or path relative to this proof directory",
    )
    parser.add_argument(
        "--certificate",
        help="single output path; valid only with --mode generic or --mode a0",
    )
    parser.add_argument("--preview-next", action="store_true")
    args = parser.parse_args()

    input_path = proof_path(args.input)
    K, T, groups, digest = load_export(input_path)
    if args.horizon > max(groups):
        raise ValueError(
            "cannot certify order %d: export stops in degree %d"
            % (args.horizon, max(groups))
        )
    if args.mode == "both" and args.certificate:
        parser.error("--certificate requires --mode generic or --mode a0")

    print("input", input_path)
    print("input sha256", digest)
    print("exported homogeneous degrees", tuple(sorted(groups)))

    certificate_directory = proof_path(args.certificate_dir)
    modes = (
        (("generic", False), ("a0", True))
        if args.mode == "both"
        else ((args.mode, args.mode == "a0"),)
    )
    for label, fix_v2_zero in modes:
        if args.certificate:
            output_path = proof_path(args.certificate)
        else:
            output_path = certificate_directory / (
                "%s_through_%d_certificate.txt" % (label, args.horizon)
            )
        data = run_mode(
            label,
            fix_v2_zero,
            groups,
            digest,
            args.horizon,
            output_path,
            args.preview_next,
        )

    print("rank A", data["A"].rank())
    print("right kernel", data["N"].ncols(), "left kernel", data["L"].nrows())
    print("pivot rows (1-based)", tuple(i + 1 for i in data["pivot_rows"]))
    print("pivot columns (1-based)", tuple(i + 1 for i in data["pivot_columns"]))
    print("pivot minor determinant", data["minor_det"])


if __name__ == "__main__":
    main()
