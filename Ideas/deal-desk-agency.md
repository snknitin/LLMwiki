---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: sales operations
form_factor:
  - local web app
  - document workflow
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#2. Deal Desk Agency]]"
status: concept
---
# Deal Desk Agency

> Turn messy proposal notes into a defensible scope, quote, negotiation brief, and delivery handoff without letting a model invent commercial terms.

## Product Outcome

Compress the hours between a sales call and a ready-to-review proposal. The output is a linked deal packet: assumptions, scope, exclusions, priced line items, risks, negotiation responses, approval status, and delivery checklist.

## User and Core Workflow

The operator imports notes, client facts, a service catalog, rate card, and contract preferences. The system extracts requirements, flags missing inputs, maps work to approved line items, calculates totals deterministically, and generates documents. A review screen shows every output beside its source and rule before export.

## Demo/Personal V0

Use three historical deals and a CSV price book. Generate Markdown plus PDF packets and compare them with the real proposals. Add an “aggressive / balanced / protective” negotiation-tone selector but never alter price rules automatically.

## Build Boundary

Include intake, structured extraction, price calculation, risk checklist, versioned drafts, and export. Exclude e-signature, payment collection, contract-law advice, CRM synchronization, and autonomous sending.

## Existing Products, Building Blocks, and Shortcuts

- [Stripe Quotes](https://docs.stripe.com/api/quotes) supplies a proven quote-to-invoice state model.
- [HubSpot quotes](https://developers.hubspot.com/docs/api-reference/legacy/crm/objects/quotes/guide) shows how deals, line items, templates, and quotes associate.
- [PandaDoc document details](https://developers.pandadoc.com/reference/document-details) provides a reference for recipients, tables, totals, approvals, and status.
- [Gmail drafts](https://developers.google.com/workspace/gmail/api/guides/sending) can later stage the client email without auto-sending.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite with Drizzle, Zod schemas, Markdown templates, Playwright PDF export, and Ollama for extraction/drafting. Type-safe schemas protect money fields; SQL makes revisions auditable; deterministic templates are easier to test than generated layouts.

## Architecture/Data Model

Model `clients`, `deals`, `source_notes`, `requirements`, `assumptions`, `catalog_items`, `quote_versions`, `line_items`, `risks`, `approvals`, and `handoff_tasks`. A pipeline separates extraction, rule evaluation, calculation, prose generation, and rendering. Every generated claim stores a source span or “operator supplied” label.

## Build Slices

1. Notes-to-requirements intake and missing-information checklist.
2. Price-book mapping, calculator, and versioned quote.
3. Risk memo, negotiation cards, handoff plan, and PDF export.
4. Optional draft-email and CRM adapters.

## Drawbacks/Concerns/Failure Modes

Ambiguous scope creates false precision; stale price books corrupt margins; legal-sounding prose may be trusted; and revision histories can drift. Block export on unresolved required fields, timestamp catalogs, distinguish suggestions from approved terms, and diff every version.

## Clever Hacks and Simpler Alternative

A folder of YAML service packages plus a command such as `deal build notes.md --package workshop` can validate the transformation before a web UI. Use the model only to map notes into the fixed schema.

## Success Measures

Measure time to first reviewable packet, unresolved-question count, pricing corrections, scope-change rate after handoff, operator acceptance, and gross-margin variance from the approved quote.

## Product Path

Personal sales toolkit → boutique agency workspace → governed deal desk product. Before public release, multi-user use, e-signature, or payments, run [[Scope Expansion Checklist]] for legal text, data rights, integrations, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#2. Deal Desk Agency]]
- [[Scope Expansion Checklist]]
- [[Conversion List Builder]]
