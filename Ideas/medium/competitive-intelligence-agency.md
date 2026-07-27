---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: competitive-intelligence
form_factor:
  - local dashboard
  - scheduled research pipeline
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#28. Competitive Intelligence Agency]]"
status: concept
tags:
  - competitors
  - monitoring
  - research
---

# Competitive Intelligence Agency

> Monitor a small allowlist of official competitor sources and turn meaningful changes into an evidence-backed weekly brief.

## Product Outcome

The owner defines three competitors, the claims/pricing/features to watch, and internal sales questions. The system captures approved pages and feeds, suppresses layout noise, extracts claim-level changes, and generates a reviewable weekly brief with screenshots and citations.

Unlike [[B2B Competitor Battlecard]], this project is recurring: its core asset is a time series of evidence and a durable change taxonomy.

## User and Core Workflow

1. Create competitor profiles and allowlist official pricing, product, docs, changelog, careers, and release sources.
2. Schedule polite, cached snapshots or consume official feeds/APIs.
3. Normalize content and generate semantic plus line diffs.
4. Classify meaningful changes: pricing, packaging, claim, feature, integration, proof, positioning, or hiring signal.
5. Human verifies the captured evidence.
6. Publish a weekly brief, update evidence-backed battlecards, and record implications as hypotheses.

## Demo/Personal V0

Monitor five pages across two open-source competitors for one week using saved fixtures that include price, headline, and release changes. Show before/after evidence, noise suppression, and a Markdown weekly digest.

## Build Boundary

**MVP:** three competitors, 15 allowlisted sources, daily snapshots, content-region selection, diffs, local classification, human verification, weekly Markdown report.

**Out:** broad web crawling, employee surveillance, paywalled/private data, automated sales claims, social listening at scale, CRM automation, predictive revenue claims, and autonomous competitive actions.

## Existing Products, Building Blocks, and Shortcuts

- [changedetection.io](https://github.com/dgtlmoon/changedetection.io) replaces snapshot scheduling, selectors, diffs, screenshots, and notifications and can run locally.
- [Playwright](https://playwright.dev/docs/intro) handles JavaScript-rendered official pages and reproducible screenshots.
- [GitHub Releases API](https://docs.github.com/en/rest/releases) supplies structured release history for open-source competitors.
- [Common Crawl Index](https://index.commoncrawl.org/) can find older public captures for research, but should not become the V0’s high-volume crawler.

## Free-First Stack

- **Capture:** changedetection.io Docker with selectors; feed/API adapters where available.
- **Pipeline:** Python + FastAPI, Beautiful Soup/readability, and Pydantic.
- **Storage:** filesystem/WARC-like raw snapshots plus SQLite metadata/claims.
- **Model:** Ollama for change classification and implications, constrained to diff evidence.
- **Dashboard:** HTMX review queue; Markdown/Obsidian export.
- **Scheduling:** changedetection’s scheduler or APScheduler, not both.

## Architecture/Data Model

`Competitor` owns `WatchTarget`. Each `Snapshot` is immutable and checksum-addressed. `ChangeEvent` stores added/removed spans, screenshot, taxonomy, and noise score. `VerifiedClaim` links one or more snapshots. `Implication` is explicitly labeled hypothesis and stores reviewer status. `BriefIssue` freezes included events.

## Build Slices

1. Watch registry, raw snapshots, and selector configuration.
2. Normalized line diffs and noise filters.
3. Taxonomy classifier with evidence.
4. Human verification queue and weekly brief.
5. Battlecard projection and stale-evidence alerts.

## Drawbacks/Concerns/Failure Modes

- Cookie banners, timestamps, and rotating testimonials create noise. Use content selectors and normalization.
- Public copy can be ambiguous. Preserve full context and label vendor claims.
- Monitoring too frequently increases cost and may breach policies. Prefer APIs/feeds, cache, back off, and respect terms.
- LLM “implications” sound factual. Separate observed change from analyst hypothesis visually.
- The system can become an unread archive. Rank by materiality relative to explicit watch questions.

## Clever Hacks and Simpler Alternative

- A weekly manual URL checklist with screenshots may validate the taxonomy before automation.
- Track only pricing, changelog, and homepage headline first; these produce high-signal change types.
- Store evidence as Markdown blocks with stable IDs so battlecards reuse them directly.
- Use release feeds/API records wherever possible; structured data beats page scraping.

## Success Measures

- At least 80% of surfaced changes are judged meaningful.
- Every observation in the brief links to before/after evidence and capture time.
- Weekly review takes under 30 minutes for 15 sources.
- No source is polled more frequently than configured policy allows.
- Battlecards clearly flag stale or superseded evidence.

## Product Path

Personal watchlist → team CI workspace → analyst-assisted agency → multi-tenant competitive-intelligence product. Expansion requires monitored-site policy review, secure customer workspaces, and license/compliance controls.

## Related Wikilinks

- [[B2B Competitor Battlecard]]
- [[Market Mood Cards]]
- [[Website Change Monitor]]

