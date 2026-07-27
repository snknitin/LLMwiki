---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#5. Finance Signals Dashboard]]"
status: concept
difficulty: hard
priority: p3
category: financial research
form_factor:
  - local dashboard
  - alert bot
deployment: desktop plus DGX Spark
source_ideas:
  - crypto moonshots in 24 hours and Polymarket bot using social chatter and due diligence
tags:
  - crypto
  - prediction-markets
  - research
  - high-risk
---

# Event Market Research Terminal

> A research-only terminal that compares event-market prices and crypto narratives with primary evidence, liquidity, timing, and source quality—without promising moonshots or autonomously placing trades.

## Product Outcome

For a selected market or token, the system builds a timestamped evidence dossier: market question and resolution rules, current price, liquidity/spread, catalysts, primary sources, counterarguments, social narrative changes, and what observation would falsify the thesis.

## Personal V0

- Manually add a market/token and define the exact decision question.
- Fetch permitted public market data and record snapshots.
- Ingest a curated set of official announcements, filings, code/release activity, and selected social sources.
- Separate first-party facts, reputable reporting, analyst inference, and anonymous chatter.
- Detect repeated narratives and likely copy amplification.
- Generate bull, bear, base, and “cannot know” cases.
- Log a paper decision before the outcome and score calibration later.
- Alert only when a predeclared evidence condition changes.

## Build Boundary

**MVP:** one market type, read-only data, paper portfolio, manual watchlist, and evidence-linked brief.

**Not in v0:** keys capable of trading, leverage, automated execution, “24-hour moonshot” claims, personalized investment advice, or copying unverified social calls. Jurisdiction, platform eligibility, and tax treatment must be checked before any real use.

## Existing Products, Building Blocks, and Shortcuts

- Polymarket exposes unauthenticated [market-data endpoints](https://docs.polymarket.com/market-data/fetching-markets) and separate authenticated trading layers; keep only read endpoints in the research process.
- [Kalshi’s API](https://docs.kalshi.com/welcome), CoinGecko’s API, and [CCXT](https://github.com/ccxt/ccxt) are implementation references for market schemas. None replaces recording resolution rules, spread, liquidity, source time, and a paper thesis.
- Dune-style dashboards and prediction-market terminals show charts; the personal edge is frozen evidence/probability snapshots and later calibration/Brier scoring.
- Simplest alternative: user-entered market question + current price + exact resolution text + Tier A/B evidence links + paper probability. No wallet, exchange key, or social sentiment is needed to test whether research improves.

## Free-First Stack

- **Pipeline:** Python/FastAPI with scheduled n8n jobs.
- **Data:** Postgres/Timescale-style schema or DuckDB/Parquet for snapshots; SQLite is fine for paper research.
- **Analysis:** deterministic return/liquidity/calibration math; source graph and event timeline.
- **Models:** local model for claim extraction and contradiction search; paid model only for long document comparison.
- **Dashboard:** local Streamlit for fastest iteration, then SvelteKit.
- **Security:** no exchange wallet/private keys in the research environment.

## Anti-Hype Design

The terminal always shows base rate, liquidity, time-to-resolution, and strongest disconfirming evidence before social sentiment. A source cannot become “three signals” simply because it was reposted three times. Backtests use time-correct data to prevent look-ahead bias.

## Build Slices

1. Watchlist, market-question schema, and snapshot store.
2. Primary-source ingestion and claim ledger.
3. Narrative clustering and provenance graph.
4. Scenario brief and paper-decision journal.
5. Calibration dashboard and precondition alerts.
6. Only after long paper validation: separate, tightly limited execution experiment.

## Success Measures

- Claims remain traceable to timestamped sources.
- Paper forecasts become better calibrated over a meaningful sample.
- Alerts correspond to predeclared evidence, not price noise.
- Backtests account for fees, spread, liquidity, and data availability time.
- The system makes uncertainty more visible.

## Product Path

The credible product is an evidence and due-diligence workspace, not a signal-selling bot. A paid research product may serve sophisticated users, but compliance, data licensing, and harm from overconfidence are central costs.

## Related

- [[Side-Hustle Radar]]
- [[Net Worth Command Center]]
- [[Personal Signal Intelligence OS]]
- [[Project Ideas Index]]
