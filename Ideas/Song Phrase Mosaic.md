---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#9. Song Phrase Mosaic]]"
status: concept
difficulty: medium
priority: p3
category: audio creativity
form_factor:
  - desktop app
deployment: local-first
source_ideas:
  - type a phrase and hear song snippets that speak it phrase by phrase
tags:
  - audio
  - search
  - copyright
---

# Song Phrase Mosaic

> A local phrase-to-audio montage tool that indexes user-supplied songs and recordings, assembling the requested sentence from matching spoken/sung fragments with editable timing.

## Product Outcome

Type a sentence and receive a timeline of candidate clips whose recognized words or phrases cover it. The user swaps takes, trims boundaries, aligns loudness, and exports a playful montage with a rights manifest.

## Personal V0

- Index a folder of user-owned recordings or purpose-recorded phrase samples.
- Transcribe with word timestamps and retain confidence.
- Search for longest phrase matches, then fall back to shorter n-grams or words.
- Build a candidate timeline with alternate clips for each span.
- Normalize loudness, add short crossfades, and preserve original pitch by default.
- Export WAV/MP3 plus a clip-level provenance manifest.
- Highlight uncovered words and offer text-to-speech or a “record this phrase” fallback.

## Build Boundary

**MVP:** local user-supplied corpus, text input, word/phrase alignment, manual timeline, and export.

**Later:** larger libraries, semantic paraphrases, musical key/tempo matching, mobile app, and collaborative packs. Distribution and licensing are deferred until a release decision.

## Existing Products, Building Blocks, and Shortcuts

- PlayPhrase.me and Yarn are product references for searchable quote clips; your local project applies the same retrieval idea to a user-supplied audio corpus and editable montage.
- [WhisperX](https://github.com/m-bain/whisperX) or another aligner provides word timestamps, while [FFmpeg](https://ffmpeg.org/) and [SoX](https://sourceforge.net/projects/sox/) handle trim, resample, loudness, crossfade, tempo, and pitch.
- [Sonic Visualiser](https://www.sonicvisualiser.org/) is a useful inspection reference for waveform/timing annotations. SQLite FTS plus exact n-grams should precede embeddings.
- Clever shortcut: dynamic programming maximizes long phrase matches and penalizes source changes. Start with speech-like assembly; musically seamless sung output is a harder second project.

## Free-First Stack

- **Pipeline:** Python, faster-whisper/WhisperX-style alignment, SQLite FTS, and FFmpeg/SoX.
- **Search:** exact normalized n-grams first; phonetic and embedding search later.
- **UI:** Tauri with waveform/timeline, or Gradio for the first experiment.
- **Audio analysis:** librosa for tempo/key candidates and loudness metrics.
- **Fallback voice:** local TTS or user recordings with a distinct label.
- **Data:** `Clip`, `Source`, `License`, `Span`, `Alignment`, and `Render` manifest.

## Clever Hacks and Simpler Alternative

- Build the first benchmark corpus from a small local folder so indexing and assembly can be debugged quickly.
- Use dynamic programming to maximize phrase length while penalizing clip changes.
- Match room tone and loudness before chasing neural voice conversion.
- Keep a two-track edit: source clips above, rendered montage below, so every result is auditable.
- A spoken movie-quote style montage is easier than musically seamless singing.

## Build Slices

1. Rights ledger and local corpus import.
2. Word-timestamp index and exact phrase search.
3. Coverage planner and alternate takes.
4. Timeline editor, loudness, and crossfades.
5. Phonetic search and optional tempo/key matching.

## Success Measures

- Every output fragment resolves to its local source file and timestamp.
- Word boundaries remain intelligible after montage.
- Rerendering from the manifest is deterministic.
- The product works with a small purpose-recorded corpus before adding media complexity.

## Product Path

The personal tool can later become a meme/creative editor or creator pack platform. Run the deferred release audit before sharing corpora, generated montages, or a commercial catalog.

## Related

- [[Audio Watermark and Perception Lab]]
- [[Manga-to-Animatic Studio]]
- [[Ambient TV]]
- [[Project Ideas Index]]
