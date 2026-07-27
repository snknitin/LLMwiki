---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: diligence operations
form_factor:
  - local document workspace
  - cited Q&A interface
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#7. Data Room Concierge]]"
status: concept
tags:
  - documents
  - diligence
  - rag
---

# Data Room Concierge

> A local diligence workspace that inventories files, detects missing or conflicting evidence, and answers investor questions with page-level citations and abstention.

## Product Outcome

Turn a messy folder into an investor-ready index without silently changing source documents. The founder sees canonical categories, versions, missing items, access class, extracted facts, contradictions, and a Q&A view where every answer opens the supporting page.

## User and Core Workflow

The founder imports a folder, selects a checklist template, and confirms file sensitivity. The pipeline hashes, converts, OCRs, classifies, and extracts document metadata. A review screen merges duplicates and chooses authoritative versions. The system generates an index and gap list; questions retrieve approved chunks and produce cited draft answers. The founder can package selected files without exposing the whole room.

## Demo/Personal V0

Use ten synthetic startup documents—cap table, incorporation record, financial model, contracts, policies, and deliberately stale duplicates. Produce an index, three missing-document warnings, one contradiction, and five cited answers. All files stay local.

## Build Boundary

No legal diligence opinion, signature validity claim, unrestricted sharing, automatic redaction, or answer without source support. Do not index unrelated personal folders. OCR/extraction confidence must be reviewable, and source files remain immutable.

## Existing Products, Building Blocks, and Shortcuts

- [Docling](https://github.com/docling-project/docling) converts PDFs and office documents into structured content; use provenance/page metadata rather than flattening everything to plain text.
- [Unstructured](https://github.com/Unstructured-IO/unstructured) provides partitioning and chunking across many formats, useful as a fallback or comparison.
- [OCRmyPDF](https://github.com/ocrmypdf/OCRmyPDF) adds searchable OCR layers while preserving scanned PDFs; `ocrmypdf --deskew input.pdf output.pdf` is a practical preflight.
- [Qdrant](https://qdrant.tech/documentation/quickstart/) supports a local vector index, but SQLite FTS is the simpler starting point for ten documents.

## Recommended Free-First Stack

Use Python, Docling/OCRmyPDF, SQLite FTS5 plus optional Qdrant, FastAPI, and SvelteKit. Store originals and derivatives on the filesystem by content hash. Use Ollama for classification and grounded answer drafting with required chunk IDs. A small corpus does not need a DGX.

## Architecture/Data Model

Model `Room`, `Document`, `Blob`, `VersionRelation`, `Page`, `Chunk`, `Classification`, `ChecklistItem`, `Gap`, `Fact`, `Conflict`, `Question`, `AnswerDraft`, `Citation`, and `AccessPolicy`. Keep extraction version, page coordinates, and source hash on each chunk.

## Build Slices

1. Folder import, hashing, and immutable blob store.
2. Conversion/OCR with visual spot-checks.
3. Document classification and editable index.
4. Checklist, missing items, and duplicate/conflict review.
5. Hybrid retrieval and citation-only Q&A.
6. Selective export manifest and access audit.

## Drawbacks, Concerns, and Failure Modes

Complex tables and scanned contracts extract poorly. Similar filenames hide stale versions. Retrieval may quote a superseded document. Investor questions can solicit undisclosed information. Embeddings and logs can leak confidential text. A polished answer may conceal uncertainty.

## Clever Hacks and Simpler Alternative

Start with a deterministic file inventory and checklist; add Q&A only after documents are correctly versioned. Generate “answer packets” containing excerpts and links, then let the founder write the final response. Use a “current/obsolete/unknown” flag at document and citation level.

## Success Measures

- All imported files have hashes, type, owner, sensitivity, and version state.
- Every answer sentence has at least one valid citation or is labeled inference.
- Superseded documents never appear without a warning.
- A user can correct classification/versioning without reimporting.
- Export contains only explicitly selected documents.

## Product Path

Personal fundraising preparation can evolve into a founder-side diligence assistant. Hosted multi-party rooms need mature authorization, encryption/key management, audit logs, retention, regional hosting, and contractual security commitments.

## Related

- [[Support FAQ Builder]]
- [[Understand This Paper]]
- [[Brag Notary]]
