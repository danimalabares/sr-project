# Terminology and foundations audit

Date of audit: 2026-08-19

Audited packet: /Users/daniel/github/grunbaum-smoothing-referee/

This is a read-only audit. No file in the referee packet, its archive, or the
source repository was changed. The packet should remain frozen until Sergei
Burkin or another human expert has reviewed this document.

## 1. Disposition

The expression “André–Quillen bracket” (and its abbreviation “AQ bracket”) is
not supported in the packet as established terminology. Targeted exact-phrase
searches found no primary mathematical source using those expressions, while
the primary sources examined use other, more specific descriptions. This is a
serious scholarly error. This audit does not prescribe a cosmetic replacement.
A revision should first define the chain-level construction and then use
terminology selected and approved by a human expert.

The terminology error does not, by itself, make the chain-level operation
fictitious. For a full cofibrant commutative DG-algebra resolution
\(P\to A\), the graded commutator on
\(\operatorname{Der}_k(P,P)\) is a genuine dg-Lie operation. In characteristic
zero its induced graded Lie operation on tangent/André–Quillen cohomology is
resolution-independent up to dg-Lie quasi-isomorphism. Those statements are
supported by the primary literature cited below.

The present packet is nevertheless not ready to be certified as a complete
proof. Two foundations issues remain:

1. The pinned DGAlgebras 1.1.0 implementation is asked to construct the
   homological-degree-two and degree-three Tate stages in a situation outside
   the scope stated in that implementation for killCycles. The script checks
   many consequences, but it does not independently prove that the 136 listed
   degree-three generators kill all required degree-two homology. The
   all-later-degrees Tate-extension lemma is correct only after this low-stage
   premise is established.
2. HighestOrder=>3 supplies a finite Massey lift. The packet does not fully
   prove that this finite, embedded, graded package deformation is the
   truncation of the same classical graded deformation hull controlled by the
   tangent dg Lie algebra, with a comparison preserving the printed family
   two-jet. Hinich’s theorem supplies a route to such a comparison, but the
   relative/absolute, graded, classical-flat, and embedded identifications are
   not carried out.

Both issues appear repairable; neither is evidence that the smoothing theorem
is false. Until they are repaired, however, the all-orders family and the final
smoothing theorem are classified **Repairable**, not **Proved**.

The Claude M1 objection about \(U(0)\) is valid against any argument that simply
drops \(U(0)\). The exact source and the script do prove more than a rank
comparison: they construct a map \(J\) from all 27 package obstruction
coordinates to the chosen Tate cohomology classes and compute
\(\operatorname{ad}_yJ\). If a completed-hull comparison
\(G=U\kappa\phi\) preserving those class pairings is established, then
\(J=U(0)^{-1}\). That last identification depends on the formal-hull bridge
which the packet has not proved. Thus \(U(0)=I\) is neither assumed nor
justified, and the M1 coordinate algebra is repaired only conditionally on
both the missing hull comparison and the low-stage Tate premise. M1 is not an
independent third defect, but neither is it unconditionally discharged.

### Classification vocabulary

- **Proved**: established by a cited theorem whose hypotheses are checked, or
  by an exact computation together with a justified interpretation.
- **Repairable**: the stated conclusion has a concrete plausible repair, but a
  necessary bridge or verification is missing from the packet.
- **Unsupported**: asserted or named without adequate evidence; truth is not
  decided merely by the assertion.
- **False**: mathematically wrong as stated. A statement marked false may be a
  warning about a possible inference rather than a sentence actually made in
  the packet.

## 2. Exhaustive occurrence inventory

The primary scope of this inventory is the packet tree named above. It has 20
UTF-8 textual files and one binary PDF. A case-insensitive scan for AQ bracket,
aq_bracket, André–Quillen ... bracket, and the TeX spelling
Andr\'e--Quillen ... bracket produced the following textual occurrences and no
others in that tree.

| File | Location | Occurrence | Kind |
|---|---:|---|---|
| PROOF.tex | 47 | “intrinsic André–Quillen bracket” | substantive terminology |
| PROOF.tex | 137 | “André–Quillen tangent-Lie bracket” | substantive terminology |
| PROOF.tex | 318 | code/verify_aq_bracket.m2 | filename reference |
| PROOF.tex | 335 | verification/aq_bracket_QQ.txt | filename reference |
| REFEREE_GUIDE.md | 23 | code/verify_aq_bracket.m2 | filename reference |
| REFEREE_GUIDE.md | 146 | “AQ bracket and exactness” | substantive table label |
| REPRODUCE.md | 55 | code/verify_aq_bracket.m2 | command |
| REPRODUCE.md | 98 | verification/aq_bracket_QQ.txt | filename reference |
| verify.sh | 25 | “computing the intrinsic Andre-Quillen bracket” | substantive progress label |
| verify.sh | 26 | code/verify_aq_bracket.m2 | command |
| MANIFEST.sha256 | 8 | code/verify_aq_bracket.m2 | filename |
| MANIFEST.sha256 | 14 | verification/aq_bracket_QQ.txt | filename |
| code/check_results.py | 69 | aq_bracket_QQ.txt | filename |
| code/verify_aq_bracket.m2 | 249 | verification/aq_bracket_QQ.txt | output filename |

The two filenames code/verify_aq_bracket.m2 and
verification/aq_bracket_QQ.txt are themselves additional path-level uses of
the abbreviation. PROOF.pdf is a generated rendering of PROOF.tex and
reproduces the substantive and path occurrences from that source; it contains
no independent mathematical claim.

Two external mirrors also exist beside the packet and must not be mistaken for
additional scholarly claims. /Users/daniel/github/CLAUDE_PACKET.txt is a
verbatim text export: its 24 matching lines consist of its table of contents,
manifest and filename boundaries as well as copies of the 14 packet-text hits.
/Users/daniel/github/grunbaum-smoothing-referee.tar.gz is a binary container of
the packet and therefore contains the same occurrences inside its members.
The text export was scanned directly. The archive was not unpacked during this
audit; its mirror status is based on its role as the generated packet archive,
not on a second global textual scan. They are mirrors, not omissions from the
packet-tree count. This audit document itself necessarily quotes the questioned
expressions and is not part of the frozen packet.

The following claims depend on the operation denoted by those terms, even when
the exact phrase is absent:

1. PROOF.tex 127–138: the commutator on
   \(\operatorname{Der}(P,P)\) controls deformations and induces an intrinsic
   operation on \(T^\ast\).
2. PROOF.tex 164–189: that operation is transported to the package hull
   coordinates, including \(U(0)^{-1}\).
3. PROOF.tex 232–307 and REFEREE_GUIDE.md 22–88: the 27 computed commutators
   give genuine \(T^3\)-classes.
4. PROOF.tex 309–335: the map
   \(\operatorname{ad}_y:T^2_0\to T^3_0\) has rank 12 and
   \(\ker\operatorname{ad}_y=\operatorname{im}Dq_y\).
5. PROOF.tex 338–375 and REFEREE_GUIDE.md 32–38, 90–107: the Bianchi identity
   and that exactness construct an all-orders arc.
6. PROOF.tex 377–417: the arc supplies a formal embedded family with sixteen
   all-orders cubic equations.
7. PROOF.tex 419–535: the fixed two-jet of that family is the input to the 280
   incidence calculations and the generic-smoothness argument.
