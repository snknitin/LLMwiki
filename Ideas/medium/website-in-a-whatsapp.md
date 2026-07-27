---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: conversational website builders
form_factor:
  - WhatsApp or Telegram bot
  - static website generator
deployment: local generator with optional messaging webhook and static host
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#27. Website in a WhatsApp]]"
status: concept
tags:
  - websites
  - messaging
  - small-business
---

# Website in a WhatsApp

> A conversational site builder where a small-business owner sends facts, photos, and voice notes, approves a preview, and later edits the live static site with constrained chat commands.

## Product Outcome

Make a credible one-page website possible from a phone without hiding important decisions. The bot turns messages into structured business data, asks for missing facts, generates an accessible preview, and requires approval before deployment or updates.

## User and Core Workflow

1. Owner begins with an authenticated chat or local conversation simulator.
2. Bot requests business name, offer, location/service area, hours, contact method, proof, colors, and authorized media.
3. Voice notes are transcribed and shown for correction; photos receive captions/alt-text suggestions.
4. Structured facts populate a chosen template and create a private preview.
5. Owner approves, edits, or rejects each unsupported claim.
6. The system builds and deploys an immutable static version.
7. Later messages such as “change Friday hours” produce a diff and confirmation before publication.

## Demo/Personal V0

Simulate the chat in a local web UI and use one business fixture, two templates, uploaded photos, and an optional local audio file. Generate an Astro site and local preview. A real WhatsApp webhook and public deployment are deliberately deferred.

## Build Boundary

- In scope: structured fact collection, local transcription, authorized media, templates, accessibility checks, previews, version history, and approval-gated deployment.
- Out of scope: free-form generated website code, fabricated testimonials, automatic domain purchase, payment collection, SEO promises, or silent chat-to-production edits.
- Treat inbound media as untrusted: limit type/size, strip metadata, scan, and re-encode.
- Keep tenant/site identity bound to verified channel identity in any hosted version.

## Existing Products, Building Blocks, and Shortcuts

- [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api/) is the official webhook/message route for a future business integration.
- [Telegram Bot API](https://core.telegram.org/bots) is easier for an early live bot and can validate the conversational workflow before WhatsApp onboarding.
- [Astro](https://docs.astro.build/) turns structured content and templates into fast static sites.
- [Cloudflare Pages direct upload](https://developers.cloudflare.com/pages/get-started/direct-upload/) can host approved static builds.
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) handles voice-note transcription locally.

## Recommended Free-First Stack

- TypeScript, Astro, Zod, and a small Node/Fastify webhook or local simulator.
- SQLite for conversations, structured facts, asset references, approvals, and versions.
- whisper.cpp for local audio; Sharp for re-encoding images and stripping metadata.
- Local LLM for fact extraction and copy suggestions constrained to the site schema.
- Playwright, Lighthouse, and axe-core for preview, responsive, link, and accessibility checks.

Static templates plus structured facts make every chat edit a safe data change rather than an uncontrolled code rewrite.

## Architecture/Data Model

`owner` owns `site`, `conversation`, `message`, `fact`, `asset`, `template`, `draft_version`, `change_request`, `approval`, `build`, `deployment`, and `domain`. Facts retain source message and confidence. Builds are immutable, while the site points at the currently approved deployment.

## Build Slices

1. Local conversation simulator, structured business schema, and missing-field prompts.
2. Two accessible templates, asset processing, and local preview.
3. Voice transcription, source-linked copy suggestions, and fact correction.
4. Change-request diff, approval state machine, version history, and rollback.
5. Telegram pilot, then WhatsApp webhook and optional static-host deployment.

## Drawbacks, Concerns, and Failure Modes

- Chat fragments are ambiguous and can create incorrect hours, prices, or claims.
- WhatsApp onboarding, templates, rate limits, and provider policy add friction.
- Uploaded images may contain private metadata or lack usage rights.
- A one-page site does not solve domain reputation, discovery, analytics, or ongoing content.
- Stolen channel access could enable site defacement without strong confirmation.

## Clever Hacks and Simpler Alternative

- Start with Telegram or a web chat simulator before WhatsApp approval.
- Generate a QR review link that opens directly on the owner’s phone.
- Restrict updates to schema fields and show natural-language plus visual diffs.
- Use a shared subdomain first; custom domains can be a later paid setup.
- Simplest alternative: a form that generates a hosted business card page, with WhatsApp used only to send the preview link.

## Success Measures

- A complete fixture becomes a usable local preview in under five minutes.
- Every published fact links to an owner message or explicit edit.
- No chat message changes production without a preview and approval event.
- Templates pass responsive, accessibility, and broken-link checks.
- Nontechnical testers can change hours and one image without help.

## Product Path

Use it for personal experiments and a few invited small businesses. Later sell template packs, custom domains, analytics, catalog/order modules, agency accounts, and managed setup. A public service needs channel-provider compliance, tenant isolation, abuse handling, domain/security operations, and clear media/content ownership terms.

## Related

- [[Microsite Factory]]
- [[WhatsApp Catalog Bot for Small Stores]]
- [[Creator Content Engine]]
