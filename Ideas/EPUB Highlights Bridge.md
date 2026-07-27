---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#11. EPUB Highlights Bridge]]"
status: concept
difficulty: medium
priority: p1
category: reading workflow
form_factor:
  - folder watcher
  - desktop tray app
  - Obsidian integration
deployment: local-first
source_ideas:
  - automate highlights from personal EPUBs across devices
tags:
  - epub
  - highlights
  - obsidian
  - calibre
---

# EPUB Highlights Bridge

> A local adapter system that imports highlights, notes, and reading locations from personal EPUB workflows into stable Obsidian notes without overwriting human commentary on re-import.

## Product Outcome

Exports from Calibre, KOReader, or other user-controlled readers land in an inbox. The bridge identifies the edition, normalizes annotations, deduplicates sync copies, enriches them with chapter/context, and updates one durable Markdown note per book.

## Personal V0

- Watch a folder for KOReader Markdown/JSON or Calibre annotation exports.
- Identify books using embedded identifier, title/author/edition, and content hash.
- Normalize highlight text, note, color, timestamp, chapter, and native position.
- Relocate quotes in a local DRM-free EPUB when available and attach surrounding context.
- Merge duplicates while retaining immutable import events.
- Render a book note with source blocks and separate user commentary sections.
- Produce conflict reports rather than silently overwriting.

## Build Boundary

**MVP:** one Calibre or KOReader adapter, folder watcher, stable book identity, deduplication, and Markdown output.

**Later:** more reader adapters, cross-device sync, deep links, annotation colors, reading progress, and a tray UI. Proprietary Kindle cloud extraction is not a reliable official integration boundary; accept user exports/manual files rather than making it core.

## Existing Products, Building Blocks, and Shortcuts

- [Calibre’s viewer](https://manual.calibre-ebook.com/viewer.html) already stores/searches highlights, synchronizes annotations through Content Server, and exposes location URLs. Start by normalizing its exports rather than creating a reader.
- [KOReader](https://github.com/koreader/koreader) exports highlights to Markdown, JSON, HTML, and text, making it the easiest second adapter.
- [EPUB CFI](https://idpf.org/epub/linking/cfi/) provides a standard anchor format, while exact-quote hash plus surrounding context protects against reader/edition differences.
- Readwise is the hosted product benchmark for multi-reader highlight sync. The local shortcut is Calibre/KOReader export → watched folder → one Obsidian note per book, with generated blocks kept separate from commentary.

## Free-First Stack

- **Pipeline:** Python, `zipfile`/XML or EbookLib, SQLite, and filesystem watching.
- **Inputs:** Calibre/KOReader local exports and user-supplied EPUBs.
- **Anchors:** native position, EPUB CFI when available, exact quote hash, and surrounding context.
- **Output:** Markdown with stable block IDs and YAML frontmatter.
- **UI:** none first; optional Tauri tray app for conflicts/import status.
- **Search:** SQLite FTS for quote relocation and duplicate review.

## Clever Hacks and Simpler Alternative

- Begin by applying a consistent template to existing Markdown exports; a normalization script may solve most of the problem.
- Keep immutable source events separate from the editable public book note.
- Identify editions hierarchically; filename alone is never enough.
- On re-import, update only generated source blocks and preserve everything outside them.
- Record adapter capabilities in a matrix so missing timestamps/positions are visible.

## Build Slices

1. Book identity and import-event schema.
2. One adapter and Markdown renderer.
3. Quote relocation and contextual anchors.
4. Deduplication/conflict handling.
5. Second adapter and tray/status UI.

## Battle-Testing Gates

- Re-importing the same export is idempotent.
- Two editions of the same title remain separate.
- User commentary survives regeneration.
- Changed quotes/locations produce conflicts rather than wrong links.
- Backup/restore reproduces import state and notes.

## Product Path

The personal bridge can become an open-source adapter toolkit. Public release concerns about reader formats and redistributed book content are deferred until then; the local build assumes user-provided files.

## Related

- [[Personal Library Website]]
- [[Bionic Reading Trainer]]
- [[Personal Signal Intelligence OS]]
- [[Project Ideas Index]]
