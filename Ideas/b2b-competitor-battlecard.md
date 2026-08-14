---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: sales-enablement
form_factor:
  - local web app
  - markdown report generator
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#19. B2B Competitor Battlecard]]"
status: concept
tags:
  - competitors
  - sales
  - research
---

# B2B Competitor Battlecard

> Produce a call-ready competitor brief whose claims link back to dated evidence.

## Product Outcome

Given your company, one competitor, a target buyer, and an optional folder of call notes, produce a one-page battlecard: positioning summary, verified differences, likely objections, discovery questions, traps to avoid, and proof links. The value is not generic prose; it is fast retrieval of defensible evidence during a sales call.

## User and Core Workflow

1. User enters official URLs and uploads approved internal material.
2. The tool snapshots selected pricing, product, security, integration, and release pages.
3. Extraction turns each claim into a structured evidence record with URL, quote fragment, capture time, and confidence.
4. The user approves or rejects evidence before generation.
5. A template assembles the battlecard and a 30-second talk track.
6. Export Markdown/PDF and schedule an optional refresh.

## Demo/Personal V0

Compare two open-source products using only their homepages, pricing pages, documentation, and GitHub releases. Show the source drawer beside every generated bullet and deliberately mark one unsupported claim as “unknown.”

## Build Boundary

**MVP:** two companies, allowlisted public pages, manual capture, structured evidence, one fixed battlecard template, local LLM summarization, Markdown/PDF export.

**Out:** crawling the open web, guessing private pricing, auto-emailing prospects, CRM sync, intent data, sentiment inference, and unsourced “competitor weakness” generation.

## Existing Products, Building Blocks, and Shortcuts

- [changedetection.io](https://github.com/dgtlmoon/changedetection.io) replaces a home-grown scheduler, snapshot store, selector UI, diff engine, and notifications for monitored pages.
- [Playwright](https://playwright.dev/docs/intro) accelerates capture of JavaScript-rendered pages and reproducible screenshots.
- [GitHub Releases API](https://docs.github.com/en/rest/releases) provides structured product-change evidence for open-source competitors instead of scraping release pages.
- [Common Crawl Index](https://index.commoncrawl.org/) is useful for finding historical public captures, but is a fallback rather than the V0 crawler.

## Free-First Stack

- **UI/API:** FastAPI + Jinja/HTMX for a small research desk with file upload and review.
- **Capture:** changedetection.io in Docker; Playwright only for pages that need JavaScript.
- **Extraction:** Beautiful Soup/readability plus Pydantic schemas.
- **Model:** local Ollama model constrained to evidence IDs.
- **Storage:** SQLite for claims and snapshots; filesystem for raw HTML and screenshots.
- **Export:** Markdown template + WeasyPrint or browser print-to-PDF.

Python keeps capture, extraction, and evaluation in one ecosystem. HTMX avoids a separate frontend while evidence review is still simple.

## Architecture/Data Model

`Company` has `SourcePage`; each capture becomes an immutable `Snapshot`. `EvidenceClaim` stores subject, predicate, object, evidence span, source URL, capture date, and verification state. `BattlecardSection` references evidence IDs. `GenerationRun` stores prompt/template/model and the exact evidence set.

Never let the final writer see unapproved raw web text without provenance. The renderer should refuse comparative claims that have no evidence reference.

## Build Slices

1. URL allowlist and snapshot capture.
2. Manual evidence highlighter and claim schema.
3. Rule/template battlecard without an LLM.
4. Evidence-bound local generation and source drawer.
5. Diff refresh and stale-claim warnings.

## Drawbacks/Concerns/Failure Modes

- Pricing and packaging change quickly; show “captured on” dates and stale badges.
- Marketing claims are not objective facts. Label “vendor says” separately from verified capabilities.
- Web layouts create noisy diffs; select stable content regions and hash normalized text.
- Scraping may violate site terms or overload servers. Prefer official APIs/feeds, low frequency, caching, and an explicit allowlist.
- Generated attack lines can become misleading or defamatory. Ban speculation and give reps “say / do not say” guidance.

## Clever Hacks and Simpler Alternative

- A strong first version is a Markdown template plus three saved-page snapshots and manual evidence highlighting.
- Capture pricing as a screenshot and text together; screenshots resolve later disputes about context.
- Add an “unknown” column. Honest absence is more useful than confident filler.
- Separate “one-off battlecard” from recurring intelligence; merge the crawler later with [[competitive-intelligence-agency|Competitive Intelligence Agency]].

## Success Measures

- Every comparative statement has a clickable evidence record.
- A useful first battlecard is produced in under 15 minutes.
- Reviewer rejects fewer than 10% of claims as unsupported.
- Refresh identifies a meaningful page change without flooding on navigation/footer noise.

## Product Path

Local call-prep tool → team evidence library → CRM/sidebar integration → continuously refreshed sales-enablement product. Future commercial scope must review monitored-site terms, customer-data handling, and dependency licenses.

## Related Wikilinks

- [[competitive-intelligence-agency|Competitive Intelligence Agency]]
- [[customer-support-agency|Customer Support Agency]]
