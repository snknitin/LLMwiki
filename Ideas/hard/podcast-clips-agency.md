---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: creator media operations
form_factor:
  - local media pipeline
  - clip review board
deployment: workstation with optional DGX transcription
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#14. Podcast Clips Agency]]"
status: concept
tags:
  - podcast
  - video
  - transcription
---

# Podcast Clips Agency

> A local production line that finds, renders, and packages strong podcast moments while keeping editorial judgment, rights, and publishing with the creator.

## Product Outcome

Convert one user-owned episode into a searchable transcript, ranked moment candidates, platform-safe vertical clips, captions, thumbnails, and a publication manifest. The system saves editing time but does not sacrifice context or auto-post weak/controversial extracts.

## User and Core Workflow

The creator imports audio/video and show metadata, confirms ownership, and chooses themes/forbidden sections. The pipeline transcribes with word timecodes, detects speaker turns and topic boundaries, scores candidate spans, and shows transcript context. The user approves moments and crop focus; deterministic rendering produces preview clips, captions, and copy drafts. Export is manual by default.

## Demo/Personal V0

Use one 20-minute self-recorded episode. Generate a timestamped transcript, ten candidates with scoring reasons, three 30–60 second 9:16 clips, burned and sidecar captions, and a local review page. Include one candidate rejected for missing context.

## Build Boundary

Only user-owned/licensed media; no YouTube ripping, voice cloning, automatic social posting, deceptive quote splicing, or removal of context needed to understand a claim. Faces and transcripts stay local. Human approval covers cut boundaries, captions, thumbnail, and copy.

## Existing Products, Building Blocks, and Shortcuts

- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) runs speech recognition locally and avoids paying before the workflow is validated.
- [FFmpeg filters](https://ffmpeg.org/ffmpeg-filters.html) cover crop, scale, subtitles, loudness, and compositing; use reproducible commands instead of a custom renderer.
- [pyannote.audio](https://github.com/pyannote/pyannote-audio) is a speaker-diarization building block; manual speaker correction remains necessary.
- The official [YouTube `videos.insert`](https://developers.google.com/youtube/v3/docs/videos/insert) endpoint demonstrates OAuth, metadata, quota, audit, and privacy-state requirements; keep uploads disabled in V0.

## Recommended Free-First Stack

Use Python, whisper.cpp or faster-whisper, FFmpeg/ffprobe, SQLite, filesystem assets, and a SvelteKit review board. Run transcription on the workstation; use DGX Spark only for batch episodes or heavier multimodal scoring. A local model ranks transcript spans; media cutting remains deterministic.

## Architecture/Data Model

Model `Episode`, `MediaAsset`, `TranscriptSegment`, `Speaker`, `Topic`, `MomentCandidate`, `EditorialDecision`, `ClipRecipe`, `Render`, `CaptionCue`, `Thumbnail`, and `PublicationDraft`. Every clip records source in/out timecodes and FFmpeg command/version.

## Build Slices

1. Media preflight and ffprobe metadata.
2. Local transcript with word timecodes.
3. Candidate segmentation/scoring with context.
4. Review board and crop/caption correction.
5. Deterministic FFmpeg renders and QC.
6. Export manifest and optional private upload sandbox.

## Drawbacks, Concerns, and Failure Modes

ASR errors corrupt captions and names; diarization fails on overlap; vertical auto-crop cuts speakers; moment scoring favors sensational fragments; rendering is CPU/GPU intensive; fonts/music/assets create licensing issues. Platform aspect/rule changes require profiles.

## Clever Hacks and Simpler Alternative

Start with audiograms over a branded static layout, avoiding face tracking. Ask the host to place live markers during recording, then let AI rank only marked neighborhoods. Render low-resolution proxies for review and full quality only after approval.

## Success Measures

- Transcript word error is acceptable on a reviewed sample and names are corrected.
- All published candidates retain enough surrounding context.
- Three clips render reproducibly from recipes.
- Human accepts at least one of the top five candidates.
- No export occurs without a rights/approval manifest.

## Product Path

Personal creator tool first; later an agency workspace with brand templates, team review, licensed stock assets, and supported platform connectors. Publishing credentials, music rights, and analytics require separate operational controls.

## Related

- [[Creator Content Engine]]
- [[SEO Agency Crew]]
- [[LongVid Learning Studio]]
