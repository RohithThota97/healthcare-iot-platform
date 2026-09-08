# Day 9 — Lakehouse Layers, Time-Series Tables & SQL Profiling Views

**Phase:** Streaming & storage · **Time budget:** 10–12 h · **Skill focus:** SQL, data modeling (medallion)
**Prereqs:** Day 8 merged; bronze is being populated by the consumer.

## Why this day matters

Bronze → silver → gold is the modeling spine, and SQL is the single most-tested skill in data
interviews. Today you define the grain and contract of each layer, build the silver transform,
and write a reusable library of profiling/DQ SQL: window functions, percentiles, gaps-and-islands,
time bucketing, anti-joins. You'll run these against silver every day after this.

## Challenges

### C1 — Layer contracts (~2 h)
- Write `docs/storage/medallion.md`: for bronze, silver, gold — the grain, the schema, what
  transformations are allowed, idempotency/rebuild story, partitioning, and retention.
- Bronze: raw, append-only, as-received. Silver: clean, conformed, deduped, one row per
  `(patient, signal, timestamp-at-canonical-cadence)` (long format). Gold: features, aggregates,
  labels (built Day 14+).
- Acceptance: each layer's grain is one sentence; silver's rebuild is provably idempotent.

### C2 — Build silver (~3 h)
- Transform bronze → silver: dedupe (`QUALIFY ROW_NUMBER() OVER (PARTITION BY natural_key ORDER
  BY ingest_time DESC)`), conform units/codes, drop hard-impossible values (flag, don't silently
  delete), leave gaps as gaps (resampling/interpolation is Day 10).
- Implement in SQL against your local warehouse (DuckDB/Postgres) reading the bronze Parquet/Delta.
- Acceptance: silver has no exact dupes on the natural key; every dropped/flagged row is
  attributable; re-running the build over the same bronze produces the same silver.

### C3 — The `dq_checks` view + profiling library (~4 h)
Build a reusable set of SQL views/queries over silver:
- **Completeness**: `COUNT(col)/COUNT(*)` per signal per day per unit.
- **Validity**: % passing range/consistency rules (systolic > diastolic, SpO2 ≤ 100).
- **Uniqueness/dupes**: exact + near-dupe counts.
- **Timeliness/staleness**: `now - max(event_time)`; gap distribution per stream.
- **Gaps-and-islands**: detect missing intervals and stale (frozen-value) runs — the
  `ROW_NUMBER()` difference trick or `LAG` vs. expected cadence.
- **Referential integrity**: anti-joins reading → patient / device / encounter.
- **Time bucketing**: `DATE_TRUNC` / `TIME_SLICE` + a generated calendar spine `LEFT JOIN`ed to
  expose holes.
- Roll them into one `dq_checks` view returning `check_name, grain, metric, passed, threshold`.
- Acceptance: run `dq_checks` against silver built from the Day 6 corrupted data; the results
  quantitatively match the injected defects (this is your detection scorecard).

### C4 — Percentiles & window-function reference queries (~2 h)
- Write and save example queries for: `PERCENTILE_CONT` reference ranges (P1/P5/P50/P95/P99) per
  signal per unit; rolling `AVG`/`STDDEV`/slope with `ROWS BETWEEN`; `LAG`/`LEAD` deltas;
  sessionization into encounters via a running sum over a "new session" flag; `PIVOT` device
  payloads.
- Acceptance: `analysis/sql/` holds runnable, commented queries; each has a one-line "what
  interview question this answers".

### Stretch (optional)
- Add `EXPLAIN` output notes and a partitioning/clustering discussion for the silver table.
- Materialize `dq_checks` results to a `data_quality_metrics` table with a run timestamp for
  trending (feeds Day 12/18).

## Deliverables (branch `day-09-lakehouse`)

- `docs/storage/medallion.md`
- `storage/silver/` build (SQL + a runner), `analysis/sql/dq_checks.sql`, `analysis/sql/*.sql`
- `docs/profiles/day09-detection-scorecard.md` — injected vs. detected
- tests: silver dedup invariant, idempotent rebuild, `dq_checks` runs green structurally

## Definition of done

- [ ] Each medallion layer has a one-sentence grain and a written contract.
- [ ] Silver build is idempotent and attributes every dropped/flagged row.
- [ ] `dq_checks` view covers completeness, validity, uniqueness, timeliness, gaps-and-islands, RI.
- [ ] Detection scorecard compares `dq_checks` output to Day 6 injected ground truth.
- [ ] `analysis/sql/` has commented window-function / percentile / sessionization examples.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- DuckDB reads Parquet/Delta directly (`SELECT * FROM 'bronze/**/*.parquet'` or
  `delta_scan(...)`) — no load step needed, great for this.
- Gaps-and-islands for stale sensors: `island_id = ROW_NUMBER() OVER (PARTITION BY patient,
  signal ORDER BY ts) - ROW_NUMBER() OVER (PARTITION BY patient, signal, value ORDER BY ts)`;
  long islands with constant `value` = frozen sensor.
- Missing-interval detection: generate a spine with `range()` / `generate_series` at the
  expected cadence, `LEFT JOIN` silver, `WHERE silver.ts IS NULL`.
- `QUALIFY` works in DuckDB and Snowflake; in Postgres use a subquery with the window filter.
- Keep the DQ rules in a table (`rule_name, signal, min, max, expr`) and drive the validity
  check from it, so Day 12's dbt/GE contracts can reuse the same rule set.
- "Idempotent rebuild" = `CREATE OR REPLACE TABLE silver AS SELECT ...` fully derived from
  bronze, no incremental state you can't reconstruct.
