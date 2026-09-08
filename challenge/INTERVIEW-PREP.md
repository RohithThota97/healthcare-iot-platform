# Interview Prep — how the interview track works

You are building a portfolio project **and** rehearsing to talk about it. Data platform /
data engineering / ML platform interviews pull from five buckets. This challenge feeds all
five:

1. **Project deep-dive** — "walk me through what you built, and why." Your ADRs + `notes.md`
   are the raw material. Each day's `interview.md` ends with 1–2 "explain today's work" prompts.
2. **Technical fundamentals** — Kafka semantics, Spark internals, SQL windowing, distributed
   systems, statistics, ML evaluation. Each day's `interview.md` has 6–10 of these on that
   day's topic.
3. **System design** — "design a real-time patient monitoring platform." You're literally
   doing it; the cross-cutting bank below is the rehearsal.
4. **Real-world scenarios / debugging** — "consumer lag is climbing at 3 a.m., what do you
   do." Each day's `interview.md` has 2–4 scenario questions.
5. **Behavioral (STAR)** — ownership, trade-offs, incidents, disagreement. Build these from
   your daily logs.

## Daily habit (30–45 min, same day)

- Answer that day's `interview.md` **out loud**, then write a 3–5 sentence answer for the two
  hardest questions.
- Add one STAR bullet to `challenge/PROGRESS.md` from something that actually happened
  (a bug you chased, a design you changed, a trade-off you made).

## Mock interview checkpoints

### End of Day 10 — "Data platform fundamentals" mock (60 min)
- 10 min: project pitch (streaming + storage half only).
- 25 min: technical — Kafka delivery semantics, DLQ design, schema evolution, medallion
  modeling, PySpark shuffle/skew, SQL gaps-and-islands live.
- 20 min: system design — "ingest 50k vitals/sec from 10k devices, alert within 5 s."
- 5 min: your questions.
- Record yourself. Re-watch at 1.5x and note every "um, I think" — those are your weak spots.

### End of Day 20 — "Full platform + ML" mock (90 min)
- 15 min: end-to-end project walkthrough with the architecture diagram.
- 30 min: technical — statistical evaluation (AUC CIs, calibration, DeLong), drift detection
  (PSI/KS), survival analysis intuition, feature store online/offline skew, GraphRAG vs.
  vector-only RAG.
- 30 min: system design — extend the platform: multi-hospital, GDPR right-to-erasure,
  model rollback, on-call runbook.
- 15 min: behavioral — hardest bug, a decision you'd reverse, how you'd onboard someone.

## Cross-cutting system design question bank (rehearse across the 20 days)

- Design the ingestion path for 10k bedside devices, mixed HL7v2 / FHIR / proprietary,
  1 Hz numerics + 125 Hz ECG waveforms. Where do you split waveform vs. numeric storage?
- What are your Kafka topic, partition, and key choices? What breaks if you key by
  `device_id` vs. `patient_id`?
- Exactly-once vs. at-least-once for the alerting path vs. the analytics path — pick per path
  and defend it.
- A device sends a malformed payload every 200 ms for an hour. Walk the DLQ + replay +
  alerting behavior. How do you stop it poisoning the consumer group?
- Schema change: a vendor adds a field and changes `spo2` from int to float. What does your
  registry compatibility mode allow, and how do producers/consumers roll out?
- Design bronze/silver/gold for vitals. What's the grain of each table? What's idempotent
  about the silver build?
- A clinician says "the dashboard showed HR 40 but the patient was fine." Trace it from
  sensor to pixel. Where are the five places it could be wrong?
- Real-time inference needs the same features as nightly training. How do you guarantee no
  online/offline skew? What's your point-in-time correctness story?
- The deterioration model's PR-AUC drops from 0.71 to 0.58 over three weeks. Triage it:
  data drift, label drift, concept drift, pipeline bug — how do you tell them apart?
- GDPR erasure request for a patient whose data is in bronze Parquet, a Delta silver table,
  a feature store, a trained model, and a Neo4j graph. What's your plan for each?
- The alerting path must survive a Kafka broker loss with < 5 s added latency. Design it.
- Design the on-call runbook for "no vitals have landed in bronze for 10 minutes."

## Statistics / ML questions that recur

- Why report a confidence interval on AUC, and how do you compute one (bootstrap vs. DeLong)?
- A model is accurate but poorly calibrated. What does that mean clinically, and how do you fix it?
- PSI of 0.28 on a feature — is that drift? What do you check before retraining?
- You have repeated vitals per patient. Why is plain logistic regression's standard error wrong,
  and what do you use instead?
- Kaplan–Meier vs. logistic regression for "deterioration in 24 h" — when is each right?
- Precision-recall vs. ROC for a 3%-prevalence deterioration label — which do you optimize and why?

## Behavioral prompts to pre-write (STAR)

- A design decision you made under uncertainty and later validated (or reversed).
- The hardest bug in the 20 days — symptom, hypotheses, how you isolated it, the fix.
- A time you cut scope to hit a deadline — what you dropped and why it was safe.
- How you'd explain the drift-monitoring system to a non-technical clinical stakeholder.
