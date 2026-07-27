---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: private media search
form_factor:
  - event gallery web app
  - messaging concierge
deployment: photographer-controlled local server with optional private event portal
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#28. Wedding Gallery Concierge]]"
status: concept
tags:
  - photography
  - semantic-search
  - privacy
---

# Wedding Gallery Concierge

> A private, event-scoped photo search concierge that lets authorized guests describe a moment and returns ranked candidates from the photographer’s delivered gallery.

## Product Outcome

Help couples and guests find meaningful photos across thousands of delivered images without creating a public face-surveillance database. The photographer controls ingestion and event access; visual/text embeddings remain event-scoped; users receive short-lived result links.

## User and Core Workflow

1. Photographer creates an event and imports a delivered, watermarked gallery.
2. The system extracts safe metadata, builds thumbnails, and computes visual/text embeddings locally.
3. Couple configures event vocabulary, people labels if explicitly consented, access policy, expiry, and download limits.
4. Guest authenticates with an event code or invited identity and types a request.
5. Hybrid search ranks semantic image matches, metadata, captions, and optional approved tags.
6. Guest refines or selects results; the system records feedback without cross-event profiling.
7. Photographer can audit, revoke, expire, and delete the event index.

## Demo/Personal V0

Use 200 user-owned or Creative Commons event photos with no face recognition. Build local OpenCLIP embeddings, text search, filters, thumbnails, and a private result page. Demonstrate prompts about scenes, colors, objects, and ceremony moments.

## Build Boundary

- In scope: authorized delivered photos, event-scoped semantic search, metadata filters, manual tags, access controls, watermarked previews, and deletion.
- Out of scope: public web indexing, cross-event person tracking, scraping cloud galleries, training on client photos, automatic identity claims, or distributing originals without photographer policy.
- Face recognition is excluded from V0; any later person-label workflow requires explicit consent and stronger governance.
- Strip location/device metadata from guest-facing derivatives.

## Existing Products, Building Blocks, and Shortcuts

- [Immich](https://github.com/immich-app/immich) demonstrates a strong self-hosted photo-management and search foundation; integrating or studying it may beat rebuilding gallery infrastructure.
- [OpenCLIP](https://github.com/mlfoundations/open_clip) provides local text-image embeddings for natural-language retrieval.
- [Qdrant](https://qdrant.tech/documentation/quickstart/) offers filtered vector search when an in-process index is no longer sufficient.
- [ExifTool](https://exiftool.org/) can inspect and remove sensitive camera/GPS metadata from derivatives.
- [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api/) can become a future query/delivery channel while the actual gallery remains behind private links.

## Recommended Free-First Stack

- Python, FastAPI, Pydantic, SQLite, OpenCLIP, and FAISS or hnswlib for a single event.
- Pillow/Sharp for thumbnails, watermarks, orientation, and metadata stripping.
- A simple responsive server-rendered gallery with signed, short-lived asset URLs.
- Local object storage on encrypted disk; event-specific embedding indexes and keys.
- Playwright tests for invite, expiration, unauthorized access, search, revoke, and delete.

For V0, local embeddings and an event code are sufficient; Qdrant and messaging APIs are optional scaling layers.

## Architecture/Data Model

`photographer` owns `event`, `asset`, `derivative`, `embedding`, `caption`, `tag`, `invitation`, `guest_session`, `query`, `result`, `feedback`, `access_event`, and `deletion_job`. Every vector and derivative carries an event ID; queries can never span event partitions. Originals stay separate from guest-facing previews.

## Build Slices

1. Folder import, hashing, metadata sanitation, thumbnails, and gallery viewer.
2. OpenCLIP embedding/index pipeline and natural-language result ranking.
3. Event vocabulary, manual tags, filters, and relevance feedback.
4. Private invitations, signed links, watermark/download policies, audit/revoke/delete.
5. Optional messaging concierge, photographer billing, and gallery-provider adapters.

## Drawbacks, Concerns, and Failure Modes

- Embeddings can misunderstand culturally specific clothing, rituals, and relationships.
- Similar scenes produce plausible but wrong matches and user disappointment.
- Wedding photos are intimate; access leakage or persistent links are high-impact.
- Face identification introduces biometric/privacy obligations and bias.
- Large RAW/JPEG galleries require storage, GPU time, deduplication, and careful backups.

## Clever Hacks and Simpler Alternative

- Ask the photographer/couple for a 20-word event vocabulary before indexing.
- Use a two-stage search: embedding top 100, then metadata/tags and optional reranking.
- Return candidate sets with easy refinement instead of claiming one exact answer.
- Keep only watermarked previews online; deliver purchased originals through existing gallery tooling.
- Simplest alternative: a local semantic-search desktop tool used only by the photographer to manually send selections.

## Success Measures

- Target photos appear in the top 20 for a curated query benchmark.
- No test query crosses event boundaries and expired links fail reliably.
- All guest-facing files have sensitive metadata removed.
- The photographer can fully revoke and delete an event index.
- Search reduces manual browsing time while relevance feedback trends upward.

## Product Path

Start as a photographer-only local search tool, then pilot private event portals. Revenue could be per event, photographer subscription, or a premium couple add-on. A production service needs explicit photo/biometric consent rules, strong access controls, storage lifecycle guarantees, gallery-provider terms, and incident response.

## Related

- [[Creator Content Engine]]
- [[Field Pokedex]]
- [[WhatsApp Catalog Bot for Small Stores]]
