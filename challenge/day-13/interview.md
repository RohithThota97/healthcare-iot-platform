# Day 13 — Interview Questions

## Technical fundamentals

1. Why is Welch's t-test the safer default than Student's? When would you not use either?
2. A p-value of 0.001 with Cohen's d of 0.03 — what do you conclude, and why is reporting the
   effect size non-negotiable?
3. You have 40 HR readings per patient across 500 patients. Why does a t-test on all 20,000
   readings give a wrong (too small) p-value? Name two correct approaches.
4. Explain a mixed-effects model with a random intercept per patient in plain language. What is
   the random intercept absorbing?
5. GEE vs. mixed-effects — what's the difference in what they estimate (population-average vs.
   subject-specific)?
6. Bonferroni vs. Benjamini–Hochberg — what does each control (FWER vs. FDR), and when do you
   prefer FDR?
7. Mutual information vs. correlation for feature screening — what does MI catch that Pearson
   misses, and what's the cost?
8. Define target leakage. Give three ways a "predictive" feature in this platform could actually
   be leaking the deterioration label.
9. How do you build a bootstrap confidence interval for the difference in median HR between two
   groups of patients? What do you resample?

## Real-world scenarios

10. Your analysis says "RR is significantly higher before deterioration (p < 1e-9)". A clinician
    shrugs — "we know that". How do you make the analysis say something *actionable*?
11. Two device models show a "significant" difference in mean SpO2. Before you tell anyone,
    what confounders do you rule out?
12. A stakeholder wants you to drop every feature with p > 0.05 from the model. Why is that a
    bad feature-selection strategy?
13. You ran 60 tests, 4 are significant after FDR. How confident are you those 4 are real, and
    what would you do to confirm?

## Explain what you built today

14. Walk me through your feature shortlist. Pick your top feature and your most borderline one
    and defend both.
15. Show me one place where accounting for within-patient correlation changed your conclusion.
    By how much?
