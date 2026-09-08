# Day 16 — Interview Questions

## Technical fundamentals

1. Walk me through computing a 95% confidence interval for AUC with the bootstrap. What exactly
   do you resample and why does it matter here?
2. ROC-AUC vs. PR-AUC for a 3%-prevalence label — which do you lead with and why? What's the
   PR-AUC of a random model?
3. What does the DeLong test do? What are its assumptions, and when can't you use it?
4. Define calibration. A model with AUC 0.9 can still be badly calibrated — how, and why does it
   matter clinically?
5. Platt scaling vs. isotonic regression for recalibration — trade-offs, and where do you fit
   them?
6. What is the Brier score and how does it decompose into reliability, resolution, and
   uncertainty?
7. Explain decision curve analysis. What does "net benefit" mean and what does it add over
   sensitivity/specificity?
8. You see AUC 0.86 overall but 0.71 for patients over 75. What are the possible causes and what
   do you do about it?

## Real-world scenarios

9. Clinical leadership asks "is the model accurate?" Give the 60-second answer that's honest
   about uncertainty and calibration without drowning them.
10. The GBM's AUC is 0.02 higher than the LR, DeLong p = 0.04. Do you ship the GBM? What else
    factors in?
11. In production, predicted probabilities cluster around 0.2–0.4 and never go high, even for
    patients who deteriorate. What's likely wrong and how do you confirm?
12. A fairness review finds lower sensitivity for one hospital unit. Is that discrimination, case
    mix, data quality, or label bias — how do you tell them apart?

## Explain what you built today

13. Show me your evaluation report's conclusion. Would you pilot this model? Where would it fail
    first?
14. Walk me through your calibration analysis — before and after recalibration, and what it means
    for someone acting on a "40% risk" number.
