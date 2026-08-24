---
type: index
status: active
created: 2026-07-27
scope: personal-first project portfolio
spec_count: 74
tags:
  - ideas
  - project-specs
  - local-first
---

# Project Ideas Index

This index now covers 74 personal project, workflow, evaluation, and skill specs. The default assumption throughout is: build for one person, run locally when practical, and only add accounts, billing, teams, and cloud infrastructure after the personal workflow is genuinely useful.

Full source-to-spec accounting: [[Source Idea Coverage Map]].

Cross-project similarities, shared engines, possible tabs, and explicit handoffs are mapped in [[Project Similarity and Reuse Map]].

The 57 surviving non-personal Hermes hackathon briefs are catalogued separately in [[Hermes Hackathon Ideas Index]].

## New Personal Ideas — August 2026

These remain self-contained builds. Similarity links identify reusable engines or possible tabs without forcing them into one mega-application.

### Marketplace and local discovery

- [[Moving Out Marketplace]]
- [[Meet-in-the-Middle City Explorer]] — the one deliberate merge of [[meet-in-the-middle]] and [[city-roast-map]].

### Personal feeds and attention

- [[X Like-to-List Builder]]
- [[Shortform Signal Digest]]
- [[Social Subscription Curator]]
- [[Deliberate Feed Gate]]

### Cognitive, research, and reflection skills

- [[Batman Prep Time Skill]]
- [[News Depth Telegram Skill]]
- [[Reflective ELIZA Companion]]
- [[Brain Blast Skill]]
- [[Personalized ADHD Skill Upgrade]]
- [[Physics Claim Debunker Skill]]
- [[Expert Lens Skill]]

### Tiny-model reasoning research

- [[Tiny Model Game Lab]] begins with a rigorously benchmarked 135M–270M Wordle policy, separates model capability from deterministic solver scaffolding, and escalates to harder constraint, planning, and partial-observability games.

### Food, cooking, and personal collections

- [[Visual Recipe Book]] turns recipe URLs, text, screenshots, and shared images into reviewed Tabular Recipe Notation, cook-mode views, and a themed personal cookbook.

### Appearance, color, and wardrobe

- [[Personal Color Relighting Studio]] combines calibrated Korean-style personal-color draping with an explicitly approximate depth-aware WebGPU garment and lighting preview.

### Desktop dashboard and workspace surfaces

- [[Dashboard Command Center]] is a Windows-first multi-webview shell for persistent URL applications, explicit enabled/paused/on-demand/warm/always-live/scheduled policies, Excel-like nested navigation, private Spark endpoints, and multi-monitor scene restore.

### Relationships and personal memory

- [[Dunbar Dossier]] is a local-first personal relationship intelligence system for an intentional 5/15/50/150 network, with versioned person files, interaction history, provenance-backed update review, meeting briefings, and Obsidian projections.

### Creator, demand, and distribution

- [[Meta Ad Creative Studio]]
- [[Personal Voice Ghostwriter and DM Desk]] — the one deliberate merge of voice-grounded public writing and private reply assistance.
- [[Conversion List Builder]]
- [[Demand Generation Workbench]]
- [[Auto-GTM Engine]]
- [[Longform-to-Shorts Studio]]
- [[Local Video Generation Evaluation Lab]]

### Existing project upgrade and new companion engine

- [[Jobs Search and Apply Tool]] now includes scheduled target-company searches, recency tactics, contact discovery, preparation dossiers, and configurable approved application automation.
- [[Quiz Master]] is a standalone question foundry that exports reviewed packs to [[Quiz Poker]].

## Urgent Personal Build Program

The current horizon is one month, targeting a durable personal beta by **2026-08-27**. Each tool should reach a useful vertical slice early, then spend the remaining time being dogfooded, instrumented, corrected, and hardened.

1. [[LongVid Learning Studio]]
2. [[Paper Logbook]]
3. [[Finance Signals Dashboard]]
4. [[Net Worth Command Center]]
5. [[Jobs Search and Apply Tool]]
6. [[Goal-to-Calendar Planner]]
7. [[Paisa Vasool Subscriptions]]
8. [[Language Learning Lab]]

