# Claim ledger — hostile audit of `proofs/grunbaum-smoothing/fable-dgla-only/`

Auditor: independent (this directory).  Date: 2026-08-27.
Target HEAD: `866e9f186a65485a3a71eb3554c33c840a757612`, branch `restructure`.

Status vocabulary (per audit mandate):

- **PROVED** — proved in the target from definitions;
- **COMPUTED** — established by a non-circular exact computation that I
  inspected at source level and replayed (or re-derived independently);
- **IMPORTED** — imported from explicitly identified canonical material;
- **EXTERNAL** — external theorem whose precise hypotheses were checked;
- **UNSUPPORTED** — not supported by the cited evidence (regardless of
  truth value).

All line numbers refer to the audited files at the recorded HEAD.

## 1. Theorem statement (mandatory target 1)

| # | Claim | Where | Status |
|---|---|---|---|
| 1.1 | Theorem 1.1: sixteen cubics `F_i ∈ Q[[s]][x]`, `F_i ≡ m_i (mod s)`, reduction mod `s³` = frozen two-jet, `Proj` flat projective over `Q[[s]]`, special fibre `X₀`, smooth geometric generic fibre | PROOF_DGLA.tex:100–111 | PROVED, assembled at 1279–1290 from the items below; the assembly is correct given its inputs |
| 1.2 | No stronger claim (total-space smoothness, irreducibility, CY, `H³` dimension, `s⁴`-preservation) is made or used | PROOF_DGLA.tex:113–116, 254–267, 955–963; STATUS.md:24–26, 180–187 | VERIFIED — grepped both TeX sources; the non-claims are genuine and the sharpness remark (DG_LIE_INDUCTION.tex:281–289) is mathematically correct |
| 1.3 | Special fibre is the Stanley–Reisner scheme of the 20-facet complex; the 16 monomials are its minimal nonfaces; `A` is CM with `depth_{S₊}A = 4` | PROOF_DGLA.tex:118–128; referee-packet/code/verify_combinatorics.py | COMPUTED (replayed; script inspected: exact `Fraction` row reduction, minimal-nonface set equality at lines 18–25/128, Reisner links at 148–160) + EXTERNAL (Reisner's criterion, correctly stated for links' reduced homology below top dimension over `Q`) |
| 1.4 | The complex is "the" Grünbaum–Sreedharan 1967 sphere | PROOF_DGLA.tex:82, bibliography | IMPORTED — the citation is bibliographically real; the identification of the facet list with the 1967 paper's sphere was not verifiable offline.  Immaterial: the theorem quantifies over the explicitly listed complex |

## 2. Controller (mandatory target 2)

