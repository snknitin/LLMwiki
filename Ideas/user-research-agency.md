---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: research operations agents
form_factor:
  - local research workbench
  - consented interview portal
deployment: local-first with optional web interview room
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#21. User Research Agency]]"
status: concept
tags:
  - user-research
  - interviews
  - qualitative-analysis
---

# User Research Agency

> A consent-first research desk that converts a question into a protocol, screens invited participants, conducts structured interviews, and produces traceable themes with quote-level evidence.

## Product Outcome

Help one researcher run a small, rigorous qualitative study without losing the chain from question to participant consent, transcript, coded excerpt, theme, and finding. The system accelerates operations and synthesis; it does not manufacture respondents, sentiment, or certainty.

## User and Core Workflow

1. Define decision, research questions, excluded populations, incentives, and retention.
2. Generate a protocol, neutral screener, interview guide, and consent text.
3. Invite participants from a user-owned list and capture explicit consent.
4. Run a text interview or a human-led call with recording/transcription permission.
5. Redact identifiers, segment transcripts, and propose codes with citations.
6. Researcher reviews codes, contradictions, saturation, and representative quotes.
7. Export a findings report, evidence appendix, and deletion log.

## Demo/Personal V0

Use three synthetic or volunteer text interviews about one low-risk product question. The participant sees consent and may skip/stop. The workbench creates a codebook, theme table, contrary evidence, and a report where every quotation opens its transcript location.

## Build Boundary

- In scope: study planning, invitations to authorized contacts, consent, structured text interviews, transcription of consented recordings, coding assistance, and reporting.
- Out of scope: scraping participants, pretending agents are real respondents, covert recording, clinical diagnosis, employment screening, or autonomous incentive payouts.
- Separate identity/contact records from response content and honor withdrawal/deletion.
- Require researcher approval for protocols, participant eligibility, quotes, and final findings.

## Existing Products, Building Blocks, and Shortcuts

- [Formbricks](https://github.com/formbricks/formbricks) provides open-source survey and feedback patterns that can shortcut consent/screener collection.
- [LimeSurvey](https://github.com/LimeSurvey/LimeSurvey) is a mature open-source survey system; exporting into the analysis desk may be simpler than building forms.
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) enables local transcription for consented audio.
- [ElevenLabs text-to-speech](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) can voice an interviewer later, though a transparent text interface is safer for V0.
- [HHS telehealth privacy guidance](https://www.hhs.gov/hipaa/for-professionals/privacy/guidance/telehealth-privacy-security/index.html) is useful privacy design reading if the idea ever enters health contexts.

## Recommended Free-First Stack

- FastAPI, Pydantic, SQLite/SQLCipher, and a minimal server-rendered participant page.
- Local whisper.cpp for optional audio; Presidio plus reviewable rules for PII suggestions.
- A local LLM for question probes and coding, constrained by protocol and transcript citations.
- DuckDB/Polars for code counts and participant matrices; Quarto or Markdown for the report.
- Playwright to verify consent, skip, stop, withdrawal, and deletion paths.

Local storage and a transparent text workflow keep the first study cheap and reduce exposure of sensitive recordings.

## Architecture/Data Model

`study` owns `protocol_version`, `participant_identity`, `consent_event`, `session`, `utterance`, `redaction`, `code`, `coded_excerpt`, `theme`, `finding`, `quote_approval`, and `deletion_event`. Identity and research schemas use separate encryption keys. Findings reference coded excerpts; excerpts reference immutable transcript offsets and consent scope.

## Build Slices

1. Protocol/screener builder, consent receipt, and synthetic participant fixtures.
2. Text interview state machine with skip, pause, stop, and researcher monitoring.
3. Transcript redaction, codebook suggestions, and evidence-linked coding UI.
4. Theme matrix, contradictions, quote approval, and exportable report.
5. Optional local transcription, invitations, incentives, and longitudinal follow-up.

## Drawbacks, Concerns, and Failure Modes

- Agent phrasing can lead participants or persist when a human would stop.
- Recruitment convenience can produce a narrow, misleading sample.
- Summaries can erase minority views and overstate saturation.
- Quotes can re-identify people even after names are removed.
- Sensitive topics demand professional ethics, crisis protocols, and stricter governance.

## Clever Hacks and Simpler Alternative

- Begin with asynchronous text interviews to avoid audio complexity.
- Lock core questions; allow only bounded probes tied to a participant’s last answer.
- Force every theme to show confirming and contradicting excerpts.
- Keep a “not enough evidence” state instead of requiring a conclusion.
- Simplest alternative: import existing consented transcripts and build only the traceable coding/report workbench.

## Success Measures

- Every finding links to at least two approved excerpts or is labeled single-participant evidence.
- Consent, withdrawal, and deletion flows pass end-to-end tests.
- Researchers agree with or deliberately edit most proposed codes.
- No unapproved quote appears in the final report.
- Report synthesis time falls without reducing contradictory evidence captured.

## Product Path

Use it for personal product discovery with volunteers, then open-source the local analysis workbench. A paid research-operations product could add team roles, participant scheduling, incentive integrations, governance, and enterprise retention controls. Specialized health, education, or employment editions require domain review before release.

## Related

- [[Therapist Intake Desk]]
- [[Feedback Mirror]]
- [[Recruiting Agency]]
