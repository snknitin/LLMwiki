---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: search growth agents
form_factor:
  - local editorial workbench
  - static-site publishing pipeline
deployment: local-first with optional search and CMS connectors
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#19. SEO Agency Crew]]"
status: concept
tags:
  - seo
  - content
  - publishing
---

# SEO Agency Crew

> An evidence-led editorial system that finds useful search opportunities, builds a coherent topic graph, drafts source-backed pages, audits quality, and publishes only after human review.

## Product Outcome

Create a small body of genuinely useful content with clear provenance, internal navigation, structured metadata, and measurable search performance. The system should optimize answered user needs and durable site quality—not mass-generated pages, fake backlinks, or synthetic community activity.

## User and Core Workflow

1. Ingest the site, audience, product facts, existing pages, and approved source list.
2. Import Search Console/PageSpeed data when available and crawl the local site.
3. Cluster queries and page gaps into pillar and supporting-page briefs.
4. Research first-party and authoritative sources, recording claims and citations.
5. Draft, fact-check, link, and audit each page for accessibility and performance.
6. Human approve the content and deployment diff.
7. Publish, submit/update sitemap, and measure impressions, clicks, conversions, and decay.

## Demo/Personal V0

Choose one personal topic with five existing notes. Generate one pillar brief and three supporting briefs, then build a local Astro preview with proposed internal links and a Lighthouse report. Publish nothing automatically and do no backlink outreach.

## Build Boundary

- In scope: owned-site analysis, content briefs, source-grounded drafts, internal links, structured data suggestions, previews, and measurement.
- Out of scope: fabricated experience, scraped/rephrased competitors, purchased links, automated Reddit seeding, doorway pages, or guaranteed rankings.
- Require page-level approval and a visible diff before deployment.
- Treat Search Console data as private business data and keep credentials outside the content store.

## Existing Products, Building Blocks, and Shortcuts

- [Google Search Console API](https://developers.google.com/webmaster-tools/v1/api_reference_index) provides query and page performance for verified properties; it is a better starting signal than guessed keyword volume.
- [PageSpeed Insights API](https://developers.google.com/speed/docs/insights/v5/get-started) and [Lighthouse](https://github.com/GoogleChrome/lighthouse) supply performance, accessibility, and SEO audits.
- [Astro](https://docs.astro.build/) produces fast static pages from Markdown/MDX with a small deployment surface.
- [Google Indexing API](https://developers.google.com/search/apis/indexing-api/v3/using-api) is intentionally limited to specific page types; the prototype should use sitemaps for ordinary articles rather than misuse it.

## Recommended Free-First Stack

- Python, Polars, and SQLite for query/page analysis and a claim/evidence ledger.
- Scrapy or a bounded HTTP crawler plus Beautiful Soup for owned-site inventory.
- Sentence Transformers or a local embedding model for topic and internal-link candidates.
- Ollama for briefs/drafts and deterministic citation validation before review.
- Astro for previews; Lighthouse CI and axe-core for quality gates; optional Cloudflare Pages only after approval.

The free-first stack separates research, editorial judgment, and static publishing so any component can be replaced without losing source data.

## Architecture/Data Model

`site` owns `page`, `query_metric`, `topic`, `brief`, `source`, `claim`, `citation`, `link_candidate`, `audit_run`, `publication`, and `conversion_event`. Page versions are content-addressed. A claim cannot reach `approved` unless linked to a source or explicitly labeled opinion/first-party experience.

## Build Slices

1. Site crawler, Search Console CSV import, and content inventory.
2. Query clustering, cannibalization report, and topic-brief generator.
3. Source ledger, grounded drafting, and claim/citation checker.
4. Internal-link graph, Astro preview, and accessibility/performance audits.
5. Approval-gated deployment adapter and post-publication scorecard.

## Drawbacks, Concerns, and Failure Modes

- Search behavior and ranking systems change, so tactics can decay quickly.
- Generated prose often becomes generic, repetitive, or factually unsupported.
- Query metrics can invite vanity traffic unrelated to business outcomes.
- Automated link placement can create awkward anchors or cannibalize pages.
- Backlink and community automation can violate platform rules and damage reputation.

## Clever Hacks and Simpler Alternative

- Start by refreshing pages that already have impressions but weak clicks or outdated facts.
- Make every brief answer “what can this page uniquely add?” before drafting.
- Use orphan-page and broken-link reports as deterministic early wins.
- Keep a reusable evidence pack per topic so related articles share verified sources.
- Simplest alternative: a weekly local report of declining pages, missing internal links, and three human-written update briefs.

## Success Measures

- Every nontrivial factual claim is cited or marked as first-party experience.
- Lighthouse accessibility and best-practice scores meet a chosen threshold before publish.
- No broken internal links and fewer orphan pages after each batch.
- Track qualified conversions as well as impressions and clicks.
- Editors accept at least 70% of proposed briefs while rejecting low-value duplication.

## Product Path

Use it first as a personal blog operating system and learning lab. Later offer vertical evidence packs, editorial calendars, team approvals, CMS connectors, and performance reporting. Any product release needs clear content ownership, model/provider terms, and responsible outreach rules; the local version can remain uncomplicated.

## Related

- [[Microsite Factory]]
- [[Creator Content Engine]]
- [[Personal Signal Intelligence OS]]
