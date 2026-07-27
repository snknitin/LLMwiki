---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: customer lifecycle agents
form_factor:
  - local campaign workbench
  - approval-gated messaging console
deployment: local-first with optional CRM and messaging adapters
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#22. Winback Agency]]"
status: concept
tags:
  - retention
  - messaging
  - crm
---

# Winback Agency

> A consent-aware customer recovery crew that segments a business’s own lapsed-customer data, proposes truthful offers, drafts approved messages, and turns replies into orders or learnings.

## Product Outcome

Recover useful conversations from a small first-party customer list while respecting consent, channel rules, frequency limits, and suppression requests. The system should make segment logic, offer economics, message provenance, and outcomes reviewable.

## User and Core Workflow

1. Import customer/order history and normalize identity, last purchase, value, product, consent, and suppression state.
2. Define “lapsed,” channel eligibility, contact limits, margin constraints, and excluded cohorts.
3. Build explainable segments and estimate reachable audience.
4. Propose per-segment offers and copy grounded in actual products and policies.
5. Human approve segment, offer, message, and send window.
6. Send a small canary batch through an authorized provider.
7. Classify replies, route exceptions to a person, capture orders/objections, and compare holdout outcomes.

## Demo/Personal V0

Use a synthetic CSV of 200 customers. Generate an RFM-style segment table, three offer drafts, a message preview, and a simulated reply inbox. Export approved rows but do not contact anyone.

## Build Boundary

- In scope: first-party data, explainable segmentation, consent/suppression checks, truthful offer drafting, approval queues, simulations, and outcome analysis.
- Out of scope: bought lists, identity enrichment, dark patterns, false scarcity, unapproved discounts, autonomous refunds, or unrestricted bulk sending.
- The suppression check must be deterministic and run immediately before export/send.
- Reply handlers may suggest actions but must escalate disputes, distress, legal threats, and policy exceptions.

## Existing Products, Building Blocks, and Shortcuts

- [Shopify Admin GraphQL API](https://shopify.dev/docs/api/admin-graphql) can provide authorized customer and order data for a future commerce adapter.
- [HubSpot CRM imports](https://developers.hubspot.com/docs/api/crm/imports) offers a low-risk CSV handoff before live CRM synchronization.
- [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api/) is the official WhatsApp business channel and defines template/webhook constraints.
- [Twilio Programmable Messaging](https://www.twilio.com/docs/messaging) can abstract SMS/WhatsApp delivery later; local simulation is enough for V0.
- [Google Sheets API](https://developers.google.com/sheets/api) is a practical review and operator handoff surface.

## Recommended Free-First Stack

- Python, FastAPI, Pydantic, Polars, and SQLite for imports, rules, and experiments.
- Streamlit for segment exploration, message review, and simulated inbox.
- Local LLM through Ollama for copy variants and reply labels, constrained by catalog and policy snippets.
- Jinja templates and deterministic validators for prices, dates, unsubscribe text, and allowed claims.
- Provider adapters behind a dry-run interface; no credentials required for the hackathon V0.

The valuable early work is data hygiene and campaign simulation, not the send button.

## Architecture/Data Model

`workspace` owns `customer`, `identity`, `consent`, `order`, `segment_definition`, `segment_membership`, `offer`, `message_template`, `campaign`, `delivery`, `reply`, `resolution`, `suppression`, and `outcome`. Store segment and policy versions with each approved message. Events are append-only so opt-outs and campaign decisions remain auditable.

## Build Slices

1. Synthetic/CSV importer, identity merge, RFM features, and lapsed rules.
2. Consent/suppression engine, segment explainer, and reachable-audience report.
3. Offer economics, grounded copy variants, and approval workflow.
4. Simulated sender/reply inbox, routing rules, and objection taxonomy.
5. Canary/holdout experiments and optional Shopify, HubSpot, or WhatsApp adapters.

## Drawbacks, Concerns, and Failure Modes

- Old consent or poor identity matching can make outreach inappropriate.
- Discounts may train customers to wait, erode margin, or anger loyal buyers.
- Model-written urgency can invent inventory, deadlines, or relationships.
- Reply classification may miss opt-outs, vulnerable customers, or complaints.
- Without a holdout group, normal repeat purchases can look like campaign lift.

## Clever Hacks and Simpler Alternative

- Start with the top 20 lapsed customers and a human phone/WhatsApp review queue.
- Use segments defined in plain rules before attempting clustering.
- Treat unsubscribe and negative intent as high-recall deterministic patterns.
- Test a service message or useful reminder against a discount, not only copy variants.
- Simplest alternative: generate a one-page lapsed-customer report and three approved CSV lists for manual outreach.

## Success Measures

- Zero suppressed or channel-ineligible customers enter an approved batch.
- All product, price, and expiry claims validate against source records.
- Reply routing catches every opt-out in a test fixture.
- Track incremental orders and contribution margin against a holdout, plus complaint rate.
- Operators can explain why each customer entered a segment.

## Product Path

Begin as a personal CSV campaign planner for a friendly small business. Later add commerce/CRM sync, approved templates, team roles, experiment analysis, and usage-based messaging. A public product must implement jurisdiction- and channel-specific compliance, provider terms, data retention, and audit controls.

## Related

- [[Sales Development Agency]]
- [[WhatsApp Catalog Bot for Small Stores]]
- [[Finance Ops Agency]]
