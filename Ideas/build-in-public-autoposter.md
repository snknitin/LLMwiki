---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: social-automation
form_factor:
  - local dashboard
  - scheduled automation
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#21. Build in Public Autoposter]]"
status: concept
tags:
  - github
  - social-media
  - writing
---

# Build in Public Autoposter

> Convert meaningful build evidence into a daily draft, with a human approval gate before anything is posted.

## Product Outcome

The tool reads selected repository activity and short build notes, identifies what changed and why it matters, and creates one honest build-in-public post plus alternate hooks. It should reduce the daily blank-page cost without leaking secrets or turning commit messages into spam.

## User and Core Workflow

1. User allowlists repositories, branches, labels, and excluded paths/keywords.
2. Ingest commits, merged pull requests, releases, and a two-sentence daily note.
3. Collapse mechanical commits and group evidence into one or two product-level changes.
4. Draft platform-specific copy with evidence references and an optional screenshot checklist.
5. Run secret/privacy checks, then present approve/edit/skip.
6. Save the final post and outcome metrics; publishing remains optional.

## Demo/Personal V0

Run a local CLI against one repository’s last 24 hours. Generate a Markdown review page containing a short post, long post, hook alternatives, exact source commits, and redaction warnings. Copy to clipboard manually rather than connecting social APIs.

## Build Boundary

**MVP:** one GitHub repository, daily manual/cron run, commits plus user note, deterministic filtering, local drafting, approval screen, Markdown history.

**Out:** automatic posting by default, engagement pods, fabricated milestones, cross-platform analytics, image generation, inbox/reply automation, and private repository access beyond the owner’s explicit allowlist.

## Existing Products, Building Blocks, and Shortcuts

- GitHub’s [commits REST endpoints](https://docs.github.com/en/rest/commits) replace shell parsing when the tool later runs remotely.
- GitHub [push webhook payloads](https://docs.github.com/en/webhooks/webhook-events-and-payloads) replace polling for an event-driven version.
- Mastodon’s [statuses API](https://docs.joinmastodon.org/methods/statuses/) supports posting and idempotency keys, making it a good first optional publisher.
- The [X API pricing documentation](https://docs.x.com/x-api/getting-started/pricing) makes current paid usage explicit; manual copy/paste is the free-first choice.

## Free-First Stack

- **Ingestion:** local `git log --numstat` first; PyGithub or GitHub REST only when needed.
- **App:** Python + Typer CLI and a small Streamlit review page.
- **Model:** Ollama structured output with a restrained personal style guide.
- **Storage:** SQLite for runs/approvals and Markdown for durable post history.
- **Scheduling:** Windows Task Scheduler or cron.
- **Safety:** regex/entropy secret scanner plus path and keyword denylist.

Local Git is faster, more private, and avoids API limits. A web dashboard is useful only for review, not as the ingestion backbone.

## Architecture/Data Model

`SourceEvent` stores repository, commit/PR ID, author, files, stats, and sanitized message. `BuildNote` captures intent and learning. `StoryCluster` groups related events. `Draft` references clusters and style version. `SafetyFinding` blocks approval. `Publication` stores target, final text, timestamp, and external ID.

The draft must be traceable: every factual sentence should point to a build note or source event.

## Build Slices

1. Local Git ingestion and exclude rules.
2. Event clustering and rule-based digest.
3. Style-constrained draft generation.
4. Safety scan and approval/history UI.
5. Optional Mastodon publisher with idempotency.

## Drawbacks/Concerns/Failure Modes

- Commit messages are implementation detail, not a story; always ask “why this mattered.”
- Private filenames, customer names, tokens, or security fixes can leak. Default private repos off, scan before model input, and require approval.
- Daily cadence can reward noise. Permit “no post today” and prefer weekly synthesis when evidence is weak.
- Model voice becomes generic. Keep a user-edited style file and learn only from explicitly approved posts.
- API policies and pricing move; isolate publishers behind adapters.

## Clever Hacks and Simpler Alternative

- A pre-commit or end-of-day prompt that asks two questions may improve content more than better generation.
- Generate a “proof packet” first—commits, screenshots, numbers—then write from it.
- Use Conventional Commit types or PR labels as high-signal filters.
- Save unused good facts to a backlog so low-activity days do not force filler.

## Success Measures

- Draft review takes under five minutes.
- Zero posts are published without explicit approval.
- Zero secrets or excluded paths enter stored prompts.
- At least 60% of generated drafts are usable after light edits.
- Posting frequency does not exceed days with meaningful source evidence.

## Product Path

Personal drafting CLI → local multi-project dashboard → team changelog/content assistant → optional paid publisher. Future scope must track each network’s API terms, automation rules, and pricing.

## Related Wikilinks

- [[x-profile-autopsy|X Profile Autopsy]]
- [[Auto-GTM Engine]]
