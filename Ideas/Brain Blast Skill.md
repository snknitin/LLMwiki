---
type: skill-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Cognitive Support and Explanation Skills#2. Brain Blast Skill]]"
status: concept
difficulty: easy
priority: p1
category: creative problem solving
form_factor:
  - Codex or Hermes skill
  - Telegram command
deployment: local-first
source_ideas:
  - Jimmy Neutron-style inventive solutions to common daily problems
tags:
  - creativity
  - problem-solving
  - invention
  - skills
---

# Brain Blast Skill

> Turn an everyday irritation into one cheap testable intervention by combining systematic inventive operators with playful, high-energy ideation.

## Product Outcome

The skill should create the feeling of a sudden inventive spark without returning twenty impractical ideas. It reframes the problem, exposes hidden constraints, applies several creativity operators, and recommends the most reversible experiment.

It is useful for household friction, learning, work routines, travel, shopping, automation, physical organization, communication, and small product ideas. It remains a skill rather than a dashboard until a backlog of experiments needs management.

## Invocation and Output Contract

Input: observed problem, who experiences it, frequency, current workaround, constraints, available materials/software, time budget, and what “better” means.

Output:

1. Symptom, underlying job, and system-level cause.
2. Assumptions that can be inverted or removed.
3. Analogies from at least three unrelated domains.
4. Options created by subtraction, substitution, combination, automation, environmental redesign, and incentive change.
5. One two-minute hack, one weekend prototype, and one ambitious redesign.
6. Scorecard: benefit, effort, reversibility, dependency count, maintenance cost, and learning value.
7. Recommended experiment, setup, prediction, observation window, and stop rule.

## Personal V0

- Implement a deterministic deck of twenty creativity operators.
- Ask the user for a real annoyance and apply five operators selected for that problem type.
- Let a local model combine and concretize the strongest results.
- Produce one experiment card in Markdown.
- Run three Brain Blasts per week for a month and log attempted/not-attempted, benefit, friction, and unexpected effects.
- Keep a gallery of useful inventions and spectacularly bad ideas.

## Build Boundary

**MVP:** skill instructions, operator library, scoring rubric, experiment template, and outcome log.

**Later:** photo/context input, parts/inventory awareness, cost lookup, CAD/sketch generation, automation-script scaffolding, and a searchable invention journal.

## Existing Products, Building Blocks, and Shortcuts

- [TRIZ](https://www.triz.org/) is the classic systematic-invention reference; use a compact operator subset rather than reproducing an entire methodology.
- Design-thinking “How might we,” morphological analysis, SCAMPER, and pre-mortem patterns are reusable deterministic operators before model generation.
- [OpenSCAD](https://openscad.org/) can turn parameterized physical concepts into quick 3D-printable sketches; Mermaid/Excalidraw covers process ideas.
- [Home Assistant](https://github.com/home-assistant/core), n8n, and small shell/Python scripts are implementation targets for household or digital automations.
- The simplest alternative is a shuffled card deck plus an experiment log. The model’s job is synthesis and adaptation, not being the only source of creativity.

## Recommended Free-First Stack

- Markdown skill package with operator cards and examples.
- Local model via Ollama/llama.cpp.
- Plain Markdown experiment log; SQLite only when pattern analysis becomes useful.
- Optional scripts for cost estimates, diagrams, or Home Assistant/n8n workflow skeletons.
- Telegram command `/brainblast` for quick capture after the manual skill is stable.

## Skill Logic

Classify the problem as information, physical flow, timing, attention, coordination, cost, reliability, or motivation. Select operators that attack different dimensions. Deduplicate solutions by mechanism, not wording. Reject ideas that violate hard constraints. Prefer reversible tests with high information gain.

## Build Slices

1. Problem intake and operator deck.
2. Structured option generation and mechanism deduplication.
3. Scoring plus one experiment card.
4. Outcome review and pattern retrieval.
5. Diagram/code/CAD helpers for selected concepts.

## Drawbacks, Concerns, and Failure Modes

- Novelty can hide maintenance burden. Score ongoing effort explicitly.
- The skill may solve the stated symptom rather than the actual job. Reframe before ideating.
- Too many choices prevent action. Output one recommendation and keep alternatives collapsed.
- Generated physical ideas may ignore dimensions/material constraints. Ask for measurements and mark assumptions.
- Automation can move rather than remove effort. Compare total lifecycle cost.

## Clever Hacks and Simpler Alternative

- Force one idea that removes a step entirely.
- Force one solution using only objects already available.
- Use “worst possible solution” to reveal hidden constraints, then invert it.
- Ask what a restaurant, operating system, ant colony, airport, and game designer would do.
- Set a five-minute build threshold for the first experiment.

## Success Measures

- At least one proposed experiment is attempted each week.
- Attempted ideas reduce time, friction, cost, or error in a measurable way.
- Recommendation acceptance improves as the skill learns personal constraints.
- The output becomes shorter without losing mechanism diversity.
- Successful interventions remain useful after four weeks.

## Product Path

Personal creativity skill -> invention journal -> domain packs for home/work/study -> maker-assistant product. Run [[Scope Expansion Checklist]] before distributing generated physical/control workflows to others.

## Related

- [[Personalized ADHD Skill Upgrade]]
- [[Side-Hustle Radar]]
- [[Jarvis and Alfred]]
- [[Motto Agent Council]]
- [[Project Ideas Index]]

