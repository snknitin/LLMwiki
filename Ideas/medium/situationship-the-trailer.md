---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: private creative media
form_factor:
  - local video generator
  - review timeline
deployment: local desktop with optional DGX Spark inference
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#30. Situationship: The Trailer]]"
status: concept
---
# Situationship: The Trailer

> Turn a user-supplied conversation into a private, redacted 40-second genre trailer whose quotes and narrative beats the uploader explicitly approves.

## Product Outcome

Create a funny or cathartic media artifact without exposing the other person or pretending the model knows their motives. The owner controls the genre, selected excerpts, redaction, title card, and final export.

## User and Core Workflow

Import a chat export or paste excerpts, review detected participants and dates, redact names/contact details, and select quotes. The system suggests narrative beats and a 40-second script, then builds a storyboard with text, abstract visuals, optional narration, and music supplied by the user. The owner previews and exports locally.

## Demo/Personal V0

Use a fictional chat transcript. Support three genres, manual quote selection, name redaction, six storyboard cards, local TTS or text-only captions, and a 1080p MP4. Do not contact or identify the other person.

## Build Boundary

Include local import, redaction, quote approval, beat/script editor, deterministic storyboard, render, and deletion. Exclude scraping chat apps, voice cloning, face generation, public sharing by default, psychological diagnosis, harassment, and sexual-content inference.

## Existing Products, Building Blocks, and Shortcuts

- [Whisper](https://github.com/openai/whisper) transcribes optional user-supplied voice notes locally.
- [Remotion](https://github.com/remotion-dev/remotion) provides React-based programmatic video compositions.
- [FFmpeg](https://www.ffmpeg.org/documentation.html) assembles, transcodes, and probes media.
- [MediaRecorder](https://www.w3.org/TR/mediastream-recording/) can capture an owner-recorded narration in the browser.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite, Remotion, FFmpeg, and Ollama/DGX inference for structured beat suggestions. Keep quotes and storyboard state as ordinary data; rendering becomes deterministic and reproducible.

## Architecture/Data Model

Store `projects`, `imports`, `participants`, `messages`, `redactions`, `approved_quotes`, `beat_versions`, `storyboard_cards`, `assets`, `render_jobs`, and `exports`. Raw imports remain local and deletable; final text can reference only approved quote IDs.

## Build Slices

1. Fictional transcript, quote picker, redaction, storyboard.
2. Three templates, caption timing, local render.
3. Optional voice-note transcription and owner narration.
4. Export presets, deletion, and provenance manifest.

## Drawbacks/Concerns/Failure Modes

Chat exports contain a non-user’s private data; generated framing can become cruel; quotes lose context; and media assets can leak identifiers. Default local/private, require manual selection, show surrounding context, ban real-person voice cloning, and strip metadata on export.

## Clever Hacks and Simpler Alternative

Create a vertical animated-text trailer with abstract gradients and sound effects. It delivers the joke while avoiding generative likenesses, stock-footage search, and expensive image/video models.

## Success Measures

Track time to first preview, redactions caught, quote-context corrections, render success, owner comfort rating, private export rate, and post-generation deletion success.

## Product Path

Personal creative toy → downloadable local app → opt-in social creative product. Before cloud processing, public sharing, template marketplaces, or payments, run [[Scope Expansion Checklist]] for privacy, third-party consent, media rights, model terms, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#30. Situationship: The Trailer]]
- [[Scope Expansion Checklist]]
