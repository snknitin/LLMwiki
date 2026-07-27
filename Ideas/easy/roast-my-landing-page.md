---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: website-diagnostic
form_factor:
  - local CLI
  - web report
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#15. Roast My Landing Page]]"
status: concept
tags: [websites, audit, viral]
---

# Roast My Landing Page

> Make deterministic audit evidence memorable with a useful roast: every joke points to a screenshot, metric, or copy problem and ends with a fix.

## Product Outcome

Provide a screenshot plus hero copy—or later a URL—and receive a prioritized report covering clarity, CTA, visual hierarchy, performance, accessibility, and trust. The share card is funny; the full report is constructive and evidence-backed.

## User and Core Workflow

1. Upload screenshot/paste copy or enter a permitted public URL.
2. Capture standard viewport evidence and run deterministic audits.
3. Normalize findings by impact and confidence.
4. Local model writes a roast plus a specific fix from approved findings.
5. Export full report and privacy-safe share card.

## Demo/Personal V0

Screenshot + hero-copy input, five manual/deterministic checks, local roast, fix list, and PNG card. Add URL capture/audits later.

## Build Boundary

**MVP:** user-provided screenshot/copy, five evidence types, prioritized fixes, local generation, share card.

**Out:** arbitrary internal URL access, defamatory owner scoring, guaranteed conversion uplift, auto-deployment, broad crawling, or visual regression platform.

## Existing Products, Building Blocks, and Shortcuts

- [Playwright screenshots](https://playwright.dev/docs/api/class-page) provide reproducible viewport/full-page captures.
- [Lighthouse](https://github.com/GoogleChrome/lighthouse) supplies local performance, accessibility, best-practice, and SEO audits.
- [axe-core](https://github.com/dequelabs/axe-core) adds machine-readable accessibility checks while acknowledging automation covers only part of WCAG.
- [Satori](https://github.com/vercel/satori) renders share cards.

## Free-First Stack

Node/TypeScript + Playwright + Lighthouse + axe-core + Ollama + Satori/resvg. Start with uploads; safe URL fetch validation is a later boundary.

## Architecture/Data Model

`AuditTarget` stores user input. `EvidenceFinding` stores tool, selector/region, metric, confidence, and screenshot. `Recommendation` references finding IDs. `RoastLine` references one recommendation. `ReportRun` freezes versions.

## Build Slices

1. Screenshot/copy upload and manual checks.
2. Evidence-to-fix templates.
3. Local roast and card.
4. Safe public URL capture.
5. Lighthouse/axe integration.

## Drawbacks/Concerns/Failure Modes

- Headless results vary by network/device; record conditions.
- Automated accessibility tests are incomplete.
- Arbitrary URL fetching risks SSRF; block private/reserved IPs and redirects.
- “Brutal” tone can be unhelpful; roast the page, not the person.

## Clever Hacks and Simpler Alternative

Validate the product with screenshot + hero copy only. Require the format “evidence → joke → fix,” which makes even a small ruleset useful.

## Success Measures

- Every roast line links to a visible finding.
- Top fixes are actionable without rereading the page.
- Identical evidence yields stable priorities.
- No private/reserved network target can be fetched.

## Product Path

Screenshot diagnostic → public URL auditor → agency lead magnet → monitored optimization product. Expansion needs safe-fetch security, data retention, and audit-tool/model license review.

## Related Wikilinks

- [[X Profile Autopsy]]
- [[Startup Idea Dating Profile]]

