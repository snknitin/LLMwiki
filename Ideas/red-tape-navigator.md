---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: civic navigation
form_factor:
  - local checklist dashboard
  - research pipeline
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#25. Red Tape Navigator]]"
status: concept
---
# Red Tape Navigator

> Compile a user-specific, timestamped checklist for Indian government procedures from official sources, with every fee and step linked back to the portal.

## Product Outcome

Replace scattered tabs and stale blog posts with a reliable preparation pack: eligibility questions, required documents, fees, appointment/portal links, sequence, timelines, traps, and a final verification checklist.

## User and Core Workflow

The user chooses a procedure and jurisdiction, answers only the questions needed for routing, and receives a draft checklist. The system retrieves approved official pages, stores snapshots, extracts structured steps with evidence, and flags changes. The user confirms current details on the linked portal before acting.

## Demo/Personal V0

Support one passport scenario and one driving-licence scenario. Use manually curated official URLs, local page snapshots, an as-of date, document checklist, and change-diff screen. Do not automate forms or store identity-document images.

## Build Boundary

Include official-source registry, versioned snapshots, rule-based intake, evidence-linked checklist, fee/timeline labels, reminders, and change detection. Exclude form submission, appointment booking, credential storage, legal advice, unofficial agents, and universal coverage.

## Existing Products, Building Blocks, and Shortcuts

- [Passport Seva application guidance](https://www.passportindia.gov.in/psp/Apply) supplies official steps and portal links.
- [Passport Seva fee calculator](https://www.passportindia.gov.in/psp/FeeCalculator) is the authoritative live fee check.
- [Parivahan](https://parivahan.gov.in/) is the official transport-services entry point.
- [Protean PAN services](https://www.protean-tinpan.com/services/pan/pan-index.html) covers official PAN workflows; [data.gov.in](https://data.gov.in/about) offers government datasets.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, Playwright for permitted snapshots, Pydantic rule schemas, OCR only for public source documents, and a local HTMX UI. Python supports extraction and diffing; manual source registry avoids uncontrolled crawling; SQLite preserves provenance.

## Architecture/Data Model

Store `procedures`, `jurisdictions`, `official_sources`, `snapshots`, `requirements`, `rules`, `intake_answers`, `checklist_versions`, `evidence_links`, `change_alerts`, and `user_confirmations`. Every rendered item includes source, retrieval date, and verification status.

## Build Slices

1. Curated source registry, snapshot command, manual checklist.
2. Passport intake rules and evidence-linked output.
3. Change diff, fee verification, reminders.
4. One Parivahan flow and procedure-authoring template.

## Drawbacks/Concerns/Failure Modes

Portals change without notice; rules differ by applicant/jurisdiction; accessibility can be poor; and outdated fees cause real harm. Keep scope narrow, show as-of dates, never hide source links, make uncertain branches explicit, and require portal verification before submission.

## Clever Hacks and Simpler Alternative

Build a version-controlled Markdown checklist pack with a weekly URL-change monitor. That alone can outperform a chatbot because users can see exactly what changed and why.

## Success Measures

Track checklist completion, stale-source detection, unsupported-item count, user corrections, visits to official verification links, time saved, and procedure attempts completed without missing documents.

## Product Path

Personal procedure notebook → open-source verified checklist library → localized civic-navigation product. Before public guidance, profile accounts, live portals, or payments, run [[Scope Expansion Checklist]] for accuracy duties, identity data, accessibility, source terms, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#25. Red Tape Navigator]]
- [[Scope Expansion Checklist]]

