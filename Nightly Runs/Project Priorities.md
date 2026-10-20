---
updated: 2026-10-20
---

# Project Priorities

The one list that decides what agents work on. Edit freely: reorder lines, move them between sections, delete them.

**How it works:** **Tonight** has three lanes, one per tool. The runner starts at 23:00 and runs up to **3 projects per lane at the same time** (9 in total), then writes [[Overnight Report]]. To move a project to another tool, move its line to another lane. To pause it, move it out of Tonight. A project stays in its lane until you move it, and each night it continues from its `PROGRESS.md`.

**Line format:** `- <folder-name> — <note>`
- `<folder-name>` is the folder under `E:\GIT_ROOT\Projects` (don't rename it here). The note is for you; the runner ignores it.
- Optional model override after the name: `@claude:sonnet`, `@codex:<model>`, `@hermes:qwen3.6-35b-a3b`. An `@tool` tag also overrides the lane.
- Defaults: **Claude** = Opus coordinating Sonnet builders (desktop, Max plan) · **Codex** = your Codex config model (desktop, ChatGPT plan) · **Hermes** = `glm53-flash` on SecondSpark + ThirdSpark, run from FirstSpark (local, free, no usage limit).
- Only projects with `scripts/verify.ps1` can run (ask Claude: "Make <folder-name> overnight-ready"). Lines without it are skipped and the report says so.

**Which lane:** Claude for UI, product feel and tricky design. Codex for well-specified backend or CLI slices, or a second opinion on a Claude project. Hermes for private-data work, Spark-hosted services, and long grinding slices where a free local model is good enough.

## Tonight

### Claude
- mock-interview-gauntlet — first slice
- bionic-reading-trainer — T1–T2: SvelteKit reader, emphasis + scroll/RSVP/chunk modes, screenshots

### Codex
- resume-blueprint-studio — first slice (its branch is codex/specification)
- epub-highlights-bridge — T1–T3: KOReader import, SQLite identity store, commentary preservation

### Hermes
- motto-agent-council — first slice (local small-agent council)
- leetcode-pattern-curriculum — T1 + T3: lcpc predict/attempt/hint loop, two-pointers module (verify.sh on Linux)

## Priority order (top 10 = daily focus)
Tiers P0–P5, highest first; ranks count straight through. In the Agents board, ⤒ ↑ ↓ ⤓ move a project only within its tier, and its tier menu moves it to the edge of another tier.

### P0 · Daily focus (top 10)
1. language-learning-lab
2. resume-blueprint-studio
3. finance-signals-dashboard
4. expert-lens-skill
5. mock-interview-gauntlet
6. net-worth-command-center
7. paisa-vasool-subscriptions
8. personal-study-curriculum
9. paper-logbook

### P1 · Next up
10. creator-content-engine
11. jobs-search-and-apply-tool
12. side-hustle-radar
13. personal-finance-cockpit
14. meet-in-the-middle-city-explorer
15. event-networking-copilot
16. motto-agent-council

### P2 · Soon
17. competitive-intelligence-agency
18. customer-support-agency
19. marionettist-utopia
20. demand-generation-workbench
21. auto-gtm-engine
22. personalized-adhd-skill-upgrade
23. bionic-reading-trainer
24. epub-highlights-bridge
25. quiz-master
26. leetcode-pattern-curriculum
27. meta-ad-creative-studio
28. ambient-tv
29. field-pokedex
30. giftshelf
31. moving-out-marketplace
32. handwriting-to-latex
33. local-video-generation-evaluation-lab

### P3 · Later
34. neural-fractal-visualizer
35. news-depth-telegram-skill
36. personal-library-website
37. taxonomy-cluster-explorer
38. visual-recipe-book
39. maintainer-desk
40. sales-development-agency
41. event-ops-agency
42. finance-ops-agency
43. landing-page-conversion-agency
44. community-ops-agency
45. commute-copilot
46. daily-parent-check-in
47. deal-desk-agency
48. dies-at-user-50
49. flex-card-forge
50. inbox-zero-mercenary
51. knowledge-base-agency
52. microsite-factory
53. murder-mystery-game-master

### P4 · Someday
54. on-call-autopilot
55. recruiting-agency
56. red-tape-navigator
57. scam-radar
58. seo-agency-crew
59. shopify-product-page-optimizer
60. user-research-agency
61. wedding-gallery-concierge
62. any-app-widget-maker
63. ar-scale-lens
64. audio-watermark-and-perception-lab
65. feedback-mirror
66. live-chess-tutor

### P5 · Parked ideas
67. phonescan-pdf
68. physio-atlas
69. playo-elo-sports-network
70. tiny-model-game-lab
71. visual-token-compiler
72. event-market-research-terminal
73. adaptive-vision-glasses
74. drone-mission-mapper
75. manga-to-animatic-studio
76. song-phrase-mosaic
77. yugioh-rl-lab

## Ready next (overnight-ready, not queued)
- (none yet: all 9 slots are filled)

## Active (built; daytime feedback and iteration)
- dashboard-command-center — 48 commits — A Windows-first, browser-chrome-free Electron operations shell for the owner's private dashboar
- dunbar-dossier — 263 commits — A completely private, local-first personal biographic archive ("Dunbar 150") for one owner
- fresh-brief — 45 commits — A personal daily paper built from the owner's FreshRSS subscriptions
- kaggle-learning-center — 51 commits — A private, Markdown-backed Kaggle learning studio (in-app model calls use the $250 Claude API credits)
- social-capture — 76 commits — A light, compact dashboard over the Markdown-backed Social Capture queue in Nitin's Obsidian va
- tiktok-learning-center — 76 commits — Turn a selected private TikTok collection into one cited Markdown learning package (brief, tuto
- agents-board — built — One place to plan, start and check overnight agent work across Claude Code, Codex and Hermes (the board you're reading this in)
- youtube-learning-center — 486 commits — A local-first, playlist-aware learning workstation

## Backlog (BUILD_SPEC written, not set up for overnight yet)
- adaptive-vision-glasses — A phone-based electronic magnifier for specific near/far tasks (reading labels, whiteboards, me
- ambient-tv — A lean-back channel guide for the owner's own Jellyfin library
- any-app-widget-maker — A user-configured widget builder
- ar-scale-lens — An Android ARCore camera tool that makes an abstract measurement feel physical
- audio-watermark-and-perception-lab — A transparent local laboratory
- auto-gtm-engine — A reusable release-to-market pipeline
- community-ops-agency — A human-supervised operations desk for one community
- commute-copilot — A local route-specific departure checker for one saved commute
- competitive-intelligence-agency — A recurring, local-first monitoring pipeline · includes merged: b2b-competitor-battlecard
- creator-content-engine — Human-led content OS for one creator · includes merged: build-in-public-autoposter, my-agent-posts-about-me, x-profile-autopsy, personal-voice-ghostwriter-and-dm-desk, social-subscription-curator, longform-to-shorts-studio
- customer-support-agency — Local-first analysis app · includes merged: google-review-reply-desk, support-faq-builder
- daily-parent-check-in — Consent-first local app that sends one daily check-in prompt to a parent (via a simulated inbox
- deal-desk-agency — Local web app that turns messy sales notes plus a service catalog and rate card into a linked, 
- demand-generation-workbench — A local experiment ledger and dashboard for demand discovery · includes merged: conversion-list-builder
- dies-at-user-50 — An authorized synthetic-user gauntlet
- drone-mission-mapper — Simulation-first mission planner
- event-market-research-terminal — A research-only terminal for event markets and crypto narratives · includes merged: edge-desk
- event-networking-copilot — A phone-first event companion
- event-ops-agency — A local Next.js app that turns an event brief plus working spreadsheets (CSV) into a deadline-a · includes merged: ai-event-matchmaker
- expert-lens-skill — A FirstSpark dashboard for topic Markdown + GLM chat: Expert Lens, Batman Prep (with goal planner), Rabbit Hole, Research (Claim Check), Experiments (Brain Blast) · includes merged: batman-prep-time-skill, goal-to-calendar-planner, rabbit-hole-speedrun, physics-claim-debunker-skill, brain-blast-skill
- feedback-mirror — A privacy-first, on-device daily appearance journal
- field-pokedex — An Expo mobile app that identifies likely plant species from a photo via a hosted identificatio
- finance-ops-agency — A local finance-operations desk for a freelancer · includes merged: invoice-chaser-agent, tax-packet-autopilot
- finance-signals-dashboard — A read-only, local-first personal dashboard that ranks a ten-instrument India/US watchlist by " · includes merged: market-mood-cards (Morning tab)
- flex-card-forge — A local Next.js app that turns opt-in GitHub stats plus pasted Strava/Chess.com exports into a 
- giftshelf — A hosted web app where a shelf owner publishes a transparent wish/recommendation list (books, t
- handwriting-to-latex — A local desktop hotkey utility
- inbox-zero-mercenary — A reversible email triage desk
- jobs-search-and-apply-tool — A private, Windows-localhost career operations console for one job seeker · includes merged: am-i-underpaid
- knowledge-base-agency — A local pipeline + web app that turns a client's supplied documents into a citation-first knowl
- landing-page-conversion-agency — A local CRO workbench that audits a user-OWNED landing page · includes merged: roast-my-landing-page
- language-learning-lab — A local-first language workbench built on three loops · includes merged: vocabulary-diction-studio (English track)
- live-chess-tutor — A local desktop chess board for guided practice
- local-video-generation-evaluation-lab — A reproducible CLI benchmark harness answering one question
- maintainer-desk — A supervised operations desk for one GitHub repository · includes merged: pr-factory
- manga-to-animatic-studio — A local previsualization studio that turns user-supplied sequential art (original/public-domain
- marionettist-utopia — A private synthetic-society sandbox
- meet-in-the-middle-city-explorer — A group-planning tool
- meta-ad-creative-studio — A local creative workbench that turns one product's evidence, audience, offer, and brand system · includes merged: paid-ad-account-audit
- microsite-factory — A schema-driven factory that turns approved, cited account research into consistent static micr
- moving-out-marketplace — A deadline-first local marketplace where one move-out becomes a temporary storefront · includes merged: price-my-room
- murder-mystery-game-master — A deterministic party-game engine for 45–90 minute murder mysteries on a local LAN
- net-worth-command-center — A private, local-first personal-finance record for one person · includes merged: latte-into-lambo
- neural-fractal-visualizer — A deterministic audio-reactive visualizer
- news-depth-telegram-skill — A single-user Telegram bot
- on-call-autopilot — A supervised incident investigator that replays a frozen telemetry bundle from a synthetic brok
- paisa-vasool-subscriptions — A private, local-first subscription-utilization tracker for one user · includes merged: 27-clicks-to-cancel, renewal-guard
- paper-logbook — An offline-first, paper-like daily/monthly notebook · includes merged: brainrot-rehab, measure-life, npc-mode-personal-coach (NPC Mode tab)
- personal-finance-cockpit — The Finance group inside Dashboard Command Center: composes Net Worth, Paisa Vasool, Finance Signals and Event Markets into one group view
- personal-library-website — A static, book-led personal website
- personal-study-curriculum — A local-first tool that turns one learning goal, weekly hours, and manually imported resources  · includes merged: course-notes-to-quiz-product
- personalized-adhd-skill-upgrade — Upgrade the existing `i-have-adhd` skill from generic productivity advice to a small, evidence-
- phonescan-pdf — A local-first document scanner
- physio-atlas — A local-first mobile app that organizes already-prescribed or self-selected physio exercises
- playo-elo-sports-network — A local sports matchmaker for one invite-only group
- quiz-master — A local quiz-authoring studio that learns structural patterns from the owner's private K-Circle · includes merged: quiz-poker
- recruiting-agency — A local hiring-design desk
- red-tape-navigator — A local checklist compiler for Indian government procedures
- sales-development-agency — A local research-and-drafting desk · includes merged: cold-email-rewrite-desk, linkedin-lead-list-plus-first-lines
- scam-radar — A local evidence dashboard that analyzes a pasted gig/job post, URL, email header set, or redac
- seo-agency-crew — A local, evidence-led editorial workbench for an owned site
- shopify-product-page-optimizer — A local audit dashboard + copy generator
- side-hustle-radar — A local-first discovery workflow that collects side-hustle evidence from approved sources (Hack · includes merged: startup-graveyard
- song-phrase-mosaic — A local desktop tool that indexes a folder of user-owned recordings, transcribes them with word
- taxonomy-cluster-explorer — A local-first dual-view explorer
- tiny-model-game-lab — A reproducible local research lab that measures where capability comes from when a 135M–270M 
- user-research-agency — A consent-first local research desk for one researcher
- visual-recipe-book — A local-first PWA + Python service that captures recipes (URL, paste, image), compiles them int
- visual-token-compiler — A local benchmark-driven compiler
- wedding-gallery-concierge — A photographer-controlled, event-scoped photo search service
- yugioh-rl-lab — A reproducible card-battler RL laboratory built on an original small rules engine (40–100 car

## Archived (out of consideration)
- agent-reach — 375 commits — Agent Reach is a Python CLI + capability layer that gives any shell-capable AI agent (Claude Co

2026-10-20 portfolio cleanup: see [[Project Portfolio]] (and its spreadsheet) for every project's status, merges, best use and open questions.

- 27-clicks-to-cancel — merged into paisa-vasool-subscriptions
- ai-event-matchmaker — merged into event-ops-agency
- am-i-underpaid — merged into jobs-search-and-apply-tool
- b2b-competitor-battlecard — merged into competitive-intelligence-agency
- brainrot-rehab — merged into paper-logbook
- build-in-public-autoposter — merged into creator-content-engine
- cold-email-rewrite-desk — merged into sales-development-agency
- conversion-list-builder — merged into demand-generation-workbench
- course-notes-to-quiz-product — merged into personal-study-curriculum
- edge-desk — merged into event-market-research-terminal
- google-review-reply-desk — merged into customer-support-agency
- half-blood-pdf — built elsewhere (live on Cloudflare with paywall) — do not rebuild
- invoice-chaser-agent — merged into finance-ops-agency
- latte-into-lambo — merged into net-worth-command-center (features/latte-into-lambo, What-if tab)
- linkedin-lead-list-plus-first-lines — merged into sales-development-agency
- measure-life — merged into paper-logbook
- my-agent-posts-about-me — merged into creator-content-engine
- paid-ad-account-audit — merged into meta-ad-creative-studio
- personal-signal-intelligence-os — parked as duplicate of fresh-brief (idea note in fresh-brief/docs/ideas)
- pocket-crm — parked as a future dunbar-dossier front-end (idea note in dunbar-dossier/docs/ideas)
- podcast-clips-agency — merged into longform-to-shorts-studio
- pr-factory — merged into maintainer-desk
- quiz-poker — merged into quiz-master
- renewal-guard — merged into paisa-vasool-subscriptions
- roast-my-landing-page — merged into landing-page-conversion-agency
- shortform-signal-digest — parked as a future fresh-brief short-form desk (idea note in fresh-brief/docs/ideas)
- startup-graveyard — merged into side-hustle-radar
- support-faq-builder — merged into customer-support-agency
- tax-packet-autopilot — merged into finance-ops-agency
- understand-this-paper — built elsewhere (browser extension, to open-source) — do not rebuild
- x-like-to-list-builder — merged into social-subscription-curator
- x-profile-autopsy — merged into creator-content-engine
- angel-and-demon-companion — Two virtual pets argue a logged choice from the user's own values
- personal-color-relighting-studio — A local-first, mobile-first web studio that turns a calibrated selfie into a private digital dr
- deliberate-feed-gate — A Chrome MV3 extension that intercepts the YouTube home feed and replaces it with a bounded loc
- ai-implementation-agency — An evidence-first workflow-audit kit


2026-10-20 merge wave 2 (see each host BUILD_SPEC §2 "Merged features"; originals preserved under <host>/features/<name>/):

- vocabulary-diction-studio — merged into language-learning-lab (features/vocabulary-diction-studio, English track)
- batman-prep-time-skill — merged into expert-lens-skill (features/batman-prep-time-skill, Batman Prep tab)
- goal-to-calendar-planner — merged into expert-lens-skill (features/goal-to-calendar-planner, planner inside the Batman Prep tab)
- rabbit-hole-speedrun — merged into expert-lens-skill (features/rabbit-hole-speedrun, Rabbit Hole tab)
- npc-mode-personal-coach — merged into paper-logbook (features/npc-mode-personal-coach, NPC Mode interstitial-journaling tab)
- price-my-room — merged into moving-out-marketplace (features/price-my-room, photo-to-price intake)
- personal-voice-ghostwriter-and-dm-desk — merged into creator-content-engine (features/personal-voice-ghostwriter-and-dm-desk, Voice + DM desk)
- social-subscription-curator — merged into creator-content-engine (features/social-subscription-curator, Follow portfolio)
- longform-to-shorts-studio — merged into creator-content-engine (features/longform-to-shorts-studio, Studio)
- jarvis-and-alfred — merged into motto-agent-council (features/jarvis-and-alfred, Jarvis and Alfred council voices)
- parallel-presence-companions — merged into motto-agent-council (features/parallel-presence-companions, desktop pets / body doubling)
- market-mood-cards — merged into finance-signals-dashboard (features/market-mood-cards, Morning mood tab)


2026-10-20 merge wave 3 (originals preserved under <host>/features/<name>/):

- reflective-eliza-companion — merged into motto-agent-council (features/reflective-eliza-companion, Eliza listening character + shared reflective memory)
- physics-claim-debunker-skill — merged into expert-lens-skill (features/physics-claim-debunker-skill, Research tab: Claim Check)
- brain-blast-skill — merged into expert-lens-skill (features/brain-blast-skill, Experiments tab: Brain Blast)
