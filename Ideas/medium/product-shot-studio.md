---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: commerce creative
form_factor:
  - local image workflow
  - seller review dashboard
deployment: local desktop with DGX Spark option
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#23. Product Shot Studio]]"
status: concept
---
# Product Shot Studio

> Turn a seller’s phone photo into a consistent, reviewable product pack: clean cutout, listing image, lifestyle variants, ad layouts, and copy.

## Product Outcome

Produce useful commerce assets in minutes while preserving the real product’s geometry, color, labels, and included parts. The seller approves each image and receives platform-ready files plus a generation record.

## User and Core Workflow

Upload several product photos and enter factual product details. The system checks framing and resolution, isolates the object, creates a deterministic white-background listing image, then offers template and optional generative lifestyle scenes. Copy is generated only from approved facts; the seller compares and exports.

## Demo/Personal V0

Support one product pack: main square listing image, two fixed template scenes, one 4:5 ad, title, five bullets, and alt text. Run background removal locally and require manual mask/color correction before generative steps.

## Build Boundary

Include intake QA, background removal, mask editor, templates, optional generated backgrounds, copy, export presets, and approval. Exclude modifying product features, fake endorsements, autonomous store publishing, bulk catalogs, and unsupported claims.

## Existing Products, Building Blocks, and Shortcuts

- [rembg](https://github.com/danielgatis/rembg) supplies local background removal via CLI/API.
- [SAM 2](https://github.com/facebookresearch/sam2) improves promptable product segmentation.
- [ComfyUI](https://github.com/comfy-org/comfyui) provides reusable local node-graph generation workflows.
- [Google Merchant image rules](https://support.google.com/merchants/answer/6324350) guide clean primary-image output.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, Pillow/OpenCV, rembg/SAM 2, ComfyUI on the workstation or DGX Spark, SQLite, and a React canvas editor. Deterministic image operations run first; generation is optional and isolated so product fidelity can be inspected.

## Architecture/Data Model

Model `products`, `approved_facts`, `source_images`, `masks`, `workflow_versions`, `renders`, `templates`, `copy_versions`, `reviews`, and `export_presets`. Preserve originals and transformation parameters; never overwrite source images.

## Build Slices

1. Upload QA, cutout, mask correction, white-background export.
2. Template studio, resize presets, factual copy.
3. ComfyUI lifestyle workflow with side-by-side review.
4. Pack export, reproducibility metadata, and batch queue.

## Drawbacks/Concerns/Failure Modes

Segmentation can clip products; generation can alter logos or shape; color shifts cause returns; and platform rules vary. Provide zoom/diff, lock product pixels where possible, include color reference, separate main images from ads, and require seller approval.

## Clever Hacks and Simpler Alternative

Skip generative lifestyle scenes initially. A high-quality cutout plus five branded SVG/CSS templates is faster, cheaper, consistent, and often enough for marketplace sellers.

## Success Measures

Track mask correction time, product-fidelity rejection rate, pack completion time, export usage, seller edits, repeated workflows, and downstream listing/creative adoption.

## Product Path

Personal seller studio → productized creative service → paid commerce asset platform. Before customer uploads, model APIs, store publishing, or payments, run [[Scope Expansion Checklist]] for image rights, model terms, marketplace rules, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#23. Product Shot Studio]]
- [[Scope Expansion Checklist]]
- [[Shopify Product Page Optimizer]]

