# Day 16 — Statistical Model Evaluation: ROC/PR AUC + Bootstrap CI, Calibration, Subgroups

**Phase:** ML & evaluation · **Time budget:** 10–12 h · **Skill focus:** statistical methods (model evaluation)
**Prereqs:** Day 15 models in MLflow; the final test period still sealed.

## Why this day matters

"The model has 0.88 AUC" is not an evaluation. A real one has uncertainty intervals, a calibrated
probability check, a statistical model-vs-model comparison, subgroup fairness, and a decision-
curve view of clinical benefit. This is one of the highest-signal ML interview topics — you'll be
asked to compute a bootstrap AUC CI and explain calibration on the spot.

## Challenges

### C1 — Threshold-independent performance with uncertainty (~3 h)
- On the sealed test period: ROC curve + AUC, PR curve + AUPRC (lead with PR given rarity).
- Bootstrap CIs for AUC, AUPRC, sensitivity/specificity at the chosen threshold — resample
  **patients**, ≥ 2000 iterations, seeded.
- Acceptance: a metrics table with point estimate + 95% CI for every headline number; PR and ROC
  curves saved.

### C2 — Model comparison, done statistically (~2 h)
- Compare LR vs. GBM ROC AUCs with the **DeLong test** (paired, same test set); compare AUPRC
  via bootstrap difference CI.
- State whether the difference is statistically and *practically* meaningful.
- Acceptance: DeLong p-value + AUC difference CI reported; a one-line verdict on which model and
  why.

### C3 — Calibration (~3 h)
- Calibration curve (reliability diagram) with confidence bands, Brier score (+ its
  decomposition if you can), Hosmer–Lemeshow or Spiegelhalter's Z.
- If miscalibrated: refit with Platt scaling / isotonic regression on a calibration split and
  re-check. Report before/after.
- Acceptance: reliability diagram + Brier before/after; a plain-language statement of what the
  calibration means for a clinician acting on "42% risk".

### C4 — Subgroups, decision curve, and the evaluation report (~3 h)
- Metrics (AUC, AUPRC, calibration, sensitivity at threshold) sliced by age band, sex, unit,
  device model. Flag any subgroup where performance materially drops.
- Decision curve analysis: net benefit across threshold probabilities vs. "treat all" / "treat
  none".
- Acceptance: `docs/models/evaluation-v0.md` — the full story, with an explicit "is this good
  enough to pilot, and where would it fail" conclusion.

### Stretch (optional)
- Confidence intervals on the calibration slope/intercept.
- Error analysis: characterize the false negatives (which patients does it miss, and why).

## Deliverables (branch `day-16-model-eval`)

- `models/eval/` (bootstrap, DeLong, calibration, subgroup, DCA)
- `docs/models/evaluation-v0.md`, plots under `docs/img/models/`
- MLflow: evaluation metrics + artifacts attached to the Day 15 runs
- tests: bootstrap is seeded/deterministic; DeLong implementation checked against a known case

## Definition of done

- [ ] Every headline metric has a bootstrap 95% CI (patient-level resampling).
- [ ] LR vs. GBM compared with DeLong + an AUPRC difference CI, with a practical verdict.
- [ ] Calibration assessed (reliability + Brier + a test); recalibrated and re-checked if needed.
- [ ] Subgroup table across age/sex/unit/device with drops flagged; decision curve included.
- [ ] `evaluation-v0.md` ends with a clear pilot / no-pilot recommendation and its caveats.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Bootstrap AUC CI: for b in 1..B: sample patient ids with replacement, gather their rows,
  recompute AUC; CI = 2.5/97.5 percentiles. Resampling rows instead of patients underestimates
  the CI.
- DeLong: use a vetted implementation (`sklearn`-adjacent gists, the `delong` package, or port
  the Sun & Xu fast algorithm) and sanity-check it against a bootstrap difference CI.
- Calibration curve: `sklearn.calibration.calibration_curve` (choose `strategy='quantile'` for
  rare events); `CalibratedClassifierCV` for isotonic/Platt — fit on a *separate* calibration
  split, never the test set.
- Brier score = mean squared error of predicted probabilities; lower is better; decompose into
  reliability − resolution + uncertainty if you want the full picture.
- Decision curve: net benefit = `TP/n − FP/n · (p_t / (1 − p_t))` swept over threshold prob `p_t`.
- Subgroup analysis with small cells → wide CIs; report n per cell and don't over-interpret.
