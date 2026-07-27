---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#1. Paper Logbook]]"
status: concept
difficulty: medium
priority: urgent
urgency: personal-beta-by-2026-08-27
category: productivity
form_factor:
  - Android app
  - iOS app
  - web app
deployment: offline-first
source_ideas:
  - customizable paper-like monthly logbook
tags:
  - journaling
  - templates
  - offline-first
---

# Paper Logbook

> A tactile, paper-like daily and monthly notebook that combines checkboxes, handwriting, compact trackers, and journaling in reusable templates across phone and web.

## Product Outcome

Capture the flexibility of a hand-drawn bullet journal without rebuilding the same page every month. The app should open instantly, work offline, feel calm, and let a user design a page once and then live inside it with minimal interface chrome.

## Personal V0

- A monthly canvas composed of date rows, checkboxes, counters, rating scales, text blocks, and freehand ink.
- A template editor with snap-to-grid layout and reusable components.
- Daily page duplication from the active template.
- Tap, type, draw, erase, undo, and keyboard/stylus input.
- Local reminders for selected fields.
- End-of-week and end-of-month rollups without interpreting private prose.
- Export a month as Markdown, JSON, PNG, and PDF.

## Build Boundary

**MVP:** one-device Android/PWA prototype, three templates, local SQLite, no login, and manual backup.

**Later:** end-to-end encrypted sync, shared templates, widgets, OCR over handwriting, and optional local reflections. Avoid turning the calm notebook into a notification-heavy habit game.

### Month-One Personal Beta

Start with one opinionated daily page—checkboxes, short text, and one rating—rather than the template editor. Use it every day for two weeks, add export/restore and migration tests, then generalize only the fields that actually changed. The month closes with offline durability, one reusable template, JSON/Markdown export, and a documented recovery drill; ink, sync, and a template marketplace wait.

## Existing Products, Building Blocks, and Shortcuts

- [Excalidraw](https://github.com/excalidraw/excalidraw) provides an embeddable hand-drawn canvas and portable JSON scene format. Embed or borrow its stroke model instead of building a drawing engine first.
- The [Pointer Events specification](https://www.w3.org/TR/pointerevents/) unifies mouse, touch, and pen—including pressure and tilt—on the web. Apple’s [PencilKit](https://developer.apple.com/documentation/pencilkit) is the native benchmark if handwriting latency becomes the decisive requirement.
- Obsidian daily notes, Logseq journals, and bullet-journal templates already cover text-first tracking. A form that writes readable Markdown plus optional SVG ink is the fastest durable alternative.
- Shortcut: define page blocks in versioned YAML, instantiate an immutable monthly snapshot, and add “duplicate yesterday, clear checkboxes.” This avoids building a full free-form template studio before daily use proves the schema.

## Free-First Stack

- **Fastest universal route:** Expo/React Native with TypeScript and web support.
- **Ink/canvas:** Skia-based drawing on mobile; SVG/canvas representation for web.
- **Data:** SQLite with append-only page events and versioned template JSON.
- **Export:** local HTML-to-PDF or SVG/PDF renderer.
- **Sync later:** user-owned WebDAV, Syncthing-compatible folder, or a small encrypted service.
- **AI:** none in the first slice; optional local model only for user-invoked summaries.

## Data Model

A `Template` contains positioned `Blocks`. A `Page` references a template version and stores block values plus ink strokes. A `Period` groups pages. Keep template migration explicit so changing next month’s layout never corrupts prior pages.

## Build Slices

1. Render a fixed paper page with checkboxes and text.
2. Save locally and reopen offline.
3. Build drag/resize template editing.
4. Add freehand ink and stylus ergonomics.
5. Monthly navigation, rollups, and exports.
6. Optional encrypted backup.

## Success Measures

- Cold start to first mark under two seconds.
- A daily check-in takes under one minute.
- No data loss across thirty offline days.
- A custom monthly page can be built in under ten minutes.
- The exported month remains readable outside the app.

## Product Path

Ship the local version as a paid-once app or open-core notebook. Monetizable layers include premium template packs, cross-device encrypted sync, printable books, and specialist packs for study, fitness, finances, or chronic-condition tracking.

## Open Decisions

- Whether visual fidelity or cross-platform speed matters more for v0.
- Stylus priority versus one-handed phone use.
- Exact paper aesthetic: clean dot-grid, aged notebook, or user themes.

## Related

- [[Measure Life]]
- [[Goal-to-Calendar Planner]]
- [[Any App Widget Maker]]
- [[Project Ideas Index]]
