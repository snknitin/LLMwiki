---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#4. Ambient TV]]"
status: concept
difficulty: medium
priority: p1
category: media
form_factor:
  - TV web app
  - desktop app
deployment: home network
source_ideas:
  - channel-surfing simulation with program guide and random episodes
  - TV channel surfing across YouTube, Netflix, streaming services, or Jellyfin
tags:
  - jellyfin
  - television
  - scheduling
---

# Ambient TV

> A lean-back channel guide that turns the user’s own media library and permitted streams into scheduled “channels,” opening an in-progress episode at the correct virtual airtime and restoring the pleasure of not choosing.

## Product Outcome

The interface behaves like television: a guide grid, channel identities, programs already underway, bumpers, and one-click surfing. A scheduler maps a deterministic playlist to wall-clock time, so joining a channel at 8:17 starts seventeen minutes into the current program.

## Personal V0

- Connect one Jellyfin library or local media directory.
- Create channels from genres, shows, creators, moods, or rules.
- Generate a seven-day schedule with durations and optional bumpers.
- Show now/next and a traditional EPG grid.
- Tune into the virtual current offset or restart from the beginning.
- Remember channel schedule seeds so household devices see the same lineup.
- Offer a “surprise me” remote with only channel up/down and favorite.

## Build Boundary

**MVP:** local/Jellyfin-owned media, browser playback, four channels, deterministic schedule, and EPG.

**Later:** YouTube playlists through permitted embedding/APIs, TV remote apps, household profiles, live streams, and DVR-like catch-up. Do not bypass DRM, automate Netflix playback, restream subscription media, or mix services in ways their terms prohibit.

## Existing Products, Building Blocks, and Shortcuts

- [Jellyfin](https://jellyfin.org/docs/) is the personal media server and playback API. [ErsatzTV](https://github.com/ErsatzTV/ErsatzTV), [Tunarr](https://github.com/chrisbenincasa/tunarr), and dizqueTV are direct open-source prior art for pseudo-live channels and EPGs.
- YouTube’s [IFrame Player API](https://developers.google.com/youtube/iframe_api_reference) can control permitted embedded videos in a separate channel type. Subscription services are best represented as “Open in service” launch cards.
- `ffprobe -v quiet -print_format json -show_format -show_streams FILE` gives exact local durations/codecs; FFmpeg can create bumpers or transcode only when Jellyfin direct play is impossible.
- Clever shortcut: seed each channel schedule by date and calculate the current item/offset from an epoch. Devices share a “live” experience without a continuously running stream.

## Free-First Stack

- **Backend:** Node.js/TypeScript or Python scheduler with SQLite.
- **Media:** Jellyfin API and direct-play/HLS capabilities on the home network.
- **Frontend:** TV-friendly React/Svelte PWA with keyboard/remote focus management.
- **EPG:** internal schedule schema with optional XMLTV export/import.
- **Playback:** native HTML5/HLS player where formats allow; delegate unsupported playback to Jellyfin.
- **Automation:** nightly schedule generator; no LLM required.

## Scheduling Hack

Treat each channel as an infinite deterministic timeline. Given channel seed and epoch, calculate the current item and offset without maintaining a constantly running stream. This creates a shared “live” experience while serving ordinary on-demand files.

## Build Slices

1. Scan library metadata and durations.
2. Channel-rule editor and deterministic scheduler.
3. Now/next and tune-at-offset playback.
4. EPG grid and remote navigation.
5. Bumpers, ratings filters, and household sync.
6. Permitted external-source adapters.

## Success Measures

- Channel tuning starts quickly on the home network.
- Schedule/offset stays consistent across devices.
- Users spend less time choosing before playback.
- No media is copied or restreamed outside authorized boundaries.

## Product Path

Start as a Jellyfin plugin or companion web app. An open-source channel scheduler has a clearer distribution path than a commercial aggregator dependent on closed streaming platforms.

## Related

- [[Creator Content Engine]]
- [[Song Phrase Mosaic]]
- [[Project Ideas Index]]
