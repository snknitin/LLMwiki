---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: accounts receivable
form_factor:
  - local dashboard
  - draft messaging agent
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#9. Invoice Chaser Agent]]"
status: concept
---
# Invoice Chaser Agent

> A calm accounts-receivable cockpit that calculates what is due, drafts context-aware reminders, and stops when payment or dispute evidence appears.

## Product Outcome

Reduce overdue cash and the emotional burden of follow-up. The user sees aging, cash at risk, next action, conversation history, and reviewable reminder drafts in one place.

## User and Core Workflow

Import invoice rows and optional message history. The system normalizes customers, computes due states, applies a user-defined cadence, and drafts a message whose tone escalates gradually. The user approves, edits, or snoozes it and records replies, promises, disputes, or payment.

## Demo/Personal V0

Use a CSV with ten synthetic invoices and a simulated email inbox. Generate due-soon, overdue, and final-check drafts; show a calendar and aging summary. Require a click before every send and manual payment confirmation.

## Build Boundary

Include invoice import, deterministic status, cadence rules, drafts, timeline, promise tracking, and stop conditions. Exclude collections activity, late-fee calculation, accounting write-back, legal threats, autonomous sending, and bank monitoring.

## Existing Products, Building Blocks, and Shortcuts

- [Stripe Invoices](https://docs.stripe.com/api/invoices) offers a reference lifecycle for draft, finalized, sent, and paid invoices.
- [Gmail sending and drafts](https://developers.google.com/workspace/gmail/api/guides/sending) supports a review-first outbound path.
- [WhatsApp message templates](https://developers.facebook.com/docs/whatsapp/business-management-api/message-templates) can carry later approved reminders.
- [SQLite](https://www.sqlite.org/docs.html) replaces a hosted database for one operator’s ledger and history.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, Pandas or Polars for imports, APScheduler, Jinja templates, and Ollama for constrained rewriting. Python is strong for CSV/date workflows; money and cadence remain ordinary code; the model only adapts a validated template.

## Architecture/Data Model

Store `customers`, `invoices`, `payments`, `message_threads`, `drafts`, `cadence_rules`, `promises`, `disputes`, and `actions`. A state machine derives `due_soon`, `overdue`, `promised`, `disputed`, `paid`, or `paused`; only eligible states may create a draft.

## Build Slices

1. CSV import, aging view, and status correction.
2. Template library, draft queue, and action log.
3. Reply/promise/dispute handling and scheduled review.
4. Optional Gmail/WhatsApp and accounting adapters.

## Drawbacks/Concerns/Failure Modes

Wrong balances or recipients damage trust; duplicate reminders annoy customers; disputes need human judgment; and time zones affect due dates. Require reconciliation, deduplicate by state/version, halt on replies, and preview recipient, amount, currency, and evidence.

## Clever Hacks and Simpler Alternative

A daily CLI that reads `invoices.csv` and writes an “approve these five drafts” Markdown file can validate cadence and tone before any messaging integration.

## Success Measures

Track overdue amount, median days to payment, drafts accepted unchanged, duplicate/incorrect reminder count, promises kept, user time per weekly review, and disputes caught before follow-up.

## Product Path

Personal freelancer tool → small-agency receivables assistant → integrated AR product. Before multi-user use, live sending, accounting sync, or payments, run [[Scope Expansion Checklist]] for financial data, consent, channel terms, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#9. Invoice Chaser Agent]]
- [[Scope Expansion Checklist]]
- [[finance-ops-agency|Finance Ops Agency]]
