---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: social entertainment
form_factor:
  - local mediated web experience
  - shareable private verdict
deployment: local desktop with LAN access
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#19. Petty Court]]"
status: concept
---
# Petty Court

> A consent-based, explicitly non-legal format for two people to present a low-stakes disagreement and receive a playful, structured ruling.

## Product Outcome

Turn recurring petty conflicts into a fair-seeming conversation: separate claims, inspect evidence, ask the same clarifying questions, summarize common ground, and produce an entertaining private verdict with suggested repair.

## User and Core Workflow

One person opens a case and invites the other. Both accept the rules, choose private visibility, submit claims and evidence independently, and review redactions. A structured judge asks bounded follow-ups, generates a neutral fact matrix, then drafts findings, a playful ruling, and optional compromise. Both approve any shareable version.

## Demo/Personal V0

Run a fictional household dispute in one local browser with two private sessions. Support text evidence, three rounds, a fact matrix, a written verdict, and a generated audio reading. No public precedent feed.

## Build Boundary

Include mutual consent, party separation, evidence upload, symmetric questions, redaction, private verdict, and deletion. Exclude real legal advice, crimes, abuse, employment/housing disputes, minors, public accusations, and binding enforcement.

## Existing Products, Building Blocks, and Shortcuts

- [docassemble](https://docassemble.org/docs.html) provides patterns for structured interviews, branching questions, and document assembly.
- [MediaRecorder](https://www.w3.org/TR/mediastream-recording/) can capture voluntary spoken statements.
- [FFmpeg](https://www.ffmpeg.org/documentation.html) renders a private verdict clip from approved text/audio.
- [JSON Schema](https://json-schema.org/specification) can validate claim, evidence, and ruling structures.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite/Drizzle, local filesystem encryption, Ollama, and optional FFmpeg. A state machine and fixed issue schema create procedural fairness; the model summarizes and writes tone, not legal conclusions.

## Architecture/Data Model

Model `cases`, `parties`, `consents`, `claims`, `evidence_items`, `questions`, `answers`, `fact_findings`, `ruling_versions`, `share_approvals`, and `deletion_events`. Party-private records stay separate until the reveal stage.

## Build Slices

1. Fictional single-device case flow and ruling template.
2. Two-party consent, private sessions, and evidence redaction.
3. Symmetric cross-examination, fact matrix, compromise.
4. Optional private audio/video ruling and expiration.

## Drawbacks/Concerns/Failure Modes

Coercion, one-sided evidence, sensitive allegations, confident fabrication, and public humiliation are primary risks. Reject high-stakes categories, let either party exit, cite submitted evidence, label the result entertainment, default private, and auto-expire raw material.

## Clever Hacks and Simpler Alternative

Frame it as “petty mediation cards”: each person answers the same five questions, then the tool reveals overlap and suggests a coin-flipable compromise. This preserves fun without an authoritative AI judge.

## Success Measures

Track mutual-consent completion, high-stakes case rejection, evidence-linked findings, party fairness ratings, disputes resolved or de-escalated, share opt-in rate, and deletion success.

## Product Path

Private party tool → downloadable game format → moderated entertainment product. Before public cases, accounts, shared precedent, or payments, run [[Scope Expansion Checklist]] for safety, privacy, moderation, legal framing, and release duties; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#19. Petty Court]]
- [[Scope Expansion Checklist]]

