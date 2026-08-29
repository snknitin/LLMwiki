---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#10. Creator Content Engine]]"
status: concept
difficulty: medium
priority: p1
category: creator automation
form_factor:
  - local dashboard
  - scheduled automation
deployment: desktop plus optional DGX Spark
source_ideas:
  - automate X and YouTube content topics with NotebookLM and n8n
tags:
  - creator
  - social-media
  - n8n
  - youtube
---

# Creator Content Engine

> A human-led content operating system that converts a private evidence library into an editorial calendar, platform-specific drafts, video source packs, and learning loops without auto-spamming followers.

## Product Outcome

Build a durable body of work from topics already being studied. The system should surface an evidence-backed angle, identify what is genuinely new, draft several formats in the user’s style, and require a final viewpoint and approval before scheduling.

## Personal V0

- Maintain content pillars, audience questions, examples, forbidden clichés, and voice rules.
- Pull approved ideas from Obsidian and [[Personal Signal Intelligence OS]].
- Score ideas for evidence strength, relevance, novelty, and production effort.
- Turn one approved idea into an X thread, short post, blog outline, YouTube brief, and thumbnail concepts.
- Create a NotebookLM-compatible or local source pack for video research.
- Track publish date, hook, format, effort, impressions, saves, replies, and downstream conversions.
- Run a weekly review that recommends experiments without blindly copying high-impression posts.

## Build Boundary

**MVP:** idea inbox, evidence cards, draft generator, editorial board, manual publishing, and metrics entered or imported after the fact.

**Later:** official platform posting APIs, YouTube production pipeline, image generation, repurposing, and audience CRM. Avoid unofficial browser posting automation and engagement bots.

## Existing Products, Building Blocks, and Shortcuts

- [n8n](https://github.com/n8n-io/n8n) supplies scheduled ingestion, approval queues, webhooks, and platform connectors; use it for deterministic movement between idea, draft, review, and publish states.
- [NotebookLM](https://support.google.com/notebooklm/answer/16164461) can turn curated sources into cited study/audio artifacts, while [[YouTube Learning Center]] produces the reusable video evidence layer.
- [FFmpeg](https://ffmpeg.org/), [Whisper](https://github.com/openai/whisper), and [Remotion](https://www.remotion.dev/docs/) cover local transcription, clipping, captions, and programmable video/cards without a full media SaaS.
- Buffer, Typefully, and Hypefury are product references for calendars and platform publishing. The simpler local version is one evidence-backed essay → five manually approved derivatives, copied manually until posting becomes the real bottleneck.

## Free-First Stack

- **Dashboard:** local Next.js/SvelteKit Kanban and editor.
- **Automation:** self-hosted n8n for ingestion, scheduled briefs, approval steps, and supported APIs.
- **Data:** SQLite/Postgres with immutable source links and versioned drafts.
- **Models:** local text model for ideation/repurposing; paid model only for important editorial passes that win a blind comparison.
- **Media:** FFmpeg, Whisper, ComfyUI, and a template renderer for cards/thumbnails.
- **Publishing:** manual copy/paste first; official OAuth APIs only when cadence justifies maintenance.

## Editorial Contract

Every draft contains a claim ledger: claim, evidence link, confidence, and whether it is opinion. Style retrieval uses only the user’s own writing. The system should ask for the original “so what?” before finalizing, because personal judgment is the part worth publishing.

## Build Slices

1. Content pillars, voice examples, and idea inbox.
2. Evidence-backed draft schema and editor.
3. Multi-format transformations with reusable templates.
4. Editorial calendar and manual publishing packet.
5. Metrics capture and weekly experiment review.
6. Optional approved scheduling through official APIs.

## Success Measures

- Most published pieces originate from stored evidence.
- Editing time per piece declines without voice scores falling.
- Content produces email signups, conversations, or project interest—not only impressions.
- No unreviewed content is published.
- Repeated ideas are detected before drafting.

## Product Path

Start as the content layer over the personal intelligence stack. It could become an open-source “evidence-first creator OS,” a service for expert creators, or a paid multi-channel editorial product. Do not compete as a generic post generator.

Keep this as the editorial calendar and evidence-to-draft core. Build the similar projects as replaceable specialist services: [[Personal Voice Ghostwriter and DM Desk]] for voice and relationships, [[Longform-to-Shorts Studio]] for editing, [[Meta Ad Creative Studio]] for paid creative tests, [[Demand Generation Workbench]] for market experiments, and [[Auto-GTM Engine]] for release orchestration.

## Related

- [[Personal Signal Intelligence OS]]
- [[YouTube Learning Center]]
- [[Personal Library Website]]
- [[Side-Hustle Radar]]
- [[Personal Voice Ghostwriter and DM Desk]]
- [[Longform-to-Shorts Studio]]
- [[Meta Ad Creative Studio]]
- [[Demand Generation Workbench]]
- [[Auto-GTM Engine]]
- [[Project Ideas Index]]
