---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#10. Visual Token Compiler]]"
status: concept
difficulty: medium
priority: p2
category: model tooling
form_factor:
  - desktop tool
  - evaluation dashboard
deployment: local-first
source_ideas:
  - a picture is worth a thousand tokens
tags:
  - multimodal
  - tokens
  - benchmarking
---

# Visual Token Compiler

> A benchmark-driven compiler that converts structured information into text, compact JSON, SVG, raster, or hybrid visual payloads and measures which representation gives a target multimodal model the best cost, accuracy, and auditability.

## Product Outcome

Instead of assuming an image is cheaper or better, provide source content and a task, generate several encodings, count provider/model tokens where possible, run the same questions, and inspect the cost–accuracy frontier. The compiler retains a source map from every rendered region back to the original data.

## Personal V0

- Accept Markdown, a table, or a small dashboard snapshot.
- Produce compact Markdown/JSON, an SVG card layout, raster variants, and a hybrid image-plus-manifest.
- Control font size, density, resolution, tiling, reading order, and semantic grouping.
- Run a fixed evaluation set across one local VLM and one optional paid model.
- Record answer accuracy, citation accuracy, token/usage estimate, latency, and failures.
- OCR round-trip the visual representation and compare it to the source.
- Display Pareto-optimal configurations by task and model.

## Build Boundary

**MVP:** two source types, three representations, one target task, one model, and a reproducible benchmark.

**Later:** provider-specific optimizers, automatic semantic tiling, UI-state capture, prompt-injection checks, and a compiler API. Do not market universal token savings; image tokenization and resolution behavior differ by model and change over time.

## Existing Products, Building Blocks, and Shortcuts

- [Satori](https://github.com/vercel/satori) converts JSX/HTML-like layouts to deterministic SVG; [Playwright screenshots](https://playwright.dev/docs/screenshots) capture browser layouts, and [Sharp](https://sharp.pixelplumbing.com/) or resvg handles raster variants.
- Gemini’s [image understanding/token guidance](https://ai.google.dev/gemini-api/docs/image-understanding) shows why this must be benchmarked: images are tokenized/tiled and denser text is not automatically cheaper.
- Provider token-count endpoints and local OCR/VLMs are existing measurement primitives. The tool’s value is orchestration and a reproducible Pareto report, not a new renderer.
- Simpler alternative: normalize the source to concise Markdown/JSON and measure it first. Use images only for spatial relationships, tables, topology, or UI state that textual serialization destroys.

## Free-First Stack

- **Rendering:** TypeScript, Satori or browser HTML/CSS, Playwright, and Sharp/resvg.
- **Evaluation:** Python harness with typed task/evaluator interfaces.
- **Data:** DuckDB/SQLite for runs and artifacts.
- **Local models:** Ollama/vLLM-compatible vision model for smoke tests.
- **Provider adapters:** `count_tokens`, `run_task`, and usage capture only for bounded comparisons.
- **UI:** static/local dashboard of cost/accuracy/latency.

## Clever Hacks and Simpler Alternative

- First remove boilerplate and duplication from text; concise structured text may beat image compression.
- Emit a dual payload: visual canvas plus compact entity IDs and reading order.
- Tile on semantic boundaries, never arbitrary pixels.
- Preserve source maps so answers can cite an original cell or paragraph.
- Refuse to claim savings until the target model’s current usage report confirms them.

## Build Slices

1. Canonical content IR and source map.
2. Text/JSON/SVG/raster encoders.
3. Task runner and exact-answer/citation evaluators.
4. OCR round-trip and density sweep.
5. Pareto dashboard and provider adapters.

## Battle-Testing Gates

- Fixed evaluation questions are authored independently from the model under test.
- All encodings contain semantically equivalent source content.
- Visual prompt injection and hidden/tiny text are surfaced.
- Repeated runs store model/version and remain comparable.
- Savings are reported only with accuracy and failure rate.

## Product Path

Keep it an internal optimization lab until repeated workloads show material savings or accuracy gains. A later product could be a model-input compiler/evaluator; provider access is the only paid component required for proof.

## Related

- [[Understand This Paper]]
- [[PhoneScan PDF]]
- [[Manga-to-Animatic Studio]]
- [[Project Ideas Index]]
