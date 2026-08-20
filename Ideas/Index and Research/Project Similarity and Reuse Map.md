---
type: architecture-index
status: active
created: 2026-08-14
scope: personal idea portfolio
tags:
  - similarity
  - reuse
  - shared-engines
  - project-architecture
---

# Project Similarity and Reuse Map

This map answers: **If one project works, which other project can reuse its engine, become a tab, or consume its output?** Similarity does not imply one shared release. Each linked spec remains self-contained unless explicitly marked as a merged pair.

## Relationship Types

- **Merged pair:** one spec intentionally covers two ideas with the same job and data.
- **Direct handoff:** one project produces a versioned artifact that another consumes.
- **Shared engine:** separate products reuse adapters, schemas, workers, or evaluation infrastructure.
- **Possible tab:** a combined personal dashboard may expose both, but each still runs alone.
- **Reference only:** useful prior art or code pattern; no runtime coupling.

## Social Feed and Attention Family

| Project | Owns | Reuses or hands off |
|---|---|---|
| [[X Like-to-List Builder]] | one-off/periodic author taxonomy from liked posts | author/topic vocabulary can seed Digest and Subscription Curator |
| [[Shortform Signal Digest]] | capture, clustering, daily report, preference learning | emits ranked `ContentItem` queue to Deliberate Feed Gate |
| [[Social Subscription Curator]] | source portfolio, activity/overlap audit, change plan | shares account adapters and topic vocabulary; remains periodic rather than daily |
| [[Deliberate Feed Gate]] | one-card consumption UI and attention budget | consumes any URL/ranked queue; does not need the Digest to function |
| [[Personal Signal Intelligence OS]] | canonical cross-source research/refinery and Obsidian output | receives approved insights from all four without absorbing their UIs |

**Build order:** X archive/list builder -> manual-capture Digest -> Deliberate Feed Gate -> YouTube Subscription Curator -> additional feed adapters.

**Shared package:** `social-content-core` containing `ContentItem`, `SourceIdentity`, provenance, preference events, adapter health, and archive import helpers.

## Creator, Demand, and Distribution Family

| Project | Owns | Reuses or hands off |
|---|---|---|
| [[Creator Content Engine]] | evidence-backed editorial inbox/calendar and ordinary drafts | possible umbrella dashboard; calls specialist services |
| [[Personal Voice Ghostwriter and DM Desk]] | personal voice, source claims, relationships, replies | transforms approved content/GTM drafts into the user’s voice |
| [[Conversion List Builder]] | evidence-backed audience/candidate hypotheses | sends reviewed contact batches to DM Desk; outcomes return to scoring |
| [[Demand Generation Workbench]] | hypothesis, experiment, evidence hierarchy, continue/revise/stop | produces experiment briefs for Ads, Lists, and Auto-GTM |
| [[Meta Ad Creative Studio]] | paid creative concepts, variants, lineage, result import | calls video lab/renderers; returns creative results to Demand Workbench |
| [[Longform-to-Shorts Studio]] | deterministic source-video clipping and captions | exports approved shorts to Auto-GTM/Creator Engine |
| [[Local Video Generation Evaluation Lab]] | model/runtime selection and reproducible performance evidence | shared renderer registry for Ads, Shorts B-roll, Manga/Animatic, and GTM |
| [[Auto-GTM Engine]] | release manifest, derivative asset graph, approvals, publishing/export | orchestrates all specialists without owning their internal logic |

**Build order:** Creator Content Engine/Voice Desk -> Demand Workbench -> Conversion List Builder -> Longform-to-Shorts -> Auto-GTM -> Meta Ads -> Local Video Lab candidates as specific renderer needs arise.

**Shared packages:**

- `artifact-manifest`: product, audience, claims, proof, release, CTA.
- `content-provenance`: source facts, voice examples, drafts, edits, published URLs.
- `approval-queue`: generated, checked, approved, exported/published, verified.
- `media-runner`: source/render manifest, model/provider adapter, asset hash, cost/telemetry.

## Cognitive and Explanation Skills

| Project | Owns | Similarity without merger |
|---|---|---|
| [[Batman Prep Time Skill]] | readiness brief, backward plan, pre-mortem, contingencies | can call Study, News Depth, Physics Debunker, and Goal Planner |
| [[Brain Blast Skill]] | inventive operators and cheapest experiment | can emit a task or product experiment; does not own scheduling |
| [[Personalized ADHD Skill Upgrade]] | state-aware task activation using personally tested strategies | can consume Brain Blast hacks and Goal/Measure context |
| [[News Depth Telegram Skill]] | layered current-event explanation and claim ledger | can invoke Physics Debunker for quantitative subclaims |
| [[Physics Claim Debunker Skill]] | reproducible physical model, calculation, uncertainty, verdict | can return ELI5/ELI12 layers through News Depth |
| [[Reflective ELIZA Companion]] | longitudinal reflective conversation, memory, hypotheses, experiments | may hand an accepted action to ADHD/Goal tools; keeps its own memory contract |
| [[Expert Lens Skill]] | domain topology, precise terminology, expert questions, teach-back, and claim calibration | can supply a domain pack to Batman Prep, Study, News Depth, or Paper tools without absorbing their workflows |

**Shared package:** `personal-context-core` with explicit facts/preferences, dated observations, source IDs, and user corrections. Do not share hidden personality inferences between projects.

## Career Preparation Family

