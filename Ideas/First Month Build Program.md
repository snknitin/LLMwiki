---
type: execution-plan
status: active
start: 2026-07-27
target: 2026-08-27
scope: eight urgent personal betas
tags:
  - monthly-plan
  - urgent
  - dogfooding
  - battle-testing
---

# First Month Build Program

The target is eight usable personal betas by **2026-08-27**. A beta is not feature-complete; it is a narrow workflow that has been exercised with real personal inputs, survived failures and restarts, and improved from recorded use.

## Beta Contracts

| Project | Repeated personal workflow | Minimum battle test |
|---|---|---|
| [[YouTube Learning Center]] | Turn saved videos and playlists into active learning | 20 varied videos; source, timestamp, coverage, probe, quiz, and regeneration failures recorded and regressed |
| [[Paper Logbook]] | Complete and revisit a daily page | 14 consecutive days; export, restore, schema migration, and offline restart tested |
| [[Finance Signals Dashboard]] | Review a bounded market brief | 15 market-day runs; signal noise labels, stale-source behavior, and formula fixtures |
| [[Net Worth Command Center]] | Reconcile the personal balance sheet | Three snapshots; one real importer; duplicate/re-import/currency/backup tests |
| [[Jobs Search and Apply Tool]] | Convert a qualified role into a truthful packet | 20 corrected job fixtures and real reviewed applications; zero unsupported claims |
| [[Goal-to-Calendar Planner]] | Plan and replan goal work around real commitments | Three weekly cycles; no fixed-event overlap; estimates and manual moves captured |
| [[Paisa Vasool Subscriptions]] | Review recurring charges and renewal actions | Gold set of true/false recurring charges; renewal verification and later statement check |
| [[Language Learning Lab]] | Complete a daily spaced language review | 21 daily sessions; persistence, due-date, leech, and content-correction feedback |

## Shared Foundation

- **Python/FastAPI** for ingestion, finance rules, job extraction, scheduling services, and a model gateway.
- **SQLite** for application state; **DuckDB/Parquet** for analytical history and repeatable finance transforms.
- A **local OpenAI-compatible model adapter** pointing to Ollama initially and DGX-hosted vLLM when throughput matters.
- **SvelteKit/Next.js or Streamlit** for local desktop workflows.
- **Expo** for Paper Logbook and Language Learning Lab, the two genuinely mobile daily tools.
- Markdown/JSON/CSV/ICS/Parquet exports as stable boundaries.
- Structured logs, fixture folders, migrations, backup/restore, and model/prompt version IDs from day one.

## Week 1 — Thin Vertical Slices

Create one real input-to-output path for all eight projects, deliberately using paste/CSV/manual import when integrations would delay learning. Establish canonical schemas, redacted fixtures, run commands, and a shared outputs directory. The objective is to begin dogfooding by the end of the week.

## Week 2 — Correctness and Recovery

Focus on deterministic failure: idempotent imports, duplicate handling, schema validation, formula fixtures, calendar conflict tests, evidence IDs, transcript anchors, offline persistence, export/restore, and clear error states. Do not add features while core correctness is unmeasured.

## Week 3 — Daily Use and Feedback

Run the eight workflows on their natural cadence. Capture every manual correction and abandonment reason as structured feedback. Improve thresholds, content, and interfaces only when a repeated observation supports the change. Add one high-value integration at most.

## Week 4 — Soak, Simplify, and Document

Freeze features for several days. Run backup recovery, source outage, stale data, corrupted input, model-unavailable, and interrupted-job drills. Delete unused abstractions. Write a one-command start, known limitations, data map, and next-month backlog for each beta.

## Quality Gates Shared by Every Tool

- A real personal workflow completes without editing the database by hand.
- Inputs, model/rule versions, and outputs are traceable.
- Deterministic logic has fixtures and regression tests.
- Model failure results in correction or a clear blocked state, not silent nonsense.
- Re-running the same input is idempotent or intentionally versioned.
- Data can be exported and restored on a clean install.
- Logs contain no secrets or unnecessary direct identifiers.
- Consequential actions remain drafts/previews.
- The tool has at least one week of observed use after its first vertical slice.
- The next iteration is chosen from use evidence, not idea-list momentum.

## Scope Rules

- If a source requires paid access, approval, or brittle scraping, switch to manual import and record the missing capability.
- If a native feature blocks progress, use a web or desktop substitute until the core loop is proven.
- If a model fails a typed schema repeatedly, add correction UI and a fixture instead of endless prompt tuning.
- Prefer a plain form/table over a polished dashboard until the transformation is correct.
- No billing, teams, public accounts, autonomous external writes, or broad cloud deployment this month.

## Existing 80% Projects

[[Angel and Demon Companion]], [[Half-Blood PDF]], and [[Understand This Paper]] are intentionally outside the build program. A short audit may record their working path and remaining 20%, but implementation resumes only after the urgent betas are stable.

## Related

- [[Personal Finance Cockpit]]
- [[Project Ideas Index]]
