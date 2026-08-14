---
type: workflow-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Creator Growth and Local Video Pipelines#4. Demand Generation Workbench]]"
status: concept
difficulty: medium
priority: p0
category: demand discovery and experimentation
form_factor:
  - experiment dashboard
  - local decision ledger
deployment: local-first
source_ideas:
  - AI agent to generate demand for products by demonstrating life improvement
tags:
  - demand
  - experiments
  - positioning
  - product-marketing
---

# Demand Generation Workbench

> Turn uncertain beliefs about audience, pain, promise, proof, offer, and channel into low-cost experiments—and make the system decide whether to continue, revise, or stop based on observed behavior rather than content volume.

## Product Outcome

The workbench does not claim it can manufacture demand by persuasion alone. It discovers latent demand, sharpens a valuable change, demonstrates that change credibly, and tests whether people take increasingly costly actions. Every experiment has a hypothesis, audience, offer, channel, asset, success event, evidence threshold, and decision rule written before results arrive.

It may hand ad briefs to [[Meta Ad Creative Studio]], candidate hypotheses to [[Conversion List Builder]], and launch assets to [[Auto-GTM Engine]], but it owns the experiment and learning ledger.

## Personal V0

1. Select one active personal project.
2. Write three competing problem hypotheses for narrow audiences.
3. Design one two-week test for each with success, revise, and stop rules.
4. Use at least two evidence types: qualified conversations plus a behavioral action such as sample request, data import, booked session, repeat use, or payment.
5. Build only the minimum landing page/sample/concierge artifact.
6. Log observation separately from interpretation.
7. End every test with continue/revise/stop and the next falsifiable belief.

## Supported Experiment Types

- Problem interview about current behavior and workaround.
- Concierge delivery of the desired result.
- Concrete sample artifact rather than a vague waitlist.
- Targeted landing page with one audience/problem/outcome/action.
- Fake-door or feature-interest test inside a personal product.
- Price/packaging conversation.
- Time-to-value/onboarding comparison.
- Small paid creative test whose concept comes from the Meta studio.

## Build Boundary

**MVP:** hypothesis/experiment templates, event ledger, interview evidence, raw-denominator dashboard, decision rules, and weekly review.

**Later:** landing-page templates, event instrumentation adapters, listmonk, GrowthBook, paid-ad imports, PostHog, and portfolio-wide experiment memory.

Do not make automated content production the core. Output without contact with reality is not demand evidence.

## Existing Products, Building Blocks, and Shortcuts

- [GrowthBook](https://github.com/growthbook/growthbook) supplies self-hosted feature flags and proper randomized experiments once exposures/outcomes are reliable.
- [listmonk](https://github.com/knadh/listmonk) can manage an owned email list and segments.
- [n8n](https://github.com/n8n-io/n8n) can orchestrate experiment events, reminders, and asset handoffs.
- PostHog, Plausible, Google Analytics, landing-page builders, and product-discovery tools are product references. A local ledger is clearer for early interviews/concierge tests.
- Simplest implementation: one Markdown experiment file, one event CSV, and a weekly decision note.

## Recommended Free-First Stack

- Markdown/YAML experiment manifests + SQLite.
- SvelteKit/Streamlit review dashboard or Obsidian Dataview initially.
- Static landing-page template with minimal event endpoint.
- n8n/scripts for reminders and artifact movement.
- GrowthBook only for genuine randomized tests; listmonk only when an approved email list exists.
- Local model summarizes recorded evidence but cannot alter raw events or decision thresholds.

## Evidence Hierarchy

Keep evidence types distinct: payment/repeated use; high-friction activation; concrete problem confirmation; qualified signup/sample request; click; impression/like. Do not sum them as interchangeable points. The workbench should always show the strongest evidence type and raw denominator.

## Build Slices

1. Hypothesis and precommitted decision-rule templates.
2. Interview/observation ledger.
3. Behavioral event capture and raw funnel.
4. Continue/revise/stop review workflow.
5. Reusable landing/sample/concierge templates.
6. Ads/list/analytics adapters.
7. Cross-project learning library.

## Drawbacks, Concerns, and Failure Modes

- Automation can avoid the discomfort of customer conversations. Make them a first-class experiment.
- A landing-page conversion validates only the presented promise and action.
- Small samples produce false certainty. Allow “insufficient evidence.”
- Changing copy, design, offer, and audience together destroys learning.
- Vanity engagement can masquerade as demand. Keep the evidence hierarchy visible.
- The system may rationalize a favored project. Write stop rules in advance.

## Clever Hacks and Simpler Alternative

- Offer a sample outcome before building the full product.
- Compare three problem statements with ten qualified people each.
- Use a concierge workflow to discover the actual input/quality/turnaround constraints.
- Keep one landing-page design fixed across hypotheses.
- Publish a weekly “what I now believe and why” note.

## Success Measures

- Every active project has a current falsifiable demand hypothesis.
- Experiments conclude with an explicit decision.
- Higher-friction evidence accumulates over time.
- The number of untested assumptions declines before major builds.
- Stopped/revised experiments save more effort than the workbench costs.

## Product Path

Personal demand lab -> reusable GTM decision system -> consulting playbook -> experiment-management product. Apply [[Scope Expansion Checklist]] before operating experiments for others; keep the evidence/decision ledger stable.

## Related

- [[Side-Hustle Radar]]
- [[Conversion List Builder]]
- [[Meta Ad Creative Studio]]
- [[Auto-GTM Engine]]
- [[Creator Content Engine]]
- [[Project Ideas Index]]

