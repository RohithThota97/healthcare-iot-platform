# Day 6 — Inject Missing, Duplicate, Noisy, Stale & Out-of-Range Data

**Phase:** Data · **Time budget:** 10–12 h · **Skill focus:** data cleaning (by first creating the mess), DQ taxonomy
**Prereqs:** Day 5 merged; clean `sensor_readings` + replay stream exist.

## Why this day matters

Clean synthetic data means every "data quality" and "drift" feature you build later is untested.
Today you deliberately corrupt a **copy** of the data with realistic, *labeled* defects, and you
record ground truth in `data_quality_events.csv`. On Day 10 and 12 you'll measure how well your
cleaning and contracts catch what you injected — you can only do that if you know what you put in.

## Challenges

### C1 — Design the defect taxonomy & injection config (~2 h)
- Enumerate the defect classes with realistic causes: device dropout (missing runs), duplicate
  delivery (at-least-once), sensor noise bursts (motion artifact), stale/frozen sensor (same
  value repeated), clock skew (out-of-order / future timestamps), out-of-physiological-range
  spikes, unit errors (whole-series scale shift), flatline disconnection.
- Put injection rates and parameters in `config/defects.yaml`, per defect class, optionally
  per device model (tie to the Day 4 "quirks").
- Acceptance: a written taxonomy in `docs/data-quality-taxonomy.md` mapping each class to its
  real-world cause, its detection method later, and its expected downstream harm.

### C2 — Injectors that preserve ground truth (~4 h)
- Implement each injector as a function `df -> (df_corrupted, events)` where `events` rows go into
  `data_quality_events.csv` (Day 3 schema): defect_id, patient_id, device_id, signal_code,
  start_time, end_time, defect_class, params, affected_row_count.
- Compose them via the config into one corrupted dataset. Order matters (dedupe-then-noise ≠
  noise-then-dedupe) — decide and document.
- Keep the clean dataset intact and separate; corrupted is a new artifact.
- Acceptance: for every corrupted row you can point to the `data_quality_events` row that
  explains it; total injected ≈ config within tolerance.

### C3 — Corrupt the replay stream too (~2 h)
- Apply the delivery-layer defects (duplicates, out-of-order, malformed payloads) to a copy of
  the Day 5 event replay file, so Day 7–8's DLQ and dedup logic has something to catch.
- Include a few genuinely un-decodable records (truncated bytes, wrong schema id) for the DLQ.
- Acceptance: the corrupted stream file has a manifest of exactly which offsets are bad and why.

### C4 — Baseline "how bad is it" report (~2 h)
- Before you build any cleaning, quantify the damage with simple SQL/pandas: completeness per
  signal, duplicate rate, % out of range, staleness gap distribution, out-of-order rate.
- Acceptance: `docs/profiles/day06-injected-dq.md` — a table comparing clean vs. corrupted, and
  a short "which defects will be hardest to detect and why".

### Stretch (optional)
- Add a `severity` and make some defects intentionally subtle (a 2% scale error) to test
  detection sensitivity later.
- Make injection itself seeded and reproducible so the corrupted dataset is regenerable.

## Deliverables (branch `day-06-inject-dq`)

- `data/generators/defects/` + `config/defects.yaml`
- `data/processed/sensor_readings_corrupted.parquet`, `data_quality_events.csv`
- `data/processed/stream_corrupted/` + a bad-record manifest
- `docs/data-quality-taxonomy.md`, `docs/profiles/day06-injected-dq.md`
- tests: injected totals match ground truth; clean dataset untouched; every corrupted row is
  explained by an event row

## Definition of done

- [ ] ≥ 7 defect classes, each mapped to cause / detection / harm in the taxonomy doc.
- [ ] `data_quality_events.csv` is complete ground truth: every corruption is labeled.
- [ ] Clean and corrupted datasets both exist; injection is seeded/reproducible.
- [ ] Corrupted replay stream + manifest of bad offsets exists.
- [ ] Baseline damage report compares clean vs. corrupted numerically.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Stale sensor = carry one value forward for a random run length; the tell is zero variance over
  a window, not an out-of-range value.
- Unit error = multiply an entire patient-signal series by a constant (F vs C: `x*9/5+32`);
  individually every point looks plausible — that's the point.
- Out-of-order: shuffle a small fraction of events within a time window and/or subtract/add a
  random offset to `event_time` for a few.
- Duplicates: re-emit a fraction of events with a new `ingest_time` but identical natural key —
  Day 8's `QUALIFY ROW_NUMBER()` dedup should catch these.
- Keep the injector output deterministic: same `config/defects.yaml` + seed → identical corrupted
  file and identical `data_quality_events.csv`.
