# Day 6 — Tools

No new services. This is Python data work plus your Day 3 schema validator.

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `numpy` (`default_rng`) | Seeded, reproducible corruption | one `rng`, threaded through every injector |
| `pandas` / `polars` | Apply defects, write corrupted Parquet + `data_quality_events.csv` | keep the clean dataset as a separate immutable artifact |
| Your Day 3 dataset validator (`pandera` / `jsonschema`) | Confirm `data_quality_events.csv` matches its schema | validate in the generator, fail fast |
| `fastavro` / `protobuf` | Corrupt the event replay file, emit genuinely undecodable bytes | keep an offset→reason manifest |
| DuckDB / `pandas` | The "how bad is it" baseline report | aggregate in SQL, don't eyeball |
| `pytest` | Assert injected totals == ground truth; clean set untouched | compare counts within a tolerance band |

### Config pattern

`config/defects.yaml`: one block per defect class with `rate`, class-specific params, and an
optional `per_device_model` override so you can tie defects to the Day 4 device "quirks".
Same config + seed → identical corrupted dataset and identical `data_quality_events.csv`.

### Traps

- If you corrupt in place you lose ground truth. Always: `clean → (corrupted, events)`.
- Order dependence is real: run dedup-generating duplicates *before* noise if you want the
  duplicates to be exact; document whatever you choose.
- Undecodable records for the DLQ must be truly undecodable (truncated bytes / wrong schema id),
  not just schema-invalid — those are two different downstream paths.
