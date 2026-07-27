---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: viral-idea-validator
form_factor:
  - local microsite
  - shareable card
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#16. Startup Idea Dating Profile]]"
status: concept
tags: [startups, validation, viral]
---

# Startup Idea Dating Profile

> Reframe a startup idea as a witty dating profile, then attach one serious validation experiment.

## Product Outcome

The founder enters idea, customer, pain, current alternative, and distribution channel. The tool returns “looking for,” green flags, red flags, toxic trait, ideal customer match, evidence gaps, and a next validation experiment. The card creates curiosity; the experiment creates utility.

## User and Core Workflow

1. Paste idea and answer four required facts.
2. Validate missing evidence and ask one clarification.
3. Generate a structured profile constrained to entered facts.
4. Separate evidence-backed observations from playful speculation.
5. Edit/export card and save the experiment as Markdown.

## Demo/Personal V0

Static form, five required fields, local Ollama JSON, one result layout, PNG export, no database.

## Build Boundary

**MVP:** single idea, structured output, evidence-needed list, one experiment, card.

**Out:** market-size claims, investor scoring, startup success prediction, competitor scraping, public idea storage, or paid validation reports.

## Existing Products, Building Blocks, and Shortcuts

- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) enforces profile and experiment fields.
- [XState](https://github.com/statelyai/xstate) handles short clarification branches/restart.
- [Satori](https://github.com/vercel/satori) plus [resvg-js](https://github.com/thx/resvg-js) generates a consistent shareable profile card.

## Free-First Stack

Vite/React/TypeScript + local Ollama + Satori/resvg. Keep state in the browser and export Markdown/PNG.

## Architecture/Data Model

`IdeaBrief` stores problem, customer, alternative, value, and channel. `ProfileResult` stores comedic fields, evidence gaps, and `ValidationExperiment` with hypothesis/action/signal/timebox. `Card` omits private notes.

## Build Slices

1. Required brief and validation.
2. Structured profile generation.
3. Experiment template.
4. Card/edit/export.

## Drawbacks/Concerns/Failure Modes

- Without evidence, red flags become generic.
- Virality does not imply product willingness to pay.
- Founders may paste sensitive ideas; default to local/no retention.
- Model may present guesses as facts; label evidence gaps.

## Clever Hacks and Simpler Alternative

Write fixed profile templates and let the model fill only tone. Requiring customer, pain, and distribution does more for quality than a larger model.

## Success Measures

- Result cannot generate until the four required facts exist.
- Every serious claim maps to input or is labeled hypothesis.
- User leaves with a time-boxed experiment.
- Card exports in under a second after generation.

## Product Path

Personal idea toy → reusable viral diagnostic engine → incubator workshop tool → validation product. Future scope needs confidentiality, marketing-claims, and model/rendering license review.

## Related Wikilinks

- [[AI Founder Archetype Quiz]]
- [[Roast My Landing Page]]

