---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: personalized-media
form_factor:
  - local web app
  - shareable gift page
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#20. Birthday Anthem Maker]]"
status: concept
tags:
  - audio
  - gifts
  - generative-media
---

# Birthday Anthem Maker

> Turn a one-minute memory form into a short, specific song package the sender can preview and edit.

## Product Outcome

The sender supplies a name, pronunciation, three memories, genre, energy, and one “never mention” field. The app returns a 45–75 second anthem, timed lyrics, cover image, and a private gift page. Specificity and safe preview matter more than studio-quality generation.

## User and Core Workflow

1. Complete a short structured form and optionally record the recipient’s name pronunciation.
2. Generate lyrics with a visible fact checklist and editable chorus.
3. Create an instrumental bed and a spoken/sung vocal approximation.
4. Mix, loudness-normalize, and render a lyric video or waveform page.
5. Sender previews, edits/regenerates one component, then exports a private link or files.

## Demo/Personal V0

Use one fixed musical bed, local lyric generation, and local TTS over a rhythmic melody-like cadence. Produce MP3, cover PNG, lyrics Markdown, and a static HTML page. This proves the gift loop without solving full singing synthesis.

## Build Boundary

**MVP:** one language, 60-second form, editable lyrics, one or two licensed/local music beds, local voice or sender narration, FFmpeg mix, local/private static page.

**Out:** celebrity imitation, voice cloning without explicit consent, chart-song style copying, public gallery, marketplace, payments, and unlimited music generation.

## Existing Products, Building Blocks, and Shortcuts

- [AudioCraft/MusicGen](https://github.com/facebookresearch/audiocraft) accelerates local instrumental generation; its repository distinguishes MIT-licensed code from CC-BY-NC model weights, so V0 can experiment locally and revisit release scope later.
- [ElevenLabs Text to Speech](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) can replace local TTS for a polished optional demo, while [Voice Design](https://elevenlabs.io/docs/eleven-creative/voices/voice-design/) creates synthetic voices from descriptions instead of impersonating a person.
- [FFmpeg filters](https://ffmpeg.org/ffmpeg-filters.html), especially audio mixing and loudness tools, replace a custom media pipeline.
- [Piper](https://github.com/OHF-Voice/piper1-gpl) is a local speech option when privacy and zero marginal cost matter more than expressiveness.

## Free-First Stack

- **App:** Gradio for the first local prototype; it handles form inputs, audio previews, and reruns quickly.
- **Writing:** Ollama with JSON-schema output for verse/chorus/fact references.
- **Audio:** pre-cleared loop library first; optional MusicGen instrumental; Piper or user-recorded vocal; FFmpeg for mix/render.
- **Image:** a local diffusion model or a deterministic SVG cover template.
- **Storage:** a per-gift folder containing `brief.json`, stems, final MP3, cover, and page.

A fixed loop plus good lyrics is the fastest credible V0. Full song generation is a later experiment, not a dependency.

## Architecture/Data Model

`GiftBrief` stores facts, pronunciation, tone, exclusions, and consent. `LyricDraft` links each personal line to a fact ID. `AudioAsset` records source, prompt, duration, and license note. `RenderJob` combines instrumental, vocal, and cover. `GiftPage` has a random local/private token and expiry.

## Build Slices

1. Brief form, fact validation, and editable lyrics.
2. Fixed-bed narration mix and MP3 export.
3. Cover/template page and QR code.
4. Optional local instrumental generation.
5. Timing, subtitles, and one-click partial regeneration.

## Drawbacks/Concerns/Failure Modes

- Names are mispronounced; require phonetic spelling or a reference recording.
- Personal facts can embarrass the recipient; provide exclusions, sender preview, and deletion.
- Music generation is slow and nondeterministic; cache stems and offer a fixed-bed fast mode.
- Loudness and timing can make an otherwise good result feel amateur; normalize audio and keep vocals intelligible.
- Voice imitation creates consent and impersonation risk; use synthetic designed voices or the sender’s own recording.

## Clever Hacks and Simpler Alternative

- “Spoken birthday radio jingle” is much easier than convincing singing and often funnier.
- Use four excellent royalty-cleared loops and generate only lyrics/voice; personalization carries the value.
- Render a kinetic-lyrics video from timed captions, avoiding complex character animation.
- Let the sender punch in one recorded line (“Happy birthday, …”) for emotional authenticity.

## Success Measures

- First playable draft in under three minutes on the target workstation.
- Sender edits fewer than three factual lines before approval.
- No excluded fact appears in lyrics.
- Speech remains intelligible on a phone speaker.
- The entire gift can be deleted from one screen.

## Product Path

Personal gift generator → paid one-off web gift → creator template marketplace → event/bulk gifting. Before monetization, audit music/model/voice licenses and commercial voice consent; keep the local prototype unchanged.

## Related Wikilinks

- [[AI Jingle Generator]]
- [[Personalized Video Greeting Generator]]
- [[Commentary Box]]