The shared architecture, weekly sequence, and battle-testing gates are in [[First Month Build Program]].

### Existing prototypes on hold

[[Angel and Demon Companion]], [[Half-Blood PDF]], and [[Understand This Paper]] are reported to be roughly 80% complete from prior hackathons. Their current priority is low: inventory the existing code, test the main path, write the missing-20% list, and resume only after the urgent personal betas are stable.

## Portfolio Rules

- **Personal v0 before product v1.** A folder, SQLite database, local web app, Telegram bot, or browser extension is a valid first product.
- **Free-first, not permanently free.** Prefer open-source tools and existing hardware for learning; use paid models only when they materially improve a measured failure case.
- **Models are replaceable components.** Put local Ollama or vLLM endpoints and paid providers behind one OpenAI-compatible adapter.
- **Automations propose before they act.** Publishing, sending messages, purchases, trades, cancellations, calendar edits, and drone movement need a preview and explicit confirmation.
- **Private inputs stay private by default.** Social messages, finances, journals, health observations, faces, and location data should remain on-device or on the home network.
- **Personal-prototype assumption.** Current builds are local, single-user tools operating on user-supplied inputs. Copyright, trademark, redistribution, commercial licensing, and public-release compliance are deferred until a project is selected for open-source or product release. Technical access limits, safety, privacy, financial accuracy, medical boundaries, drone control, and live-game fair play still affect the prototype.

## Deferred Release Gate

Do not spend the current build month on product-rights analysis. Before any repository, hosted service, public demo, monetization, or third-party access, run a separate release audit covering assets/data/models, platform terms, privacy, safety, trademarks, payments, and applicable regulation.

## Best First Builds

These give the best combination of immediate personal value, low cash cost, and reusable technical learning.

| Order | Spec | Why start here | Main learning lane | First useful slice |
|---|---|---|---|---|
| 1 | [[LongVid Learning Studio]] | Turns saved videos into durable notes and study material | browser capture, queues, transcript provenance | URL/transcript to timestamped note |
| 2 | [[Paper Logbook]] | A useful daily mobile app with no external API dependence | Expo, local SQLite, offline durability | Fixed daily page, then template iteration |
| 3 | [[Finance Signals Dashboard]] | Daily evidence-backed conventional-market view | market data, time series, provenance | Ten-item watchlist and morning brief |
| 4 | [[Net Worth Command Center]] | Makes private finances inspectable immediately | CSV adapters, DuckDB/SQLite, reconciliation | Balances plus one tested importer |
| 5 | [[Jobs Search and Apply Tool]] | Direct career and income leverage | browser capture, ranking, document generation | Job link to truthful reviewed packet |
| 6 | [[Goal-to-Calendar Planner]] | Makes goals operational and teaches approval-based automation | Calendar APIs, scheduling, constraint validation | One conflict-free weekly plan |
| 7 | [[Paisa Vasool Subscriptions]] | Quick verified savings from existing exports | recurrence detection, reminders | Confirmed registry from finance imports |
| 8 | [[Language Learning Lab]] | Daily learning loop with reusable mobile primitives | Expo, SQLite, FSRS, audio | One language and reviewed starter set |

## Project Families

### Personal intelligence and learning

- [[Personal Signal Intelligence OS]]
- [[Personal Study Curriculum]]
- [[LongVid Learning Studio]]
- [[Bionic Reading Trainer]]
- [[Half-Blood PDF]]
- [[Understand This Paper]]
- [[Language Learning Lab]]
- [[LeetCode Pattern Curriculum]]
- [[Handwriting to LaTeX]]
- [[Visual Token Compiler]]
- [[EPUB Highlights Bridge]]
- [[X Like-to-List Builder]]
- [[Shortform Signal Digest]]
- [[Social Subscription Curator]]
- [[Deliberate Feed Gate]]
- [[News Depth Telegram Skill]]
- [[Physics Claim Debunker Skill]]
- [[Expert Lens Skill]]

### Personal operations, behavior, and wellbeing

