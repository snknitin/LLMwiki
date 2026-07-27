---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#8. LeetCode Pattern Curriculum]]"
status: concept
difficulty: medium
priority: p1
category: coding education
form_factor:
  - local web app
  - Markdown curriculum
deployment: local-first
source_ideas:
  - explain Python solutions from Lee215, Stephan Pochmann, and Yaogao as tutorials
tags:
  - algorithms
  - python
  - spaced-repetition
  - coding
---

# LeetCode Pattern Curriculum

> A local Python algorithms curriculum that teaches pattern recognition, invariants, implementation, testing, and transfer using the user’s chosen problem links and solution references.

## Product Outcome

For each pattern, learn a small set of concepts, predict the technique for linked problems, implement locally, receive progressive hints, run reviewed tests, and explain the invariant. Public solution authors can inspire the reading list, but their work is linked and used only according to repository licenses.

## Personal V0

- Author ten pattern modules in Markdown/YAML.
- Each module includes prerequisite, invariant, template, common failure, complexity, and original example.
- Link to external problem pages rather than copying statements.
- Record pattern prediction before code.
- Run personal Python submissions against local reviewed tests and property tests.
- Offer a hint ladder: counterexample, invariant, data-structure clue, pseudocode.
- Schedule recognition, implementation, and transfer prompts with FSRS.
- Track earliest hint, time, failure type, and delayed re-solve.

## Build Boundary

**MVP:** Python only, user-authored curriculum, local code, no public sandbox, and no automated corpus scraping.

**Later:** browser editor, more languages, mentor feedback, near-transfer generators, and a safely isolated runner for other users. Automated scraping is still postponed because it is brittle and unnecessary for the personal build; release/licensing review is deferred.

## Existing Products, Building Blocks, and Shortcuts

- LeetCode supplies the problem interface; [Exercism](https://github.com/exercism) demonstrates open exercise tracks and mentoring workflows. Your project should organize and teach rather than clone another judge.
- [pytest](https://docs.pytest.org/) and [Hypothesis](https://hypothesis.readthedocs.io/) cover deterministic and property-based testing for personal Python solutions. A folder of tests is a better first correctness oracle than an LLM.
- [Piston](https://github.com/engineer-man/piston) and [Judge0](https://github.com/judge0/judge0) are self-hostable code-execution systems if this ever accepts other users’ code. For personal trusted code, a dedicated local virtual environment plus timeouts is much simpler.
- [Anki/FSRS](https://docs.ankiweb.net/deck-options.html#fsrs) can schedule invariants and pattern-recognition prompts immediately. The smallest useful build is Markdown modules + `pytest` fixtures + FSRS, with no custom editor.

## Free-First Stack

- **Content:** Markdown/YAML with source/license fields.
- **Execution:** local Python environment, pytest, Hypothesis, timeouts, and resource limits suitable for trusted personal code.
- **Data:** SQLite plus an open FSRS implementation.
- **UI:** Obsidian first; Vite/SvelteKit with Monaco only when it improves practice.
- **Models:** local model for hint/explanation drafts from verified code and tests.
- **Shared/public runner later:** self-hosted Piston or Judge0 on isolated Linux infrastructure, treated as security-sensitive.

## Clever Hacks and Simpler Alternative

- Begin with a forty-problem link list, ten original pattern notes, and pytest files; no app is required.
- Separate recognition, invariant, implementation, and adaptation so “solved” is not one bit.
- Generate adversarial tests from known failure modes, then freeze human-reviewed cases.
- Hide the pattern label on transfer problems.
- Compare code behavior and complexity rather than superficial AST similarity.

## Build Slices

1. Pattern schema and ten modules.
2. Local runner and reviewed fixtures.
3. Attempt/hint telemetry.
4. FSRS reviews and near-transfer tasks.
5. Optional editor and richer feedback.

## Battle-Testing Gates

- All canonical solutions pass property and edge-case tests.
- Every hint is consistent with the invariant and does not reveal more than its level.
- External content retains link, author, and license.
- Re-solving after a delay improves without pattern labels.
- No public untrusted-code endpoint exists in the personal version.

## Product Path

The strongest product is an original pedagogy layer and learner model. Mirroring competitive-programming content or running arbitrary public code adds legal/security costs without validating the teaching loop.

## Related

- [[Personal Study Curriculum]]
- [[Language Learning Lab]]
- [[Live Chess Tutor]]
- [[Project Ideas Index]]
