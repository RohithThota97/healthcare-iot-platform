# Day 4 — Synthetic Patient & Device Metadata Generation

**Phase:** Data · **Time budget:** 10–12 h · **Skill focus:** data collection, realistic simulation
**Prereqs:** Day 3 merged; dataset schemas exist.

## Why this day matters

Your whole platform will be judged on data that you generate. If the synthetic data has no
correlation structure, no missingness, no realistic cardinality, then every statistical result
on Day 11+ is a toy. Good synthetic data is a skill: you're encoding a generative model of how
hospitals, patients, and devices actually behave.

## Mission

Build a configurable, seeded generator for `patients`, `device_metadata`, and the encounter /
admission backbone of `clinical_events`. It must produce data that satisfies your Day 3 schemas,
has believable distributions, and has referential integrity you can test.

## Challenges

### C1 — Patient generator (~3 h)
- Generate `patients.csv`: demographics (age, sex, height, weight/BMI), admission unit
  (ICU / step-down / ward), comorbidity flags, admission and (optional) discharge timestamps.
- Distributions must be defensible: age skewed older for ICU, BMI roughly log-normal, unit mix
  realistic, a minority of patients still admitted (open encounters).
- Seeded and reproducible: same seed → identical output. Config-driven: `n_patients`, date
  window, unit mix all parameterized.
- Acceptance: passes the Day 3 `patients` schema; age/BMI distributions plotted and sane;
  re-running with the same seed produces a byte-identical file.

### C2 — Device metadata generator (~2.5 h)
- Generate `device_metadata.csv`: device_id, device_type (monitor model), firmware version,
  manufacturer, calibration_date, assigned_unit, sampling_rate_hz per signal.
- Encode real structure: 3–5 device models, each with its own firmware distribution and its own
  quirks (one model runs hot on temperature, one has a slow SpO2 sensor) — you'll use these on
  Day 12 for drift detection.
- Acceptance: passes schema; each model has a documented "quirk" in `docs/data-dictionary.md`
  or a `docs/synthetic-data-model.md`.

### C3 — Encounters & the deterioration process (~3 h)
- Generate the admission/encounter rows of `clinical_events.csv` and, crucially, decide **which
  patients deteriorate and when** — this is the latent label the whole ML half depends on.
- Model deterioration as a process: a hazard that depends on age, unit, and comorbidities;
  a deterioration event with a timestamp; downstream medication and (some) discharge events.
- Keep the generation logic for *vitals given deterioration state* documented but unimplemented
  today (that's Day 5).
- Acceptance: deterioration rate is a config parameter and comes out within tolerance;
  deteriorating patients skew older/sicker in a `groupby` check; every clinical event FKs to a
  real patient.

### C4 — Referential integrity & a data card (~2 h)
- Write `docs/synthetic-data-model.md`: the generative assumptions, the distributions and their
  parameters, the known limitations ("no seasonality", "device assignment is static").
- Write tests: every FK resolves, no patient discharged before admitted, no device calibrated in
  the future, unit mix within tolerance of config.
- Acceptance: `pytest tests/synthetic/` green; the data card is honest about what's fake.

### Stretch (optional)
- Compare your marginal distributions to a published ICU cohort table (e.g. MIMIC demographics)
  and note where you diverge and why.
- Add a `--scale` flag proven to generate 100k patients in reasonable time/memory.

## Deliverables (branch `day-04-synthetic-metadata`)

- `data/generators/` (patients, devices, encounters) — seeded, config-driven
- `data/processed/patients.csv`, `device_metadata.csv`, encounter rows of `clinical_events.csv`
  (or a `make gen-metadata` target that produces them; decide whether generated data is committed)
- `docs/synthetic-data-model.md`
- `tests/synthetic/`

## Definition of done

- [ ] Same seed → identical files; generator is config-driven, not hardcoded.
- [ ] All three datasets pass their Day 3 schemas.
- [ ] Deterioration is a modeled process with a tunable base rate and sane risk-factor skew.
- [ ] FK / temporal-order / range tests pass.
- [ ] `docs/synthetic-data-model.md` states the assumptions and limitations.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- `numpy.random.default_rng(seed)` and thread the generator through every function — no bare
  `np.random.*`, no `random` module, or reproducibility breaks.
- For correlated demographics, sample age first, then make BMI, comorbidity count, and unit
  conditional on it. A simple set of `if`/weights is fine; you don't need a copula.
- Hazard model that's enough: `p_deteriorate_per_hour = base * exp(b_age*age_z + b_unit + b_comorb*n)`;
  draw a time from the resulting exponential; censor at discharge.
- Decide the committed-vs-generated question explicitly: committing a small `data/sample/` set
  for tests + `.gitignore` for the full generated set is a common answer. Record it in an ADR.
- Keep `device_id → unit` and `patient → unit` consistent so vitals can join cleanly later.
