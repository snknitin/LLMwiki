---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: negotiation-game
form_factor:
  - mobile-first web game
  - shareable score card
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#8. Haggle Score]]"
status: concept
tags: [game, negotiation, viral]
---

# Haggle Score

> A deterministic bargaining game where the rule engine owns price and scoring while the model performs the shopkeeper.

## Product Outcome

Negotiate a fictional item from list price toward a hidden reservation price. The score rewards useful tactics—anchoring, questions, calibrated concessions, and walking away—rather than simply the lowest price.

## User and Core Workflow

1. Choose scenario/difficulty and see constraints.
2. Send an offer or tactic.
3. A parser maps the message to allowed actions.
4. The rule engine updates patience, concession budget, price, and state.
5. The local model voices the deterministic outcome in character.
6. Finish with score breakdown, coaching, and challenge card.

## Demo/Personal V0

Three scenarios, typed negotiation, hidden reservation price, six turn limit, deterministic scoring, one shopkeeper voice, and PNG result.

## Build Boundary

**MVP:** fictional prices, finite-state game, tactic classifier, model dialogue, coaching/card.

**Out:** real purchase execution, live product prices, financial advice, deceptive real-world scripts, multiplayer marketplace, or model-controlled scoring.

## Existing Products, Building Blocks, and Shortcuts

- [XState](https://github.com/statelyai/xstate) models offer, counter, concession, walk-away, and terminal states.
- [Ollama tool calling](https://docs.ollama.com/capabilities/tool-calling) lets dialogue request legal engine actions without controlling price.
- [Satori](https://github.com/vercel/satori) plus [resvg-js](https://github.com/thx/resvg-js) produces score/challenge cards.

## Free-First Stack

Vite/React/TypeScript + XState + local Ollama + Satori/resvg. Use JSON scenarios and optional localStorage leaderboard; no backend.

## Architecture/Data Model

`Scenario` defines list/reservation prices, patience, allowed tactics, and concession curve. `Turn` stores user text, parsed action, engine result, and dialogue. `ScoreBreakdown` is computed from tactics, outcome, and efficiency.

## Build Slices

1. State machine and scripted UI.
2. Deterministic scoring and tests.
3. Tool-called character dialogue.
4. Coaching and share card.

## Drawbacks/Concerns/Failure Modes

- Prompt injection can break character; engine ignores unrecognized actions.
- Lowest price is a poor lesson; reward relationship and walk-away quality.
- Generated dialogue may stereotype vendors; use fictional settings and review scripts.
- Scenarios can feel solved after one run; vary constraints, not arbitrary model behavior.

## Clever Hacks and Simpler Alternative

Use buttons for tactics plus optional free text. This makes the game reliable while the model adds flavor. A fully scripted first scenario can validate fun before any inference.

## Success Measures

- Identical action sequences produce identical outcomes.
- Every turn maps to a legal state transition.
- Players understand their score breakdown.
- Median completion stays under five minutes.

## Product Path

Local web game → challenge links → negotiation practice packs → training product. Future scope needs content/safety review and model/card license audit.

## Related Wikilinks

- [[AI Founder Archetype Quiz]]
- [[Startup Idea Dating Profile]]

