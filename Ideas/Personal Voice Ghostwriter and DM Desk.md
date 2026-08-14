---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Creator Growth and Local Video Pipelines#2. Personal Voice Ghostwriter and DM Desk]]"
status: concept
difficulty: hard
priority: p0
category: personal writing and relationship operations
form_factor:
  - local writing desk
  - Notion and Obsidian integration
  - message review queue
deployment: local-first
source_ideas:
  - AI ghostwriter in personal voice for X and LinkedIn using a Notion database
  - handle DM interactions with relationship context
tags:
  - ghostwriter
  - voice
  - notion
  - social-media
  - dm
---

# Personal Voice Ghostwriter and DM Desk

> Draft public posts and private replies from the user’s actual knowledge, beliefs, experiences, and writing patterns—while preserving source provenance, relationship context, and the edit history that teaches the system what “sounds like me.”

## Why This Pair Merges Cleanly

Ghostwriting and DM replies need the same primitives: source-note retrieval, voice fingerprint, people/context memory, promises/open loops, claim provenance, draft review, and learning from edits. Public and private writing remain separate modes with different templates and data access, but a single desk avoids two inconsistent versions of the user’s voice.

## Product Outcome

The desk supports three public workflows—turn note into post, react to a saved idea, continue a series—and a private inbox workflow that triages messages, reconstructs relationship context, and drafts a response. Every factual/personal claim points to a Notion/Obsidian source or is flagged for user input.

The system learns from accepted edits. It maintains an inspectable voice card rather than a vague prompt such as “be witty and insightful.”

## Personal V0

- Curate 30–100 strong writing examples and 10–20 deliberately negative examples.
- Index selected Obsidian folders and explicitly shared Notion pages with heading-level provenance.
- Define X, LinkedIn, and private-message voice differences.
- Implement post workflows for one note, one saved idea, and one recurring series.
- Paste a DM thread into a relationship card and generate triage + reply draft.
- Store draft -> edit -> approved/sent diff and propose voice-card updates.
- Produce a daily batch of at most three post drafts and five DM recommendations.

## Build Boundary

**MVP:** source normalization, voice examples/card, provenance-grounded retrieval, post editor, manual DM intake, relationship cards, review/diff learning, and copy/export.

**Later:** Notion incremental sync, X API, LinkedIn Posts API where available, supported DM events, scheduled editorial queues, and a browser capture helper.

The product remains valuable with manual intake and clipboard export; platform connectors are adapters, not the core.

## Existing Products, Building Blocks, and Shortcuts

- Notion’s [block children API](https://developers.notion.com/reference/get-block-children) and [page-content guide](https://developers.notion.com/guides/data-apis/working-with-page-content) support recursive ingestion of explicitly shared pages.
- Obsidian files are local Markdown; its [Vault API](https://docs.obsidian.md/Plugins/Vault) is only needed for live plugin behavior.
- The [X API](https://docs.x.com/x-api/overview) offers posts, Lists, likes, DMs, and [Account Activity webhooks](https://docs.x.com/x-api/account-activity/introduction), but manual/import mode avoids webhook infrastructure in V0.
- LinkedIn’s official [Posts API](https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/posts-api) supports approved publishing paths, while many read/management capabilities require program access.
- Typefully, Hypefury, Taplio, Buffer, Notion AI, and CRM inboxes are product references. The differentiator is source-level truth, personal voice diffs, and relationship/open-loop memory.

## Recommended Free-First Stack

- Tauri or local SvelteKit/Next.js desk.
- SQLite + FTS5 for sources, relationships, drafts, and edits; local embeddings only if measured retrieval improves.
- Direct Obsidian Markdown reader and Notion API adapter with stable content hashes.
- Local model for ordinary drafts; optional paid model behind the same structured-output adapter.
- Diff-match-patch or Git-style text diffs for learning.
- Clipboard/Markdown/Notion export before any publisher API.

## Voice and Relationship Model

`SourceChunk` stores stable URI, heading path, status (`draft`, `belief`, `published`, `deprecated`), timestamp, and hash. `VoiceExample` stores platform, task, annotations, and accepted/rejected status. `VoiceRule` stores pattern, confidence, evidence examples, and user approval. `PersonCard` stores relationship, topics, prior interactions, promises, open loops, and do-not-forget notes. `WritingDraft` stores task, source IDs, style examples, unsupported-claim flags, edit diff, and final status.

Retrieve topical evidence and stylistic examples separately. A semantically relevant technical note may not be a representative LinkedIn style sample.

## Build Slices

1. Curated corpus, negative examples, and voice card.
2. Obsidian/Notion normalization and FTS retrieval.
3. Three post workflows with claim ledger.
4. Edit-diff capture and voice-rule proposals.
5. Manual DM inbox, relationship card, and reply queue.
6. Daily batch brief and series memory.
7. Official platform adapters one at a time.

## Drawbacks, Concerns, and Failure Modes

- Indexing the whole vault worsens voice and truth. Curate sources and store document status.
- Engagement optimization can flatten the user into clichés. Track voice match, novelty, edit effort, and source support.
- Retrieval may treat brainstorming as belief. Filter by status and require claim provenance.
- Relationship summaries can silently drift. Link them to message/source records and make corrections append-only.
- The model may sound overfamiliar in DMs. Platform/private-message templates need their own boundaries and examples.
- Fine-tuning too early hides mistakes. Retrieval + voice card + edit diffs is faster and reversible.

## Clever Hacks and Simpler Alternative

- Start with one Notion database view and one Obsidian folder.
- Use “turn this note into three openings,” not full-post generation, until the voice is good.
- Add `shorter`, `warmer`, `more direct`, and `answer only` controls instead of dozens of tones.
- Require one original judgment/question from the user before finalizing reaction posts.
- Keep a “phrases I never want” negative library.

## Success Measures

- Unsupported personal/factual claims approach zero.
- Edit distance and time-to-approval decline without voice ratings falling.
- Drafts cite the right source ideas and avoid repeating recent posts.
- DM recommendations correctly preserve open loops and promises.
- The user voluntarily publishes/sends a meaningful portion after review.

## Product Path

Private writing desk -> creator relationship OS -> expert/founder writing service -> configurable product. Run [[Scope Expansion Checklist]] before handling other people’s private sources or identities; keep provenance and approval as durable primitives.

## Related

- [[Creator Content Engine]]
- [[Shortform Signal Digest]]
- [[Conversion List Builder]]
- [[Auto-GTM Engine]]
- [[Personal Library Website]]
- [[Project Ideas Index]]

