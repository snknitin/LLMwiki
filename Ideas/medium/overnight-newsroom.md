---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: news intelligence
form_factor:
  - local editorial dashboard
  - scheduled bulletin pipeline
deployment: local desktop with optional DGX Spark inference
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#17. Overnight Newsroom]]"
status: concept
---
# Overnight Newsroom

> An overnight, source-preserving editorial desk that prepares a reviewable Indian news bulletin instead of autonomously publishing unverified stories.

## Product Outcome

Have a concise morning package ready: clustered developments, claim/source matrices, uncertainty flags, script, suggested audio, and a publish queue. Every sentence must be traceable to captured sources.

## User and Core Workflow

The editor maintains an allowlist of Indian and primary-source feeds. Overnight jobs ingest and snapshot entries, deduplicate stories, cluster related reports, extract claims, and flag contradictions or single-source items. A writer drafts only from approved claims; a morning editor reviews and optionally renders/publishes.

## Demo/Personal V0

Monitor ten RSS/Atom feeds for one week. Produce a private five-story Markdown/HTML bulletin with source cards, timestamps, duplicate groups, and one 60-second audio preview. Require a morning approval before any Telegram post.

## Build Boundary

Include feed ingestion, snapshots, deduplication, clustering, claim matrices, provenance, editorial review, script, and optional rendering. Exclude open-web scraping, anonymous-source invention, auto-posting, synthetic eyewitness media, and unsupervised breaking-news alerts.

## Existing Products, Building Blocks, and Shortcuts

- [Atom RFC 4287](https://datatracker.ietf.org/doc/html/rfc4287) supplies a standard feed ingestion contract.
- [GDELT DOC 2.0](https://blog.gdeltproject.org/gdelt-doc-2-0-api-debuts/) can broaden story discovery after the allowlist works.
- [Telegram Bot API](https://core.telegram.org/bots/api) provides a later reviewed publication channel.
- [FFmpeg](https://www.ffmpeg.org/documentation.html) assembles audio/video from an approved script and assets.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, feedparser, trafilatura for permitted page extraction, sentence-transformers for clustering, Ollama/DGX inference for structured claims, and FFmpeg. Python has mature feed/NLP tooling; SQLite preserves a replayable overnight ledger.

## Architecture/Data Model

Store `sources`, `feed_entries`, `snapshots`, `story_clusters`, `claims`, `claim_sources`, `contradictions`, `editorial_decisions`, `script_versions`, `media_assets`, and `publish_jobs`. The writer can only consume claims marked publishable; every script sentence links to claim IDs.

## Build Slices

1. Allowlisted feeds, snapshots, dedupe, morning inbox.
2. Clustering, claim extraction, source matrix, contradiction flags.
3. Editorial review, bulletin/script generation, citations.
4. Optional TTS/FFmpeg preview and confirmed Telegram publish.

## Drawbacks/Concerns/Failure Modes

Feed delays, copied stories, bad clustering, source capture failures, and fabricated synthesis can mislead. Preserve raw snapshots, distinguish publication time from event time, require corroboration policies, block unsupported sentences, and show when the pipeline is incomplete.

## Clever Hacks and Simpler Alternative

Start with an “overnight reading queue” that ranks and clusters headlines without summarizing. Add claim extraction only after source capture and deduplication are demonstrably reliable.

## Success Measures

Track duplicate reduction, source coverage, unsupported-sentence count, editor correction time, morning usefulness, publication latency after review, and number of stories correctly withheld.

## Product Path

Personal morning desk → transparent niche newsletter workflow → supervised newsroom product. Before public broadcasts, team accounts, paid feeds, or monetization, run [[Scope Expansion Checklist]] for editorial liability, source rights, media rights, model terms, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#17. Overnight Newsroom]]
- [[Scope Expansion Checklist]]

