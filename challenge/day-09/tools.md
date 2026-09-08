# Day 9 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| DuckDB (CLI + Python) | Local warehouse; reads Parquet/Delta directly | `duckdb -c "select * from 'data/.../bronze/**/*.parquet' limit 5"` works; `INSTALL delta; LOAD delta;` for `delta_scan` |
| Postgres 16 (from compose) | Alternative warehouse if you want strict ANSI + concurrency | `psql` connects; `\timing on` for query cost feel |
| `sqlfluff` | Lint/format SQL | `sqlfluff lint analysis/sql/` in pre-commit; pick a dialect (`duckdb`/`postgres`) |
| A SQL notebook or client | Iterating on the profiling queries | DBeaver / VS Code / `harlequin` (DuckDB TUI) |
| `dbt-duckdb` or `dbt-postgres` (optional, preview for Day 12) | Model silver as dbt models | `dbt debug` passes; only if you want to start dbt early |

### Config checkpoints

- Decide the warehouse (DuckDB vs. Postgres) and record it in an ADR. DuckDB = zero-infra, reads
  files in place, great for this challenge. Postgres = closer to a real serving DB, concurrency.
- If DuckDB: `SET threads TO N;` and `SET memory_limit=...` if silver is large.
- Keep one SQL dialect for `analysis/sql/`; note where Snowflake syntax differs (the parent
  README targets Snowflake).

### Traps

- `PERCENTILE_CONT` is an ordered-set aggregate: `PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY
  value)` — syntax differs slightly across engines.
- `LAST_VALUE` needs an explicit frame (`ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED
  FOLLOWING`) or it returns the current row.
- Reading Delta from DuckDB needs the `delta` extension; plain Parquet doesn't.
- Don't `SELECT *` into pandas for profiling a large silver table — push the aggregation into SQL.
