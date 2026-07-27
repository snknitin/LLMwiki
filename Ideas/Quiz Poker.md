---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#15. Quiz Poker]]"
status: concept
difficulty: medium
priority: p2
category: multiplayer learning game
form_factor:
  - web app
  - mobile PWA
deployment: local network or hosted
source_ideas:
  - quiz poker bidding game like Kahoot or Codenames
tags:
  - quiz
  - multiplayer
  - confidence
---

# Quiz Poker

> A points-only multiplayer quiz game where players wager confidence, manage a finite stack, and sometimes bluff—turning calibration and risk judgment into part of the learning.

## Product Outcome

Players answer privately and allocate confidence points. Correct, high-confidence answers earn more; confident errors hurt. Special rounds allow plausible false answers or team insurance. The design should reward calibrated knowledge, not only speed.

## Personal V0

- Host creates a local room and chooses a reviewed question pack.
- Players join with a code and receive the same question.
- Submit answer plus confidence wager before the server deadline.
- Commit answers before reveal and score on the server.
- Support numeric tolerances, aliases, partial credit, and host adjudication.
- Show calibration: accuracy by confidence band.
- Run a five-round game with comeback mechanics that do not erase skill.

## Build Boundary

**MVP:** four to twelve players, points only, private rooms, reviewed questions, server-authoritative timer/scoring, and no accounts.

**Later:** teams, bluff rounds, async classrooms, generated draft questions with review, tournaments, and public rooms. Money, deposits, cash-out, purchasable chips, and cash-equivalent prizes are excluded from the personal game.

## Existing Products, Building Blocks, and Shortcuts

- Kahoot, Quizizz, Jackbox, and Codenames are product references for room codes, host displays, reveal pacing, bluff rounds, and accessible party play.
- [Supabase Realtime](https://supabase.com/docs/guides/realtime) or Socket.IO can supply rooms, presence, broadcasts, and reconnect; a local WebSocket server is enough for a home game.
- Use a versioned question JSON schema and server-authoritative timer/scoring. A commit hash before reveal makes answers auditable without sophisticated anti-cheat.
- Simplest alternative: points-only confidence wager over five reviewed questions on one Wi-Fi network. Calibration charts after the game create a learning feature distinct from speed trivia.

## Free-First Stack

- **Client:** responsive TypeScript PWA.
- **Realtime:** Socket.IO/PartyKit or Supabase Realtime; a simple local WebSocket server is enough for friends.
- **Server/data:** Node/TypeScript and SQLite/Postgres.
- **Protocol:** append-only room events, answer commitments, server time, and reconnect state.
- **Question format:** versioned JSON with source, accepted answers, tolerance, explanation, and adjudication notes.
- **Models:** local model may draft questions, but packs require human review.

## Clever Hacks and Simpler Alternative

- Start as a host-screen game on one Wi-Fi network.
- Normalize wagers by remaining stack so cautious/new players still act.
- Hash commitments before reveal for an auditable event log.
- Use team insurance tokens and a planned comeback round instead of randomness.
- Show confidence calibration after the game; that is a meaningful learning artifact.

## Build Slices

1. Room protocol, join flow, and server timer.
2. Answer/wager/commit/reveal/scoring.
3. Reconnect and host adjudication.
4. Calibration report and reviewed pack editor.
5. Team/bluff variants.

## Battle-Testing Gates

- Simulated late/duplicate/disconnected messages do not corrupt scores.
- Server time, not client time, determines deadlines.
- Ambiguous questions have an adjudication path and version history.
- A full game survives host/client refresh.
- Playtests measure runaway leaders, downtime, and perceived fairness.

## Product Path

Use it for friends and study groups first. A hosted classroom/party product is feasible after question quality, moderation, and multiplayer reliability are demonstrated.

## Related

- [[Personal Study Curriculum]]
- [[Playo Elo Sports Network]]
- [[Live Chess Tutor]]
- [[Project Ideas Index]]
