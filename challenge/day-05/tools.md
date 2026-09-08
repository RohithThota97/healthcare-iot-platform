# Day 5 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `numpy` / `scipy.signal` | AR(1) noise, resampling, FFT sanity check | `scipy.signal.welch` / `periodogram` available |
| `pandas` / `polars` | Time-series assembly, Parquet output | Datetime index in UTC; `to_parquet` with a partition scheme |
| `pyarrow` | Parquet + partitioned dataset writes | `pyarrow.dataset.write_dataset(..., partitioning=...)` works |
| `wfdb` (optional) | Canonical PhysioNet reader | You already have CSVs, so `pandas.read_csv` is enough; `wfdb` only if you fetch more records |
| `fastavro` / `protobuf` | Encode the replay stream file | Same library/version you'll use in the Day 8 producer |
| `matplotlib` | Vitals + waveform plots for the data card | Save under `docs/img/synthetic/` |

### BIDMC file map (in `data/raw/bidmc_csv/`)

| Suffix | Contents | Rate |
|---|---|---|
| `*_Signals.csv` | PPG, ECG (`II`), respiration waveforms | ~125 Hz |
| `*_Numerics.csv` | HR, PULSE, RESP, SpO2 | 1 Hz |
| `*_Breaths.csv` | Breath annotation indices | event |
| `*_Fix.txt` | Age, gender, fixed metadata | once |

### Traps

- The BIDMC waveform time column may be a sample index, not seconds — convert with the sample rate.
- Emitting one Avro record per ECG sample will make a multi-GB replay file. Frame the waveform
  per your Day 3 schema (N samples + start ts + rate).
- If `sensor_readings` doesn't fit in memory, generate per-patient and append to a partitioned
  Parquet dataset; don't build one giant DataFrame.
- Keep RNG seeded and per-patient-derived (`rng = default_rng(base_seed + patient_hash)`) so you
  can regenerate one patient without redoing all of them.
