# Day 12 — Sensor-Quality, Statistical Outlier & Drift Rules + dbt / Great Expectations Contracts

**Phase:** Statistics & data quality · **Time budget:** 10–12 h · **Skill focus:** statistics + SQL + tooling
**Prereqs:** Day 11 merged; EDA reference ranges + distribution verdicts exist.

## Why this day matters

Static range checks (`HR between 20 and 250`) are table stakes. Real DQ systems add *statistical*
checks — modified z-score, Hampel, PSI/KS drift vs. a baseline — and enforce them as **contracts**
in dbt/GE so promotion bronze→silver→gold is gated. Today you turn Day 11's findings into
executable, versioned data contracts and a drift monitor.

## Challenges

### C1 — Statistical outlier rules as a rule table (~2.5 h)
- Formalize the rules from the README's outlier section into a config-driven engine reading from a
  `dq_rules` table: physiological hard bounds, modified z-score (median + MAD), IQR/Tukey fences,
  rolling Hampel, cross-field consistency (systolic > diastolic, SpO2 ≤ 100).
- Each rule: id, signal, type, params, severity, action (flag / quarantine / reject).
- Acceptance: running the engine over Day 6 corrupted silver reproduces (or beats) the Day 10
  detection scorecard; results written to `data_quality_events` with `detected_by=rule_id`.

### C2 — Drift & statistical process control (~3.5 h)
- Establish a **baseline** distribution per feature (a clean training window).
- Implement drift metrics vs. baseline on a rolling window: PSI, KS statistic, Wasserstein,
  and JS divergence for binned/categorical; a chi-square drift test for categoricals.
- Add a control chart per device model (Shewhart X̄-R or a CUSUM/EWMA) for calibration drift —
  use the Day 4 device "quirks" as the thing you should catch.
- Acceptance: `analysis/drift/` produces a per-feature, per-window drift report; the report
  fires on the device with the injected calibration quirk and stays quiet on a clean slice.

### C3 — dbt models + tests for silver/gold (~3 h)
- Model at least the silver vitals table and a gold daily-summary as dbt models.
- Add tests: built-in (`not_null`, `unique`, `accepted_values`, `relationships`) **plus** custom
  generic tests for range/consistency/statistical checks (or `dbt-expectations` /
  `elementary`).
- Acceptance: `dbt build` runs; a deliberately bad row makes the right test fail; docs generated
  (`dbt docs`).

### C4 — Great Expectations (or Deequ) contract at the ingestion→ML boundary (~2 h)
- A GE suite (or PyDeequ) that the Day 8 consumer's bronze output must pass before silver
  promotion: schema, completeness thresholds, range validity, distribution stability (a PSI/KS
  expectation vs. baseline).
- Wire it so a failing contract blocks promotion and emits a metric/alert.
- Acceptance: run against clean bronze (passes) and Day 6 corrupted bronze (fails on the
  expected expectations); a `docs/data-quality/contracts.md` explains what each gate protects.

### Stretch (optional)
- Multiple-testing correction (Benjamini–Hochberg) across the per-signal/per-unit rule fires.
- Isolation Forest / LOF as a multivariate contextual anomaly check across vitals; compare its
  catches to the univariate rules.

## Deliverables (branch `day-12-dq-contracts`)

- `processing/dq/` rule engine + `dq_rules` seed
- `analysis/drift/` PSI/KS/CUSUM implementation + report
- `dbt/` project (models + tests + docs), `dq/great_expectations/` suite
- `docs/data-quality/contracts.md`, updated detection scorecard
- tests: rule engine vs. ground truth; drift fires on quirk device; contracts pass clean / fail corrupted

## Definition of done

- [ ] Outlier rules are config-driven and score ≥ Day 10 on the detection scorecard.
- [ ] Drift report computes PSI/KS/Wasserstein/JS + a control chart; catches the Day 4 quirk device.
- [ ] dbt project builds with built-in + custom statistical tests; docs generated.
- [ ] A GE/Deequ contract gates bronze→silver: passes clean, fails corrupted, blocks promotion.
- [ ] `contracts.md` maps each gate to the harm it prevents.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- PSI: bin the baseline (deciles), compute `Σ (actual% − expected%) · ln(actual%/expected%)`.
  Rule of thumb: < 0.1 stable, 0.1–0.25 moderate shift, > 0.25 significant. Note it's
  bin-count-sensitive.
- Modified z-score: `0.6745 · (x − median) / MAD`; flag `|.| > 3.5`.
- CUSUM: accumulate `S⁺ = max(0, S⁺ + (x − target) − k)`; alarm when `S⁺ > h`. Pick `k`, `h`
  from the shift size you care about.
- dbt custom generic test = a macro in `tests/generic/` returning failing rows; reuse your
  `dq_rules` table so SQL and dbt agree.
- GE: `ExpectColumnKlDivergenceToBeLessThan` / `expect_column_values_to_be_between` /
  `expect_table_row_count_to_be_between` cover most of this. A "partition object" is the baseline.
- Keep the *baseline* under version control (a committed Parquet/JSON of bin edges + freqs) so
  drift is reproducible.
