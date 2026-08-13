---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: workflow consulting
form_factor:
  - local audit workspace
  - automation prototype
deployment: local-first with optional self-hosted runner
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#2. AI Implementation Agency]]"
status: concept
tags:
  - agency
  - automation
  - roi
---

# AI Implementation Agency

> An evidence-first workflow audit that finds five automations worth testing, makes ROI assumptions inspectable, and prototypes the safest high-value candidate.

## Product Outcome

Give a small team a prioritized implementation map rather than a generic “AI transformation” deck. Each opportunity shows the present workflow, frequency, labor and error cost, data sensitivity, integration surface, automation ceiling, failure cost, and a staged experiment with an owner.

## User and Core Workflow

The operator imports sanitized SOPs, forms, screenshots, and interview notes. The system extracts tasks and handoffs, asks targeted follow-ups, and builds an as-is process graph. A rules engine scores volume, variability, reversibility, and evidence quality; the model drafts five proposals. The user edits assumptions, selects one, and runs a sandboxed proof against fixtures. The final report compares baseline and observed results.

## Demo/Personal V0

Use one of your own recurring workflows—such as turning invoice emails into a tracker. Capture ten historical examples, measure the manual baseline, generate five candidate improvements, and implement only a draft-producing flow. Show before/after time, exceptions, and every step requiring human approval.

## Build Boundary

No access to a client’s production systems, employee surveillance, automated layoffs, autonomous external communication, or savings guarantees. ROI is a range derived from user-entered rates and measured frequency. The demo handles sanitized fixtures and read-only connector data.

## Existing Products, Building Blocks, and Shortcuts

- [n8n](https://docs.n8n.io/hosting/) supplies self-hosted triggers, connectors, schedules, retries, and approval patterns; use it once the target workflow is known.
- [Activepieces](https://www.activepieces.com/docs/install/overview) is a lighter open-source automation builder and a useful reference for simple client handoff.
- [Dify](https://github.com/langgenius/dify) combines model routing, workflow graphs, RAG, and observability; use it for rapid LLM-flow experiments while noting its [multi-tenant licence conditions](https://github.com/langgenius/dify/blob/main/LICENSE) for a future hosted product.
- BPMN tools such as [bpmn.io](https://github.com/bpmn-io/bpmn-js) avoid inventing a process-map format and make human review easier.

## Recommended Free-First Stack

Use FastAPI/Pydantic for the audit service, SQLite for projects and assumptions, a SvelteKit UI, and Mermaid or bpmn-js for process maps. Run deterministic calculations in Python; call Ollama for extraction and proposal drafting. Use n8n only for the selected prototype because premature orchestration creates impressive plumbing without evidence of value.

## Architecture/Data Model

Model `Organization`, `Workflow`, `Step`, `Actor`, `Artifact`, `PainPoint`, `Assumption`, `Opportunity`, `Risk`, `Experiment`, and `Measurement`. Store evidence spans for every inferred step. Version the scoring rubric and retain the manual baseline so proposal changes are reproducible.

## Build Slices

1. Guided interview and evidence upload.
2. As-is workflow graph with editable steps.
3. ROI/risk rubric and sensitivity ranges.
4. Five ranked opportunity cards.
5. Fixture-driven prototype for one opportunity.
6. Experiment report and 30-day implementation backlog.

## Drawbacks, Concerns, and Failure Modes

Teams describe idealized rather than actual processes. Labor savings double-count time that cannot really be redeployed. Integration and exception handling dominate cost. Models can recommend automating a bad control or sensitive decision. Connector credentials and client data expand the security perimeter.

## Clever Hacks and Simpler Alternative

Begin with a spreadsheet: task, frequency, minutes, exception rate, failure cost, reversibility, and data class. A two-hour “automation clinic” plus one Loom-sized prototype may validate demand before building an agency platform. Require one week of manual baseline logging for the top opportunity.

## Success Measures

- Every proposed saving traces to a measured or user-approved assumption.
- At least one prototype handles 80% of the fixture set without silent error.
- Exceptions are visible and routed to a human.
- The client can explain why the top proposal outranks the others.
- The report results in a concrete owner and next experiment.

## Product Path

Start as a repeatable personal consulting kit. Later paths are a vertical agency, an open workflow-audit template, or a hosted evidence/ROI workspace; connector depth should follow repeated demand in one vertical.

## Related

- [[Finance Ops Agency]]
- [[Sales Development Agency]]
- [[Support FAQ Builder]]
