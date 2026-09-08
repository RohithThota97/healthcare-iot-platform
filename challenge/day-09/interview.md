# Day 9 — Interview Questions

## Technical fundamentals (SQL — expect to write these live)

1. Explain the medallion (bronze/silver/gold) pattern. What's the grain of each layer here, and
   what makes the silver build idempotent?
2. Write a query to deduplicate readings keeping the latest by `ingest_time` per natural key.
   Do it with `QUALIFY` and again without.
3. Gaps-and-islands: write a query that finds every period a patient's HR stream was stale
   (same value repeated ≥ 10 minutes).
4. Write a query for per-signal P1/P5/P50/P95/P99 by hospital unit. Which percentile function
   and why the `WITHIN GROUP`?
5. Rolling 15-minute mean and slope of HR per patient using window functions. How do you frame
   it by time vs. by row count, and why does the difference matter with irregular sampling?
6. Detect missing intervals: you expect a reading every 5 s. Write the calendar-spine + anti-join
   approach.
7. Referential integrity: write the anti-join that finds readings whose `device_id` isn't in
   `device_metadata`. How is `NOT IN` a trap here?
8. `LAG`/`LEAD` vs. a self-join for computing deltas between consecutive readings — which does
   the engine do better and why?

## Real-world scenarios

9. Your silver rebuild takes 40 minutes and blocks the morning dashboards. How do you make it
   incremental without losing idempotency?
10. `dq_checks` says completeness is 100% but the dashboard clearly has holes. What's the bug in
    the check?
11. A clinician disputes a P95 "normal range" your query produced. Walk through how you'd audit
    the number from silver back to raw.
12. The same profiling query runs in 1 s on DuckDB locally and 90 s on the real warehouse.
    What are the likely reasons and what do you check (pruning, clustering, stats)?

## Explain what you built today

13. Walk me through your `dq_checks` view. How does each sub-check map to a defect class you
    injected on Day 6, and what did the detection scorecard show?
14. Defend your partitioning choice for the silver vitals table given the queries in
    `analysis/sql/`.
