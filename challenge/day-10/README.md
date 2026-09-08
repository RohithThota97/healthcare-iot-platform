# Day 10 — PySpark Preprocessing: Resampling, Interpolation, Dedup, Artifact Rejection

**Phase:** Streaming & storage · **Time budget:** 10–12 h · **Skill focus:** data transformation + cleaning at scale
**Prereqs:** Day 9 merged; silver (long-format, gaps intact) exists.

## Why this day matters

This is the big PySpark day. You take conformed-but-gappy silver and produce an analysis-ready,
fixed-cadence silver/silver+ table: resampled, interpolated where defensible, artifact-rejected,
with an audit trail of every change. Interviewers ask about shuffles, skew, window functions, and
"how do you know your cleaning didn't destroy the signal" — you'll have answers because you'll
measure it against the Day 6 ground truth.

## Challenges

### C1 — Spark job scaffold + read silver (~1.5 h)
- A parameterized PySpark job (local `master=local[*]`, but written so it could run on a cluster):
  config-driven input/output paths, a run id, structured logging.
- Read silver, repartition sensibly for the work (by `patient_id` or `(patient, signal)` so
  per-key windows don't shuffle repeatedly).
- Acceptance: `make spark-clean` runs end to end on the sample; the job prints an execution plan
  and a row-count-in/out summary.

### C2 — Resample & align to fixed cadence (~3 h)
- Resample each `(patient, signal)` to its canonical cadence (e.g. numerics to 1/min or 1/5s;
  waveforms handled separately). Aggregate within a bucket (mean/median + count + a
  "n_raw_in_bucket" column).
- Align all signals onto a common time grid per patient so downstream joins are trivial.
- Acceptance: output has exactly one row per `(patient, signal, bucket)`; buckets with no raw
  data are present and marked (not silently absent).

### C3 — Interpolation & imputation with flags (~3 h)
- Fill short gaps (≤ threshold) by forward-fill / linear / spline; leave long gaps null.
- Every filled value gets `imputed=true` and an `impute_method` column. Never overwrite a real
  value.
- Decide per signal: temperature LOCF is fine; SpO2 spline across a 20-min gap is not. Document
  the policy table.
- Acceptance: a query shows imputed vs. observed counts per signal; no gap longer than threshold
  is imputed; policy table in `docs/processing/imputation-policy.md`.

### C4 — Artifact rejection & the audit trail (~3 h)
- Implement rolling robust filters: Hampel (rolling median + MAD) for spikes, a variance/
  flatline detector for stuck sensors, physiological hard bounds, and a rate-of-change limit.
- Rejected points are flagged and (optionally) replaced by imputation, never dropped without a
  record.
- Write a `cleaning_audit` table: `patient, signal, bucket, action, reason, old_value, new_value`.
- Acceptance: compare `cleaning_audit` to the Day 6 `data_quality_events` — compute precision/
  recall of your artifact rejection per defect class. Put it in a scorecard.

### C5 — Skew & performance notes (~1 h)
- Identify the most skewed key (busiest patient / most-sampled signal), show its effect in the
  Spark UI, and apply one mitigation (salting, `repartition`, AQE). Write it up.
- Acceptance: `docs/processing/spark-performance.md` with before/after stage times and the
  mitigation rationale.

### Stretch (optional)
- Savitzky–Golay smoothing on a waveform-derived series, preserving peak shape; compare to a
  moving average.
- Make the job incremental (process only new buckets) while staying reproducible.

## Deliverables (branch `day-10-pyspark-clean`)

- `processing/clean/` PySpark job + config
- Cleaned fixed-cadence table under `storage/`, `cleaning_audit` table
- `docs/processing/imputation-policy.md`, `spark-performance.md`
- `docs/profiles/day10-cleaning-scorecard.md` — precision/recall vs. Day 6 ground truth
- tests: one row per (patient, signal, bucket); no over-threshold imputation; audit completeness

## Definition of done

- [ ] Fixed-cadence output, one row per (patient, signal, bucket), empty buckets marked.
- [ ] Imputation is flagged, method-tagged, policy-bounded, never destructive.
- [ ] Hampel + flatline + range + rate-of-change artifact rejection implemented with an audit trail.
- [ ] Cleaning scorecard: precision/recall of rejection per defect class vs. Day 6 truth.
- [ ] One documented skew mitigation with Spark UI evidence.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Resampling in Spark: bucket with `window(event_time, '60 seconds')` or
  `from_unixtime(floor(unix_timestamp(ts)/60)*60)`, then `groupBy(patient, signal, bucket)`.
- Per-key ordered operations (LOCF, Hampel) use `Window.partitionBy("patient","signal")
  .orderBy("bucket")` with a bounded `rowsBetween`. A `pandas_udf` (grouped map) is often
  cleaner for Hampel — one function per `(patient, signal)` group.
- Hampel: flag `|x - rolling_median| > n_sigmas * 1.4826 * rolling_MAD`.
- Don't `collect()` the dataset. Keep everything as DataFrame ops or grouped pandas UDFs.
- Skew tell: one task in a stage runs 20x longer. Fix with `spark.sql.adaptive.enabled=true` +
  `skewJoin`, or salt the hot key, or `repartition(n, "patient_id")` before the window.
- Score rejection like a classifier: a rejected point is a "positive"; match it to a Day 6
  event window to call it TP vs. FP.
