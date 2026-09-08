# Day 10 — Interview Questions

## Technical fundamentals

1. What is a shuffle in Spark? Which operations cause one, and why is it the usual performance
   bottleneck?
2. Narrow vs. wide transformations — classify `map`, `filter`, `groupBy`, `repartition`, `join`,
   `window`.
3. What is data skew, how do you spot it in the Spark UI, and name three mitigations with their
   trade-offs.
4. `repartition` vs. `coalesce` vs. `partitionBy` on write — when each?
5. How do Spark window functions work under the hood, and why can an unbounded-frame window be
   dangerous on a hot key?
6. `pandas_udf` (vectorized/grouped) vs. a plain Python UDF vs. native Spark SQL — performance
   ordering and why.
7. What is Adaptive Query Execution and what three things does it change at runtime?
8. Forward-fill, linear interpolation, spline, KNN, MICE — for a 3-minute SpO2 gap vs. a
   30-minute temperature gap, which and why? What flag do you always add?
9. Explain the Hampel filter. Why median + MAD instead of mean + SD for vitals?

## Real-world scenarios

10. Your cleaning job's artifact rejection has 95% recall but 40% false-positive rate — it's
    deleting real bradycardia events. How do you tune it, and how do you prove the new version
    is safer?
11. The job runs in 4 min on sample data and 3 hours on a full day. Profile it in your head:
    what are the top three suspects?
12. A clinician says "your smoothing hid a real desaturation." How do you change the pipeline so
    smoothing informs but never destroys, and how do you audit past decisions?
13. You need this transform to run both as a nightly batch and (a lighter version) in the
    streaming path. What do you share and what has to differ?

## Explain what you built today

14. Walk me through your `cleaning_audit` table and the Day 10 scorecard. What's your artifact-
    rejection precision/recall per defect class, and where is it weakest?
15. Show me your one skew mitigation with the Spark UI before/after. Why that mitigation?
