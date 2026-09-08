# 20-Day Build Challenge — Healthcare IoT Real-Time Patient Monitoring Platform

This folder is a self-paced, challenge-style program to build the platform described in the
repo [README](../README.md). It is **not a tutorial**. Each day gives you:

- **Mission + Challenges** — the outcomes to hit, the constraints to respect, and the
  acceptance criteria that tell you when you are done. *How* you get there is yours to work out.
- **Tools** (`tools.md`, on days that introduce new tooling) — what to install and stand up,
  with configuration checkpoints and known traps. Enough to unblock you, not a copy-paste script.
- **Interview** (`interview.md`) — technical deep-dive questions and real-world scenario
  questions on that day's topic, plus "explain what you built today" prompts. Answer them out
  loud or in writing before moving on.
- **Notes** (`notes.md`) — a template to log decisions, blockers, time spent, and what you'd
  redo. Fill it in every day; it becomes your interview story bank.

## How to use it

1. Work the days in order. Each day assumes the previous day's deliverables are committed.
2. Budget **10–12 hours/day**. Every day lists a rough per-challenge time split. If a challenge
   runs 50% over budget, drop to the "minimum viable" acceptance criteria and open the `Hints`
   section — don't lose the day.
3. Commit at the end of every challenge, not just every day. Use a branch per day
   (`day-03-schemas`) and open a PR against `main` so you practice the review loop.
4. Do the interview questions the **same day**, while the material is fresh. Speaking them
   aloud is the point — reading the answer in your head doesn't build recall.
5. Two checkpoint mock interviews are built in: **end of Day 10** and **end of Day 20**
   (see [INTERVIEW-PREP.md](INTERVIEW-PREP.md)).

## Rules of the challenge

- **Synthetic or de-identified data only.** Never commit PHI, real identifiers, credentials,
  or unapproved clinical content. Any model output is experimental decision support, not a
  diagnosis. (Same rules as the parent repo.)
- **Everything runs locally.** No paid cloud accounts required. Where the architecture names a
  managed service (Snowflake, Databricks, Unity Catalog), you substitute a local equivalent
  (DuckDB/Postgres, local Spark + Delta, file-based ACLs) and write an ADR explaining the swap.
- **Write it down.** Every non-obvious decision gets a one-paragraph ADR in `docs/adr/`.
  Interviewers ask "why did you choose X" — your ADRs are the answer.
- **Test as you go.** By Day 20 you should have a `tests/` suite and data-quality checks that
  run in CI, not a pile of notebooks.

## Phases

| Days | Phase | Outcome |
|---|---|---|
| 1–2 | Foundations | Architecture decided, environment reproducible, docs skeleton |
| 3–6 | Data | Schemas, synthetic generators, PhysioNet load, injected defects |
| 7–10 | Streaming & storage | Kafka path with DLQ, Kafka Connect, lakehouse layers, PySpark cleaning |
| 11–14 | Statistics & data quality | EDA, drift + outlier rules, hypothesis tests, windowed features |
| 15–18 | ML & evaluation | Baseline models, statistical evaluation, survival analysis, drift monitors |
| 19–20 | RAG, serving, ops | GraphRAG agent, API + dashboard, Airflow, observability, final review |

## Directory layout

```text
challenge/
├── README.md            # this file
├── SETUP.md             # one-time machine setup, done before Day 1
├── INTERVIEW-PREP.md    # interview strategy, mock schedule, cross-cutting question bank
├── PROGRESS.md          # your tracker — update daily
├── day-01/ … day-20/
│   ├── README.md        # mission, challenges, deliverables, definition of done, hints
│   ├── tools.md         # (some days) tools to install + config checkpoints
│   ├── interview.md     # technical + real-world questions for the day
│   └── notes.md         # your daily log template
```

Start with [SETUP.md](SETUP.md), then [day-01/README.md](day-01/README.md).
