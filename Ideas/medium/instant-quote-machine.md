---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: local service sales
form_factor:
  - mobile-friendly web app
  - lead qualification dashboard
deployment: local desktop with LAN access
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#7. Instant Quote Machine]]"
status: concept
---
# Instant Quote Machine

> Ask a homeowner a few high-signal questions and return a transparent ballpark range while giving the business a properly qualified lead.

## Product Outcome

Deliver a useful estimate in under a minute without implying false precision. The business receives photos, answers, confidence, assumptions, and the recommended next action; the customer receives a range and a clear reason for any site visit.

## User and Core Workflow

The business defines service types, minimum charges, price bands, modifiers, exclusions, and disqualifiers. A homeowner selects a job, answers branching questions, uploads photos, and receives either a rules-based range or “inspection required.” The operator reviews and converts the estimate into a formal quote.

## Demo/Personal V0

Implement one service such as room painting with five questions and three photos. Use a hand-built price book, show the calculation, and collect contact consent. Simulate the operator inbox; do not send or book automatically.

## Build Boundary

Include configurable questions, photo upload, deterministic calculator, assumptions, confidence, lead card, and manual conversion. Exclude computer-vision-only pricing, payment, binding quotes, dispatch, automated contractor matching, and arbitrary trades.

## Existing Products, Building Blocks, and Shortcuts

- [Stripe Quotes](https://docs.stripe.com/api/quotes) provides a later formal quote and acceptance lifecycle.
- [Gmail drafts](https://developers.google.com/workspace/gmail/api/guides/sending) stages follow-up for operator review.
- [rembg](https://github.com/danielgatis/rembg) can isolate an object or damaged area when a clean crop helps review.
- [Sharp](https://sharp.pixelplumbing.com/) handles local image resize, metadata removal, and thumbnails.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js PWA, SQLite/Drizzle, Zod, filesystem image storage, Sharp, and a small deterministic pricing engine. Ollama may summarize the lead, but rules own all money calculations. A PWA works on the phone without native-app overhead.

## Architecture/Data Model

Store `service_types`, `question_rules`, `price_rules`, `leads`, `answers`, `photos`, `estimate_versions`, `assumptions`, and `operator_actions`. A rules engine returns a range and explanation; a confidence gate decides whether a range may be displayed.

## Build Slices

1. Service schema, branching questionnaire, price calculator.
2. Photo handling, consent, and operator lead inbox.
3. Review/correction, formal quote handoff, and analytics.
4. Additional service templates after one trade is calibrated.

## Drawbacks/Concerns/Failure Modes

Hidden site conditions, misleading photos, regional price changes, and users treating a range as a promise can destroy trust. Show prominent assumptions, expire estimates, require site inspection above risk thresholds, and continuously compare estimates with actual jobs.

## Clever Hacks and Simpler Alternative

A hosted form plus a spreadsheet calculator and generated PDF is enough for the first ten leads. The product opportunity appears only if structured intake consistently saves the business time.

## Success Measures

Track completion time, qualified-lead rate, range-to-final-quote variance, inspection-required accuracy, operator minutes saved, and customer abandonment by question.

## Product Path

One-business estimator → reusable trade templates → white-label quoting product. Before customer-facing deployment, team accounts, messaging, or payment, run [[Scope Expansion Checklist]] for pricing disclaimers, data rights, channel terms, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#7. Instant Quote Machine]]
- [[Scope Expansion Checklist]]
- [[Deal Desk Agency]]

