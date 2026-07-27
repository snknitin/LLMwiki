---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#16. Event Networking Copilot]]"
status: concept
difficulty: hard
priority: p2
category: networking
form_factor:
  - mobile app
  - smart-glasses companion
deployment: phone plus optional wearable
source_ideas:
  - Meta Ray-Ban event networking and common-ground assistant
tags:
  - wearables
  - networking
  - privacy
---

# Event Networking Copilot

> A consent-based event companion that helps remember who the user planned to meet, surfaces common ground from approved profiles, and captures follow-ups—without covert face recognition or scraping strangers’ LinkedIn identities.

## Product Outcome

Before an event, import the attendee list or selected public profiles and shortlist people based on explicit goals. At the venue, the user identifies someone by name, QR code, badge text, or manual tap; the app returns a tiny conversation card and later records a voice note and follow-up.

## Personal V0

- Define event goal, industries/topics, people already known, and desired introductions.
- Import a CSV, event page, shared digital business cards, or manually selected profiles.
- Build one evidence-linked card per person: role, recent work, mutual context, conversation starters, and questions.
- Rank a shortlist with diversity and “why this person” explanations.
- Search by typed/spoken name or scan an opt-in QR badge.
- Record a post-conversation note and proposed follow-up.
- Produce an end-of-event relationship map and action list.

## Build Boundary

**MVP:** phone app, manually provided attendee data, name/QR lookup, local storage, and follow-up drafts.

**Later:** Meta wearable camera/audio integration, badge OCR, organizer partnerships, live display cards, and contact sync. Do not implement face-to-identity matching, biometric watchlists, covert recording, or profile scraping.

## Existing Products, Building Blocks, and Shortcuts

- Meta’s [Wearables Device Access Toolkit](https://github.com/facebook/meta-wearables-dat-ios) exposes camera streaming/capture for supported glasses, and its [Mock Device Kit](https://wearables.developer.meta.com/docs/mock-device-kit/) allows development before relying on hardware.
- [vCard](https://www.rfc-editor.org/rfc/rfc6350) plus QR codes solves opt-in identity/contact exchange, while on-device ML Kit OCR can read a badge after an explicit scan.
- Event products such as Grip, Braindate, and Swapcard are references for attendee matchmaking and meeting follow-up. Organizer-supplied attendee data is a much cleaner input than identifying strangers.
- Simplest alternative: phone lock-screen card or earbud voice query—“prep me for Asha”—using a manually imported attendee CSV. Add glasses only if lookup latency is the measured bottleneck.

## Free-First Stack

- **App:** native Android/Kotlin or Expo development build; choose native if the wearable SDK requires it.
- **Wearable:** Meta Wearables Device Access Toolkit where supported, with its Mock Device Kit for early development.
- **Data:** encrypted local SQLite and event-scoped retention.
- **Search:** full-text and embeddings over user-approved attendee cards.
- **Models:** local model for common-ground synthesis and follow-up drafts.
- **OCR:** ML Kit/on-device text recognition for visible badges only after user action.
- **Sharing:** QR/vCard support before any social-platform API.

## Clever Shortcut

Prototype the whole value proposition without glasses: a lock-screen widget or one-earbud voice query—“prep me for Asha”—is cheaper, faster, and socially less intrusive. Add wearables only if lookup latency is the genuine bottleneck.

## Build Slices

1. Event goal and attendee-card importer.
2. Shortlist and evidence-linked conversation prompts.
3. Fast name search and QR/vCard exchange.
4. Voice-note capture and follow-up queue.
5. Mock wearable flow.
6. Hardware integration with visible recording/consent signals.

## Success Measures

- A useful card appears within three seconds.
- Every profile fact links to its supplied source.
- The user follows up with more relevant people after an event.
- Event data can be deleted as a batch.
- The tool never identifies an unknown face.

## Product Path

Organizer-provided attendee data is the credible product route: conferences can offer an opt-in matchmaking companion. A personal phone-first tool is useful without waiting for wearable platform maturity.

## Related

- [[Personal Signal Intelligence OS]]
- [[Jarvis and Alfred]]
- [[Playo Elo Sports Network]]
- [[Project Ideas Index]]
