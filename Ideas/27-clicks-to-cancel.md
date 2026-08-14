---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: consumer automation
form_factor:
  - local browser assistant
  - evidence report
deployment: local-first desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#1. 27 Clicks to Cancel]]"
status: concept
tags:
  - subscriptions
  - browser-automation
  - consumer-rights
---

# 27 Clicks to Cancel

> A user-supervised cancellation navigator that measures dark-pattern friction, preserves evidence, and stops for approval before the irreversible final action.

## Product Outcome

Turn “I need to cancel this” into a reproducible evidence bundle: the exact path taken, elapsed time, clicks, retention screens, disclosed consequences, final status, and receipt. The personal benefit is saving attention; the public-interest angle is an aggregate friction benchmark built from reviewed facts rather than accusations.

## User and Core Workflow

The user names a service and opens an authenticated browser profile. The assistant discovers likely account/billing routes, navigates one step at a time, screenshots material screens, and records semantic actions. At the final cancellation boundary it summarizes effective date, refund or fee, benefit loss, and outstanding uncertainty. The user approves or abandons; the assistant then verifies the resulting account state and stores the receipt.

## Demo/Personal V0

Build a local mock service with a deliberately annoying 12-step maze, branching offers, disabled-looking buttons, and a fake chat handoff. Run the navigator, show a live click counter, pause on the final action, and export an HTML/Markdown receipt. A second demo can parse an RFC 8058 unsubscribe header without contacting a live merchant.

## Build Boundary

The prototype does not evade CAPTCHAs, impersonate the user on calls, make legal claims, publish company rankings, or execute final cancellation without an explicit confirmation bound to the current page state. Credentials remain in the user-controlled browser profile; never collect raw passwords.

## Existing Products, Building Blocks, and Shortcuts

- [Playwright](https://playwright.dev/docs/intro) provides locators, auto-waiting, screenshots, and trace files; use it for deterministic flows and replay instead of inventing a browser driver.
- [Browser Use](https://github.com/browser-use/browser-use) can recover when labels/layouts vary; restrict it to selecting from an allowlisted action set and fall back to manual control.
- [RFC 8058](https://datatracker.ietf.org/doc/html/rfc8058) defines HTTPS one-click list unsubscribe; prefer this machine-readable path for email lists.
- The [FTC Negative Option Rule page](https://www.ftc.gov/legal-library/browse/rules/negative-option-rule) is the primary status reference; store jurisdiction and capture date rather than encoding a stale universal legal verdict.

## Recommended Free-First Stack

Use TypeScript, Playwright, SQLite, and a local SvelteKit review UI. Playwright is strongest for observable browser state; SQLite is enough for runs/actions/artifacts; SvelteKit can display the trace and approval card. Add a small local model only to classify screen intent, never to directly click arbitrary coordinates. Store screenshots and HTML snapshots on disk with content hashes.

## Architecture/Data Model

Core records are `Service`, `Run`, `PageSnapshot`, `Action`, `Disclosure`, `Approval`, `Outcome`, and `Artifact`. Every action records URL origin, locator/label, pre/post screenshot hashes, timestamp, actor, and confidence. The state machine is `discover → navigate → review_required → approved → execute → verify`, with `aborted` available from every state.

## Build Slices

1. Mock cancellation maze and typed state machine.
2. Playwright recorder with trace, screenshot, and click count.
3. Consequence extractor and approval card.
4. Final-state verifier and receipt renderer.
5. RFC 8058 parser and dry-run view.
6. Optional aggregate benchmark using manually approved, redacted facts.

## Drawbacks, Concerns, and Failure Modes

DOM changes, regional variants, mobile-only flows, chat/phone requirements, and anti-bot controls make maintenance expensive. An incorrect click can forfeit data or benefits. Screenshots may contain personal information. A raw click count can be gamed and does not alone prove deception. Public “shame” labels add defamation and moderation risk.

## Clever Hacks and Simpler Alternative

Start as a cancellation co-pilot: find the correct support page, highlight the next control, and record while the human clicks. This yields most evidence value with much less risk. Maintain service-specific recipes only after two successful supervised runs; use visual/agentic recovery as an exception.

## Success Measures

- Complete the mock maze with a correct, reviewable action log.
- Zero irreversible actions without a matching approval record.
- Receipt identifies the final state and all material disclosures.
- A user can resume manual control at any step.
- Redaction removes account identifiers from an export.

## Product Path

Personal utility first; then an open recipe/measurement format. A consumer product would need jurisdiction-aware policy, secure browser isolation, insurer-grade auditability, and careful factual moderation before any public leaderboard.

## Related

- [[inbox-zero-mercenary|Inbox Zero Mercenary]]
- [[Paisa Vasool Subscriptions]]
- [[Scope Expansion Checklist]]
