---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: ecommerce optimization
form_factor:
  - local audit dashboard
  - product-copy generator
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#29. Shopify Product Page Optimizer]]"
status: concept
---
# Shopify Product Page Optimizer

> Audit one product page and create an evidence-constrained title, bullets, FAQ, trust structure, image brief, and SEO patch—without inventing claims.

## Product Outcome

Give a merchant a prioritized, editable page upgrade package. The output distinguishes missing facts from weak presentation and contains exact proposed field changes that can be copied or later applied through Shopify.

## User and Core Workflow

Import a product URL, HTML, or export and add an approved product-facts sheet. The system extracts current content, checks structure/completeness, identifies unsupported or missing elements, and proposes revised sections. The merchant reviews a side-by-side preview, locks facts, and exports copy plus image tasks.

## Demo/Personal V0

Process five user-owned product pages from saved HTML. Support title, description, bullets, FAQ, SEO title/meta, alt text, and an image checklist. Render a local preview; do not write to Shopify.

## Build Boundary

Include import, product-fact schema, page audit, structured rewrite, preview/diff, image brief, SEO fields, and export. Exclude store write access, fabricated reviews/certifications/scarcity, dynamic pricing, ad generation, and autonomous publishing.

## Existing Products, Building Blocks, and Shortcuts

- Shopify’s [Product object](https://shopify.dev/docs/api/admin-graphql/latest/objects/Product) defines product, media, and SEO data for a later adapter.
- Shopify’s [products query](https://shopify.dev/docs/api/admin-graphql/latest/queries/products) supplies authorized catalog retrieval.
- [Google Merchant product data specification](https://support.google.com/merchants/answer/14779112) provides field-level commerce guidance.
- [Google Merchant image rules](https://support.google.com/merchants/answer/6324350) inform primary and supporting image recommendations.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite/Drizzle, Playwright or Cheerio for owned-page import, Zod fact schemas, and Ollama for constrained rewriting. The shared TS schema can later map directly to Shopify GraphQL fields.

## Architecture/Data Model

Model `stores`, `products`, `source_snapshots`, `approved_facts`, `page_sections`, `audit_findings`, `copy_versions`, `image_tasks`, `seo_fields`, `reviews`, and `exports`. Every generated factual phrase references an approved-fact ID.

## Build Slices

1. Saved HTML/CSV intake, fact editor, current-page extraction.
2. Audit rules, missing-evidence flags, prioritized findings.
3. Constrained rewrite, side-by-side preview, export.
4. Image brief and optional read-only Shopify adapter.

## Drawbacks/Concerns/Failure Modes

Theme markup varies; merchant facts may be incomplete; AI copy can create prohibited claims; SEO advice can become keyword stuffing; and page changes may not improve conversion. Lock claims, validate output against facts, keep observations separate from hypotheses, and recommend measurable tests.

## Clever Hacks and Simpler Alternative

Generate a copy-only patch file with `before`, `after`, `reason`, and `source_fact` for each field. It is easier to review and can later drive either manual edits or an API write.

## Success Measures

Track factual-validation pass rate, merchant edit rate, accepted field changes, missing-information found, time to publish manually, page completeness, and conversion tests launched.

## Product Path

Personal store optimizer → productized audit service → Shopify-connected paid product. Before write access, multi-store accounts, generated assets, or payments, run [[Scope Expansion Checklist]] for commerce claims, store permissions, provider terms, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#29. Shopify Product Page Optimizer]]
- [[Scope Expansion Checklist]]
- [[Product Shot Studio]]
