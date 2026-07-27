---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: startup comparison tools
form_factor:
  - local research tool
  - shareable comparison card
deployment: local-first with optional static card export
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#31. Your Twin Raised More]]"
status: concept
tags:
  - startups
  - funding
  - virality
---

# Your Twin Raised More

> Describe a startup and receive a source-backed nearest-company comparison card showing similarities, crucial differences, disclosed funding, and what the comparison cannot prove.

## Product Outcome

Create a fun founder hook without reducing company quality to capital raised. The system identifies several candidates, exposes the matching dimensions, cites dated funding/status sources, and lets the user choose the fairest “twin” before exporting a card.

## User and Core Workflow

1. Enter customer, problem, product, geography, business model, and stage.
2. Convert the description into structured facets and an embedding.
3. Search a curated, source-backed company dataset for candidates.
4. Rerank by customer/problem/model/region/era and explain similarity/differences.
5. Resolve disclosed funding assertions with currency, date, and source confidence.
6. User reviews candidates, corrects facets, and chooses or rejects a twin.
7. Export a visual card plus evidence/details page and update date.

## Demo/Personal V0

Curate 100 companies in one sector from permitted public sources. Run local embedding retrieval, deterministic facet reranking, and produce three candidate cards. Funding is optional: missing data appears as “not verified,” never zero.

## Build Boundary

- In scope: user descriptions, curated company records, similarity search, explainable reranking, sourced funding/status facts, and static exports.
- Out of scope: scraping restricted databases, inferring undisclosed funding, company valuation claims, investment advice, or declaring one startup better.
- Clearly distinguish total publicly reported funding from valuation, revenue, and current cash.
- Every share card links to an evidence page and “as of” date.

## Existing Products, Building Blocks, and Shortcuts

- [SEC EDGAR APIs](https://www.sec.gov/search-filings/edgar-application-programming-interfaces) provide authoritative filing/company facts for applicable US entities.
- [Companies House API](https://developer.company-information.service.gov.uk/) provides official UK entity status and filings.
- [Crunchbase data documentation](https://data.crunchbase.com/docs) describes a licensed structured company dataset; use an approved plan or export rather than scrape the public UI.
- [Internet Archive APIs](https://archive.org/developers/) help verify historical product positioning.
- [Sentence Transformers](https://www.sbert.net/) supplies local semantic embeddings; structured facets should still control the final comparison.

## Recommended Free-First Stack

- Python, FastAPI, Pydantic, SQLite/FTS5, and Polars.
- Sentence Transformers plus FAISS/hnswlib for candidate retrieval.
- Deterministic facet scoring and a local LLM for structured extraction/explanation.
- Astro or server-rendered HTML for evidence pages; Satori or SVG templates for consistent social cards.
- A curated CSV/JSON dataset with source URLs and retrieval dates instead of broad live scraping.

The main asset is a trustworthy small dataset. A clever model cannot repair missing, ambiguously sourced company history.

## Architecture/Data Model

`company` owns `alias`, `company_snapshot`, `facet`, `funding_assertion`, `status_assertion`, `source`, and `embedding`. `query` owns extracted facets, `candidate_score`, `difference`, `user_selection`, and `card_export`. Scores retain per-facet weights; facts retain source, currency, amount type, announcement date, retrieval date, and confidence.

## Build Slices

1. Define facets and curate 30 source-rich company fixtures.
2. Build embeddings, nearest-neighbor retrieval, and deterministic reranking.
3. Evidence page with funding/status assertions and conflict handling.
4. Candidate correction/selection UI and share-card renderer.
5. Expand to 100 companies, add change monitoring, and publish selected cards.

## Drawbacks, Concerns, and Failure Modes

- Private funding data is incomplete, duplicated, estimated, or reported in different currencies.
- Semantic similarity can overvalue shared buzzwords and ignore distribution or timing.
- Funding is a poor proxy for health, usefulness, or likely success.
- Cards can imply endorsement, disclosure, or current status beyond the evidence.
- Curating and refreshing a credible dataset is the expensive part.

## Clever Hacks and Simpler Alternative

- Restrict V0 to one sector and geography with reliable sources.
- Present three candidate twins and let the user reject all of them.
- Always include one “important difference” beside the similarity score.
- Normalize comparison by funding stage or company age, not only raw total.
- Simplest alternative: compare the idea to a manually curated deck of archetypes without funding numbers.

## Success Measures

- Every displayed funding/status fact has a source and date.
- A labeled benchmark places a human-chosen comparable in the top three often enough to be useful.
- Missing facts remain unknown rather than silently becoming zero.
- Users understand why candidates matched and can correct the extracted facets.
- Share cards consistently link back to the full caveated evidence page.

## Product Path

Start as a local founder toy and content generator, then publish themed datasets and “twin of the week” analyses. Paid options could include private portfolio comparisons, market maps, collaborative curation, and licensed data integrations. Public launch requires brand/trademark care, correction channels, and rigorous data-source licensing.

## Related

- [[Startup Graveyard]]
- [[Side-Hustle Radar]]
- [[Brag Notary]]
