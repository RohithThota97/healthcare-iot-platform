# Day 19 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| Neo4j Community (Docker) | Trajectory graph | `:7474` browser + `:7687` bolt; set constraints/indexes before bulk load |
| `neo4j` Python driver | Batched idempotent load | `session.execute_write` + `UNWIND $rows` + `MERGE` |
| Postgres + `pgvector` | Semantic vector store | `CREATE EXTENSION vector;` `ivfflat`/`hnsw` index; embedding dim matches the model |
| `sentence-transformers` (HuggingFace) | Local embeddings | `all-MiniLM-L6-v2` (384-dim); first run downloads the model |
| `langgraph` / `langchain` | Multi-agent orchestration | pin versions — the API moves fast; a plain state machine is an acceptable substitute |
| `docling` (optional) | Parse PDFs/HTML reference docs to clean text | only if your corpus isn't already markdown/text |
| An LLM (API or local `ollama`) | Reasoning + guardrail agents | if unavailable, rule-based + templated answers; document the substitution |

### Config checkpoints

- Neo4j: `dbms.security.auth_enabled` on; put creds in `.env` (git-ignored), never in code.
- pgvector: the index type and `lists`/`m` params affect recall — note your choice.
- Embedding model + dimension is a contract: changing it means re-embedding the whole corpus.
- Keep the RAG eval set in the repo (`rag/eval/qa.jsonl`) so results are reproducible.

### Traps

- Loading raw time-series into Neo4j will blow it up — aggregate to window nodes.
- `MERGE` without a uniqueness constraint does a full scan and can create duplicates under
  concurrency — create constraints first.
- LangChain/LangGraph version drift breaks examples constantly; pin exact versions and don't
  copy tutorials blindly.
- LLM-as-judge for faithfulness needs a strict rubric or it rubber-stamps everything.
- Don't let any real-looking identifier into the corpus or the answers — the guardrail must
  check output, and you must check the corpus.
