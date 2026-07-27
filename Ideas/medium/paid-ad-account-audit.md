---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: marketing analytics
form_factor:
  - local analytics dashboard
  - audit report generator
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#18. Paid Ad Account Audit]]"
status: concept
---
# Paid Ad Account Audit

> Import ad-platform exports, calculate explainable waste and coverage signals, and produce a prioritized test plan without claiming causal certainty.

## Product Outcome

Give an operator a repeatable audit showing spend concentration, tracking gaps, weak segments, fatigue signals, and experiments worth running. Every finding includes its metric definition, comparison period, and affected rows.

## User and Core Workflow

Upload Google or Meta CSV exports, map columns, choose currency/time zone, and validate totals. The system computes deterministic checks, segments results by campaign/ad/audience, and labels findings by confidence. The operator adds business context, accepts recommendations, and exports a report.

## Demo/Personal V0

Use anonymized exports from two time windows. Support ten audit rules, a metric dictionary, filters, evidence tables, and five experiment cards. Avoid live account OAuth.

## Build Boundary

Include imports, schema mapping, reconciliation, metric definitions, rule-based findings, exploratory views, and test-plan export. Exclude bid/budget changes, tracking installation, creative generation, attribution modeling beyond supplied data, and autonomous account access.

## Existing Products, Building Blocks, and Shortcuts

- [Google Ads API reporting](https://developers.google.com/google-ads/api/docs/reporting/overview) defines GAQL and Search/SearchStream reporting for a later adapter.
- [Meta Marketing API Insights](https://developers.facebook.com/docs/marketing-api/insights) is the first-party Meta reporting surface.
- [DuckDB](https://duckdb.org/docs/stable/) accelerates local analysis of large CSV/Parquet exports.
- [Apache ECharts](https://echarts.apache.org/en/index.html) provides interactive local charts without a hosted BI tool.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, DuckDB, Polars, Pydantic, and a lightweight React/ECharts UI. This stack handles messy exports and local analytical queries efficiently. Use an LLM only to explain already-computed findings and draft experiments.

## Architecture/Data Model

Store `accounts`, `imports`, `column_mappings`, `metric_definitions`, `fact_rows`, `audit_rules`, `findings`, `evidence_queries`, `annotations`, and `experiments`. Preserve raw files and normalized tables; each finding stores executable logic or SQL plus affected dimensions.

## Build Slices

1. CSV import, mapping, currency/time-zone validation, reconciliation.
2. Ten deterministic audit rules and evidence tables.
3. Dashboard, priorities, context annotations, report.
4. Optional API adapters and scheduled comparison.

## Drawbacks/Concerns/Failure Modes

Platforms define metrics differently; incomplete attribution can punish good campaigns; small samples create noise; and recommendations can be mistaken for causality. Show denominators, windows, data gaps, minimum-sample rules, and hypothesis language.

## Clever Hacks and Simpler Alternative

Start as a DuckDB SQL pack plus a generated Markdown report. If operators repeatedly override the same rule, improve the metric model before adding more AI prose.

## Success Measures

Track import success, total reconciliation error, finding acceptance, false-positive dismissals, analyst time saved, experiments launched, and measurable waste removed after controlled changes.

## Product Path

Personal audit notebook → productized agency report → connected marketing-analytics product. Before live APIs, client accounts, write access, or billing, run [[Scope Expansion Checklist]] for advertising data, provider terms, permissions, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#18. Paid Ad Account Audit]]
- [[Scope Expansion Checklist]]

