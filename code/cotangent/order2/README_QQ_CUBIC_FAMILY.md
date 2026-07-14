# QQ cubic family checkpoint

This is the finite cubic deformation pattern after leaving finite fields.

Run from `code/cotangent/order2`:

```bash
sage 19_solve_cubic_family_over_QQ.sage
sage 20_verify_cubic_family_over_QQ_from_json.sage
./21_archive_QQ_cubic_family.sh
```

Expected permanent files:

```text
cache/cubic_family_QQ.sobj
cache/cubic_family_QQ_data.json
cache/cubic_family_QQ_verification.sobj
cache/QQ_cubic_family_snapshot_<timestamp>.tar.gz
cache/QQ_cubic_family_snapshot_<timestamp>.tar.gz.sha256
```

Meaning:

```text
F(t) = f + tG_1 + t^2G_2 + t^3G_3
S(t) = s + tA_1
```

The verifier checks over `QQ`:

```text
order 1: sG_1 + A_1 f = 0          exactly
order 2: sG_2 + A_1G_1 = 0         modulo I
order 3: sG_3 + A_1G_2 = 0         modulo I
order 4: A_1G_3 = 0                modulo I
```

This proves the cubic formal deformation pattern over `QQ`, hence over `C` by base change.

It does not yet prove smoothness of a fiber.
