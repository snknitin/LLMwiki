---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: healthcare operations
form_factor:
  - receptionist dashboard
  - messaging workflow
deployment: local-first with sandboxed provider webhooks
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#5. Clinic Missed-Call Follow-Up Bot]]"
status: concept
tags:
  - clinic
  - whatsapp
  - lead-follow-up
---

# Clinic Missed-Call Follow-Up Bot

> A receptionist-controlled queue that turns true missed calls into timely, privacy-minimal callback drafts without exposing medical context or pretending to be a clinician.

## Product Outcome

Recover legitimate enquiries that clinics lose when staff cannot answer, while reducing duplicate callbacks and inappropriate messages. Every lead gets a reasoned status, consent/channel record, neutral template, owner, next attempt, and complete audit trail.

## User and Core Workflow

A telephony webhook records a terminal `no-answer`, `busy`, or `failed` event. The system deduplicates by clinic/number/time window, checks suppression and business hours, and creates a review card. A receptionist approves a neutral WhatsApp/SMS draft, handles the reply, and books or closes the enquiry. Escalation to clinical staff occurs only through clinic-authored rules.

## Demo/Personal V0

Replay synthetic Twilio callbacks into a local dashboard. Show five cases: no-answer, duplicate retry, existing appointment, opted-out number, and after-hours call. The app drafts but does not send; a simulated reply moves the case into booking or human callback.

## Build Boundary

No diagnosis, symptom triage, emergency assessment, prescription discussion, call recording, or automated appointment promise. Messages reveal only the clinic name and callback intent. Real deployment requires clinic approval, consent/suppression policy, retention schedule, and supported messaging templates.

## Existing Products, Building Blocks, and Shortcuts

- [Twilio Voice Call resource](https://www.twilio.com/docs/voice/api/call-resource) exposes callback states including `busy`, `failed`, and `no-answer`; use its signed webhook rather than inferring a miss from duration.
- [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api/) is the supported channel; pre-approved templates and the customer-service window replace brittle personal-account automation.
- [Cal.com](https://github.com/calcom/cal.com) can supply scheduling/availability later instead of building a calendar engine.
- [HL7 FHIR Appointment](https://hl7.org/fhir/appointment.html) is a future interoperability model; keep the hackathon schema smaller.

## Recommended Free-First Stack

Use FastAPI, SQLite, a SvelteKit receptionist UI, and a local webhook simulator. Add Twilio test credentials or request fixtures only after state transitions pass. Keep templates in versioned YAML and use a tiny local model solely to classify a free-text reply into approved intents; uncertain replies route to staff.

## Architecture/Data Model

Model `Clinic`, `Caller`, `Consent`, `CallEvent`, `Lead`, `TemplateVersion`, `MessageDraft`, `Approval`, `Reply`, `AppointmentIntent`, and `AuditEvent`. Use provider event IDs for idempotency. The state machine is `new → suppressed/review → approved → sent → replied/booked/closed`, with every transition actor-stamped.

## Build Slices

1. Signed/simulated call-event ingestion and deduplication.
2. Suppression, quiet-hours, and consent rules.
3. Receptionist review queue and neutral templates.
4. Reply-intent routing and booking handoff.
5. Audit/export and deletion controls.
6. Optional provider sandbox integration.

## Drawbacks, Concerns, and Failure Modes

Carrier retries can duplicate events; shared family numbers create mistaken identity; messages can reveal clinic association on a lock screen; WhatsApp approval and pricing add operational friction. An LLM may turn a neutral reply into unsafe clinical advice. Staff may rely on the queue and miss emergencies.

## Clever Hacks and Simpler Alternative

Start with a daily missed-call CSV/import and “copy approved message” button. A single bilingual neutral template plus receptionist callback timer may recover most value. Hide caller details until the operator opens the case and auto-delete unconverted leads after a short clinic-set period.

## Success Measures

- Duplicate webhook events create one lead.
- Suppressed and after-hours cases never generate send-ready messages.
- Receptionist can review a case in under 20 seconds.
- Every sent message maps to an approved template and actor.
- No clinical content appears in automated drafts.

## Product Path

Begin as a local receptionist aid. A clinic product would add provider agreements, template management, role-based access, retention/deletion controls, scheduling integration, monitoring, and formal healthcare/privacy review.

## Related

- [[Therapist Intake Desk]]
- [[WhatsApp Catalog Bot for Small Stores]]
- [[Scope Expansion Checklist]]
