---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: personal publishing
form_factor:
  - local journaling dashboard
  - draft publishing agent
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#16. My Agent Posts About Me]]"
status: concept
---
# My Agent Posts About Me

> A private, opt-in observation journal that drafts an occasional post about the owner from explicit, inspectable sources.

## Product Outcome

Help the user notice patterns and publish authentic small stories without turning their computer into a surveillance system. Every draft explains what observations it used and waits for approval.

## User and Core Workflow

The owner enables narrow sources such as completed tasks, selected notes, workouts, or an ActivityWatch summary. A daily job creates candidate observations, suppresses sensitive categories, and suggests zero or one post. The owner can edit, discard, correct the memory, or publish manually.

## Demo/Personal V0

Use a hand-authored daily JSON log for two weeks. Generate a private timeline and one evidence-linked draft per day, with explicit “no worthwhile post today.” Export approved text; do not connect social accounts.

## Build Boundary

Include allowlisted inputs, local observation store, sensitivity filters, evidence-linked drafts, approval, deletion, and memory correction. Exclude keystroke/content capture, private-message reading, covert monitoring, direct auto-posting, and claims about other people.

## Existing Products, Building Blocks, and Shortcuts

- [ActivityWatch](https://github.com/ActivityWatch/activitywatch) can provide local, user-controlled activity summaries.
- [Mastodon statuses API](https://docs.joinmastodon.org/methods/statuses/) supports later visibility and scheduling controls.
- [Bluesky’s post guide](https://docs.bsky.app/docs/tutorials/creating-a-post) documents another explicit publishing adapter.
- [Ollama](https://github.com/ollama/ollama) keeps draft generation local.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, APScheduler, a local HTMX dashboard, and Ollama. Python makes folder/watch adapters easy; a simple web review queue is sufficient; SQLite supports correction and deletion without infrastructure.

## Architecture/Data Model

Model `sources`, `source_events`, `observations`, `sensitivity_labels`, `memory_cards`, `drafts`, `evidence_links`, `reviews`, and `publish_events`. Source adapters emit minimal structured events. The generator receives only approved non-sensitive observations.

## Build Slices

1. Manual daily log, observation timeline, and draft review.
2. Sensitivity filters, corrections, and deletion.
3. ActivityWatch/notes adapters and cadence controls.
4. Optional Mastodon/Bluesky publish action with final confirmation.

## Drawbacks/Concerns/Failure Modes

The agent may overinterpret behavior, expose routines, mention non-consenting people, or create pressure to perform. Prefer factual language, redact named third parties, default to private, allow “skip,” and expire detailed raw observations.

## Clever Hacks and Simpler Alternative

A daily prompt—“What did I finish, learn, and enjoy?”—may produce better material than passive sensing. Generate a weekly digest first; only promote one sentence into a post when it remains meaningful.

## Success Measures

Track draft acceptance, corrections per draft, sensitive-item catches, days intentionally skipped, time saved, regret/deletion rate after review, and whether posts still sound like the owner.

## Product Path

Private reflection tool → creator drafting assistant → controlled personal publishing product. Before connected accounts, audience analytics, shared data, or payments, run [[Scope Expansion Checklist]] for privacy, identity, platform terms, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#16. My Agent Posts About Me]]
- [[Scope Expansion Checklist]]
