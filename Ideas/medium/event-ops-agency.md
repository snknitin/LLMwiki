---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: event operations
form_factor:
  - local operations dashboard
  - document generator
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#4. Event Ops Agency]]"
status: concept
---
# Event Ops Agency

> Convert an event brief and working spreadsheets into an owned, deadline-aware operations pack with reviewable communications.

## Product Outcome

Give one organizer a live control surface for venue readiness, speakers, run-of-show, sponsors, attendee messages, and recap. The output should reduce dropped handoffs and last-minute search across documents.

## User and Core Workflow

Import an event brief, schedule, speaker list, venue checklist, and sponsor commitments. The system normalizes people and sessions, finds gaps or collisions, generates owner-tagged tasks, and drafts host scripts and audience communications. Changes propagate into a visible “what changed” queue before anything is sent.

## Demo/Personal V0

Run one fictional 100-person meetup from CSV files. Generate a T-minus-seven-day checklist, speaker cards, minute-by-minute host script, sponsor mention matrix, attendee email drafts, and post-event recap.

## Build Boundary

Include imports, task dependencies, schedule checks, document generation, run-of-show view, and message drafts. Exclude ticket sales, badge printing, payment settlement, live venue control, and autonomous broadcast.

## Existing Products, Building Blocks, and Shortcuts

- [pretalx](https://docs.pretalx.org/) accelerates speaker, submission, and schedule management rather than rebuilding them.
- Its [schedule workflow](https://docs.pretalx.org/user/schedule/) demonstrates availability constraints, warnings, and versioned releases.
- Its [email outbox](https://docs.pretalx.org/user/emails/) is the right review-before-send pattern.
- [pretalx API resources](https://docs.pretalx.org/api/resources/) provide a later adapter for speakers, slots, rooms, and submissions.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite/Drizzle, Zod CSV importers, FullCalendar for the run-of-show, Markdown templates, and Ollama for draft generation. This produces a local, inspectable ops database while reusing familiar web components.

## Architecture/Data Model

Model `events`, `venues`, `people`, `sessions`, `schedule_versions`, `tasks`, `dependencies`, `sponsor_deliverables`, `message_drafts`, and `change_events`. Importers create provenance-tagged records; validators calculate conflicts; generators consume only approved records.

## Build Slices

1. Event brief, CSV imports, people/session normalization.
2. Task graph, deadline dashboard, and schedule validation.
3. Host script, speaker cards, sponsor matrix, communication drafts.
4. Day-of mode, change log, and recap generator.

## Drawbacks/Concerns/Failure Modes

Stale spreadsheets produce wrong messaging; duplicate people create confusion; time-zone errors break schedules; and AI prose can invent logistics. Make imports repeatable, show diffs, use canonical IDs and IANA time zones, and block generation when required source fields are missing.

## Clever Hacks and Simpler Alternative

An opinionated event-folder command can be enough: `event build ./event` reads five CSV/Markdown files and writes a static operations site. Only add editing after the generated pack proves useful on a real event.

## Success Measures

Measure unresolved blockers at T-24 hours, missed deliverables, schedule conflicts caught, edit rate on generated messages, time to produce the ops pack, and organizer confidence.

## Product Path

Personal meetup cockpit → repeatable event-agency kit → multi-event operations product. Before public events, multi-user coordination, messaging, or payments, run [[Scope Expansion Checklist]] for attendee data, API terms, release responsibilities, and rights; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#4. Event Ops Agency]]
- [[Scope Expansion Checklist]]
- [[Sponsorship Sales Agency]]
