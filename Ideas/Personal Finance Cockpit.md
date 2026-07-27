---
type: architecture-index
status: active
category: personal finance
tags:
  - finance
  - architecture
  - local-first
---

# Personal Finance Cockpit

This is the shared shell for several independently testable finance projects. It provides navigation, provenance, import jobs, currencies, market calendars, backups, and a model-free calculation library; each tab owns its domain rules and can ship on its own.

## Tabs and Boundaries

| Tab | Project | Primary question | Action level |
|---|---|---|---|
| Balance Sheet | [[Net Worth Command Center]] | What do I own, owe, earn, spend, and how has it changed? | Read, import, reconcile, model scenarios |
| Subscriptions | [[Paisa Vasool Subscriptions]] | Which recurring charges deliver value and what renews next? | Detect, remind, prepare cancellation |
| Market Signals | [[Finance Signals Dashboard]] | What changed in conventional assets and what deserves research? | Read-only research |
| Crypto and Event Markets | [[Event Market Research Terminal]] | What evidence, liquidity, and resolution risk surround a speculative market? | Research and paper decisions only |

## Shared Components

- Immutable import/raw-response store with hashes and timestamps.
- Canonical money, currency, asset, account, merchant, source, and evidence types.
- Reconciliation and idempotent re-import.
- Formula library with golden fixtures.
- Read-only model gateway for document classification and summaries; no model owns arithmetic.
- Local authentication or localhost-only binding, encrypted backups, and redacted demo fixtures.
- One notification policy with previews and quiet hours.
- Export to CSV/Parquet/Markdown so every module remains portable.

## Architecture Choice

Use a modular monorepo, not one database table or one all-powerful “finance agent.” A local web shell can expose four routes, while Python packages such as `finance_core`, `networth`, `subscriptions`, `signals`, and `event_markets` have separate schemas and tests. Start with SQLite/DuckDB and filesystem snapshots; add Postgres only when concurrent writers or a hosted product require it.

## Shared Non-Goals

- No brokerage/exchange credentials.
- No automated trade or cancellation.
- No promises of profit, tax status, or individualized advice.
- No cloud model receives full statements or identity fields by default.
- No metric hides source time, currency, estimate status, or formula version.

## Composition Sequence

1. Build [[Net Worth Command Center]] import and reconciliation primitives.
2. Reuse normalized transactions in [[Paisa Vasool Subscriptions]].
3. Build [[Finance Signals Dashboard]] on a separate market-data store.
4. Add [[Event Market Research Terminal]] only after paper-research and compliance boundaries are stable.
5. Compose the tabs in one shell after each module passes its own acceptance tests.

## Related

- [[First Month Build Program]]
- [[Project Ideas Index]]

