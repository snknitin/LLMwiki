---
type: skill-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Cognitive Support and Explanation Skills#1. Batman Prep Time Skill]]"
status: concept
difficulty: medium
priority: p0
category: preparation and contingency planning
form_factor:
  - Codex or Hermes skill
  - calendar-triggered workflow
  - Telegram brief
deployment: local-first
source_ideas:
  - calendar-aware high-signal preparation with contingency plans
tags:
  - preparation
  - calendar
  - research
  - contingency
---

# Batman Prep Time Skill

> Given any calendar event, task, trip, deadline, meeting, exam, purchase, or difficult conversation, assemble the smallest high-signal preparation pack that materially changes the outcome.

## Product Outcome

The skill turns a vague future commitment into a readiness artifact: objective, context, Pareto knowledge, questions, rehearsal, dependencies, backward plan, failure pre-mortem, contingencies, and a final ten-minute checklist. It should feel like “Batman with prep time” because it anticipates likely branches—not because it produces an enormous dossier.

The same skill can be invoked manually or triggered when a calendar event crosses a lead-time threshold. It hands time blocks to [[Goal-to-Calendar Planner]] but remains useful without any calendar write access.

## Invocation Contract

Inputs:

- Event/task description, time, duration, location, people, and stakes.
- Desired outcome and unacceptable outcome.
- Available preparation time and resources.
- Relevant notes, prior meetings, documents, messages, travel constraints, or skill gaps.
- Preferred brief length and whether outside research is allowed.

Outputs:

1. **Mission:** one-sentence objective and success evidence.
2. **Situation map:** known facts, assumptions, unknowns, and decision points.
3. **Pareto brief:** the few facts/concepts most likely to matter.
4. **Backward plan:** artifacts and rehearsal blocks working from deadline to now.
5. **Questions:** what to ask, verify, carry, or decide.
6. **Pre-mortem:** plausible failures with prevent/detect/recover actions.
7. **Contingencies:** likely, adverse, and surprise branches.
8. **Ten-minute card:** only what must be recalled immediately beforehand.

## Personal V0

- Paste one event and its related notes into the skill.
- Cap research at five primary sources and preparation output at one main page plus appendices.
- Generate a backward plan with effort estimates but do not write calendar events.
- Use the skill for ten varied commitments: meeting, interview, trip, exam, purchase, presentation, deadline, social event, appointment, and difficult conversation.
- After each event, record surprises, unused prep, missing prep, and outcome.
- Revise the template based on evidence rather than adding more sections.

## Build Boundary

**MVP:** standalone skill instructions, structured Markdown/JSON output, attached-document reading, primary-source research, and outcome review template.

**Later:** read-only calendar triggers, Gmail/Drive/Obsidian context assembly, automated refresh when details change, Telegram delivery, rehearsal simulations, and approved calendar-block creation.

The skill is allowed to be imaginative and thorough; its fixed constraint is a user-selected time budget so preparation does not become procrastination.

## Existing Products, Building Blocks, and Shortcuts

- [Google Calendar API](https://developers.google.com/calendar/api/guides/overview), ICS, and CalDAV are calendar-context adapters; event paste is enough for the first skill.
- [OpenAlex](https://docs.openalex.org/), [Crossref REST API](https://www.crossref.org/documentation/retrieve-metadata/rest-api/), official documentation, and organization-owned pages provide primary research material.
- [Obsidian API](https://github.com/obsidianmd/obsidian-api) or direct Markdown search can collect related notes and backlinks.
- Meeting-prep products, travel checklists, executive briefings, and military-style pre-mortems are useful product patterns. The distinctive combination is personal context + research + backward plan + scenario branches.
- Simplest implementation: a Codex/Hermes skill folder with an instruction file, `prep-brief.md` template, `event-review.md` template, and no application UI.

## Recommended Free-First Stack

- Markdown skill package with `references/`, output templates, and a JSON schema.
- Small Python/TypeScript context assembler for ICS, selected vault notes, and URLs.
- Local model for synthesis; research tool for current facts; optional stronger model for complex scenario simulation.
- SQLite only when longitudinal outcomes justify analysis.
- Telegram/n8n/Calendar integration after manual invocations prove repeatable value.

## Skill Architecture

`PrepRequest` stores mission, event, stakes, constraints, and budget. `EvidenceItem` stores source, date, claim, and relevance. `PreparationAction` stores timing, dependency, estimated effort, and completion. `Scenario` stores trigger, expected impact, preventive move, detection signal, fallback, and recovery. `PrepReview` connects predicted risks to observed surprises and outcomes.

The skill should allocate its token/research budget based on stakes and uncertainty, not event length.

## Build Slices

1. Manual skill with fixed brief template and ten-minute card.
2. Primary-source research and evidence table.
3. Pre-mortem/contingency generator with bounded branches.
4. Post-event review and reusable lessons.
5. Calendar context reader and lead-time triggers.
6. Goal-planner handoff and rehearsal mode.

## Drawbacks, Concerns, and Failure Modes

- Prep can expand indefinitely. Require a time budget and label optional depth.
- False precision in contingency probabilities can mislead. Rank relative plausibility and list assumptions.
- Research may be current but irrelevant. Every source must support a decision, question, or action.
- Calendar titles are often vague. Ask a few high-leverage questions instead of hallucinating context.
- Repeated templates can become ceremonial. Post-event reviews should delete unused sections.
- Some surprises are irreducible. Judge the skill on adaptability and recovery, not omniscience.

## Clever Hacks and Simpler Alternative

- Put a `PREP:` token in a calendar description; the workflow processes only opted-in events.
- Generate separate `T-7 days`, `T-24 hours`, and `T-10 minutes` views from one canonical brief.
- Use a deterministic checklist library for travel, interviews, presentations, and purchases; let the model fill only contextual gaps.
- Ask “what single missing fact could change the plan?” before broad research.
- Store lessons as reusable patterns linked to event type and people.

## Success Measures

- More required artifacts are ready before the deadline.
- Important unknowns are discovered earlier.
- The ten-minute card is actually used.
- Preparation stays within its budget.
- Post-event surprise severity and preventable failures decline across similar events.
- The user continues invoking the skill for high-stakes events after novelty fades.

## Product Path

Personal skill -> calendar-aware local workflow -> professional prep assistant -> shareable domain-specific prep packs. Apply [[Scope Expansion Checklist]] only when connecting other users, private organizational systems, or public delivery.

## Related

- [[Goal-to-Calendar Planner]]
- [[Jobs Search and Apply Tool]]
- [[Personal Study Curriculum]]
- [[Event Networking Copilot]]
- [[Project Ideas Index]]

