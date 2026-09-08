# Day 5 — Synthetic Real-Time Sensor Readings + PhysioNet BIDMC Load

**Phase:** Data · **Time budget:** 10–12 h · **Skill focus:** time-series simulation, signal data handling
**Prereqs:** Day 4 merged; patients, devices, encounters, and deterioration timeline exist.

## Why this day matters

This produces the time-series heart of the platform: `sensor_readings`. It has to look like real
vitals — circadian rhythm, physiological coupling between signals, per-patient baselines,
irregular sampling, and a clear signature when a patient deteriorates. You also fold in the real
BIDMC PPG/ECG waveforms you already have in `data/raw/bidmc_csv/` so the waveform path uses
genuine signal shapes.

## Challenges

### C1 — Per-patient vitals generator (~4 h)
- For each patient, generate `sensor_readings` for HR, SpO2, respiratory rate, temperature, and
  BP over their encounter, at each signal's configured cadence.
- Model must include: a per-patient baseline (drawn from demographics), circadian variation,
  short-term autocorrelation (a reading depends on the previous), physiological coupling
  (SpO2 drop → compensatory HR/RR rise), and measurement noise.
- Deterioration signature: when a patient enters the deteriorating state (Day 4 timeline),
  vitals drift toward NEWS2-abnormal over a realistic window — not an instant step.
- Acceptance: plot 3 stable and 3 deteriorating patients; a clinician-plausible reviewer could
  tell which is which; ACF of HR is non-trivial (readings are not iid).

### C2 — Integrate BIDMC waveforms (~2.5 h)
- Parse `data/raw/bidmc_csv/` (Signals = PPG/ECG/resp waveforms, Numerics = derived HR/SpO2/RR,
  Fix = fixed metadata, Breaths = annotations). Understand the format before writing code.
- Attach real waveform segments to a subset of your synthetic patients as the ECG/PPG frames
  your Day 3 schema defines. Keep timestamps coherent with that patient's encounter.
- Acceptance: a documented mapping from BIDMC subject → synthetic patient; waveform frames
  validate against the Day 3 schema; the derived numerics from BIDMC are consistent with the
  attached waveform.

### C3 — Emit in the event contract + a replayable stream file (~2 h)
- Serialize a slice of `sensor_readings` into your Day 3 **event** schema (Avro/Protobuf
  records), ordered by `event_time`, written to `data/processed/stream/` — this is what Day 8's
  producer will replay.
- Include the fields needed for lag metrics (`event_time`, and leave `ingest_time` for the
  producer to stamp).
- Acceptance: a small tool can read the file back, decode every record, and confirm monotonic
  `event_time` per `(patient_id, signal_code)`.

### C4 — Volume, partitioning, and a profile report (~2 h)
- Decide storage layout for `sensor_readings` (partition by date? by unit? by signal?) and write
  it as Parquet accordingly.
- Produce a first profiling report: row counts per signal, sampling-interval distribution,
  value ranges vs. physiological bounds, per-patient coverage, waveform vs. numeric byte split.
- Acceptance: `docs/profiles/day05-sensor-readings.md` (or a notebook export) with the numbers;
  they match your Day 1 capacity model within an order of magnitude (explain if not).

### Stretch (optional)
- Add a `--realtime` mode that emits events at wall-clock cadence (sleep between events) for a
  live demo later.
- Use `scipy.signal` to verify HR extracted from a BIDMC PPG segment via FFT matches the
  Numerics file — a preview of Day 11's spectral work.

## Deliverables (branch `day-05-vitals`)

- `data/generators/vitals.py` (+ waveform loader)
- `data/processed/sensor_readings.parquet` (or `make gen-vitals`)
- `data/processed/stream/*.avro` (or `.pb`) replay file
- `docs/profiles/day05-sensor-readings.md`
- `docs/synthetic-data-model.md` updated with the vitals + deterioration signal model
- tests: schema validation, monotonic time, physiological-range coverage

## Definition of done

- [ ] Vitals show baseline + circadian + autocorrelation + cross-signal coupling, all documented.
- [ ] Deterioration produces a gradual, NEWS2-relevant drift, not a step change.
- [ ] Real BIDMC waveforms are attached to a documented subset and validate against the schema.
- [ ] A replay file of event-schema records exists and round-trips.
- [ ] Profiling report numbers reconcile with the Day 1 capacity model.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Cheapest realistic autocorrelation: an Ornstein–Uhlenbeck / AR(1) process around the
  circadian mean — `x[t] = mean[t] + phi*(x[t-1]-mean[t-1]) + noise`.
- Circadian: a sine with ~24 h period on HR/temp/BP; amplitude a few % of baseline.
- Coupling doesn't need to be physiologically exact: when SpO2 is pushed down, add a term to
  HR and RR means proportional to the SpO2 deficit.
- BIDMC `Signals` CSVs are ~125 Hz columns for PPG/ECG/resp; `Numerics` are 1 Hz HR/PULSE/RESP/SpO2.
  The `_Fix.txt` has age/gender. Read one file by hand first.
- Irregular sampling: don't emit on a perfect grid — jitter the interval and drop some readings
  (real dropout comes on Day 6, but a little jitter now is realistic).
- Keep the full generated Parquet out of git (`.gitignore`); commit a `data/sample/` slice.
