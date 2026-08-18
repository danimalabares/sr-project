This directory receives deterministically regenerable exports.  From the
repository root, run `export_base.m2` for the GF(32003) versal-base
truncation, `export_base_QQ.m2` for its characteristic-zero counterpart, and
`export_t1_QQ.m2` for the tangent representatives.  The generated files are
ignored.  `export_rational_two_jet.m2` likewise writes the canonical rational
two-jet used by `check_prescribed_two_jet.sage`.  The corresponding verifiers
record generated-file SHA-256 digests in the checked-in certificates.
