---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: founder-operations
form_factor:
  - local dashboard
  - email-export tool
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#6. Founder Investor Update Writer]]"
status: concept
tags: [founders, reporting, metrics]
---

# Founder Investor Update Writer

> Calculate the numbers in code, then turn validated metrics and founder notes into a candid monthly update.

## Product Outcome

The founder enters monthly metrics, wins, misses, asks, risks, and next milestones. The app compares with prior months, flags missing or changed definitions, and drafts a skimmable update with charts and explicit asks.

## User and Core Workflow

1. Define each metric once, including unit and calculation.
2. Enter/import the month’s values and qualitative notes.
3. Code validates and calculates deltas/runway.
4. Founder reviews the source table and approves facts.
5. Local model narrates only approved values.
6. Export Markdown/HTML or a Gmail draft.

## Demo/Personal V0

Local dashboard for MRR, burn, cash, customers, activation, and runway; three seeded months; one chart; Markdown/email preview.

## Build Boundary

**MVP:** versioned metrics, monthly form, deterministic deltas, chart, structured narrative, manual export.

**Out:** accounting, bank access, investor CRM, fundraising promises, autonomous sending, or model-calculated finance.

## Existing Products, Building Blocks, and Shortcuts

- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) fixes update sections such as highlights, lowlights, asks, risks, and plan.
- [SQLite](https://www.sqlite.org/about.html) is a serverless single-file store for private monthly history.
- [Chart.js](https://github.com/chartjs/Chart.js) replaces custom deterministic trend visualization.
- [Gmail Drafts API](https://developers.google.com/workspace/gmail/api/guides/drafts) adds reviewable export later.

## Free-First Stack

Vite/React + TypeScript/Zod + SQLite + Chart.js + local Ollama. Generate Markdown/HTML first; email OAuth is optional.

## Architecture/Data Model

`MetricDefinition` has name, unit, formula, and version. `MonthlyMetric` links value and source note. `FounderNote` is categorized win/miss/ask/risk/plan. `UpdateRun` stores approved inputs, calculated deltas, model, and final edits.

## Build Slices

1. Metric dictionary and monthly input.
2. Deterministic calculations and source table.
3. Chart and fixed Markdown template.
4. Local narrative and optional Gmail draft.

## Drawbacks/Concerns/Failure Modes

- Financial data is confidential; keep local and exclude telemetry.
- Metric definitions drift; version them and warn before comparisons.
- Models may turn uncertainty into confidence; pass exact numbers and retain caveats.
- A polished update can hide bad news; require lowlights, asks, and risks.

## Clever Hacks and Simpler Alternative

A well-designed Markdown template plus code-calculated table may solve 80% of the problem. Ask founders for one sentence each: “what changed, why, what help.”

## Success Measures

- Every number traces to a stored value/formula.
- Update prep takes under 20 minutes.
- Missing definitions block misleading comparisons.
- Founder edits narrative, not arithmetic.

## Product Path

Personal monthly template → metric-connected founder dashboard → investor communications product. Expansion needs financial-data security, connector permissions, and claims review.

## Related Wikilinks

- [[Build in Public Autoposter]]
- [[Pocket CRM]]

