---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: community-operations
form_factor:
  - local dashboard
  - messaging-platform assistant
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#25. Community Ops Agency]]"
status: concept
tags:
  - community
  - moderation
  - operations
---

# Community Ops Agency

> A human-supervised operations desk that turns one community’s rules, events, and activity into a repeatable weekly system.

## Product Outcome

Import community rules, a member/onboarding sample, events, and recent messages. The app produces an onboarding checklist, moderation decision tree, event calendar, weekly digest, unanswered-question queue, and three low-pressure engagement prompts. It is an operating kit, not an autonomous moderator.

## User and Core Workflow

1. Owner defines purpose, audience, house rules, escalation contacts, and platform.
2. Import an export/API sample or paste selected threads.
3. Classify messages into question, resource, win, risk, event, and noise with evidence links.
4. Draft digest, event reminders, onboarding copy, and suggested moderation actions.
5. Human reviews every external action; approved artifacts are copied or posted.
6. Track unanswered questions, repeat incidents, event attendance, and member feedback.

## Demo/Personal V0

Use a synthetic Discord/Discourse export with 100 messages. Generate a Markdown weekly digest, a moderation queue, an ICS event file, and onboarding page. No live posting or deletion.

## Build Boundary

**MVP:** one community, manual JSON/CSV import, local classification, configurable rules, digest/onboarding/event exports, suggestion-only moderation.

**Out:** autonomous bans/deletions, surveillance of private groups, identity scoring, cross-community profiles, sentiment-based punishment, payments, and full multi-tenant agency operations.

## Existing Products, Building Blocks, and Shortcuts

- The [Discord API](https://docs.discord.com/developers/reference) replaces browser automation for a future bot and provides versioned REST/Gateway interfaces.
- [Discourse API](https://docs.discourse.org/) exposes posts, topics, site categories, private messages, and calendar events, accelerating forum integration.
- The [Matrix Client-Server API](https://spec.matrix.org/latest/client-server-api/) is an open option for sending messages, rooms, and synchronized history.
- [n8n](https://github.com/n8n-io/n8n) can replace custom integration glue and supports self-hosting plus human approvals; its fair-code terms should be revisited only if product scope expands.

## Free-First Stack

- **Dashboard:** FastAPI + HTMX for queues, rules, previews, and approvals.
- **Data:** SQLite plus filesystem imports.
- **Model:** Ollama structured classification and drafting.
- **Automation:** APScheduler for local reminders; ICS export before calendar APIs.
- **Integrations:** platform adapters behind a common interface; manual export/import first.
- **Evaluation:** a labeled set of 50 messages for moderation/digest checks.

## Architecture/Data Model

`Community` owns `PolicyRule`, `EscalationPath`, `Member`, `Event`, and `Message`. `MessageLabel` references text spans and model/rule versions. `ModerationSuggestion` stores rule ID, evidence, severity, and approval. `DigestIssue` contains approved blocks. `ActionLog` records only human-confirmed actions.

## Build Slices

1. Community brief, rules, and synthetic import.
2. Deterministic keyword/rule queue.
3. Local classification with evidence and confidence.
4. Digest, onboarding, ICS, and engagement templates.
5. Read-only platform connector; write actions remain approval-gated.

## Drawbacks/Concerns/Failure Modes

- Models miss context, dialect, sarcasm, and reclaimed language. Suggestions need evidence and human judgment.
- A noisy engagement metric rewards shallow posting. Optimize for answered questions, retained members, and useful events.
- Private conversations contain personal data. Minimize imports, redact identifiers, and define retention.
- Platform permissions and rate limits vary. Start with exports and add one adapter at a time.
- Rules may conflict or be selectively enforced. Version policies and record the exact rule used for a suggestion.

## Clever Hacks and Simpler Alternative

- The most useful V0 is a weekly “unanswered questions + member wins + upcoming events” digest generator.
- Use slash commands to let moderators tag examples; those become the evaluation set.
- Generate ICS and Markdown, universal formats that avoid early API integrations.
- Treat every action as a draft. Approval logs become training/evaluation data later.

## Success Measures

- Weekly prep time falls by at least 50%.
- At least 90% of digest claims link to a source message or event.
- No moderation action is executed without explicit approval.
- Unanswered high-value questions older than 48 hours decline.
- Moderators agree with at least 80% of high-confidence suggestions in the test set.

## Product Path

Personal community kit → single-community operator dashboard → reusable agency templates → multi-client product. Public scope needs platform permission review, retention controls, moderator accountability, and dependency-license review.

## Related Wikilinks

- [[customer-support-agency|Customer Support Agency]]
- [[ai-event-matchmaker|AI Event Matchmaker]]
