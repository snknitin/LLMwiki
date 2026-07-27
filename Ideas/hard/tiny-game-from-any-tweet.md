---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: generative interactive media
form_factor:
  - web game generator
  - local creator workbench
deployment: local preview with optional static-site deployment
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#20. Tiny Game from Any Tweet]]"
status: concept
tags:
  - games
  - generative-media
  - virality
---

# Tiny Game from Any Tweet

> Paste a post you own or may reuse, choose a mechanic, and get a tiny browser game whose premise, art direction, copy, and victory condition visibly derive from the source.

## Product Outcome

Produce a playable, shareable 30–90 second game—not an unbounded code-generation demo. Every game uses a constrained runtime and schema, previews locally, attributes its source, and can be rebuilt from the same generation record.

## User and Core Workflow

1. Paste post text and optional image with confirmation of reuse rights.
2. Extract entities, tone, conflict, and an achievable game objective.
3. Rank compatible mechanics such as dodge, collect, clicker, dialogue, or quiz.
4. Generate a typed game manifest, captions, palette, and optional sound prompts.
5. Validate assets and simulate core states before opening a local preview.
6. User edits title, difficulty, attribution, and content warnings.
7. Export a static bundle or publish after an explicit approval.

## Demo/Personal V0

Support plain text only and three mechanics using built-in shapes and sounds. Generate a JSON manifest consumed by one hand-written Phaser runtime. The demo succeeds if five diverse posts produce completable games without generated JavaScript.

## Build Boundary

- In scope: user-provided text, template selection, structured generation, local playtesting, attribution, and static export.
- Out of scope: arbitrary generated code execution, scraping private/deleted posts, cloning copyrighted characters, multiplayer, accounts, payments, or automatic social posting.
- Refuse harassment-focused games about private people and expose a report/delete path in any public version.
- Never make fetched media a hidden dependency; copy only authorized assets into the export.

## Existing Products, Building Blocks, and Shortcuts

- [Phaser](https://docs.phaser.io/) supplies a mature HTML5 game loop, input, physics, loaders, and scenes; build one runtime rather than generating engines.
- [Cloudflare Pages direct upload](https://developers.cloudflare.com/pages/get-started/direct-upload/) can host immutable static bundles after approval.
- [Convex real-time documentation](https://docs.convex.dev/realtime) offers a future collaboration/leaderboard backend, but V0 needs no server.
- [ElevenLabs text-to-speech](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) can add optional narration later; browser speech synthesis or bundled effects are enough initially.

## Recommended Free-First Stack

- TypeScript, Vite, Phaser, and Zod for the runtime and manifest validation.
- A local model through Ollama for premise-to-schema generation.
- Playwright for smoke tests: launch, input, win/lose transition, restart, and screenshot.
- Sharp or SVG templates for title cards and simple authorized assets.
- Static filesystem storage for V0; add SQLite only for a local game library.

A fixed runtime plus generated data is safer, faster, and easier to debug than asking a model to emit runnable JavaScript.

## Architecture/Data Model

`source_post` links to `generation`, `game_manifest`, `asset`, `validation_run`, `playtest`, and `export`. The manifest contains a versioned mechanic, entities, spawn rates, controls, scoring, timing, copy, palette, attribution, and safety flags. A deterministic seed enables reproduction and regression testing.

## Build Slices

1. Hand-build one runtime with three polished mechanics and JSON fixtures.
2. Add source-text analysis and constrained manifest generation.
3. Validate difficulty bounds, assets, forbidden content, and state transitions.
4. Add editable preview, deterministic seed, and Playwright smoke tests.
5. Export a static zip and optionally deploy an approved build.

## Drawbacks, Concerns, and Failure Modes

- A post may not contain enough structure for a satisfying mechanic.
- Generated difficulty can make a technically valid game boring or impossible.
- Reusing usernames, likenesses, images, or text can create consent and copyright problems.
- Arbitrary asset URLs introduce tracking, availability, and content-safety risks.
- Viral sharing can amplify harassment or political misinformation through parody.

## Clever Hacks and Simpler Alternative

- Let the model select and populate templates; never let it author executable logic.
- Run headless scripted play traces to catch unreachable victory conditions.
- Use geometric SVG characters and palette changes instead of generated art for V0.
- Show three one-sentence game pitches before paying the cost to build one.
- Simplest alternative: generate an interactive share card or branching poll from the post.

## Success Measures

- At least 90% of generated manifests pass schema validation first try.
- Every accepted game can start, reach a terminal state, and restart in automated smoke tests.
- Median generation-to-preview time stays under 30 seconds on local hardware.
- Test users understand controls and objective without explanation.
- Every exported game includes source attribution and an unpublish/delete identifier.

## Product Path

Start as a local creative toy and publish a gallery of user-approved examples. Later add creator templates, remix lineage, branded campaigns, analytics, and paid premium assets or voices. Review engine, asset, font, and model licenses before distribution; those concerns need not block an all-local template prototype.

## Related

- [[AI Roast Battle Room]]
- [[Visual Token Compiler]]
- [[Microsite Factory]]
