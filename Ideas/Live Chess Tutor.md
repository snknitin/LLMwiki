---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#3. Live Chess Tutor]]"
status: concept
difficulty: hard
priority: p2
category: games and learning
form_factor:
  - desktop app
  - mobile board
deployment: local-first
source_ideas:
  - chess tutor that teaches during moves rather than only after the game
tags:
  - chess
  - tutoring
  - engine
---

# Live Chess Tutor

> A guided-practice chess board that intervenes during training games with questions, concepts, and adjustable hints, while remaining completely separate from rated or third-party competitive play.

## Product Outcome

Instead of showing an engine score after the game, the tutor notices a teachable moment before the move is committed: hanging piece, forcing sequence, pawn break, weak square, time-management issue, or plan mismatch. It asks the learner to reason, then reveals hints progressively.

## Personal V0

- Play against Stockfish inside the app or solve a position from a personal game.
- Before selected moves, ask “checks, captures, threats?” or a concept-specific question.
- Offer three hint levels: focus area, candidate moves, and line.
- Track the learner’s stated candidate moves and evaluation.
- Adjust intervention frequency to avoid stopping every turn.
- After the game, show which concepts required help and schedule similar positions.
- Support “guess the master move” from licensed/public game data.

## Build Boundary

**MVP:** local board, unrated games against an embedded engine, blunder guard, hint ladder, and concept log.

**Never:** an overlay, extension, or process that assists moves on a live third-party rated board. The app should disable tutoring in imported live-play contexts and make fair-play boundaries explicit.

## Existing Products, Building Blocks, and Shortcuts

- Lichess Analysis/Studies and Chess.com Game Review are product references for engine-backed explanations after a game; the gap is progressive questioning during a sandbox game.
- [Stockfish](https://github.com/official-stockfish/Stockfish) supplies UCI analysis, principal variations, MultiPV, and adjustable limits. [chess.js](https://github.com/jhlywa/chess.js) handles legal moves/notation, while [Chessground](https://github.com/lichess-org/chessground) provides a mature board UI.
- Lichess publishes clear [fair-play rules](https://lichess.org/page/fair-play), so the local tutor should only play against its own engine or analyze completed PGNs.
- Simplest alternative: local PWA against Stockfish where hints escalate from motif → candidate pieces → line. The LLM verbalizes board facts and verified engine lines; it never analyzes raw prose alone.

## Free-First Stack

- **Client:** Tauri desktop app with a TypeScript chessboard.
- **Rules:** chess.js or a native chess library for legal moves and PGN/FEN.
- **Engine:** Stockfish through UCI, with configurable depth and MultiPV.
- **Tutor logic:** deterministic tactical detectors plus tagged position patterns; local LLM only renders explanations from verified engine lines.
- **Data:** SQLite for positions, attempts, hints, and concept mastery.
- **Testing:** curated FEN fixtures for forks, pins, overloaded defenders, and quiet moves.

## Teaching Logic

Engine centipawns do not directly explain human plans. Convert analysis into a structured evidence object: best candidates, tactical motifs, vulnerable squares, changed material, and principal variations. The language model may explain that object but cannot invent a line that the engine did not verify.

## Build Slices

1. Board, legal moves, engine opponent, and PGN save.
2. Evaluation swing detector and progressive hints.
3. Candidate-move capture and post-game concept report.
4. Motif classifiers and spaced position review.
5. Adaptive intervention policy and voice mode.

## Success Measures

- Hint explanations reproduce legal, engine-checked lines.
- Intervention rate declines as a concept improves.
- The learner identifies candidate moves before requesting the final hint.
- No integration can be used as a live rated-play assistant.

## Product Path

A personal tutor can become an open-source study board, school tool, or paid adaptive curriculum. Product value comes from timing and pedagogy; Stockfish analysis alone is abundant.

## Related

- [[Personal Study Curriculum]]
- [[LeetCode Pattern Curriculum]]
- [[Quiz Poker]]
- [[Project Ideas Index]]