8. PROOF.tex 537–611: algebraization and flatness are applied to that formal
   family, yielding the claimed smoothing.

Thus the terminology does not sit in an isolated label. The all-orders
existence claim and the final theorem depend transitively on the mathematical
identification behind it. The numerical statements
\(\dim T^1_0=53\), \(\dim T^2_0=27\), \(q(y)=0\),
\(\operatorname{rank}Dq_y=15\), and the 280 ideal memberships are independent
exact calculations, although the proof uses them in the dependent chain above.

## 3. What the computation actually constructs

### 3.1 The algebra and the materialized DG algebra

The ground field is \(k=\mathbb Q\),
\(S=k[x_1,\ldots,x_8]\), and \(A=S/I\), with the ordered input
\[
\begin{aligned}
I=(\,&x_6x_7x_8,x_4x_6x_8,x_3x_7x_8,x_3x_5x_7,
x_3x_4x_8,x_2x_7x_8,\\
&x_2x_5x_7,x_2x_5x_6,x_2x_4x_7,x_2x_4x_6,
x_1x_4x_6,x_1x_4x_5,\\
&x_1x_3x_8,x_1x_3x_6,x_1x_3x_5,x_1x_2x_5\,).
\end{aligned}
\]
The augmentation sends every positive homological-degree generator to zero
and \(S\) to \(A\).

The script code/verify_aq_bracket.m2 materializes a finite semi-free
commutative DG \(S\)-algebra \(E\):

\[
 E=S[e_1,\ldots,e_{16},f_1,\ldots,f_{30},g_1,\ldots,g_{136}]
\]

with:

| generators | homological degree | internal degree |
|---|---:|---:|
| \(e_1,\ldots,e_{16}\) | 1 | 3 |
| \(f_1,\ldots,f_{30}\) | 2 | 4 |
| 16 of the \(g_a\) | 3 | 5 |
| 120 of the \(g_a\) | 3 | 6 |

The differential has homological degree \(-1\), preserves internal degree,
and satisfies \(d(e_i)=m_i\), the sixteen generators of \(I\). The \(f_j\)
have differentials given by a 30-column syzygy matrix. The \(g_a\) have the
cycles returned by the second killCycles call as their differentials.

The full \(P\) used in the proof is not printed generator-by-generator. It is
defined abstractly as a Tate completion of this \(E\), obtained by adjoining
generators in increasing homological degree until

\[
 H_0(P)=A,\qquad H_n(P)=0\quad(n>0).
\]

Since \(S\) is itself polynomial over \(k\), a semi-free extension over \(S\)
is also a semi-free commutative \(k\)-DGA after including the eight
degree-zero polynomial generators. In characteristic zero the divided-power
and ordinary graded-commutative descriptions agree in the relevant sense.

**Classification.** Existence of some full Tate resolution is **Proved** by
Avramov, Proposition 6.1.4. The exact finite generator inventory of \(E\) is
**Proved** by exact computation. The assertion that the displayed \(g_a\) comprise
the complete degree-three stage needed before all later generators have degree
at least four is **Repairable**, because the pinned killCycles call is outside
its stated implementation scope and no independent \(H_2\)-vanishing check is
present.

### 3.2 The derivation complexes

For a degree-\(p\) derivation, “degree \(p\)” in the packet means that the map
lowers homological degree by \(p\). Let

\[
 \mathfrak g^p=\operatorname{Der}^p_k(P,P)_0,
\]

where the subscript is internal degree zero. Its differential is

\[
 \partial\theta=[d,\theta]
   =d\circ\theta-(-1)^p\theta\circ d,
\]

and its graded commutator is

\[
 [\theta,\eta]
   =\theta\circ\eta-(-1)^{pq}\eta\circ\theta
   \quad(\theta\in\mathfrak g^p,\ \eta\in\mathfrak g^q).
\]

Composition itself need not preserve derivations, but this graded commutator
does. With the displayed differential it makes
\(\operatorname{Der}_k(P,P)_0\) a dg Lie algebra.

The coefficient complex used to compute cotangent cohomology is

\[
 C^p=\operatorname{Der}^p_k(P,A)_0,\qquad
 T^p_0(A)=H^p(C).
\]

Because \(A\) is concentrated in homological degree zero, a degree-\(p\)
cochain in \(C^p\) is determined by its values on homological-degree-\(p\)
Tate generators. Positive-degree derivations automatically vanish on
\(S=P_0\). The map induced by the augmentation,

\[
 \operatorname{Der}_k(P,P)_0\longrightarrow
 \operatorname{Der}_k(P,A)_0,
\]

is a quasi-isomorphism when \(P\) is a full cofibrant resolution: its module
of differentials is semi-free/cofibrant, so Hom from it preserves the
quasi-isomorphism \(P\to A\).

There is an important distinction. The strict composition commutator is on
\(\operatorname{Der}(P,P)\), not on
\(\operatorname{Der}(P,A)\). The latter has no raw composition bracket because
its target is \(A\), not \(P\). The operation on \(H^\ast(C)\) is transported
through the quasi-isomorphism.

On the materialized low stage, the internal-degree-zero cochain spaces are
\[
 C^1=(A_3)^{16},\qquad
 C^2=(A_4)^{30},\qquad
 C^3=(A_5)^{16}\oplus(A_6)^{120}.
\]
The cochain map \(d_C:C^1\to C^2\) is the transpose of the
30-column relation matrix, after reduction to \(A\). The map
\(d_C:C^2\to C^3\) is obtained from the coefficients linear in the
\(f_j\) in the 136 differentials \(d(g_a)\). The CT^1 calculation also
accounts for the preceding degree-zero/Jacobian image. The script proves in
internal degree zero that its 27 transported CT^2 columns are closed,
independent modulo \(d_C(C^1)\), and span
\(\ker(C^2\to C^3)/d_C(C^1)\).

This automatic vanishing on \(S\) does not apply to every degree-zero
derivation used for gauge. A degree-zero \(k\)-derivation can move the
polynomial generators of \(S\), whereas a derivation relative to \(S\)
cannot. The positive-degree maps computed here are unaffected, but the
distinction between abstract graded deformations and deformations of the fixed
presentation is another item that the formal-hull comparison must handle.

### 3.3 Cohomological indexing and the two computed maps

No additional shift is being used after converting the nonnegative
homological resolution grading to the cohomological derivation grading:

\[
 H^1(C)=T^1,\qquad H^2(C)=T^2,\qquad H^3(C)=T^3.
\]

Maurer–Cartan tangent classes are in degree 1. The degree-zero cohomology
operation induced by the dg-Lie commutator therefore has types

\[
 T^1\times T^1\longrightarrow T^2,\qquad
 T^1\times T^2\longrightarrow T^3.
\]

For the fixed class \(y\in T^1_0\), whose coordinates in the ordered CT^1
basis are
\[
\begin{aligned}
y=(\,&1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,\\
&35,42,1,4,10,1,25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,\\
&12,20,1,4,22,1,15,1,1,8,11\,),
\end{aligned}
\]
the script computes:

1. the primary map
   \[
   b_y:T^1_0\longrightarrow T^2_0,\qquad
   v\longmapsto[y,v],
   \]
   on all 53 basis vectors; the exact identity in the chosen Tate quotient is
   \(b_y=-J\,D(q_G)_y\), so after identifying the package equation space
   with \(T^2_0\) by \(J\), its matrix is \(-D(q_G)_y\);
