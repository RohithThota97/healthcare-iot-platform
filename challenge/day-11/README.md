# Day 11 — EDA: Descriptive Stats, Distribution & Normality Checks, Missingness Analysis

**Phase:** Statistics & data quality · **Time budget:** 10–12 h · **Skill focus:** statistical methods (exploratory)
**Prereqs:** Day 10 merged; cleaned fixed-cadence table + `cleaning_audit` exist.

## Why this day matters

Every model and every DQ threshold downstream should be grounded in what the data actually looks
like. Today you produce a rigorous EDA: not "here are some histograms" but a structured pass —
central tendency and spread per stratum, distribution shape with formal checks, and a missingness
analysis that decides whether dropping rows will bias your Day 15 model. This is heavily tested in
DS/ML interviews.

## Challenges

### C1 — Descriptive statistics by stratum (~2.5 h)
- For each vital: mean, median, SD, IQR, range, P1/P5/P50/P95/P99, skewness, kurtosis — broken
  down by unit, by device model, by patient deterioration status, and overall.
- Do the heavy aggregation in SQL/Spark; only pull the summary table into Python.
- Acceptance: `analysis/eda/descriptives.*` produces a tidy table (`signal, stratum, stat,
  value`) and a short written reading of it (which vitals are right-skewed, where spread differs
  by unit).

### C2 — Distribution shape & assumption checks (~3 h)
- Per vital (and per key stratum): histogram + KDE + ECDF, Q–Q plot, Shapiro–Wilk (or
  Anderson–Darling for larger n), and a candidate parametric fit (normal / log-normal / etc.)
  with a goodness-of-fit statistic.
- Levene's/Bartlett's test for equal variance across units (you'll need this for Day 13's tests).
- Acceptance: a `docs/analysis/distributions.md` table: per signal, is it plausibly normal?
  log-normal? what does that imply for which Day 13 test you'll use?

### C3 — Missingness analysis (~3.5 h)
- Missingness rate per column, per patient, per time bucket, per unit, per device model.
- Missingness co-occurrence: a correlation heatmap of missing-indicators (does SpO2 drop out
  when HR does? = device dropout).
- Reason about MCAR / MAR / MNAR for each signal; run Little's MCAR test where feasible; state
  the consequence: is complete-case analysis biased for the Day 15 label?
- Acceptance: `docs/analysis/missingness.md` with the maps and an explicit MCAR/MAR/MNAR call
  per signal and a recommended handling (already partly done Day 10 — reconcile).

### C4 — Correlation structure & first feature view (~2 h)
- Pearson + Spearman correlation matrix across vitals (contemporaneous and at a few lags).
- Point-biserial correlation of each vital vs. the deterioration label.
- Flag multicollinearity (VIF) among candidate features.
- Acceptance: a clustermap + a ranked "vitals most associated with deterioration" table, with a
  note on linear vs. monotonic (Pearson vs. Spearman) disagreements.

### Stretch (optional)
- Repeat the key distributions on the *pre-clean* vs. *post-clean* data to show what Day 10
  changed.
- Per-patient random-intercept view: how much of HR variance is between-patient vs. within
  (a preview of Day 13's mixed-effects argument).

## Deliverables (branch `day-11-eda`)

- `analysis/eda/` notebooks or scripts (exported to `.md`/`.html`, committed)
- `docs/analysis/descriptives.md`, `distributions.md`, `missingness.md`, `correlation.md`
- `docs/img/eda/` plots
- A one-page `docs/analysis/eda-summary.md` with the decisions EDA drove

## Definition of done

- [ ] Descriptives are stratified (unit / device / outcome), not just global.
- [ ] Every vital has a distribution-shape verdict backed by a plot **and** a test.
- [ ] Missingness has an MCAR/MAR/MNAR call per signal and a bias assessment for the label.
- [ ] Correlation analysis distinguishes linear vs. monotonic and flags multicollinearity.
- [ ] `eda-summary.md` lists concrete downstream decisions (which tests, which features, which
      imputation).
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Shapiro–Wilk loses meaning above n≈5000 (rejects everything). Subsample, or switch to
  Anderson–Darling + a Q–Q plot judgment. Interviewers like that you know this.
- Skew sign: HR, RR, and length-of-stay are typically right-skewed; log-transform before a
  normal fit.
- Missingness heatmap: build an indicator matrix (`df.isna().astype(int)`), then `corr()` on it;
  `missingno.matrix` / `heatmap` visualizes it fast.
- Little's MCAR test is in `statsmodels`-adjacent packages (`pyampute`, or implement the
  chi-square version). If it's a rabbit hole, reason it through qualitatively and say so.
- Point-biserial = Pearson with one binary variable; `scipy.stats.pointbiserialr`.
- VIF: `statsmodels.stats.outliers_influence.variance_inflation_factor`; VIF > 5–10 = worry.
