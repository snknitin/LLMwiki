---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#1. Personal Signal Intelligence OS]]"
status: concept
difficulty: hard
priority: p0
category: personal intelligence
form_factor:
  - local dashboard
  - scheduled automation
  - Obsidian notes
deployment: desktop plus optional DGX Spark
source_ideas:
  - FreshRSS to Substack daily Z-ai-tgeist
  - authenticated social signal versus noise
  - Telegram-to-Obsidian knowledge capture
tags:
  - local-first
  - rss
  - knowledge-management
  - creator
---

# Personal Signal Intelligence OS

> A private information refinery that turns followed feeds, explicitly connected social sources, and Telegram captures into a trustworthy daily brief, durable second-brain notes, and an optional human-edited newsletter called **Z-ai-tgeist**.

## Product Outcome

Replace several scrolling sessions with one bounded reading session. Every surfaced item should answer: what happened, why it matters to current goals, what evidence supports it, whether it is new, and what action—save, study, write, ignore—belongs next. The system learns from explicit feedback rather than maximizing engagement.

## Personal V0

1. Pull unread and starred FreshRSS items on a schedule.
2. Normalize title, author, URL, timestamp, feed, text, and tags into one local content table.
3. Remove duplicates and cluster coverage of the same story.
4. Rank items using rules plus a local model: goal relevance, source trust, novelty, consequence, and effort to consume.
5. Generate `Daily Signal - YYYY-MM-DD.md` with a ten-minute edition, a deep-reading queue, discarded themes, and source links.
6. Accept Telegram commands such as `/save`, `/why`, `/more-like-this`, and `/noise`.
7. Promote approved items to atomic Obsidian notes with provenance and wikilinks.
8. Generate a separate Substack-ready draft with a human voice pass, citations, image prompt, and final publication checklist.

## Build Boundary

**MVP:** FreshRSS only, one daily run, Markdown output, local feedback buttons, and manual Substack copy/paste.

**Later:** OAuth connectors, hourly alerts, multi-modal posts, newsletter analytics, mobile inbox, and public recommendations.

Do not make unofficial scraping or brittle browser automation the foundation. For WhatsApp, LinkedIn, TikTok, and X, start with official exports, forwarded links, notification emails, or supported APIs. Each connector must show what it can and cannot retrieve.

## Existing Products, Building Blocks, and Shortcuts

- [FreshRSS](https://github.com/FreshRSS/FreshRSS) should remain the feed source of truth; its [Google Reader-compatible API](https://freshrss.github.io/FreshRSS/en/developers/06_GoogleReader_API.html) already exposes streams, subscriptions, unread state, and tags, avoiding a new feed crawler.
- FreshRSS’s official [extensions repository](https://github.com/FreshRSS/Extensions) includes OpenAI-compatible LLM classification and webhook patterns. A first version can install/adapt those extensions and generate Markdown rather than duplicate classification inside another service.
- [RSSHub](https://github.com/DIYgod/RSSHub) can turn many sites into feeds, while [n8n’s self-hosted AI starter kit](https://github.com/n8n-io/self-hosted-ai-starter-kit) supplies n8n, Ollama, Qdrant, and Postgres in one Compose stack. Use either only where it replaces a connector you would otherwise maintain.
- Simplest alternative: a browser share target appends URLs to `Signal Inbox.md`; a scheduled Python script ranks only FreshRSS plus that inbox and writes the daily note.

## Free-First Stack

- **Orchestration:** self-hosted n8n for schedules and approvals; plain Python jobs for deterministic transforms.
- **Service:** FastAPI with Pydantic schemas.
- **Data:** SQLite first, then Postgres; filesystem or MinIO for snapshots; optional Qdrant only after full-text search is insufficient.
- **Models:** Ollama on the workstation for classification and short summaries; vLLM on DGX Spark for batched synthesis; provider adapter for occasional paid long-context/editorial passes.
- **Interface:** local SvelteKit or Next.js review queue; Telegram bot for capture.
- **Publishing:** Markdown/HTML export. Treat Substack as a reviewed editor handoff unless an official supported publishing route is confirmed.

## Core Data Model

`Source`, `Item`, `Cluster`, `Score`, `Goal`, `Feedback`, `Digest`, `Note`, and `PublicationDraft`. Keep the raw source snapshot and content hash so every sentence in a digest can be traced back and reruns are reproducible.

## Build Slices

1. FreshRSS sync with incremental cursor and a fixture-based test set.
2. Deterministic deduplication and rule-based ranking before any LLM.
3. Local-model summary with required inline source IDs.
4. Markdown renderer and morning schedule.
5. Feedback capture and a weekly ranking-weight review.
6. Telegram capture and Obsidian promotion.
7. Newsletter view with editorial checklist and image generation.

## Success Measures

- At least 70% of top-ten items are marked useful after two weeks.
- Daily reading time stays below the chosen budget.
- Every factual claim links to a retrieved source.
- Duplicate coverage occupies one cluster, not multiple slots.
- The system creates at least three genuinely reusable notes or content seeds per week.

## Risks and Rules

Prompt injection can arrive inside feeds; source text is untrusted data and never instructions. Store tokens in a secrets manager, scope connectors read-only, and redact private social content from public drafts. Never auto-publish. A “human voice” step should edit for viewpoint and accuracy, not disguise automated plagiarism.

## Product Path

Start as a personal intelligence dashboard. Later versions could be an open-source local “personal feed compiler,” a hosted niche-research service, or a paid newsletter operations product. The defensible layer is the feedback-trained relevance model and provenance graph, not generic summarization.

## Definition of Done

For fourteen consecutive days, the scheduled job produces a readable, cited brief; feedback changes future rankings; a saved item becomes a linked Obsidian note; and a newsletter draft can be reviewed without reopening the original feeds.

## Related

- [[LongVid Learning Studio]]
- [[Personal Study Curriculum]]
- [[Creator Content Engine]]
- [[Side-Hustle Radar]]
- [[Project Ideas Index]]
