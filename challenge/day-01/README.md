# Day 1 — Requirements, Architecture & Technology Decisions

**Phase:** Foundations · **Time budget:** 10–12 h · **Skill focus:** system design, decision records
**Prereqs:** [SETUP.md](../SETUP.md) complete.

## Why this day matters

Every later day inherits the decisions you make today. Interviewers spend most of a system-design
round on *why* you chose something and *what you traded away*. If you can't defend a choice, it
doesn't belong in the design. Today you turn the parent README's prose into a decided,
constrained, diagrammed architecture with explicit non-goals.

## Mission

Produce a requirements doc, a set of Architecture Decision Records, a data-flow diagram you drew
(not copied), and a capacity model — enough that someone could start building tomorrow without
asking you a question.

## Challenges

### C1 — Requirements & non-goals (~2.5 h)
- Write `docs/requirements.md` covering: functional requirements, the two latency-critical paths
  (real-time alerting vs. batch analytics), data volume assumptions, consumers of the platform
  (clinicians, data scientists, ops), and compliance constraints (HIPAA/GDPR-style).
- Define **service level objectives** as numbers: alert end-to-end latency target, ingestion
  throughput, bronze freshness, dashboard query latency, model-refresh cadence.
- Write an explicit **non-goals** section. At least 6 things this platform will not do.
- Acceptance: every functional requirement has a measurable acceptance signal; no requirement
  uses the words "fast", "scalable", or "real-time" without a number attached.

### C2 — Capacity & data model sketch (~2 h)
- Build a back-of-envelope capacity model: N devices, numeric sample rates, ECG waveform rate,
  bytes/sample, → events/sec, MB/sec, GB/day for bronze, retention × size for each layer.
- Decide the **grain** of the core event and the core silver table. Write it down.
- Decide waveform vs. numeric storage split and justify with the numbers from above.
- Acceptance: a table of peak and average load, and a one-paragraph "what breaks first as we
  10x" answer.

### C3 — Architecture Decision Records (~3.5 h)
Write short ADRs (context → decision → alternatives → consequences) for at least:
- Streaming platform (Kafka vs. Redpanda vs. Pulsar) and why.
- Serialization + schema registry (Avro vs. Protobuf vs. JSON Schema) and compatibility mode.
- Storage: lakehouse table format (Delta vs. Iceberg vs. Hudi) and the local substitute.
- Stream processing engine (Kafka Streams vs. Flink vs. Spark Structured Streaming).
- Partitioning/keying strategy for the vitals topic.
- The local-vs-cloud substitution table (from SETUP.md) as a formal ADR.
- Acceptance: each ADR names at least 2 rejected alternatives with a real reason, not "less popular".

### C4 — Draw the data flow (~2 h)
- Redraw the end-to-end data flow as your own diagram (Mermaid in `docs/architecture.md`, or
  Excalidraw/draw.io exported to `docs/img/`). Mark on it: every latency-critical edge, every
  place data is validated, every place it's persisted, every async boundary (queue/DLQ).
- Add a second diagram: the failure view — what happens to an event that fails schema validation.
- Acceptance: the diagram distinguishes the alerting path from the analytics path visually, and
  a reader can point to where NEWS2 is computed and where drift is detected.

### Stretch (optional)
- Threat-model the PHI paths: where could an identifier leak, and what control stops it.
- Write the SLO error budget policy: what you stop shipping when the alert-latency budget burns.

## Deliverables (commit on branch `day-01-architecture`)

- `docs/requirements.md`
- `docs/architecture.md` (diagrams + narrative)
- `docs/capacity-model.md` (or a section in architecture.md)
- `docs/adr/0002-*.md` … at least 6 ADRs
- PR opened against `main` with a description that summarizes the key decisions

## Definition of done

- [ ] All SLOs are numeric.
- [ ] ≥ 6 ADRs, each with rejected alternatives.
- [ ] Capacity model gives GB/day for bronze and a "breaks first at 10x" answer.
- [ ] Two diagrams: happy path and failure path, alerting vs. analytics visually distinct.
- [ ] `docs/requirements.md` has a non-goals section with ≥ 6 items.
- [ ] Interview questions in `interview.md` answered in `notes.md`.

## Hints (open only if stuck)

- For the capacity model, start from: 10,000 devices × (6 numerics @ 1 Hz + 1 ECG @ 125 Hz).
  Assume ~40 bytes per numeric event and ~2 bytes per ECG sample before framing overhead.
- NEWS2 needs HR, RR, SpO2, temp, systolic BP, consciousness, and supplemental-O2 flag. That
  tells you the minimum event schema.
- Compatibility modes: `BACKWARD` lets new consumers read old data; `FORWARD` lets old consumers
  read new data; `FULL` is both. Pick based on who upgrades first.
- Keying by `patient_id` gives per-patient ordering (good for windowed scoring) but hot partitions
  for busy patients; keying by `device_id` spreads load but splits a patient across partitions.
- If drawing tools eat time, Mermaid `flowchart LR` in a fenced ```mermaid block renders on GitHub.
