---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: conversion optimization
form_factor:
  - local audit dashboard
  - preview generator
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#11. Landing Page Conversion Agency]]"
status: concept
---
# Landing Page Conversion Agency

> Audit a user-owned landing page, separate measured problems from hypotheses, and produce a prioritized rewrite plus testable preview.

## Product Outcome

Deliver an evidence pack an operator can act on: screenshots, deterministic checks, message hierarchy, rewritten sections, a preview, and a test plan. It must never promise uplift without an experiment.

## User and Core Workflow

The operator enters an owned URL or uploads HTML, defines audience and desired action, and runs the audit. The system captures desktop/mobile states, executes performance/accessibility checks, extracts copy, identifies friction, and proposes ranked changes. The operator accepts changes into a preview and exports a test brief.

## Demo/Personal V0

Audit three of the user’s pages. Generate a before/after side-by-side, five evidence-backed issues, one rewritten hero/CTA flow, and one experiment card with hypothesis, metric, and guardrail.

## Build Boundary

Include capture, Lighthouse/axe results, copy and structure analysis, editable preview, and test plan. Exclude editing production sites, analytics claims without data, competitor scraping, experiment execution, and autonomous publishing.

## Existing Products, Building Blocks, and Shortcuts

- [Lighthouse](https://developer.chrome.com/docs/lighthouse/overview) replaces custom performance, accessibility, best-practice, and SEO checks.
- [axe-core](https://github.com/dequelabs/axe-core) adds automated accessibility rules.
- [Playwright](https://playwright.dev/docs/intro) captures responsive states and verifies generated previews.
- [WebPageTest](https://docs.webpagetest.org/) offers a later external performance comparison when local tests are insufficient.

## Recommended Free-First Stack with Rationale

Use TypeScript, Node.js, Playwright, Lighthouse CLI, axe-core, SQLite, Next.js, and Ollama for bounded copy analysis. Browser tooling is native to the task; SQLite stores audit evidence; a local preview protects production.

## Architecture/Data Model

Store `sites`, `audit_runs`, `page_snapshots`, `measurements`, `observations`, `hypotheses`, `copy_blocks`, `change_proposals`, `previews`, and `experiments`. Every recommendation links to a screenshot region, measured check, or explicit user context.

## Build Slices

1. URL/HTML intake, screenshots, and deterministic audit.
2. Copy extraction, evidence-linked findings, priority model.
3. Editable rewritten preview and diff.
4. Experiment brief, export, and regression comparison.

## Drawbacks/Concerns/Failure Modes

Automated audits miss business context; dynamic pages may capture poorly; rewritten copy can invent proof; and accessibility scores are incomplete. Ask for audience/offer context, retain raw screenshots, lock factual claims, and label all conversion advice as a hypothesis.

## Clever Hacks and Simpler Alternative

A CLI that outputs a single annotated screenshot and top-five fix list may be a better first product than a full agency dashboard. Add rewriting only after deterministic findings are trusted.

## Success Measures

Track audit time, actionable-finding acceptance, unsupported-claim count, preview edits, issues fixed, repeat audit improvement, and experiments actually launched.

## Product Path

Personal CRO workbench → productized audit service → collaborative optimization platform. Before third-party sites, team accounts, production changes, or payments, run [[Scope Expansion Checklist]] for authorization, analytics, content rights, and release duties; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#11. Landing Page Conversion Agency]]
- [[Scope Expansion Checklist]]
- [[Shopify Product Page Optimizer]]