| # | Claim | Where | Status |
|---|---|---|---|
| 2.1 | Sign conventions define strict dg Lie algebras; `∂=[d,−]`, graded commutator; weights as tabulated | PROOF_DGLA.tex:130–156 | PROVED (re-derived by hand; conventions consistent throughout) |
| 2.2 | Staged Tate resolution exists with the tabulated generators (16/30/136 in degrees 1/2/3, weights 3/4/5,6) | PROOF_DGLA.tex:182–231 (Lemma 2.1) | PROVED (inline re-proof of Tate's construction is correct; over `Q` no divided powers needed) + COMPUTED for the specific table (item 2.3) |
| 2.3 | `D₁D₂=0, D₂D₃=0, D₂Z=0, ker D₁=im D₂, ker D₂=im[D₃ Z]` as unbounded graded module identities | PROOF_DGLA.tex:233–252; audits/tate-stage/ | COMPUTED — dual-CAS (Macaulay2 full `syz` + two-sided lifts; Singular independent reconstruction + full `syz`), replayed 2026-08-27; I additionally re-verified `F₀·R = 0`, module equality `im R = ker F₀`, `D₂·Z = 0` and all `Z`-column weights from the raw tsv with my own parser (`independent_exactness.m2`, lines 66–103) |
| 2.4 | tsv data = the DGAlgebras model actually used by the frozen bracket script | tate-stage provenance | COMPUTED — my `independent_provenance.m2` rebuilds the pinned deterministic `killCycles` model and proves entrywise equality of its `d(f)`, `d(g)` with the tsv `R`, `Z` |
| 2.5 | `h^p = g^p` for `p ≥ 1`; `H^q(h)=H^q(g)` for `q≥2`; `H¹(h) ↠ H¹(g)` | PROOF_DGLA.tex:287–309 (Lemma 2.4) | PROVED (re-derived: degree-`p≥1` derivations kill `P₀=S`, hence `S`-linear; coboundary comparison correct) |
| 2.6 | Derivation quasi-isomorphisms `g → Der(P,A)₀`, `h → Der_S(P,A)₀` | PROOF_DGLA.tex:326–362 (Lemma 2.5) | PROVED (re-derived: semifree filtration of `Ω`, acyclicity of `Hom(F_q/F_{q−1},Q)`, Milnor sequence with surjective transition maps, weight-product decomposition — all steps check) |
| 2.7 | `H¹(h) = Hom_S(I,A)₀` (dim 109), `im(Jac)₀` (dim 56), `H¹(g) = T¹₀` (dim 53 = 109−56); `H²` dim 27 | PROOF_DGLA.tex:364–411 | COMPUTED — replayed via `verify_fable_dgla.m2`; **independently re-derived by me** with no deformation package from the tsv data: `ker(δ¹)₀ = 109`, Jacobian image 56, quotient 53, `dim H²₀ = 27` (`independent_exactness.m2`).  The two distinct characterizations of `H¹(h)` (M2 `Hom(I,A)` vs `ker δ¹` with `R` complete) agree, confirming Lemma 2.6(1); the classical Lichtenbaum–Schlessinger `T²(A)₀ = 27` was additionally recomputed package-free (`independent_T2_LS.m2`), confirming Lemma 2.6(3)'s identification from a third angle |
| 2.8 | Filtration `ŝh = s·h[[s]] = ∏ s^j h` complete, separated, bracket adds levels | PROOF_DGLA.tex:415–423; DG_LIE_INDUCTION.tex:61–70 | PROVED (immediate) |

## 3. Maurer–Cartan realization (mandatory target 3)

| # | Claim | Where | Status |
|---|---|---|---|
| 3.1 | `D=d+α` square-zero ⇔ MC; `D` is `R_n[x]`-linear weight-preserving | PROOF_DGLA.tex:450–456 | PROVED (`(d+α)² = ∂α + ½[α,α]` re-derived; sign conventions verified) |
| 3.2 | `H_i(P⊗R_n, D)=0` for `i>0`; `H₀ = R_n[x]/(D(e_i))`; each `D(e_i)` a cubic ≡ `m_i` mod `s` | PROOF_DGLA.tex:458–472 | PROVED (subcomplex `s^{n−1}(P⊗R_n) ≅ (P,d)` because `α` has positive `s`-order; long exact sequence induction re-derived; degree-0/1 structure of `P` gives the presentation) |
| 3.3 | Weightwise flatness/freeness over `R_n`; local flatness criterion in the Artinian case | PROOF_DGLA.tex:474–494 | PROVED (the truncated perturbed complex is a finite free resolution; `−⊗k` returns the Tate complex; `Tor₁ = 0`; the inline Nakayama re-proof of the Artinian case of Tag 00MK is correct) + EXTERNAL (Tag 00MK statement verified verbatim against the Stacks Project on 2026-08-27) |
| 3.4 | Same over `R = Q[[s]]` via truncations | PROOF_DGLA.tex:444–447, 496–499 | PROVED (right-exactness of `H₀` under base change) |
| 3.5 | Filtered cycle-lifting lemma | PROOF_DGLA.tex:513–533 (Lemma 3.3) | PROVED (re-derived; the induction on `s`-order and weight-homogeneous primitives are correct given `H_{q−2}(Q)=0`) |
| 3.6 | Sixteen deformed cubics and SR specialization at `s=0` | PROOF_DGLA.tex:468–472, 982–999 | PROVED + COMPUTED (two-jet byte identity; weight homogeneity, item 4.3) |

## 4. `R₄` family → truncated MC element (mandatory target 4)

| # | Claim | Where | Status |
|---|---|---|---|
| 4.1 | `F^{[3]}Q^{[3]} = 0` over `R₄[x]`; base equations vanish at `y` | PROOF_DGLA.tex:552–581; completion/verify_starting_jet.m2:43–49; verify_fable_dgla.m2:64–70 | COMPUTED (both scripts replayed from fresh copies; the identity is checked by exact matrix multiplication over `QQ[s,z]/(s⁴)`, not modulo anything weaker) |
| 4.2 | `Q₀` is the complete 30-column first-syzygy matrix | verify_starting_jet.m2:53–56; verify_fable_dgla.m2:73–76 | COMPUTED (replayed: `R#0 == substitute(gens ker F0, ·)`); independently: my module equality `im R = ker F₀` for the Tate-side matrix |
| 4.3 | Weight homogeneity: family entries `x`-degree 3, relation entries `x`-degree 1 | verify_fable_dgla.m2:85–88 (new check) | COMPUTED (replayed; I additionally verified both frozen two-jet rows are homogeneous cubics by an independent parse, `independent_exactness.m2:154–156`) |
| 4.4 | Constant `U` with `Q₀U = R₀`, `det U = 1` | PROOF_DGLA.tex:588–596; verify_aq_bracket.m2:90–103 | COMPUTED (replayed; note `det U=1` is stronger than needed — only `Q₀U = R₀` with constant `U` is load-bearing, and module equality `im Q₀ = im R₀` was re-proved independently) |
| 4.5 | `D` defined on `e,f` by (4.4) satisfies `D²=0` there; `D ≡ d mod s` | PROOF_DGLA.tex:597–656 (Prop 4.2) | PROVED (algebra re-derived: `D²(f_j) = (F^{[3]}Q^{[3]}U)_j = 0`; reduction uses 4.4) |
| 4.6 | Extension of `D` over all Tate generators of degree ≥ 3; hypotheses `H₁(P_{<3})=0`, `H₂(P_{<4})=0` are exactly the certified equalities; degrees ≥ 5 by Tate acyclicity | PROOF_DGLA.tex:629–645 | PROVED given item 2.3 (I checked the degree bookkeeping: for `q=3` the needed equality is `ker D₁ = im D₂`; for `q=4` it is `ker D₂ = im[D₃ Z]`, whose boundary space correctly includes the `g`-columns since `P_{<4} = S[e,f,g]`) |
| 4.7 | `ᾱ = D−d ∈ MC(h⊗(s)/(s⁴))`, linear coefficient `a` has `a(e_i) = (T¹y)_i` | PROOF_DGLA.tex:646–656; verify_fable_dgla.m2:92–96 | PROVED + COMPUTED (replayed: `firstOrder == transpose(T1*y)` and byte identity with the frozen two-jet file, which pins `a`'s e-values to the file across processes) |

## 5. Strict Bianchi induction (mandatory target 5)

| # | Claim | Where | Status |
|---|---|---|---|
| 5.1 | Strict Bianchi identity `∂F(γ) + [γ,F(γ)] = 0` | PROOF_DGLA.tex:850–866; DG_LIE_INDUCTION.tex:81–113 | PROVED — re-derived sign by sign: `∂½[γ,γ] = −[γ,∂γ]` and `[γ,[γ,γ]] = 0` from graded Jacobi in char 0; both correct |
| 5.2 | Curvature-change formula (6.5)/(2.2) | PROOF_DGLA.tex:913–918; DG_LIE_INDUCTION.tex:115–126 | PROVED (`[δ,γ]=[γ,δ]` for odd elements; correct) |
| 5.3 | Initial case: `F(γ⁽⁴⁾) = s⁴([a₁,a₃]+½[a₂,a₂]) + s⁵[a₂,a₃] + s⁶·½[a₃,a₃]` | DG_LIE_INDUCTION.tex:172–185; PROOF_DGLA.tex:942–953 | PROVED — re-expanded by hand; the low-order MC identities (3.2) are extracted correctly |
| 5.4 | Step 1 (`∂r_N = 0`): `s^N`-coefficient of Bianchi | DG_LIE_INDUCTION.tex:200–206 | PROVED (all bracket terms have order `m+n ≥ N+1`; correct) |
| 5.5 | Step 2 (`[a,r_N] = −∂r_{N+1}`): `s^{N+1}`-coefficient | DG_LIE_INDUCTION.tex:207–215 | PROVED (only `(m,n)=(1,N)` contributes; correct) |
| 5.6 | Step 3/4: correction `δ_N = s^{N−1}v − s^N w` with `r_N+[a,v]=∂w` kills `r_N`, disturbs nothing below, `½[δ,δ] ∈ F^{2N−2} ⊆ F^{N+2}` for `N≥4` | DG_LIE_INDUCTION.tex:217–253 | PROVED — every power and sign re-checked (`∂δ = −s^N∂w` since `∂v=0`; `[γ−sa, s^{N−1}v] ∈ F^{N+1}`; `2N−2 ≥ N+2 ⇔ N ≥ 4`) |
| 5.7 | Convergence and separatedness; two-jet preserved (corrections in `F^{N−1} ⊆ F³`), `s³`-coefficient NOT preserved, and this sharpness is correctly acknowledged | DG_LIE_INDUCTION.tex:255–289; PROOF_DGLA.tex:928–963; STATUS.md:180–187 | PROVED — coefficient stabilization index re-checked; the target explicitly does not claim `R₄`-preservation, which would require `[r₄]=0`, and nothing downstream consumes coefficients beyond `s²` |
| 5.8 | Exactness hypothesis used only as `ker ⊆ im`; converse inclusion automatic for MC linear coefficients (`[a,a] = −2∂a₂`) | DG_LIE_INDUCTION.tex:149–158 | PROVED (re-derived; this also makes the target's exactness argument robust to whether the `ψ` classes span `H¹`) |

## 6. Exactness at `H²`, the 27 classes, and the 136 cycles (mandatory target 6)

| # | Claim | Where | Status |
|---|---|---|---|
| 6.1 | The 136 `g`-columns are used ONLY as Tate-stage completeness, never as `H³` classes; no `H³` dimension used | PROOF_DGLA.tex:254–267, 709–713; grep of both TeX files | VERIFIED — confirmed by reading every use; the `H³`-side rank is computed in `C³/im δ²` on globally-closed columns, into which `H³` injects (Cor 5.2, correct) |
| 6.2 | Global closed extension of `θ`, `η_j`, `ψ_t` over the full resolution | PROOF_DGLA.tex:672–693 (Lemma 5.1) | PROVED given item 2.3 (first open case `p=1,q=3` needs `ker D₁ = im D₂`; `q ≥ 4` needs stage acyclicity; degree bookkeeping re-checked) |
| 6.3 | The 27 transported columns are closed and independent mod `im δ¹` | PROOF_DGLA.tex:715–723; verify_aq_bracket.m2:136–139, 177–179 | COMPUTED (replayed; assert semantics verified sound — source `A^27` in degree 0; independently reproduced: my own 27 classes, `independent_exactness.m2:134–144`) |
| 6.4 | **Spanning**: "no weight-zero cocycle in `C²` remains outside their span plus `im δ¹`; hence `[η_j]` is a basis of the 27-dimensional `H²(g)`" | PROOF_DGLA.tex:718–721 (Comp. 5.3(1)), citing frozen line `T2_remaining_degree_zero_cocycles=0` (verify_aq_bracket.m2:185, 264); same claim repeated at AUDIT.md:164–172 ("spanning is checked, not assumed") and REPRODUCE.md:92–95 | **UNSUPPORTED by the cited computation — the frozen assert is vacuous** (Finding F1 in AUDIT_REPORT.md): `H2quotient` inherits generator degrees +4, weight-zero classes live in module degree 8, and `basis(0, ker delta2quotient)` inspects an empty graded piece, so the assert cannot fail for any data.  **The claim itself is TRUE and is now certified twice independently**: (i) my package-free computation `dim H²₀ = ker(δ²)₀/im(δ¹)₀ = 27` from the tsv data (`independent_exactness.m2:134–144`); (ii) instrumentation of a scratch copy of the frozen script showing `basis(8, ker delta2quotient) = 0` (the meaningful degree), with nonzero kernel pieces in degrees 6–7 proving the original degree-0 test was vacuous, and `basis(8, H2quotient) = 5378` proving non-degeneracy |
| 6.5 | `rank(ad_θ : H² → H³) = 12` (in genuine `H³` via the injection on closed columns) | PROOF_DGLA.tex:695–707, 722–723; verify_aq_bracket.m2:186–189 | COMPUTED (replayed) + **independently re-derived**: with my own `H²` basis, my own `θ` built from the frozen two-jet row, all closure solves assert-certified: rank = 12 (`independent_exactness.m2`) |
| 6.6 | Primary identity `[θ,ψ_t] = −J·Dq_y` mod boundaries, `rank Dq_y = 15`, image dimension 15 | PROOF_DGLA.tex:724–727; verify_aq_bracket.m2:195–241 | COMPUTED (replayed) + **independently strengthened**: I computed `rank(ad_θ : H¹(h) → H²)` directly on the full 109-dimensional relative cocycle space = 15 (`independent_exactness.m2`), which certifies the relative-controller image dimension with no transfer lemma and no `versalDeformation` at all |
| 6.7 | Zero composite | verify_aq_bracket.m2:242–244 | COMPUTED (replayed) + independently reproduced (composite rank 0 on my spans) |
| 6.8 | Bridge lemma: `a − θ = ∂ξ`, so `ad_a = ad_θ` on `H^p(h)`, `p ≥ 1` | PROOF_DGLA.tex:743–768 (Lemma 5.4) | PROVED (re-derived; the shared e-values are pinned by the byte-certified two-jet — my independent `θ` literally uses the frozen file's first-order row, closing any cross-process determinism gap) |
| 6.9 | Transfer of exactness from `g` to `h` (109 vs 53 discrepancy harmless) | PROOF_DGLA.tex:772–836 (Prop 5.5) | PROVED (re-derived: `Z¹(h)=Z¹(g)`, `[θ,∂ξ] = −∂[θ,ξ]` with `[θ,ξ] ∈ g¹=h¹`) — and **independently bypassed**: my rank-15 computation is on `H¹(h)` directly |

## 7. Convergence and the algebraic family (mandatory target 7)

| # | Claim | Where | Status |
|---|---|---|---|
| 7.1 | `F_i = D_∞(e_i)` is a polynomial in `x` (degree 3) with `Q[[s]]` coefficients — no `x`-completion | PROOF_DGLA.tex:982–999 (Lemma 7.1) | PROVED (weight preservation of `α_∞` — the induction corrections `v,w` lie in the weight-zero algebra `h` by definition — forces each `s`-coefficient into the finite space `S₃`) |
| 7.2 | `X = Proj(R[x]/(F_i))` is projective and flat over `Spec Q[[s]]`, special fibre `X₀`; each `B_j` free of rank `dim A_j` | PROOF_DGLA.tex:1009–1049 (Prop 7.2) | PROVED (re-derived: truncation freeness + Krull intersection ⇒ torsion-free ⇒ free over the DVR; chart flatness via degree-zero summand) |
| 7.3 | The family is finitely presented over `Spec Q[[s]]`; no algebraization over a finite-type base is claimed; Tag 0899 route optional only | PROOF_DGLA.tex:1017–1028 (footnote) | PROVED / EXTERNAL (Tag 0899 statement verified verbatim against the Stacks Project 2026-08-27; its hypotheses as listed in the footnote match; genuinely unused) |

## 8. The 280 certificates and generic smoothness (mandatory target 8)

| # | Claim | Where | Status |
|---|---|---|---|
| 8.1 | Betti semicontinuity `dim Tor_i(B_K,K) ≤ dim Tor_i^S(A,k)` | PROOF_DGLA.tex:1060–1088 (Lemma 8.1) | PROVED (re-derived: `R`-flat syzygies of the flat `B`, fibrewise resolutions, universal coefficients over the DVR) — this is the target's replacement for the citation-fragile Tag 0E7T route, and it is correct |
| 8.2 | `B_L` CM of dim 4, unmixed, all components of `X_K̄` of dim 3, local rings of dim 3 at closed points; stable under any field extension `L/K` | PROOF_DGLA.tex:1090–1131 (Prop 8.2) | PROVED (Hilbert function constant by flatness; Auslander–Buchsbaum twice; CM ⇒ unmixed; Tor and Hilbert functions commute with field extension — all steps re-checked) + EXTERNAL (Bruns–Herzog facts cited at section level; standard) |
| 8.3 | Each Proj chart is cut out by the sixteen dehomogenized cubics; Jacobian dichotomy: singular ⇔ `rank J(p) ≤ 3` ⇔ 4-plane in `ker J(p)` | PROOF_DGLA.tex:1140–1159 (Lemma 8.3) | PROVED (the degree-zero localization argument is correct; the dichotomy needs exactly the dimension-3 statement from 8.2) |
| 8.4 | The 280 memberships `s² ∈ (q₁..q₈₀) + (s³)` in `Q[z,a][s]` | PROOF_DGLA.tex:1176–1200; referee-packet/code/verify_incidence_chart.m2 + verify_all_incidence.py | COMPUTED — encoding inspected line by line: the 3×240 module over `Q[y,a]` is exactly `Q[z,a][s]/(s³)` as a free rank-3 module; the target `(0,0,1)ᵀ = s²`; zero remainder against a degree-limited GB is a valid positive membership certificate; the driver enforces coverage of all 280 pairs and the 6→8 retry; replayed (`proved 280/280`, degree-8 pairs `(2,7),(6,12),(8,16)`); **independently re-proved in Singular** with a different encoding and exact, re-multiplied lifts (`run_all_singular_incidence.py` → `independent_incidence_singular.txt`) |
| 8.5 | Incidence generators = two-jet only; higher coefficients `H_i` never consumed | verify_incidence_chart.m2:30–38 (reads only `universal_2jet_QQ.txt`) | VERIFIED (also confirms the induction's two-jet preservation is exactly what is needed) |
| 8.6 | DVR argument: `Σ` finite type, closed point with `K'/K` finite; `R'` complete DVR finite over `R`; properness extends point and plane; unit coordinate/Plücker selects one of the 280 pairs; chart change legitimate (intrinsic tangent space + 8.3); evaluation gives `s² = s³c`, valuation contradiction | PROOF_DGLA.tex:1204–1277 (Prop 8.5) | PROVED (re-derived in full; the chart-change step — the historically flagged gap — is now honestly handled: the four-plane is re-chosen in the unit-coordinate chart using intrinsicness of `T_pX_{K'}` and Lemma 8.3 applied over `K'`) + EXTERNAL (Serre, Local Fields Ch. II: integral closure of a complete DVR in a finite extension is a complete DVR, finite — standard; valuative criterion of properness — standard) |
| 8.7 | Smoothness of `X_K̄` from no singular closed point | PROOF_DGLA.tex:1274–1277 | PROVED (singular locus closed; regular + perfect field ⇒ smooth) |

## 9. Verification-infrastructure claims

| # | Claim | Where | Status |
|---|---|---|---|
| 9.1 | `verify.sh --all` replays all four packages non-mutatingly from temporary copies | fable-dgla-only/verify.sh | VERIFIED behaviorally (replayed from a scratch copy; canonical trees byte-unchanged; regenerated certificates byte-identical to the committed ones) |
| 9.2 | `check_fable.py` bans higher-operation constructs and enforces certificate contents | check_fable.py | VERIFIED (patterns inspected; MC and Bianchi formulas genuinely present in both TeX sources; no L∞/transfer constructs found by my own grep either) |
| 9.3 | Environment pins | REPRODUCE.md:135–140 | VERIFIED (M2 1.20, VersalDeformations 3.0, DGAlgebras 1.1.0, Singular 4.4.1, Python 3.13.7 present and used) |
