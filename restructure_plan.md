# SR project consolidation and conference-readiness plan

> **Archived planning document (August 2, 2026).** This predates the
> characteristic-zero smoothing proof now recorded in [`README.md`](README.md)
> and [`proofs/`](proofs/). Statements below that the problem is open, or that
> the degree-zero obstruction space has dimension 12, are obsolete. The exact
> value is \(\dim T^2_0=27\).

**Date:** August 2, 2026  
**Primary repository:** `github.com/danimalabares/sr-project`  
**Old private repository to retire:** local clone `~/github/daniel`, remote `github.com/sergunchik/daniel`  
**Immediate external goal:** prepare a clear, accurate, public-facing repository and poster request for the Bahia conference.

---

## 1. Current situation

The project currently lives across two
repositories.

### 1.1 `sr-project`

The public repository already contains most
of the central computational chain:

- the corrected facet list of the Grünbaum–Sreedharan sphere;
- the 16 cubic Stanley–Reisner generators;
- the 1664-coordinate embedded first-order deformation problem;
- the computation
  \[
  \dim \operatorname{Hom}_S(I,S/I)_0=109;
  \]
- the 56-dimensional space of coordinate-change directions;
- the quotient
  \[
  \dim T^1=109-56=53;
  \]
- a combinatorial computation reporting
  \[
  \dim T^2_{A_M,0}=12;
  \]
- a separate finite-field order-two calculation producing 27 independent raw candidate quadratic compatibility conditions;
- higher-order formal lifting experiments;
- exact flatness failures and torsion witnesses;
- frozen flat families under `serendipity/`;
- Gulliksen–Negård degeneration experiments;
- selected Lean certificates;
- the RL/search infrastructure.

The basic numerical story is internally
consistent. The main weakness is not that
the computations disagree, but that the
repository does not yet provide a single
transparent chain from the canonical facets
to every downstream coordinate system and
cached object.

### 1.2 `~/github/daniel`

Most central scripts were copied into
`sr-project`, but several important items
remain only in the old private repository:

1. `code/links/`, containing the bridge
   between the frozen coordinates \[
y_0,\ldots,y_{52} \] and the
Altmann–Christophersen basis pieces \[
t_1,\ldots,t_{53}; \]

2. the Sage generator for the committed Lean
   order-two certificate data;

3. `code/not-smooth/`, containing the exact
   finite chirotope/non-polytopality
computation and a detailed interpretation of
the torsion defect;

4. `code/new-cy3/`, containing the candidate
   census for other degree-20
codimension-four arithmetically Gorenstein
Calabi–Yau threefolds in \(\mathbf P^7\);

5. selected higher-order-lifting and
   Gulliksen–Negård logs that provide
provenance for results already quoted in the
new repository;

6. historical material explaining the
   wrong-polytope episode, the early Gröbner
strategy, and the ancestry of the current
syzygy computation.

The old repository also contains many
unrelated projects, private notes, generated
files, obsolete scaffolding, and duplicated
experiments. These should not be copied
wholesale.

### 1.3 Immediate mathematical documentation problem

The current public language must distinguish
carefully between two different
calculations:

- a combinatorial implementation reporting
  \[
  \dim T^2_{A_M,0}=12;
  \]

- a finite-field order-two computation producing 27 independent raw candidate quadratic compatibility conditions in the chosen 53 coordinates.

The code has not yet identified the 27-dimensional raw target with the canonical 12-dimensional obstruction space. Public documentation must not call the 27 rows “the obstruction equations” without qualification.

---

## 2. Canonical conventions

The repository should adopt one explicit permanent convention.

### 2.1 Vertices and variables

Use:

\[
M \text{ on vertices } \{1,\ldots,8\},
\qquad
S=k[x_1,\ldots,x_8].
\]

A face such as `2458` therefore corresponds directly to the monomial

\[
x_2x_4x_5x_8.
\]

Python may internally index lists by `0,…,7`, but every script must document the translation

```text
vertex v  <->  Python index v-1  <->  variable x_v.
```

