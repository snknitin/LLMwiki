---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: partnership sales
form_factor:
  - local sales dashboard
  - proposal workflow
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#31. Sponsorship Sales Agency]]"
status: concept
---
# Sponsorship Sales Agency

> Turn event inventory and an ideal sponsor profile into a small researched pipeline, credible packages, tailored pitches, and disciplined follow-up drafts.

## Product Outcome

Help a community or event operator sell sponsorship without overpromising inventory. Every target has a fit rationale and source evidence; every proposal maps price to actual deliverables and capacity.

## User and Core Workflow

The operator enters audience, outcomes, inventory, delivery capacity, price floors, conflicts, and ideal sponsor criteria. They import or curate target companies. The system researches official pages, creates fit cards, proposes packages, drafts personalized outreach and a proposal, then tracks review, follow-up, objections, and commitments.

## Demo/Personal V0

Use one fictional event, three packages, 20 company URLs, and a simulated pipeline. Produce ten evidence-backed targets, five reviewed pitch drafts, a deliverable matrix, and one proposal PDF. No bulk send or CRM connection.

## Build Boundary

Include inventory/capacity model, ICP, first-party research, fit ranking, package builder, drafts, pipeline, and delivery handoff. Exclude contact scraping, mass outreach, contract signature, invoicing, payment, and guarantees of audience performance.

## Existing Products, Building Blocks, and Shortcuts

- [HubSpot CRM object model](https://developers.hubspot.com/docs/api-reference/latest/crm/understanding-the-crm) provides a reference for companies, contacts, deals, and activities.
- [PandaDoc document details](https://developers.pandadoc.com/reference/document-details) accelerates later proposal structure, pricing tables, recipients, and status.
- [Gmail drafts](https://developers.google.com/workspace/gmail/api/guides/sending) provides a review-first outreach adapter.
- [Schema.org Organization](https://schema.org/Organization) helps extract official company metadata.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, httpx/Beautiful Soup, optional Playwright, Pydantic, Jinja/HTML-to-PDF, and Ollama. Python unifies research and document generation; SQLite models pipeline and finite inventory; typed templates prevent accidental package drift.

## Architecture/Data Model

Model `properties`, `audience_facts`, `inventory_items`, `packages`, `companies`, `source_pages`, `claims`, `fit_scores`, `contacts`, `pitch_versions`, `deal_stages`, `follow_ups`, `commitments`, and `handoff_tasks`. Package availability is calculated from committed inventory.

## Build Slices

1. Property brief, inventory, capacity, package calculator.
2. Company import, official-site research, evidence cards.
3. Fit ranking, pitch/proposal drafts, review.
4. Pipeline, follow-up cadence, commitment-to-handoff view.

## Drawbacks/Concerns/Failure Modes

Weak audience evidence, stale company priorities, overbooked deliverables, generic personalization, and aggressive follow-up damage trust. Version audience facts, show sources, reserve inventory on commitment, require human review, and cap cadence.

## Clever Hacks and Simpler Alternative

Start with a one-page sponsor inventory calculator and five manually researched targets. If package clarity improves replies, add research automation; if not, more leads will not solve the offer.

## Success Measures

Track qualified targets, accepted pitch drafts, positive replies, meetings booked, close rate, revenue per inventory unit, delivery-capacity conflicts, and sponsor renewals after fulfillment.

## Product Path

Personal event sales desk → productized sponsorship agency → partnership revenue platform. Before team accounts, live outreach, signatures, payments, or client use, run [[Scope Expansion Checklist]] for data sourcing, channel terms, deliverable rights, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#31. Sponsorship Sales Agency]]
- [[Scope Expansion Checklist]]
- [[Event Ops Agency]]
