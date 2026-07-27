---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: real-estate-content
form_factor:
  - local content workbench
  - desktop web app
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#14. Real Estate Listing Optimizer]]"
status: concept
tags: [real-estate, writing, photos]
---

# Real Estate Listing Optimizer

> Turn locked property facts into channel-specific copy without inventing amenities, approvals, distances, or urgency.

## Product Outcome

The broker enters verified facts once and receives a portal listing, WhatsApp version, buyer FAQ, photo checklist/order, and unsupported-claim warnings. Every adjective should be traceable to a selected fact or marked subjective.

## User and Core Workflow

1. Complete structured property/offer/location/amenity fields and upload photos.
2. Validate required facts, units, and claim evidence.
3. Strip/review EXIF metadata and order the photo checklist.
4. Generate outputs constrained to locked fields.
5. Review a claims panel and copy/export.

## Demo/Personal V0

Local form for one residential listing, deterministic base copy, optional Ollama tone pass, WhatsApp version, FAQ, and EXIF report.

## Build Boundary

**MVP:** structured facts, one listing type, three outputs, unsupported-adjective lint, photo metadata check.

**Out:** portal scraping/posting, price estimates, fabricated neighborhood facts, discriminatory targeting, lead routing, payments, or legal title verification.

## Existing Products, Building Blocks, and Shortcuts

- Schema.org [`House`](https://schema.org/House) and [`Offer`](https://schema.org/Offer) provide a reusable property/transaction fact model.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) constrains each channel draft to validated fields.
- [ExifTool](https://exiftool.org/) audits and removes photo metadata.
- India’s [Guidelines for Prevention of Misleading Advertisements](https://consumeraffairs.nic.in/sites/default/files/CCPA_Notification.pdf) supply concrete claims/disclaimer guardrails.

## Free-First Stack

Vite/React + TypeScript/Zod + local SQLite/files + Ollama + ExifTool. Copyable text/ZIP export avoids early portal/WhatsApp automation.

## Architecture/Data Model

`Property` stores physical facts; `Offer` stores price/transaction/availability; `LocationClaim` stores distance and evidence; `PhotoAsset` stores EXIF audit/order; `Draft` records facts used and warnings.

## Build Slices

1. Fact schema/validation.
2. Deterministic listing and WhatsApp templates.
3. Tone pass with evidence mapping.
4. FAQ/photo checklist/EXIF audit.

## Drawbacks/Concerns/Failure Modes

- Models invent desirable features; forbid any output field without fact IDs.
- Area/price units and approval status are easy to misstate.
- Photos may leak GPS coordinates.
- Housing copy can become discriminatory; block protected-class targeting.

## Clever Hacks and Simpler Alternative

Generate deterministically first and highlight unsupported adjectives. The LLM only rewrites approved sentences, making the audit simple.

## Success Measures

- Every factual claim maps to a locked field/evidence.
- No GPS EXIF survives export unless explicitly retained.
- Broker prepares three channel outputs in under ten minutes.
- Unit tests cover area/price formatting.

## Product Path

Personal broker workbench → reusable team templates → portal integrations → paid listing operations product. Expansion needs advertising/housing compliance, portal terms, and media/model license review.

## Related Wikilinks

- [[Cold Email Rewrite Desk]]
- [[Google Review Reply Desk]]