- [[Paper Logbook]]
- [[NPC Mode Personal Coach]]
- [[Goal-to-Calendar Planner]]
- [[Jarvis and Alfred]]
- [[Angel and Demon Companion]]
- [[Parallel Presence Companions]]
- [[Measure Life]]
- [[Feedback Mirror]]
- [[Physio Atlas]]
- [[Adaptive Vision Glasses]]
- [[Batman Prep Time Skill]]
- [[Brain Blast Skill]]
- [[Personalized ADHD Skill Upgrade]]
- [[Reflective ELIZA Companion]]

### Relationships, communication, and private CRM

- [[Dunbar Dossier]] — canonical active-150 roster, relationship history, reviewed facts, cadence, and meeting briefs.
- [[pocket-crm]] — separate shorthand capture for contacts, opportunities, and next actions; may share stable person IDs.
- [[Event Networking Copilot]] — can hand reviewed new contacts and event notes into Dunbar Dossier.
- [[Personal Voice Ghostwriter and DM Desk]] — may consume approved communication guidance and open loops without owning relationship truth.
- [[GiftShelf]] — may consume confirmed interests and important dates for thoughtful-gift prompts.

### Dashboard shells and private operating surfaces

- [[Dashboard Command Center]]
- [[Personal Signal Intelligence OS]] — a dashboard/content producer that can open inside the shell; it remains the owner of signal ingestion and Obsidian output.
- [[Finance Signals Dashboard]] — possible registered sheet; it remains a separate financial-research product.
- [[Net Worth Command Center]] — possible registered sheet; it remains a separate private-finance product.
- [[Any App Widget Maker]] — shares URL/endpoint concepts but owns glanceable extracted widgets rather than full web applications.
- [[Ambient TV]] — may use presentation/full-screen patterns but owns scheduled media playback rather than dashboard orchestration.

### Money, career, and creator systems

- [[Creator Content Engine]]
- [[Side-Hustle Radar]]
- [[Jobs Search and Apply Tool]]
- [[Net Worth Command Center]]
- [[Paisa Vasool Subscriptions]]
- [[Finance Signals Dashboard]]
- [[Event Market Research Terminal]]
- [[GiftShelf]]
- [[Personal Library Website]]
- [[Event Networking Copilot]]
- [[Moving Out Marketplace]]
- [[Meta Ad Creative Studio]]
- [[Personal Voice Ghostwriter and DM Desk]]
- [[Conversion List Builder]]
- [[Demand Generation Workbench]]
- [[Auto-GTM Engine]]

### Spatial, vision, and media tools

- [[AR Scale Lens]]
- [[Ambient TV]]
- [[Drone Mission Mapper]]
- [[Field Pokedex]]
- [[Manga-to-Animatic Studio]]
- [[Song Phrase Mosaic]]
- [[PhoneScan PDF]]
- [[Neural Fractal Visualizer]]
- [[Audio Watermark and Perception Lab]]
- [[Longform-to-Shorts Studio]]
- [[Local Video Generation Evaluation Lab]]
- [[Meet-in-the-Middle City Explorer]]
- [[Personal Color Relighting Studio]]

### Food, cooking, and personal collections

- [[Visual Recipe Book]]
- [[Personal Library Website]] — reusable catalog and collection patterns; not the recipe data model.
- [[PhoneScan PDF]] — reusable image-cleanup and OCR patterns; remains a separate document utility.
- [[Visual Token Compiler]] — reusable SVG/export and visual-legibility evaluation patterns.

### Social simulations, platforms, and games

- [[Marionettist Utopia]]
- [[Live Chess Tutor]]
- [[Playo Elo Sports Network]]
- [[Any App Widget Maker]]
- [[Motto Agent Council]]
- [[Yu-Gi-Oh RL Lab]]
- [[Tiny Model Game Lab]]
- [[Quiz Poker]]
- [[Quiz Master]]
- [[Taxonomy Cluster Explorer]]

## Free-First Technology Lanes

