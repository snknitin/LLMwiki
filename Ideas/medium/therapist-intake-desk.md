---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: behavioral health administration
form_factor:
  - clinician-configured intake portal
  - local review dashboard
deployment: encrypted local or clinician-controlled server
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#26. Therapist Intake Desk]]"
status: concept
tags:
  - healthcare
  - intake
  - privacy
---

# Therapist Intake Desk

> A clinician-configured, consent-first pre-session intake that collects structured history, lets clients skip or stop, and produces a source-linked draft summary for professional review.

## Product Outcome

Reduce administrative intake time without turning a chatbot into a therapist, diagnostician, or emergency service. The clinician owns the questions and risk protocol; the system collects responses, highlights configured flags, and shows exactly which answer supports each summary statement.

## User and Core Workflow

1. Clinician selects or authors a versioned intake protocol, jurisdiction notice, retention period, and urgent-help instructions.
2. Client opens a private link, verifies identity at an appropriate level, reads consent, and chooses text or conventional form mode.
3. The state machine asks required and optional questions with skip, pause, and stop controls.
4. Deterministic rules surface clinician-configured risk answers and immediately display the clinic’s emergency/escalation instructions.
5. The system drafts a neutral summary with answer citations and unresolved items.
6. Clinician reviews before the first session, corrects the summary, and follows their own care protocol.
7. Client may request a copy or deletion where applicable.

## Demo/Personal V0

Use only synthetic clients and a clinician-authored low-risk intake. Build a text conversation plus regular form fallback, consent receipt, rule-trigger fixture, and clinician summary review. The demo never offers advice and uses a prominent “not monitored / not emergency care” message.

## Build Boundary

- In scope: configured questionnaires, informed consent, structured collection, deterministic flags, cited summaries, clinician review, access logs, and deletion.
- Out of scope: diagnosis, treatment advice, clinical scores without licensed instruments, autonomous triage, emergency dispatch, voice emotion inference, or replacing clinician assessment.
- Do not run a public pilot without a qualified clinician, legal/privacy review, and tested crisis workflow.
- Minimize identifiers and never reuse intake data for model training by default.

## Existing Products, Building Blocks, and Shortcuts

- [HL7 FHIR Questionnaire](https://hl7.org/fhir/questionnaire.html) provides a standards-based representation for questions, groups, answer types, and conditions.
- [Formbricks](https://github.com/formbricks/formbricks) supplies open-source survey patterns and may be safer to adapt than inventing form infrastructure.
- [LimeSurvey](https://github.com/LimeSurvey/LimeSurvey) is a mature alternative if the first product is conventional intake plus summarization.
- [HHS telehealth privacy and security guidance](https://www.hhs.gov/hipaa/for-professionals/privacy/guidance/telehealth-privacy-security/index.html) offers practical design considerations for health communication, even when another jurisdiction governs.
- [OWASP Application Security Verification Standard](https://owasp.org/www-project-application-security-verification-standard/) is a useful security checklist for any later web deployment.

## Recommended Free-First Stack

- FastAPI, Pydantic, server-rendered HTML/HTMX, and PostgreSQL locally via Docker; SQLite/SQLCipher is acceptable for one clinician.
- A versioned JSON/FHIR-inspired questionnaire engine with deterministic branching and validation.
- Local LLM only for neutral summary drafting; rules and exact answers control safety flags.
- libsodium-backed field encryption, short-lived signed links, role-based clinician access, and append-only access logs.
- Playwright tests for consent, skip, stop, expiry, risk-message, review, export, and deletion.

For V0, a normal form with conversational styling is more dependable and accessible than a free-form agent.

## Architecture/Data Model

`clinic` owns `clinician`, `questionnaire_version`, `question`, `branch_rule`, `client_invitation`, `consent_event`, `response_session`, `answer`, `flag`, `summary_claim`, `review`, `access_event`, and `deletion_event`. Identity data is separated from clinical responses. Summary claims reference answer IDs and retain clinician edits.

## Build Slices

1. Synthetic data, questionnaire authoring, versioning, and accessible form renderer.
2. Consent/notice receipt, signed invitation, branching, skip/pause/stop.
3. Configured safety flags and tested emergency-information behavior.
4. Cited summary drafting, clinician review, export, and audit log.
5. Security/privacy review before any real-client pilot; then scheduling/EHR adapters if justified.

## Drawbacks, Concerns, and Failure Modes

- A distressed client may assume the system is monitored or clinically responsive.
- Conversational prompts can elicit more sensitive data than necessary.
- Model summaries can omit negation, time context, uncertainty, or protective factors.
- Client privacy can be harmed by weak links, device sharing, logs, or backups.
- Clinical instruments, retention, consent, and disclosure rules vary by jurisdiction.

## Clever Hacks and Simpler Alternative

- Make the clinician define every question and branch; use AI only after collection.
- Pair every summary sentence with a click-to-source answer.
- Include “prefer to discuss in session” as a first-class answer.
- Test critical branches with synthetic fixtures on every change.
- Simplest alternative: a secure conventional form that exports a structured intake PDF, with no chatbot or model.

## Success Measures

- Every summary claim resolves to one or more exact responses.
- All configured safety fixtures show the correct immediate guidance and clinician flag.
- Clients can skip, stop, obtain the notice, and request deletion.
- No real data leaves the clinician-controlled environment without explicit configuration.
- Clinicians report reduced preparation time without more correction or missed-risk work.

## Product Path

Keep the first build synthetic and clinician-supervised. A future product may add practice-management integration, multilingual forms, validated instruments under appropriate licenses, and team governance. Real clinical deployment requires jurisdiction-specific privacy, security, accessibility, medical-device, and professional review.

## Related

- [[Clinic Missed-Call Follow-Up Bot]]
- [[User Research Agency]]
- [[Paper Logbook]]
