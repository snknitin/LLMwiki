---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#2. NPC Mode Personal Coach]]"
status: concept
difficulty: medium
priority: p1
category: productivity
form_factor:
  - mobile app
  - local dashboard
deployment: local-first
source_ideas:
  - image-based NPC self compared with an ideal task-completing self
tags:
  - coaching
  - calendar
  - agents
---

# NPC Mode Personal Coach

> A playful daily coach that compares current behavior with a user-authored “ideal player character,” then turns the gap into the next tiny action and safely automates administrative parts of the day.

## Product Outcome

The character framing should create momentum, not shame. The app looks at goals, calendar, tasks, energy, and a morning check-in, then presents a split-screen status card: current build, ideal build, biggest stat gap, and one executable quest.

## Personal V0

- Create an avatar from a user-supplied image or a non-photoreal character builder.
- Define the ideal self through behaviors and constraints, not vague perfection.
- Read today’s calendar and manually imported tasks.
- Generate a quest chain with time estimates, prerequisites, and “minimum viable win.”
- Start a focus timer and record completion evidence.
- Draft low-risk admin actions—calendar blocks, task breakdowns, reply outlines—for approval.
- Produce an evening comparison that rewards adaptation and honest replanning.

## Build Boundary

**MVP:** local web/mobile view, manual tasks, read-only calendar, one-day quest plan, and no autonomous external actions.

**Later:** richer calendar/task connectors, optional voice, recurring quests, and a private progress timeline. Avoid pseudo-clinical personality judgments or visual attractiveness scoring.

## Existing Products, Building Blocks, and Shortcuts

- [Habitica](https://github.com/HabitRPG/habitica) is open-source prior art for RPG-flavored tasks, habits, rewards, and parties. Reuse the interaction lessons; the differentiator is plan-versus-actual reflection and approved automation.
- Google’s [Calendar API](https://developers.google.com/workspace/calendar/api/guides/overview) and [Tasks API](https://developers.google.com/workspace/tasks/reference/rest) provide supported inputs/actions. The coach should be a view over the same task truth as [[Goal-to-Calendar Planner]].
- [OR-Tools](https://developers.google.com/optimization) can generate the feasible “ideal path”; the local model explains or reframes it. This avoids asking an LLM to invent a schedule and then pretending the result is optimal.
- Simpler alternative: “Ghost Run,” a deterministic card showing planned path, observed path, and what one 25-minute block changes. Add avatar generation only if it increases use.

## Free-First Stack

- **App:** Expo for mobile/web, or a PWA if the first goal is speed.
- **Backend/data:** FastAPI and SQLite.
- **Integrations:** Google Calendar read-only first; ICS import as a connector-free fallback.
- **Models:** local text model for reframing and decomposition; rules enforce duration, deadlines, and protected time.
- **Images:** local image generation only for stylized avatars, with the original kept private.
- **Automation:** n8n approval queue for proposed calendar/task changes.

## Coaching Contract

The ideal self is a set of chosen values and repeatable behaviors. Comparison language describes state—“two tasks are blocked”—not identity—“you are lazy.” Users can inspect the inputs behind every suggestion and disable any data source.

## Build Slices

1. Ideal-self editor and daily check-in.
2. Calendar/task normalization.
3. Quest-chain generator with deterministic schedule validation.
4. Focus session and completion evidence.
5. Evening comparison and weekly trends.
6. Approval-based task automation.

## Success Measures

- Morning planning takes under five minutes.
- At least one important task starts earlier than baseline.
- Suggested schedules never overlap fixed events.
- Shame/annoyance feedback remains near zero.
- The user continues after novelty wears off for three weeks.

## Product Path

This can remain a personal dashboard, become an open-source agent skill, or ship as a consumer focus app with themed character packs. Monetization should favor customization and sync over manipulative streaks.

## Related

- [[Goal-to-Calendar Planner]]
- [[Jarvis and Alfred]]
- [[Angel and Demon Companion]]
- [[Paper Logbook]]
- [[Project Ideas Index]]