Historical scripts using `x0,…,x7` must either be converted when migrated or carry a visible warning that `x_i` corresponds to vertex `i+1`.

### 2.2 Coordinate orderings that must be frozen

The following orderings are part of the mathematical data:

1. the order of the 20 facets;
2. the order of the 16 Stanley–Reisner generators;
3. the order of the 104 degree-three correction monomials;
4. the order of the 38 first syzygies;
5. the raw 1664 coordinates:
   ```text
   raw index = 104 * generator_index + correction_monomial_index;
   ```
6. the frozen basis \(y_0,\ldots,y_{52}\);
7. the permutation, up to units, from the frozen \(y\)-basis to the AC basis \(t_1,\ldots,t_{53}\);
8. the finite field used in each computation.

These conventions must be exported in human-readable, machine-readable files rather than being recoverable only from Sage pickles.

---

## 3. Desired final repository

The final repository should be organized by mathematical role, not by chronology.

```text
sr-project/
├── README.md
├── foundations/
│   ├── README.md
│   ├── M_FACETS.py
│   ├── verify_M.py
│   ├── part-1.sage
│   ├── part-1.pkl
│   ├── PROVENANCE.md
│   ├── coordinates/
│   │   ├── README.md
│   │   ├── facets.json
│   │   ├── sr_generators.json
│   │   ├── correction_monomials.json
│   │   ├── syzygies.json
│   │   ├── frozen_y_basis.json
│   │   ├── frozen_y_to_ac.json
│   │   └── build_ac_t1_basis.sage
│   └── nonpolytopality/
│       ├── README.md
│       ├── certificate scripts
│       └── human-readable reports
├── deformation-basics/
│   ├── README.md
│   ├── compute_T1_AC.py
│   ├── compute_T2_AC.py
│   ├── count_free_params_part1.sage
│   ├── count_T1_quotient_part1.sage
│   ├── order2/
│   │   ├── README.md
│   │   ├── source/
│   │   ├── data/
│   │   ├── reports/
│   │   └── verification/
│   ├── explicit-directions/
│   └── examples/
│       └── twisted-cubic/
├── higher-order-lifting/
│   ├── README.md
│   ├── experiments/
│   ├── flatness-failures/
│   ├── data/
│   └── reports/
├── gulliksen-negard/
│   ├── README.md
│   ├── PROOF.md
│   ├── source/
│   ├── data/
│   ├── archive/
│   └── candidate-census/
├── lean/
│   ├── README.md
│   ├── generators/
│   └── [single Lake project]
├── rl/
├── serendipity/
├── archive/
│   ├── README.md
│   ├── groebner-search/
│   ├── artin-criterion-precursors/
│   ├── failed-searches/
│   └── selected-logs/
└── journal.md
```

The exact subdirectory depth may be simplified during implementation. The important top-level boundaries are:

- `foundations/`;
- `deformation-basics/`;
- `higher-order-lifting/`;
- `gulliksen-negard/`;
- `lean/`;
- `rl/`;
- `serendipity/`;
- `archive/`.

---

## 4. Guiding principles

### 4.1 One source of truth

`M_FACETS.py` must be the canonical source of the simplicial complex.

- `verify_M.py` should import this file
 rather than duplicate the facet list.

- `part-1.sage` should derive the 16 minimal
 nonfaces from the canonical facets, or at
 least compare its ordered list against a
 list derived from them and fail loudly on
 disagreement.

- Lean, GN, serendipity, and RL should
 either import generated manifests or
 explicitly verify that their duplicated
 data match canonical hashes.

### 4.2 Preserve coordinates before regenerating anything

The present cached coordinate system is
already used by RL and by all named
directions \(y_{i}\). It must be frozen and
documented before any cache is regenerated.

The old-only `code/links/` material is
therefore the first migration priority.

### 4.3 Human-readable evidence beside opaque caches

Every committed `.pkl` or `.sobj` should
have a sidecar giving:

- producing script;
- command;
- Git commit;
- Sage, Python, Singular, Macaulay2, and platform versions as relevant;
- finite field;
- SHA-256 hashes of source inputs;
- dimensions and matrix hashes;
- portable exports of discrete data;
- a plain-language statement of what the artifact proves and does not prove.

