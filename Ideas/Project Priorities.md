---
updated: 2026-10-19
---

# Project Priorities

The one list that decides what agents work on. Edit freely: reorder lines, move them between sections, delete them.

**Line format:** `- <folder-name> @<harness> — <note>`
- `<folder-name>` is the folder under `E:\GIT_ROOT\Projects` (don't rename it here).
- `@claude` (default if omitted), `@claude:sonnet`, `@codex`, or `@hermes`. The overnight runner runs `@claude` and `@codex` lines on the desktop and skips `@hermes` (those run through Hermes cron on FirstSpark; see [[AI Coding Playbook]]).
- The note is for you; the runner ignores it.

**Tonight** is the overnight queue: the runner works through it top to bottom at 23:00 and writes [[Overnight Report]]. A project stays in Tonight until you move it out, and each night it continues from its `PROGRESS.md`. A project can only go in Tonight once it has `scripts/verify.ps1` (ask Claude: "Make <folder-name> overnight-ready").

## Tonight
- mock-interview-gauntlet @claude — first slice
- vocabulary-diction-studio @claude — first slice
- resume-blueprint-studio @claude — first slice (branch codex/specification)

## Ready next (overnight-ready, not queued)
- batman-prep-time-skill @claude
- motto-agent-council @claude

## Active (built; daytime feedback and iteration)
- agent-reach — 375 commits — Agent Reach is a Python CLI + capability layer that gives any shell-capable AI agent (Claude Co
- dashboard-command-center — 48 commits — A Windows-first, browser-chrome-free Electron operations shell for the owner's private dashboar
- dunbar-dossier — 263 commits — A completely private, local-first personal biographic archive ("Dunbar 150") for one owner
- fresh-brief — 45 commits — A personal daily paper built from the owner's FreshRSS subscriptions
- kaggle-learning-center — 51 commits — A private, Markdown-backed Kaggle learning studio (in-app model calls use the $250 Claude API credits)
- social-capture — 76 commits — A light, compact dashboard over the Markdown-backed Social Capture queue in Nitin's Obsidian va
- tiktok-learning-center — 76 commits — Turn a selected private TikTok collection into one cited Markdown learning package (brief, tuto
- youtube-learning-center — 486 commits — A local-first, playlist-aware learning workstation

## Backlog (BUILD_SPEC written, not set up for overnight yet)
- 27-clicks-to-cancel — A user-supervised cancellation navigator
- adaptive-vision-glasses — A phone-based electronic magnifier for specific near/far tasks (reading labels, whiteboards, me
- ai-event-matchmaker — For one event the owner controls
- ai-implementation-agency — An evidence-first workflow-audit kit
- am-i-underpaid — A local-first compensation reality check
- ambient-tv — A lean-back channel guide for the owner's own Jellyfin library
- angel-and-demon-companion — Two virtual pets argue a logged choice from the user's own values
- any-app-widget-maker — A user-configured widget builder
- ar-scale-lens — An Android ARCore camera tool that makes an abstract measurement feel physical
- audio-watermark-and-perception-lab — A transparent local laboratory
- auto-gtm-engine — A reusable release-to-market pipeline
- b2b-competitor-battlecard — A local-first research desk that produces a one-page, call-ready competitor battlecard where ev
- bionic-reading-trainer — An on-device PWA reading surface
- brain-blast-skill — A Markdown skill package that turns one everyday irritation into one cheap, reversible experime
- brainrot-rehab — A private Telegram-bot check-in
- build-in-public-autoposter — A local CLI + review page that turns one repository's last 24 hours of git activity plus a two-
- cold-email-rewrite-desk — A local web app that rewrites the user's own rough outreach draft into one compact email, two a
- community-ops-agency — A human-supervised operations desk for one community
- commute-copilot — A local route-specific departure checker for one saved commute
- competitive-intelligence-agency — A recurring, local-first monitoring pipeline
- conversion-list-builder — A local evidence board for one product and one falsifiable audience hypothesis
- course-notes-to-quiz-product — Local-first study tool
- creator-content-engine — Human-led content OS for one creator
- customer-support-agency — Local-first analysis app
- daily-parent-check-in — Consent-first local app that sends one daily check-in prompt to a parent (via a simulated inbox
- deal-desk-agency — Local web app that turns messy sales notes plus a service catalog and rate card into a linked, 
- deliberate-feed-gate — A Chrome MV3 extension that intercepts the YouTube home feed and replaces it with a bounded loc
- demand-generation-workbench — A local experiment ledger and dashboard for demand discovery
- dies-at-user-50 — An authorized synthetic-user gauntlet
- drone-mission-mapper — Simulation-first mission planner
- edge-desk — A read-only prediction-market research desk
- epub-highlights-bridge — A local-first pipeline that imports highlight/note exports from KOReader (and later Calibre) in
- event-market-research-terminal — A research-only terminal for event markets and crypto narratives
- event-networking-copilot — A phone-first event companion
- event-ops-agency — A local Next.js app that turns an event brief plus working spreadsheets (CSV) into a deadline-a
- expert-lens-skill — A local-first Codex/Hermes skill plus Python pipeline that turns "domain + situation + counterp
- feedback-mirror — A privacy-first, on-device daily appearance journal
- field-pokedex — An Expo mobile app that identifies likely plant species from a photo via a hosted identificatio
- finance-ops-agency — A local finance-operations desk for a freelancer
- finance-signals-dashboard — A read-only, local-first personal dashboard that ranks a ten-instrument India/US watchlist by "
- flex-card-forge — A local Next.js app that turns opt-in GitHub stats plus pasted Strava/Chess.com exports into a 
- giftshelf — A hosted web app where a shelf owner publishes a transparent wish/recommendation list (books, t
- goal-to-calendar-planner — An approval-based local planner that turns one large goal into milestones and dependency-aware 
- google-review-reply-desk — A local writing desk where a business owner pastes a review and gets a structured draft
- half-blood-pdf — A local pipeline that enriches a text-based PDF with reviewed marginal annotations (clarificati
- handwriting-to-latex — A local desktop hotkey utility
- inbox-zero-mercenary — A reversible email triage desk
- invoice-chaser-agent — A local accounts-receivable cockpit for one operator
- jarvis-and-alfred — A two-role personal executive-assistant harness
- jobs-search-and-apply-tool — A private, Windows-localhost career operations console for one job seeker
- knowledge-base-agency — A local pipeline + web app that turns a client's supplied documents into a citation-first knowl
- landing-page-conversion-agency — A local CRO workbench that audits a user-OWNED landing page
- language-learning-lab — A local-first language workbench built on three loops
- latte-into-lambo — A private, local-only counterfactual calculator
- leetcode-pattern-curriculum — A local, Python-only algorithms curriculum
- linkedin-lead-list-plus-first-lines — A local research workbench
- live-chess-tutor — A local desktop chess board for guided practice
- local-video-generation-evaluation-lab — A reproducible CLI benchmark harness answering one question
- longform-to-shorts-studio — A local pipeline + transcript-first editor that analyzes a long video (MP4/MKV/MOV), proposes s
- maintainer-desk — A supervised operations desk for one GitHub repository
- manga-to-animatic-studio — A local previsualization studio that turns user-supplied sequential art (original/public-domain
- marionettist-utopia — A private synthetic-society sandbox
- market-mood-cards — A standalone, Spark-hosted morning-briefing pipeline and private dashboard
- measure-life — A private, local-first N-of-1 self-observation app
- meet-in-the-middle-city-explorer — A group-planning tool
- meta-ad-creative-studio — A local creative workbench that turns one product's evidence, audience, offer, and brand system
- microsite-factory — A schema-driven factory that turns approved, cited account research into consistent static micr
- moving-out-marketplace — A deadline-first local marketplace where one move-out becomes a temporary storefront
- murder-mystery-game-master — A deterministic party-game engine for 45–90 minute murder mysteries on a local LAN
- my-agent-posts-about-me — A private, opt-in observation journal that turns explicit, inspectable sources (V0
- net-worth-command-center — A private, local-first personal-finance record for one person
- neural-fractal-visualizer — A deterministic audio-reactive visualizer
- news-depth-telegram-skill — A single-user Telegram bot
- npc-mode-personal-coach — A playful, local-first daily coach that compares today's actual behavior with a user-authored "
- on-call-autopilot — A supervised incident investigator that replays a frozen telemetry bundle from a synthetic brok
- paid-ad-account-audit — A local desktop auditor that imports Google/Meta ad CSV exports, reconciles totals, runs ten de
- paisa-vasool-subscriptions — A private, local-first subscription-utilization tracker for one user
- paper-logbook — An offline-first, paper-like daily/monthly notebook
- parallel-presence-companions — A body-doubling focus room
- personal-color-relighting-studio — A local-first, mobile-first web studio that turns a calibrated selfie into a private digital dr
- personal-library-website — A static, book-led personal website
- personal-signal-intelligence-os — A private information refinery
- personal-study-curriculum — A local-first tool that turns one learning goal, weekly hours, and manually imported resources 
- personal-voice-ghostwriter-and-dm-desk — A local-first writing desk that drafts public posts (X, LinkedIn) and private DM replies in the
- personalized-adhd-skill-upgrade — Upgrade the existing `i-have-adhd` skill from generic productivity advice to a small, evidence-
- phonescan-pdf — A local-first document scanner
- physics-claim-debunker-skill — A local research skill that turns an extraordinary claim into measurable subclaims, steelmans i
- physio-atlas — A local-first mobile app that organizes already-prescribed or self-selected physio exercises
- playo-elo-sports-network — A local sports matchmaker for one invite-only group
- pocket-crm — A personal, local-first CRM captured through a Telegram bot
- podcast-clips-agency — A local production line that turns one user-owned podcast episode into a word-timecoded transcr
- pr-factory — A local, test-gated coding tournament
- price-my-room — A local web app that turns room photos into a user-correctable item inventory with conservative
- quiz-master — A local quiz-authoring studio that learns structural patterns from the owner's private K-Circle
- quiz-poker — A points-only multiplayer quiz for 4–12 friends on one Wi-Fi network
- rabbit-hole-speedrun — A local single-player knowledge game
- recruiting-agency — A local hiring-design desk
- red-tape-navigator — A local checklist compiler for Indian government procedures
- reflective-eliza-companion — A private, local-first reflective conversation companion
- renewal-guard — A local, private vault that turns receipts/invoices (files and manually exported emails) into c
- roast-my-landing-page — A local CLI that turns a landing-page screenshot + hero copy (later a permitted public URL) int
- sales-development-agency — A local research-and-drafting desk
- scam-radar — A local evidence dashboard that analyzes a pasted gig/job post, URL, email header set, or redac
- seo-agency-crew — A local, evidence-led editorial workbench for an owned site
- shopify-product-page-optimizer — A local audit dashboard + copy generator
- shortform-signal-digest — A private feed observer for one platform
- side-hustle-radar — A local-first discovery workflow that collects side-hustle evidence from approved sources (Hack
- social-subscription-curator — A local review-and-apply workflow that audits everything you follow (YouTube + one other platfo
- song-phrase-mosaic — A local desktop tool that indexes a folder of user-owned recordings, transcribes them with word
- startup-graveyard — A local research dashboard that turns a startup thesis into a source-backed "cemetery" of compa
- support-faq-builder — A local analysis dashboard that imports a bounded ticket export plus approved policy/product do
- tax-packet-autopilot — A local evidence desk that imports user-owned invoice/receipt files (read-only), OCRs and extra
- taxonomy-cluster-explorer — A local-first dual-view explorer
- tiny-model-game-lab — A reproducible local research lab that measures where capability comes from when a 135M–270M 
- understand-this-paper — An interactive research-paper tutor for ML arXiv papers
- user-research-agency — A consent-first local research desk for one researcher
- visual-recipe-book — A local-first PWA + Python service that captures recipes (URL, paste, image), compiles them int
- visual-token-compiler — A local benchmark-driven compiler
- wedding-gallery-concierge — A photographer-controlled, event-scoped photo search service
- x-like-to-list-builder — A local CLI + review dashboard that turns the likes in an X archive into 5–12 proposed X List
- x-profile-autopsy — A local self-analysis tool
- yugioh-rl-lab — A reproducible card-battler RL laboratory built on an original small rules engine (40–100 car
