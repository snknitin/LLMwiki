---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: personal finance operations
form_factor:
  - local vault dashboard
  - reminder automation
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#26. Renewal Guard]]"
status: concept
---
# Renewal Guard

> Convert forwarded receipts and invoices into a reviewable vault of renewals, warranties, deadlines, and next actions.

## Product Outcome

Prevent surprise renewals and lost warranty windows. The user sees upcoming dates, expected cost, confidence, original evidence, cancellation/claim notes, and reminders in one private place.

## User and Core Workflow

Upload or forward a receipt/email, inspect OCR/extraction, and confirm merchant, item, amount, start date, renewal or warranty date, and reminder policy. The system deduplicates records, creates reminders, and surfaces a monthly review. Claim/cancel instructions remain source-linked notes.

## Demo/Personal V0

Import 20 sample PDFs/images/emails manually. Support subscriptions and product warranties, confidence highlighting, original-file preview, calendar export, and local notifications. Avoid mailbox-wide access.

## Build Boundary

Include file/email import, OCR, typed extraction, correction, deduplication, reminders, status history, and export. Exclude bank scraping, autonomous cancellation, claims submission, app-store account access, purchasing, and financial advice.

## Existing Products, Building Blocks, and Shortcuts

- [Tesseract](https://github.com/tesseract-ocr/tesseract) provides local OCR for scanned receipts.
- [Gmail OAuth scopes](https://developers.google.com/workspace/gmail/api/auth/scopes) explain why forwarded messages are a simpler first boundary than mailbox access.
- [Apple App Store Server API](https://developer.apple.com/documentation/appstoreserverapi) exposes subscription data for a developer’s own app customers, not a universal consumer vault.
- [Google Play subscriptionsv2](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2) has the same app-developer limitation.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, Tesseract/Docling, APScheduler, local notifications, and Ollama for structured extraction. Python handles documents and dates; SQLite is portable; a review queue prevents bad OCR from silently creating reminders.

## Architecture/Data Model

Store `documents`, `document_hashes`, `merchants`, `assets`, `contracts`, `date_events`, `amounts`, `extractions`, `corrections`, `reminders`, and `actions`. Each field records source coordinates and confidence. Deduplication uses document hashes plus merchant/date/amount.

## Build Slices

1. Upload, OCR, review form, and record vault.
2. Renewal/warranty schemas, dedupe, dashboard.
3. Reminder scheduler, calendar export, monthly review.
4. Optional dedicated forwarding inbox and claim/cancel notes.

## Drawbacks/Concerns/Failure Modes

OCR date errors, confusing trial versus renewal dates, duplicates, expired instructions, and sensitive invoices create risk. Highlight low confidence, require date confirmation, preserve originals, encrypt local storage, and link actions to current merchant sources.

## Clever Hacks and Simpler Alternative

Start with a special email folder users manually export once a week. Even a command that produces `renewals.ics` plus a Markdown vault can prove the value before inbox integration.

## Success Measures

Track extraction correction rate, duplicate rate, reminders acknowledged, unwanted renewals prevented, warranty actions completed, false/missed reminders, and monthly review time.

## Product Path

Personal renewal vault → open-source receipt-to-calendar tool → consumer subscription/warranty product. Before mailbox access, cloud sync, multi-user sharing, or payments, run [[Scope Expansion Checklist]] for financial documents, security, provider terms, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#26. Renewal Guard]]
- [[Scope Expansion Checklist]]

