# Claim ledger

This ledger uses five classifications:

- **Target proof**: established by a mathematical argument printed in the
  audited target.
- **Exact computation**: established by a non-circular exact calculation whose
  code, inputs, output object, and logical translation were inspected.
- **Canonical import**: established in explicitly identified frozen/canonical
  repository material and replayed here.
- **External theorem**: follows from a stated classical theorem whose relevant
  hypotheses hold.
- **Unsupported strengthening**: not established as printed; the effect and
  minimal correction are stated.

“Target proof + exact computation” means that the computation certifies a
precise algebraic premise and the target separately proves the claimed
mathematical consequence.

| # | Substantive claim | Classification | Evidence and hostile-audit conclusion |
|---:|---|---|---|
| 1 | The intended simplicial complex is the Grünbaum--Sreedharan Complex M. | Canonical import + primary-source check | Facets at `PROOF_DGLA.tex:73-91` agree term-for-term with Table 4 of Grünbaum--Sreedharan (1967), Complex M. |
| 2 | The 16 displayed cubics are exactly the inclusion-minimal nonfaces. | Exact computation | `referee-packet/code/verify_combinatorics.py`; summarized at `PROOF_DGLA.tex:118-126`. The script enumerates subsets and minimality, not an expected list comparison alone. |
| 3 | The special complex is pure of dimension 3 with 97 faces. | Exact computation | Same exact combinatorics replay; `PROOF_DGLA.tex:118-123`. |
| 4 | Every link has the rational homology required by Reisner. | Exact computation | The script builds boundary matrices and uses exact `Fraction` row reduction for every face, including the empty face; `PROOF_DGLA.tex:123-126`. |
| 5 | `A=S/I` is Cohen--Macaulay of dimension 4. | External theorem + exact computation | Reisner's criterion applied to claims 2--4; dimension is `dim Delta+1`; `PROOF_DGLA.tex:126-127`. |
| 6 | The actual theorem is a flat projective `Q[[s]]` family with special fibre `X_0` and smooth geometric generic fibre. | Target proof + exact computations | Statement `PROOF_DGLA.tex:100-110`; dependency chain `:1279-1289`; audited below. |
| 7 | The theorem proves total-space smoothness, generic irreducibility, trivial canonical class, or a named smooth threefold. | Unsupported/false as an attribution | Explicitly disclaimed at `PROOF_DGLA.tex:113-116`; no such stronger result follows here. |
| 8 | The final family is spread out over a finite-type `Q`-base. | Unsupported strengthening | No such base is constructed. `PROOF_DGLA.tex:1017-1027` gives a scheme over `Q[[s]]`; Tag 0899 is not finite-type spreading out. Add Noetherian approximation if this convention is required. |
| 9 | A staged Tate resolution with finitely many generators in each homological degree exists. | Target proof | Inductive construction at `PROOF_DGLA.tex:182-221`, using Noetherianity and homogeneous cycle generators. |
| 10 | The initial stages have 16 `e`, 30 `f`, and 136 `g` generators with the printed weights. | Canonical import + exact computation | `PROOF_DGLA.tex:187-201`; canonical sparse data and bracket replay confirm counts `16,30,16+120`. |
| 11 | `ker D1=image D2`. | Canonical import + exact computation | `audits/tate-stage/MATHEMATICAL_CERTIFICATE.md:73-115`; full unbounded syzygy modules, exact two-sided lifts, replayed in Macaulay2 and Singular. |
| 12 | `ker D2=image[D3 Z]`. | Canonical import + exact computation | Same certificate, with independently reconstructed signed `D3`; not a bounded-degree rank check. |
| 13 | The 136 columns are sufficient degree-two Tate cycles. | Exact computation | Claims 11--12 imply the `g` generators kill all homological-degree-two stage homology; `PROOF_DGLA.tex:223-230`. |
| 14 | The 136 cycles are `H^3` classes or a basis of `H^3`. | Unsupported/false as an attribution | The target expressly rejects this at `PROOF_DGLA.tex:254-266`; they are differentials of Tate generators, not derivation-cohomology classes. |
| 15 | `Der_S(P,P)_0` is the fixed-coordinate embedded controller used in the construction. | Target proof | Relative derivations fix `S`; `PROOF_DGLA.tex:269-282`. No general deformation-functor equivalence is needed. |
| 16 | `Der_Q(P,P)_0` is the absolute complex used for the 53-dimensional quotient tangent. | Target proof + exact computation | `PROOF_DGLA.tex:283-285`, `:364-410`. |
| 17 | Relative and absolute derivation groups coincide in cohomological degrees at least 1. | Target proof | A positive-degree derivation kills `P_0`; `PROOF_DGLA.tex:287-303`. This is literal equality. |
| 18 | `H^q(relative)=H^q(absolute)` for `q>=2`, but only a surjection in `H^1`. | Target proof | Coboundaries enter from equal degree-one terms for `q>=2`; `PROOF_DGLA.tex:301-308`. |
| 19 | `Der(P,P)->Der(P,A)` is a quasi-isomorphism, absolutely and relatively. | Target proof | Kähler-differential filtration, acyclic augmentation kernel, surjective inverse limit, weight splitting; `PROOF_DGLA.tex:326-361`. |
| 20 | Relative `H^1=Hom_S(I,A)_0`. | Target proof + canonical completeness | Complete `R_0` syzygies make closed `e`-values exactly well-defined maps `I->A`; `PROOF_DGLA.tex:364-386`. |
| 21 | Absolute `H^1` is the quotient by coordinate Jacobian boundaries. | Target proof | The only extra cochain group is `(A_1)^8` in degree zero; `PROOF_DGLA.tex:369-372`, `:387-389`. |
| 22 | Relative `H^1` has dimension 109. | Independent exact computation | Target check `verify_fable_dgla.m2:31-46`; independently reconstructed in `check_controller_complex.py` from sparse `F,R,Z`. |
| 23 | Coordinate boundaries have rank 56 and absolute `H^1` has dimension 53. | Independent exact computation | `rank delta_0=56`; `109-56=53`; same two independent paths as claim 22. |
| 24 | `H^2` has dimension 27. | Independent exact computation | `dim C2-rank delta1-rank delta2=6960-1555-5378=27` in `check_controller_complex.py`; package result separately agrees. |
| 25 | The `s`-adic dg Lie algebra is complete and separated and brackets add orders. | Target proof | Definition and product topology at `PROOF_DGLA.tex:416-424`; also `DG_LIE_INDUCTION.tex:61-70`. |
| 26 | Maurer--Cartan is literally the square-zero equation for `D=d+alpha`. | Target proof | Correct odd-commutator calculation at `PROOF_DGLA.tex:450-456`. |
| 27 | A finite-level Maurer--Cartan element produces exactly 16 deformed cubic generators. | Target proof | Degree-zero boundaries are generated by `D(e_i)`; weight three and relative linearity; `PROOF_DGLA.tex:468-472`. |
| 28 | The cubics specialize to the 16 Stanley--Reisner generators. | Target proof | `alpha` has positive `s`-order, so `D(e_i)=m_i mod s`; `PROOF_DGLA.tex:471-472`. |
| 29 | The perturbed Tate complex is acyclic in positive degrees over every `R_n`. | Target proof | Induction through `0 -> s^(n-1)P -> P_n -> P_(n-1) ->0`; `PROOF_DGLA.tex:458-466`. |
| 30 | Every graded piece of `H_0` is finite free over `R_n` with special-fibre rank. | Target proof + external theorem re-proved | Fixed-weight finite free resolution, Tor vanishing, Artinian local flatness/Nakayama; `PROOF_DGLA.tex:474-494`. |
| 31 | The same positive acyclicity is proved over `Q[[s]]` by the printed paragraph. | Unsupported strengthening | Asserted at `PROOF_DGLA.tex:444-447`, but `:496-499` only treats `H_0` reductions. Add compatible weightwise boundary lifting. Main theorem uses claim 29. |
| 32 | The infinite formal derivation is well-defined on `P tensor Q[[s]]`. | Target proof, under-explained | Weight preservation places each generator value in a fixed finite-dimensional bidegree. This is explicit for `e_i` at `PROOF_DGLA.tex:993-996`; state it for all generators at `:975`. |
| 33 | The package produces `F^[3]Q^[3]=0` over `Q[s]/(s^4)`. | Exact computation | Direct matrix equality in `verify_fable_dgla.m2:57-70` and `completion/verify_starting_jet.m2:36-49`. |
| 34 | The specialized base equations vanish through the required order. | Exact computation | `base3==0` in the same scripts, over the quotient ring, not point sampling. |
| 35 | `Q_0` contains all special first syzygies, not a selected subset. | Exact computation | Fresh `gens ker F0` has 30 columns and equals `R#0`; `verify_fable_dgla.m2:72-76`. |
| 36 | The starting family entries are cubic and relation entries linear in `x`. | Exact computation | Explicit `isHomogeneous` and degree assertions at `verify_fable_dgla.m2:78-88`. This certifies the repaired weight-zero premise. |
| 37 | The first-order family coefficient is literally `T1*y`. | Exact computation | Entrywise equality at `verify_fable_dgla.m2:90-96`; used in the chain bridge. |
| 38 | The starting reduction mod `s^3` is exactly the frozen two-jet. | Exact computation | Regenerated file compared byte-for-byte at `verify_fable_dgla.m2:98-107`; SHA-256 printed in `PROOF_DGLA.tex:573-577`. |
| 39 | A constant invertible matrix `U` satisfies `Q_0 U=R_0`, with determinant 1. | Exact computation | `referee-packet/code/verify_aq_bracket.m2:90-111`; orientation matches `PROOF_DGLA.tex:588-595`. |
| 40 | The displayed `D(e),D(f)` satisfies `D^2=0`. | Target proof + exact computation | `D^2(f)=F^[3]Q^[3]U`; `PROOF_DGLA.tex:619-628`. |
| 41 | The square-zero `D` extends through all `g` and all later Tate generators. | Target proof + canonical import | Filtered cycle lifting `PROOF_DGLA.tex:513-533`; exact low-stage hypotheses and later Tate acyclicity applied at `:630-645`. |
| 42 | The certified `R_4` family is a genuine truncated relative Maurer--Cartan element. | Target proof | `alpha_bar=D-d` is relative, weight zero, positive order, and square-zero; `PROOF_DGLA.tex:647-655`. |
| 43 | The 27 transported `T^2` columns are closed. | Exact computation | `delta2*T2cocycles==0`; `verify_aq_bracket.m2:134-176`. |
| 44 | Those 27 classes are independent modulo every degree-two boundary. | Exact computation | Degree-zero image in `coker delta1` has 27 columns; `verify_aq_bracket.m2:177-179`. |
| 45 | Those 27 classes span `H^2_0`. | Exact computation + independent dimension check | Quotienting by boundaries and all 27 leaves zero degree-zero kernel; `verify_aq_bracket.m2:180-185`. Independently, claim 24 gives total dimension 27. |
| 46 | `ad_theta:H^2->H^3` has rank 12. | Exact computation + target proof | Chain-level commutators have rank 12 modulo `delta2`; global closure and the injection into `C3/image delta2` justify the `H^3` translation; `PROOF_DGLA.tex:662-706`. |
| 47 | The primary map `ad_theta:H^1->H^2` has rank 15. | Exact computation | `rank Dq_y=15`, `T2` columns injective, and direct primary commutators equal `-T2 Dq_y`; `verify_aq_bracket.m2:195-241`. |
| 48 | The composite primary then secondary map is zero. | Exact computation | Direct matrix equality at `verify_aq_bracket.m2:242-247`, plus the independently formed Jacobi composite at `:209-214`. Not inferred from dimensions. |
| 49 | The actual linear coefficient `a` induces the same cohomology maps as script cocycle `theta`. | Target proof | Identical `e`-values, derivation quasi-isomorphism, and boundary-bracket identity; `PROOF_DGLA.tex:740-767`. |
| 50 | `H^1(relative)->H^2(relative)->H^3(relative)` is exact at `H^2`, with ranks 15 and 12. | Target proof + exact computations | Dimension, zero composite, and relative/absolute transfer at `PROOF_DGLA.tex:772-826`. Extra 56 relative tangent classes map trivially. |
| 51 | The strict Bianchi identity has the printed signs. | Target proof, independently re-derived | `PROOF_DGLA.tex:850-865`; `DG_LIE_INDUCTION.tex:79-113`. Odd antisymmetry and Jacobi give the formula. |
| 52 | The initial curvature starts in order `s^4` with the printed `r_4,r_5,r_6`. | Target proof, independently re-derived | `PROOF_DGLA.tex:942-952`; `DG_LIE_INDUCTION.tex:172-185`. |
| 53 | At order `s^N`, `r_N` is a cocycle and its class lies in `ker ad_a`. | Target proof | Coefficients `s^N` and `s^(N+1)` of Bianchi; `PROOF_DGLA.tex:891-901`. |
| 54 | The correction `s^(N-1)v-s^N w` kills the obstruction with correct sign/order. | Target proof, independently re-derived | Exact curvature-change formula and `2N-2>=N+2`; `PROOF_DGLA.tex:903-926`. |
| 55 | The corrections converge to a genuine Maurer--Cartan element. | Target proof | Coefficient stabilization plus complete separated filtration; `PROOF_DGLA.tex:928-937`. |
| 56 | The construction preserves the two-jet but not necessarily the full `R_4` element. | Target proof | First correction is `s^3v-s^4w`; `PROOF_DGLA.tex:938-962`. Any claim of mod-`s^4` preservation would be unsupported. |
| 57 | Each final `F_i` is an honest polynomial in `x` with coefficients in `Q[[s]]`. | Target proof | Weight-three target is finite-dimensional; `PROOF_DGLA.tex:982-998`. It need not be polynomial in `s`. |
| 58 | The final quotient is finitely presented and Proj is projective over `Q[[s]]`. | Target proof | Sixteen homogeneous polynomials define a closed subscheme of projective space; `PROOF_DGLA.tex:1001-1029`. |
| 59 | Every final graded piece `B_j` is free over `Q[[s]]`. | Target proof | Finite reductions, Krull intersection, DVR torsion-free implies free; `PROOF_DGLA.tex:1031-1045`. |
| 60 | `X->Spec Q[[s]]` is flat. | Target proof | Graded direct-sum flatness, localization, and degree-zero direct summands on standard charts; `PROOF_DGLA.tex:1045-1048`. |
| 61 | Generic Betti numbers are bounded by special Betti numbers. | Target proof | A common free resolution with `R`-flat syzygies and universal coefficients; `PROOF_DGLA.tex:1060-1088`. |
| 62 | Every field extension of the generic coordinate ring is Cohen--Macaulay of dimension 4. | Target proof + external theorems | Constant Hilbert function, Auslander--Buchsbaum, flat base change of Tor; `PROOF_DGLA.tex:1090-1117`. |
| 63 | Every generic minimal component has affine dimension 4/projective dimension 3. | Target proof + external theorem | CM unmixedness at the irrelevant maximal ideal and homogeneous-prime correspondence; `PROOF_DGLA.tex:1119-1127`. |
| 64 | Every closed projective point has local dimension 3 solely because all components have dimension 3. | Unsupported as stated | `PROOF_DGLA.tex:1128-1130` omits the finite-type dimension theorem. Stacks Tag 0A21, Lemma 33.20.3(2),(5), applies here and gives exactly the assertion; cite it, since purity alone is not a general proof. |
| 65 | A geometric generic point is singular iff the affine Jacobian rank is at most 3. | Target proof after claim 64's minor repair | Exact chart ideal, local dimension 3, tangent dimension `7-rank`; `PROOF_DGLA.tex:1140-1158`. |
| 66 | The 280 chart pairs cover all potential rank-`<=3` incidences. | Target proof | 8 projective standard charts and all `binomial(7,4)=35` Grassmann charts; `PROOF_DGLA.tex:1161-1174`. |
| 67 | Each certificate proves `s^2 in (q_1,...,q_80)+(s^3)`. | Exact computation | Exact 3-row truncated-module encoding with columns `q,sq,s^2q`; `PROOF_DGLA.tex:1176-1193`; checker source inspected. |
| 68 | All 280 memberships pass. | Exact computation | Fresh exact replay: 277 at degree 6 and `(2,7),(6,12),(8,16)` at degree 8; driver checks pair coverage and a retained lift. |
| 69 | A 280 membership alone proves smoothness. | Unsupported/false | Correctly disclaimed at `PROOF_DGLA.tex:1195-1199`; it only supplies a polynomial identity for the two-jet. |
| 70 | A hypothetical singular geometric point descends after a finite field extension. | External theorem | The incidence is finite type over `K`; a nonempty finite-type `K`-scheme has a closed point with finite residue extension; `PROOF_DGLA.tex:1210-1222`. |
| 71 | The integral closure in that finite extension is a finite complete DVR. | External theorem | `Q[[s]]` is complete/Henselian; in characteristic zero the finite field extension is separable and has one extended valuation. Stacks Section 15.113, Remark 15.113.6 (Tag 0EXQ); `PROOF_DGLA.tex:1224-1227`. |
| 72 | Properness extends the point and four-plane to integral sections. | External theorem | Valuative criterion for projective space/`X` and the Grassmannian; `PROOF_DGLA.tex:1229-1245`. |
| 73 | Changing to a unit projective chart preserves the needed four-dimensional kernel. | Target proof | Both generic affine charts compute the intrinsic tangent space; the four-plane is reselected; `PROOF_DGLA.tex:1233-1240`. This repairs the chart-change issue. |
| 74 | Changing the equations by `s^3 H_i` changes every incidence generator by a multiple of `s^3`. | Target proof | Dehomogenization, differentiation, and integral matrix multiplication preserve the factor; `PROOF_DGLA.tex:1259-1267`. |
| 75 | The DVR evaluation gives a contradiction. | Target proof + exact membership | `s^2=s^3c` implies `2v(s)>=3v(s)` with `v(s)>0`; `PROOF_DGLA.tex:1268-1274`. |
| 76 | The constructed geometric generic fibre is smooth over the algebraic closure. | Target proof | Claims 62--75; regular equals smooth over an algebraically closed characteristic-zero field, and a nonempty closed nonsmooth locus has a closed point. |
| 77 | Every flat projective family with this two-jet is covered by the printed proof. | Unsupported strengthening | `PROOF_DGLA.tex:1205-1207` imports Proposition 8.2, proved using the constructed coordinate ring's graded-piece freeness. Delete or add the missing hypotheses/theorem. |
| 78 | The proof uses only strict dg Lie deformation theory. | Target-source audit | Only `partial`, the binary commutator, ordinary Maurer--Cartan curvature, and strict Bianchi occur in the proof. `check_fable.py` is merely a static guard; the conclusion comes from full manual source inspection. |
| 79 | `verify.sh --all` certifies a fresh TeX build. | Unsupported as a wrapper claim | `verify.sh:33-38` invokes ordinary `latexmk` after preserving target timestamps, so it can do no work. Forced `latexmk -g` builds passed independently. |
| 80 | The complete mathematical and computational replay succeeds on the audited machine. | Exact replay | Fresh temporary target/canonical copies returned the semantic lines recorded in `AUDIT_REPORT.md` and `REPRODUCE.md`; no canonical or target file was written. |

## Net dependency chain

The theorem-relevant chain is:

```text
certified low Tate stages
    -> genuine relative R4 Maurer--Cartan element
    -> exact H1 --ad_a--> H2 --ad_a--> H3
    -> strict Bianchi obstruction killing with fixed two-jet
    -> sixteen Q[[s]]-coefficient cubics and degreewise-flat quotient
    -> CM/equidimensional geometric generic fibre
    -> 280 identities + integral chart change + DVR valuation
    -> smooth geometric generic fibre.
```

The four unsupported/under-explained statements in rows 8, 31, 64, and 77
are not links needed for the constructed `Q[[s]]` family once the indicated
standard sentences or scope restriction are supplied.
