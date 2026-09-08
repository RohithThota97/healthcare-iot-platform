# Day 1 — Interview Questions

Answer aloud first, then write 3–5 sentences for the two hardest in `notes.md`.

## Technical fundamentals

1. What is an SLI vs. an SLO vs. an SLA? Give one of each for a patient-alerting path.
2. Why separate the real-time alerting path from the batch analytics path physically instead of
   sharing infrastructure? What do you lose by separating them?
3. Avro vs. Protobuf vs. JSON Schema for event serialization — compare on schema evolution,
   payload size, tooling, and self-describing-ness.
4. Explain `BACKWARD`, `FORWARD`, and `FULL` schema compatibility. For a hospital where devices
   (producers) are upgraded on a slow vendor cycle but our consumers deploy weekly, which mode
   do you want and why?
5. What does "grain" mean for a table? What's the grain of a raw vitals event vs. a silver
   "vitals, 1-minute, per patient per signal" table?
6. Delta vs. Iceberg vs. Hudi at a conceptual level — what problem do all three solve that plain
   Parquet-on-S3 does not?
7. Why might you store 125 Hz ECG waveforms differently from 1 Hz numeric vitals? What are the
   query patterns for each?

## Real-world scenarios

8. A stakeholder says "we need real-time monitoring." Turn that into 4 measurable requirements
   with numbers you'd propose and then negotiate.
9. You estimate 3.2 GB/day for bronze at current scale. The hospital group wants to onboard 8
   more hospitals next quarter. Walk through what you check and what you'd change.
10. Leadership wants one platform that does both sub-second alerts and heavy ad-hoc analytical
    queries. Make the case for a design that serves both without one starving the other.
11. During design review, a senior engineer says "just use Kafka Streams, Flink is overkill."
    How do you resolve this — what evidence would settle it?

## Explain what you built today

12. Walk me through your architecture diagram in 3 minutes. Where is the alerting path, where is
    NEWS2 computed, where does data get validated, and where does it get persisted?
13. Pick your most contested ADR. What did you decide, what did you reject, and what would make
    you revisit it?
