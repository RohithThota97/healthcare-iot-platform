# Day 19 — Medical Reference Docs, Graph Model & GraphRAG Multi-Agent Workflow

**Phase:** RAG, serving, ops · **Time budget:** 10–12 h · **Skill focus:** tooling (graph + retrieval + agents)
**Prereqs:** Day 18; silver/gold tables + clinical events + risk labels available.

## Why this day matters

The RAG layer answers *relational and temporal* clinical questions ("what changed after
medication X", "which patients on unit 4 trended toward NEWS2 ≥ 5 overnight") — the kind vector
similarity alone can't. You'll model patient trajectories as a graph, do hybrid graph+semantic
retrieval, and orchestrate a small multi-agent flow with a guardrail agent. Interviewers probe
"why a graph", "how do you stop hallucination", "how do you evaluate RAG".

## Challenges

### C1 — Curate a small reference corpus (~1.5 h)
- Assemble a handful of **non-PHI, redistributable** reference docs: NEWS2 scoring definition,
  vital-sign normal ranges, your own platform/data-dictionary docs, the statistical-methods
  notes. Chunk them; store text + metadata.
- Acceptance: a `rag/corpus/` with source, license note, and a chunking record. No clinical
  content beyond public scoring guidance.

### C2 — Graph model of patient trajectories (~3.5 h)
- Model in Neo4j: `(:Patient)-[:HAD_ENCOUNTER]->(:Encounter)-[:HAS_READING]->(:ReadingWindow)`,
  `(:Encounter)-[:RECEIVED]->(:Medication)`, `(:Encounter)-[:HAD_EVENT]->(:DeteriorationEvent)`,
  `(:Encounter)-[:SCORED]->(:RiskScore)`, plus `(:Device)`, `(:Unit)`.
- Load from your silver/gold + clinical events (aggregate readings to windows — don't load every
  raw row).
- Write Cypher for the target questions: "vitals in the 6 h after medication X vs. 6 h before",
  "patients whose risk score crossed 0.5 within 12 h of a unit transfer".
- Acceptance: graph loads from a script; 4+ example Cypher queries return sensible results;
  `docs/rag/graph-model.md` has the schema diagram.

### C3 — Hybrid retrieval (~3 h)
- Embeddings for the corpus chunks (HuggingFace sentence-transformers) into pgvector (or
  Weaviate).
- A retriever that combines: semantic search over docs + a graph query over patient data +
  structured lookups (a risk score, a trend) — and fuses them into a context bundle.
- Acceptance: for 3 sample questions, show the retrieved context (doc chunks + graph rows) and
  that it's sufficient and relevant.

### C4 — Multi-agent orchestration + guardrail + eval (~3 h)
- With LangGraph/LangChain: a **retrieval agent** (plans which sources to hit), a
  **reasoning agent** (answers strictly from retrieved context, cites it), and a **guardrail
  agent** (flags diagnostic/treatment-advice phrasing, out-of-scope, missing citations,
  PHI in output).
- A tiny eval set (10–20 Q/A pairs with gold answers or gold retrieved-context) scored for
  retrieval hit-rate, answer faithfulness (grounded in context), and guardrail catch-rate.
- Acceptance: `docs/rag/evaluation.md` with the metrics; the guardrail blocks a planted
  "what should we prescribe" question; every answer carries citations.

### Stretch (optional)
- GraphRAG-style community summaries over the trajectory graph for "summarize unit 4 last night".
- Compare hybrid vs. vector-only retrieval on the eval set and quantify the lift.

## Deliverables (branch `day-19-graphrag`)

- `rag/corpus/`, `rag/graph/` (loader + Cypher), `rag/retrieval/`, `rag/agents/`
- `docs/rag/graph-model.md`, `retrieval.md`, `evaluation.md`
- eval set + a runnable eval script
- tests: graph loader is idempotent; guardrail blocks the planted unsafe prompt; answers cite sources

## Definition of done

- [ ] Reference corpus is non-PHI, license-noted, chunked.
- [ ] Neo4j trajectory graph loads idempotently; 4+ Cypher queries answer relational/temporal Qs.
- [ ] Hybrid retriever fuses semantic + graph + structured lookups; shown sufficient on samples.
- [ ] Multi-agent flow with a guardrail that blocks diagnostic/out-of-scope prompts; answers cited.
- [ ] RAG eval report: retrieval hit-rate, faithfulness, guardrail catch-rate.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Don't load raw readings into Neo4j — aggregate to `ReadingWindow` nodes (e.g. hourly
  mean/min/max per signal). Graph is for relationships, not time-series storage.
- `LOAD CSV` or the Python driver with `UNWIND $rows` batched; `MERGE` on natural keys for
  idempotency; create constraints/indexes first.
- Temporal Cypher: parameterize a medication time and match readings with
  `WHERE r.ts >= $t - duration('PT6H') AND r.ts <= $t + duration('PT6H')`.
- Embeddings: `sentence-transformers/all-MiniLM-L6-v2` is small and fine locally; store vectors
  in pgvector (`CREATE EXTENSION vector`; an `ivfflat` index).
- Faithfulness eval without a big framework: check that every sentence in the answer is
  entailed by some retrieved chunk (LLM-as-judge with a strict rubric, or n-gram overlap as a
  crude proxy).
- Guardrail as a classifier + rules: regex/keyword for "prescribe/diagnose/dose", plus a check
  that citations exist and no identifier-shaped strings appear.
- If you have no LLM API access, make the reasoning/guardrail agents rule-based + template
  answers over retrieved context — the *architecture* and eval are the graded parts. Note the
  substitution.
