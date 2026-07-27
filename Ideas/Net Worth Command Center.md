---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#12. Net Worth Command Center]]"
status: concept
difficulty: medium
priority: urgent
urgency: personal-beta-by-2026-08-27
category: personal finance
form_factor:
  - local dashboard
deployment: local-first
source_ideas:
  - net worth, total compensation, assets, percentile, mentor, budget, and asset analysis
tags:
  - finance
  - privacy
  - dashboard
---

# Net Worth Command Center

> A private financial cockpit that consolidates assets, liabilities, cash flow, total compensation, and decision scenarios without selling data or pretending uncertain market estimates are facts.

## Product Outcome

The dashboard should make the household balance sheet understandable: current net worth, liquidity, concentration, recurring burn, runway, goal progress, compensation components, and decisions that change the trajectory. Percentiles are optional context, never a score of personal worth.

## Personal V0

- Import CSVs from banks, brokers, salary statements, loans, and manual assets.
- Normalize accounts and transactions while preserving the original import.
- Track assets, liabilities, vesting schedules, recurring income/expense, and valuation date.
- Show net worth over time, liquid versus illiquid share, asset concentration, and monthly cash flow.
- Model scenarios such as a job change, purchase, investment contribution, or market drawdown.
- Attach evidence and confidence to manually valued assets.
- Generate a monthly Markdown financial review with anomalies and questions.

## Build Boundary

**MVP:** manual CSV import, local encrypted database, account reconciliation, net-worth chart, and scenario calculator.

**Later:** supported account aggregators, tax lots, benchmark percentiles, compensation comparisons, and mentor matching. Avoid trade execution, tax advice, credit decisions, or personalized investment recommendations without appropriate controls.

### Month-One Personal Beta

Create the canonical account/asset/liability schema, manual balances, and one real CSV adapter first. Reconcile three historical snapshots, test duplicates, signs, currencies, missing rows, stale valuations, and re-import idempotence. Add total-compensation and scenario views only after the balance sheet matches source statements. The beta includes encrypted backup/restore and a month-end reconciliation checklist.

## Existing Products, Building Blocks, and Shortcuts

- [Actual Budget](https://github.com/actualbudget/actual) and [Firefly III](https://github.com/firefly-iii/firefly-iii) are mature self-hosted personal-finance products. Evaluate whether a custom dashboard can consume/export their data before recreating budgeting and transaction rules.
- [Beancount](https://beancount.github.io/docs/) and [hledger](https://hledger.org/) provide plain-text double-entry ledgers and command-line reports; `hledger balance` or `bean-report` can be the boring correctness baseline for asset/liability totals.
- [DuckDB](https://duckdb.org/) plus Parquet/CSV is ideal for local statement analysis, while Plotly/ECharts can render views. Financial aggregators such as Plaid are a later convenience, not necessary for personal CSV imports.
- Simplest alternative: monthly balances in a ledger/CSV plus a generated Markdown report. Build account connectors only after manual reconciliation becomes the dominant cost.

## Free-First Stack

- **Dashboard:** local Streamlit for fastest learning, or SvelteKit for a durable product.
- **Data:** SQLite/DuckDB plus Parquet snapshots; SQLCipher or application-level field encryption for sensitive values.
- **Ingestion:** per-institution CSV adapters with fixture tests; double-entry ledger model if transaction depth grows.
- **Analysis:** Polars/Pandas and deterministic finance formulas.
- **Models:** optional local model for merchant/category suggestions and document extraction, never for arithmetic or unsourced recommendations.
- **Charts:** Observable Plot, ECharts, or Plotly.

## Data Contract

Separate `Account`, `Holding`, `Transaction`, `Liability`, `CompensationGrant`, `Valuation`, and `Scenario`. Every imported row retains source file hash and reconciliation state. Market values show quote time and currency; percentile datasets show source year and population.

## Build Slices

1. Canonical account/valuation schema and manual balances.
2. CSV importer with reversible mapping.
3. Historical net-worth and cash-flow views.
4. Reconciliation and anomaly checks.
5. Compensation/vesting timeline and scenarios.
6. Optional read-only data connectors.

## Success Measures

- Balance sheet reconciles to source statements.
- A monthly update takes under twenty minutes.
- Stale or estimated values are visibly different from verified values.
- Scenario calculations are testable outside the UI.
- No financial data leaves the machine without explicit export.

## Product Path

Keep the personal build local. An eventual product can be a paid-once privacy-first desktop finance app, an adviser collaboration export, or an open-source data model. Aggregation licensing and support become the expensive part of a consumer product.

## Related

- [[Paisa Vasool Subscriptions]]
- [[Event Market Research Terminal]]
- [[Measure Life]]
- [[Project Ideas Index]]
