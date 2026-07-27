---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: prediction-market research
form_factor:
  - local research dashboard
  - paper forecast journal
deployment: local-first read-only
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#8. Edge Desk]]"
status: concept
tags:
  - prediction-markets
  - evidence
  - forecasting
---

# Edge Desk

> A read-only prediction-market research desk that treats prices as noisy evidence, makes resolution risk visible, and trains forecasting skill without moving money.

## Product Outcome

Help the user notice material probability shifts, inspect liquidity and rules, gather primary evidence, record a personal forecast, and evaluate calibration after resolution. The product is valuable if it improves research discipline—not if it generates sensational “edge” alerts.

## User and Core Workflow

The user follows a small list of questions. Scheduled jobs snapshot price, bid/ask, spread, volume, close date, and resolution rules. A detector flags moves only when liquidity/freshness thresholds pass. The user reviews linked evidence, records probability/confidence and falsifiers, and optionally opens a paper position. At resolution the system computes Brier score and compares the forecast with market close.

## Demo/Personal V0

Track five public markets with cached fixtures or public read endpoints for one week. Show one price/liquidity alert, one ambiguous-resolution warning, a frozen evidence bundle, and a calibration report. No wallet, exchange account, or API secret capable of trading.

## Build Boundary

No execution, wallet connection, private-key handling, VPN circumvention, insider-source ingestion, profit claims, copy trading, or personalized financial advice. Location/eligibility rules are checked on the provider’s current page. News summaries must link to first-party evidence where available.

## Existing Products, Building Blocks, and Shortcuts

- Polymarket documents public [market fetching](https://docs.polymarket.com/market-data/fetching-markets), while its [authentication](https://docs.polymarket.com/api-reference/authentication) shows the separate wallet/API layers required for trading.
- Polymarket’s [geographic restrictions](https://help.polymarket.com/en/articles/13364163-geographic-restrictions) are a live eligibility source and explicitly reject circumvention.
- [Kalshi API](https://docs.kalshi.com/welcome) is a second market-data/product reference; do not normalize different resolution contracts as interchangeable.
- DuckDB and [Polars](https://docs.pola.rs/) make timestamped snapshots and replay cheap; use them before adding streaming infrastructure.

## Recommended Free-First Stack

Use Python/httpx/Pydantic, Polars, DuckDB/Parquet, APScheduler, and Streamlit/Plotly. Cache raw JSON and response timestamps. Use a local model to summarize evidence with URLs, never to calculate prices or invent causal explanations. Markdown forecast notes make the simplest durable journal.

## Architecture/Data Model

Core records: `Venue`, `Market`, `ResolutionRuleVersion`, `Snapshot`, `OrderBookSummary`, `EvidenceItem`, `Alert`, `Forecast`, `PaperPosition`, `Resolution`, and `Score`. Store venue/market timezone, units, raw payload hash, retrieval time, and licence note. Forecasts are append-only once locked.

## Build Slices

1. Five-market watchlist and raw snapshot cache.
2. Spread/liquidity/freshness normalization.
3. Material-change alerts and resolution ambiguity rubric.
4. Evidence notebook and forecast lock.
5. Paper positions and outcome scoring.
6. Replay evaluation against simple baselines.

## Drawbacks, Concerns, and Failure Modes

Thin markets, spoofing, provider outages, stale books, fees, and ambiguous contracts distort displayed probabilities. Correlated news feeds create false confidence. Backtests suffer selection and hindsight bias. Legal/eligibility rules vary by location and change. Alerting can encourage compulsive checking.

## Clever Hacks and Simpler Alternative

Use end-of-day CSV snapshots and one daily brief. Alert on probability change plus spread/volume improvement rather than price alone. Require “what would change my mind?” before saving a forecast and hide P&L until the calibration review.

## Success Measures

- Every alert shows freshness, spread, liquidity, and exact rule version.
- Forecast history is immutable and scores reproducibly.
- Ambiguous/illiquid markets are suppressed.
- Zero credentials capable of placing orders.
- Weekly alert volume stays within the user’s attention budget.

## Product Path

Keep it as a personal forecasting laboratory. A paid research feed would require market-data licences, regulated-product review, rigorous provenance, conflicts disclosure, and a separate security architecture; trading remains out of scope.

## Related

- [[Finance Signals Dashboard]]
- [[Event Market Research Terminal]]
- [[Personal Signal Intelligence OS]]
