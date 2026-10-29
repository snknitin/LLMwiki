---
updated: 2026-10-20
---

# Project Priorities

The one list that decides what agents work on. Edit freely: reorder lines, move them between sections, delete them.

**How it works:** **Tonight** has three lanes, one per tool. The runner starts at 23:00 and runs **every project in every lane at the same time** (no limit per lane), then writes [[Overnight Report]]. To move a project to another tool, move its line to another lane. To pause it, move it out of Tonight. A project stays in its lane until you move it, and each night it continues from its `PROGRESS.md`.

**Line format:** `- <folder-name> — <note>`
- `<folder-name>` is the folder under `E:\GIT_ROOT\Projects` (don't rename it here). The note is for you; the runner ignores it.
- Optional model override after the name: `@claude:sonnet`, `@codex:<model>`, `@hermes:qwen3.6-35b-a3b`. An `@tool` tag also overrides the lane.
- Defaults: **Claude** = Opus coordinating Sonnet builders (desktop, Max plan) · **Codex** = your Codex config model (desktop, ChatGPT plan) · **Hermes** = `glm53-flash` on SecondSpark + ThirdSpark, run from FirstSpark (local, free, no usage limit).
- Only projects with `scripts/verify.ps1` can run (ask Claude: "Make <folder-name> overnight-ready"). Lines without it are skipped and the report says so.

**Which lane:** Claude for UI, product feel and tricky design. Codex for well-specified backend or CLI slices, or a second opinion on a Claude project. Hermes for private-data work, Spark-hosted services, and long grinding slices where a free local model is good enough.

## Tonight

### Claude
- creator-content-engine — Human-led content OS for one creator · includes merged: build-in-public-autoposter, my-agent-posts-about-me, x-profile-autopsy, personal-voice-ghostwriter-and-dm-desk, social-subscription-curator, longform-to-shorts-studio, auto-gtm-engine
- event-market-research-terminal — A research-only terminal for event markets and crypto narratives · includes merged: edge-desk
- personal-library-website — A static, book-led personal website · includes merged: epub-highlights-bridge, giftshelf

### Codex
- event-networking-copilot — A phone-first event companion
- finance-signals-dashboard @codex:sol-6-high — A read-only, local-first personal dashboard that ranks a ten-instrument India/US watchlist by " · includes merged: market-mood-cards (Morning tab)
- leetcode-pattern-curriculum — T1 + T3: lcpc predict/attempt/hint loop, two-pointers module (verify.sh on Linux)
- customer-support-agency — Local-first analysis app · includes merged: google-review-reply-desk, support-faq-builder, knowledge-base-agency
- paper-logbook @codex:sol-6-high — An offline-first, paper-like daily/monthly notebook · includes merged: brainrot-rehab, measure-life, npc-mode-personal-coach (NPC Mode tab)
- bionic-reading-trainer — T1–T2: SvelteKit reader, emphasis + scroll/RSVP/chunk modes, screenshots

### Hermes
- motto-agent-council — first slice (local small-agent council)
- daily-parent-check-in — Consent-first local app that sends one daily check-in prompt to a parent (via a simulated inbox

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
11. motto-agent-council
12. personalized-adhd-skill-upgrade
13. event-market-research-terminal
14. jobs-search-and-apply-tool
15. meet-in-the-middle-city-explorer
16. side-hustle-radar
17. daily-parent-check-in
18. competitive-intelligence-agency

### P2 · Soon
19. personal-finance-cockpit
20. quiz-master
21. event-networking-copilot
22. leetcode-pattern-curriculum
23. customer-support-agency
24. bionic-reading-trainer
25. marionettist-utopia
26. personal-library-website
27. ambient-tv
28. demand-generation-workbench
29. visual-recipe-book
30. meta-ad-creative-studio
31. field-pokedex
32. moving-out-marketplace
33. local-video-generation-evaluation-lab

### P3 · Later
34. handwriting-to-latex
35. neural-fractal-visualizer
36. dies-at-user-50
37. taxonomy-cluster-explorer
38. maintainer-desk
39. sales-development-agency
40. event-ops-agency
41. finance-ops-agency
42. landing-page-conversion-agency
43. scam-radar
44. community-ops-agency
45. commute-copilot
46. deal-desk-agency
47. flex-card-forge
48. inbox-zero-mercenary
49. murder-mystery-game-master

### P4 · Someday
50. on-call-autopilot
51. recruiting-agency
52. phonescan-pdf
53. red-tape-navigator
54. seo-agency-crew
55. user-research-agency
56. wedding-gallery-concierge
57. any-app-widget-maker
58. ar-scale-lens
59. audio-watermark-and-perception-lab
60. feedback-mirror
61. live-chess-tutor

### P5 · Parked ideas
62. playo-elo-sports-network
63. tiny-model-game-lab
64. visual-token-compiler
65. adaptive-vision-glasses
66. drone-mission-mapper
67. manga-to-animatic-studio
68. song-phrase-mosaic
69. yugioh-rl-lab

## Ready next (overnight-ready, not queued)
- moving-out-marketplace — A deadline-first local marketplace where one move-out becomes a temporary storefront · includes merged: price-my-room
- demand-generation-workbench — A local experiment ledger and dashboard for demand discovery · includes merged: conversion-list-builder
- meta-ad-creative-studio — A local creative workbench that turns one product's evidence, audience, offer, and brand system · includes merged: paid-ad-account-audit
- field-pokedex — An Expo mobile app that identifies likely plant species from a photo via a hosted identificatio
- local-video-generation-evaluation-lab — A reproducible CLI benchmark harness answering one question

## Active (built; daytime feedback and iteration)
- resume-blueprint-studio @codex:sol-6-1-high — first slice (its branch is codex/specification)
- mock-interview-gauntlet @codex:sol-6-high — first slice
- dashboard-command-center — 48 commits — A Windows-first, browser-chrome-free Electron operations shell for the owner's private dashboar
- dunbar-dossier — 263 commits — A completely private, local-first personal biographic archive ("Dunbar 150") for one owner
- fresh-brief — 45 commits — A personal daily paper built from the owner's FreshRSS subscriptions · includes merged: news-depth-telegram-skill
- kaggle-learning-center — 51 commits — A private, Markdown-backed Kaggle learning studio (in-app model calls use the $250 Claude API credits)
- social-capture — 76 commits — A light, compact dashboard over the Markdown-backed Social Capture queue in Nitin's Obsidian va
- tiktok-learning-center — 76 commits — Turn a selected private TikTok collection into one cited Markdown learning package (brief, tuto
- agents-board — built — One place to plan, start and check overnight agent work across Claude Code, Codex and Hermes (the board you're reading this in)
- youtube-learning-center — 486 commits — A local-first, playlist-aware learning workstation
- language-learning-lab — A local-first language workbench built on three loops · includes merged: vocabulary-diction-studio (English track)
- paisa-vasool-subscriptions — A private, local-first subscription-utilization tracker for one user · includes merged: 27-clicks-to-cancel, renewal-guard
- personalized-adhd-skill-upgrade — Upgrade the existing `i-have-adhd` skill from generic productivity advice to a small, evidence-
- net-worth-command-center — A private, local-first personal-finance record for one person · includes merged: latte-into-lambo
- personal-study-curriculum — A local-first tool that turns one learning goal, weekly hours, and manually imported resources  · includes merged: course-notes-to-quiz-product
- side-hustle-radar — A local-first discovery workflow that collects side-hustle evidence from approved sources (Hack · includes merged: startup-graveyard
- meet-in-the-middle-city-explorer — A group-planning tool
- personal-finance-cockpit — The Finance group inside Dashboard Command Center: composes Net Worth, Paisa Vasool, Finance Signals and Event Markets into one group view
- competitive-intelligence-agency — A recurring, local-first monitoring pipeline · includes merged: b2b-competitor-battlecard
- quiz-master — A local quiz-authoring studio that learns structural patterns from the owner's private K-Circle · includes merged: quiz-poker
- jobs-search-and-apply-tool — A private, Windows-localhost career operations console for one job seeker · includes merged: am-i-underpaid
- marionettist-utopia — A private synthetic-society sandbox
- ambient-tv — A lean-back channel guide for the owner's own Jellyfin library
- visual-recipe-book — A local-first PWA + Python service that captures recipes (URL, paste, image), compiles them int
- expert-lens-skill — A FirstSpark dashboard for topic Markdown + GLM chat: Expert Lens, Batman Prep (with goal planner), Rabbit Hole, Research (Claim Check), Experiments (Brain Blast) · includes merged: batman-prep-time-skill, goal-to-calendar-planner, rabbit-hole-speedrun, physics-claim-debunker-skill, brain-blast-skill

## Backlog (BUILD_SPEC written, not set up for overnight yet)
- adaptive-vision-glasses — A phone-based electronic magnifier for specific near/far tasks (reading labels, whiteboards, me
- any-app-widget-maker — A user-configured widget builder
- ar-scale-lens — An Android ARCore camera tool that makes an abstract measurement feel physical
- audio-watermark-and-perception-lab — A transparent local laboratory
- community-ops-agency — A human-supervised operations desk for one community
- commute-copilot — A local route-specific departure checker for one saved commute
- deal-desk-agency — Local web app that turns messy sales notes plus a service catalog and rate card into a linked, 
- drone-mission-mapper — Simulation-first mission planner
- event-ops-agency — A local Next.js app that turns an event brief plus working spreadsheets (CSV) into a deadline-a · includes merged: ai-event-matchmaker
- feedback-mirror — A privacy-first, on-device daily appearance journal
- finance-ops-agency — A local finance-operations desk for a freelancer · includes merged: invoice-chaser-agent, tax-packet-autopilot
- flex-card-forge — A local Next.js app that turns opt-in GitHub stats plus pasted Strava/Chess.com exports into a 
- inbox-zero-mercenary — A reversible email triage desk
- landing-page-conversion-agency — A local CRO workbench that audits a user-OWNED landing page · includes merged: roast-my-landing-page, shopify-product-page-optimizer
- live-chess-tutor — A local desktop chess board for guided practice
- manga-to-animatic-studio — A local previsualization studio that turns user-supplied sequential art (original/public-domain
- murder-mystery-game-master — A deterministic party-game engine for 45–90 minute murder mysteries on a local LAN
- on-call-autopilot — A supervised incident investigator that replays a frozen telemetry bundle from a synthetic brok
- phonescan-pdf — A local-first document scanner
- playo-elo-sports-network — A local sports matchmaker for one invite-only group
- recruiting-agency — A local hiring-design desk
- red-tape-navigator — A local checklist compiler for Indian government procedures
- sales-development-agency — A local research-and-drafting desk · includes merged: cold-email-rewrite-desk, linkedin-lead-list-plus-first-lines, microsite-factory
- scam-radar — A local evidence dashboard that analyzes a pasted gig/job post, URL, email header set, or redac
- seo-agency-crew — A local, evidence-led editorial workbench for an owned site
- song-phrase-mosaic — A local desktop tool that indexes a folder of user-owned recordings, transcribes them with word
- tiny-model-game-lab — A reproducible local research lab that measures where capability comes from when a 135M–270M 
- user-research-agency — A consent-first local research desk for one researcher
- visual-token-compiler — A local benchmark-driven compiler
- wedding-gallery-concierge — A photographer-controlled, event-scoped photo search service
- yugioh-rl-lab — A reproducible card-battler RL laboratory built on an original small rules engine (40–100 car
- maintainer-desk — A supervised operations desk for one GitHub repository · includes merged: pr-factory
- taxonomy-cluster-explorer — A local-first dual-view explorer
- dies-at-user-50 — An authorized synthetic-user gauntlet
- handwriting-to-latex — A local desktop hotkey utility
- neural-fractal-visualizer — A deterministic audio-reactive visualizer

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
- physio-atlas — A local-first mobile app that organizes already-prescribed or self-selected physio exercises
- auto-gtm-engine — merged into creator-content-engine (features/auto-gtm-engine, Release mode on the Git activity tab)
- knowledge-base-agency — merged into customer-support-agency (features/knowledge-base-agency, Knowledge base tab)
- epub-highlights-bridge — merged into personal-library-website (features/epub-highlights-bridge, highlights importer on book pages)
- giftshelf — merged into personal-library-website (features/giftshelf, Gift shelf page)
- microsite-factory — merged into sales-development-agency (features/microsite-factory, Microsite tab)
- shopify-product-page-optimizer — merged into landing-page-conversion-agency (features/shopify-product-page-optimizer, Product page audit profile)
- news-depth-telegram-skill — merged into fresh-brief (features/news-depth-telegram-skill, Explain this)
