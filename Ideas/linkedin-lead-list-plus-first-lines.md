---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: sales research
form_factor:
  - local research dashboard
  - CSV enrichment workflow
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#12. LinkedIn Lead List plus First Lines]]"
status: concept
---
# LinkedIn Lead List plus First Lines

> Rank user-supplied prospects against a clear ICP and draft a first line supported by current, first-party company evidence.

## Product Outcome

Create a small, high-confidence outreach list rather than a scraped database. Each row contains fit reasons, freshness, evidence URLs, a personalized opening, and a human review state.

## User and Core Workflow

The founder defines ICP constraints and imports a CSV of people or companies they are permitted to contact. The system visits allowlisted company pages, extracts structured facts and recent evidence, calculates an explainable fit score, and drafts one sentence. The user reviews, edits, and exports selected rows.

## Demo/Personal V0

Import 25 synthetic or personally sourced companies. Research only their official home, about, careers, and news pages. Produce ten ranked rows and first lines with exact evidence snippets; no LinkedIn browser automation or sending.

## Build Boundary

Include ICP schema, CSV import, first-party website research, provenance, fit scoring, duplicate detection, draft review, and export. Exclude LinkedIn scraping, contact-data brokerage, automated connection requests, bulk messaging, and inferred sensitive traits.

## Existing Products, Building Blocks, and Shortcuts

- LinkedIn’s [automated activity policy](https://www.linkedin.com/help/linkedin/answer/a1340567/automated-activity-on-linkedin) establishes the boundary: do not automate scraping or engagement.
- [Schema.org Organization](https://schema.org/Organization) metadata accelerates company-name, URL, industry, and relationship extraction.
- [Playwright](https://playwright.dev/docs/intro) can render official company pages when static HTTP is insufficient.
- [Gmail drafts](https://developers.google.com/workspace/gmail/api/guides/sending) stages individually reviewed outreach later.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, httpx/Beautiful Soup, optional Playwright, Pydantic, and Ollama. Python suits controlled crawling and extraction; SQLite keeps page snapshots and deduplication local; typed outputs keep evidence tied to each line.

## Architecture/Data Model

Model `icp_versions`, `companies`, `people`, `source_pages`, `claims`, `fit_scores`, `first_line_versions`, `reviews`, and `exports`. Each claim stores URL, page title, retrieval time, and text span. Scoring rules run before prose generation.

## Build Slices

1. ICP builder, CSV import, normalization, dedupe.
2. Allowlisted page fetcher, claim extraction, evidence UI.
3. Explainable ranking and first-line generator.
4. Review queue, CSV export, and optional Gmail draft.

## Drawbacks/Concerns/Failure Modes

Stale sites, namesakes, unsupported flattery, blocked pages, and scale pressure can degrade quality. Prefer unknown over guesswork, require recent evidence, cap crawl depth, log failures, and optimize for 10 useful leads rather than 10,000 rows.

## Clever Hacks and Simpler Alternative

Have the founder paste one official URL per company. A command that returns “fit / no fit / investigate” plus one cited line tests usefulness without any discovery crawler.

## Success Measures

Track accepted leads, evidence freshness, first-line edit rate, unsupported-claim count, duplicate rate, positive reply rate on manually sent messages, and research minutes per accepted lead.

## Product Path

Personal prospect research → boutique outbound workbench → governed sales-intelligence product. Before team use, contact enrichment, live messaging, or monetization, run [[Scope Expansion Checklist]] for data sourcing, provider terms, consent, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#12. LinkedIn Lead List plus First Lines]]
- [[Scope Expansion Checklist]]
- [[Conversion List Builder]]
