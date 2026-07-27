---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: knowledge systems
form_factor:
  - local web app
  - reusable delivery workflow
deployment: local desktop with optional DGX Spark inference
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#10. Knowledge Base Agency]]"
status: concept
---
# Knowledge Base Agency

> Turn a client’s supplied documents, transcripts, and FAQs into a citation-first knowledge base and a tested question-answering interface.

## Product Outcome

Produce a maintainable delivery package rather than a one-off chatbot: parsed sources, searchable chunks, answer UI, unanswered-question queue, evaluation set, and refresh instructions.

## User and Core Workflow

The operator creates a project, imports files, reviews parsing/OCR, assigns document metadata, and generates a searchable index. Seed questions test retrieval and answer faithfulness. The client-facing preview shows citations and abstains when evidence is absent; operator corrections become evaluation cases.

## Demo/Personal V0

Use 20 local PDFs/Markdown files and 30 expected questions. Support search, cited answers, “not found,” source preview, and an evaluation report. Skip website crawling and external chat-channel deployment.

## Build Boundary

Include file ingestion, parsing QA, metadata, hybrid search, cited answers, abstention, evaluations, and rebuilds. Exclude arbitrary web crawling, access-control synchronization, autonomous content rewriting, live customer support escalation, and multi-tenant hosting.

## Existing Products, Building Blocks, and Shortcuts

- [Docling](https://github.com/docling-project/docling) accelerates conversion of PDFs, OCR, layouts, and tables into structured content.
- [Qdrant](https://github.com/qdrant/qdrant) provides hybrid and multivector retrieval when a larger index warrants it.
- [Whisper](https://github.com/openai/whisper) transcribes supplied audio/video locally.
- [SQLite FTS5](https://www.sqlite.org/fts5.html) replaces a vector database for the first small corpus.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, Docling, SQLite FTS5, sentence-transformers, Ollama, and a minimal React or HTMX UI. Python integrates the document stack cleanly; SQLite keeps deployments portable; DGX Spark can host embeddings and inference when the corpus grows.

## Architecture/Data Model

Model `projects`, `sources`, `source_versions`, `pages`, `chunks`, `embeddings`, `questions`, `retrieval_runs`, `answers`, `citations`, and `evaluations`. Preserve source hashes and page coordinates. Retrieval and generation logs must be replayable against an index version.

## Build Slices

1. Ingest, parse preview, metadata, and FTS search.
2. Chunking, embeddings, cited answer, and abstention.
3. Golden-question harness, failure review, and rebuild command.
4. Reusable project template and optional Qdrant/DGX mode.

## Drawbacks/Concerns/Failure Modes

OCR errors, bad chunk boundaries, stale sources, access leaks, and confident synthesis across unrelated passages are common. Add parsing QA, document-level filters, source versioning, permission-aware project boundaries, and a citation-support evaluator.

## Clever Hacks and Simpler Alternative

Ship a strong full-text search portal with AI-generated query expansion before RAG. Many “knowledge bot” requests are solved by fast navigation and source snippets with dramatically less uncertainty.

## Success Measures

Measure answer support rate, citation precision, abstention accuracy, top-k retrieval recall, corpus refresh time, unanswered-question backlog, and client correction rate.

## Product Path

Personal document assistant → repeatable agency package → hosted knowledge operations product. Before client hosting, shared accounts, connectors, or billing, run [[Scope Expansion Checklist]] for permissions, data rights, model terms, and release duties; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#10. Knowledge Base Agency]]
- [[Scope Expansion Checklist]]
- [[Personal Signal Intelligence OS]]

