---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: market-briefing
form_factor:
  - scheduled local pipeline
  - messaging card
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#10. Market Mood Cards]]"
status: concept
tags: [markets, news, briefing]
---

# Market Mood Cards

> A pre-market card with verified price moves, contemporaneous headlines, and one watch item—without claiming headlines caused the move.

## Product Outcome

At a scheduled time, the tool calculates selected index/asset moves, retrieves recent sourced headlines, writes a short neutral context summary, and sends a compact card to Telegram. The audit view retains raw numbers, timestamps, and links.

## User and Core Workflow

1. Configure watchlist, market timezone, and briefing time.
2. Fetch/calculate changes using cached price series.
3. Query recent relevant headlines and deduplicate.
4. Local model summarizes only selected headlines and labels uncertainty.
5. Render/send card and save the evidence bundle.

## Demo/Personal V0

One index plus BTC, three GDELT headlines, local summary, HTML/PNG card, and manual run. Add scheduling only after the card is trustworthy.

## Build Boundary

**MVP:** small watchlist, deterministic price calculations, sourced headlines, no causal claim, local archive, Telegram output.

**Out:** trading signals, forecasts, order execution, personalized advice, unsourced sentiment score, WhatsApp Channel publishing, or real-time terminal.

## Existing Products, Building Blocks, and Shortcuts

- [Alpha Vantage](https://www.alphavantage.co/documentation/) provides time-series/market utilities for a limited prototype.
- [GDELT data](https://www.gdeltproject.org/data.html) and the [DOC 2.0 API](https://blog.gdeltproject.org/gdelt-doc-2-0-api-debuts/) provide open, frequently updated global news discovery.
- [APScheduler](https://github.com/agronholm/apscheduler) or Cloudflare [Cron Triggers](https://developers.cloudflare.com/workers/configuration/cron-triggers/) runs the briefing.
- [Telegram Bot API](https://core.telegram.org/bots/api) and [Satori](https://github.com/vercel/satori) handle delivery/card rendering.

## Free-First Stack

Python + Polars + SQLite + GDELT + limited/cached price data + Ollama + APScheduler + Satori/resvg + Telegram. Compute all numbers in code.

## Architecture/Data Model

`Asset`, `PriceObservation`, and `MoveCalculation` retain source/time/rule. `Headline` stores URL, publisher, timestamp, and query. `BriefingIssue` references selected evidence and generated text. `DeliveryReceipt` prevents duplicates.

## Build Slices

1. Price adapters and move calculations.
2. GDELT query/dedup.
3. Evidence-constrained summary.
4. Card, archive, and scheduler.

## Drawbacks/Concerns/Failure Modes

- Contemporaneous news does not prove causality.
- Free feeds have latency, quotas, and licensing/attribution rules.
- Market holidays/timezones break naïve comparisons.
- LLM summaries may overstate; retain neutral templates and source links.

## Clever Hacks and Simpler Alternative

Publish “moves + three headlines + one watch item” with no mood score. A static watchlist and cached daily close data are enough for a useful personal morning brief.

## Success Measures

- Every number and headline is traceable.
- Card arrives on schedule without duplicates.
- Stale/missing feeds visibly degrade to “unavailable.”
- No predictive or causal claim appears.

## Product Path

Personal Telegram brief → multiple watchlists → analyst-curated newsletter → paid market briefing. Expansion needs market/news data licenses, financial-claims review, and delivery costs.

## Related Wikilinks

- [[latte-into-lambo|Latte into Lambo]]
- [[competitive-intelligence-agency|Competitive Intelligence Agency]]

