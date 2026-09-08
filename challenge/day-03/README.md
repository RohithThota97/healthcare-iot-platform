# Day 3 — Event & Dataset Schemas + Data Dictionary

**Phase:** Data · **Time budget:** 10–12 h · **Skill focus:** data collection, contracts, schema design
**Prereqs:** Day 2 merged; broker + a schema registry (or Redpanda's built-in) reachable via `make up`.

## Why this day matters

The schema is the contract between everyone upstream and downstream of the bus. Get the grain,
the types, the nullability, and the evolution story right and the next 17 days are smooth. Get
them wrong and you're doing migrations on Day 12. Interviewers probe schema evolution hard
because it's where real production pain lives.

## Mission

Define versioned event schemas for multi-device vitals and HL7/FHIR-derived events, register
them, define the batch dataset schemas from the parent README, and write a data dictionary that
is the single source of truth for every field.

## Challenges

### C1 — Vitals event schema (~3 h)
- Design the canonical vitals event in Avro **or** Protobuf (decide from your Day 1 ADR).
  Cover: HR, SpO2, ECG waveform frame, BP (systolic/diastolic/MAP), temperature, respiratory
  rate. One schema with a typed union / oneof, or a small family of schemas — decide and justify.
- Every field: type, unit, nullability, allowed range (as doc, not enforcement yet), and a
  provenance field (device_id, firmware, ingest_time vs. event_time).
- Include the identifiers needed to join to patient / device / encounter later.
- Acceptance: the schema can represent a 1 Hz numeric reading **and** a 125 Hz ECG frame
  without wasted space; `event_time` and `ingest_time` are distinct; PHI fields are marked.

### C2 — HL7/FHIR-derived event contract (~2 h)
- Define the normalized event that a Kafka Connect / mapping layer will emit from an HL7v2
  `ORU^R01` observation or a FHIR `Observation` resource. It must land on the **same** downstream
  contract as C1 where possible.
- Document the field-by-field mapping (`OBX-3` → `signal_code`, `OBX-5` → `value`, LOINC codes,
  units) in `schemas/mappings/`.
- Acceptance: a sample HL7 message and a sample FHIR Observation both map to your canonical event
  with no information loss that matters clinically.

### C3 — Register schemas & prove evolution (~2 h)
- Register the schemas in the registry with an explicit compatibility mode.
- Write two follow-up versions: one **compatible** change (add an optional field) and one
  **breaking** change (retype `spo2`). Show the registry accepting the first and rejecting the
  second.
- Acceptance: a script or test that registers v1, evolves to v2, and asserts v3 is rejected
  under your chosen mode.

### C4 — Batch dataset schemas + data dictionary (~2.5 h)
- Formal schemas (JSON Schema / `pandera` / `dbt` yml — pick one) for every file in the parent
  README's dataset plan: `patients`, `sensor_readings`, `device_metadata`,
  `data_quality_events`, `clinical_events`, `patient_risk_labels`, `feature_store`.
- `docs/data-dictionary.md`: one row per field across all datasets — name, type, unit,
  nullable?, PK/FK, allowed values/range, PHI flag, description, source.
- Acceptance: every FK in the dictionary points at a named PK; every PHI field is flagged;
  the dictionary and the schema files agree (a test can check this).

### Stretch (optional)
- Generate language bindings from the schemas (`avrogen` / `protoc`) and commit them.
- Add a `schemas/CHANGELOG.md` and a rule: no schema PR merges without a changelog entry.

## Deliverables (branch `day-03-schemas`)

- `schemas/events/vitals-v1.avsc` (or `.proto`) + v2/v3 for the evolution demo
- `schemas/mappings/hl7-oru-r01.md`, `schemas/mappings/fhir-observation.md`
- `schemas/datasets/*.{json,yml,py}` for all 7 datasets
- `docs/data-dictionary.md`
- A registration script/test under `schemas/` or `tests/`

## Definition of done

- [ ] Vitals schema handles numeric + waveform, event vs. ingest time, PHI flags.
- [ ] HL7 and FHIR samples both map to the canonical contract, mapping documented.
- [ ] Registry accepts the compatible evolution and rejects the breaking one, proven by a test.
- [ ] Data dictionary covers all 7 datasets; FKs resolve; a test checks dictionary ↔ schema agreement.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- ECG frames: don't send one Kafka message per sample at 125 Hz. Send a frame — an array of N
  samples plus a start timestamp and sample rate. Decide N from your Day 1 latency budget.
- Avro unions with `null` first (`["null", "double"]`) is the idiomatic optional field.
- Keep `signal_code` an enum/string with a controlled vocabulary (map to LOINC) rather than
  separate columns per vital — it makes the silver table long-format and generalizes to new
  devices.
- For the evolution demo, the registry REST API is `POST /subjects/<subject>/versions` and
  `POST /compatibility/subjects/<subject>/versions/latest`.
- `event_time` = when the measurement happened on the device. `ingest_time` = when your platform
  received it. You need both for lag metrics and for point-in-time-correct features later.
