# Day 7 — Interview Questions

## Technical fundamentals

1. How does Kafka decide which partition a message goes to? What happens to ordering guarantees
   across partitions vs. within a partition?
2. You key vitals by `patient_id`. What ordering do you get, what do you give up, and what's the
   hot-partition risk?
3. Walk through `acks=0` / `1` / `all` and `min.insync.replicas`. Which combination can lose
   data, and which can block writes?
4. What is a consumer group rebalance, what triggers it, and how does it hurt a latency-sensitive
   consumer? How do you minimize it?
5. `cleanup.policy=delete` vs. `compact` — give a topic on this platform that wants each.
6. Explain at-least-once vs. exactly-once vs. "effectively once". How do you get effectively-once
   into a Delta/Parquet sink without Kafka transactions?
7. What's a poison message and how does a naive consumer get stuck on one forever? Design the way
   out.
8. What metadata do you attach to a dead-lettered message so that replay is actually possible?

## Real-world scenarios

9. 3 a.m. page: consumer lag on the alerting topic is climbing at 10k msg/min and not
   recovering. Walk your triage, top to bottom.
10. One device firmware bug emits a malformed payload every 200 ms. Your consumer group stalls.
    What do you do in the next 10 minutes, and what's the permanent fix?
11. You need to add partitions to a topic that's keyed by `patient_id` to handle more load.
    What breaks, and how do you do it safely?
12. A downstream consumer was down for 6 hours and now needs to catch up without falling further
    behind on live data. Options?
13. Product wants alert latency < 5 s even if a broker dies. What's your topic config, producer
    config, and consumer design?

## Explain what you built today

14. Walk me through your topic topology. Defend the partition count and key for the raw vitals
    topic and the waveform topic separately.
15. Demo your DLQ path: show a bad record going in with metadata and a fixed one being replayed.
    How do your counts reconcile with ground truth?
