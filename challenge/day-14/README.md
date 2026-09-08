# Day 14 — Rolling-Window Features (SQL + PySpark) & Feature Store Definitions

**Phase:** Statistics & data quality · **Time budget:** 10–12 h · **Skill focus:** SQL + transformation + feature engineering
**Prereqs:** Day 13 feature shortlist; Day 10 cleaned fixed-cadence table.

## Why this day matters

The feature layer is where online/offline skew and point-in-time correctness bugs live — and
interviewers love those. Today you build the gold feature table with rolling-window features
(both in SQL window functions and PySpark), define them in a feature store with matching
online/offline logic, and prove there's no leakage and no train/serve skew.

## Challenges

### C1 — Feature spec (~2 h)
- From the Day 13 shortlist, write `docs/features/feature-spec.md`: for each feature — name,
  definition, window, aggregation, source columns, expected type/range, the label it's used
  against, and the point-in-time rule (data strictly before `t`).
- Group into entities: `patient`, `patient x signal`, `device`.
- Acceptance: every feature has an unambiguous windowed definition and an explicit "as of time"
  semantics.

### C2 — Build features in SQL (~3 h)
- Implement the gold feature table with window functions: rolling mean/std/min/max/slope over
  multiple windows (e.g. 15 min / 1 h / 6 h), EWMA, deltas vs. baseline, time-since-last-reading,
  count of range violations in window, cross-signal ratios (shock index = HR/SBP).
- Use `ROWS`/`RANGE BETWEEN` correctly for time-based windows on irregular data.
- Acceptance: gold feature rows keyed by `(patient_id, feature_timestamp)`; a spot-check query
  recomputes one feature by hand and matches.

### C3 — Build the same features in PySpark + reconcile (~3 h)
- Reimplement the feature logic in PySpark (this is the "batch training" path).
- Reconcile SQL vs. Spark outputs — they must match within floating-point tolerance. Investigate
  any mismatch (frame semantics, null handling, ordering).
- Acceptance: a reconciliation report showing max abs diff per feature ≈ 0; differences explained.

### C4 — Feature store: offline + online + PIT correctness (~3 h)
- Define the features in a feature store (Feast with a local registry + Postgres online store,
  or a documented minimal equivalent). Offline store = your gold Parquet; online store =
  Postgres.
- Implement a point-in-time-correct **training dataset** join (`get_historical_features` with an
  entity+timestamp spine) and an **online** `get_online_features` path.
- Write a test that proves the online value for entity E at time T equals the offline value for
  (E, T) — i.e. no train/serve skew.
- Acceptance: PIT join produces no future leakage (a targeted test); online == offline for
  sampled (entity, time) pairs.

### Stretch (optional)
- Add a feature freshness/SLA check and a feature-level data-quality expectation (reuse Day 12).
- Backfill the online store from offline and measure the backfill time.

## Deliverables (branch `day-14-features`)

- `docs/features/feature-spec.md`
- `analysis/sql/features.sql` + `processing/features/` PySpark job
- `models/feature_store/` (Feast repo or equivalent) with offline+online defs
- `feature_store.csv` / gold feature table, reconciliation report
- tests: SQL↔Spark reconcile, PIT no-leakage, online==offline skew check

## Definition of done

- [ ] Every feature has a windowed definition + explicit as-of-time semantics + leakage rule.
- [ ] Features built in SQL and PySpark; outputs reconciled with differences explained.
- [ ] Feature store has offline + online definitions from one spec.
- [ ] A test proves point-in-time correctness (no future data) and online==offline (no skew).
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Time-based rolling window in SQL on irregular data: `RANGE BETWEEN INTERVAL '1 hour' PRECEDING
  AND CURRENT ROW` (DuckDB/Postgres support `RANGE` with interval on an ordered timestamp).
  Spark: `Window.orderBy(col("ts").cast("long")).rangeBetween(-3600, 0)`.
- Slope over a window = `REGR_SLOPE(value, epoch_seconds)` in SQL; in Spark compute via
  `covar_pop`/`var_pop` or a small pandas UDF.
- EWMA: SQL doesn't have it natively — recursive CTE or approximate with a fixed decay; pandas
  `ewm` in a Spark grouped UDF is simplest.
- Point-in-time join: the entity spine has `(patient_id, event_timestamp=label_time)`; features
  must be `feature_timestamp <= event_timestamp` and you take the latest — Feast does this, but
  understand it so you can defend it.
- The classic skew bug: offline uses `<= t`, online accidentally includes the current in-progress
  bucket. Make the cutoff identical in both code paths (share the function).
- Feast: `feast apply`, `feast materialize` to load the online store; entity + FeatureView +
  FileSource(offline) + a Postgres online store in `feature_store.yaml`.
