---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Creator Growth and Local Video Pipelines#1. Meta Ad Creative Studio]]"
status: concept
difficulty: hard
priority: p1
category: paid creative experimentation
form_factor:
  - local creative dashboard
  - media generation workflow
deployment: desktop plus local and hosted render adapters
source_ideas:
  - AI ads for Meta using Claude design direction and Higgsfield
tags:
  - meta-ads
  - creative-testing
  - design
  - video
  - experiments
---

# Meta Ad Creative Studio

> Turn a product’s evidence, audience, offer, and brand system into intentionally different Meta ad concepts, exportable creative packs, and a learning loop that joins actual results back to the hypothesis that produced each asset.

## Product Outcome

The studio does not try to predict a winning ad from an LLM opinion. It makes disciplined creative testing cheap. For each test it records audience, problem, promise, proof, concept, hook, format, CTA, assets, and exactly what changed. It produces storyboards, copy, images/videos, placement-ready exports, contact sheets, and an analysis view organized by concept rather than opaque filenames.

This remains separate from [[Demand Generation Workbench]], which decides which audience/problem/offer deserves a test. It can use [[Local Video Generation Evaluation Lab]] and Higgsfield as interchangeable renderers.

## Personal V0

1. Choose one real tool and create an approved product-evidence sheet: capabilities, proof assets, claims, audience, offer, and objections.
2. Generate three distinct concepts, each using a different visual mechanism and value proposition.
3. For one concept, produce three hooks while keeping all other variables fixed.
4. Create storyboard, primary copy, headline, CTA, source-assets list, and `changed_variable` metadata.
5. Render static cards and simple screen-demo videos locally; optionally render one hosted Higgsfield variant.
6. Export a folder/manifest ready for manual Ads Manager upload.
7. Import results CSV and compare by hypothesis, concept, hook, placement, spend, and sample size.

## Build Boundary

**MVP:** product/brand evidence library, concept matrix, structured briefs, static/demo renderers, asset QA, export packs, and result import.

**Later:** Meta Marketing API publishing, automated placement variants, hosted/local generative video adapters, creative fatigue tracking, and portfolio-wide experiment comparison.

Do not rebuild every crop and generic copy variation already offered by Meta. The valuable layer is product truth, concept diversity, lineage, and learning.

## Existing Products, Building Blocks, and Shortcuts

- Meta [Advantage+ creative](https://www.facebook.com/business/ads/meta-advantage-plus/creative) already handles text variants, expansion, backgrounds, animation, music, and some placement adaptation; use it instead of duplicating commodity transformations.
- Meta’s [ad creative guidance](https://www.facebook.com/business/ads/ad-creative) and [performance guidance](https://www.facebook.com/business/ads/performance-marketing) are the baseline for placement and creative-diversification checks.
- The official [Meta Python Business SDK](https://github.com/facebook/facebook-python-business-sdk) can later create/read campaign and creative objects with approved account permissions.
- Anthropic’s [frontend-design skill](https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md) is a useful art-direction/critique pattern: deliberate typography, composition, color, and concept rather than generic “AI design.”
- The [Higgsfield CLI](https://github.com/higgsfield-ai/cli) is a hosted asynchronous renderer. Installing its CLI on Windows does not run Higgsfield, Hailuo, Veo, or Kling on the local RTX GPU.
- HTML/CSS + Playwright screenshots, SVG/Satori, FFmpeg, and Remotion cover reproducible local static and simple motion ads.

## Recommended Free-First Stack

- SvelteKit/Next.js local creative board with SQLite.
- Markdown/YAML product and brand records with immutable proof IDs.
- Local/paid text model behind one adapter for concept generation and critique.
- HTML/CSS/Playwright or Satori/resvg for cards; FFmpeg/Remotion for screen demos.
- Optional ComfyUI worker selected by [[Local Video Generation Evaluation Lab]].
- Optional Higgsfield CLI adapter with polling, cost/credit fields, and returned-asset hashes.
- Manual Ads Manager upload and CSV result import before Marketing API integration.

## Creative Data Model

`ProductClaim` references evidence. `CreativeHypothesis` owns audience, problem, promise, mechanism, changed variable, and decision rule. `CreativeConcept` owns art direction, hook family, storyboard, and source assets. `RenderedVariant` records renderer/model/version/prompt/config and placement. `CampaignObservation` stores spend, impressions, clicks, conversion event, date window, and Meta automation settings. `CreativeDecision` records continue/revise/stop.

## Build Slices

1. Product evidence and brand-token schemas.
2. Hypothesis/concept matrix and review board.
3. Static renderer, contact sheet, and manifest.
4. Screen-demo video templates and placement encoding.
5. Higgsfield/local-video adapter interface.
6. Results importer and concept-aware analysis.
7. Optional Marketing API publishing with dry run.

## Drawbacks, Concerns, and Failure Modes

- Dozens of near-duplicates create false experimentation. Cluster by mechanism and require declared changed variables.
- Meta may transform assets during delivery. Record which Advantage+ features were enabled.
- Small campaigns cannot identify tiny performance differences. Show raw denominators and uncertainty.
- Aesthetic critique is not a performance predictor. Use it for coherence, not expected return.
- Generated claims can outpace product truth. Block any claim without a proof ID.
- Hosted renderer behavior changes over time. Store provider model label, date, request, and result hash.

## Clever Hacks and Simpler Alternative

- Stop at brief + storyboard + contact sheet and assemble manually until rendering is the bottleneck.
- Maintain an annotated swipe file by visual mechanism and “why it works,” not only screenshots.
- Test concept diversity before hook variants.
- Use one product screen recording and template-driven overlays for the first ten ads.
- Ask Meta to handle placement adaptations while the studio tracks the conceptual source.

## Success Measures

- Every asset maps to an audience, hypothesis, proof, and changed variable.
- Time from product brief to reviewable test pack declines.
- Creative concepts are meaningfully distinct under blind review.
- Result imports correctly join spend/outcomes to concept lineage.
- The studio generates actionable continue/revise/stop decisions instead of merely more assets.

## Product Path

Personal creative workbench -> reusable studio for all personal projects -> client creative-testing service -> paid creative operations product. Run [[Scope Expansion Checklist]] before commercial ad operation; retain the local evidence and lineage model.

## Related

- [[Demand Generation Workbench]]
- [[Local Video Generation Evaluation Lab]]
- [[Auto-GTM Engine]]
- [[Longform-to-Shorts Studio]]
- [[Creator Content Engine]]
- [[Project Ideas Index]]

