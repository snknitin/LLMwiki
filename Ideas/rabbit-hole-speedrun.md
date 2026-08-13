---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: knowledge game
form_factor:
  - local web game
  - shareable knowledge path
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#24. Rabbit Hole Speedrun]]"
status: concept
---
# Rabbit Hole Speedrun

> Race through a chain of increasingly surprising, source-backed connections without allowing the model to invent the links.

## Product Outcome

Make curiosity replayable. A run begins with a topic, exposes several valid edges at each step, records the chosen path, and ends with a shareable map containing facts and citations.

## User and Core Workflow

Enter a topic and a time/depth target. The system resolves it to an entity, retrieves structured relationships and page snippets, ranks surprising but defensible edges, and presents choices. The player selects a branch, reads a short explanation, and continues. The final path can be replayed or challenged.

## Demo/Personal V0

Use Wikipedia/Wikidata only. Support a six-step run, three choices per step, local cache, source preview, invalid-edge report, timer, and static result card. No arbitrary web search.

## Build Boundary

Include entity resolution, graph retrieval, cited facts, path state, difficulty, replay, and export. Exclude uncited model trivia, unsafe random-web navigation, multiplayer, live competitive leaderboards, and claiming universal “wildness.”

## Existing Products, Building Blocks, and Shortcuts

- [MediaWiki REST API](https://www.mediawiki.org/wiki/API_REST_API/en) supplies page search and content.
- [Wikidata query help](https://www.wikidata.org/wiki/Help:Queries) supports structured relationship retrieval.
- [OpenAlex API](https://docs.openalex.org/) can later expand paths into scholarly works.
- [Satori](https://github.com/vercel/satori) renders the final path card as SVG.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite, a small graph layer with recursive SQL, MediaWiki/Wikidata clients, Ollama for concise explanations, and Satori. Explicit retrieved edges keep correctness auditable; SQLite caches entity/source snapshots.

## Architecture/Data Model

Store `entities`, `source_snapshots`, `edges`, `edge_evidence`, `runs`, `steps`, `choices`, `timers`, and `reports`. Every edge carries source, retrieval time, relation type, and validation state. The model sees only validated edges.

## Build Slices

1. Topic resolution, cached entities, fixed relationship queries.
2. Six-step game loop, path persistence, citations.
3. Surprise ranking, timer, invalid-edge feedback.
4. OpenAlex adapter, challenges, and share card.

## Drawbacks/Concerns/Failure Modes

Entity ambiguity, query-service limits, repetitive hubs, weak source snippets, and sensational ranking can spoil runs. Ask for disambiguation, cache politely, penalize repeated entity classes, expose source context, and optimize for novelty plus support.

## Clever Hacks and Simpler Alternative

Precompute a high-quality graph around 100 seed topics. A curated nightly graph offers faster, safer play and makes “surprise” scoring testable.

## Success Measures

Track completed depth, invalid-edge rate, source opens, repeated-node rate, path shares, replay rate, and player ratings for surprise and trust separately.

## Product Path

Personal curiosity game → open-source knowledge graph toy → hosted challenge platform. Before public profiles, multiplayer, user-generated paths, or monetization, run [[Scope Expansion Checklist]] for source attribution, moderation, API terms, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#24. Rabbit Hole Speedrun]]
- [[Scope Expansion Checklist]]
