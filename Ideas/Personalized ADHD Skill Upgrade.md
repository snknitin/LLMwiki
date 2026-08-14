---
type: skill-upgrade-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Cognitive Support and Explanation Skills#3. Personalized ADHD Skill Upgrade]]"
status: task-ready
difficulty: medium
priority: p0
category: executive function support
form_factor:
  - existing skill upgrade
  - context-aware workflow
  - optional Telegram coach
deployment: local-first
source_ideas:
  - update i-have-adhd with personalized strategies
  - mine user-selected TikTok saved collections for candidate techniques
tags:
  - adhd
  - personalization
  - skills
  - executive-function
---

# Personalized ADHD Skill Upgrade

> Replace generic productivity advice inside the existing `i-have-adhd` skill with a small, evidence-tracked repertoire of interventions that work for this user in specific states and contexts.

## Product Outcome

The upgraded skill recognizes the current blockage—unclear next step, overwhelmed, under-stimulated, perfection-locked, distracted, low-energy, time-blind, or emotionally avoidant—and chooses one brief protocol from strategies the user has tested. It explains why that protocol fits, starts with a physical action, and asks for a tiny outcome review.

This is an upgrade workflow, not a new wellness dashboard. Its canonical output is a revised skill package, personal reference file, test fixtures, and a changelog of which advice was added, removed, or constrained.

## Inputs for Personalization

- Current `i-have-adhd` skill instructions, examples, and failure cases.
- Real tasks consistently started, delayed, abandoned, or completed.
- Time-of-day, location, device, energy, and social-context patterns.
- Preferred timers, body doubling, sound, movement, novelty, accountability, reward, and task-display formats.
- Language that creates momentum versus shame or resistance.
- Selected TikTok saved-collection URLs, transcripts, screenshots, or notes retrieved by the user from their own session/VPN setup.
- Relevant observations from [[Measure Life]], [[Paper Logbook]], and [[Goal-to-Calendar Planner]].

## Personal V0

1. Audit the current skill line by line: keep, rewrite, delete, personalize, or move to optional reference.
2. Build a state taxonomy from twenty recent stuck moments.
3. Extract candidate techniques from saved posts into `technique`, `claimed mechanism`, `context`, `effort`, and `source` fields.
4. Select ten candidate interventions and test them manually.
5. Create a deterministic routing table: state × energy × available time × environment -> one primary intervention and one fallback.
6. Update the skill, add five good and five bad fixtures, and run a two-week evaluation.
7. Prune any strategy that is repeatedly ignored or creates more setup than action.

## Build Boundary

**MVP:** skill audit, personal profile, candidate-technique library, routing table, fixture set, and outcome logging.

**Later:** passive calendar/task context, Telegram start cards, body-doubling sessions, wearable/phone cues, and adaptive strategy selection.

The skill can be deeply personalized without treating a habit as a permanent identity. Observations need timestamps, contexts, and easy deletion.

## Existing Products, Building Blocks, and Shortcuts

- The local `skill-creator` workflow is the correct scaffolding mechanism: instruction file, references, templates, and deterministic helpers rather than an application rewrite.
- [Obsidian API](https://github.com/obsidianmd/obsidian-api) and ordinary Markdown/YAML are sufficient for personal strategy and outcome files.
- [ActivityWatch](https://github.com/ActivityWatch/activitywatch) can supply optional local activity context; manual state check-ins are a cleaner V0.
- [Super Productivity](https://github.com/johannesjo/super-productivity), Pomodoro timers, Focusmate/body-doubling services, and Goblin Tools are product references for task breakdown, focus sessions, and activation support.
- yt-dlp/Whisper may process user-selected accessible saved clips after the user supplies URLs or exported media. A spreadsheet of manually transcribed tips is an adequate first evidence set.
- TikTok’s official developer surfaces do not provide a general saved-collections export to this local skill. The practical V0 is for the user to open the collection through their own VPN/browser session and forward URLs, screenshots, transcripts, or notes into an intake folder.

## Recommended Free-First Stack

- Existing skill folder plus `references/personal-profile.md`, `references/techniques.yaml`, fixtures, and an outcome template.
- Small Python/TypeScript validator for schema and fixture tests.
- Local model for state-aware phrasing and task decomposition; deterministic table for strategy selection.
- Markdown/CSV log first; SQLite only for longitudinal analysis.
- Optional Telegram bot for one-card interventions.

## Skill Output Contract

Every invocation returns:

1. A one-line reflection of the blockage, phrased tentatively.
2. One action requiring no more than two minutes to begin.
3. A short focus container or environmental change.
4. A fallback if the first action fails.
5. A finish/stop condition.
6. One-tap review: helped, neutral, annoying, or wrong state.

Explanations remain collapsed unless requested. The skill should reduce cognitive load, not demonstrate intelligence.

## Build Slices

1. Existing-skill audit and personal pattern interview.
2. State taxonomy and strategy schema.
3. Saved-content extraction and candidate library.
4. Deterministic router plus personalized phrasing.
5. Fixture/evaluation harness and two-week dogfood cycle.
6. Telegram/calendar context only after the core skill wins.

## Drawbacks, Concerns, and Failure Modes

- Saved social tips may be memorable but ineffective. Treat them as hypotheses and record outcomes.
- An intervention that worked once can become stale. Track recency and rotate only among tested options.
- Too much context collection becomes another avoidance ritual. Use a five-second state check-in.
- Incorrect state classification makes advice irritating. Allow instant correction and learn from it.
- Gamification can turn into guilt. Prefer restartability and neutral resets over streak loss.
- The skill may over-explain. Keep the first response action-first and short.

## Clever Hacks and Simpler Alternative

- Maintain a physical/Markdown “activation menu” with five reliable moves before adding any model.
- Create `5 minutes`, `25 minutes`, and `low-energy` versions of common tasks.
- Route to body doubling with one click when solitary strategies repeatedly fail.
- Use “open the file and write a deliberately bad first line” as an activation bridge for perfection lock.
- Ask the user to name the wrong-state classification; those corrections train the router better than passive tracking.

## Success Measures

- Median task-initiation latency declines in recurring contexts.
- The percentage of suggestions actually attempted increases.
- Annoying/wrong-state responses decline across versions.
- The skill uses fewer words and fewer strategies while outcomes improve.
- Personal data sources can be removed without breaking the core skill.

## Product Path

Private skill upgrade -> anonymized/template-only skill pack -> configurable executive-function assistant. Before making public wellbeing or treatment claims, apply [[Scope Expansion Checklist]]. This does not alter the local skill architecture.

## Related

- [[Brain Blast Skill]]
- [[Goal-to-Calendar Planner]]
- [[Measure Life]]
- [[Paper Logbook]]
- [[Parallel Presence Companions]]
- [[Project Ideas Index]]
