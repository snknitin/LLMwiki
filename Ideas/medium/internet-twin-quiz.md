---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: social game
form_factor:
  - local web app
  - shareable quiz
deployment: local authoring plus static hosting
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#8. Internet Twin Quiz]]"
status: concept
---
# Internet Twin Quiz

> Create a playful “how well do you know me?” quiz from owner-selected public profiles and editable fact cards.

## Product Outcome

Transform scattered online signals into a surprising but fair quiz with an answer key and source provenance. The owner controls what appears; friends compete against a bounded digital twin rather than an inferred psychological profile.

## User and Core Workflow

The owner connects or imports sources, reviews extracted fact cards, removes sensitive or stale items, and chooses quiz difficulty. The system generates questions with one defensible answer and plausible distractors, previews them, then exports a link. Results show explanations without exposing hidden source data.

## Demo/Personal V0

Accept a GitHub username and a manually pasted interests file. Create ten approved questions, local gameplay, score breakdown, and shareable static result card. Defer OAuth and public hosting.

## Build Boundary

Include opt-in import, provenance, owner review, question validation, gameplay, and export. Exclude scraping third parties, personality diagnosis, face recognition, visitor tracking, and using private messages.

## Existing Products, Building Blocks, and Shortcuts

- [GitHub REST API](https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api) supplies owner-authorized public coding facts.
- [Spotify’s profile flow](https://developer.spotify.com/documentation/web-api/howtos/web-app-profile) demonstrates permissioned profile access.
- [Strava API](https://developers.strava.com/docs/reference/) is an optional fitness source.
- [Satori](https://github.com/vercel/satori) renders deterministic score cards for sharing.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite/Drizzle, Ollama, Zod validation, and Satori. Store imported data locally and export a minimal static quiz bundle. Structured generation keeps answer correctness testable.

## Architecture/Data Model

Model `owners`, `source_connections`, `source_snapshots`, `fact_cards`, `question_versions`, `answer_options`, `quiz_runs`, and `scores`. Every question points to one approved fact; validators reject duplicate answers, ambiguous dates, and distractors supported by other facts.

## Build Slices

1. Manual facts, question generator, owner preview.
2. Local gameplay, explanations, and result card.
3. GitHub adapter, source refresh, and stale-fact warnings.
4. Optional permissioned providers and static export.

## Drawbacks/Concerns/Failure Modes

The model may create subjective questions or leak sensitive details; provider data can be stale; distractors can become insults. Limit questions to typed templates, add sensitivity labels, require owner approval, and include a delete/export control.

## Clever Hacks and Simpler Alternative

Ask the owner to pick 20 facts from a generated checklist and use deterministic templates such as “Which project did I ship most recently?” This avoids fragile open-ended question generation.

## Success Measures

Measure owner approval rate, answer-key error rate, quiz completion, replay/share rate, fact-removal rate, and the percentage of questions with visible provenance.

## Product Path

Personal party game → open-source quiz generator → hosted social experience. Before public profiles, analytics, multiplayer accounts, or payments, run [[Scope Expansion Checklist]] for consent, identity, provider terms, moderation, and release concerns; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#8. Internet Twin Quiz]]
- [[Scope Expansion Checklist]]
- [[Flex Card Forge]]
