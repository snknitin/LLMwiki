---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: personal-experiment
form_factor:
  - Telegram bot
  - private recap page
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#12. NPC Mode]]"
status: concept
tags: [habits, game, bot]
---

# NPC Mode

> A bounded daily-choice game for low-stakes habits, with instant veto and no autonomous control over real life.

## Product Outcome

For a chosen time window, the bot selects from user-approved actions such as focus block, short walk, meal from a list, playlist, or break activity. The user can obey, reroll, skip, or stop; a private recap shows what happened.

## User and Core Workflow

1. Configure allowed categories, exact options, quiet hours, budget, and hard exclusions.
2. At scheduled moments, the rule engine selects a safe option.
3. Optional local model writes playful NPC flavor text.
4. User taps done/reroll/skip/stop.
5. Private recap summarizes choices without publishing routine/location.

## Demo/Personal V0

Telegram bot, 20 curated actions, three prompts per day, one reroll each, SQLite state, and a weekly private recap.

## Build Boundary

**MVP:** curated low-stakes deck, scheduler, finite states, veto/stop, private log.

**Out:** money, medication, health, dangerous travel, relationship/work decisions, device control, public live location/routine, or “obey anything” mode.

## Existing Products, Building Blocks, and Shortcuts

- [Telegram Bot API](https://core.telegram.org/bots/api) covers prompts, buttons, and replies.
- [XState](https://github.com/statelyai/xstate) constrains legal prompt/respond/reroll/stop transitions.
- [APScheduler](https://github.com/agronholm/apscheduler) or Cloudflare [Cron Triggers](https://developers.cloudflare.com/workers/configuration/cron-triggers/) schedules decisions.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) validates optional generated choices against allowed categories.

## Free-First Stack

Node/TypeScript Telegram bot + XState + SQLite + APScheduler; Ollama for flavor only. Keep action selection deterministic.

## Architecture/Data Model

`SafetyProfile` owns approved `Action`s and exclusions. `GameWindow` defines cadence. `Decision` stores chosen action and expiry. `Response` is done/reroll/skip/stop. `Recap` contains only private aggregate counts.

## Build Slices

1. Curated deck and commands.
2. State machine, scheduler, and stop.
3. Private log/recap.
4. Optional constrained flavor text.

## Drawbacks/Concerns/Failure Modes

- “Obey” framing can encourage unsafe compliance; keep veto visible in every prompt.
- Notifications can become intrusive; cap cadence and respect quiet hours.
- Public logs expose routine/location.
- Generated actions can escape boundaries; prefer curated actions and schema validation.

## Clever Hacks and Simpler Alternative

Make it a seven-day deck with one scheduled decision daily. The fun comes from commitment and recap, not autonomous intelligence.

## Success Measures

- All selected actions originate from the approved deck.
- Stop command works from every state.
- No private routine is published automatically.
- User completes the week without disabling notifications.

## Product Path

Personal Telegram game → themed challenge packs → social opt-in recaps. Any public version needs safety, age/privacy, notification, and moderation review.

## Related Wikilinks

- [[brainrot-rehab|Brainrot Rehab]]
- [[NPC Mode Personal Coach]]
