---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: founder tooling
form_factor:
  - local document analyzer
  - shareable scorecard
deployment: local desktop with optional DGX Spark inference
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#20. Pitch Deck Brutality Score]]"
status: concept
---
# Pitch Deck Brutality Score

> Parse a pitch deck into slide-level evidence, score it with a transparent rubric, and produce a direct investor-style memo without inventing market facts.

## Product Outcome

Give a founder a fast, uncomfortable, actionable review: what is clear, what is missing, which claims lack proof, what questions an investor will ask, and the next three deck changes.

## User and Core Workflow

Upload PDF or PPTX, inspect the rendered slides and extracted text, choose company stage and deck purpose, and run a rubric. The system scores categories, links every criticism to slide evidence, separates absent information from contradictory information, and generates an editable memo plus scorecard.

## Demo/Personal V0

Analyze five public or user-owned decks as PDF. Support eight rubric categories, slide citations, missing-section detection, tone settings, and a before/after rerun. Export Markdown and a one-page PDF grade.

## Build Boundary

Include conversion, slide extraction, OCR fallback, stage-aware rubric, evidence, memo, edit/re-run, and export. Exclude confidential-deck sharing, investment advice, market-size fact invention, fundraising guarantees, and public leaderboards.

## Existing Products, Building Blocks, and Shortcuts

- [PyMuPDF](https://github.com/pymupdf/PyMuPDF) extracts PDF text, images, and page renderings.
- [LibreOffice startup parameters](https://help.libreoffice.org/latest/en-US/text/shared/guide/start_parameters.html) document headless PPTX-to-PDF conversion.
- [PptxGenJS](https://github.com/gitbrent/PptxGenJS) can generate a shareable scorecard deck.
- [Tesseract](https://github.com/tesseract-ocr/tesseract) is a local OCR fallback for image-heavy slides.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, PyMuPDF, LibreOffice headless, Tesseract, SQLite, Ollama/DGX inference, and HTML-to-PDF export. Python fits document extraction; local processing protects unpublished decks; structured rubric outputs are testable.

## Architecture/Data Model

Store `decks`, `deck_versions`, `slides`, `text_blocks`, `visual_assets`, `rubric_versions`, `scores`, `findings`, `evidence_spans`, `memo_versions`, and `founder_responses`. Each score needs slide evidence or an explicit “missing across deck” query.

## Build Slices

1. PDF intake, slide images/text, quality check.
2. Stage-aware rubric and evidence-linked findings.
3. Memo, prioritized fixes, grade export.
4. PPTX conversion, OCR fallback, before/after diff.

## Drawbacks/Concerns/Failure Modes

Extraction misses charts; rubrics vary by stage; harsh tone can obscure useful advice; and scores create fake objectivity. Preview parsing, expose weights, allow “not applicable,” pair every criticism with a fix, and treat the score as navigation.

## Clever Hacks and Simpler Alternative

First build a “missing investor questions” checklist with slide citations. It may deliver more value than a composite score and makes evaluation far easier.

## Success Measures

Track parsing accuracy, evidence-backed finding rate, founder acceptance, score stability across reruns, prioritized fixes completed, time to review, and external reviewer agreement.

## Product Path

Personal founder reviewer → productized advisory tool → collaborative deck workspace. Before shared uploads, external reviewers, model APIs, or payments, run [[Scope Expansion Checklist]] for confidentiality, document rights, model terms, and release responsibilities; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#20. Pitch Deck Brutality Score]]
- [[Scope Expansion Checklist]]
