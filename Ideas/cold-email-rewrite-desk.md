---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: sales-writing
form_factor:
  - local web app
  - browser-extension candidate
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#4. Cold Email Rewrite Desk]]"
status: concept
tags: [email, sales, writing]
---

# Cold Email Rewrite Desk

> Rewrite a user-supplied outreach draft into concise, evidence-based variants and follow-ups—without sourcing leads or auto-sending.

## Product Outcome

The user pastes a draft, recipient context, relevance evidence, offer, and desired call to action. The tool returns a compact email, two alternate openings, three spaced follow-ups, and a claims/risks panel. The owner remains the sender.

## User and Core Workflow

1. Enter relationship, why-now evidence, allowed claims, proof, and CTA.
2. Validate that personalization is backed by user-provided context.
3. Generate structured variants at set word limits.
4. Run claim, tone, privacy, and compliance checklist.
5. Edit/copy or create a reviewable Gmail draft.

## Demo/Personal V0

Local form + Ollama JSON output + side-by-side versions + copy buttons. No OAuth, recipient discovery, tracking pixel, or sending.

## Build Boundary

**MVP:** one message, fixed fields, three variants/follow-ups, claims panel, manual copy.

**Out:** lead scraping, enrichment, automatic sending, inbox warming, tracking, reply impersonation, and campaign orchestration.

## Existing Products, Building Blocks, and Shortcuts

- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) enforces separate subject, opener, body, CTA, follow-ups, and warnings.
- [Gmail Drafts API](https://developers.google.com/workspace/gmail/api/guides/drafts) creates reviewable drafts rather than sending automatically.
- The FTC’s [CAN-SPAM compliance guide](https://www.ftc.gov/business-guidance/resources/can-spam-act-compliance-guide-business) supplies US commercial-email guardrails, including B2B scope.
- Gmail’s [sender guidelines](https://support.google.com/a/answer/14229414) cover authentication, spam rates, and bulk promotional requirements.

## Free-First Stack

React/Vite + TypeScript/Zod + Ollama. Store approved tone examples locally in SQLite/JSON. Add Gmail OAuth with narrow compose scope only after copy/paste proves useful.

## Architecture/Data Model

`OutreachBrief` stores relevance evidence, claims, proof, CTA, tone, and prohibited details. `DraftSet` stores structured variants. `PolicyFinding` links to offending text. `Approval` stores the user-edited final; no recipient list is required.

## Build Slices

1. Brief schema and deterministic lint rules.
2. Structured rewrite/follow-ups.
3. Claim evidence and diff view.
4. Style examples and optional Gmail draft export.

## Drawbacks/Concerns/Failure Modes

- Personalization can be fabricated; require evidence and show which phrase used it.
- Compliance varies by jurisdiction; do not claim a universal legal pass.
- Deliverability depends more on relevance, list quality, and reputation than wording.
- Sensitive recipient context should not be retained by default.

## Clever Hacks and Simpler Alternative

Require the user’s rough email first and optimize it; blank-page generation produces generic outreach. A deterministic 80-word editor with “one claim, one proof, one ask” can be useful even without an LLM.

## Success Measures

- Final email stays within chosen length.
- Every personalized fact maps to entered evidence.
- User can accept/edit/copy in under two minutes.
- No message is sent without explicit user action.

## Product Path

Local rewriting desk → Gmail/browser companion → team style/compliance library → paid sales-writing tool. Expansion needs jurisdictional review, provider/API compliance, and anti-abuse safeguards.

## Related Wikilinks

- [[google-review-reply-desk|Google Review Reply Desk]]
- [[Personal Voice Ghostwriter and DM Desk]]
