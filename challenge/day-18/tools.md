# Day 18 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `mlflow` | Load registered model by stage in the scoring job | `mlflow.pyfunc.load_model("models:/<name>/Staging")` resolves |
| `confluent-kafka` | Streaming inference consumer + `alerts` producer | reuse Day 8 serde config; commit offsets after producing the alert |
| `prometheus-client` | New serving/monitoring metrics | new port or the Day 8 exporter; update `ops/prometheus.yml` |
| Grafana | Dashboard for scores/alerts/drift/AUPRC | provision the dashboard JSON in the repo (`ops/grafana/`) |
| `scipy.stats` / Day 12 drift module | PSI, KS, CUSUM on live windows | import the Day 12 code; don't fork it |
| `evidently` (optional) | Prebuilt drift + performance reports/dashboards | `evidently` report presets are a fast way to a monitoring UI; still keep your own PSI for interviews |
| `river` (optional) | Online drift detectors (ADWIN, Page-Hinkley) | streaming-native; stretch only |

### Config checkpoints

- Freeze and commit the monitoring baseline (training-window distributions + Day 16 metric
  baselines with CIs). Monitors compare against *that*, not rolling recent data.
- Alert de-bounce params (`N`, `M`, cooldown, rise-delta) live in `config/alerting.yaml`.
- Retrain thresholds live in `config/retrain.yaml` and are referenced by `retrain-policy.md`.

### Traps

- Computing "current AUPRC" before labels mature = scoring against mostly-unknown outcomes.
  Lag the performance monitor by the label horizon and expose a pending-labels gauge.
- PSI against last week instead of the frozen baseline masks gradual drift entirely.
- An alert consumer that commits offsets before the `alerts` produce succeeds can silently drop
  alerts on crash.
- Evidently is great for a demo but don't let it be your only understanding of drift — you'll be
  asked to derive PSI by hand.
