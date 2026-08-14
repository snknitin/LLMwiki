---
type: workflow-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - New Personal Workflows and Product Ideas#4. Social Subscription Curator]]"
status: concept
difficulty: medium
priority: p1
category: social account hygiene
form_factor:
  - local dashboard
  - review-and-apply workflow
deployment: local-first
source_ideas:
  - categorize subscribed or followed channels
  - extract useful content from playlists and videos
  - identify and unsubscribe from defunct channels across social platforms
tags:
  - subscriptions
  - youtube
  - social-media
  - cleanup
---

# Social Subscription Curator

> Audit who and what you follow, recover the best material from valuable sources, and generate a reversible keep/list/mute/unsubscribe plan instead of performing an impulsive mass cleanup.

## Product Outcome

The workflow converts platform-specific subscriptions into a source registry with topic, activity, value history, overlap, and a decision. It distinguishes an inactive but uniquely valuable archive from a dead low-value source, and separates “unsubscribe” from “consume less often.”

For high-value channels, it should identify cornerstone playlists/videos/posts to process through [[LongVid Learning Studio]] or [[Shortform Signal Digest]] before changing the subscription.

## Personal V0

1. Import YouTube subscriptions and one other platform’s follows through an export or user-provided list.
2. Retrieve recent activity metadata and a small content sample.
3. Classify topic, format, posting frequency, last active date, overlap, and personal value evidence.
4. Produce `keep`, `list/folder`, `sample less`, `archive best content`, `mute`, `review`, and `unsubscribe` proposals.
5. Let the user edit decisions and rules in a table.
6. Export the before-state, approved actions, and a rollback/reference file.
7. Apply changes manually first; later support reviewed API/browser batches.

## Build Boundary

**MVP:** imports, source registry, activity/topic metrics, content sampling, decision proposals, review UI, and export.

**Later:** recurring quarterly audit, cross-platform identity, list/folder creation, playlist extraction, and approved batch actions.

This is not the daily content reader. [[Shortform Signal Digest]] handles items; this workflow maintains the upstream source portfolio.

## Existing Products, Building Blocks, and Shortcuts

- The [YouTube Data API](https://developers.google.com/youtube/v3/docs/subscriptions/list) exposes a user-authorized subscription collection, while channel and playlist endpoints provide recent metadata.
- The official [`subscriptions.delete`](https://developers.google.com/youtube/v3/docs/subscriptions/delete) endpoint can apply reviewed YouTube unsubscribe actions; preserve the subscription/channel ID and pre-change manifest for verification.
- Google Takeout and platform account archives provide owned-data fallbacks when APIs omit history or are inconvenient.
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) can inspect playlists/channels and retrieve metadata/captions for selected processable content; use `--flat-playlist --dump-single-json` for a cheap metadata-first inventory.
- [FreshRSS](https://github.com/FreshRSS/FreshRSS) categories and OPML export are a simple destination for sources that publish feeds.
- Unfollow tools and YouTube subscription managers are product references. The differentiator is cross-platform evidence, archive-before-unsubscribe, and explicit personal-value scoring.

## Recommended Free-First Stack

- Python adapters, Polars, SQLite, and a Streamlit review table.
- YouTube Data API for authorized metadata; archive/export parsers elsewhere.
- sentence-transformers/local model for topic summaries and source overlap.
- yt-dlp metadata/captions only for shortlisted sources.
- CSV/OPML/Markdown exports plus optional Playwright action adapters.

## Decision Model

For each `SourceSubscription`, track platform ID, identity, topic distribution, last activity, cadence, sampled items, saved/liked evidence, unique-value score, overlap set, and current organization. `SubscriptionDecision` stores proposed action, rules fired, evidence, approval, applied status, and verification.

“Defunct” must be deterministic and configurable—for example, no content for twelve months—then modified by archive value and explicit keep rules.

## Build Slices

1. YouTube import and editable source table.
2. Activity sampling and deterministic inactivity rules.
3. Topic/overlap analysis and proposed folders.
4. Archive-best-content queue.
5. Reviewed action export and manual execution checklist.
6. One supported write adapter with dry-run and post-action verification.

## Drawbacks, Concerns, and Failure Modes

- Posting frequency is not value. Rare expert channels should not be penalized as dead noise.
- Sampling only recent content misclassifies changing or seasonal channels. Show the sample window.
- Cross-platform identities are ambiguous. Merge only with explicit confirmation.
- Automated unsubscribe batches can remove intentionally dormant sources. Require a before-state export and review.
- Processing every back catalog is expensive. Rank playlists/items before transcription.

## Clever Hacks and Simpler Alternative

- Start with a spreadsheet sorted by last activity and subscription age.
- Archive only each channel’s top three user-selected playlists before cleanup.
- Add a “seasonal/syllabus/reference” keep reason so inactive sources are not treated as broken.
- Convert low-frequency high-value channels to RSS/FreshRSS rather than remaining subscribed in a distracting app.

## Success Measures

- The user can explain every approved unsubscribe or reorganization decision.
- High-value archives are captured before removal.
- Followed sources become easier to browse by intent.
- Quarterly reruns reuse manual labels and do not repeat resolved work.
- Daily feed relevance improves without losing deliberate exploration.

## Product Path

Personal audit workflow -> recurring subscription-maintenance dashboard -> cross-platform source portfolio manager. Apply [[Scope Expansion Checklist]] before operating other users’ accounts; preserve the local export-first core.

## Related

- [[X Like-to-List Builder]]
- [[Shortform Signal Digest]]
- [[LongVid Learning Studio]]
- [[Personal Signal Intelligence OS]]
- [[Project Ideas Index]]
