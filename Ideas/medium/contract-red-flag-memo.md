---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: document-review
form_factor:
  - local desktop app
  - document analysis report
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#29. Contract Red Flag Memo]]"
status: concept
tags:
  - contracts
  - document-ai
  - high-stakes
---

# Contract Red Flag Memo

> A private issue-spotting assistant that quotes the contract, explains business impact, and prepares questions for counsel—never a substitute for legal review.

## Product Outcome

Upload a contract and select the user’s side, jurisdiction if known, business priorities, and fallback positions. The tool returns an executive memo of potentially relevant clauses, exact page/quote references, missing-clause checks, uncertainty, and a negotiation-email draft. It must distinguish extraction, issue spotting, and legal judgment.

## User and Core Workflow

1. Import PDF/DOCX and choose contract type, party side, and priorities.
2. Extract page-aware text; detect scans and run OCR when required.
3. Segment clauses while retaining page/bounding-box provenance.
4. Apply a versioned issue checklist, then let the local model explain only retrieved clauses.
5. User reviews each finding beside the source page and marks accept/discuss/ignore.
6. Export memo and questions/negotiation draft with a prominent review disclaimer.

## Demo/Personal V0

Use public sample NDAs or vendor agreements. Support PDF only, ten issue categories, page-linked quotes, and local generation. Include one scanned sample and one clause deliberately absent to test uncertainty/missing checks.

## Build Boundary

**MVP:** local PDF import, text/OCR, ten configurable red-flag categories, clause quotes with page numbers, confidence, review checklist, memo/email export.

**Out:** legal advice, enforceability predictions, court-outcome claims, autonomous signatures/sends, jurisdiction-wide legal research, bulk customer uploads, and replacing counsel.

## Existing Products, Building Blocks, and Shortcuts

- [PyMuPDF](https://pymupdf.readthedocs.io/en/latest/the-basics.html) replaces low-level PDF parsing and supports page text, blocks, images, and OCR-assisted extraction.
- [OCRmyPDF](https://ocrmypdf.readthedocs.io/en/latest/) adds a searchable text layer to scanned PDFs before review.
- [Docling](https://github.com/docling-project/docling) accelerates structured document conversion when layouts/tables outgrow simple extraction.
- [CUAD](https://github.com/TheAtticusProject/cuad/) provides an expert-annotated contract-review benchmark and clause taxonomy for evaluation, not a turnkey legal oracle.

## Free-First Stack

- **App:** Python + Streamlit or Gradio for private document upload and side-by-side review.
- **Extraction:** PyMuPDF; OCRmyPDF/Tesseract fallback; Docling experiment for complex layouts.
- **Model:** local Ollama/vLLM with structured findings and retrieved clause text.
- **Storage:** encrypted-at-rest local workspace or ephemeral per-document folder.
- **Export:** Markdown/HTML to PDF; preserve page/quote references.
- **Evaluation:** small labeled set derived from public contracts and CUAD categories.

## Architecture/Data Model

`Document` stores checksum and metadata. `PageBlock` retains page, coordinates, and text. `Clause` references blocks. `ReviewRule` defines trigger, rationale, limitations, and questions. `Finding` contains clause IDs, quote, severity, uncertainty, and user decision. `MemoRun` records parser/model/rule versions.

## Build Slices

1. Page-aware extraction and document viewer.
2. Fixed checklist with keyword/regex retrieval.
3. Structured local explanations and missing-clause checks.
4. Review decisions and memo/email export.
5. OCR/layout fallbacks and evaluation suite.

## Drawbacks/Concerns/Failure Modes

- PDF reading order and OCR errors can alter meaning. Show source page image and confidence; never quote text the user cannot verify.
- A clause’s effect depends on definitions, exhibits, law, and negotiation context. Retrieve cross-references and use “potential issue” language.
- Models omit material issues. Report checklist coverage and an explicit “not assessed” section.
- Contracts are highly confidential. Keep local, disable telemetry/logging, and delete temp files.
- Severity is business-specific. Ask priorities and allow rule customization rather than universal risk scores.

## Clever Hacks and Simpler Alternative

- Start with one contract type and ten deterministic questions rather than “analyze anything.”
- A clause locator plus annotated checklist is more trustworthy than a fluent memo alone.
- Require each finding to quote fewer than a bounded number of words plus page number; the full clause stays in the viewer.
- Produce “questions for your lawyer” as the primary outcome; the negotiation email is secondary.

## Success Measures

- Every finding opens the correct source page/region.
- No finding survives export without a quote or explicit missing-clause rule.
- OCR/parsing failures are surfaced, not silently analyzed.
- A reviewer can audit a 10-page agreement faster than manual reading alone.
- Confidential files and derivatives can be removed in one action.

## Product Path

Personal contract checklist → role/contract-specific desktop tool → counsel-reviewed team workflow → regulated paid product. Any expansion requires professional legal review, security controls, jurisdiction boundaries, and document/model license audits.

## Related Wikilinks

- [[Fine Print Rage Meter]]
- [[Document Intelligence Workbench]]
- [[Proposal Writer for Freelancers]]

