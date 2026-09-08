# Day 4 — Interview Questions

## Technical fundamentals

1. What makes synthetic data "good enough" for building a data platform vs. good enough for
   training a model you'd trust? Where's the line?
2. How do you make a data generator reproducible? Name every source of non-determinism you had
   to control.
3. You want age, BMI, unit, and comorbidities to be *correlated*. What are three ways to do that,
   from simplest to most rigorous?
4. What is referential integrity, and what tests prove your generated `clinical_events` has it
   against `patients` and `device_metadata`?
5. Why model deterioration as a hazard/process rather than just flipping a random 5% of patients
   to "deteriorated"?
6. Parquet vs. CSV for generated datasets — what do you lose with CSV and when does it matter?

## Real-world scenarios

7. A data scientist trains a model on your synthetic data, gets AUC 0.95, and is thrilled.
   Why are you skeptical, and what do you tell them?
8. You need to demo to a hospital that can't share real data. What are the risks of synthetic
   data leading you to design the wrong thing, and how do you mitigate them?
9. Your generated data has zero missingness and zero label noise. What breaks on Day 11–16
   because of that, and what are you deliberately adding on Day 6?
10. Someone asks you to "just use MIMIC / eICU directly." What are the access, licensing, and
    de-identification considerations, and why might synthetic still be the right call here?

## Explain what you built today

11. Walk me through your generative model of a patient. What's conditional on what, and why?
12. How would I, as a reviewer, verify your synthetic data is internally consistent without
    reading all the code?
