# Day 18 — Risk-Prediction Output Datasets, Stream Feedback & PSI / Control-Chart Drift Monitors

**Phase:** ML & evaluation · **Time budget:** 10–12 h · **Skill focus:** statistics + streaming integration
**Prereqs:** Day 17 registered model; Day 12 drift primitives; Day 8 Kafka path.

## Why this day matters

A model that only lives in a notebook isn't a platform. Today you close the loop: batch-score to
produce `patient_risk_labels`, push scored risk back into Kafka as alerts, and stand up
**production** monitoring — input drift (PSI/KS), prediction drift, and performance decay with a
retrain trigger. This is the "MLOps in production" story interviewers want.

## Challenges

### C1 — Batch scoring → `patient_risk_labels` (~2.5 h)
- A scoring job that loads the Staging/Production model from MLflow, pulls PIT-correct features
  from the feature store, scores every admitted patient at the chosen cadence, and writes
  `patient_risk_labels.csv` (risk score, risk level, model version, feature snapshot ref,
  scored_at).
- Idempotent and re-runnable for a date range.
- Acceptance: schema-valid output; model version recorded per row; re-running a day overwrites,
  not duplicates.

### C2 — Streaming inference + alert feedback (~3 h)
- A consumer on the gold/feature stream that scores in near-real-time and produces to an
  `alerts` topic when risk crosses the threshold, with de-bounce (EWMA / N-of-M) so one noisy
  reading doesn't spam.
- Alert payload: patient, score, contributing features (top SHAP or coefficient terms), model
  version, timestamp. Route to the same DLQ discipline on failure.
- Acceptance: replay a deteriorating patient's stream → an alert fires within your latency
  budget, once, not 30 times; a stable patient produces none.

### C3 — Production drift & performance monitors (~3.5 h)
- **Input drift:** PSI/KS per feature, live window vs. the Day 12 training baseline, on a
  schedule; emit `healthcare_feature_drift_score` (per the observability doc).
- **Prediction drift:** distribution of scores over time (are we drifting toward always-high?).
- **Performance decay:** once labels mature (24 h later), compute rolling AUPRC / calibration
  and track vs. the Day 16 baseline; a CUSUM/EWMA chart on the metric.
- **Retrain trigger:** a documented rule combining drift + decay + data-quality, with
  hysteresis so it doesn't flap.
- Acceptance: `analysis/monitoring/` produces a drift+performance report; feed it the Day 6
  quirk-device slice and show the monitor firing; the retrain rule is written with thresholds.

### C4 — Wire alerts into observability (~2 h)
- Prometheus metrics for: scores served, alerts fired, alert latency, drift score, current
  AUPRC estimate, staleness of labels. Grafana panel. Prometheus alert rules extending
  `ops/alert-rules.yml`.
- Acceptance: metrics scrape; a Grafana dashboard screenshot; at least two new alert rules with
  sane thresholds and a comment explaining each.

### Stretch (optional)
- Online drift with `river` (ADWIN / Page-Hinkley) on the streaming path.
- A shadow-mode harness: score with a candidate model in parallel, compare, don't alert.

## Deliverables (branch `day-18-serving-monitoring`)

- `models/score/` batch job, `models/serve/` streaming consumer + `alerts` producer
- `analysis/monitoring/` (input/prediction/performance drift + retrain rule)
- `patient_risk_labels.csv`, updated `ops/alert-rules.yml`, Grafana dashboard JSON
- `docs/models/monitoring.md`, `docs/models/retrain-policy.md`
- tests: scoring idempotency, alert de-bounce (once per episode), monitor fires on quirk slice

## Definition of done

- [ ] Batch scoring writes schema-valid `patient_risk_labels` with model version, idempotently.
- [ ] Streaming inference fires a single de-bounced alert per deterioration episode within budget.
- [ ] Input drift, prediction drift, and (matured-label) performance decay are all monitored.
- [ ] A written retrain trigger with thresholds + hysteresis.
- [ ] New Prometheus metrics + ≥ 2 alert rules + a Grafana panel.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- De-bounce: alert when `EWMA(score) > threshold` for `M of the last N` windows, then suppress
  re-alerts for a cooldown unless score rises another delta. Tune on the Day 5 deteriorating
  patients.
- Performance monitoring has a label-latency problem: you can't score AUPRC until the 24 h
  horizon closes. Track a "pending labels" gauge and compute metrics on a lag.
- PSI baseline must be the *frozen training* distribution (Day 12 committed baseline), not
  last week's live data (that hides slow drift).
- Retrain rule with hysteresis: trigger if `PSI > 0.25` for 3 consecutive days OR `AUPRC` drops
  > X below baseline CI lower bound; clear only after 2 good days. Write it as a truth table.
- Alert payload explainability: for LR, `coef * (x - mean)` per feature ranked; for GBM, cached
  SHAP or `pred_contribs=True` (XGBoost).
- Reuse the Day 12 drift code — don't reimplement PSI/KS.
