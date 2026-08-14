---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: personal finance document automation
form_factor:
  - local document dashboard
  - accountant handoff generator
deployment: encrypted local workstation
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#25. Tax Packet Autopilot]]"
status: concept
tags:
  - tax
  - invoices
  - ocr
  - india
---

# Tax Packet Autopilot

> A local evidence desk that finds user-authorized invoices and receipts, extracts reviewable fields, detects missing periods, and assembles a clean CA handoff—without calculating liability or filing returns.

## Product Outcome

Replace the annual scramble of folders and email search with an indexed, deduplicated document packet. Every extracted amount, GSTIN, date, and category remains linked to the original page and confidence so the user or chartered accountant can correct it.

## User and Core Workflow

1. Define financial year, entities, accounts, GST registrations, and document sources.
2. Import selected mailbox search results and local folders in read-only mode.
3. Classify documents, detect duplicates/credit notes, and OCR scanned pages.
4. Extract vendor, invoice number/date, taxable value, GST breakup, total, currency, and payment clues.
5. Review low-confidence fields and category suggestions against the page image.
6. Reconcile months/vendors, flag gaps and duplicates, and draft missing-document requests.
7. Export originals, normalized CSV/XLSX, exception list, and manifest for the CA.

## Demo/Personal V0

Use 30 redacted or synthetic Indian invoices and receipts from a local folder. Generate searchable previews, extraction/confidence fields, a duplicate report, month coverage, and a zip/manifest. Do not connect email, calculate tax, or contact clients.

## Build Boundary

- In scope: user-owned files, selected Gmail metadata/attachments later, OCR, extraction, review, deduplication, categorization suggestions, gap detection, and handoff exports.
- Out of scope: tax advice, eligibility decisions, return preparation, portal login, filing, payment, or autonomous client messages.
- Originals are immutable; corrections live as separate versioned records.
- Encrypt sensitive local data, redact logs, and make deletion/export explicit.

## Existing Products, Building Blocks, and Shortcuts

- [Gmail API guides](https://developers.google.com/workspace/gmail/api/guides) support narrowly scoped user-authorized searches and attachment retrieval later.
- [OCRmyPDF](https://github.com/ocrmypdf/OCRmyPDF) adds searchable text layers while preserving scanned PDFs.
- [Tesseract OCR](https://tesseract-ocr.github.io/) is a free local OCR baseline for images and mixed scripts.
- [GST e-invoice schema](https://einvoice6.gst.gov.in/content/notified-e-invoice-schema/) provides official Indian invoice-field terminology and structures.
- [GSTR-1 guidance](https://tutorial.gst.gov.in/userguide/returns/GSTR_1.htm) and the [Income Tax portal](https://www.incometax.gov.in/iec/foportal/) are references for the accountant-facing context, not APIs to automate filing.

## Recommended Free-First Stack

- Python, FastAPI, Pydantic, SQLite/SQLCipher, and Polars.
- OCRmyPDF plus Tesseract; PyMuPDF for page rendering and text/coordinate extraction.
- Rules for GSTIN, invoice totals, dates, and tax arithmetic; a local vision/language model only for difficult layouts.
- Streamlit for side-by-side field review and confidence filters.
- openpyxl and zipfile for a deterministic accountant packet with checksums.

Rules should validate model extraction: CGST/SGST/IGST relationships and subtotal arithmetic catch errors more reliably than prose confidence.

## Architecture/Data Model

`tax_period` owns `source`, `document`, `file_hash`, `page`, `ocr_run`, `invoice`, `field_observation`, `field_correction`, `vendor`, `category`, `duplicate_group`, `exception`, and `export_manifest`. Store original files in content-addressed local storage; the database references immutable hashes and records parser/model versions.

## Build Slices

1. Folder importer, hashing, document viewer, and OCR pipeline.
2. Invoice schema extraction with bounding boxes, rules, and confidence.
3. Review queue, vendor normalization, duplicate/credit-note handling.
4. Period coverage, exception report, categorization suggestions, and totals.
5. CA-ready CSV/XLSX/zip manifest, then optional Gmail adapter and reminder drafts.

## Drawbacks, Concerns, and Failure Modes

- OCR can confuse decimal separators, dates, GSTINs, and tax columns.
- Duplicate invoices and credit notes can inflate totals if treated naively.
- Categorization and input-credit eligibility require professional judgment.
- Mailbox access creates a large privacy and security surface.
- Tax forms and rules change, and a neat packet can still contain incomplete records.

## Clever Hacks and Simpler Alternative

- Start from a local “Tax Inbox” folder populated manually throughout the year.
- Use perceptual page hashes plus vendor/invoice/amount keys for duplicate candidates.
- Highlight arithmetic mismatches before applying a model.
- Export an exception-first workbook so the CA reviews uncertainty, not every row.
- Simplest alternative: a folder watcher that renames, hashes, OCRs, and indexes documents without tax categorization.

## Success Measures

- 100% of exported rows link to an immutable original document and page.
- High-confidence test fields achieve a chosen accuracy threshold on a labeled fixture.
- No known duplicate fixture is counted twice.
- Low-confidence, arithmetic-mismatch, and missing-period items are always surfaced.
- A user can assemble and review a 30-document packet in under 30 minutes.

## Product Path

Use it locally for one person and collaborate with a CA on the export format. Later add reusable vendor mappings, monthly inbox checks, accountant portals, and jurisdiction-specific schemas. A commercial release needs strong encryption, backups, consented mailbox scopes, professional disclaimers, and ongoing regulatory maintenance.

## Related

- [[finance-ops-agency|Finance Ops Agency]]
- [[Net Worth Command Center]]
- [[PhoneScan PDF]]
