---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#5. Angel and Demon Companion]]"
status: existing-prototype
difficulty: medium
priority: low
completion_estimate: 80-percent
category: behavior change
form_factor:
  - mobile app
  - voice companion
deployment: local-first
source_ideas:
  - angel and demon pet that learns virtues and vices
tags:
  - coaching
  - virtual-pet
  - values
---

# Angel and Demon Companion

> Two customizable virtual pets that argue from the user’s chosen values and temptations, helping a decision become explicit without claiming moral authority or mental-health expertise.

## Product Outcome

When facing a choice, the “demon” articulates the immediate reward and rationalization honestly; the “angel” articulates long-term values and consequences. A third neutral summary identifies the real tradeoff and suggests the smallest value-aligned action. Over time the pets learn which framing helps.

## Personal V0

- Define personal virtues, vices, goals, boundaries, and topics the app should not coach.
- Log a choice by text or voice.
- Generate the two perspectives from a shared factual state.
- Ask the user what they chose and how it felt later.
- Maintain a local pattern log of triggers, contexts, and helpful interventions.
- Customize names, voices, and original character art.
- Offer “no debate—just help me act” and “do not moralize” modes.

## Build Boundary

**MVP:** text-only local app, explicit values profile, two perspectives, neutral synthesis, and outcome feedback.

**Later:** voices, images, proactive check-ins, wearable context, and shared challenges. Do not diagnose addiction, depression, eating disorders, or other health conditions; route crisis or clinical needs outside the character mechanic.

### Current Disposition

An existing hackathon prototype is reported to be about 80% complete. Do not rebuild it during the urgent program. Audit the repository, record the working demo path, capture defects in the remaining 20%, and decide whether the current architecture is worth finishing.

## Existing Products, Building Blocks, and Shortcuts

- [SillyTavern](https://github.com/SillyTavern/SillyTavern) already implements local character cards, group chats, lore/memory, TTS, image backends, and many model providers. It is the fastest harness for testing whether the two-perspective mechanic helps.
- [Open WebUI custom models](https://docs.openwebui.com/features/workspace/models/) can wrap one base model with different system prompts, tools, and knowledge; this is enough for an early Angel/Demon prototype.
- [Piper](https://github.com/rhasspy/piper) or platform TTS can provide local voices, and a local image workflow can create original pet states without making media generation core.
- Simpler alternative: one factual memory, two constrained interpretations, and a neutral decision summary in a plain local chat. Add pets, proactive check-ins, and voices only after the reflection loop proves useful.

## Free-First Stack

- **App:** Expo/React Native.
- **Data:** encrypted local SQLite with separate values, decisions, context tags, and feedback.
- **Models:** a local model with three constrained prompts; factual claims must come from user input or a reviewed source.
- **Voice later:** faster-whisper and local TTS; push-to-talk rather than continuous listening.
- **Images:** user-selected assets or local original-character generation.
- **Rules:** topic classifier and hard boundaries outside the generative model.

## Coaching Contract

The user owns the values. The pets cannot invent moral rules, shame the user, or manipulate by threatening relationship loss. Proactive notifications are opt-in, rate-limited, and easy to silence. Memory can be viewed, corrected, and deleted.

## Build Slices

1. Values/boundaries onboarding.
2. Decision dialogue and neutral summary.
3. Outcome check-in and pattern timeline.
4. Intervention feedback and personalization.
5. Voice/art customization.

## Success Measures

- The user reports clearer tradeoffs rather than more guilt.
- Advice references chosen values accurately.
- Proactive prompts are more often helpful than annoying.
- Sensitive logs remain local and deletable.

## Product Path

It can be a playful personal reflection tool or an open-source character-coach template. A paid consumer app could sell customization and encrypted sync, but must avoid engagement mechanics that exploit emotional dependence.

## Related

- [[NPC Mode Personal Coach]]
- [[Parallel Presence Companions]]
- [[Motto Agent Council]]
- [[Measure Life]]
- [[Project Ideas Index]]
