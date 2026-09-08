# Day 14 — Interview Questions

## Technical fundamentals

1. What is train/serve skew in a feature pipeline? Give a concrete way it happens and how a
   feature store prevents it.
2. What is a point-in-time-correct join, and what goes wrong without one? Walk through an entity
   spine + feature timestamps.
3. `ROWS BETWEEN` vs. `RANGE BETWEEN` for a rolling window on irregularly-sampled vitals — why
   does the choice matter and which is correct?
4. Offline store vs. online store in a feature store — different data, different latency,
   different consistency guarantees. How do you keep them in agreement?
5. How would you compute a rolling slope (trend) of HR over 1 hour in SQL? In Spark? Why might
   they disagree at the 1e-3 level and when is that a bug?
6. What's `feast materialize` doing, and what's the difference between full and incremental
   materialization?
7. Shock index (HR/SBP) is a cross-signal feature. What are the pitfalls of ratio features
   (division by near-zero, missing one signal, different cadences)?

## Real-world scenarios

8. Real-time inference reads a feature that's 20 minutes stale because materialization is
   behind. How do you detect this, and what should the model/serving layer do about it?
9. A feature that was great in training is useless in production. List the top four causes and
   how you'd distinguish them.
10. You need to add a new feature and backfill 90 days of history for retraining. Walk the plan
    so you don't corrupt the online store or leak future data.
11. Two teams define "mean HR last hour" slightly differently (bucket edges, null handling).
    How does a feature store stop this from becoming two silently different numbers?

## Explain what you built today

12. Show me your reconciliation report. Where did SQL and Spark disagree and why?
13. Prove to me your training dataset has no future leakage. What test asserts it?
