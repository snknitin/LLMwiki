---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: recruiting operations
form_factor:
  - local hiring workspace
  - ATS handoff packet
deployment: local-first with optional ATS connector
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#16. Recruiting Agency]]"
status: concept
tags:
  - recruiting
  - hiring
  - structured-interviews
---

# Recruiting Agency

> A structured hiring-design desk that improves the job definition, rubric, outreach, and interview plan while leaving sourcing decisions and candidate outcomes with accountable humans.

## Product Outcome

Turn a vague hiring request into a consistent evidence system: outcome-focused JD, must-have versus trainable skills, sourcing channels, precommitted scorecard, outreach drafts, interview loop, and candidate summary template. The goal is better decisions and reduced inconsistency, not automated rejection.

## User and Core Workflow

The hiring manager defines business outcomes and constraints. The system rewrites the JD, maps skills, checks potentially exclusionary requirements, and creates a rubric before candidate data is loaded. The user imports fictional/consented profiles or ATS exports; the app highlights evidence spans and missing information, drafts outreach, and generates structured interviews. Humans record decisions and overrides.

## Demo/Personal V0

Use one fictional role and five synthetic candidates. Produce a revised JD, weighted scorecard, channel plan, evidence-based candidate summaries, one outreach sequence, and a four-stage interview plan. Demonstrate that names/photos/protected attributes are hidden during the first screen.

## Build Boundary

No LinkedIn scraping, protected-trait inference, personality diagnosis, facial/voice analysis, automatic rejection, resume fabrication, or outreach sending. Ranking is decision support against a job-related rubric and exposes uncertainty. Local law and organizational policy govern future real use.

## Existing Products, Building Blocks, and Shortcuts

- [Greenhouse Harvest API](https://developers.greenhouse.io/harvest) exposes jobs, candidates, stages, and audited writes using `On-Behalf-Of`; use it for a future supported ATS handoff.
- [O*NET Web Services](https://services.onetcenter.org/) provides a primary occupational skills/task vocabulary instead of model-invented taxonomies.
- [OpenSkills](https://github.com/workforce-data-initiative/skills-api) is an open skills-data reference for normalization experiments.
- [JSON Resume](https://jsonresume.org/schema/) offers a typed profile interchange for synthetic fixtures and consented imports.

## Recommended Free-First Stack

Use Python/FastAPI, Pydantic schemas, SQLite, and a SvelteKit workspace. Ollama can rewrite and summarize with required evidence spans. Keep scoring deterministic and rubric-versioned. Export CSV/JSON/Markdown for ATS/manual use before building connectors.

## Architecture/Data Model

Model `Role`, `Outcome`, `Skill`, `RubricVersion`, `Candidate`, `EvidenceSpan`, `ScoreProposal`, `HumanScore`, `OutreachDraft`, `InterviewStage`, `Question`, `Decision`, and `Override`. Store source document hashes and never turn missing evidence into a negative score automatically.

## Build Slices

1. Role intake and outcome-based JD rewrite.
2. Skills map and precommitted rubric.
3. Synthetic candidate import with blind view.
4. Evidence-linked score proposals and summaries.
5. Outreach and structured interview plan.
6. Decision audit and ATS export preview.

## Drawbacks, Concerns, and Failure Modes

Historical hiring criteria encode bias. Resume language rewards coaching and privilege. Models may infer demographic proxies or overvalue keyword overlap. “Objective” numeric scores create false precision. Candidate data is sensitive and retention/access need controls. Outreach can become spam.

## Clever Hacks and Simpler Alternative

Build only the job scorecard and interview kit first. Blind the top of resumes, randomize candidate order, and require positive evidence for every score. Use paired human calibration on two synthetic profiles before evaluating real candidates.

## Success Measures

- Rubric is approved before candidate import.
- Every score proposal links to evidence or says “unknown.”
- No protected attribute or proxy appears in scoring features.
- Interviewers use the same anchored questions and record independent scores.
- Human overrides include a reason and remain auditable.

## Product Path

Start as a personal hiring-kit generator. A productized service needs candidate consent/privacy operations, bias evaluation, ATS security, jurisdictional employment-law review, accessibility, and transparent human decision ownership.

## Related

- [[Sales Development Agency]]
- [[User Research Agency]]
- [[AI Implementation Agency]]
