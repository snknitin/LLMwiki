---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - New Personal Workflows and Product Ideas#3. Shortform Signal Digest]]"
status: concept
difficulty: hard
priority: p0
category: personal social intelligence
form_factor:
  - local dashboard
  - scheduled automation
  - browser capture
deployment: desktop plus optional DGX Spark
source_ideas:
  - hourly personalized short-form feed checks
  - end-of-day trend and event digest
  - preference learning from explicit usefulness feedback
  - grounded engagement drafts using personal experience
tags:
  - short-form
  - digest
  - social-media
  - attention
  - personalization
---

# Shortform Signal Digest

> A private feed observer that samples the short-form accounts and feeds you already use, consolidates the day into trends and noteworthy items, and learns from explicit feedback so you can read once instead of scroll all day.

## Product Outcome

Run capture jobs throughout the day but deliver one bounded report. The digest separates events, original information, useful techniques, repeated takes, entertainment, and noise. It is personalized to the user’s follows and interactions rather than a generic news summary.

The system may prepare suggested replies, questions, saves, or follows, but each suggestion must show the source context and which user experience it is drawing from. It should ask for missing personal context instead of inventing a viewpoint.

## Personal V0

Choose one platform and one week:

1. Capture a small sample of the user’s feed at three scheduled times through an authenticated browser session or manual export.
2. Normalize author, post URL/ID, timestamp, text/caption, media metadata, engagement counts, and capture position.
3. Retrieve captions/transcripts for only the shortlisted media.
4. Deduplicate reposts and cluster discussion of the same event or idea.
5. Generate an evening brief with ten items, five themes, three disagreements, and an explicit discarded/noise section.
6. Collect `useful`, `known`, `noise`, `follow`, and free-text feedback.
7. For selected items, ask one question about the user’s experience before drafting a reply or post angle.

## Build Boundary

**MVP:** one platform, scheduled sampling, text/metadata capture, selective transcription, clustered daily report, explicit feedback, and draft-only engagement suggestions.

**Later:** several platforms, image/video understanding, urgent alerts, approved engagement actions, creator-opportunity detection, and a mobile inbox.

This is a briefing product. The separate [[Deliberate Feed Gate]] controls live consumption, while [[X Like-to-List Builder]] and [[Social Subscription Curator]] reorganize sources.

## Existing Products, Building Blocks, and Shortcuts

- [Playwright](https://playwright.dev/) can drive a personal logged-in browser profile and capture rendered feed items where an export or supported API is insufficient.
- TikTok’s official [Display API](https://developers.tiktok.com/doc/display-api-overview/) exposes a user’s profile and selected/own public videos, not the personalized For You feed or saved collections. A user-controlled browser capture adapter is therefore a technically necessary personal path for those surfaces.
- [yt-dlp](https://github.com/yt-dlp/yt-dlp), [Whisper](https://github.com/openai/whisper), and FFmpeg cover selected short-video metadata, transcription, and frame sampling.
- [gallery-dl](https://github.com/mikf/gallery-dl) is a useful cookie-backed cross-site extractor for supported personal surfaces; isolate it behind an adapter because extractors change.
- [FreshRSS](https://github.com/FreshRSS/FreshRSS), [RSSHub](https://github.com/DIYgod/RSSHub), and [[Personal Signal Intelligence OS]] already provide reusable ingestion, deduplication, provenance, and reporting primitives.
- [n8n](https://github.com/n8n-io/n8n) or APScheduler can run bounded capture windows and the daily synthesis job.
- Feedly AI, Readwise Reader, Artifact-style news readers, and social listening products are useful references. The differentiator is an owned personalized feed sample, explicit attention cost, and user-grounded response drafting.

## Recommended Free-First Stack

- Python/Playwright site adapters with saved raw HTML/JSON snapshots and fixture tests.
- SQLite + FTS5 and Parquet for normalized items; local object folder for selected media.
- sentence-transformers for embeddings; local Ollama/llama.cpp for classification; vLLM on DGX for batch summaries.
- SvelteKit dashboard plus Markdown daily briefs.
- n8n/APScheduler for collection and daily run.
- Model outputs constrained into topic, novelty, evidence, attention cost, and suggested action fields.

## Architecture and Data Model

`FeedCapture` records platform, time, adapter version, and sampling rule. `FeedItem` stores source identity, content hash, text/media route, and provenance. `StoryCluster` links related items and identifies earliest observed source. `PreferenceEvent` stores explicit feedback with current goal/context. `DigestEdition` stores inclusion/exclusion reasons. `EngagementDraft` references exact item spans plus approved personal-memory IDs.

Maintain two models: a long-term interest profile and a short-lived current-goals profile. A topic can be interesting in general but irrelevant this week.

## Build Slices

1. One-site capture adapter and replayable fixtures.
2. Normalization, deduplication, and searchable inbox.
3. Topic/event clusters and basic daily Markdown.
4. Explicit feedback and ranking evaluation.
5. Selective transcript/frame enrichment.
6. User-context questions and grounded reply drafts.
7. Second platform only after the first remains stable for two weeks.

## Drawbacks, Concerns, and Failure Modes

- Personalized feeds can change between captures and differ by session state. Treat the sample as “what was observed,” not a complete feed archive.
- Hourly capture can ingest massive low-value media. Store metadata/text first and enrich only ranked candidates.
- The system can reproduce the platform’s engagement bias. Train on post-consumption usefulness, not position or raw likes.
- Summaries of short videos miss visual demonstrations. Record whether text, audio, or frames were analyzed.
- Drafted engagement can become generic or falsely personal. Require an evidence link to an actual user note or ask a question.
- Connector maintenance can overwhelm the product. Keep a manual URL/dropbox path for every platform.

## Clever Hacks and Simpler Alternative

- Start with notifications, email digests, saved collections, and manually forwarded links instead of feed automation.
- Sample the first 30 items at three fixed times rather than attempting continuous capture.
- Create a “network narrative versus underlying sources” split to expose repeated commentary.
- Show only one representative per cluster, with an expandable pile of reactions.
- Ask the user to select three useful items nightly; this is a higher-quality signal than hundreds of passive clicks.

## Success Measures

- Daily report fits the chosen reading budget and replaces at least one scrolling session.
- Useful-item precision improves on held-out days after feedback.
- Every item links to the observed source and states the extraction route.
- Duplicate commentary is collapsed without hiding meaningful disagreement.
- Engagement drafts contain no invented personal claims.

## Product Path

Single-platform personal digest -> cross-platform attention briefing -> creator/research social radar -> configurable local-first product. Public operation and third-party accounts invoke [[Scope Expansion Checklist]], without changing the personal adapter-and-provenance core.

## Related

- [[Personal Signal Intelligence OS]]
- [[Deliberate Feed Gate]]
- [[X Like-to-List Builder]]
- [[Social Subscription Curator]]
- [[Creator Content Engine]]
- [[Project Ideas Index]]
