---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - New Personal Workflows and Product Ideas#5. Deliberate Feed Gate]]"
status: concept
difficulty: medium
priority: p0
category: attention interface
form_factor:
  - browser extension
  - local review app
deployment: local-first
source_ideas:
  - replace feed scrolling gestures with explicit buttons
  - preview and choose before opening each social item
  - optionally perform like comment share or skip actions
tags:
  - attention
  - browser-extension
  - social-media
  - deliberate-use
---

# Deliberate Feed Gate

> Put a decision between the impulse and the feed: preview one item, decide whether it deserves attention, then open or skip it with an explicit button instead of entering an endless scroll.

## Product Outcome

When the user visits a supported social home feed, the extension redirects or overlays it with a bounded local queue. Each card shows source, topic, media length, short description, why it was selected, and what attention budget remains. Only `show me`, `save the summary`, `later`, or `skip` advances the queue.

If the user chooses to open the item, the original platform remains the place for viewing and normal interactions. Optional like/comment/share/unfollow proposals can be performed through site adapters after explicit selection. The product changes the interaction rhythm rather than attempting to replace every social UI.

## Personal V0

- Begin with YouTube home/subscription links or a user-created queue of social URLs.
- Generate preview cards from metadata, caption snippets, and [[Shortform Signal Digest]] summaries.
- Enforce ten items or fifteen minutes per session.
- Require a button to reveal/open the next item; disable wheel/swipe navigation inside the local queue.
- Record `open`, `skip`, `later`, `save summary`, time spent, and optional reason.
- End with a session recap and one question: “Was this better than opening the original feed?”

## Build Boundary

**MVP:** one site, local queue, preview card, explicit controls, session budget, feedback log, and deep-link to the original item.

**Later:** intercept several home-feed routes, browser-assisted actions, mobile accessibility overlay/share target, scheduled sessions, and adaptive budgets.

Content discovery and ranking can be imported from [[Shortform Signal Digest]]. This project owns the **consumption interface and behavior loop**, so it remains useful as a standalone extension.

## Existing Products, Building Blocks, and Shortcuts

- [Chrome Manifest V3](https://developer.chrome.com/docs/extensions/develop/migrate/what-is-mv3), `declarativeNetRequest`, `tabs`, and `activeTab` provide the browser-extension foundation.
- Unhook, DF Tube, News Feed Eradicator, LeechBlock, and Freedom demonstrate feed hiding, redirecting, and time limits. This project adds item-level preview and deliberate consent to spend attention.
- [YouTube Data API](https://developers.google.com/youtube/v3/docs/videos/list) or oEmbed-style metadata can populate a queue without loading the full watch page.
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) can enrich explicitly queued processable links with subtitles/metadata for local preview generation.
- A bookmark folder plus a static one-card webpage is the simplest test; an extension is justified only when automatic interception matters.

## Recommended Free-First Stack

- TypeScript Manifest V3 extension with site adapters and minimal permissions.
- Local Svelte/React queue UI served from extension storage or localhost.
- SQLite local service for cross-browser history; IndexedDB is enough for one-browser V0.
- Deterministic session-budget state machine using XState or plain reducers.
- Local summaries imported through JSON/localhost API; do not put model inference in the extension service worker.

## Architecture and Data Model

`QueueItem` stores URL, platform ID, source, preview evidence, duration, topic, rank reason, and state. `AttentionSession` stores budget, start/end, cards shown, and termination reason. `FeedDecision` stores action, delay, reason, and eventual outcome. `SiteAdapter` defines detect-feed, extract-item/deep-link, and optional supported-action methods.

The gate should never require the model to decide whether the user is “allowed” to view something. It presents evidence and applies the user’s configured rules.

## Build Slices

1. Static URL queue with one-card interface and session limit.
2. Metadata/summary previews and local decision log.
3. Browser redirect/overlay for one feed route.
4. Later/save/skip behavior and end-of-session report.
5. Optional approved site action adapter.
6. Import rankings from [[Shortform Signal Digest]].

## Drawbacks, Concerns, and Failure Modes

- The preview itself can become a new infinite feed. Hard-stop the queue and omit engagement counters by default.
- Some content cannot be summarized reliably without viewing. Mark low-confidence previews and offer “open blind.”
- Site DOM changes can break adapters. Keep URL-queue mode functional without them.
- Excess friction can make the user disable the tool. Allow scheduled windows, emergency bypass, and adjustable budgets.
- Skip behavior may be misread as dislike. Capture `not now`, `already know`, and `not relevant` separately.

## Clever Hacks and Simpler Alternative

- Redirect only home/recommendation URLs; search results, messages, and direct links remain normal.
- Show a blurred thumbnail or no thumbnail to reduce clickbait effects.
- Require a one-sentence intention at session start and rank only against it.
- After an item opens, require returning to the gate before another recommendation is shown.
- Offer a summary-only mode for low-value or repetitive clusters.

## Success Measures

- Feed sessions end within the configured budget.
- The user opens a smaller proportion of cards but rates opened items more useful.
- The extension survives site-adapter failures by falling back to the local queue.
- Explicit bypass remains rare and understandable.
- Scroll time falls without blocking purposeful direct-link use.

## Product Path

Local URL queue -> one-site extension -> cross-platform attention layer -> configurable accessibility/digital-wellbeing product. Expansion invokes [[Scope Expansion Checklist]], but the initial local redirect-and-queue architecture remains appropriate.

## Related

- [[Shortform Signal Digest]]
- [[Social Subscription Curator]]
- [[Bionic Reading Trainer]]
- [[Measure Life]]
- [[Project Ideas Index]]

