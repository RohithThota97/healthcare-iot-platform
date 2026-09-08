# Day 8 — Interview Questions

## Technical fundamentals

1. Walk the full path of one vitals reading from the device simulator to a row in bronze. Name
   every serialization/deserialization and every place it could be dropped.
2. What does the Confluent wire format look like on the wire (bytes), and why the schema id?
3. Why commit Kafka offsets *after* the sink write and not before? What failure does each order
   produce?
4. Your consumer must be idempotent because it will re-read messages. What's your dedup key and
   where does dedup happen — in the consumer, at write, or on read?
5. `enable.idempotence` on the producer — what exactly does it prevent, and what does it *not*?
6. Kafka Connect: what are converters, SMTs, and the dead-letter-queue settings, and how would
   an HL7 source connector use each?
7. You batch 500 records then write. How do you size the batch against `max.poll.interval.ms`,
   and what happens if the write hangs?

## Real-world scenarios

8. After a deploy, `healthcare_dlq_messages_total` jumps 20x. Walk your investigation. What
   dashboards and what messages do you look at first?
9. A hospital's HL7 feed uses local timezone with no offset and a non-standard `OBX-3` code set.
   How do you onboard it without special-casing your core consumer?
10. Bronze row count is 3% lower than events produced, but DLQ is empty. Where did the rows go?
11. You need to reprocess yesterday's bronze because a mapping bug mislabeled a signal. How do
    you replay without double-writing or disturbing today's live ingestion?
12. The consumer keeps rebalancing every few minutes under load. Diagnose and fix.

## Explain what you built today

13. Show me `make e2e`. What does it assert, and how do those assertions tie back to the Day 6
    ground-truth manifest?
14. How does an HL7 message and a FHIR Observation end up indistinguishable in bronze? Where's
    the canonicalization boundary?
