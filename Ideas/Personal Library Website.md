---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#15. Personal Library Website]]"
status: concept
difficulty: easy
priority: p1
category: personal publishing
form_factor:
  - static website
deployment: static hosting
source_ideas:
  - personal website revamp with a springtexts-like book catalog using Goodreads lists and AI-edited reviews
tags:
  - books
  - personal-website
  - reviews
  - creator
---

# Personal Library Website

> A book-led personal website where a browsable library, reading history, original reviews, annotations, and thematic trails become the spine of a public intellectual portfolio.

## Product Outcome

Visitors can browse books by topic, year, status, rating, influence, and project connection. Each book page combines factual metadata with clearly personal notes and links to essays or ideas it influenced. AI may edit the user’s own writing but should not fabricate opinions.

## Personal V0

- Import a user-provided Goodreads/library CSV or maintain books as Markdown.
- Normalize title, author, edition, identifiers, dates, shelves, rating, and user review.
- Build catalog, search, filters, book detail, reading timeline, and “related ideas.”
- Preserve the original review and show an approved edited public version.
- Generate thematic shelves and reading paths from manually reviewed tags.
- Link books to project specs and blog posts using Obsidian wikilink-derived relationships.
- Export the entire site as static files.

## Build Boundary

**MVP:** one import, static catalog, full-text search, book pages, and approved reviews.

**Later:** recommendations, newsletters, reading statistics, public annotations, gift shelves, and community features. Use the user’s export/local data now; run the deferred release audit before publishing third-party metadata or imagery broadly.

## Existing Products, Building Blocks, and Shortcuts

- Goodreads exports provide the personal reading dataset, while [Open Library APIs](https://openlibrary.org/developers/api) can resolve ISBNs, editions, covers, and authors. Manual corrections remain authoritative.
- [Astro](https://docs.astro.build/) is designed for content-heavy static sites, and [Pagefind](https://pagefind.app/) adds static full-text search without a backend.
- Hardcover, Oku, The StoryGraph, and Goodreads are product references for catalog/timeline/recommendation UX. Your site differentiates through original reviews, project links, thematic trails, and owned static output.
- Simplest alternative: CSV → generated Markdown/JSON → Astro catalog. Use text-only CSS book spines when cover metadata is messy.

## Free-First Stack

- **Site:** Astro for a content-heavy static build, or SvelteKit/Next.js static export.
- **Content:** Markdown/MDX plus generated JSON.
- **Search:** Pagefind or a small client-side index.
- **Metadata:** ISBN/Open Library or other sources only under their current usage/licensing terms; manual correction is authoritative.
- **Images:** user-owned photos, permitted covers, or tasteful text-only placeholders.
- **AI:** local model for copyediting and tag suggestions with diff approval.
- **Hosting:** GitHub Pages/Cloudflare Pages or another free static host.

## Clever Hacks and Simpler Alternative

- Start from exported CSV and a single static template; no database, auth, or CMS.
- Use book-spine CSS cards when cover rights or metadata are messy.
- Turn each thematic shelf into an essay outline, making the library a creator-content engine.
- Keep `original_review` and `published_review` separate with an edit diff.
- Generate RSS for new reviews and a “currently reading” widget.

## Build Slices

1. Import/normalization and data validation.
2. Catalog, filters, and detail pages.
3. Search and related-idea links.
4. Review-edit approval workflow.
5. Thematic trails and RSS.

## Success Measures

- Every book maps to the correct edition or is visibly unresolved.
- Re-import does not overwrite manual corrections or published prose.
- The static site builds reproducibly with no secret data.
- Visitors reach projects/essays through books.

## Product Path

The website is primarily a personal brand and content flywheel. Reusable themes, a local Goodreads-to-static-site compiler, or premium book-catalog templates could later become products.

## Related

- [[GiftShelf]]
- [[Creator Content Engine]]
- [[EPUB Highlights Bridge]]
- [[Jobs Search and Apply Tool]]
- [[Project Ideas Index]]