| Project | Relationship |
|---|---|
| [[Jobs Search and Apply Tool]] | owns discovery, fit, truthful packet, applications, outcomes |
| [[Batman Prep Time Skill]] | direct handoff for interview/company/meeting preparation |
| [[Personal Voice Ghostwriter and DM Desk]] | reusable personal voice and relationship context for reviewed outreach |
| [[Goal-to-Calendar Planner]] | schedules search, application, practice, interview, and follow-up blocks |
| [[Personal Study Curriculum]] | turns verified gaps into a focused learning plan |
| [[mock-interview-gauntlet]] | reference/optional interview simulation service |

## Quiz and Learning Family

| Project | Relationship |
|---|---|
| [[Quiz Master]] | owns corpus analysis, question grammar, sources, drafting, review, QOTD, and pack export |
| [[Quiz Poker]] | direct consumer of reviewed packs; owns rooms, wagering, scoring, and reconnect |
| [[Personal Study Curriculum]] | may request practice questions but uses a learner model rather than party-game rules |
| [[course-notes-to-quiz-product]] | reference implementation for converting bounded course notes into a reviewed product |

The versioned question-pack schema is the only required coupling.

## Location and Local Commerce Family

| Project | Relationship |
|---|---|
| [[Meet-in-the-Middle City Explorer]] | **merged pair**: routing/fairness core from [[meet-in-the-middle]] plus optional presentation layer from [[city-roast-map]] |
| [[Moving Out Marketplace]] | separate local-commerce product; may reuse map/geocoder and meetup/pickup location components |
| [[commute-copilot]] | reference for recurring route intelligence |
| [[Event Networking Copilot]] | may deep-link into fair venue planning for small groups |

Share the map/provider cache and location-picker component, not marketplace inventory or participant data models.

## Media Family

| Project | Reuse opportunity |
|---|---|
| [[LongVid Learning Studio]] | transcript/timestamp/source-provenance engine can seed clip candidates |
| [[Longform-to-Shorts Studio]] | reusable deterministic edit/render service |
| [[Local Video Generation Evaluation Lab]] | renderer/model registry and benchmark evidence |
| [[Manga-to-Animatic Studio]] | can use selected local renderer through the registry |
| [[Meta Ad Creative Studio]] | consumes demo clips and selected generative renders |
| [[Auto-GTM Engine]] | distributes approved final media |
| [[podcast-clips-agency]] | prior-art/reference workflow for an external-service version |

## Recipe, Capture, and Visual Publishing Family

| Project | Owns | Reuse relationship |
|---|---|---|
| [[Visual Recipe Book]] | recipe ingestion, source-preserving extraction, ingredient-operation graph, Tabular Recipe Notation, cook mode, cookbooks, and recipe-card sharing | owns the recipe truth and user experience; remains a standalone product |
| [[PhoneScan PDF]] | general document capture, perspective correction, enhancement, OCR, and PDF output | image preprocessing and confidence-overlay code can be reused; it does not own recipe semantics |
| [[Personal Library Website]] | cataloguing and presenting a personal collection | reusable shelf, cover, tag, search, and collection-navigation patterns; recipes require their own graph and cooking views |
| [[Visual Token Compiler]] | measured visual compression and legibility experiments | reusable SVG/export, layout scoring, and visual-regression concepts; it does not parse or store recipes |
| [[Auto-GTM Engine]] | approved derivative assets and distribution workflows | optional downstream consumer of exported recipe cards; no dependency for personal V0 |

**Build order:** five hand-authored recipe graphs -> deterministic TRN SVG renderer -> JSON-LD import and review -> local cookbook -> cook mode -> OCR/model-assisted fallbacks -> phone share target.

**Shared package:** `capture-and-render-core` may contain image cleanup, source snapshots, SVG/PNG export, font/contrast checks, and immutable artifact manifests. The recipe graph, ingredient parsing, cooking validation, and cookbook data remain owned by [[Visual Recipe Book]].

## Finance and Operations Reuse

[[Net Worth Command Center]], [[Paisa Vasool Subscriptions]], [[Finance Signals Dashboard]], [[finance-ops-agency]], [[tax-packet-autopilot]], and [[invoice-chaser-agent]] should share import, reconciliation, source hashing, scheduling, and audit-event packages while retaining separate financial jobs and screens.

## Tiny-Model and Game Research Family

| Project | Owns | Reuse relationship |
|---|---|---|
| [[Tiny Model Game Lab]] | tiny-model baselines, capability accounting, tool/search ablations, distillation, and cross-game curriculum | may consume compatible environments but keeps its own evaluation contract and model-training pipeline |
| [[Yu-Gi-Oh RL Lab]] | deterministic card-battler rules, self-play, deck diversity, and card-game diagnostics | can expose a later small ruleset through the lab's generic environment protocol |
| [[Live Chess Tutor]] | human-facing move analysis and teaching | chess endgame positions can become a held-out planning environment; the tutor remains a separate product |
| [[Quiz Poker]] | multiplayer question wagering and scoring | reference only unless a bounded language-strategy environment is deliberately defined |

**Shared package:** `game-eval-core` containing environment/version manifests, action legality, trajectory/replay schemas, policy adapters, seeds, scorecards, and leakage checks. Game rules and product interfaces remain project-owned.

## Rule for Future Similar Ideas

Before merging, ask:

1. Do they serve the same user job at the same frequency?
2. Do they own the same canonical data and success metric?
3. Would they be released and tested together?

If all three are true, a two- or three-idea merge may be justified. Otherwise create a self-contained spec and mark **direct handoff**, **shared engine**, or **possible tab** here.

## Related

- [[Project Ideas Index]]
- [[Source Idea Coverage Map]]
- [[Research - Existing Product and Shortcut Atlas]]
- [[Scope Expansion Checklist]]
