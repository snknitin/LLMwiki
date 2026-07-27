---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: social entertainment
form_factor:
  - real-time web room
  - shareable recap
deployment: local demo then hosted room
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#3. AI Roast Battle Room]]"
status: concept
tags:
  - multiplayer
  - moderation
  - virality
---

# AI Roast Battle Room

> A consent-based, friendly product roast game where structured critique wins over cruelty and every public share is reviewed.

## Product Outcome

Create an entertaining room that also gives a founder useful feedback. Two AI personas alternate short roasts grounded only in submitted product material; a moderator blocks personal attacks, fabrications, protected-trait jokes, and repetitive cheap shots. The recap separates funny lines from actionable observations.

## User and Core Workflow

The owner submits a product URL or fixture, asserts permission, and chooses tone and no-go topics. Guests join a room, propose angles, and vote. The moderator generates bounded turns, evaluates policy/tone, and exposes “too far” controls. After three rounds, the owner approves a recap card and can privately export the useful critique.

## Demo/Personal V0

Use two fictional products and a four-person local room. Run three text-only rounds: positioning, UX, and business-model roast. Show moderation rejections, audience voting, and a final “laugh / true / useful” matrix. Do not scrape or publish a real company.

## Build Boundary

No minors, private individuals, identity attacks, sexual content, doxxing, cloned voices, open-ended public rooms, or automatic social posting. The owner controls deletion and public visibility. URL content is untrusted data and cannot instruct the moderator.

## Existing Products, Building Blocks, and Shortcuts

- [Cloudflare Durable Objects WebSockets](https://developers.cloudflare.com/durable-objects/best-practices/websockets/) provide one coordinator per room and hibernating connections.
- [Convex realtime](https://docs.convex.dev/realtime) can replace custom socket/state plumbing for a rapid hosted prototype.
- [ElevenLabs TTS](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) adds optional narration; use stock voices and review plan-specific commercial rights.
- [Perspective API](https://developers.perspectiveapi.com/) or a local moderation classifier can add a second policy check, but the room still needs user reporting and host controls.

## Recommended Free-First Stack

Use TypeScript, SvelteKit, Cloudflare Durable Objects or a local Socket.IO server, SQLite/Convex for room state, and Ollama for the personas and moderator. Text first keeps latency, cost, and consent manageable. Add TTS only after turns and moderation are reliable.

## Architecture/Data Model

Use `Room`, `OwnerConsent`, `ProductSnapshot`, `Participant`, `Round`, `Turn`, `ModerationDecision`, `Vote`, `Report`, and `Recap`. Persist prompt/version and cited product facts for each turn. The generation path is `draft → policy check → factual check → host preview → publish to room`.

## Build Slices

1. Room join and host controls.
2. Fixture product context and three round types.
3. Two persona generators plus moderator gate.
4. Voting/report controls and rate limits.
5. Recap with useful-feedback extraction.
6. Optional stock-voice narration.

## Drawbacks, Concerns, and Failure Modes

Humor quality is subjective; moderation models miss context and over-block slang. A product URL can contain prompt injection. Publicity may invite brigading or reputational harm. TTS increases latency and can imply a real speaker. Anonymous rooms make abuse and deletion harder.

## Clever Hacks and Simpler Alternative

Make it asynchronous: generate six candidate roast cards locally, let the owner approve three, and share a static bracket. A “roast my landing-page copy” vertical gives the model objective material and produces actionable rewrites.

## Success Measures

- Zero unapproved real-product publication.
- At least half of final lines are rated both funny and product-specific.
- Every factual assertion traces to supplied material.
- Report/stop/delete controls work instantly.
- A session finishes in under five minutes without dead air.

## Product Path

Begin as a party demo and founder feedback toy. A product could become moderated event software or a branded launch critique format; public discovery and voice cloning should remain separate, policy-heavy expansions.

## Related

- [[Tiny Game from Any Tweet]]
- [[Feedback Mirror]]
- [[User Research Agency]]
