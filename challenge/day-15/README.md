# Day 15 — Baseline Logistic-Regression & Gradient-Boosted Risk Models

**Phase:** ML & evaluation · **Time budget:** 10–12 h · **Skill focus:** statistics + ML, honest baselines
**Prereqs:** Day 14 feature store + PIT training dataset; Day 13 shortlist.

## Why this day matters

An interpretable baseline you can defend beats a fancy model you can't. Today you build two: a
logistic regression (odds ratios, CIs, diagnostics) and a gradient-boosted model, with a
**temporally honest** split, leakage guards, class-imbalance handling done right, and everything
tracked in MLflow. Day 16 is the rigorous evaluation; today is "train something correct".

## Challenges

### C1 — Training dataset & split design (~2.5 h)
- Assemble the modeling frame from the feature store: features as-of `t`, label = deterioration
  within the next 24 h, one row per patient per prediction time (decide the sampling cadence).
- Split **by time** (and by patient — no patient in both train and test). Hold out a final test
  period untouched until Day 16.
- Document prevalence, patient counts, and the censoring rule (patients discharged before the
  horizon).
- Acceptance: `docs/models/dataset.md` — split boundaries, prevalence per split, and a check
  that no patient_id crosses splits and no feature timestamp ≥ label time.

### C2 — Logistic regression baseline (~3 h)
- Fit with `statsmodels` for inference (coefficients, odds ratios, 95% CIs, p-values) and with
  `scikit-learn` in a pipeline for prediction.
- Handle: scaling, missing-indicator features, collinearity (from Day 13 VIF), class weights.
- Regression diagnostics: residual/deviance checks, Hosmer–Lemeshow or a calibration look,
  influential points.
- Acceptance: an odds-ratio table with CIs; a short clinical-plausibility read ("higher shock
  index → higher odds, OR 1.7 per SD"); model + params logged to MLflow.

### C3 — Gradient-boosted model (~3 h)
- Train XGBoost or LightGBM in the same pipeline/CV structure. Use `scale_pos_weight` /
  class weights; early stopping on a temporal validation fold.
- Time-series-aware CV (expanding window), not random k-fold.
- Feature importance (gain + permutation) and a couple of SHAP summary plots for interpretability.
- Acceptance: logged to MLflow with params, metrics, importance plots; CV scheme documented and
  justified.

### C4 — Imbalance, thresholds & a model card (~2 h)
- Compare handling strategies: class weights vs. threshold tuning vs. SMOTE (train folds only —
  never touch val/test). Report what each does to PR-AUC and calibration.
- Pick an operating threshold from a cost rationale (missed deterioration vs. alarm fatigue).
- Write `docs/models/model-card-v0.md`: intended use, data, features, metrics, limitations,
  "experimental decision support, not a diagnosis".
- Acceptance: model card committed; threshold choice has a written cost argument, not a default 0.5.

### Stretch (optional)
- A "vitals-only NEWS2" rule-based baseline to beat — if your ML can't beat NEWS2, say so.
- Nested CV for the boosted model's hyperparameters.

## Deliverables (branch `day-15-baseline-models`)

- `models/train/` pipelines (LR + GBM), `models/datasets/` builder
- MLflow runs (tracking dir committed or a `docs/models/mlflow-runs.md` export)
- `docs/models/dataset.md`, `model-card-v0.md`, CV-scheme note
- tests: no patient/time leakage across splits; SMOTE never applied outside train folds

## Definition of done

- [ ] Split is by time **and** patient; leakage tests pass; prevalence documented per split.
- [ ] LR gives odds ratios + CIs + diagnostics; GBM uses expanding-window CV + early stopping.
- [ ] Imbalance handled with a documented comparison; threshold chosen from a cost argument.
- [ ] Everything logged to MLflow; model card v0 committed.
- [ ] Final test period still untouched (opened Day 16).
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Prediction-time sampling: e.g. one row every hour per admitted patient; label = any
  deterioration event in `(t, t+24h]`; drop rows where the patient is censored before `t+24h`
  unless you handle it explicitly (survival does this properly on Day 17).
- `statsmodels` `Logit` / `GLM(family=Binomial())` for inference; `sklearn` `LogisticRegression`
  for the pipeline. OR = `exp(coef)`; CI = `exp(conf_int())`.
- Expanding-window CV: `sklearn.model_selection.TimeSeriesSplit`, but also make sure a patient
  doesn't straddle a fold boundary — you may need a custom splitter grouping by patient and
  ordering by time.
- `scale_pos_weight = n_neg / n_pos` for XGBoost as a starting point.
- SMOTE: fit it *inside* the CV loop on the training fold only (`imblearn.pipeline.Pipeline`
  handles this correctly; a plain sklearn Pipeline does not).
- Log to MLflow: `mlflow.sklearn.log_model`, `mlflow.log_params/metrics`, `mlflow.log_artifact`
  for plots. Set `MLFLOW_TRACKING_URI` to a local dir or the compose MLflow service.
