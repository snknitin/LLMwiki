---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossiers:
  - "[[Research - Information and Learning Ideas#7. Language Learning Lab]]"
  - "[[Research - Personal Systems and Product Ideas#20. Language Learning and Pronunciation Coach]]"
status: concept
difficulty: hard
priority: urgent
urgency: personal-beta-by-2026-08-27
category: language learning
form_factor:
  - mobile app
  - web app
  - browser extension
deployment: local-first
source_ideas:
  - thirty-word spaced-repetition vocabulary builder
  - pronunciation coach with visual vocal comparison and text-to-speech
  - high-frequency words and phrases ranked across languages
tags:
  - language
  - spaced-repetition
  - pronunciation
  - speech
---

# Language Learning Lab

> A unified language workbench built on three connected loops: learn the most useful words and phrases, recall them with spacing, and speak them with interpretable pronunciation feedback.

## Product Outcome

The learner chooses a language and real-life contexts. A frequency-informed curriculum introduces a manageable number of lexical items, generates contextual examples, schedules retrieval, and connects each item to audio and pronunciation targets. Progress is measured by delayed recall and successful use, not daily word count alone.

## Personal V0

- Import a reputable frequency list and choose target contexts such as travel, work, or family.
- Create a ranked learner queue that balances frequency, personal relevance, and prerequisite phrases.
- Run recognition, production, cloze, listening, and speaking cards.
- Limit new items adaptively rather than forcing thirty every day.
- Record speech and compare timing, phoneme hypotheses, pitch contour, and energy against reference audio.
- Let the user select text from a browser reader and add a phrase with source context.
- Generate situation dialogues using only reviewed vocabulary bands.
- Show cognates, false friends, morphology, and cross-language comparisons.

## Build Boundary

**MVP:** one target language, one open frequency source, text/audio cards, SM-2/FSRS-style scheduling, local recording, and simple waveform/pitch feedback.

**Later:** phoneme-level scoring, multiple languages, live conversation, accent targets, browser extension, and teacher review. Avoid presenting one native accent as the only valid identity or treating ASR confidence as pronunciation truth.

### Month-One Personal Beta

Choose one target language and a reviewed starter set. First ship recognition/production cards, FSRS-style scheduling, reference audio, record/replay, and local persistence. Use it daily, log confusing cards and scheduler overload, and revise content from observed errors. Add only one narrowly defined pronunciation contrast after building a repeatable recording test set; generalized accent scoring is outside the month.

## Existing Products, Building Blocks, and Shortcuts

- [Anki FSRS](https://docs.ankiweb.net/deck-options.html#fsrs) provides a proven review scheduler; embed an open FSRS implementation rather than creating custom intervals.
- [Tatoeba downloads](https://tatoeba.org/en/downloads) can seed phrase/translation/audio records, while [Whisper](https://github.com/openai/whisper) provides local transcription. Whisper confirms words; it is not itself a pronunciation score.
- [Montreal Forced Aligner](https://montreal-forced-aligner.readthedocs.io/) aligns known text to word/phone boundaries, and [Praat](https://www.fon.hum.uva.nl/praat/) exposes pitch, formants, timing, and spectrogram analysis. They cover the “vocal graph” more credibly than an invented radar score.
- Existing products such as Anki, Speechling, YouGlish, and language shadowing apps show that a phrase inbox plus A/B playback is already useful. Simplest local alternative: selected text → TTS → record → playback → FSRS queue.

## Free-First Stack

- **App:** Expo/React Native for Android, iOS, and web; native audio modules where required.
- **Data:** local SQLite with lexical items, senses, contexts, attempts, and scheduler state.
- **Scheduling:** deterministic spaced-repetition library.
- **Speech:** Whisper-family ASR for rough transcripts; Montreal Forced Aligner or language-specific phoneme tools offline; Praat/Parselmouth for pitch/formants; Piper or licensed audio for TTS.
- **Models:** local LLM for constrained example drafts and dialogue; dictionaries/corpora remain authoritative.
- **Visualization:** Canvas/SVG for waveform, pitch, timing, and phoneme spans.

## Key Technical Choice

Do not start with a single “accent score.” First visualize alignment and let the learner hear A/B segments. Add language-specific detectors only for a few target contrasts—vowel length, aspiration, retroflexion, glottal stop—using reviewed examples.

## Build Slices

1. Frequency list, item editor, and scheduler.
2. Multi-mode cards and audio playback.
3. Recording, A/B playback, and timing/pitch view.
4. Situation curriculum and controlled dialogue.
5. Phrase capture from browser/mobile.
6. Language-specific phonetic models and evaluation.

## Success Measures

- Delayed production recall improves over four weeks.
- Example sentences remain natural and match the intended sense.
- Speaking feedback is stable across repeated recordings.
- New-item load automatically falls when review burden rises.
- Learners can hear or see the specific difference they need to practice.

## Product Path

Build one excellent language/phonetic contrast personally before becoming a platform. Open frequency/curriculum data and a paid cross-device coach could coexist. A specialist pronunciation module may be more defensible than a full Duolingo competitor.

## Related

- [[Bionic Reading Trainer]]
- [[Personal Study Curriculum]]
- [[Parallel Presence Companions]]
- [[Project Ideas Index]]
