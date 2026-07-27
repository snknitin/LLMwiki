---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#3. LongVid Learning Studio]]"
status: concept
difficulty: medium
priority: urgent
urgency: personal-beta-by-2026-08-27
category: learning
form_factor:
  - browser extension
  - mobile share target
  - local dashboard
deployment: workstation plus optional DGX Spark
source_ideas:
  - Gemini YouTube video and playlist summarizer using the longvid prompt
tags:
  - youtube
  - summarization
  - notebooklm
  - browser-extension
---

# LongVid Learning Studio

> A “send video, receive a study artifact” pipeline for individual YouTube videos and playlists, with length-aware outputs, traceable timestamps, cross-video synthesis, and optional audio-overview handoff.

## Product Outcome

Saved videos should become something easier to review than another playlist: a structured note, concept map, claims with timestamps, examples, disagreements, exercises, and a concise “core tenets” document. Playlist mode should synthesize across videos rather than concatenate summaries.

## Personal V0

- Browser-extension button and mobile share target accept a YouTube URL.
- Detect video, playlist, duration, channel, and available metadata.
- Obtain a permitted transcript or ask the user to provide media/transcript when unavailable.
- Choose an output recipe based on duration and intent: skim, lecture notes, tutorial, debate, or `/longvid`.
- Chunk by semantic sections and retain timestamp spans.
- Generate a Markdown note with source metadata, outline, claims, examples, questions, and flashcards.
- In playlist mode, maintain per-video notes plus a synthesis of recurring concepts, contradictions, and prerequisites.
- Export a source pack for NotebookLM or generate a local two-voice audio overview.

## Build Boundary

**MVP:** public video URL, available transcript, one output style, local queue, Markdown export, and timestamps.

**Later:** playlists, mobile share sheet, audio, diagrams, channel subscriptions, and a paid long-context model fallback. Do not depend on unauthorized caption downloading. The official YouTube API can enumerate playlists and caption tracks, but transcript access permissions vary.

### Month-One Personal Beta

Reach the complete one-video path in the first week: URL plus permitted transcript/audio to a timestamped Markdown note using the existing `/longvid` recipe. Then dogfood it on at least twenty varied videos, record transcript/coverage/citation failures, add fixture-based regression tests, and only then add playlist synthesis and a capture extension. NotebookLM and podcast generation remain optional handoffs until the core note is trusted.

## Existing Products, Building Blocks, and Shortcuts

- Gemini’s API now accepts a [public YouTube URL directly as video input](https://ai.google.dev/gemini-api/docs/video-understanding), so Google can provide multimodal understanding without your app first acquiring a transcript. This is the closest paid/hosted shortcut, but its preview limits and pricing can change.
- [NotebookLM’s YouTube importer](https://support.google.com/notebooklm/answer/16215270) is different: Google states that it imports only the transcript of a public video with captions, not the video imagery. Use NotebookLM as an immediate no-code study/audio-overview path and build LongVid for timestamps, custom schemas, playlist coverage, and durable local notes.
- Perplexity officially documents [uploaded audio/video transcription](https://www.perplexity.ai/help-center/en/articles/10354807-file-uploads), with speech made searchable but visual scenes not indexed. Its public documentation does not promise arbitrary YouTube-URL transcript retrieval, so treat any URL behavior as a convenience rather than a dependable ingestion API.
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) is the pragmatic local fallback for user-supplied/processable media. Transcript-only example: `yt-dlp --write-auto-subs --skip-download --sub-format vtt URL`; audio fallback: `yt-dlp -x --audio-format m4a URL`, then transcribe with [Whisper](https://github.com/openai/whisper) or faster-whisper.
- The official [YouTube Data API](https://developers.google.com/youtube/v3/docs) is excellent for playlist ordering and metadata, but `captions.download` requires authorization to edit the video. Do not confuse metadata access with a universal public-transcript endpoint.

## Free-First Stack

- **Extension:** Manifest V3 TypeScript extension with a minimal popup.
- **Queue/API:** FastAPI plus SQLite; a filesystem job directory is enough initially.
- **Ingestion:** YouTube Data API for metadata/playlist enumeration plus `yt-dlp` for caption discovery, subtitle extraction, and user-authorized media/audio fallback.
- **Speech:** faster-whisper locally for media the user is authorized to process.
- **Models:** local model for section extraction; DGX-hosted vLLM for batched synthesis; optional Gemini or another paid long-context provider through an adapter.
- **Output:** Markdown, JSON sidecar, Mermaid/Excalidraw-compatible diagrams, and source bundle.

## Architecture

Store each claim with `video_id`, start/end timestamp, transcript span hash, and generation recipe. Hierarchical synthesis runs section → video → playlist, while a coverage checker compares final concepts against section notes to flag omissions.

## Build Slices

1. URL parser, metadata fetch, and one-video job queue.
2. Transcript ingestion and timestamped chunking.
3. `/longvid` structured note renderer.
4. Coverage and citation checks.
5. Browser button and mobile capture endpoint.
6. Playlist synthesis and NotebookLM/local audio handoff.

## Success Measures

- Every nontrivial claim links to a timestamp.
- A 60-minute video becomes a useful note within the chosen latency budget.
- Coverage tests retain the concepts a human marked essential.
- Playlist synthesis removes repetition while preserving disagreements.
- Notes are reviewed later, not merely generated.

## Product Path

Start as a personal extension and local service. It could become an open-source browser tool, a bring-your-own-model study product, or a paid service for courses and team video libraries. The durable feature is verifiable learning output, not generic “AI summary.”

## Related

- [[Personal Study Curriculum]]
- [[Personal Signal Intelligence OS]]
- [[Half-Blood PDF]]
- [[Creator Content Engine]]
- [[Project Ideas Index]]
