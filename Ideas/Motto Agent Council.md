---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#19. Motto Agent Council]]"
status: concept
difficulty: medium
priority: p2
category: personal agents
form_factor:
  - local chat
  - decision dashboard
deployment: local-first
source_ideas:
  - agents that replicate different aspects of me and my motto
tags:
  - agents
  - decision-making
  - personal-model
---

# Motto Agent Council

> A council of small, explicit perspective agents—each representing one chosen value, role, or personal motto—that critique a decision and expose tradeoffs without pretending to be autonomous copies of the user.

## Product Outcome

For a decision or plan, each council member receives the same fact packet and responds from a narrow charter: builder, learner, health protector, skeptic, relationship steward, financial conservator, or another user-authored lens. A neutral chair summarizes agreements, conflicts, missing evidence, and reversible next steps.

## Personal V0

- Define three to five charters with purpose, questions, red lines, preferred evidence, and what they must not decide.
- Enter a decision, options, constraints, and source notes.
- Run perspectives independently with identical facts.
- Require each response to distinguish fact, assumption, value judgment, and unknown.
- Let agents challenge one another for one bounded round.
- Produce a decision memo and record the user’s actual choice.
- Review later outcomes to correct charters, not fabricate a “digital twin.”

## Build Boundary

**MVP:** text-only local app, four fixed charters, one deliberation round, structured memo, and decision journal.

**Later:** context from projects/calendar, voice/persona presentation, reusable skills, and team councils. Do not let council rhetoric silently trigger tools or make high-stakes decisions.

## Existing Products, Building Blocks, and Shortcuts

- [LangGraph’s supervisor examples](https://github.com/langchain-ai/langgraph-supervisor-py) show multi-agent handoff, but the project itself recommends simpler tool-calling patterns for many cases. A plain state machine is enough until resumable branches exist.
- [Open WebUI custom models](https://docs.openwebui.com/features/workspace/models/) and Ollama model wrappers can test several charters over one base model without building an agent platform.
- [Pydantic](https://docs.pydantic.dev/) or JSON Schema can force fact/assumption/value/unknown fields; a deterministic comparison table should preserve dissent before any synthesis.
- Simplest alternative: one prompt emits four named perspectives in strict JSON, followed by non-LLM comparison. Split into independent calls only if anchoring or diversity tests justify the cost.

## Free-First Stack

- **UI:** local SvelteKit or Open WebUI custom interface.
- **Orchestration:** plain Python state machine or LangGraph only when durable branches are needed.
- **Data:** SQLite for charters, fact packets, arguments, decisions, and outcomes.
- **Models:** one local model called with independent contexts; diversity comes from charters and evidence, not random temperature alone.
- **Verification:** JSON Schema plus deterministic checks for citations and claim labels.
- **Integration:** read-only links to Obsidian/project notes.

## Clever Hacks and Simpler Alternative

- A Markdown template with four headings can validate whether the council helps before building agents.
- Run agents independently before showing prior answers to reduce convergence.
- Ask one “red team” to identify missing options, not merely choose among supplied ones.
- Keep each charter short and editable; long personality biographies create theatrical noise.
- Score the memo six weeks later against the outcome to improve the process.

## Build Slices

1. Charter editor and fact-packet schema.
2. Independent responses with fact/assumption/value labels.
3. One critique round and chair synthesis.
4. Decision/outcome journal.
5. Read-only context retrieval and comparison analytics.

## Success Measures

- Perspectives remain meaningfully different without contradicting shared facts.
- Unknowns and reversible tests are surfaced.
- The council reduces overlooked consequences, not only decision time.
- Every external fact links to supplied evidence.

## Product Path

This can remain a personal reasoning tool or become an open-source deliberation skill. If productized, the useful layer is transparent charters and outcome learning—not a claim to clone a person.

## Related

- [[Jarvis and Alfred]]
- [[Angel and Demon Companion]]
- [[Marionettist Utopia]]
- [[Project Ideas Index]]
