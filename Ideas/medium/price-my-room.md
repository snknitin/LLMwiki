---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: resale intelligence
form_factor:
  - local vision web app
  - inventory dashboard
deployment: local desktop with optional DGX Spark inference
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#22. Price My Room]]"
status: concept
---
# Price My Room

> Convert a room photo into a user-correctable inventory and conservative resale ranges backed by traceable comparable listings.

## Product Outcome

Help someone decide what is worth listing, donating, or keeping. The output is not one magical total: it is item detection, corrections, condition/region assumptions, comparable evidence, value ranges, and confidence.

## User and Core Workflow

Upload one or more room photos, review detected item boxes, merge/delete mistakes, and add brand, model, age, condition, and location. The system searches approved comparable sources or accepts pasted links, normalizes currencies, and calculates a range. The user exports an inventory and action list.

## Demo/Personal V0

Process one desk setup containing ten manually corrected items. Accept three pasted comparable links per item and calculate low/median/high asking-price ranges. Add automatic segmentation only to accelerate cropping.

## Build Boundary

Include photo import, segmentation, correction, item metadata, comparable capture, range calculation, and inventory export. Exclude facial/person analysis, theft identification, insured valuation, autonomous listings, and unsupported “live market” claims.

## Existing Products, Building Blocks, and Shortcuts

- [SAM 2](https://github.com/facebookresearch/sam2) accelerates promptable item segmentation.
- [rembg](https://github.com/danielgatis/rembg) creates clean crops for search and inventory.
- [eBay Browse API](https://developer.ebay.com/api-docs/buy/api-browse.html) can search active listings where approved access exists.
- [eBay Buy API requirements](https://developer.ebay.com/api-docs/buy/buy-requirements.html) explain why pasted comparable links are the reliable V0.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, OpenCV, SAM 2/rembg, a local vision model on DGX Spark when available, and an HTMX canvas for box correction. Python fits vision workflows; human correction prevents detection errors from silently becoming valuations.

## Architecture/Data Model

Store `rooms`, `photos`, `detections`, `items`, `item_attributes`, `comparables`, `markets`, `valuation_versions`, `assumptions`, and `actions`. Each comparable records URL, captured price, currency, location, condition, listing date, and source type.

## Build Slices

1. Photo upload, manual boxes, inventory editor.
2. Comparable-link capture, normalization, range calculator.
3. SAM-assisted crops and suggested labels.
4. Optional approved marketplace adapter and listing-prep export.

## Drawbacks/Concerns/Failure Modes

Occlusion, duplicate items, model misidentification, regional scarcity, and active-listing bias can make totals meaningless. Require corrections, separate asking from sold evidence, show sample sizes, avoid household-level certainty, and protect location metadata.

## Clever Hacks and Simpler Alternative

Start with a “desk drawer” or “camera gear” niche where users photograph items individually. A narrower category produces better matching and can validate whether valuation changes behavior.

## Success Measures

Track item correction rate, comparable coverage, range width, valuation-to-actual-sale error, time to inventory, items listed/donated, and user trust in the evidence.

## Product Path

Personal declutter tool → category-specific resale assistant → marketplace-integrated product. Before external listing data, public inventories, seller accounts, or payments, run [[Scope Expansion Checklist]] for location privacy, marketplace terms, rights, and release duties; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#22. Price My Room]]
- [[Scope Expansion Checklist]]

