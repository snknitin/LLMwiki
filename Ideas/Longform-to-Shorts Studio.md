---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Creator Growth and Local Video Pipelines#6. Longform-to-Shorts Studio]]"
status: concept
difficulty: hard
priority: p1
category: video editing automation
form_factor:
  - local desktop or web editor
  - media-processing pipeline
deployment: desktop workstation
source_ideas:
  - convert long-form video into multiple scrollable short-form clips
tags:
  - video
  - shorts
  - captions
  - editing
  - ffmpeg
---

# Longform-to-Shorts Studio

> Analyze a long local video, propose standalone high-value segments, and turn approved ranges into editable vertical clips with accurate captions, intentional boundaries, stable reframing, and complete source provenance.

## Product Outcome

The studio reduces search and rough-cut work. It probes the file, transcribes/alines speakers, detects scenes and silence, constructs semantic windows, ranks candidates using an explicit rubric, and provides a transcript-first editor for approving ranges. It then renders proxies/finals without modifying the source.

It is separate from [[Local Video Generation Evaluation Lab]]: clipping is deterministic editing of source footage. Generative B-roll or inserts are optional assets, never the core.

## Personal V0

1. Accept local MP4/MKV/MOV and create an immutable source manifest/hash.
2. Generate word-aligned transcript, speaker labels, scenes, silence intervals, and ten candidate ranges.
3. Show transcript + source preview + rationale with editable in/out points.
4. Rank by standalone comprehension, opening hook, payoff, specificity, visual continuity, clean boundaries, novelty, audience, and CTA fit.
5. Approve three clips, apply one 9:16 crop mode and two caption styles.
6. Export proxy/final, SRT/VTT, manifest, thumbnail/contact sheet, and optional NLE timeline.
7. Compare candidates against segments selected manually by the user.

## Build Boundary

**MVP:** local files, transcript/scene pipeline, candidate ranking, review UI, captions, fixed/safe crop, and FFmpeg export.

**Later:** speaker/face tracking, manual crop keyframes, multimodal highlight scoring, B-roll suggestions, multiple templates, NLE export, batch channels, and LongVid URL handoff.

## Existing Products, Building Blocks, and Shortcuts

- [FFmpeg filters](https://ffmpeg.org/ffmpeg-filters.html) cover probing, silence/crop detection, subtitles, scaling, loudness, and encoding.
- [WhisperX](https://github.com/m-bain/whisperX) supplies word timestamps and speaker diarization.
- [PySceneDetect](https://github.com/Breakthrough/PySceneDetect) detects scene cuts.
- [Auto-Editor](https://github.com/WyattBlue/auto-editor) removes/rearranges low-loudness or motion sections and exports timelines for NLEs.
- OpusClip, Descript, Captions, Klap, Riverside, and Premiere’s text editing are product references. The local differentiator is inspectable scoring, source manifests, and reusable open media primitives.

## Recommended Free-First Stack

- Python/FastAPI workers with FFmpeg/ffprobe, WhisperX/faster-whisper, PySceneDetect, and Auto-Editor.
- SQLite job/project store plus YAML/JSON sidecars.
- SvelteKit/Tauri transcript-first editor.
- Local text model for semantic windows/rationales; deterministic overlap/duration/boundary checks.
- ASS/SRT/VTT caption generator and FFmpeg final render.
- Optional MediaPipe/vision tracker after stable crop is measured.

## Architecture and Data Model

`SourceMedia` records file hash/streams. `TranscriptWord` and `SpeakerSegment` retain model/confidence. `SceneBoundary` and `SilenceInterval` provide cut candidates. `ClipCandidate` stores in/out, rationale components, flags, and overlap group. `CropTrack` stores keyframes. `CaptionRevision` preserves edits. `RenderJob` stores exact command/config/output hash.

## Build Slices

1. Probe/transcribe and sidecar manifests.
2. Scene/silence boundary fusion.
3. Semantic windows and candidate linting.
4. Transcript review and in/out editing.
5. 9:16 proxy, captions, and final render.
6. Crop tracking/keyframes and NLE export.
7. [[Auto-GTM Engine]] handoff.

## Drawbacks, Concerns, and Failure Modes

- Transcript-only scoring misses physical comedy/demonstrations. Add visual features after a transcript baseline.
- Face tracking can jump or follow the wrong subject. Smooth motion and allow manual keyframes.
- Alignment fails with crosstalk/music/names. Make transcript correction easy before captions.
- “Virality score” is opaque and misleading. Keep rubric components editable.
- Candidates may repeat the same idea. Penalize semantic overlap across the selected pack.
- Media processing can fill disk rapidly. Cache intermediates by source/config hash and expose cleanup.

## Clever Hacks and Simpler Alternative

- First output only timestamp recommendations to open in the user’s existing editor.
- Build transcript-first; video canvas complexity can wait.
- Use center crop for screen recordings and manual keyframes for talking heads before face AI.
- Select clips with hook/context/payoff or claim/evidence/conclusion structure.
- Render low-resolution proxies until final approval.

## Success Measures

- A high fraction of proposed clips are accepted or need only boundary edits.
- Time from source file to three usable clips declines substantially.
- Captions need few word/timing corrections.
- Exports reproduce from sidecars and do not modify the source.
- Selected clips are non-duplicative and understandable without missing setup.

## Product Path

Local rough-cut assistant -> personal creator studio -> Auto-GTM media adapter -> paid local/hosted editor. Apply [[Scope Expansion Checklist]] before other-user media; retain non-destructive provenance and reproducible renders.

## Related

- [[YouTube Learning Center]]
- [[Creator Content Engine]]
- [[Auto-GTM Engine]]
- [[Meta Ad Creative Studio]]
- [[Local Video Generation Evaluation Lab]]
- [[Project Ideas Index]]
