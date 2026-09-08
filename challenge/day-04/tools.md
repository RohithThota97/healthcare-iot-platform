# Day 4 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `numpy` (`default_rng`) | Seeded random sampling | One `rng` object threaded everywhere; no global state |
| `pandas` / `polars` | Assemble and write the tables | Column dtypes match the Day 3 schema (esp. datetimes as UTC) |
| `Faker` (optional) | Names, MRNs, addresses — **synthetic only** | Seed it (`Faker.seed()`); never generate anything that could collide with a real identifier format you care about |
| `SDV` / `ydata-synthetic` (optional, advanced) | Learn a joint distribution from a reference table | Heavy; only if you want to fit to MIMIC-style marginals. Not required. |
| `pandera` / your Day 3 validator | Validate generated output | `schema.validate(df)` in the generator itself, fail fast |
| `hypothesis` (optional) | Property-based tests for the generator | Good for "discharge always after admission" invariants |
| `matplotlib` | Sanity-plot the distributions | Save plots to `docs/img/synthetic/` for the data card |

### Config pattern

Put generation parameters in a `config/synthetic.yaml` (n_patients, date_window, unit_mix,
deterioration_base_rate, device_models[...]) and load it. Interviewers like "it's config-driven"
far more than "I changed a constant and re-ran".

### Traps

- `datetime.now()` anywhere in a generator kills reproducibility. Pass a "reference now" in config.
- Writing floats to CSV loses precision and dtype on reload. Prefer Parquet for generated data;
  keep CSV only for the small human-readable `data/sample/`.
- If you commit generated data, a re-run with a tweaked param creates a huge diff. Decide the
  commit policy (ADR) before you generate at scale.
