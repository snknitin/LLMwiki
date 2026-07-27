---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#4. Bionic Reading Trainer]]"
status: concept
difficulty: easy
priority: p1
category: reading
form_factor:
  - mobile app
  - browser extension
deployment: on-device
source_ideas:
  - bionic reading text with speed-reading setup
tags:
  - accessibility
  - reading
  - browser-extension
---

# Bionic Reading Trainer

> An on-device reading surface that combines configurable fixation emphasis with paced reading, comprehension checks, and per-site profiles instead of promising speed through typography alone.

## Product Outcome

Let the user paste text, share an article, or activate a browser mode, then tune bold-prefix length, line width, font, contrast, chunk size, and pacing. The app measures comfortable speed and delayed comprehension so the visual treatment adapts to the reader rather than enforcing one gimmick.

## Personal V0

- Paste or import clean article text.
- Apply adjustable emphasis to the first portion of words.
- Offer scroll, RSVP one/few-word display, and phrase-chunk modes.
- Set words per minute and keyboard/touch controls.
- Ask lightweight comprehension and recall questions.
- Save presets for study, fiction, and skim reading.
- Export highlights without altering the source page.

## Build Boundary

**MVP:** local PWA with pasted text, three display modes, saved preferences, and a comprehension log.

**Later:** browser extension, mobile share target, EPUB support, accessibility presets, and optional local text-to-speech. Make no medical or universal speed claims.

## Existing Products, Building Blocks, and Shortcuts

- Mozilla’s [Readability](https://github.com/mozilla/readability) extracts the main article content and metadata from noisy pages; use it instead of maintaining site-specific selectors.
- The commercial [Bionic Reading](https://bionic-reading.com/) product demonstrates fixation-emphasis formatting, while browser reader modes demonstrate the calmer alternative. Your differentiator should be adjustable formatting plus comprehension measurement, not the bold-prefix transform alone.
- The browser-native [`Intl.Segmenter`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/Segmenter) helps segment words and sentences across languages, and the [Web Speech API](https://webaudio.github.io/web-speech-api/) can provide a zero-backend first TTS path.
- Simplest alternative: a bookmarklet/extension that sends the selected article through Readability and applies CSS variables for emphasis, line width, and pace. Add accounts or AI only after repeated use.

## Free-First Stack

- **PWA:** TypeScript with SvelteKit or React.
- **Extension:** Manifest V3 content script using a sanitized reader view.
- **Storage:** IndexedDB; no backend needed.
- **Text processing:** `Intl.Segmenter` where supported plus language-specific fallbacks.
- **Speech:** browser speech APIs first; local Piper server if consistent offline voices matter.
- **AI:** optional local question generation, always grounded only in the visible passage.

## Experiment Design

Run short within-person A/B sessions: plain reader versus emphasis versus paced chunks. Compare comprehension, delayed recall, comfort, and abandonment—not only raw words per minute. Keep all results local.

## Build Slices

1. Reader view and emphasis algorithm.
2. Pace controls and three modes.
3. Comprehension prompts and session history.
4. Preference profiles and accessible themes.
5. Extension/share integration.

## Success Measures

- Imported text renders correctly across punctuation and languages.
- Reading sessions resume exactly where they stopped.
- Comfortable speed rises without a meaningful comprehension drop.
- Users can disable every transformation instantly.

## Product Path

A polished free extension can build distribution. Paid options could include cross-device sync, teacher-created reading drills, language packs, and EPUB libraries, while the core transformation remains local.

## Related

- [[Language Learning Lab]]
- [[Personal Study Curriculum]]
- [[EPUB Highlights Bridge]]
- [[Project Ideas Index]]
