---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: career-finance
form_factor:
  - local calculator
  - benchmark dashboard
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#2. Am I Underpaid]]"
status: concept
tags: [salary, freelancing, negotiation]
---

# Am I Underpaid

> A transparent compensation range and negotiation planner that shows sample size and uncertainty instead of a fake exact percentile.

## Product Outcome

Enter location, role, experience, employment type, hours/utilization, and compensation. Receive a broad market range when defensible, a personal sustainable-rate calculation, the assumptions used, and a negotiation checklist.

## User and Core Workflow

1. Choose employee or freelancer and enter normalized annual/contract values.
2. Select the closest supported cohort.
3. Code calculates currency normalization, percentiles, and a sustainable freelance floor.
4. Display cohort size, year, range, caveats, and sensitivity controls.
5. Export a private negotiation brief or a share card without salary amount.

## Demo/Personal V0

Load the Stack Overflow survey CSV into DuckDB/SQLite and support a few broad developer cohorts. When `n` is too small, suppress percentile and show only the personal rate calculator.

## Build Boundary

**MVP:** one disclosed dataset, broad filters, deterministic calculations, cohort threshold, freelance floor, local-only storage.

**Out:** salary guarantees, real-time employer data, individualized tax advice, scraped compensation sites, public personal submissions, or job placement.

## Existing Products, Building Blocks, and Shortcuts

- The [2025 Stack Overflow Developer Survey work data](https://survey.stackoverflow.co/2025/work) supplies a credible seed dataset with compensation responses.
- Its [methodology](https://survey.stackoverflow.co/2025/methodology/) provides the selection-bias and sampling caveats the UI should surface.
- PostgreSQL [`percent_rank`](https://www.postgresql.org/docs/17/functions-window.html) replaces bespoke rank logic when crowdsourced data later moves server-side.
- [Satori](https://github.com/vercel/satori) can render privacy-safe range cards.

## Free-First Stack

React/Vite, DuckDB-WASM or SQLite, downloaded survey CSV, TypeScript calculations, and Satori/resvg. No LLM is required; if used, it writes negotiation language only.

## Architecture/Data Model

`DatasetRelease` records source/year/methodology. `CompRecord` stores normalized country, role, experience, employment, and annual value. `CohortQuery` stores filters and `n`. `BenchmarkResult` stores quantiles and suppression reason. `RatePlan` stores desired income, costs, billable utilization, and floor.

## Build Slices

1. Salary/rate normalization and unit tests.
2. Dataset loader and broad cohort selector.
3. Threshold/caveat UI and sensitivity controls.
4. Negotiation brief and privacy-safe card.

## Drawbacks/Concerns/Failure Modes

- Self-selected survey data is not a population census.
- Tiny cohorts create false precision; set a minimum `n` and widen filters automatically.
- Currency, taxes, benefits, unpaid time, and cost of living differ.
- Stale data should never be presented as a current offer guarantee.

## Clever Hacks and Simpler Alternative

Ship the sustainable-rate calculator first: desired take-home + business costs divided by realistic billable hours. It is immediately actionable and needs no market-data license.

## Success Measures

- All calculations reproduce from displayed inputs.
- No percentile appears below the cohort threshold.
- Dataset year and cohort size are visible beside every result.
- User leaves with a specific negotiation/rate experiment.

## Product Path

Personal calculator → benchmark imports → anonymous opt-in cohort product → career negotiation service. Future scope needs privacy, dataset licensing, and financial-claims review.

## Related Wikilinks

- [[latte-into-lambo|Latte into Lambo]]
- [[cold-email-rewrite-desk|Cold Email Rewrite Desk]]

