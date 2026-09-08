# Day 13 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `scipy.stats` | t-tests, Mann–Whitney, Kruskal, chi-square, Fisher, Wilcoxon | Know which return one- vs. two-sided by default |
| `statsmodels` | ANOVA, Tukey HSD, `MixedLM`, GEE, multipletests (BH/Bonferroni) | `statsmodels.stats.multitest.multipletests`; `MixedLM.from_formula` |
| `pingouin` | Tidy tests with effect sizes + CIs in one call | `pg.ttest`, `pg.pairwise_gameshowell`, `pg.partial_corr` — much less boilerplate |
| `scikit-learn` | Mutual information, permutation importance, univariate AUC | `mutual_info_classif`, `permutation_importance` |
| `numpy` | Seeded bootstrap resampling (by patient!) | `default_rng`; resample patient ids, not rows |
| `matplotlib`/`seaborn` | Group distributions, forest plot of effect sizes + CIs | Save to `docs/img/stats/` |

### Config checkpoints

- Fix a seed for every bootstrap and record iteration count (2k for exploration, 10k for the
  final numbers).
- Decide and document the analysis unit (patient-window vs. reading) before running anything.
- Keep a single `results.csv` schema: `question, test, statistic, p_raw, effect_name,
  effect_value, ci_low, ci_high, n, p_adj_bh`.

### Traps

- `ttest_ind` default is `equal_var=True` (Student's). Set `equal_var=False` for Welch.
- Mann–Whitney U in scipy: the `alternative` arg matters; and it tests stochastic dominance, not
  "difference in medians" exactly.
- `MixedLM` can fail to converge — scale predictors, simplify random effects, try a different
  optimizer; report convergence status.
- Bootstrapping rows instead of patients gives falsely tight CIs — the classic repeated-measures
  mistake.
- `multipletests` returns adjusted p-values *and* a reject boolean — report both.