### 4.4 Exact results, experiments, and conjectures must be separated

Public prose should label results as one of:

- mathematical proof;
- exact machine verification;
- finite-field computation;
- exact rational computation;
- numerical experiment;
- observed pattern;
- conjecture;
- failed attempt.

### 4.5 Do not combine relocation with mass renaming

The first restructuring pass should preserve
most filenames.

Move, repair paths, and verify first. Rename
scripts such as `part-1.sage` only in a
later commit once the migrated repository is
stable.

---

## 5. Work plan

## Phase 0 — Submit the Bahia poster request

This phase should happen before the full
repository renovation.

### Goal

Produce enough accurate public-facing
material to submit the poster request
without waiting for every historical file to
be reorganized.

### Immediate deliverables

1. A concise poster title.
2. A clear abstract stating:
   - the geometric problem;
   - the known first-order deformation dimension;
   - the current obstruction/lifting picture;
   - the existence of exact flat families found computationally;
   - the fact that the tested fibres are still singular;
   - the open smoothing problem.
3. A corrected root `README.md` status paragraph.
4. One stable public commit or tag containing the poster-facing state.
5. A short “Computational status” section distinguishing:
   \[
   \dim T^1=53,\qquad
   \dim T^2_{A_M,0}=12,
   \]
   from the 27 raw compatibility quadrics.

### Claims safe for the poster request

Subject to final wording review:

- The Stanley–Reisner scheme is a degree-20
 union of coordinate \(\mathbf P^3\)'s in
 \(\mathbf P^7\).

- Exact computations give
  \[
  \dim T^1=53.
  \]

- A combinatorial implementation reports
  \[
  \dim T^2_{A_M,0}=12.
  \]

- A separate finite-field order-two
 calculation produces 27 independent raw
 candidate quadratic compatibility
 conditions.

- Several formal directions have been lifted
 to high order.

- The naive high-order sparse continuation
 is not flat; exact torsion and saturation
 witnesses are known.

- Exact flat families have been found in the
 serendipity search.

- The tested nonzero fibres of the frozen
 families remain singular.

- It remains open whether the
 Stanley–Reisner scheme admits a smoothing
 to a smooth Calabi–Yau threefold.

### Claims not safe without further work

Do not say:

- that the 27 quadrics are a canonical basis
 of the obstruction space;

- that \(\dim T^2=27\);

- that the high-order sparse formal lift
 defines a flat family;

- that a smooth general fibre has been found;

- that every continuation of the sparse
 tangent direction must fail;

- that no Gulliksen–Negård matrix can ever
 degenerate to the SR ideal beyond the
 proved support hypotheses.

### Completion criterion

The poster request can be submitted once the
abstract and root status paragraph use the
safe claims above. Full repository
restructuring is not a prerequisite.

---

## Phase 1 — Rescue old-only material

No broad restructuring should happen before this phase is complete.

### 1.1 Migrate `code/links/`

Preserve selectively:

- `basis_T1_degree0.*`;
- `old_y_to_AC_basis.*`;
- `build_ac_t1_basis.sage`;
- the AC piece-decomposition report;
- the AC-coordinate translation of the 27 quadrics;
- the sparse flatness audit;
- the \(N=1,2,3\) Artin-flatness test;
- the torsion-witness autopsy;
- the partial universal-\(N=3\) calculation, clearly labelled inconclusive.

Recommended destinations:

```text
foundations/coordinates/
higher-order-lifting/flatness-failures/
archive/higher-order-lifting/
```

### 1.2 Migrate the missing Lean generator

Old path:

```text
~/github/daniel/code/cotangent/sr_t1/
08_export_order2_certificate_for_lean.sage
```

Destination:

```text
lean/generators/export_order2_certificate.sage
```

Verify that it regenerates the committed Lean data exactly or document any environment-dependent differences.

### 1.3 Migrate `code/not-smooth/`

Split it conceptually:

- chirotope/non-polytopality certificate:
  ```text
  foundations/nonpolytopality/
  ```

