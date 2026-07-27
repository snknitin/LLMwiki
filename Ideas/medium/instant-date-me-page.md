---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: personal publishing
form_factor:
  - static website generator
  - conversational profile
deployment: local authoring plus static hosting
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#6. Instant Date Me Page]]"
status: concept
---
# Instant Date Me Page

> A five-minute owner interview that produces an editable date-me page and a bounded AI wingman grounded only in approved facts.

## Product Outcome

Help the owner express personality, values, availability, and preferred ways to connect without writing from a blank page. Visitors can ask lightweight questions and receive sourced answers or a candid “not specified.”

## User and Core Workflow

The owner completes a short text or voice interview, reviews extracted fact cards, chooses visibility per card, and selects a design. A static site is generated. Visitor questions retrieve approved cards; the wingman answers in a chosen tone and always distinguishes facts from playful phrasing.

## Demo/Personal V0

Use 12 interview questions, five sections, one theme, a preview, and local chat. Publish only static HTML while the conversational wingman runs locally during the demo. Include a one-click “hide this fact” control.

## Build Boundary

Include interview, transcript correction, fact approval, page generation, bounded Q&A, and export. Exclude dating-platform scraping, matchmaking scores, visitor profiling, autonomous messaging, and inference of sexuality, health, or other sensitive traits.

## Existing Products, Building Blocks, and Shortcuts

- [Astro](https://docs.astro.build/) replaces a heavy runtime with a static-first personal site.
- [Ollama](https://github.com/ollama/ollama) provides local extraction and grounded responses.
- [MediaRecorder](https://www.w3.org/TR/mediastream-recording/) supports an optional browser voice interview.
- [Satori](https://github.com/vercel/satori) can generate social preview cards from the approved profile.

## Recommended Free-First Stack with Rationale

Use Astro, TypeScript, SQLite during authoring, Ollama, and a small local FastAPI or Node endpoint for preview chat. Export a static site with a JSON fact bundle; this separates durable publishing from optional model inference.

## Architecture/Data Model

Model `interviews`, `answers`, `fact_cards`, `visibility_rules`, `page_sections`, `themes`, `visitor_questions`, and `answer_traces`. Every fact retains its interview answer and owner approval. Retrieval filters visibility before the model sees context.

## Build Slices

1. Typed interview, fact-card editor, and static page.
2. Voice recording/transcription and source-linked preview.
3. Local wingman with refusal/unknown behavior.
4. Theme options, export bundle, and social card.

## Drawbacks/Concerns/Failure Modes

Over-sharing, hallucinated answers, cringe tone, stale availability, and prompt injection from visitor questions can harm the owner. Default fields private, require approval, constrain retrieved context, escape rendered content, and add an expiry reminder.

## Clever Hacks and Simpler Alternative

Generate a polished single-page Markdown/Astro site plus a curated FAQ. A non-AI “question chips” interface may deliver most of the wingman charm with no runtime or hallucination risk.

## Success Measures

Measure time to publishable preview, percentage of facts accepted, page edits after generation, grounded-answer accuracy, unknown-response correctness, and owner comfort after a one-week review.

## Product Path

Personal page generator → open-source profile kit → hosted personal-site product. Before public chat, visitor analytics, account sharing, or payments, run [[Scope Expansion Checklist]] for identity, privacy, moderation, data rights, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#6. Instant Date Me Page]]
- [[Scope Expansion Checklist]]
- [[Internet Twin Quiz]]