2. the fixed-direction map
   \[
   a_y:T^2_0\longrightarrow T^3_0,\qquad
   w\longmapsto[y,w],
   \]
   on all 27 transported \(T^2_0\) basis vectors; the printed bracketMap is
   \(a_yJ:E\to T^3_0\).

Concretely, the script takes a degree-one derivation \(\theta_y\) which fixes
\(S\) and has values on the \(e_i\) given by the CT^1 column combination
\(y\). It solves and exactly rechecks the closure equations for its values on
the \(f_j\) and \(g_a\). For each of the 27 columns it takes a degree-two
derivation \(\eta_j\) which vanishes on \(S\) and the \(e_i\), has the
T2onF column as its values on the \(f_j\), and again solves and rechecks
closure on every displayed \(g_a\). It evaluates
\[
 [\theta_y,\eta_j]
   =\theta_y\eta_j-\eta_j\theta_y
\]
on the \(g_a\) and reduces the resulting columns in
\(C^3/d_C(C^2)\). It separately repeats the commutator with the 53
degree-one basis derivations to obtain \(b_y\). These are strict
chain-level graded commutators; their interpretation as the two intrinsic
cohomology maps is subject to the full-resolution premises audited below.

For an ordinary unshifted minimal \(L_\infty\)-model,
\(\ell_n\) has degree \(2-n\). Since degree-one inputs are odd, \(\ell_2\) is
symmetric on them. Consequently the quadratic curvature term

\[
 q_2(t)=\frac12\ell_2(t,t)
\]

has derivative \(D(q_2)_y(v)=\ell_2(y,v)\). This statement concerns the
quadratic term only. Identifying the entire Kuranishi/hull map, including
higher terms, with one half of a binary bracket would be **False**; the packet
does not make that identification.

## 4. Terminology in the primary literature

The literature supports the operation, but not the packet’s chosen name.

### 4.1 Derivations and André–Quillen cohomology

Block and Lazarev, *André–Quillen cohomology and rational homotopy of function
spaces*, Advances in Mathematics 193 (2005), 18–39:

