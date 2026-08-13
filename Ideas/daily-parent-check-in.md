---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: family care
form_factor:
  - local dashboard
  - scheduled messaging assistant
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#1. Daily Parent Check-In]]"
status: concept
---
# Daily Parent Check-In

> A consent-first daily conversation ritual that helps an adult child stay connected to a parent without pretending to be a medical or emergency monitor.

## Product Outcome

Produce a warm, low-friction check-in in the parent’s preferred language and an evening digest containing highlights, requested follow-ups, and only explicitly configured concern signals. Success is more regular contact and less coordination anxiety—not “AI elder care.”

## User and Core Workflow

The child creates a parent profile with consent, language, timing, topics, contact method, and escalation rules. Each day the system sends one prompt, accepts text or voice, transcribes locally, extracts memories and requests, and drafts a short digest. The child can correct summaries, mark follow-ups, and call directly. Missed replies follow a configurable retry/escalation ladder.

## Demo/Personal V0

Run a seven-day pilot using a local simulated inbox or Telegram. Support one parent, one child, one daily prompt, voice-note upload, editable transcript, and a digest screen. Seed prompts manually and require the child to approve every outbound message.

## Build Boundary

Include scheduling, consent record, multilingual text/voice, local memory, digest, and explicit no-response rules. Exclude diagnosis, passive surveillance, emergency dispatch, automated sentiment-based alarms, medication advice, and autonomous calling.

## Existing Products, Building Blocks, and Shortcuts

- [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api) is the eventual family messaging channel; defer it while validating with a simulated inbox.
- [Whisper](https://github.com/openai/whisper) replaces a paid transcription service for local multilingual voice notes.
- [ElevenLabs TTS](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) can add natural spoken prompts after the text workflow works.
- [Telegram Bot API](https://core.telegram.org/bots/api) provides a lower-friction pilot channel with messages and voice files.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, APScheduler, a small HTMX/Jinja dashboard, Whisper, and Ollama. Python has excellent audio and scheduling libraries; SQLite is sufficient for one family; HTMX keeps the correction UI simple; local inference keeps intimate conversations on the workstation.

## Architecture/Data Model

Store `people`, `consents`, `preferences`, `check_ins`, `messages`, `transcripts`, `memory_cards`, `signals`, and `follow_ups`. A scheduler creates a check-in; the channel adapter records delivery/reply; transcription and structured extraction create reviewable artifacts; the digest renderer includes evidence links back to the message.

## Build Slices

1. Profile, consent, schedule, and typed check-in.
2. Voice upload, transcript correction, and multilingual digest.
3. Memory cards, follow-up queue, missed-reply ladder, and weekly review.
4. Optional Telegram/WhatsApp adapter after local reliability.

## Drawbacks/Concerns/Failure Modes

Summaries can distort tone; parents may feel surveilled; false alarms create anxiety; silence has many benign causes; and channel delivery may fail. Make memory visible/editable, keep signal rules deterministic, log delivery states, and display “contact directly” rather than medical conclusions.

## Clever Hacks and Simpler Alternative

Begin with a rotating scheduled question and a shared local webpage that records a voice note. Even a daily one-tap “I’m okay” plus one optional story prompt can prove the habit before adding conversation generation.

## Success Measures

Track reply rate, median parent effort, digest correction rate, missed-contact false alarms, follow-ups completed, and both participants’ weekly “felt more connected” rating.

## Product Path

Personal V0 → family pilot → configurable caregiver coordination product. Before public release, multi-user messaging, or payments, run [[Scope Expansion Checklist]] for consent, data rights, channel terms, and release obligations; keep the recommended local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#1. Daily Parent Check-In]]
- [[Scope Expansion Checklist]]
