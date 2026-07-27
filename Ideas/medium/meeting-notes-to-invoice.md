---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: professional services billing
form_factor:
  - local web app
  - document workflow
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#13. Meeting Notes to Invoice]]"
status: concept
---
# Meeting Notes to Invoice

> Convert meeting evidence into human-approved billable work, a draft invoice, and a client follow-up without guessing hours or rates.

## Product Outcome

Reduce the gap between doing work and billing it. The operator receives candidate tasks linked to note excerpts, applies contract rules, approves quantities, and exports both an invoice draft and a concise recap.

## User and Core Workflow

Import meeting notes or a transcript, select the client/project, and review extracted decisions, deliverables, and action items. The system matches candidates to approved service codes and rate rules, asks for missing time or quantity, then calculates line items. The user edits and approves before export.

## Demo/Personal V0

Use five historical notes plus a small project/rate CSV. Create billable-candidate cards with source quotes, a “non-billable” option, a draft invoice, and a follow-up email. Do not connect a calendar or send messages.

## Build Boundary

Include note import, task extraction, source evidence, project/rate mapping, deterministic calculations, invoice versioning, and follow-up draft. Exclude automatic time tracking, legal interpretation, accounting write-back, payment collection, and autonomous sending.

## Existing Products, Building Blocks, and Shortcuts

- [Google Meet API](https://developers.google.com/workspace/meet/api/guides/overview) provides a later path to conference artifacts.
- The [Meet artifact guide](https://developers.google.com/workspace/meet/api/guides/artifacts) clarifies recordings/transcripts and retention constraints.
- [Stripe Invoices](https://docs.stripe.com/api/invoices) supplies a proven draft/finalize/send lifecycle.
- [Whisper](https://github.com/openai/whisper) transcribes user-supplied recordings locally.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, Pydantic, Whisper, Jinja/HTML-to-PDF templates, and Ollama for structured extraction. Python handles notes and audio well; schemas separate suggested billables from approved money fields.

## Architecture/Data Model

Store `clients`, `projects`, `contracts`, `rate_rules`, `meetings`, `source_spans`, `task_candidates`, `billable_decisions`, `invoice_versions`, `line_items`, and `email_drafts`. Calculation consumes only approved tasks and versioned rates.

## Build Slices

1. Notes upload, project selection, action extraction.
2. Evidence-linked candidate review and rate mapping.
3. Invoice calculation, PDF/Markdown export, follow-up draft.
4. Optional transcription and Meet/Stripe adapters.

## Drawbacks/Concerns/Failure Modes

Meetings mix relationship work with billable delivery; action items may lack duration; stale rates create errors; and invoice language can overstate completion. Require explicit quantity approval, surface contract rules, diff invoice versions, and never infer time from speaking duration.

## Clever Hacks and Simpler Alternative

A local command can transform `notes.md` into `billing-review.md`, where the operator checks boxes and enters quantities. Generate the invoice only from checked rows.

## Success Measures

Measure time from meeting to draft, candidate precision, amount corrected before approval, missed billable items found, invoice rejection rate, and user time saved per billing cycle.

## Product Path

Personal consultant tool → agency billing assistant → integrated professional-services workflow. Before team use, meeting connectors, accounting sync, or payments, run [[Scope Expansion Checklist]] for client data, financial records, consent, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#13. Meeting Notes to Invoice]]
- [[Scope Expansion Checklist]]
- [[Invoice Chaser Agent]]

