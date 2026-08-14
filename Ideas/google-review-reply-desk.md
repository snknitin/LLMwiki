---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: reputation-management
form_factor:
  - local writing desk
  - business-profile integration candidate
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#7. Google Review Reply Desk]]"
status: concept
tags: [reviews, local-business, writing]
---

# Google Review Reply Desk

> Draft short, privacy-safe review replies and separate public response from private recovery work.

## Product Outcome

Paste a review, rating, business tone, and known facts. Receive a public reply, internal recovery note, escalation flag, and prohibited-details warning. The owner reviews and posts manually in V0.

## User and Core Workflow

1. Enter review and choose verified facts/offers the reply may use.
2. Classify praise, routine complaint, safety/legal allegation, harassment, or unclear.
3. Draft a short public response grounded in approved facts.
4. Route serious cases to a neutral “contact us privately” template.
5. Copy manually or later update through the official API.

## Demo/Personal V0

Local form with five synthetic reviews, three business tones, risk flags, approval/edit/copy, and a small library of approved offers.

## Build Boundary

**MVP:** pasted reviews, structured draft, escalation rules, privacy checker, manual copy.

**Out:** scraping listings, autonomous replies, invented refunds, admissions of liability, fake reviews, multi-location SaaS, or customer identification.

## Existing Products, Building Blocks, and Shortcuts

- Google Business Profile’s [review API guide](https://developers.google.com/my-business/content/review-data) supports listing reviews and managing replies.
- [`reviews.updateReply`](https://developers.google.com/my-business/reference/rest/v4/accounts.locations.reviews/updateReply) replaces browser automation for approved, verified locations.
- Google’s [reply guidance](https://support.google.com/business/answer/3474050) recommends short, professional, non-promotional, privacy-safe responses.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) separates public reply, private note, escalation, and confidence.

## Free-First Stack

React/TypeScript + Ollama + Zod; SQLite/JSON for business facts, tone, and approved remedies. API access is phase two because it needs OAuth, verified locations, and project approval.

## Architecture/Data Model

`BusinessProfile` stores tone and allowed facts. `ReviewInput` contains rating/text only. `ReplyDraft` contains public reply, private action, escalation, evidence used, and warnings. `Approval` preserves the final edited version.

## Build Slices

1. Business fact/tone profile.
2. Risk rules and structured drafts.
3. Evidence/warning panel and approval history.
4. Optional read-only then reply API integration.

## Drawbacks/Concerns/Failure Modes

- Public replies may reveal personal details; forbid names/order specifics unless already public and necessary.
- Model may invent remedies; choose only from approved offers.
- Serious allegations need human/legal handling.
- Official API access is not instant and should not block V0.

## Clever Hacks and Simpler Alternative

Build ten deterministic reply skeletons for common categories; let the model only shorten and match tone. A “public reply + internal action” split prevents the reply box becoming a support workflow.

## Success Measures

- No unapproved offer or personal detail appears.
- Routine reply is reviewable in under one minute.
- All serious categories trigger escalation.
- Human approval precedes every posted reply.

## Product Path

Paste-and-copy desk → official single-location integration → multi-location reputation product. Expansion requires API approval, access controls, audit logs, and jurisdiction-specific risk handling.

## Related Wikilinks

- [[cold-email-rewrite-desk|Cold Email Rewrite Desk]]
- [[customer-support-agency|Customer Support Agency]]