- sparse-branch torsion interpretation:
  ```text
  higher-order-lifting/flatness-failures/
  ```

The README must state the precise finite encoding and what geometric reduction is assumed.

### 1.4 Migrate `code/new-cy3/`

Place under:

```text
gulliksen-negard/candidate-census/
```

or another clearly labelled research-survey directory.

Review every citation and state explicitly that this is a literature/database census, not a classification theorem.

### 1.5 Preserve selected logs

Archive only logs that support claims still cited:

- order-12 and order-30 lifting summaries and selected full logs;
- quadratic-component and wall computations;
- torsion and saturation computations;
- search logs explaining the discovery of the \(y_8,y_{20}\) families;
- the exact GN invariants log.

Each archived log must have a provenance note.

### 1.6 Preserve the wrong-polytope history

Record:

```text
corrective commit:
37e1878285cff912f763a5389af828028b9b2c68
```

The note should explain that pre-correction data may correspond to a different entry in the Grünbaum–Sreedharan table and must not be mixed with current caches.

### 1.7 Select historical examples

Preserve only a curated subset:

- one twisted-cubic example showing a successful Gröbner degeneration;
- a short account of the failed early GN perfect-pairing search;
- selected syzygy-M precursor files or a manually written summary.

Do not migrate all toy scaffolding.

### Completion criterion

Every item marked “unique important material” in the old-repository audit either:

- exists in `sr-project`;
- has been summarized in a human-readable document;
- or has an explicit decision not to migrate.

---

## Phase 2 — Repair the foundation in place

Keep the current directory layout during this phase.

### 2.1 Canonicalize the combinatorial source

- Make `verify_M.py` import `M_FACETS.py`.
- Ensure `verify_M.py` derives:
  - vertex count;
  - facet count;
  - f-vector;
  - triangle incidences;
  - dual graph connectivity;
  - minimal nonfaces;
  - the ordered 16 SR generators.
- Remove accidental AI citation debris and fix the Grünbaum–Sreedharan name.

### 2.2 Canonicalize the SR ideal

Modify `part-1.sage` so that its generator list is derived from, or checked against, the canonical facets.

The script should fail if the ordered derived list differs from the frozen generator order used by existing caches.

### 2.3 Fix the 109/53 scripts

`count_free_params_part1.sage` computes the pre-quotient embedded Hom dimension and should expect 109, not 53.

`count_T1_quotient_part1.sage` should be the script establishing:

```text
dim Hom = 109
rank derivation image = 56
dim T1 = 53
```

### 2.4 Install the coordinate constitution

Create portable manifests recording:

- canonical facets;
- ordered SR generators;
- 104 correction monomials;
- 38 syzygies;
- 1664 raw coordinate labels;
- the frozen 53-dimensional basis;
- the \(y\)-to-AC dictionary;
- fields and software versions.

Add checks that compare these manifests against:

- `part-1.pkl`;
- `raw_obstruction_data.sobj`;
- RL’s reconstructed ordering;
- the explicit-direction scripts;
- serendipity provenance;
- Lean/GN duplicated exponent data where feasible.

### 2.5 Add provenance to foundational caches

For `part-1.pkl` and core order-two `.sobj` files, record:

- hashes;
- source commit;
- producing command;
- software versions;
- semantic dimensions;
- portable exports.

Do not require byte-identical pickle hashes across Sage versions. Verify semantic content.

### 2.6 Repair public claims

Update all READMEs so that they say:

> A combinatorial implementation reports
> \(\dim T^2_{A_M,0}=12\).
> A separate finite-field order-two calculation produces
> 27 independent raw candidate quadratic compatibility conditions.
> Their relation to the canonical 12-dimensional obstruction space has not yet been completed.

Also distinguish:

- formal lifting from flat family construction;
- exact flatness of frozen serendipity families from smoothness;
- exact GN certificates from numerical searches;
- finite-field results from rational results.

### Completion criterion

A clean clone can reconstruct the foundational data and verify the numerical invariants without referring to `~/github/daniel`.

---

## Phase 3 — Restructure the repository

