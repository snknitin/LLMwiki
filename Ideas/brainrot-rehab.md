---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: digital-wellbeing
form_factor:
  - messaging bot
  - mobile-friendly dashboard
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#3. Brainrot Rehab]]"
status: concept
tags: [wellbeing, screen-time, habits]
---

# Brainrot Rehab

> A private daily screen-time check-in that converts one number into a small behavior experiment, with comedy but no diagnosis.

## Product Outcome

The user submits daily screen time and the top distracting app, optionally via screenshot. The tool shows trend, a playful “stage,” one achievable intervention, and a weekly reflection. It should help the user notice and change patterns without shame.

## User and Core Workflow

1. Send total time, top app, and a 1–5 intention score.
2. Optional local OCR proposes values from a screenshot; user confirms.
3. Compare with the user’s rolling baseline, not other people.
4. Suggest one bounded action from a curated intervention library.
5. Record done/skipped and deliver a private weekly recap.

## Demo/Personal V0

Telegram bot or local PWA with manual number entry, SQLite history, seven-day chart, and deterministic stage/intervention rules. OCR is a stretch slice.

## Build Boundary

**MVP:** manual check-in, optional screenshot OCR, private trends, low-stakes intervention deck, instant stop/delete.

**Out:** medical/addiction diagnosis, punitive blocking, public shame leaderboard, child monitoring, or autonomous device control.

## Existing Products, Building Blocks, and Shortcuts

- [Tesseract.js](https://github.com/naptha/tesseract.js) performs screenshot OCR locally in browser or Node.
- [Telegram Bot API](https://core.telegram.org/bots/api) supplies uploads, buttons, prompts, and scheduled messages.
- Android [`UsageStatsManager`](https://developer.android.com/reference/android/app/usage/UsageStatsManager.html) is a later native path but requires special user-granted access.
- Apple [`DeviceActivityReport`](https://developer.apple.com/documentation/deviceactivity/deviceactivityreport) offers privacy-preserving reporting inside its constrained authorization model.

## Free-First Stack

Node/TypeScript Telegram bot or PWA, SQLite, Chart.js, APScheduler/Task Scheduler, and Tesseract.js. Use local Ollama only for weekly wording, never for score calculation.

## Architecture/Data Model

`DailyCheckIn` stores date, minutes, top app/category, intention, and confirmation source. `Baseline` computes rolling median. `Intervention` is curated with duration and safe category. `Attempt` records done/skipped. Screenshot bytes expire after confirmation.

## Build Slices

1. Manual check-in and seven-day chart.
2. Intervention rules and reminders.
3. Weekly reflection.
4. Optional OCR and later native data experiments.

## Drawbacks/Concerns/Failure Modes

- Screen-time screenshots vary by platform; always require confirmation.
- “Brainrot stage” may shame or imply illness; make it opt-in comedy and use neutral analytics underneath.
- Native access is permission-heavy and platform-specific.
- Reminders can become more unwanted screen time; make cadence and quiet hours explicit.

## Clever Hacks and Simpler Alternative

One daily number plus “what were you avoiding?” may create more insight than perfect per-app telemetry. Keep a curated seven-day experiment deck rather than generating advice.

## Success Measures

- Check-in takes under 20 seconds.
- Screenshot is deleted immediately after confirmation.
- At least four check-ins per week without reminder fatigue.
- User completes one chosen intervention in most weeks.

## Product Path

Private tracker → native opt-in integrations → coach-guided wellbeing tool. Public scope needs clinical-claims restraint, platform entitlements, age/privacy controls, and notification review.

## Related Wikilinks

- [[npc-mode|NPC Mode]]
- [[pocket-crm|Pocket CRM]]

