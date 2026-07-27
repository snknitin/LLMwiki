---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#2. Personal Study Curriculum]]"
status: concept
difficulty: medium
priority: p0
category: learning
form_factor:
  - local web app
  - Obsidian workflow
deployment: local-first
source_ideas:
  - Personal Study curriculum
tags:
  - education
  - planning
  - spaced-repetition
---

# Personal Study Curriculum

> A living curriculum that turns a learning goal, available time, and saved resources into a dependency-aware plan with practice, retrieval, projects, and evidence of mastery.

## Product Outcome

The app should answer “what should I learn next, why is it next, and how will I prove I understand it?” It is not another endless course catalog. It maintains a small current syllabus, schedules deliberate practice, diagnoses weak prerequisites, and revises the route from actual performance.

## Personal V0

- Enter one target outcome, deadline, weekly hours, current knowledge, and preferred learning modes.
- Import notes, books, videos, courses, code repositories, and problem sets.
- Build a concept graph with prerequisite edges and confidence estimates.
- Produce a two-week sprint: learn, recall, solve, build, explain, and review.
- Generate short diagnostic questions before assigning material.
- Record evidence: quiz score, solved problem, Feynman explanation, project artifact, or delayed recall.
- Write a weekly Markdown review that proposes curriculum changes for approval.

## Build Boundary

**MVP:** one subject, manual resource import, two-week plan, simple quiz cards, and Markdown/ICS export.

**Not yet:** social cohorts, marketplace courses, autonomous calendar edits, universal content ingestion, or high-stakes grading.

## Existing Products, Building Blocks, and Shortcuts

- [Anki’s FSRS scheduler](https://docs.ankiweb.net/deck-options.html#fsrs) and the open [FSRS implementations](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler) solve memory-item scheduling; reuse them instead of inventing another spaced-repetition algorithm.
- [MIT OpenCourseWare](https://ocw.mit.edu/about/) and [OpenStax](https://openstax.org/about) provide strong canonical course/textbook starting points. The tool’s job is sequencing, evidence, and adaptation—not generating an entire subject from scratch.
- The [Obsidian plugin API](https://github.com/obsidianmd/obsidian-api) exposes vault files, metadata, links, headings, blocks, and workspace commands. A Markdown-first curriculum can become interactive later without moving its canonical content into a proprietary database.
- Simpler alternative: one curriculum Markdown template plus Anki cards and a Sunday review. Build graph editing only after dependency mistakes recur.

## Free-First Stack

- **UI:** SvelteKit or Next.js local web app; optional Obsidian views generated as Markdown.
- **Backend:** FastAPI.
- **Data:** SQLite with tables for concepts, edges, resources, sessions, assessments, and evidence.
- **Search:** SQLite FTS first; embeddings only for resource-to-concept suggestions.
- **Models:** local text model for extraction and question drafts; deterministic scheduler for spacing and workload.
- **Automation:** n8n weekly review; ICS export before Google Calendar write access.

## Learning Engine

Use a mastery state per concept: `unknown`, `recognized`, `recalled`, `applied`, `transferred`. Advancing requires evidence after a delay, not a self-reported “done.” The planner selects the smallest set of prerequisites needed for the next authentic task and reserves at least half of study time for retrieval or production.

## Build Slices

1. Goal wizard and concept graph editor.
2. Manual curriculum builder with workload estimates.
3. Session runner and evidence capture.
4. Spaced review scheduler.
5. Local-model resource parser and question generator.
6. Weekly adaptation report with before/after plan diff.

## Success Measures

- At least 80% of planned weekly time is realistically scheduled.
- The learner can explain why each current task exists.
- Delayed recall improves over four weeks.
- Every week produces a visible artifact, not only consumed content.
- Curriculum churn stays low unless assessment evidence changes.

## Product Path

The personal version can become an open-source “curriculum as code” tool: a portable YAML/Markdown syllabus, assessment evidence, and adapters for notes or calendars. A paid version could add mentor review, cohort curricula, richer content licensing, and organization skill maps.

## Open Decisions

- First subject to dogfood.
- Whether Obsidian is the canonical data store or only an output.
- Preferred session length and maximum concurrent concepts.

## Related

- [[LongVid Learning Studio]]
- [[LeetCode Pattern Curriculum]]
- [[Language Learning Lab]]
- [[Goal-to-Calendar Planner]]
- [[Project Ideas Index]]
