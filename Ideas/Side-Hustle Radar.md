---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#11. Side-Hustle Radar]]"
status: concept
difficulty: medium
priority: p0
category: opportunity research
form_factor:
  - local dashboard
  - daily report
deployment: local-first
source_ideas:
  - side hustle search from Reddit and help grow projects
tags:
  - reddit
  - market-research
  - entrepreneurship
---

# Side-Hustle Radar

> A problem-discovery system that finds repeated, costly complaints in selected communities, verifies demand signals, and converts them into small experiments rather than producing a daily pile of generic startup ideas.

## Product Outcome

The useful output is not “build an AI app for X.” It is an evidence packet: who has the problem, the exact job they are trying to do, current workaround, frequency, urgency, willingness-to-pay clues, reachable distribution channel, and the cheapest test.

## Personal V0

- Monitor a small manually selected set of subreddits and RSS/search feeds.
- Store posts and comments through permitted APIs or manual exports.
- Detect repeated problem statements and cluster paraphrases over time.
- Extract current tools, workaround cost, trigger event, and buyer type.
- Require at least three independent examples before promoting a theme.
- Generate a weekly opportunity brief with verbatim snippets kept within review context and direct links.
- Propose a no-code concierge test, landing page, or interview script.
- Track experiments, replies, commitments, and why an idea was rejected.

## Build Boundary

**MVP:** one community, manual or official ingestion, weekly report, human-validated clusters, and experiment tracker.

**Later:** multiple communities, trend alerts, competitor pricing, outreach CRM, and portfolio scoring. Do not mass-message users or treat upvotes as willingness to pay.

## Existing Products, Building Blocks, and Shortcuts

- Reddit’s [official API documentation](https://www.reddit.com/dev/api/) and RSS endpoints can provide selected community inputs; Hacker News offers an official [Firebase API](https://github.com/HackerNews/API). Start with sources you can replay and audit.
- GummySearch, F5Bot, and Google Alerts are product references for community/problem monitoring. Your differentiator is the evidence threshold, workaround economics, experiment log, and rejection memory.
- [RSSHub](https://github.com/DIYgod/RSSHub), FreshRSS, and n8n can replace most custom monitoring plumbing. Embeddings should suggest clusters; a human merge/split review owns the market theme.
- Simplest alternative: manually capture twenty threads into a fixed complaint template and run one concierge experiment. Automate only after the extraction itself repeatedly saves time.

## Free-First Stack

- **Ingestion:** official Reddit developer access where available, RSS feeds, or user-provided exports; cache sparingly and honor terms.
- **Pipeline:** Python/FastAPI plus scheduled n8n runs.
- **Data:** SQLite/Postgres with source, timestamp, author pseudonym, text hash, and cluster history.
- **Analysis:** BM25/embeddings for candidate clustering; local model for structured extraction; human labels as ground truth.
- **UI:** local evidence board with source-first cluster review.
- **Validation:** simple static landing pages and manual interview tracking before building software.

## Clever Shortcut

Start with a “complaint notebook” rather than automation: twenty manually selected threads, a fixed extraction template, and one weekend experiment. Only automate the fields that repeatedly save time. This prevents spending weeks perfecting a market-research crawler with no market insight.

## Build Slices

1. Opportunity schema and manual evidence capture.
2. Single-source ingestion and deduplication.
3. Cluster review with merge/split controls.
4. Evidence threshold and weekly brief.
5. Experiment tracker and learning loop.

## Success Measures

- Every promoted idea has multiple independent sources.
- At least one experiment reaches a real conversation or commitment each month.
- The system distinguishes consumer frustration from a buyer with budget.
- Rejected ideas retain reasons, preventing repeated rediscovery.

## Product Path

Keep the early version personal because access rules and market context are hard to generalize. Later it can become a niche research service, agency tool, or “evidence before code” product for builders.

## Related

- [[Personal Signal Intelligence OS]]
- [[Creator Content Engine]]
- [[Event Market Research Terminal]]
- [[Project Ideas Index]]
