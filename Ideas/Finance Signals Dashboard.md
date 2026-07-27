---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#5. Finance Signals Dashboard]]"
status: concept
difficulty: medium
priority: urgent
urgency: personal-beta-by-2026-08-27
category: financial research
form_factor:
  - local dashboard
  - dated Markdown brief
deployment: local-first
source_ideas:
  - finance signals dashboard
tags:
  - finance
  - markets
  - watchlist
  - evidence
---

# Finance Signals Dashboard

> A read-only personal dashboard for conventional investment signals—equities, funds, rates, commodities, and macro context—where every signal shows freshness, source, formula, and counterevidence.

## Product Outcome

The dashboard should answer “what changed in assets I deliberately follow, is the change unusual, what primary information may explain it, and what should I investigate?” It is a research triage tool, not an oracle or trading system.

## Personal V0

- Maintain a small watchlist with asset type, currency, thesis, expected catalyst, benchmark, and review cadence.
- Ingest permitted end-of-day or delayed market data and cache raw responses.
- Calculate transparent signals: daily/weekly return, moving averages, drawdown, rolling volatility, relative strength to a chosen benchmark, and volume anomaly where available.
- Attach first-party filings, exchange/company notices, central-bank releases, or manually reviewed evidence.
- Generate one signal card per asset with formula, observation timestamp, data gaps, and strongest reason the signal may be misleading.
- Produce a dated morning/evening Markdown brief and retain later outcome labels.
- Keep alerts disabled until the dashboard has a low-noise track record.

## Build Boundary

**MVP:** ten assets, one or two documented data sources, end-of-day updates, five deterministic signals, evidence links, and no predictions.

**Later:** intraday feeds, options, fundamentals, portfolio exposure, alert policies, event studies, and paid licensed data. Crypto and prediction markets remain a separate high-risk module in [[Event Market Research Terminal]].

### Month-One Personal Beta

Week one builds the watchlist, raw-data cache, provenance fields, and five formula tests using fixed fixtures. Run the brief every market day for three weeks; label useful/noisy/misleading cards and record missing/corrected data. Only add a signal when it has a plain-language hypothesis, unit test, and observation plan. The month closes with a source outage drill, stale-data behavior, and a reproducible history rebuild.

## Existing Products, Building Blocks, and Shortcuts

- TradingView, Koyfin, and broker dashboards are product references for charts/watchlists; your differentiator is a small evidence inbox, transparent formulas, feedback, and local reproducibility.
- The SEC offers keyless [EDGAR submissions/XBRL APIs](https://www.sec.gov/search-filings/edgar-application-programming-interfaces), while SEBI links official [NSE/BSE corporate filings](https://www.sebi.gov.in/curation/corporate_filings.html) and RBI provides [DBIE macro data](https://dbie.rbi.org.in/). These are better evidence anchors than generic news summaries.
- [DuckDB](https://duckdb.org/), Polars, Parquet, and Streamlit cover local time-series analysis and an inspectable dashboard. `duckdb -c \"select * from read_csv_auto('prices.csv') limit 5\"` is a useful ingestion smoke test.
- Simplest alternative: broker-exported CSV + official event calendar + generated Markdown brief. Add live/paid data only when delayed/manual inputs cause a measured missed decision.

## Free-First Stack

- **Fastest dashboard:** Streamlit plus Plotly/ECharts for personal use; migrate to SvelteKit only if interaction demands it.
- **Pipeline:** Python, Polars/Pandas, and scheduled jobs.
- **Data:** DuckDB/Parquet for price history; SQLite for watchlists, sources, annotations, and feedback.
- **Sources:** official exchange/company/central-bank documents where practical; free data only after checking license, delay, and redistribution terms.
- **Models:** optional local model for summarizing linked documents; never calculate indicators or infer missing prices.
- **Exports:** Markdown plus CSV/Parquet snapshots.

## Signal Contract

Each card includes `formula_version`, input series, source, market timezone, adjusted/unadjusted status, currency, latest valid timestamp, missing-value policy, threshold rationale, and feedback. A stale source disables the card rather than carrying yesterday’s value forward invisibly.

## Clever Hacks and Simpler Alternative

- Start with end-of-day CSV downloads and a manual primary-source link inbox; the insight loop matters more than live feeds.
- Separate “observation” from “interpretation.” The deterministic engine detects a 20-day breakout; the human or grounded model proposes possible explanations.
- Compare every asset to a consciously chosen benchmark so broad market moves do not look asset-specific.
- Use a daily top-three budget. Even correct signals become noise when twenty cards demand attention.
- Store raw data snapshots and rebuild derived tables; never make a chart the only record.

## Build Slices

1. Watchlist and source/market-calendar metadata.
2. Raw ingestion cache with validation.
3. Indicator library with golden fixtures.
4. Signal cards and chart views.
5. Evidence inbox and dated Markdown brief.
6. Feedback/noise tracking and threshold calibration.
7. Optional alerts and paid data evaluation.

## Battle-Testing Gates

- Indicator outputs match a separately calculated fixture.
- Split/dividend adjustments and timezone boundaries are tested.
- Stale, missing, duplicated, and revised data fail visibly.
- The same raw snapshot rebuilds the same brief.
- Three weeks of feedback demonstrate a manageable signal count.
- No view implies personalized financial advice or expected profit.

## Product Path

Keep this as a personal research tab until its data licenses and formulas are stable. A future product can be a “bring your own data” evidence-first dashboard, while real-time/licensed feeds and regulated advice remain separate commercial decisions.

## Related

- [[Personal Finance Cockpit]]
- [[Net Worth Command Center]]
- [[Paisa Vasool Subscriptions]]
- [[Event Market Research Terminal]]
- [[First Month Build Program]]
- [[Project Ideas Index]]
