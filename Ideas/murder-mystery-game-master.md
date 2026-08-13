---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: social gaming
form_factor:
  - local multiplayer web app
  - chat bot
deployment: local desktop with LAN access
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#15. Murder Mystery Game Master]]"
status: concept
---
# Murder Mystery Game Master

> A deterministic party-game engine that privately assigns fictional roles, releases timed clues, narrates suspects, and produces a satisfying reveal. Like Dungeons and Dragons with AI being the dungeon master. Base some cases on the show Detective Conan and revela how teh case is solved if no one can piece it together. Great mental exercise even for a single player. 

## Product Outcome

Let a host run a 45–90 minute mystery without manually tracking secrets, timers, votes, or clue dependencies. AI adds responsive flavor while the game state remains consistent and replayable.

## User and Core Workflow

The host selects a scenario and player count, edits safety settings, and starts a room. Players receive private role cards, the group sees an opening scene, and timed rounds reveal clues and prompt investigation. Players submit theories and vote; the engine validates reveal conditions and generates a recap.

## Demo/Personal V0

Run one six-player scenario on a local LAN: one host screen, private player URLs, three timed rounds, eight fixed clues, one vote, and a narrated reveal. Use text first; add one fictional suspect voice only after the state machine works.

## Build Boundary

Include authored scenario schema, role privacy, round state, clues, timers, votes, host controls, and recap. Exclude real-person accusations, open-ended evidence generation, cash gambling, public matchmaking, and unsupervised minors.

## Existing Products, Building Blocks, and Shortcuts

- [Telegram Bot API](https://core.telegram.org/bots/api) can later deliver group clues and private role messages.
- [Discord interactions](https://docs.discord.com/developers/platform/interactions) supports commands, buttons, and modals for gameplay.
- [ElevenLabs TTS](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) can voice fictional characters.
- [JSON Schema](https://json-schema.org/specification) validates scenario structure and prevents impossible state.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, Socket.IO, SQLite/Drizzle, JSON Schema, and Ollama for bounded narration. TypeScript and shared schemas keep client/server state aligned; SQLite is enough for local rooms; WebSockets provide immediate round updates.

## Architecture/Data Model

Store `scenarios`, `characters`, `roles`, `clues`, `conditions`, `rooms`, `players`, `private_assignments`, `rounds`, `events`, `theories`, and `votes`. An append-only event log drives the state machine; narration reads state but cannot mutate it.

## Build Slices

1. Scenario validator and single-screen host simulation.
2. LAN room, private player views, timed clue engine.
3. Theory/vote flow, reveal, and recap.
4. Optional Telegram/Discord adapter and fictional TTS.

## Drawbacks/Concerns/Failure Modes

Leaked roles ruin play; model narration may contradict clues; disconnects stall rounds; and themes can cross comfort boundaries. Keep secrets server-side, generate from fixed facts, allow reconnect, add content controls, and give the host override buttons.

## Clever Hacks and Simpler Alternative

Use QR-coded static role pages and a host-only timer/clue deck. This proves pacing and clue quality before real-time networking or generative dialogue.

## Success Measures

Track completion without host intervention, state inconsistencies, reconnect success, player understanding, reveal satisfaction, average dead time between rounds, and replay requests.

## Product Path

Personal party game → downloadable scenario engine → creator marketplace/social product. Before public rooms, user-created content, voice packs, or payments, run [[Scope Expansion Checklist]] for moderation, rights, privacy, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#15. Murder Mystery Game Master]]
- [[Scope Expansion Checklist]]

