# Day 12 — Interview Questions

## Technical fundamentals

1. Static range checks vs. statistical outlier detection vs. drift detection — what does each
   catch that the others miss?
2. Derive PSI. What are its failure modes (bin count, zero bins, sample size)? What's a
   defensible alert threshold?
3. KS test vs. Wasserstein distance vs. JS divergence for measuring distribution shift — when
   is each the right tool?
4. Why is a modified z-score (median + MAD) preferred over a plain z-score for vitals with
   existing outliers?
5. Explain a CUSUM chart. How do `k` and `h` relate to the size of shift you want to detect and
   your false-alarm rate?
6. In dbt, what's the difference between a singular test, a generic test, and a package test
   like `dbt-expectations`? How do you test a *statistical* property?
7. Where should a data contract live — in dbt, in Great Expectations, in the application, or all
   three? What does each position give you?
8. Multiple testing: you run 6 vitals × 8 units = 48 drift tests nightly. Why is "any p < 0.05"
   a bad alert rule, and what do you do instead?

## Real-world scenarios

9. PSI on `heart_rate` is 0.27 this week. Walk through everything you check before triggering a
   retrain.
10. A dbt test starts failing every night at 2% of rows. It's a real range violation from one
    new device. Do you fail the build, quarantine, or warn — and how do you decide the policy?
11. Your drift monitor fires constantly on weekends. What's likely happening and how do you make
    the monitor robust to it without going blind to real drift?
12. A GE contract blocks silver promotion at 6 a.m. and the clinical dashboard is now stale.
    What's your runbook — override, partial-promote, or hold?

## Explain what you built today

13. Show me a data contract. What harm does it prevent, what does it let through, and what
    happens on failure?
14. Walk me through your drift report catching the Day 4 "quirk" device. What metric fired, on
    what baseline, and why didn't it false-alarm on the clean slice?
