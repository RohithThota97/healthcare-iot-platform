# Day 17 — Survival Analysis (Kaplan–Meier, Cox) for Time-to-Deterioration + MLflow Registry

**Phase:** ML & evaluation · **Time budget:** 10–12 h · **Skill focus:** statistical methods (survival), model registry
**Prereqs:** Day 16 evaluation; Day 4 deterioration timeline + censoring.

## Why this day matters

"Deterioration in 24 h" throws away *when*. Survival analysis models time-to-event with censoring
(discharge, end of stay) handled correctly — the right framing for early-warning. You'll also
formalize model promotion in the MLflow registry with stages and gates, which is the MLOps half
of the question.

## Challenges

### C1 — Set up the survival dataset (~2 h)
- Per patient (or per encounter): `time` = hours from admission (or from a landmark time) to
  deterioration **or** censoring; `event` = 1 if deteriorated, 0 if censored; plus baseline and
  landmark covariates.
- Decide and document the time origin, the landmark (to avoid immortal-time bias), and the
  censoring rules.
- Acceptance: `docs/models/survival-dataset.md` — origin, landmark, censoring, event rate,
  median follow-up; a check that no event time is negative or post-censoring.

### C2 — Kaplan–Meier + log-rank (~2.5 h)
- KM survival curves overall and stratified (unit, age band, device model, a key vital
  above/below its Day 11 P75).
- Log-rank tests between strata; report median survival + CI where reached.
- Acceptance: KM plots with at-risk tables; log-rank statistics; a written reading of which
  strata separate.

### C3 — Cox proportional hazards (~3.5 h)
- Fit a Cox model with the Day 13 shortlist covariates; report hazard ratios + 95% CIs.
- Check the proportional-hazards assumption (Schoenfeld residuals); handle violations
  (stratification or a time-varying term).
- Optionally a time-varying-covariate Cox using windowed vitals (counting-process format).
- Evaluate: concordance index (Harrell's C), and time-dependent AUC if you can.
- Acceptance: HR table with PH-assumption results; C-index on a held-out period; violations
  addressed or explicitly acknowledged.

### C4 — MLflow model registry + promotion gates (~2.5 h)
- Register the best models (classification from Day 15/16 and the Cox model) in the MLflow
  Registry. Define stages (None → Staging → Production → Archived).
- Write `docs/models/promotion-policy.md`: the gates a model must pass to move to Staging
  (eval metrics + CIs, calibration, subgroup floor, no-leakage sign-off) and to Production
  (drift plan, rollback plan, clinical review placeholder).
- Implement a script that checks a run against the gates and transitions the stage (or refuses).
- Acceptance: a model gets promoted to Staging by the script only when it passes; a deliberately
  worse model is refused.

### Stretch (optional)
- Compare the Cox model's risk ranking to the classifier's on the same patients (rank
  correlation).
- Random Survival Forest or `scikit-survival` gradient boosting as a non-linear comparison.

## Deliverables (branch `day-17-survival-registry`)

- `models/survival/` (KM, log-rank, Cox, C-index), `models/registry/` promotion script
- `docs/models/survival-dataset.md`, `survival-results.md`, `promotion-policy.md`
- MLflow Registry entries with stages set via the gate script
- tests: no invalid event/censor times; promotion script refuses a failing model; seeded

## Definition of done

- [ ] Survival dataset documents time origin, landmark, censoring; validity checks pass.
- [ ] KM + log-rank across ≥ 3 stratifications with at-risk tables.
- [ ] Cox HRs + CIs; PH assumption checked via Schoenfeld and addressed; C-index on held-out data.
- [ ] Models registered in MLflow Registry; promotion gates written and enforced by a script.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- `lifelines`: `KaplanMeierFitter`, `logrank_test` / `multivariate_logrank_test`,
  `CoxPHFitter` (`.fit(df, 'time', 'event')`, `.print_summary()`, `.check_assumptions(df)`).
- Immortal-time bias: if a covariate is measured after the origin, use a landmark time (e.g.
  "6 h after admission") and only include patients still event-free at the landmark.
- Time-varying Cox needs long format: one row per patient per interval with `start`, `stop`,
  `event`, covariates in that interval — `CoxTimeVaryingFitter`.
- Schoenfeld: `cph.check_assumptions(df, show_plots=True)`; p < 0.05 per covariate = PH violated
  → stratify on it or add a `covariate * log(time)` term.
- Harrell's C ≈ AUC for survival; `concordance_index(time, -partial_hazard, event)`.
- MLflow Registry: `mlflow.register_model`, `MlflowClient().transition_model_version_stage`.
  Gate script reads metrics from the run, asserts thresholds, then transitions or raises.
