---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: viral-diagnostic
form_factor:
  - local microsite
  - shareable result card
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#1. AI Founder Archetype Quiz]]"
status: concept
tags: [quiz, founders, viral]
---

# AI Founder Archetype Quiz

> A fast, funny founder quiz whose result is reproducible enough to share and useful enough to suggest a next experiment.

## Product Outcome

Answer 12 questions and receive an archetype, strengths, predictable failure mode, complementary collaborator, and one practical challenge. The entertainment layer earns the share; deterministic scoring makes the result feel coherent.

## User and Core Workflow

1. Answer weighted multiple-choice questions across risk, craft, sales, pace, and decision style.
2. See a live progress state and optionally add one sentence about the current idea.
3. Code calculates dimension scores and chooses an archetype.
4. A local model writes a personalized explanation constrained to those scores.
5. Export a PNG card and restart or compare with a friend.

## Demo/Personal V0

Six archetypes, 12 questions, deterministic scoring, one local narrative call, and a static result card. No accounts or database.

## Build Boundary

**MVP:** fixed questionnaire, scoring tests, six result templates, optional free-text flourish, PNG export.

**Out:** psychological diagnosis, investor-worthiness claims, hiring recommendations, public rankings, or a learned model.

## Existing Products, Building Blocks, and Shortcuts

- [XState](https://github.com/statelyai/xstate) replaces ad hoc step/branch/restart logic.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) constrains optional personalization to a validated result schema.
- [Satori](https://github.com/vercel/satori) plus [resvg-js](https://github.com/thx/resvg-js) turns JSX into SVG/PNG cards without canvas code.

## Free-First Stack

Vite + React + TypeScript + XState; plain JSON question bank; local Ollama only for prose; Satori/resvg for cards; static deployment or localhost. This remains a front-end project with no backend burden.

## Architecture/Data Model

`Question` has weighted `Option`s. `QuizRun` yields five dimension scores. `ArchetypeRule` maps score ranges to a result. `ResultCard` stores template version and optional narrative. Persist nothing by default.

## Build Slices

1. Question bank, score rules, and tests.
2. Multi-step UI and deterministic result.
3. Share-card renderer.
4. Optional local narrative and analytics-free share flow.

## Drawbacks/Concerns/Failure Modes

- Archetypes have no objective truth; label them entertainment/reflection.
- Results feel generic if questions do not force trade-offs.
- Model prose may contradict scoring; pass only the selected evidence and validate fields.
- Share cards can overclaim; include dimension bars and playful language.

## Clever Hacks and Simpler Alternative

Skip the model entirely for V0: write six excellent result templates and interpolate the two strongest dimensions. Add one “prove us wrong this week” challenge to create lasting value.

## Success Measures

- Completion rate above 70%.
- Same answers always yield the same archetype.
- Result arrives in under one second without the model.
- Test users call the result both recognizable and shareable.

## Product Path

Static quiz → themed quiz engine → lead magnet/template product → team workshop. Future commercial scope should audit model/card-renderer licenses and avoid employment or clinical claims.

## Related Wikilinks

- [[Startup Idea Dating Profile]]
- [[Compatibility Duet]]

