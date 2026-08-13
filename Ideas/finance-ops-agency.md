---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: finance operations
form_factor:
  - local operations dashboard
  - monthly close packet
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#9. Finance Ops Agency]]"
status: concept
tags:
  - invoices
  - cashflow
  - reconciliation
---

# Finance Ops Agency

> A local finance-operations desk that converts exports and documents into a reconciled action queue, cash view, and review-ready monthly memo.

## Product Outcome

Give a freelancer or tiny business one reliable place to see invoices due, cash expected, vendor obligations, reimbursements, unresolved exceptions, and evidence behind the month-end summary. It supports bookkeeping work but does not become the ledger of record or invent accounting treatment.

## User and Core Workflow

The user imports invoice, expense, bank, and reimbursement CSV/PDF fixtures. The system normalizes counterparties and dates, proposes matches, and routes low-confidence items to review. It builds receivable aging, payable calendar, cash projection, and exception lists. The user confirms matches and notes; the app generates a monthly memo and evidence manifest.

## Demo/Personal V0

Use three months of synthetic transactions: 20 invoices, two partial payments, duplicates, one credit note, five receipts, and missing reimbursement proof. Demonstrate matching, exception resolution, a 30-day cash view, and a Markdown close memo.

## Build Boundary

No bank credential connection, payment initiation, tax filing, double-entry posting, payroll, or claim that projected cash is guaranteed. Inputs are exports; all categorization and matches are proposed until confirmed. Financial documents stay local.

## Existing Products, Building Blocks, and Shortcuts

- [InvoicePlane](https://github.com/InvoicePlane/InvoicePlane) already manages invoices, clients, and payments; integrate/export rather than rebuilding invoice authoring.
- [Firefly III](https://github.com/firefly-iii/firefly-iii) provides rules, reports, a double-entry model, and REST API; use it as a ledger/reference if personal finance overlap matters.
- [Actual Budget](https://github.com/actualbudget/actual) demonstrates a local-first finance UX and import workflow.
- [DuckDB](https://duckdb.org/docs/stable/data/csv/overview.html) can query CSV/Parquet directly; `duckdb -c "select * from read_csv_auto('bank.csv') limit 5"` is a useful source smoke test.

## Recommended Free-First Stack

Use Python, Polars, DuckDB/Parquet for transaction analysis, SQLite for review state, FastAPI, and Streamlit. OCRmyPDF/Tesseract handle scanned evidence. Deterministic matching rules precede a local model, which may suggest vendor/category labels and draft the memo with row IDs.

## Architecture/Data Model

Entities: `SourceImport`, `RawRow`, `Counterparty`, `Invoice`, `Payment`, `Expense`, `Receipt`, `MatchProposal`, `ReviewDecision`, `CashScenario`, `Task`, and `MonthlyClose`. Amounts use decimal minor units plus currency; imported rows are immutable and transformations versioned.

## Build Slices

1. Typed CSV import and validation report.
2. Invoice/payment normalization and exact matching.
3. Fuzzy/partial match review queue.
4. Aging, payables, reimbursements, and cash scenarios.
5. Monthly memo with evidence links.
6. Export/backup and rebuild test.

## Drawbacks, Concerns, and Failure Modes

Duplicate exports, timezone/date formats, split/partial payments, taxes, FX, refunds, and owner transfers create ambiguity. A cash forecast can mislead if collections slip. OCR and category suggestions are error-prone. Finance data is highly sensitive, and spreadsheet corrections can break referential identity.

## Clever Hacks and Simpler Alternative

Start with an “exceptions only” report over existing spreadsheets. Exact amount/date/reference matching plus a manual unresolved queue delivers most value. Use three cash scenarios—confirmed, expected, stretch—instead of a single false-precision line.

## Success Measures

- Every summarized amount drills to immutable source rows.
- Exact fixture totals and aging buckets reconcile.
- Duplicate imports are idempotent.
- Uncertain matches never post silently.
- Monthly close time and unresolved-item count decline.

## Product Path

Personal/freelancer use can become a productized monthly finance-ops service. Bank feeds, accounting sync, payments, and tax treatment require stronger controls and professional partnership, added only after the export workflow proves valuable.

## Related

- [[Tax Packet Autopilot]]
- [[Personal Finance Cockpit]]
- [[Compliance Autopilot]]