| Lane | Use it for | Start with | Graduate to |
|---|---|---|---|
| Local automation | Scheduled ingestion, approvals, daily reports | n8n + Python/FastAPI + SQLite + Ollama | Postgres, Redis, workers, LangGraph |
| Universal mobile/web | Journals, trackers, capture, camera workflows | Expo/React Native + TypeScript + SQLite | Native Kotlin/Swift modules only where needed |
| Desktop utilities | Files, PDFs, widgets, private dashboards | Tauri + React/Svelte + SQLite | Rust sidecars, OS-specific plugins |
| Local AI workstation | Private text, vision, speech, embeddings | Ollama for iteration | vLLM on DGX Spark for throughput; paid APIs behind the same adapter |
| Computer vision and AR | Measurement, pose, species, mirrors | OpenCV + MediaPipe + phone camera | ARCore/ARKit, depth sensors, optimized on-device models |
| Generative media | Images, storyboards, audio, video experiments | ComfyUI + open checkpoints + FFmpeg | Hosted GPU jobs or paid models for quality/latency |
| Product web app | Shareable or paid services | Next.js or SvelteKit + Postgres | Managed auth, object storage, billing, observability |

Useful official starting points: [FreshRSS APIs](https://freshrss.github.io/FreshRSS/en/developers/06_GoogleReader_API.html), [Expo](https://docs.expo.dev/), [Tauri](https://v2.tauri.app/start/), [Ollama API](https://docs.ollama.com/api), [n8n](https://github.com/n8n-io/n8n), [n8n self-hosted AI starter kit](https://github.com/n8n-io/self-hosted-ai-starter-kit), [ARCore Depth](https://developers.google.com/ar/develop/depth), and [YouTube Data API](https://developers.google.com/youtube/v3/docs).

The general desktop lane remains Tauri-first, but [[Dashboard Command Center]] is an intentional Electron exception: its primary problem is composing and lifecycle-managing several Chromium web applications, session partitions, and native windows rather than wrapping one local UI.

## Deep Research Dossiers

Every project spec links directly to its relevant section in one of these primary-source research notes:

- [[Research - Information and Learning Ideas]]
- [[Research - Personal Systems and Product Ideas]]
- [[Research - Spatial Media and Experimental Ideas]]
- [[Research - Existing Product and Shortcut Atlas]]
- [[Research - New Personal Workflows and Product Ideas]]
- [[Research - Cognitive Support and Explanation Skills]]
- [[Research - Creator Growth and Local Video Pipelines]]
- [[Research - Expert Mode and Tiny Model Game Lab]]
- [[Research - Visual Recipe Notation and Recipe Library]]
- [[Research - Personal Color Analysis and Depth-Aware Relighting]]
- [[Research - Dashboard Command Center and Multi-Webview Shell]]
- [[Research - Dunbar Dossier and Personal Relationship Intelligence]]
- [[Project Similarity and Reuse Map]]

The specs contain the build decisions; the dossiers preserve deeper prior art, verified API/platform facts, drawbacks, hidden costs, clever shortcuts, paid-service triggers, and direct official-source links.

## Merge Decisions

- **FreshRSS newsletter + authenticated social signal triage + Telegram/Obsidian capture** became [[Personal Signal Intelligence OS]]. They share ingestion, deduplication, ranking, feedback, provenance, and publishing infrastructure; the outputs remain separate views.
- **Vocabulary builder + pronunciation coach + high-frequency phrase curriculum** became [[Language Learning Lab]]. They are three learning modes over one learner model and shared content graph.
- **Both channel-surfing bullets** became [[Ambient TV]].
- **Map-drawn drone patterns + LocateAnything visual search** became [[Drone Mission Mapper]].
- The paper/PDF ideas remain separate because they optimize different jobs: [[Half-Blood PDF]] produces a richly annotated artifact, [[Understand This Paper]] teaches a research paper interactively, and [[PhoneScan PDF]] is a capture utility.
- The personal-agent ideas remain separate because their interaction contracts differ: execution ([[Jarvis and Alfred]]), comparison ([[NPC Mode Personal Coach]]), values reflection ([[Angel and Demon Companion]]), social presence ([[Parallel Presence Companions]]), and perspective diversity ([[Motto Agent Council]]).
- **Meet-in-the-Middle + City Roast** became [[Meet-in-the-Middle City Explorer]] because the roast/compliment is an optional presentation layer over the same candidate-location data. The original component specs remain independently buildable.
- **Personal voice ghostwriting + DM replies** became [[Personal Voice Ghostwriter and DM Desk]] because both require the same voice examples, source provenance, people memory, open loops, and review/diff learning.
- The four feed projects remain separate: [[X Like-to-List Builder]] reorganizes authors, [[Shortform Signal Digest]] creates the daily briefing, [[Social Subscription Curator]] audits the source portfolio, and [[Deliberate Feed Gate]] changes the consumption interface. They may share adapters and a content schema.
- The creator/growth projects remain separate and composable. [[Demand Generation Workbench]] owns experiments; [[Conversion List Builder]] owns evidence-backed audiences; [[Meta Ad Creative Studio]] owns ad variants; [[Personal Voice Ghostwriter and DM Desk]] owns voice/relationships; [[Longform-to-Shorts Studio]] owns deterministic editing; [[Local Video Generation Evaluation Lab]] selects renderers; and [[Auto-GTM Engine]] orchestrates release assets.
- The three cognitive skills remain individual: [[Batman Prep Time Skill]] prepares, [[Brain Blast Skill]] invents, and [[Personalized ADHD Skill Upgrade]] adapts task-start support. They can share personal context without sharing a release cycle.
- [[Expert Lens Skill]] remains a separate domain-orientation and conversation-preparation skill; it may supply terminology and expert questions to Batman Prep or Study tools without sharing their workflow or release cycle.
- [[Tiny Model Game Lab]] remains separate from [[Yu-Gi-Oh RL Lab]] and [[Live Chess Tutor]]. It owns model-size ablations, distillation, tool-use accounting, and a cross-game curriculum; the other projects own their domain-specific game environments and user experiences.
- [[Visual Recipe Book]] remains a self-contained recipe capture, verification, cooking, and sharing product. It may reuse OCR from [[PhoneScan PDF]], collection patterns from [[Personal Library Website]], and rendering tests from [[Visual Token Compiler]] without merging those distinct jobs.
- [[Personal Color Relighting Studio]] remains a standalone personal styling and computational-photography product. It may reuse guided capture and longitudinal comparison patterns from [[Feedback Mirror]] plus renderer benchmarking from [[Local Video Generation Evaluation Lab]], but it must keep color analysis separate from health interpretation and generative media evaluation.
- [[Dashboard Command Center]] remains a standalone Windows shell, not a merger of the dashboards it displays. Finance, signals, agents, study, and Obsidian-backed tools can register as sheets or scenes while retaining their own data, jobs, feedback, and release cycles. It may share endpoint/health manifests with [[Any App Widget Maker]] but does not reduce full applications into widgets.
- [[Dunbar Dossier]] remains separate from [[pocket-crm]], [[Event Networking Copilot]], and [[Personal Voice Ghostwriter and DM Desk]]. It owns the active 150, temporal relationship memory, evidence review, and meeting briefs; the neighboring projects may share people/context contracts or hand off reviewed records without sharing the same daily job or release cycle.

## Portfolio Sequence

1. **Foundation:** run n8n, SQLite/Postgres, an object folder, and one model gateway on the workstation.
2. **Information loop:** build [[Personal Signal Intelligence OS]], [[LongVid Learning Studio]], and [[Personal Study Curriculum]] on the same content schema.
3. **Action loop:** add [[Goal-to-Calendar Planner]], [[Paper Logbook]], [[Jobs Search and Apply Tool]], and [[Measure Life]] with a shared events/feedback schema.
4. **Creator loop:** let approved insights flow into [[Creator Content Engine]] and [[Personal Library Website]].
5. **Specialized apps:** choose one mobile vision project and one GPU media project after the common foundation is stable.

## Clarifications to Revisit

- Which phone is the primary development target: Android first, iPhone first, or both?
- Is FreshRSS self-hosted and is its Google Reader-compatible API already enabled?
- Which desktop holds the canonical always-on automation runtime, and how should the DGX Spark be reached from it?
- Which accounts may be read through official APIs versus manual exports/forwarding?
- Which paid model providers are acceptable, and what monthly experiment budget should trigger an approval?
