---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: generative-video
form_factor:
  - local desktop workflow
  - web upload app
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#24. Commentary Box]]"
status: concept
tags:
  - video
  - speech
  - commentary
---

# Commentary Box

> Add energetic, time-aware broadcast commentary to a short personal clip without needing a full video editor.

## Product Outcome

Upload a 15–90 second clip, choose language and commentator energy, mark two or three moments, and receive a mixed video with scripted commentary, captions, and ducked original audio. The output should feel synchronized and fun, not merely like a paragraph read over footage.

## User and Core Workflow

1. Import a short clip and select language, energy, and safe pronunciation notes.
2. Extract audio, transcript, duration, and low-resolution preview frames.
3. User marks key moments or accepts automatically proposed timestamps.
4. Generate a beat-by-beat script with strict duration budgets.
5. Synthesize or record commentary, align segments, duck the source audio, and render captions.
6. Preview, regenerate one segment, and export MP4 plus script.

## Demo/Personal V0

Use a 30-second cricket/demo clip. The user manually marks three timestamps and describes what happens. Generate three short lines, synthesize locally, mix with FFmpeg, and burn captions. Manual marking avoids building unreliable video understanding first.

## Build Boundary

**MVP:** clips under 90 seconds, manual event markers, one local TTS voice per language, timed script schema, FFmpeg mix/captions, segment-level retry.

**Out:** live streaming, face identification, copyrighted broadcast footage ingestion at scale, celebrity commentator cloning, automatic sports statistics, long-form editing, and public hosting.

## Existing Products, Building Blocks, and Shortcuts

- [FFmpeg’s filter system](https://ffmpeg.org/ffmpeg-filters.html) replaces custom audio mixing, ducking, subtitle, loudness, and muxing code.
- [Whisper](https://github.com/openai/whisper) accelerates optional source-audio transcription and timestamp extraction.
- [Remotion](https://www.remotion.dev/docs) is useful when the output needs programmable graphics, score bugs, and caption animation beyond FFmpeg templates.
- [ElevenLabs TTS](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) is an optional polished voice path; [Piper](https://github.com/OHF-Voice/piper1-gpl) keeps the personal V0 local.

## Free-First Stack

- **UI:** Gradio for upload, timestamp sliders, audio preview, and retries.
- **Media probing/render:** FFprobe + FFmpeg.
- **Speech/text:** faster-whisper/Whisper for transcript, Ollama for timed script JSON, Piper for local TTS.
- **Optional graphics:** Remotion only after the audio pipeline works.
- **Storage:** per-job workspace with automatic cleanup and a render manifest.

## Architecture/Data Model

`Clip` stores duration, frame rate, audio layout, and checksum. `Moment` stores timestamp, user description, and importance. `ScriptSegment` has start/end budget, words, pronunciation overrides, and energy. `VoiceTake` records engine and duration. `RenderManifest` lists filters, assets, and outputs for reproducibility.

## Build Slices

1. Upload/probe and manual moment markers.
2. Duration-constrained script generation.
3. Local TTS and segment preview.
4. FFmpeg duck/mix/captions.
5. Optional automatic moment suggestions and Remotion graphics.

## Drawbacks/Concerns/Failure Modes

- Generated lines run longer than their slot. Estimate speech rate, synthesize per segment, and re-write when duration exceeds budget.
- Commentary covers important original sound. Use side-chain ducking and allow “preserve audio” zones.
- Video understanding may hallucinate actions. In V0, use user descriptions as the authority.
- Multilingual names are often mispronounced; support phonetic overrides and per-line retries.
- Uploaded clips may contain bystanders or copyrighted material; local processing and explicit export responsibility reduce exposure.

## Clever Hacks and Simpler Alternative

- Manual event markers plus one sentence per marker outperform an ambitious vision pipeline in a weekend.
- Offer three preset formats: sports hype, documentary deadpan, and product-launch announcer.
- Generate only audio + `.srt` first; users can combine them in an editor if rendering is slow.
- Use waveform silence detection to place commentary where it conflicts least.

## Success Measures

- A 60-second clip renders in under five minutes on the target workstation.
- At least 90% of commentary segments fit their time window.
- User can fix one bad line without rerendering every upstream step.
- Speech is intelligible and original audio remains audible at key moments.

## Product Path

Local clip toy → downloadable desktop creator tool → hosted short-video service → live/event production add-on. Commercial scope must review voice/model licenses and user rights to uploaded media.

## Related Wikilinks

- [[Birthday Anthem Maker]]
- [[Automated Short Video Factory]]
- [[AI Sports Highlight Narrator]]
