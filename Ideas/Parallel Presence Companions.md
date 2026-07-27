---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#6. Parallel Presence Companions]]"
status: concept
difficulty: medium
priority: p1
category: companionship and focus
form_factor:
  - desktop app
  - mobile app
  - video room
deployment: local-first with optional realtime server
source_ideas:
  - work alongside another person for social presence
  - speaking or texting fictional-character friends that check in
tags:
  - body-doubling
  - companionship
  - focus
---

# Parallel Presence Companions

> A body-doubling focus room that supports either a real partner or a clearly synthetic original character, using lightweight check-ins and ambient presence rather than constant conversation.

## Product Outcome

The user starts a session, states the next visible task, and chooses silent co-work, periodic text check-ins, or a low-bandwidth video/audio room. A companion remembers only approved context, checks progress at agreed intervals, and helps restart after distraction.

## Personal V0

- Set task, session length, desired interruption frequency, and “stuck” plan.
- Run a full-screen focus timer with optional ambient companion.
- Support a remote real-person room with mute-first defaults.
- Offer several original synthetic personalities with transparent AI labeling.
- At each checkpoint ask: progress, blocker, next action.
- End with a short receipt and optional scheduled follow-up.
- Allow “do not contact me outside sessions” and quiet-hours controls.

## Build Boundary

**MVP:** local timer, text companion, user-initiated sessions, and session history.

**Later:** WebRTC rooms, friend matching, customizable voice/avatar, persistent friendship arcs, and calendar awareness. Do not imitate copyrighted characters commercially, conceal that a companion is synthetic, or optimize for emotional dependency.

## Existing Products, Building Blocks, and Shortcuts

- Focusmate and Flow Club are product references for scheduled body doubling; their core value is the start declaration, social presence, and completion check—not complex collaboration.
- [Jitsi Meet](https://github.com/jitsi/jitsi-meet) or [LiveKit](https://github.com/livekit/livekit) can supply self-hosted realtime rooms. Use them only after a simple invite link beats silent text check-ins.
- The browser [WebRTC APIs](https://www.w3.org/TR/webrtc/) handle direct audio/video, while [SillyTavern](https://github.com/SillyTavern/SillyTavern) demonstrates local character companionship.
- Simplest alternative: Telegram bot + focus page—declare task, midpoint ping, completion receipt. It tests the social-presence effect before WebRTC, matching, avatars, or generated video.

## Free-First Stack

- **App:** Tauri or Expo, depending on desktop versus mobile priority.
- **Realtime later:** WebRTC with a small signaling server; LiveKit/mediasoup only when self-hosted rooms justify them.
- **Data:** local SQLite; encrypted sync for multi-device.
- **Models:** local LLM for brief check-ins with a small, explicit memory store.
- **Voice:** faster-whisper and local TTS; pre-generated idle reactions reduce latency.
- **Avatar:** simple 2D animation or Live2D-like original assets before generative video.

## Clever Shortcut

The highest-value version may be a Telegram bot plus a browser focus page: “starting 25 minutes on X,” a midpoint ping, and a completion receipt. Test whether presence works before investing in animated characters or video infrastructure.

## Build Slices

1. Focus contract, timer, and text checkpoints.
2. Companion styles and memory controls.
3. Interruption/restart flows.
4. Real-person invite link.
5. Voice/avatar layer.
6. Safe matching and moderation only if public rooms are attempted.

## Success Measures

- More sessions start and finish than with a timer alone.
- Check-ins help without becoming distraction.
- Users can inspect and delete companion memory.
- The app does not pressure users to return for the companion’s sake.

## Product Path

The personal tool can become a focus app, an open-source body-double bot, or a paid workplace/student product. Real-person rooms add moderation and safety costs; synthetic local companions are the simpler initial path.

## Related

- [[Angel and Demon Companion]]
- [[NPC Mode Personal Coach]]
- [[Motto Agent Council]]
- [[Project Ideas Index]]
