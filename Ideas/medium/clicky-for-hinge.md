---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: conversation-assistance
form_factor:
  - local web app
  - mobile-share-target
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#23. Clicky for Hinge]]"
status: concept
tags:
  - dating
  - ocr
  - writing-assistant
---

# Clicky for Hinge

> A private drafting assistant that offers three authentic replies and explains the trade-off—never an autonomous dating bot.

## Product Outcome

Paste text or a screenshot of a dating conversation and receive three distinct drafts: specific/curious, playful/forward, and graceful reset. Each answer references visible context, avoids pressure or deception, and remains editable before the user copies it.

## User and Core Workflow

1. User pastes the last few messages or imports a screenshot.
2. OCR extracts text; the user corrects names, speaker order, and any mistakes.
3. User chooses intent and voice: continue, ask out, clarify, or close politely.
4. The model proposes three ranked replies with a one-line rationale and risk flag.
5. User edits/copies one; raw screenshot is deleted immediately by default.

## Demo/Personal V0

Build a localhost page with paste, optional image upload, manual transcript correction, four intents, and local Ollama generation. Store nothing unless the user explicitly saves a de-identified example.

## Build Boundary

**MVP:** user-provided text/screenshots, local OCR, local model, three fixed strategies, safety filters, copy button, delete-by-default.

**Out:** accessing Hinge accounts, browser/mobile automation, auto-sending, background monitoring, scraping profiles, attractiveness scoring, manipulative “guaranteed response” tactics, or persistent dossiers about other people.

## Existing Products, Building Blocks, and Shortcuts

- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) replaces a hosted OCR service for desktop screenshots and supports many languages.
- [ML Kit Text Recognition v2](https://developers.google.com/ml-kit/vision/text-recognition/v2) is a stronger on-device path for a future Android app, returning text structure and bounding boxes.
- The PWA [`share_target` manifest feature](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Manifest/Reference/share_target) can receive shared images on supported platforms, though browser support is limited.
- [Ollama’s local chat API](https://docs.ollama.com/api/chat) provides structured private inference without uploading intimate conversations.

## Free-First Stack

- **App:** FastAPI + lightweight React or HTMX; start with text paste.
- **OCR:** Tesseract + OpenCV preprocessing; ML Kit only for a native Android iteration.
- **Model:** Ollama with JSON schema for three drafts, rationale, and flags.
- **Storage:** in-memory session; optional encrypted local SQLite for user-approved examples.
- **Packaging:** PWA first; Tauri later if global hotkeys/share integration matter.

## Architecture/Data Model

`DraftSession` holds transient input and expiry. `TranscriptTurn` has speaker, text, OCR confidence, and user-corrected flag. `IntentProfile` contains desired action, tone, and no-go topics. `ReplyCandidate` stores strategy, text, context references, and safety flags. Persist only de-identified `Feedback` if opted in.

## Build Slices

1. Text-only prompt, three strategies, and copy flow.
2. Screenshot OCR plus transcript correction.
3. Privacy controls and automatic expiry.
4. Style calibration from user-written examples.
5. Installable PWA/share-target experiment.

## Drawbacks/Concerns/Failure Modes

- OCR can swap speakers, producing an embarrassing reply. Require transcript confirmation.
- Suggestions may make the user sound unlike themselves. Offer “closer to my draft” rewriting and editable style controls.
- Intimate data is unusually sensitive; avoid logs, cloud analytics, and default persistence.
- Optimization for replies can encourage manipulation. Never claim certainty and block coercive, harassing, deceptive, or sexual-pressure tactics.
- The product can create dependence; frame it as drafting practice and show why each version works.

## Clever Hacks and Simpler Alternative

- Skip OCR initially: the user pastes only the last message plus one profile detail.
- Ask the user to write a rough reply first; improve it instead of impersonating them.
- Use deterministic strategies and a local rewrite model rather than a “dating expert” agent.
- Add a “send nothing / move on” candidate when the context indicates disinterest or discomfort.

## Success Measures

- User can get and copy a useful draft in under 30 seconds.
- Speaker-order confirmation prevents all known OCR mix-ups in testing.
- Raw screenshots are absent after session expiry.
- At least two of three drafts are rated “sounds like me.”
- Safety tests reject coercive and harassing prompts.

## Product Path

Personal local rewriter → privacy-first mobile share tool → general conversation coach. A public release must independently review app-platform rules, sensitive-data handling, age gating, and model licenses.

## Related Wikilinks

- [[Conversation Coach]]
- [[Cold Email Rewrite Desk]]
- [[Compatibility Duet]]

