---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: personal-crm
form_factor:
  - messaging bot
  - local dashboard
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#13. Pocket CRM]]"
status: concept
tags: [crm, reminders, relationships]
---

# Pocket CRM

> Capture a contact, opportunity, and next action in one message; confirm the parse before anything is saved. Posiblt connect this with Dunbar Number in Notion. Mainting 150 relationships privately and rest of the cotnacts as acquaintances. This distinction needs to be made.

## Product Outcome

Send shorthand such as “Priya | logo project | ₹40k | follow up Friday.” The tool extracts a contact/opportunity/reminder, shows the parsed record, and stores it only after confirmation. Daily views answer “who needs attention?”

## User and Core Workflow

1. Send a structured-ish note or use a tiny local form.
2. Parse person, context, amount, stage, next action, and date.
3. Confirm/correct ambiguous fields and timezone.
4. Store minimum useful fields, then schedule reminder.
5. Mark done/snooze/lost/won and add the next action.

## Demo/Personal V0

Telegram self-bot with explicit `/lead name | context | date` syntax, SQLite, daily due list, snooze, and CSV backup. Add free-text parsing later.

## Build Boundary

**MVP:** personal contacts/opportunities, confirmation, reminders, search, export/backup.

**Out:** message-history scraping, team sales CRM, email synchronization, bulk outreach, autonomous follow-ups, contact enrichment, or WhatsApp business onboarding.

## Existing Products, Building Blocks, and Shortcuts

- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) extracts a validated CRM record from shorthand.
- [SQLite](https://www.sqlite.org/about.html) supplies a private serverless single-file database.
- [APScheduler](https://github.com/agronholm/apscheduler) handles one-off follow-ups and recurring stale-lead scans.
- [Telegram Bot API](https://core.telegram.org/bots/api) is an easier personal capture channel than WhatsApp’s business setup.

## Free-First Stack

Python/FastAPI or Node/TypeScript + SQLite + APScheduler + Telegram + local Ollama. Encrypt backups and store extracted CRM facts, not whole conversations.

## Architecture/Data Model

`Person` has aliases and context. `Opportunity` has amount/currency/stage. `InteractionNote` contains minimal user-entered summary. `NextAction` has due/timezone/status. `ParseProposal` is temporary until confirmed.

## Build Slices

1. Explicit command syntax and SQLite CRUD.
2. Reminders/daily due list.
3. Search/export/backup.
4. Free-text parse with confirmation.
5. Tiny dashboard.

## Drawbacks/Concerns/Failure Modes

- Natural-language dates are ambiguous; preview exact timestamp/timezone.
- Contact/deal notes are sensitive; minimize and encrypt backups.
- Reminders duplicate if jobs lack stable IDs.
- The capture channel can become a vendor dependency; keep database/export portable.

## Clever Hacks and Simpler Alternative

Start with pipe-delimited commands. Reliable structure often beats “AI magic,” and the same schema supports local LLM extraction later.

## Success Measures

- Capture/confirm takes under 30 seconds.
- No reminder is saved with an unconfirmed ambiguous date.
- Daily due view matches database state without duplicates.
- Full data exports to readable CSV/JSON.

## Product Path

Personal bot → local relationship dashboard → freelancer CRM → privacy-first paid CRM. Expansion needs contact consent, integrations, access control, and messaging-platform terms.

## Related Wikilinks

- [[Founder Investor Update Writer]]
- [[Build in Public Autoposter]]

