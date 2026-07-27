---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: financial-visualization
form_factor:
  - local calculator
  - shareable card
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#9. Latte into Lambo]]"
status: concept
tags: [finance, counterfactual, data]
---

# Latte into Lambo

> A transparent price-only counterfactual: “If this recurring spend had bought an asset, what would the historical nominal value be?”

## Product Outcome

Choose a recurring spend, cadence, date range, and supported comparison asset. The app calculates contributions and historical price-only value, shows assumptions, and produces a humorous card. It must not imply that users should stop small pleasures or that hindsight equals advice.

## User and Core Workflow

1. Enter amount/cadence/currency and select asset/date range.
2. Map each contribution date to a documented market-price rule.
3. Calculate units purchased, current/horizon value, and total contributions.
4. Display missing dates, fees/taxes/dividends exclusions, source, and sensitivity.
5. Export a card labeled hypothetical.

## Demo/Personal V0

BTC-only with cached CoinGecko monthly prices and a fixed currency. Calculate in code, show a transaction table, and render one card.

## Build Boundary

**MVP:** one asset, historical cached data, deterministic date rules, transaction audit, clear price-only disclaimer.

**Out:** portfolio advice, forecasts, brokerage integration, tax calculations, arbitrary tokens/stocks, or claims of attainable luxury purchases.

## Existing Products, Building Blocks, and Shortcuts

- CoinGecko’s [historical market-chart range endpoint](https://docs.coingecko.com/reference/coins-id-market-chart-range) supplies dated crypto prices.
- The [CoinGecko Demo plan](https://www.coingecko.com/en/api/pricing) supports a limited free prototype subject to attribution and terms.
- [Alpha Vantage](https://www.alphavantage.co/documentation/) supplies equity/ETF time series, but long full history may exceed free endpoint limits.
- [Satori](https://github.com/vercel/satori) renders consistent share cards.

## Free-First Stack

Static React/TypeScript calculator, cached CoinGecko JSON or a small licensed CSV, Decimal arithmetic, and Satori/resvg. No LLM is needed.

## Architecture/Data Model

`PriceSeries` records provider, asset, currency, interval, timestamps, and retrieval date. `ContributionRule` defines cadence and non-trading-day behavior. `Simulation` stores each contribution, price, units, and exclusions. `Card` freezes assumptions.

## Build Slices

1. Contribution schedule and decimal-safe math.
2. Cached BTC price adapter.
3. Audit table and assumptions.
4. Card renderer and sensitivity controls.

## Drawbacks/Concerns/Failure Modes

- Hindsight framing encourages financial FOMO.
- Price-only output excludes fees, spreads, taxes, dividends, and practical behavior.
- API licensing/limits and historical revisions matter.
- Exchange rate and date-boundary choices change results; expose them.

## Clever Hacks and Simpler Alternative

Bundle monthly BTC data for a fixed demo range. Monthly contributions avoid high-resolution API needs and make the method easy to audit.

## Success Measures

- Every displayed total reconciles with the transaction table.
- Data source/date and exclusions are always visible.
- Repeated runs with the same dataset are identical.
- No forecast or personalized recommendation appears.

## Product Path

Static curiosity calculator → multi-asset sourced cards → educational finance visualization library. Any commercial scope needs financial-promotion language, market-data licenses, and provider attribution review.

## Related Wikilinks

- [[Market Mood Cards]]
- [[Am I Underpaid]]
