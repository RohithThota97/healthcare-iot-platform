# Day 11 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `pandas` / `polars` | Summary tables from SQL output | Don't load raw silver into pandas — aggregate in SQL/Spark first |
| `numpy` / `scipy.stats` | Skew, kurtosis, Shapiro, Anderson, Levene, pointbiserialr | `scipy.stats` version recent enough for `anderson` k-sample if needed |
| `statsmodels` | Q–Q plots, VIF, ECDF, later regression | `statsmodels.api` imports; `qqplot` renders |
| `matplotlib` + `seaborn` | Histograms, KDE, clustermap, heatmaps | Save to `docs/img/eda/`; set a non-interactive backend for scripts (`Agg`) |
| `missingno` | Missingness matrix / heatmap / dendrogram | `pip install missingno`; works on a sampled frame |
| `pingouin` (optional) | Tidy stats (partial corr, effect sizes) | Nicer API than raw scipy for Day 13 too |
| `jupyter` / `jupytext` / `nbconvert` | Notebooks that also live as `.py`/`.md` in git | `jupytext --to md` or `nbconvert --to html`; commit the rendered output |

### Config checkpoints

- Decide notebook policy: pair every `.ipynb` with a `jupytext` `.md`/`.py` so diffs are
  reviewable, and commit an executed `.html` for the record. Record in `CONTRIBUTING.md`.
- Set a fixed random seed for any subsampling so the EDA is reproducible.
- Fix the plotting style once (`seaborn.set_theme`) so every figure is consistent.

### Traps

- Running normality tests on 100k+ rows: they'll reject normality on trivial deviations.
  Subsample to ~1–5k or use visual + effect-size judgment.
- `seaborn.clustermap` on a huge matrix is slow and unreadable — cluster on the correlation
  matrix (small), not the raw data.
- Kurtosis: `scipy.stats.kurtosis` is *excess* kurtosis (normal = 0) by default; say which you
  report.
