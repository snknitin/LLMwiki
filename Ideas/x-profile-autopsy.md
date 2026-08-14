---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: creator-analytics
form_factor:
  - local report generator
  - shareable score card
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#17. X Profile Autopsy]]"
status: concept
tags: [x, creators, content]
---

# X Profile Autopsy

> Analyze your own bio and post sample into evidence-backed content pillars, gaps, and draft experiments—without paying for or scraping arbitrary profiles.

## Product Outcome

Paste a bio and 20–50 owned posts or import an account export. Receive audience promise, content pillars, format/engagement patterns, gaps, a transparent score breakdown, and ten draft ideas. Every observation cites example post IDs/text snippets.

## User and Core Workflow

1. Import owned bio/posts and choose the desired audience/outcome.
2. Calculate deterministic posting, format, and public-metric summaries.
3. Cluster topics and select representative posts.
4. Local model names pillars/gaps from those examples.
5. Review draft posts, then export report/card.

## Demo/Personal V0

Manual JSON/CSV/text import, local analysis of 30 posts, four pillar labels, ten drafts, Markdown report, and share card. No X API.

## Build Boundary

**MVP:** self-analysis, manual import, deterministic metrics, cited themes, local generation, export.

**Out:** public third-party scoring, scraping, follower profiling, autonomous posting, guaranteed growth, harassment cards, or API spend.

## Existing Products, Building Blocks, and Shortcuts

- X [user lookup](https://docs.x.com/x-api/users/lookup/quickstart/user-lookup) provides profile fields and public metrics for a later authenticated integration.
- X [user posts endpoint](https://docs.x.com/x-api/users/get-posts) returns authored posts with optional public metrics.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) constrains persona, pillars, gaps, evidence, and draft ideas.
- [Satori](https://github.com/vercel/satori) generates the result card; X’s [pricing](https://docs.x.com/x-api/getting-started/pricing) supports the free-first decision to import manually.

## Free-First Stack

Local React/TypeScript + CSV/JSON parser + SQLite/DuckDB-WASM + Ollama + Satori/resvg. Calculate metrics in code; use the model for naming and drafts.

## Architecture/Data Model

`ProfileSnapshot` stores owned bio/date. `Post` stores text/date/public metrics. `DerivedMetric` stores calculation/version. `ContentPillar` references representative post IDs. `DraftIdea` references a gap and approved style examples.

## Build Slices

1. Manual import/normalization.
2. Deterministic metrics and post explorer.
3. Evidence-linked pillars/gaps.
4. Draft ideas and report/card.
5. Optional OAuth for the user’s own account.

## Drawbacks/Concerns/Failure Modes

- Engagement metrics do not reveal causality or content quality.
- Small samples and platform changes distort conclusions.
- Third-party autopsies invite harassment/consent problems; keep self-owned scope.
- Generated drafts can flatten voice; learn only from user-selected posts.

## Clever Hacks and Simpler Alternative

Ask for the user’s best five and most representative five posts. A small curated corpus often produces better voice analysis than a costly full history.

## Success Measures

- Every pillar cites representative posts.
- All numeric scores disclose formula/sample window.
- At least half of draft ideas are worth saving after review.
- V0 runs without X API calls or cloud storage.

## Product Path

Personal report → authenticated creator workspace → content experimentation dashboard → paid creator tool. Expansion needs X API pricing/terms, consent, retention, and posting-policy review.

## Related Wikilinks

- [[build-in-public-autoposter|Build in Public Autoposter]]
- [[roast-my-landing-page|Roast My Landing Page]]
