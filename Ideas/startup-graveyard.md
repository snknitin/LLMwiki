---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: startup research tools
form_factor:
  - local research dashboard
  - shareable static report
deployment: local-first with optional static-site export
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#23. Startup Graveyard]]"
status: concept
tags:
  - startups
  - research
  - competitive-intelligence
---

# Startup Graveyard

> Enter a startup thesis and receive a source-backed cemetery of comparable discontinued companies, failed approaches, surviving pivots, and testable lessons—without fictional epitaphs masquerading as facts.

## Product Outcome

Turn a vague idea into a memorable but responsible pre-mortem. Each company card separates verified dates/funding/status from reported explanations and the system’s own inference. The output ends with assumptions to test, not a fatalistic “this will fail” verdict.

## User and Core Workflow

1. Describe customer, problem, solution, business model, geography, and era.
2. Expand the concept into search terms and comparable categories.
3. Search approved registries, archives, company sites, filings, and reputable reporting.
4. Deduplicate entities and build a timeline with source confidence.
5. Label outcomes: shut down, acquired, pivoted, dormant, or status unknown.
6. Extract cited founder/reporter explanations and separately derive recurring risks.
7. Review cards and export a static graveyard plus survival experiments.

## Demo/Personal V0

Research one well-documented idea and manually seed ten candidate company URLs. The tool resolves five entities, captures archived homepage evidence and authoritative status clues, and renders cards with a three-level confidence badge. No open-web autonomous discovery is needed.

## Build Boundary

- In scope: public company research, source capture, entity resolution, timelines, uncertainty labels, comparison, and static reports.
- Out of scope: claiming legal insolvency without records, guessing funding totals, declaring living companies dead, defaming founders, or treating an acquisition as failure.
- Require at least one status source and clearly display the “as of” date.
- “Cause of death” must be quoted/reported evidence or labeled hypothesis.

## Existing Products, Building Blocks, and Shortcuts

- [SEC EDGAR APIs](https://www.sec.gov/search-filings/edgar-application-programming-interfaces) provide authoritative US public-company filing facts where applicable.
- [Companies House API](https://developer.company-information.service.gov.uk/) offers official UK company status and filing data.
- [Internet Archive APIs](https://archive.org/developers/) can help retrieve historical pages and artifacts when the live site has disappeared.
- [Crunchbase data documentation](https://data.crunchbase.com/docs) describes a structured commercial company dataset; use it only with suitable access rather than scraping the site.

## Recommended Free-First Stack

- Python, FastAPI, Pydantic, SQLite, and FTS5 for entities, timelines, evidence, and search.
- Playwright plus trafilatura for permitted page capture; WARC or HTML snapshots with hashes for provenance.
- Local embeddings for candidate similarity, followed by deterministic entity checks.
- Local LLM for search expansion and evidence synthesis with claim-level citations.
- Astro for a polished, static, shareable “graveyard” export.

Manual candidate seeding makes the first build useful before investing in unreliable broad discovery.

## Architecture/Data Model

`idea` links to `search_term`, `company`, `alias`, `event`, `status_assertion`, `funding_assertion`, `explanation`, `source_snapshot`, `comparison`, and `experiment`. Each assertion stores source, retrieval date, confidence, and whether it is direct, reported, or inferred. Conflicting assertions remain visible.

## Build Slices

1. Idea schema, manual URL queue, source capture, and entity deduplication.
2. Timeline/status extraction with confidence and contradiction handling.
3. Comparable scoring and evidence-linked company cards.
4. Pattern analysis, counterexamples, and survival-experiment generator.
5. Search adapters, saved reports, and static publish flow.

## Drawbacks, Concerns, and Failure Modes

- Private-company status and funding are often incomplete or stale.
- Survivorship and selection bias can make the graveyard look more predictive than it is.
- Similar products may have different timing, distribution, geography, or economics.
- Archived pages can omit key context; press narratives oversimplify failure.
- A “cause of death” framing can become defamatory or cruel without careful attribution.

## Clever Hacks and Simpler Alternative

- Ask the user to provide the first ten candidate names or links.
- Include successful and pivoted comparables beside shutdowns.
- Add a “what changed since then?” field for technology, regulation, and distribution.
- Score evidence completeness independently from similarity.
- Simplest alternative: a source-backed comparison table and pre-mortem checklist instead of a visual cemetery.

## Success Measures

- Every status and funding claim has a direct source and retrieval date.
- No hypothesis is displayed as a reported fact.
- Entity deduplication correctly handles aliases in a curated fixture.
- Users identify at least three concrete assumptions or experiments from the report.
- A complete five-company report can be produced in under 20 minutes after URLs are supplied.

## Product Path

Start as a local founder research game and turn strong reports into a blog series. Later add monitored portfolios, vertical research packs, collaborative annotations, and paid due-diligence exports. Public release requires careful attribution, correction requests, source licenses, and neutral status language.

## Related

- [[Demand Generation Workbench]]
- [[Conversion List Builder]]
- [[Side-Hustle Radar]]
