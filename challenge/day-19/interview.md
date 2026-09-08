# Day 19 — Interview Questions

## Technical fundamentals

1. Why model patient trajectories as a graph instead of just chunking notes into a vector store?
   Give a question each approach answers well and badly.
2. What is hybrid retrieval? How do you fuse results from semantic search, a graph query, and a
   structured lookup into one context?
3. How do you make a Neo4j bulk load idempotent? What's the role of constraints and `MERGE`?
4. Write Cypher (sketch) for "average HR in the 6 hours after each dose of medication X, per
   patient".
5. What does an embedding model's dimension commit you to? What breaks if you switch models?
6. How do you evaluate a RAG system? Define retrieval hit-rate, answer faithfulness/groundedness,
   and why exact-match is a bad answer metric here.
7. What is the guardrail agent for, and what are its failure modes (false blocks, missed unsafe
   outputs)?
8. `ivfflat` vs. `hnsw` index in pgvector — recall/latency/build-time trade-offs.

## Real-world scenarios

9. A clinician asks the agent "should we start norepinephrine?" What must happen, and where in
   the pipeline does it happen?
10. The agent gives a confident answer with a citation that doesn't actually support it. How do
    you catch this automatically and how do you reduce it?
11. Your graph is now 50M nodes and the temporal queries are slow. What do you change —
    modeling, indexing, pre-aggregation?
12. Legal erasure request for a patient in the graph, the vector store, and the corpus metadata.
    Walk the deletion across all three.

## Explain what you built today

13. Walk me through one question end to end: which agents run, what each retrieves, how the
    answer gets grounded and cited, and what the guardrail checked.
14. Show me your RAG eval numbers. Where is retrieval weakest and what would you try next?
