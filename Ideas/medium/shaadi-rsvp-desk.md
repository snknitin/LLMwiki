---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: event guest operations
form_factor:
  - local dashboard
  - draft messaging assistant
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#28. Shaadi RSVP Desk]]"
status: concept
---
# Shaadi RSVP Desk

> A household-aware Indian wedding RSVP desk that tracks invitations, plus-ones, functions, meals, travel, and follow-up without losing the human host.

## Product Outcome

Produce a trustworthy live headcount and an exception queue. Hosts should know who has replied, for which events, with how many guests and what needs clarification—without searching hundreds of chats.

## User and Core Workflow

Import households and invitation limits, configure functions and questions, then preview a language/tone template. The system stages messages, parses replies into proposed updates, and asks the host to resolve ambiguous names, plus-ones, meal choices, or split attendance. Guests can opt out or request a person.

## Demo/Personal V0

Use 50 synthetic guests across 20 households in a simulated WhatsApp inbox. Support English/Hindi templates, event-by-event attendance, plus-one constraints, meal choices, correction, and a live dashboard. No real sends.

## Build Boundary

Include household model, guest import/dedupe, message drafts, reply parsing, confirmations, correction, exception queue, and export. Exclude invitations design, payment, vendor booking, seating optimization, autonomous mass sending, and scraping contacts.

## Existing Products, Building Blocks, and Shortcuts

- [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api) is the eventual delivery adapter.
- [WhatsApp message templates](https://developers.facebook.com/docs/whatsapp/business-management-api/message-templates) establish the outbound template workflow.
- [Gmail drafts](https://developers.google.com/workspace/gmail/api/guides/sending) offers a simpler review-first pilot channel.
- [SQLite](https://www.sqlite.org/docs.html) is sufficient for one wedding’s relational guest state.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite/Drizzle, Zod CSV imports, a deterministic household state machine, and Ollama for constrained reply parsing. Keep all messaging simulated or draft-only first; relational data is more important than chatbot sophistication.

## Architecture/Data Model

Store `households`, `guests`, `relationships`, `events`, `invitations`, `invite_limits`, `messages`, `reply_proposals`, `attendance`, `meal_choices`, `travel_notes`, and `exceptions`. Proposed changes require review when confidence is low or limits conflict.

## Build Slices

1. CSV import, household dedupe, functions/invitations.
2. Simulated message flow, reply parsing, confirmation.
3. Exception queue, multilingual templates, live counts.
4. Optional WhatsApp/Gmail adapter and coordinator handoff.

## Drawbacks/Concerns/Failure Modes

Indian names and household relationships are ambiguous; forwarded replies create duplicates; plus-one assumptions cause offense; and automated tone can feel impersonal. Preserve raw replies, let hosts correct identity, never infer attendance, and make human takeover obvious.

## Clever Hacks and Simpler Alternative

Generate personalized `wa.me` links for the host to click manually and record replies in the dashboard. This avoids API setup while proving whether household state saves real coordination time.

## Success Measures

Track confirmed headcount accuracy, unresolved exceptions, duplicate identities, host corrections, response time, reminder reduction, guest opt-outs, and coordinator hours saved.

## Product Path

Personal wedding desk → planner toolkit → multi-event guest-operations product. Before live bulk messaging, multi-user planners, vendor sharing, or payments, run [[Scope Expansion Checklist]] for guest consent, personal data, channel terms, and release duties; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#28. Shaadi RSVP Desk]]
- [[Scope Expansion Checklist]]
- [[Event Ops Agency]]
