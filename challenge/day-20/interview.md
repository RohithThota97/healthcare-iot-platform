# Day 20 — Interview Questions

Today also has the **90-minute full mock** in [INTERVIEW-PREP.md](../INTERVIEW-PREP.md). These
are the integration/ops questions on top of that.

## Technical fundamentals

1. How do you keep PHI out of application logs while still having useful debug logs? What's your
   correlation-id strategy?
2. Why split orchestration into SLA tiers? What's different about the DAG design for a
   5-second-latency path vs. a nightly batch?
3. What makes an Airflow task idempotent and safely retryable? How does the logical/execution
   date help?
4. Sensors on Kafka lag and Delta freshness — what do they gate, and what's the risk of a sensor
   that waits forever?
5. What's the difference between `unit`, `integration`, and `e2e` tests here, and what should
   block a PR vs. run on a schedule?
6. Walk the full observability chain: metric emitted → scraped → stored → alerted → paged. Where
   can it silently break?
7. GDPR right-to-erasure across bronze/silver/feature-store/model/graph/vector-DB — what's the
   procedure for each, and which one can't truly comply and why?
8. Your API returns a risk score. What should it also return so the number is actionable and
   auditable?

## Real-world scenarios

9. It's demo day and the streaming path won't start. You have 10 minutes. What do you cut, and
   how do you still tell a credible story?
10. A clinician says the dashboard is "too noisy to use". How do you redesign what it surfaces
    without hiding real risk?
11. The nightly DAG missed its SLA three nights running. Walk your investigation and the fix.
12. Security review flags that the API key is checked but not rotated and is in an env file.
    How serious is it, and what's the remediation order?

## Explain the whole platform (rehearse for the mock)

13. Give me the 3-minute version of what you built: data in, alert out, and the two things you're
    proudest of.
14. Walk the architecture diagram end to end. At each hop: what can fail, how you'd know, and
    what happens to the data.
15. If you had 20 more days, what are the top three things you'd build or fix, and why those?