- [Definition 2.1](https://www2.math.upenn.edu/~blockj/papers/BlockLazarevRat.pdf)
  defines their homological André–Quillen/Harrison quotient chain complex; the
  prose immediately before Theorem 2.4 introduces the cochain complex
  \(C^*_{AQ}(A,M)=\operatorname{Hom}_A(C_*^{AQ}(A,A),M)\);
- [Theorem 2.4](https://www2.math.upenn.edu/~blockj/papers/BlockLazarevRat.pdf)
  identifies André–Quillen cohomology with the cohomology of
  \(\operatorname{Der}(P,M)\) for a cofibrant replacement \(P\).
- The text preceding Theorem 2.8 describes the coderivation operation as
  “the commutator bracket which we will call the Gerstenhaber bracket.”
- [Theorem 2.8(1)](https://www2.math.upenn.edu/~blockj/papers/BlockLazarevRat.pdf)
  proves quasi-isomorphism invariance of
  \(\operatorname{Der}(P,P)\) for weakly equivalent cofibrant commutative
  DGAs.
- Theorem 2.8(3) compares that derivation dg Lie algebra with the
  coderivation/Harrison model.

Thus this source speaks of a *Gerstenhaber bracket on André–Quillen
cohomology* and of a graded Lie algebra structure. It does not use “AQ
bracket” in the checked text.

Hinich, *Homological algebra of homotopy algebras*, Communications in Algebra
25 (1997), 3291–3323,
[DOI 10.1080/00927879708826055](https://doi.org/10.1080/00927879708826055):

- Section 8 defines the *tangent Lie algebra* of a cofibrant operad algebra as
  its derivation dg Lie algebra.
- [the Lemma in Section 8.1 and Propositions 8.2.1 and
  8.3.1](https://arxiv.org/pdf/q-alg/9702015) construct the quasi-isomorphic
  comparison spans used for invariance.
- [Theorem 8.5.3](https://arxiv.org/pdf/q-alg/9702015) gives the functor on the
  maximal subgroupoids of the relevant homotopy categories which “assigns to
  each cofibrant \(O\)-algebra the dg Lie algebra
  \(T_A=\operatorname{Der}_O(A,A)\).”

Hinich’s [erratum](https://arxiv.org/pdf/math/0309453) corrects Theorem 6.1.1,
not the Section 8 results used here; it does not undermine this
characteristic-zero commutative-algebra application.

Schlessinger and Stasheff’s primary article is titled *The Lie algebra
structure of tangent cohomology and deformation theory*, Journal of Pure and
Applied Algebra 38 (1985), 313–322,
[DOI 10.1016/0022-4049(85)90019-2](https://doi.org/10.1016/0022-4049(85)90019-2).
Its terminology is tangent cohomology/tangent Lie algebra, not evidence for
the packet’s phrase; the publisher abstract says, “This d.g. Lie algebra,
called the tangent Lie algebra”.

### 4.2 Coderivation and convolution models are not the same chain model

Block–Lazarev’s coderivation/Harrison model has a commutator which their text
calls the Gerstenhaber bracket. Their Theorem 2.8 compares it, up to
quasi-isomorphism, with the derivation dg Lie algebra of a cofibrant
commutative DGA.

An operadic convolution deformation complex is a different chain
presentation. Millès, *André–Quillen cohomology of algebras over an operad*,
Advances in Mathematics 226 (2011), 5120–5164,
[DOI 10.1016/j.aim.2011.01.002](https://doi.org/10.1016/j.aim.2011.01.002),
[Section 1.3 and Definition
1.3.1](https://pure.mpg.de/pubman/item/item_3122530_1/component/file_3122531/milles_andre-quillen_oa_2011.pdf),
starts with a convolution pre-Lie product and an operadic twisting
Maurer–Cartan equation. Markl, *Intrinsic brackets and the
\(L_\infty\)-deformation theory of bialgebras*, Journal of Homotopy and
Related Structures 5 (2010), 177–212,
[Theorem 1 and Proposition
2](https://arxiv.org/pdf/math/0411456), uses *intrinsic bracket* in an
operadic/PROP deformation-complex setting. Neither source licenses calling an
arbitrary chain computation on a truncated Tate algebra by the packet’s
phrase. An explicit comparison is needed before identifying these chain
models.

### 4.3 Terminology classification

| Claim | Classification | Reason |
|---|---|---|
| “André–Quillen bracket” or “AQ bracket” is established terminology | **Unsupported** | No citation is given; exact-phrase searches found no primary use; checked primary sources use more specific terms. |
| The strict operation computed on \(\operatorname{Der}(P,P)\) is a graded commutator | **Proved** | Definition and direct sign check. |
| \(\operatorname{Der}(P,P)\) is the controlling/tangent dg Lie algebra for the exact deformation problem used by the packet | **Repairable** | Hinich proves the general control theorem; the packet still has to identify its exact graded classical deformation functor. |
| The induced operation on \(T^\ast\) is a graded Lie operation on André–Quillen/tangent cohomology for a full cofibrant \(P\) | **Proved** | Block–Lazarev Theorems 2.4 and 2.8. |
| The chain matrix itself is resolution-independent or canonical | **False** | Only the dg-Lie homotopy type and induced cohomology operation are invariant; representatives and bases are not. |
| \(\operatorname{Der}(P,A)\) itself has the composition commutator in general | **False** | Composition is not defined with target \(A\); the operation is transported from \(\operatorname{Der}(P,P)\) or an equivalent model. |
| The operation is Yoneda multiplication on \(\operatorname{Ext}_A(I/I^2,A)\) | **False** | It is induced by a dg-Lie commutator, and the naive conormal Ext complex need not compute higher intrinsic cotangent cohomology for this non-lci ring. |

## 5. Resolution independence and control of the deformation problem

### 5.1 What is independent

For full cofibrant commutative DGAs \(P\to A\) and \(P'\to A\), Hinich
Theorem 8.5.3 and Block–Lazarev Theorem 2.8 give a zigzag of dg-Lie
quasi-isomorphisms. Together with Hinich’s deformation-control theorem cited
below, under its hypotheses, this implies that:

- the cohomology groups;
- the induced graded Lie operation on cohomology; and
- the formal deformation problem represented by the dg-Lie homotopy type

are independent of the resolution in the appropriate homotopy category.

The following are not independent:

- the finite list of Tate generators;
- the values of a chosen derivation on those generators;
- the matrices relationChange, T2onF, bracketMatrix, and bracketMap; and
- signs and bases used for the package obstruction equations.

Those finite matrices can represent an invariant operation only after their
source and target bases have been compared with the cohomology bases. The
packet succeeds in pairing all finite package obstruction coordinates with
chosen cohomology classes. Interpreting that pairing as the constant term of a
comparison between completed hulls still requires the missing formal-hull
bridge.

### 5.2 Intrinsic formal control

Hinich, *Deformations of homotopy algebras*, Communications in Algebra 32
(2004), 473–494,
[DOI 10.1081/AGB-120027907](https://doi.org/10.1081/AGB-120027907),
[Theorem 2.1.2](https://arxiv.org/pdf/math/9904145), states in characteristic
zero, under its nonpositive-grading hypotheses, that “the deformation functor
... is equivalent to the nerve ... of the tangent dg Lie algebra.”
After reversing the Tate homological grading, the commutative operad and the
ordinary algebra \(A\) meet the basic grading and characteristic hypotheses.

That theorem does not automatically identify every object used in the packet:

1. The code retains the internal-degree-zero part, so the proof needs the
   weight-preserving/graded version of the equivalence.
2. The packet needs classical flat graded algebra deformations over ordinary
   Artin rings, not merely an object in a derived deformation groupoid.
3. VersalDeformations works with a chosen quotient presentation and returns
   embedded equations and relation matrices. The proof uses the absolute
   commutative-algebra tangent dg Lie algebra.
4. The exact printed two-jet must be preserved, up to a controlled change of
   the eight degree-one generators, when passing between the embedded package
   family and a Maurer–Cartan representative.

PROOF.tex 164 says that the completed Maurer–Cartan base is a hull and then
places the package equations in “another” minimal hull presentation. The
packet does not prove that the finite HighestOrder=>3 output is a truncation of
such a completed presentation, nor does it prove all four identifications
above. Ilten’s paper describes the finite-order Massey algorithm; it is not a
substitute for this comparison theorem.

**Classification.** Resolution independence of the cohomology operation is
**Proved**. Identification with the exact classical graded embedded
deformation problem and its printed package jet is **Repairable** but not
proved in the packet. This is a genuine logical gap in the application of the
otherwise valid tangent-dg-Lie theory.

## 6. The \(U(0)\) issue and Claude’s M1 objection

Let \(\kappa\) be an intrinsic minimal-model curvature in an \(H^2\) basis,
and let \(G\) be a tuple of package equations in a coordinate vector space
\(E\). If

\[
 G(t)=U(t)\kappa(\phi(t)),\qquad C=U(0),\qquad L=D\phi(0),
\]

then the quadratic terms and their derivative satisfy

\[
 q_G(t)=Cq_\kappa(Lt),\qquad
 D(q_G)_y=C\,D(q_\kappa)_{Ly}\,L.
\]

The transported Bianchi operator is

\[
 B_G(t)=d_{\phi(t)}U(t)^{-1},
\]

and its term linear in \(t\) is

\[
 B_{G,1}(y)=\operatorname{ad}_{Ly}\,C^{-1}.
\]

Therefore the exactness required in package equation coordinates is

\[
 \ker\!\left(\operatorname{ad}_{Ly}C^{-1}:E\to H^3\right)
   =\operatorname{im}\!\left(D(q_G)_y:T_{\rm pkg}\to E\right).
\]

Dropping \(C^{-1}\), or asserting \(C=I\) merely because both spaces have
dimension 27, is **False** in general.

### 6.1 What the exact code does

The current code contains more than a rank comparison:

1. In code/verify_aq_bracket.m2 90–101, relationChange is the constant
   30-by-30 change from the package syzygy basis to the \(f\)-generator basis.
   The script verifies the defining matrix identity, that every nonzero entry
   has degree zero, and \(\det(\mathrm{relationChange})=1\).
2. Lines 102–111 reproduce the package’s reduction of its supplied \(T^2\)
   columns modulo relationAction:
   \[
   \mathrm{NT2}
      = \mathrm{T2}\bmod\mathrm{relationAction},\qquad
   \mathrm{T2onF}
      ={}^t\!\mathrm{relationChange}\,\mathrm{NT2}.
   \]
3. The exact VersalDeformations 3.0 source at release-1.20, lines 419–433,
   performs that NT2 reduction and pairs the components of \(G\) with those
   ordered columns. Thus
   \[
   J:E\longrightarrow T^2,\qquad e_j\longmapsto
   [\,\mathrm{T2onF}_j\,]
   \]
   is the exact computational map from package equation coordinates to the
   chosen \(T^2\)-classes, including every constant scaling or normalization
   visible in that finite package calculation. Under a formal comparison
   \(G=U\kappa\phi\) compatible with these class pairings, it is \(C^{-1}\).
   The code alone does not construct that completed comparison.
4. Lines 142–189 form bracketMap by bracketing \(y\) with every one of those
   27 transported classes. Hence bracketMap represents
   \(\operatorname{ad}_yJ\), not an untransported operation on an unrelated
   \(H^2\) basis. Once the missing hull comparison identifies the linear
   tangent map and \(J=C^{-1}\), this is
   \(\operatorname{ad}_{Ly}C^{-1}\).
5. Lines 195–214 differentiate the 27 components of the same package
   quadratic tuple \(G_2\), verify rank 15, and verify
   \(\mathrm{bracketMap}\,Dq_y=0\).
6. Lines 216–247 independently compute all 53 primary commutators in the
   Tate complex and verify
   \[
   \mathrm{primaryMap}
      +\mathrm{T2onF}\,Dq_y=0
   \]
   in \(C^2/\operatorname{im}\delta_1\). This checks the orientation and the
   convention-dependent minus sign, rather than inferring them from ranks.

The same ordered CT^1 matrix is supplied to versalDeformation and used to
construct the degree-one derivations. This proves the finite source-coordinate
pairing; identifying it with the \(L\) of a completed hull comparison again
depends on the missing bridge.

Because the 27 T2onF columns are a basis, \(J\) is an isomorphism. The exact
rank calculation gives
\[
 \dim\ker(\mathrm{bracketMap})=27-12=15,
\]
while \(D(q_G)_y\) has rank 15 and
\(\mathrm{bracketMap}\,D(q_G)_y=0\). Hence
\[
 \ker(\mathrm{bracketMap})=\operatorname{im}D(q_G)_y
\]
in package equation coordinates. Together with
\(b_y=-J D(q_G)_y\) and
\(\mathrm{bracketMap}=a_yJ\), this is the intrinsic equality
\[
 \ker(a_y:T^2_0\to T^3_0)
   =\operatorname{im}(b_y:T^1_0\to T^2_0)
\]
once the computed commutator columns are certified as genuine \(T^3\)-classes.
This intrinsic equality depends on the low Tate-stage premise, but not on a
completed-hull comparison. Using the same matrices as the Bianchi complex for
the printed package equations additionally requires \(J=C^{-1}\) and the
formal-hull bridge.

### 6.2 Why higher terms of \(U(t)\) do not enter the leading obstruction

If all coefficients of \(G(t(s))\) below \(s^N\) vanish, write
\(G(t(s))=r_Ns^N+O(s^{N+1})\). Since the minimal Bianchi operator has no
constant term and begins in order \(s\),

\[
 U(t(s))^{-1}=C^{-1}+O(s)
\]

shows that the coefficient of \(s^{N+1}\) in \(B_GG\) uses only
\(\operatorname{ad}_{Ly}C^{-1}r_N\). Terms from the nonlinear part of
\(U^{-1}\), from the nonlinear part of \(\phi\), or from higher brackets have
order at least \(N+2\). Thus a full numerical computation of \(U(t)\) is not
needed for the induction; existence of the formal presentation comparison and
the identification of its constant map with \(J\) are needed.

### 6.3 M1 classification

| Claim | Classification |
|---|---|
| \(U(0)\) may simply be omitted | **False** |
| The packet proves \(U(0)=I\) | **False** as a description of the packet; it neither proves nor needs this |
| The code constructs \(J:E\to T^2\) and bracketMap \(=\operatorname{ad}_yJ\) on all 27 package equation coordinates | **Proved**; its intrinsic interpretation is conditional on the low Tate stage |
| This \(J\) is the \(U(0)^{-1}\) of a completed comparison \(G=U\kappa\phi\) | **Repairable**; it also requires the missing formal-hull bridge |
| The rank computation alone repairs M1 | **False** |
| The full formal equality \(G=U\kappa\phi\) for a completed package hull is established | **Repairable**, not proved; this is part of the formal-hull bridge gap |

## 7. Bianchi identity and the all-orders induction

In the ordinary unshifted cohomological convention,
\(\ell_n:\bigwedge^nH\to H\) has degree \(2-n\), and a minimal model has
\(\ell_1=0\). For \(t\in H^1\),

\[
 \kappa(t)=\sum_{n\ge2}\frac1{n!}\ell_n(t,\ldots,t)\in H^2,
\]

and for \(w\in H^2\),

\[
 d_t(w)=\sum_{n\ge0}\frac1{n!}
   \ell_{n+1}(t,\ldots,t,w)\in H^3.
\]

Fix the antisymmetric argument-order convention in which the displayed formula
defines the twisted differential. The \(L_\infty\) identities then give the
curved Bianchi identity exactly as \(d_t\kappa(t)=0\). Reordering the
arguments under another standard convention changes the displayed signs but
not the kernel conclusion below. The packet consistently uses the ordinary
unshifted degrees; the earlier \(L_\infty[1]\) convention error is not present
in this version.

For \(N\ge3\), suppose \(t(s)=sy+O(s^2)\) and

\[
 \kappa(t(s))=r_Ns^N+O(s^{N+1}).
\]

Because \(\ell_1=0\), the coefficient of \(s^{N+1}\) in the Bianchi identity
is exactly

\[
 \ell_2(y,r_N)=0.
\]

If
\[
 \ker(\ell_2(y,-):H^2\to H^3)
   =\operatorname{im}(Dq_y:H^1\to H^2),
\]
choose \(v_{N-1}\) with \(Dq_y(v_{N-1})=-r_N\). Adding
\(v_{N-1}s^{N-1}\) changes the quadratic curvature at order \(s^N\) by that
amount. An \(m\)-ary term with \(m\ge3\) containing the new coefficient has
order at least

\[
 (N-1)+(m-1)\ge N+1,
\]

so it does not disturb lower orders. Completeness gives a formal
Maurer–Cartan arc.

Here \(Dq_y\) means the derivative of the intrinsic quadratic curvature
\(q_2\), hence the map \(b_y\). It is not the untransported derivative of the
package tuple; in the audited coordinates
\(b_y=-J D(q_G)_y\).

The case \(N=2\) is the separate starting check \(q(y)=0\). A quadratic term
containing two copies of the new correction has order
\(2N-2\ge N+1\), so it likewise does not alter the coefficient being killed.

This induction is mathematically sound. In package coordinates the same proof
uses \(B_{G,1}(y)=\operatorname{ad}_{Ly}C^{-1}\) and \(D(q_G)_y\), as in
Section 6.

Even without the missing hull bridge, the exact primary-commutator identity and
the homogeneous equality \(D(q_G)_y(y)=2q_G(y)=0\) show intrinsically that
\([y,y]=0\). Therefore the intrinsic exactness calculation gives an abstract
formal Maurer–Cartan arc with first derivative \(y\), subject to the low Tate
premise. At order three the induction may choose a nonzero
\(s^2\)-coefficient.

The stronger finite starting assertion is exact only in package coordinates:
\(q_G(y)=0\) and the cubic package base term vanishes at \(y\), so the
returned finite deformation equation has no residual through the asserted
order along the uncorrected line. To conclude that the intrinsic arc may start
with that same uncorrected package two-jet requires the missing comparison.
Two conclusions do not follow from HighestOrder=>3 alone:

- that the package tuple is part of a completed minimal hull presentation
  related to the intrinsic \(L_\infty\) hull by \(U,\phi\); and
- that the resulting Maurer–Cartan continuation yields a classical flat
  embedded family whose reduction has exactly the printed two-jet.

One possible mathematical repair is to send the actual order-three embedded
deformation object into the controlling deformation groupoid, perform the
induction from that object, and then prove that a compatible choice of the
eight degree-one generators preserves its embedded two-jet. That repair is
not currently written.

**Classification.**

| Claim | Classification |
|---|---|
| Ordinary unshifted Bianchi identity | **Proved** |
| Order bookkeeping in the induction | **Proved** |
| Intrinsic exactness and \([y,y]=0\) imply an abstract all-orders MC arc with first derivative \(y\) | **Proved**, once the low Tate stage is certified |
| HighestOrder=>3 itself constructs an all-orders arc | **False** |
| The packet has proved the required identification of the package finite jet with the same classical graded formal hull | **Repairable** |
| The abstract arc can be chosen with the uncorrected package two-jet used in the incidence calculation | **Repairable**, pending that bridge |
| Proposition 2.15 as a statement about the displayed embedded two-jet | **Repairable**, pending that bridge and the low Tate-stage check |

## 8. Tate extension and genuine \(T^3\)-classes

### 8.1 Primary references

Avramov, *Infinite Free Resolutions*, in *Six Lectures on Commutative
Algebra*, Progress in Mathematics 166 (1998):

- [Proposition
  6.1.4](https://people.math.sc.edu/kustin/teaching/746/Avramov-Infinite-Free-Resolutions.pdf)
  states: “Each \(R\)-algebra \(S\) has a Tate resolution.”
- Remark 6.1.3 identifies the divided-power and ordinary
  graded-commutative forms over a \(\mathbb Q\)-algebra.
- Remark 6.2.2 describes derivations by their generator values and the signed
  Leibniz rule.
- Proposition 6.2.3 constructs the module of differentials and gives the
  derivation differential.
- Corollary 6.2.4 says that a surjective quasi-isomorphism of target DG
  modules induces a quasi-isomorphism of derivation complexes.
- Construction 6.2.5 defines the complex of indecomposables and its chain maps
  \(\delta_{n+1}:SX_{n+1}\to SX_n\).
- [Lemma
  6.2.6](https://people.math.sc.edu/kustin/teaching/746/Avramov-Infinite-Free-Resolutions.pdf)
  lifts appropriate chain maps to chain derivations.
- [Proposition
  6.2.7](https://people.math.sc.edu/kustin/teaching/746/Avramov-Infinite-Free-Resolutions.pdf)
  requires a class which “generates a free direct summand of
  \(\operatorname{Coker}\delta_{n+1}\)” before the corresponding generator
  evaluation is promoted to a chain derivation.

These references show why a newly adjoined degree-three variable does not, by
itself, create a \(T^3\)-class. An outgoing degree-four condition can kill a
degree-three cochain.

### 8.2 The packet’s stronger extension argument

Assume that the displayed degree-one and degree-two derivations are closed on
all Tate generators of homological degree at most three, and that all later
generators have degree \(n\ge4\). For a degree-\(p\) derivation
\(\vartheta\), \(p=1\) or \(2\), closedness on a newly adjoined generator
\(z\) requires

\[
 d(\vartheta z)=(-1)^p\vartheta(dz).
\]

The right side is a cycle because \(dz\) uses earlier generators and
\(\vartheta\) is already closed there. Its homological degree is
\(n-p-1\ge1\), so acyclicity of the full Tate resolution makes it a boundary.
A primitive has degree \(n-p<n\), hence involves only previously adjoined
generators. Internal-degree preservation lets one choose the required
homogeneous component. Induction extends each derivation globally.

For global closed derivations \(\theta\) and \(\eta\), the dg-Lie identity
implies that \([\theta,\eta]\) is a global closed degree-three derivation. Its
image in \(\operatorname{Der}(P,A)\) therefore satisfies the outgoing cochain
condition \(d_C:C^3\to C^4\), dual to the relevant degree-four Tate data, even
though the code does not materialize degree-four generators. Moreover,

\[
 H^3(C)=\ker(d_C:C^3\to C^4)/\operatorname{im}(d_C:C^2\to C^3)
   \hookrightarrow C^3/\operatorname{im}(d_C:C^2\to C^3).
\]

Thus rank measured in the latter quotient is the genuine \(T^3\) rank for
columns already known to be global cocycles. Higher-degree choices do not
change their values on degree-three generators.

The proof of this lemma is **Proved**. The bare inference “degree-three Tate
generator, therefore a \(T^3\)-class” is **False**. The application to this
packet is **Repairable**, because the hypothesis that the 136 \(g_a\) are all
degree-three generators required in the low Tate stage has not been
independently certified under the pinned killCycles implementation.

## 9. Macaulay2 1.20 and package audit

### 9.1 Exact implementation audited

The replay pins:

- Macaulay2 1.20, build description
  version-1.20-6-a156a3cd4-dirty;
- launcher SHA-256
  a768799d25c404f5cd33ef445c37c7c83a28ca86b6d3124ac5a8d6997fe8dfbe;
- binary SHA-256
  c6f0c89e69d18334031c78217ddb6b383d5a729bde32aeb5f70ee2da0eec9b6c;
- VersalDeformations 3.0 source SHA-256
  3363126cce0237f2c3a7ab8a8438372c5adcf83a6fb5be1fb84e7cea9bd61c3a;
- DGAlgebras 1.1.0 source SHA-256
  72adff5eb889703562b7cedfce10c93490fda171f5f9dd90a998eb69b7d433b0.

The source comparison used the official Macaulay2
[release-1.20](https://github.com/Macaulay2/M2/releases/tag/release-1.20),
commit 940e8f4. The relevant source files are:

- [VersalDeformations.m2](https://github.com/Macaulay2/M2/blob/release-1.20/M2/Macaulay2/packages/VersalDeformations.m2),
  Git blob SHA-1 79def9977653211fe2a61c2ae6de9619c70df159;
- [DGAlgebras.m2](https://github.com/Macaulay2/M2/blob/release-1.20/M2/Macaulay2/packages/DGAlgebras.m2),
  Git blob SHA-1 def22eec09bbad6f9199ef418a9cba991e675fab.

The SHA-256 checks prove that the replayed executable and installed package
sources match the exact bytes recorded by the packet. The relevant routines
were separately compared with the official release-tag sources identified by
the Git blob SHA-1s above. Neither fact proves that a self-reported certificate
line has the stated mathematical interpretation, and the word “dirty” in the
build description means that the executable hash, not a generic 1.20 label, is
the actual reproducibility anchor.
These hashes do not inventory every dynamically linked library or transitive
runtime dependency, so they support exact replay on the tested installation
but are not by themselves a complete reconstruction recipe for the binary
environment.

### 9.2 VersalDeformations 3.0

In the exact release source:

- lines 104–140 implement CT^1 as the appropriate quotient of
  \(\operatorname{Hom}(I/I^2,A)\) by the Jacobian image;
- lines 144–164 implement CT^2 using first syzygies modulo Koszul syzygies and
  the relation-map image;
- lines 388–398 construct the first-order deformation;
- lines 419–433 reduce the supplied \(T^2\) representatives modulo
  relationAction, form NT2, and pair those columns with the base equations;
  this reduction changes representatives by the relation-map image while
  preserving their ordered quotient classes, and does not itself introduce an
  arbitrary \(\mathrm{GL}_{27}\) basis change;
- lines 446–475 perform the iterative finite-order lifting;
- HighestOrder is an upper bound for the order of that lift, not an
  all-orders assertion.

For HighestOrder=>3 the source sets ord=2 and performs the quadratic and cubic
steps. The branch which can certify exact termination requires its polynomial
check to find the newly produced terms identically zero. Here the cubic base
tuple is not asserted to vanish identically; only its exact evaluation at
\(y\) vanishes.

Ilten, *VersalDeformations — a package for computing versal deformations and
local Hilbert schemes*, Journal of Software for Algebra and Geometry 4 (2012),
12–16, documents package version 1.0 and has no numbered theorem, proposition,
or algorithm. It is a primary source for the algorithmic deformation equation,
not for the exact version 3.0 implementation; the pinned release source is the
authority for the latter. The accurate paper pinpoints are
[Section 1 and Section 2, especially equation
(1)](https://arxiv.org/pdf/1107.2416). The paper says that “CT may be used to
calculate bases of the first and second cotangent cohomology modules” and
describes the iterative equation

\[
 (F_iR_i)^{\mathsf T}+C_{i-2}G_{i-2}=0\pmod{\mathfrak m^{i+1}}.
\]

It also explicitly permits termination at a user-selected finite order.
The package statements are conditional on the selected \(T^1\) and \(T^2\)
being tangent and obstruction spaces.

| Package/script claim | Audit | Classification |
|---|---|---|
| CT^1(0,F0) returns a 53-element basis of \(T^1_0\) | Source formula and exact matrix dimensions agree | **Proved** |
| CT^2(0,F0) returns a 27-element basis of \(T^2_0\) | The one-row quotient-presentation hypothesis used by the release formula holds for this \(F\); direct cocycle, independence, and spanning checks also pass in degree zero | **Proved** |
| The CT^2 columns are canonical | They are chosen representatives and a chosen basis | **False** |
| The quadratic tuple has 27 minimal generators | mingens is checked over \(\mathbb Q\) | **Proved** |
| \(q(y)=0\), the reported cubic term vanishes at \(y\), and \(\operatorname{rank}Dq_y=15\) | Exact evaluation, differentiation, and rank assertions | **Proved** |
| The exported sixteen-row family two-jet has the recorded SHA-256 | Regenerated and hash-checked | **Proved** |
| HighestOrder=>3 performs the quadratic and cubic finite Massey lifts | The source sets ord=HighestOrder-1; exact output list lengths and residual evaluations are checked | **Proved** |
| HighestOrder=>3 proves an all-orders hull or arc | It terminates at the selected order | **False** |
| The ordered package \(G\)-coordinates are paired with NT2 | Exact source lines 419–433 and the script’s reproduction | **Proved** |
| The package name or call alone proves that the chosen modules are the required tangent and obstruction spaces | The documentation is conditional; the packet needs its separate CT/Tate comparisons | **Unsupported** |
| Ilten’s paper proves the derivation commutator, \(T^3\), Bianchi identity, or all-orders induction | Those subjects are absent | **Unsupported** |
| The finite package output is already proved to be the same completed classical graded hull as the intrinsic MC hull | No such comparison is supplied by the call or Ilten’s paper | **Repairable** |

### 9.3 DGAlgebras 1.1.0

In the exact release source:

- lines 91–118 construct the underlying graded-commutative free algebra with
  the specified generator degrees; the source itself notes that differential
  degree should be verified rather than certifying it there;
- lines 129–139 install generator differentials with setDiff;
- lines 238–260 implement killCycles;
- lines 263–276 adjoin generators with the selected cycles as differentials;
- lines 296–341 implement the graded-Leibniz polynomial differential used by
  the packet through the private polyDifferential interface.

Important implementation facts:

1. freeDGAlgebra and setDiff do not certify acyclicity. setDiff installs the
   supplied images; in this version it is not an
   independent semantic proof that \(d^2=0\). For the initial \(e_i\),
   \(d^2(e_i)=0\) is immediate because \(d(e_i)\in S\). Later stages still
   require the selected inputs to be cycles.
2. The version-1.20 killCycles source states a limitation to the case
   \(H_0(E)=k\): “For now this will only work” in that case. Here
   \(H_0(E)=S/I=A\), not \(\mathbb Q\). The calls do return concrete
   generators and differentials, but the routine selects cycles in one detected
   homological degree and does not certify full acyclicity. Its documentation
   cannot be cited as a theorem that the returned generators kill all required
   homology in this instance.
3. Version 1.1.0 has an EndDegree initialization defect. The packet supplies
   StartDegree only and leaves EndDegree at its default, so that particular
   defect is not triggered.
4. E.natural and polyDifferential are private/debug interfaces. The exact
   source hash makes their behavior reproducible for this binary; it gives no
   portability guarantee.
5. Applying the ring-map field E.diff directly to a product would not compute
   the graded-Leibniz differential. The packet does not make that error: it
   uses diff(E,z) and the package’s polyDifferential for products, and its
   custom derivation code implements the signed Leibniz formula.

| DG-algebra claim | Audit | Classification |
|---|---|---|
| The displayed finite \(E\) is semi-free with 16, 30, and 136 generators in the asserted degrees | Direct exact assertions | **Proved** |
| The 30 \(f\)-differentials give the complete first syzygy basis | relationMatrix equals packageRelationMatrix times an invertible constant matrix of determinant 1 | **Proved** |
| The 136 \(g\)-differentials kill all next-stage cycles | Relies on killCycles outside its stated \(H_0=k\) scope; no independent \(H_2\)-vanishing/spanning assertion | **Repairable** |
| “model=semi-free_commutative_DG_algebra_resolution” in the certificate proves acyclicity | It is a literal line written by the script, not a CAS test | **Unsupported** |
| The custom derivation formula has the correct signs | It matches the graded Leibniz rule; degree \((1,2)\) gives subtraction and degree \((1,1)\) gives addition as used | **Proved** |
| Closure equations for \(\theta\) and all 27 \(\eta_j\) through the displayed \(g_a\) | Every division is followed by an exact recomposition assertion | **Proved** |
| The 27 transported columns are closed, independent modulo \(\delta_1\), and span the degree-zero kernel quotient for the displayed complex | Lines 175–185 assert all three facts exactly | **Proved** |
| The commutator columns have rank 12 in the displayed \(C^3/\operatorname{im}\delta_2\) | Exact module computation | **Proved** |
| Those columns are genuine intrinsic \(T^3\)-classes | Global-extension proof is valid, but its complete-low-stage premise is not yet independently certified | **Repairable** |
| primaryMap + T2onF DqY is zero | Exact map equality in \(C^2/\operatorname{im}\delta_1\) | **Proved** |
| bracketMap DqY is zero and ranks are 12 and 15 | Exact map/rank assertions; the intrinsic interpretation remains conditional as above | **Proved** |

### 9.4 Incidence Gröbner computations

The incidence script works over exact \(\mathbb Q\), expands each element of
\(B[s]/(s^3)\) into three coefficient rows, and asks whether
\((0,0,1)^{\mathsf T}\) is in the module generated by 240 columns.
The version-1.20
[quotientRemainder documentation](https://macaulay2.com/doc/Macaulay2-1.20/share/doc/Macaulay2/Macaulay2Doc/html/_quotient__Remainder.html)
records the exact division identity \(gq+r=f\), while the
[% operator documentation](https://macaulay2.com/doc/Macaulay2-1.20/share/doc/Macaulay2/Macaulay2Doc/html/__pc.html)
identifies \(f\%g\) as remainder/normal form. A zero remainder therefore
gives an exact membership expression. The
[gb documentation](https://macaulay2.com/doc/Macaulay2-1.20/share/doc/Macaulay2/Macaulay2Doc/html/_gb.html)
says that DegreeLimit stops after the specified degree. That may make a nonzero
remainder inconclusive, but it does not make a zero remainder false: every
partial-basis column was produced from the input module. The driver correctly
retries nonzero results and checks one retained change-matrix identity in the
original columns.

Accordingly:

- each of the 280 reported zero remainders is an exact ideal/module membership:
  **Proved** by exact computation;
- the 277/3 split between degree limits 6 and 8 and the three exceptional
  pairs is **Proved** by exact computation;
- the claim that those 280 charts cover every possible singular generic point
  is not a Macaulay2 claim. It is the separate projective/Grassmannian
  properness argument in PROOF.tex 487–534, and is **Proved** assuming the
  rank criterion and the existence of the family;
- the DVR consequence \(s^2=s^3c\) is **Proved**, since any extension DVR has
  \(v(s)>0\), making \(2v(s)=3v(s)+v(c)\) impossible.

### 9.5 Downstream geometry, existence, and flatness

These arguments are not supplied by Macaulay2, but they depend on the
all-orders family whose foundations are under audit.

If a compatible flat graded formal deformation has been constructed, each
graded piece is finite free over \(R=\mathbb Q[[s]]\). Compatible lifts of the
special-fibre cubic basis give a basis of the degree-three formal ideal.
Nakayama gives no ideal terms below degree three and shows that the sixteen
cubics generate in every higher degree. This generator argument is
**Proved** under the stated formal-flatness premise; its application to the
packet is **Repairable** because that family has not yet been connected to the
printed two-jet.

For such a family, the projective rank criterion, specialization to the
special fibre, and the incidence enumeration reduce any hypothetical singular
geometric generic point to one of the 280 exact memberships. Reducing along an
extension DVR gives
\(s^2\in(s^3)\), hence \(s^2=s^3c\), contradicting the positive valuation of
\(s\). The coverage and valuation arguments are **Proved** assuming existence
of the family with that two-jet. Their present application is **Repairable**,
not because of the Gröbner computations, but because of the upstream
formal-hull bridge.

The [Stacks Project, Lemma 30.28.1 (Tag
0899)](https://stacks.math.columbia.edu/tag/0899) applies to a cartesian system
of closed subschemes
\(X_n\subset\mathbb P^7_{R/s^n}\): the base is complete noetherian, the
ambient morphism is projective, and the compatible coherent ideal sheaves are
the required formal data. The packet also has coefficientwise cubic series in
\(R[x_1,\ldots,x_8]\); full faithfulness identifies the effective formal
closed subscheme with the one cut out by those series.

Flatness is not automatic from algebraization, but the packet’s separate
argument is valid. At a special stalk \(B\), if \(sb=0\), flatness of
\(B/s^nB\) over \(R/s^n\) gives
\(b\in s^{n-1}B\) for every \(n\). Krull intersection gives \(b=0\).
Thus \(B\) is \(s\)-torsion-free and hence flat over the DVR; at generic
stalks \(s\) is invertible. Grothendieck existence and this flatness lemma are
**Proved** once the compatible flat formal family exists. Their use in the
current smoothing theorem remains **Repairable** because that upstream premise
has not been fully established.

## 10. Consolidated claim ledger

| Claim | Classification |
|---|---|
| The packet’s “André–Quillen bracket” / “AQ bracket” is evidenced established terminology | **Unsupported** |
| The chain operation actually computed is the graded commutator of derivations | **Proved** |
| A full cofibrant \(P\) gives \(H^p\operatorname{Der}(P,A)=T^p\) | **Proved** |
| The induced graded Lie operation is independent of the full cofibrant resolution up to dg-Lie quasi-isomorphism | **Proved** |
| Chosen chain representatives or matrices are resolution-independent | **False** |
| The operation is raw Yoneda multiplication on conormal Ext | **False** |
| The materialized finite DG algebra has the displayed generators and differentials | **Proved** |
| The 136 \(g_a\) are independently certified as the complete degree-three Tate stage | **Repairable** |
| A degree-three Tate generator automatically defines a \(T^3\)-class | **False** |
| The packet’s induction extends closed degree-one and degree-two derivations over all later \(n\ge4\) generators | **Proved**, once the low-stage premise holds |
| The resulting global commutators are genuine \(T^3\)-cocycles | **Proved**, once the low-stage premise holds |
| The 27 CT^2 columns form the degree-zero \(T^2\) basis in the displayed complex | **Proved** |
| The package obstruction coordinates are transported into the Tate basis by T2onF | **Proved** |
| \(U(0)=I\) | **Unsupported** |
| Omitting \(U(0)^{-1}\) in a general hull-coordinate comparison | **False** |
| The code constructs the package-to-cohomology map \(J\) and bracketMap \(=\operatorname{ad}_yJ\) | **Proved** |
| Identifying \(J\) with \(U(0)^{-1}\) for a completed hull comparison | **Repairable** |
| The primary commutator equals minus the transported \(Dq_y\) | **Proved** |
| \(\operatorname{rank}Dq_y=15\), displayed commutator rank 12, and their composite is zero | **Proved** |
| The intrinsic formula \(\ker(a_y:T^2\to T^3)=\operatorname{im}(b_y:T^1\to T^2)=\operatorname{im}(J D(q_G)_y)\) | **Repairable**, because the numerical proof is complete after the genuine-\(T^3\) premise, which still needs the low-stage certification |
| The ordinary unshifted Bianchi calculation and order induction are correct | **Proved** |
| HighestOrder=>3 supplies an all-orders family | **False** |
| The finite package jet and the intrinsic/classical graded MC hull are fully identified in the packet | **Repairable** |
| The all-orders continuation preserves the exact printed embedded two-jet | **Repairable** pending that identification |
| Ilten’s paper supports CT^1, CT^2, and the finite Massey lifting equation | **Proved** |
| Ilten’s paper supports the derivation commutator, \(T^3\), Bianchi, or the all-orders theorem | **Unsupported** |
| The 280 exact memberships hold | **Proved** |
| The 280 chart pairs are geometrically exhaustive, assuming the family and rank criterion | **Proved** |
| The valuation contradiction from \(s^2\in(F,J^{\mathsf T}K,s^3)\) is valid | **Proved** |
| Sixteen lifted cubics generate a compatible flat formal ideal | **Proved** under that explicit premise |
| Grothendieck existence applies to the compatible projective formal system | **Proved** under that explicit premise |
| The algebraized family is flat by the torsion/Krull-intersection argument | **Proved** under that explicit premise |
| The current packet has established the compatible formal family with the printed two-jet required by those three downstream steps | **Repairable** |
| The smoothing theorem is fully proved by the current packet | **Repairable**, not presently certified |

## 11. Required human-reviewed repairs before altering the packet

No change should be made merely by replacing one label with another. A
human-reviewed revision should, at minimum:

1. withdraw the unsupported terminology and give an explicit definition before
   choosing any literature-approved wording;
2. add the primary references and distinguish the strict derivation
   commutator, tangent/controlling dg Lie algebra, coderivation or convolution
   models, and the induced cohomology operation;
3. independently verify that the \(f\)- and \(g\)-differentials form the
   complete low Tate stages needed by the extension lemma, including an exact
   \(H_2\)-vanishing or equivalent spanning certificate not based solely on
   the out-of-scope killCycles promise;
4. prove the graded classical deformation-functor comparison and show that the
   exact order-three package family represents the corresponding MC object
   while preserving the printed embedded two-jet;
5. retain the full 27-column T2onF transport, define the resulting map \(J\),
   and identify it with \(U(0)^{-1}\) only after proving the completed-hull
   comparison; never assert \(U(0)=I\) without a separate proof;
6. state that only the quadratic curvature term is induced by the binary
   cohomology operation, while higher hull terms come from higher transferred
   \(L_\infty\) operations; and
7. keep the Macaulay2 finite-order facts separate from the theoretical
   all-orders conclusion.

Until those repairs have been reviewed by Sergei Burkin or another qualified
human expert, the original referee packet should not be amended or circulated
as a complete proof.