Only begin once Phase 2 passes.

### 3.1 First move: preserve filenames

Move coherent groups into the target top-level directories while retaining existing filenames wherever possible.

Primary moves:

```text
old-code/cotangent foundational files
    -> foundations/ and deformation-basics/

old-code/cotangent/order2/
    -> deformation-basics/order2/
       and higher-order-lifting/

old-code/more-lifting/
    -> higher-order-lifting/

old-code/GN2/
    -> gulliksen-negard/
```

Keep:

```text
lean/
rl/
serendipity/
```

at top level.

### 3.2 Separate active code from history

Active directories should contain scripts that are part of the current computational narrative.

Historical or superseded scripts should move to:

```text
archive/
```

but exact negative results should remain easy to find and be linked from active READMEs.

A failed computation is not “garbage” when it establishes an important obstruction or rules out an approach.

### 3.3 Repair all paths

Use paths resolved from the script location or a shared repository-root helper.

Eliminate assumptions that scripts are launched from a special working directory.

Update:

- Sage `load(...)`;
- pickle and `.sobj` paths;
- Macaulay2 cache paths;
- README links;
- Lean links;
- RL tests;
- serendipity reconstruction scripts;
- GN cross-script imports.

### 3.4 Run migration verification

Required checks include:

```sh
python3 foundations/verify_M.py
sage foundations/part-1.sage
sage deformation-basics/count_free_params_part1.sage
sage deformation-basics/count_T1_quotient_part1.sage
python3 deformation-basics/compute_T1_AC.py
python3 deformation-basics/compute_T2_AC.py
sage deformation-basics/order2/[core build and verification scripts]
sage rl/sr_environment.sage
sage rl/tests/test_search_pipeline.sage
sage serendipity/verify_flatness.sage
sage serendipity/y8-y20-branch/verify_flatness.sage
sage serendipity/check_fibre_rescaling.sage
sage serendipity/test_nonzero_fibres.sage
python3 gulliksen-negard/10_obstruction_certificate.py
cd lean && lake build
```

The precise paths will depend on the approved final tree.

### Completion criterion

All active scripts run from a clean clone, all public links resolve, and no source path contains `old-code/cotangent` or `~/github/daniel`.

---

## Phase 4 — Make the repository human-readable

### 4.1 Root README

The root README should answer, in this order:

1. What is the geometric problem?
2. Why this sphere is interesting.
3. What is known.
4. What has been computed.
5. What remains open.
6. How the repository is organized.
7. How to reproduce the principal claims.
8. What software is required.

### 4.2 Required subproject READMEs

At minimum:

```text
foundations/README.md
foundations/coordinates/README.md
foundations/nonpolytopality/README.md
deformation-basics/README.md
deformation-basics/order2/README.md
higher-order-lifting/README.md
gulliksen-negard/README.md
lean/README.md
rl/README.md
rl/search/README.md
serendipity/README.md
archive/README.md
```

### 4.3 Human-readable result summaries

Create concise reports for:

- the canonical combinatorics;
- the 109/56/53 computation;
- the AC \(T^1\) decomposition;
- the \(T^2_{A_M,0}=12\) calculation;
- the 27 raw compatibility quadrics;
- the order-30 formal lift;
- the exact flatness failure and torsion witnesses;
- the frozen serendipity flat families and their singular fibres;
- the GN exact certificates and numerical evidence;
- the non-polytopality certificate;
- the candidate-CY3 census.

Each report must link to its generating scripts and data.

### 4.4 Clean public tone

Remove or rewrite:

- “ChatGPT says” and similar attribution;
- share links that are not necessary for reproducibility;
- accidental AI citation syntax;
- private correspondence;
- jokes and temporary emotional notes in active documentation;
- claims stronger than the scripts justify.

The private research journal should not be transferred wholesale. Only manually distilled mathematical chronology should appear publicly.

### Completion criterion

A mathematically literate visitor can understand the project’s goals, evidence, failures, and open questions without opening opaque serialized data.

---

## Phase 5 — Conference snapshot

### 5.1 Final public audit

Run:

