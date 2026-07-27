---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: events-and-networking
form_factor:
  - local web app
  - attendee microsite
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#18. AI Event Matchmaker]]"
status: concept
tags:
  - matchmaking
  - events
  - recommendations
---

# AI Event Matchmaker

> Turn five useful answers into a short, explainable “meet these people” list instead of an opaque networking feed.

## Product Outcome

For one event, the organizer imports attendees, sends a five-question intake, and gives each participant three to five introductions with a concrete reason and a suggested opener. The useful artifact is a meeting queue that reduces wandering and awkward cold starts.

The first build is for a small event the owner controls. It does not need a social graph, chat, calendar integration, or a learned recommender.

## User and Core Workflow

1. Organizer creates an event and chooses five questions: role, current project, help sought, help offered, and one personal interest.
2. Attendees open a private link and consent to which answers may be shown.
3. The app normalizes answers, embeds the two “help” fields, and applies hard exclusions such as self, blocked contacts, or same-company-only repetition.
4. A deterministic score ranks candidates by offer/need complement, shared context, and diversity.
5. Each person receives a compact card: who, why, what to ask, and where to meet.
6. A thumbs-up/down and “we met” action records outcome feedback.

## Demo/Personal V0

Use a CSV with 20 synthetic attendees and a local form. Generate top-three matches, an organizer matrix, and printable HTML cards. Include one deliberately poor match to show exclusions and explainability. No accounts: magic event codes are enough for the demo.

## Build Boundary

**MVP:** one event, CSV import, five fixed questions, local embeddings, rule-weighted ranking, consent flags, match cards, and outcome feedback.

**Out:** cross-event identity, public profiles, autonomous introductions, payments, chat, calendar booking, facial recognition, and claims that the model predicts friendship or business success.

## Existing Products, Building Blocks, and Shortcuts

- [pretix](https://github.com/pretix/pretix) and its [orders API](https://docs.pretix.eu/dev/api/resources/orders.html) can replace a custom ticketing/attendee registry when an event already uses it.
- [Sentence Transformers](https://github.com/UKPLab/sentence-transformers) accelerates semantic comparison of short “need” and “offer” answers without requiring a hosted embedding API.
- [vCard RFC 6350](https://datatracker.ietf.org/doc/rfc6350/) replaces a proprietary contact-export format; a match card can download as a standard `.vcf`.

## Free-First Stack

- **UI:** SvelteKit + Tailwind, because a small form and organizer table need little client state.
- **Storage:** SQLite with Drizzle ORM; one file is easy to inspect, reset, and back up.
- **Matching:** Python sidecar with `sentence-transformers`, or Ollama embeddings if already running locally.
- **Jobs:** a plain CLI command or APScheduler; a queue is unnecessary at event scale.
- **Delivery:** localhost plus printable HTML/PDF and optional QR codes.

This split keeps the recommendation logic testable in Python while the attendee experience remains a fast web build.

## Architecture/Data Model

`Event` owns `Question`, `Attendee`, and `Response`. `Consent` controls discoverability per response. `MatchCandidate` stores component scores (`need_offer`, `shared_context`, `diversity`, `penalty`) plus a reason trace. `MatchDecision` stores the final rank, and `Outcome` records met/helpful/skipped.

Scoring should be reproducible: normalize every component to 0–1, publish the weights in the organizer screen, and generate the explanation from stored evidence rather than asking an LLM to invent one.

## Build Slices

1. CSV seed, five-question form, and schema.
2. Exact-keyword baseline with transparent scoring.
3. Local embeddings and offer-to-need cross-matching.
4. Consent/exclusion controls and organizer review.
5. Cards, QR/vCard export, and feedback.

## Drawbacks/Concerns/Failure Modes

- Sparse or jokey answers produce false precision; show confidence and allow “not enough information.”
- Popular attendees can dominate results; cap incoming recommendations and solve as a balanced assignment, not independent top-k lists.
- Sensitive needs may leak. Default each answer to event-only, preview exactly what a match sees, and support immediate deletion.
- Similarity favors people who sound alike. Add complementarity and a diversity constraint, then audit match distribution.
- Organizer imports may contain personal data; retain only the minimum and expire an event automatically.

## Clever Hacks and Simpler Alternative

- The best V0 may be a Google Form export plus a Python script that emits static cards—no live app needed.
- Ask attendees to choose controlled tags before free text. Tags create a reliable baseline; embeddings only break ties.
- Treat matching as a stable-room assignment with per-person capacity so one “celebrity” cannot absorb the graph.
- Let users request a rematch after meeting someone; this turns one batch into a useful event loop.

## Success Measures

- At least 70% of attendees complete the five questions.
- At least 50% of recommendations lead to a recorded meeting.
- Median usefulness rating is 4/5 or better.
- Fewer than 10% of cards are marked irrelevant or uncomfortable.
- Organizer can import, review, and publish 50 attendees in under 20 minutes.

## Product Path

Personal script → organizer dashboard → event-platform integration → multi-event networking product. Future release work must revisit consent, deletion, data-processing terms, and model/runtime licensing without changing the local V0.

## Related Wikilinks

- [[Event Networking Copilot]]
- [[AI Networking Helper]]
- [[Personal CRM and Follow-up Dashboard]]

