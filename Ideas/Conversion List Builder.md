---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Creator Growth and Local Video Pipelines#3. Conversion List Builder]]"
status: concept
difficulty: medium
priority: p1
category: audience research and conversion
form_factor:
  - local research dashboard
  - evidence-backed list builder
deployment: local-first
source_ideas:
  - build lists of users who may convert to paying customers
  - analyze what each prospect needs and why they might pay
tags:
  - leads
  - conversion
  - audience
  - research
  - crm
---

# Conversion List Builder

> Build a ranked research queue of people or organizations by showing the observable evidence for fit, need, timing, reachability, and contradictions—then learn which signals actually correlate with conversation, trial, and payment.

## Product Outcome

For one product and one falsifiable audience hypothesis, create a board answering: who should I talk to, why now, what do they appear to need, what evidence supports that belief, what would disconfirm it, and what happened after contact?

This tool produces research queues and conversion hypotheses. [[Personal Voice Ghostwriter and DM Desk]] handles conversations; [[Demand Generation Workbench]] decides the broader experiment.

## Personal V0

1. Pick one tool and write one narrow audience/problem hypothesis.
2. Define five to eight observable positive signals, two contradiction signals, expiry windows, and one target outcome.
3. Assemble fifty candidates manually or from user-supplied URLs/exports.
4. Store exact evidence, capture date, confidence, and source for every signal.
5. Compute a transparent score: fit + observable need + timing + reachable path + prior interest - contradiction - staleness.
6. Review the top ten and send only an approved batch to the DM desk.
7. Join outcomes—replied, problem confirmed, trial, paid, not now, disconfirmed—back to the signals.

## Build Boundary

**MVP:** one hypothesis board, evidence schema, deterministic scoring, review queue, CSV export, and outcome analysis.

**Later:** source adapters, monitoring/refresh, CRM/email list sync, saved audience templates, cohort analysis, and team workflows.

Avoid a giant universal lead database. One hypothesis and target action per board keeps learning interpretable.

## Existing Products, Building Blocks, and Shortcuts

- [listmonk](https://github.com/knadh/listmonk) is a self-hosted mailing-list/segmentation system for approved owned lists; keep research evidence outside it.
- [GrowthBook](https://github.com/growthbook/growthbook) can later run product experiments, but it does not replace the lead evidence ledger.
- X’s official [List member API](https://docs.x.com/x-api/lists/list-members/quickstart/manage-list-members) and liked-post retrieval can support user-selected watchlists when access is worthwhile.
- Airtable, Clay, Apollo, HubSpot, Attio, and spreadsheets are product references for enrichment and pipeline management. The differentiator is transparent falsifiable hypotheses, evidence expiry, and outcome learning.
- A Markdown/CSV table plus SQLite query is the simplest useful product; build a web UI only when review becomes painful.

## Recommended Free-First Stack

- SvelteKit/Streamlit board over SQLite.
- YAML hypothesis definitions and ordinary SQL/rule scoring.
- Playwright/manual URL capture adapters only as needed.
- Local model extracts candidate signals from supplied pages and drafts rationales; code computes the score.
- CSV export to CRM/listmonk/DM desk; no bulk outreach engine inside this project.

## Data Model

`ConversionHypothesis` owns audience, problem, value, target action, window, success and contradiction conditions. `Candidate` owns identity and source links. `SignalDefinition` stores direction, weight, expiry, and evidence requirements. `SignalObservation` stores source, captured time, confidence, and value. `PriorityScore` stores decomposition. `ConversionOutcome` records stage, date, evidence, and learning.

## Build Slices

1. Hypothesis/target outcome schema.
2. Candidate and evidence capture.
3. Transparent score and review table.
4. Staleness/contradiction handling.
5. Export/import with DM desk.
6. Outcome cohorts and signal pruning.
7. One connector only after manual evidence is useful.

## Drawbacks, Concerns, and Failure Modes

- A precise score can hide weak evidence. Always show components and “what would change this rank.”
- Missing evidence is not a negative signal. Keep it missing.
- Stale timing clues mislead. Decay/expire them automatically.
- Willingness to pay is rarely inferable from public writing. Prioritize observable pain and learn price in real experiments.
- Tiny outcome datasets invite overfitting. Use simple cohorts and raw denominators.
- Collection can become procrastination. Cap each research board and require a conversation/experiment milestone.

## Clever Hacks and Simpler Alternative

- Start with twenty candidates and five signals in a CSV.
- Require one disconfirming observation before a candidate can receive the highest rank.
- Show evidence freshness as prominently as total score.
- Ask “why this person now?” in one sentence before generating any outreach.
- Delete signals that fail to distinguish outcomes after thirty conversations.

## Success Measures

- Top-ranked candidates more often confirm the problem than unranked/manual choices.
- Evidence and scoring can be independently inspected.
- Stale/contradictory candidates fall automatically.
- Research time per qualified conversation declines.
- The system learns which signals matter rather than merely accumulating contacts.

## Product Path

Personal evidence board -> reusable audience-research module -> vertical prospecting workbench -> paid research/CRM product. Run [[Scope Expansion Checklist]] before other-user data and outreach operations; preserve the evidence-first local core.

## Related

- [[Demand Generation Workbench]]
- [[Personal Voice Ghostwriter and DM Desk]]
- [[Side-Hustle Radar]]
- [[Auto-GTM Engine]]
- [[Project Ideas Index]]