```sh
git status --short
git diff --check
rg -n 'chatgpt\.com/share|contentReference|oaicite|/Users/|~/github/daniel|old-code/cotangent'
```

Also check:

- broken Markdown fences;
- stale links;
- missing files;
- inconsistent Grünbaum–Sreedharan spelling;
- `x0,…,x7` convention warnings;
- statements containing “proved,” “verified,” “flat,” or “smooth.”

### 5.2 Reproducibility record

Record:

- Git commit;
- software versions;
- principal commands;
- hashes of canonical inputs and caches;
- expected outputs.

### 5.3 Freeze the conference state

After all mandatory tests pass:

```sh
git tag -a bahia-2026 -m "Public snapshot for the Bahia conference"
git push origin main --follow-tags
```

A GitHub release may be created from the same tag if useful.

### Completion criterion

The repository is accurate, navigable, reproducible at the advertised level, and suitable to link from the Bahia poster submission.

---

## Phase 6 — Retire `~/github/daniel`

Before retirement:

1. confirm that no active `sr-project` file loads or references anything under `~/github/daniel`;
2. confirm that every unique important item has been migrated, summarized, or deliberately excluded;
3. record the old repository HEAD:
   ```text
   bb9f23e799e62c15bde4c3a19dadee053d87d4d7
   ```
4. record all local branches and tags;
5. create a private read-only Git bundle or equivalent archival safeguard;
6. keep private journals, unrelated projects, and personal material outside `sr-project`;
7. stop using the old clone for active SR work.

After this point, `github.com/danimalabares/sr-project` becomes the sole canonical active repository for the project.

---

## 6. Priority table

### P0 — Poster request

- draft poster title and abstract;
- correct the root public status language;
- state the 12/27 distinction accurately;
- submit the Bahia poster request.

### P1 — Prevent loss of unique work

- migrate `code/links/`;
- migrate the Lean generator;
- migrate `code/not-smooth/`;
- migrate `code/new-cy3/`;
- preserve selected logs;
- record the wrong-polytope correction.

### P2 — Repair foundations

- canonical facet import;
- derived/checked SR generators;
- fix 109 versus 53;
- freeze coordinate manifests;
- add provenance and hashes;
- audit all mathematical claims.

### P3 — Restructure

- move coherent projects;
- update paths;
- separate active work from archive;
- run the full test suite.

### P4 — Polish and freeze

- complete all READMEs;
- generate human-readable reports;
- run final hygiene checks;
- tag `bahia-2026`;
- retire the old repository.

---

## 7. Final acceptance criteria

The project is complete for this consolidation effort when all of the following are true:

- [ ] The Bahia poster request has been submitted with mathematically safe claims.
- [ ] `sr-project` contains every uniquely important SR item from `~/github/daniel`.
- [ ] The old repository is no longer needed to regenerate or interpret any active result.
- [ ] There is one canonical facet source.
- [ ] The ordered SR generators are derived from or checked against that source.
- [ ] The 109/56/53 computation is clearly documented.
- [ ] The \(T^2_{A_M,0}=12\) computation is not conflated with the 27 raw quadrics.
- [ ] The full frozen coordinate system is exported and documented.
- [ ] Every opaque cache has provenance and a human-readable companion.
- [ ] RL and serendipity preserve their historical coordinate labels.
- [ ] Lean certificate generators are present.
- [ ] Exact results, finite-field evidence, numerical searches, and conjectures are labelled separately.
- [ ] All active scripts run from a clean clone without special working-directory assumptions.
- [ ] Every active directory has a useful README.
- [ ] Private and unrelated material has not been transferred into the public repository.
- [ ] A conference snapshot has been tagged.
- [ ] A private archival safeguard of `~/github/daniel` exists.
- [ ] All future SR work takes place only in `github.com/danimalabares/sr-project`.

---

## 8. Immediate next action

The next working session should do exactly two things:

1. draft and submit the Bahia poster request using the safe current mathematical status;
2. begin the controlled migration of `code/links/`, because it contains the coordinate dictionary required to make the rest of the project intelligible.

Do not start the full directory move before these two tasks are complete.
