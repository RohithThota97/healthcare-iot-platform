# Day 13 — Hypothesis Testing & Correlation: Deteriorating vs. Stable, Feature Screening

**Phase:** Statistics & data quality · **Time budget:** 10–12 h · **Skill focus:** statistical methods (confirmatory)
**Prereqs:** Day 11 EDA (distribution verdicts), Day 12 (clean gated data).

## Why this day matters

This is the confirmatory-statistics day and a heavy interview topic. You'll formally compare
deteriorating vs. stable patients, respect the fact that vitals are repeated measures within a
patient (so plain tests overstate significance), report effect sizes and CIs — not just p-values
— correct for multiple testing, and turn the results into a defensible feature shortlist for
Day 15.

## Challenges

### C1 — Frame the questions & pick the tests (~2 h)
- Write `docs/analysis/hypotheses.md`: a table of specific, pre-registered questions
  ("mean HR in the 6 h before deterioration vs. matched stable window", "RR variability differs
  by unit", "alarm counts differ by device model") each with H0/H1, the chosen test, and *why*
  that test (from Day 11's normality/variance verdicts).
- Decide the analysis unit: per-reading? per-patient-window? This determines independence.
- Acceptance: every question names a test, an effect-size measure, and the assumption checks it
  needs.

### C2 — Run the two-group and k-group comparisons (~3 h)
- Welch's t-test / Mann–Whitney for two groups; one-way ANOVA / Kruskal–Wallis + post-hoc
  (Tukey / Games–Howell / Dunn) for 3+.
- Paired tests (paired t / Wilcoxon signed-rank) for before-vs-after an intervention on the same
  patient.
- Chi-square / Fisher's exact for categorical associations (unit × deterioration, device × alarm).
- Report for **every** test: statistic, p, effect size (Cohen's d / rank-biserial / Cramér's V),
  and a CI (bootstrap where no closed form).
- Acceptance: a results table; no p-value reported without an effect size and CI beside it.

### C3 — Handle repeated measures & multiple testing (~3 h)
- Show the naive per-reading test is wrong: compare its p-value/CI to a correct approach — a
  mixed-effects model (random intercept per patient) or GEE, or per-patient summary then a
  between-patient test.
- Apply Benjamini–Hochberg FDR (and Bonferroni for contrast) across the full test family.
- Acceptance: a paragraph + numbers showing how much the "significance" shrinks when you account
  for within-patient correlation and multiplicity.

### C4 — Correlation & feature screening → shortlist (~3 h)
- Pearson/Spearman of candidate features vs. the label; point-biserial; mutual information for
  non-linear dependence; partial correlation controlling for age/unit.
- VIF pass to drop redundant features; a permutation-importance or univariate-AUC ranking.
- Output `docs/analysis/feature-shortlist.md`: ranked features, the evidence for each, and what
  you're excluding and why (leakage risk, collinearity, instability).
- Acceptance: the shortlist is defensible feature-by-feature and explicitly calls out any
  feature that could leak the outcome.

### Stretch (optional)
- Sensitivity analysis: do the conclusions hold under a different window length / matching
  scheme?
- Power analysis: given your effect sizes, what n would you need for 80% power — reframed as
  "how many patient-hours of data".

## Deliverables (branch `day-13-hypothesis-tests`)

- `analysis/stats/` scripts/notebooks (committed rendered)
- `docs/analysis/hypotheses.md`, `test-results.md`, `feature-shortlist.md`
- A `results` table artifact (`analysis/stats/results.csv`) with statistic/p/effect/CI/adjusted-p
- tests: the analysis is re-runnable and deterministic (seeded bootstrap)

## Definition of done

- [ ] Every hypothesis has a pre-registered test justified by Day 11 assumption checks.
- [ ] Every result reports effect size + CI, not just p.
- [ ] Repeated-measures correction shown numerically (mixed-effects/GEE or per-patient summary).
- [ ] BH-FDR (and Bonferroni) applied across the test family.
- [ ] Feature shortlist is ranked, evidence-backed, and flags leakage/collinearity.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Welch's t-test (`scipy.stats.ttest_ind(..., equal_var=False)`) is the safe default over
  Student's — don't gate on a normality test you already know fails at scale; use Mann–Whitney
  if clearly skewed/ordinal.
- Repeated measures the cheap way: collapse to one value per patient (e.g. mean HR in the window),
  then do a between-patient test. The rigorous way: `statsmodels` `MixedLM` with
  `groups=patient_id`, random intercept.
- Effect sizes: Cohen's d for t-tests, rank-biserial for Mann–Whitney, Cramér's V for chi-square,
  odds ratio for 2×2.
- Bootstrap CI: resample patients (not readings) with replacement, recompute the statistic 2–10k
  times, take percentiles. Seed it.
- Mutual information: `sklearn.feature_selection.mutual_info_classif` (discretizes internally).
- Leakage check: any feature computed using data at or after the label time is out. Be strict
  about the window cutoff.
