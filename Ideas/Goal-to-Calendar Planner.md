---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#3. Goal-to-Calendar Planner]]"
status: concept
difficulty: medium
priority: urgent
urgency: personal-beta-by-2026-08-27
category: personal operations
form_factor:
  - local dashboard
  - calendar integration
deployment: local-first
source_ideas:
  - connect Google Calendar to a todo app that builds SMART tasks from goals
tags:
  - calendar
  - planning
  - goals
  - automation
---

# Goal-to-Calendar Planner

> An approval-based planning engine that turns a large goal into measurable milestones, feasible tasks, and protected calendar blocks, then replans from what actually happened.

## Product Outcome

The user states an outcome such as “finish a working AR prototype in six weeks.” The planner asks for evidence of done, constraints, recurring obligations, energy patterns, and available hours. It proposes a dependency-aware task tree and calendar plan with slack instead of filling every open minute.

## Personal V0

- Define one goal, deadline, success evidence, exclusions, and weekly time budget.
- Import calendar events read-only and define protected hours.
- Break the goal into milestones and tasks with duration ranges, dependencies, and “next physical action.”
- Validate that the plan fits available capacity.
- Preview a week as a diff before creating any blocks.
- Mark blocks done, partial, skipped, or interrupted and capture the reason.
- Replan unfinished work without silently moving fixed commitments.
- Produce a weekly review explaining slippage and changed assumptions.

## Build Boundary

**MVP:** one goal, read-only calendar or ICS import, task-tree editor, weekly schedule preview, and ICS export.

**Later:** two-way Google Calendar sync, multiple goals, task-manager connectors, energy prediction, and assistant-generated status updates. No autonomous calendar mutation in the first version.

### Month-One Personal Beta

Week one uses one goal, editable tasks, manual/ICS busy blocks, a transparent scheduler, and ICS export. Run a real weekly plan for three cycles. Capture estimate error, interruptions, unscheduled work, and every manual move; turn those observations into tests before enabling Google OAuth or two-way writes. The beta is trusted when it never overlaps fixed events and its replan explains every change.

## Existing Products, Building Blocks, and Shortcuts

- Google exposes official [Calendar event operations](https://developers.google.com/workspace/calendar/api/guides/overview) and [Tasks REST operations](https://developers.google.com/workspace/tasks/reference/rest). Use a dedicated tentative-plan calendar so every generated block can be hidden or deleted together.
- [OR-Tools CP-SAT](https://developers.google.com/optimization/scheduling) is purpose-built for assignment/scheduling constraints and should own placement; the LLM should only draft candidate tasks.
- [iCalendar RFC 5545](https://datatracker.ietf.org/doc/html/rfc5545) gives a provider-neutral export/import path, and [CalDAV](https://datatracker.ietf.org/doc/html/rfc4791) can be added later without redesigning the task schema.
- Sunsama, Motion, Reclaim, and SkedPal are product references for task-to-calendar planning. The simpler local alternative is to schedule only the next two actions, reserve 20–30% slack, and export an ICS diff.

## Free-First Stack

- **UI:** local SvelteKit/Next.js weekly planner.
- **Service:** FastAPI with a typed planning schema.
- **Data:** SQLite for goals, tasks, dependencies, estimates, calendar snapshots, and outcomes.
- **Scheduling:** OR-Tools constraint solver or a transparent greedy scheduler before LLM planning.
- **Models:** local model for clarifying questions and task decomposition; deterministic validation owns dates and conflicts.
- **Integration:** Google Calendar OAuth with least-privilege scopes; ICS import/export as a no-account fallback.
- **Automation:** n8n for Sunday review and approval notifications.

## Planning Contract

SMART language alone is insufficient. Each task needs an observable completion condition, owner, earliest start, deadline, estimated range, dependency list, and recovery action. The planner reserves buffer and rejects impossible plans with a capacity explanation.

## Build Slices

1. Goal interview and task-tree editor.
2. Calendar import and free-time calculation.
3. Deterministic weekly scheduler with buffers.
4. Plan diff and ICS export.
5. Outcome tracking and estimation calibration.
6. Approved two-way sync and weekly replan.

## Success Measures

- Zero double-booked fixed events.
- Planned work stays below a chosen percentage of true free capacity.
- Estimate error narrows over four weeks.
- Important work receives calendar time before reactive tasks.
- Replanning takes under ten minutes.

## Product Path

The local planner can become an open-source “goals to calendar” engine or a paid planning assistant for freelancers and students. The valuable differentiator is constraint-aware replanning with visible assumptions, not more AI-generated tasks.

## Related

- [[Personal Study Curriculum]]
- [[NPC Mode Personal Coach]]
- [[Jarvis and Alfred]]
- [[Paper Logbook]]
- [[Project Ideas Index]]
