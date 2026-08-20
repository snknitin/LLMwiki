---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Visual Recipe Notation and Recipe Library#1. Visual Recipe Book]]"
status: concept
difficulty: medium
priority: p1
category: recipe capture and visual cooking
form_factor:
  - mobile-first PWA
  - personal recipe library
  - share-image generator
deployment: local-first then optional hosted sync
source_ideas:
  - convert recipe text URLs and images into compact tabular recipe notation
  - collect themed personal cookbooks and share instantly readable recipe cards
tags:
  - recipes
  - visualization
  - OCR
  - PWA
  - cookbook
  - sharing
---

# Visual Recipe Book

> Capture a recipe from a blog, pasted text, screenshot, photo, or phone share sheet; turn it into a verified ingredient-flow diagram; and keep the result in a beautiful personal cookbook that is faster to cook from and easier to share than the source page.

## Product Outcome

Build a personal recipe inbox, compiler, and visual library. The app removes article clutter, preserves the source, extracts a structured recipe, asks the user to resolve dangerous ambiguities, and renders the result as a compact operation diagram. A saved recipe becomes three synchronized views over the same data:

1. **Visual card:** a square or portrait infographic for rapid understanding and social sharing.
2. **Cook mode:** a large, touch-friendly, wake-lock-enabled view with timers, quantities, cues, and the current dependency path.
3. **Canonical recipe:** complete ingredients, instructions, notes, provenance, alternatives, and user corrections without visual compression.

The key product is not merely “summarize a recipe with AI.” It is a trustworthy personal collection in which each recipe is represented as an executable cooking graph. Rendering, scaling, search, timers, grocery exports, and future formats should all compile from that one reviewed representation.

## What the Diagram Is Called

The attached Espresso Brownies image is a **recipe summary table** in **Tabular Recipe Notation (TRN)**, terminology used by Michael Chu for the diagrams on Cooking for Engineers. Chu described the shorthand as ingredients on the left and operations arranged through merged cells to the right. The exact example is the [Cooking for Engineers Espresso Brownies recipe](https://www.cookingforengineers.com/recipe/327/Espresso-Brownies/print), and the terminology is documented in this [interview with Chu](https://coolinfographics.squarespace.com/blog/2010/4/26/cooking-for-engineersrecipe-infographics-and-interview.html).

The market gainers-and-losers image the idea recalls is a **treemap**, often presented as a stock-market heatmap. The resemblance is real—both fill a rectangle with nested cells—but the encoding is different:

- A treemap uses **area** to encode a quantitative value such as market capitalization.
- TRN uses **rows, merged spans, and left-to-right nesting** to encode ingredients, grouping, sequence, and dependency.
- It is not a Sankey diagram because band width does not encode flow quantity.
- It is not a conventional Gantt chart because horizontal width does not necessarily encode elapsed time.
- It is not merely a flowchart because the table alignment lets one see exactly which ingredients and intermediate mixtures feed each operation without a forest of arrows.

A precise product description is therefore: **a tabular recipe notation compiler and visual cookbook, powered by an ingredient-operation dependency graph**. “Recipe heatmap” can remain a friendly marketing phrase, but should not define the internal representation.

## Visual Grammar

The renderer should follow a documented grammar so the result is readable because of consistent rules, not because a model improvised a pretty image:

- Ingredients are leaf inputs, normally listed as rows on the left with original and normalized quantities.
- An action cell spans the consecutive inputs it consumes: `melt` spans butter; `mix` spans butter, sugar, vanilla, and coffee; a later `mix` absorbs eggs; `fold` combines wet and dry branches.
- Each action produces a named intermediate such as `melted butter`, `wet mixture`, `dry mix`, `batter`, or `sauce` even when the compact view hides that label.
- Progression moves left to right. Later columns consume the outputs of earlier columns.
- Global preparation steps such as preheating or preparing a pan occupy full-width header bands when they are not tied to one ingredient branch.
- Temperature, active duration, passive duration, and doneness cues belong to the operation they constrain. “Bake at 170°C for 30–40 minutes, until…” must remain one inspectable semantic unit.
- Parallel branches remain visibly separate until the operation that joins them. A sauce and pasta cooking at the same time should not be flattened into a false linear sequence.
- Optional ingredients, divided quantities, substitutes, garnishes, and “reserve some for later” need explicit visual markers rather than silent omission.
- Color may encode action class—prep, heat, rest, combine, finish—but meaning must also survive grayscale, high-contrast mode, and color-vision differences.

The compact card should never be the only representation. Simple recipes can fit one square; complex recipes need a portrait card, multiple panels, or a scrollable diagram. Legibility takes priority over forcing every dish into a social-media square.

## Personal V0

Prove the full loop with twenty-five recipes that the user actually cooks:

- Import a recipe URL, paste recipe text, or upload a clean screenshot/photo.
- Save an immutable source snapshot, title, author/site, capture time, and source URL before transformation.
- Prefer embedded Recipe JSON-LD for blogs that provide it; fall back to page extraction and OCR only when needed.
- Normalize ingredients and instructions into a typed recipe graph.
- Show a short review screen for amounts, divided ingredients, temperatures, times, doneness cues, parallel work, and which ingredients feed each action.
- Reject cycles, orphaned ingredients, orphaned steps, missing outputs, and unsupported references such as “add the remaining mixture” until resolved.
- Render a canonical SVG and export PNG for sharing.
- Save the recipe into local cookbooks with tags, favorites, cuisine, meal, dietary notes, difficulty, and personal changes.
- Provide a distraction-free cook mode with screen wake lock, scalable servings, individual timers, and one-tap access to the original wording.

The V0 succeeds when importing, correcting, retrieving, cooking, and sharing feel easier than keeping browser bookmarks—not when every recipe on the internet parses automatically.

## Capture and Review Workflow

1. **Receive:** URL, pasted text, image, PDF page, or installed-PWA/native share action enters a local inbox.
2. **Preserve:** hash and retain the raw input, relevant page snapshot, source metadata, and any detected structured data.
3. **Extract deterministically:** read Recipe JSON-LD, headings, lists, units, times, temperatures, and known instruction structure before calling a model.
4. **OCR when required:** correct rotation, crop, contrast, fractions, degree symbols, and line order; retain OCR confidence and bounding boxes.
5. **Build the graph:** map each instruction to typed operations, material inputs, equipment, timing constraints, and named outputs. Use a model only for unresolved references and semantic grouping.
6. **Validate:** detect cycles, unreachable operations, unused ingredients, missing quantities, conflicting temperatures, order violations, and implausible conversions.
7. **Review:** highlight only uncertain or safety-critical fields, show the supporting source fragment, and let the user connect or split cells directly.
8. **Compile:** generate visual card, canonical reading view, cook mode, search record, and portable structured export.
9. **Learn locally:** store corrections as recipe-specific patches and anonymized parsing fixtures; never silently rewrite already approved recipes after a model update.

The review screen is part of the product, not an admission of failure. Recipe language contains implicit references—“the rest,” “until ready,” “prepare as before”—that should not be guessed invisibly when the output will guide a real cooking session.

## Build Boundary

**MVP:** responsive local web app/PWA; URL, paste, and image import; structured extraction; graph review; SVG/PNG rendering; local search and cookbooks; cook mode; timers; source provenance; export/import backup.

**Later:** native Android and iOS share extensions, handwriting-specific OCR, multi-device private sync, family cookbooks, pantry and shopping-list connections, nutrition calculation, meal planning, creator pages, collaborative annotations, public sharing, and commercial themes.

Do not begin with a social network, grocery-delivery integration, nutritional medical advice, full pantry management, or universal autonomous scraping. Those are separate product jobs. The personal library and trustworthy compile path must work first.

## Existing Products, Building Blocks, and Shortcuts

- [Cooking for Engineers](https://www.cookingforengineers.com/article/138/About-Cooking-For-Engineers) is the lineage of the attached design. Its [Espresso Brownies summary](https://www.cookingforengineers.com/recipe/327/Espresso-Brownies/print) is the exact visual reference, and Michael Chu calls the format recipe summary tables or Tabular Recipe Notation in this [documented interview](https://coolinfographics.squarespace.com/blog/2010/4/26/cooking-for-engineersrecipe-infographics-and-interview.html).
- [Tabular Recipe](https://tabularrecipe.com/) is an unusually close current implementation: it converts pasted recipes into an operation graph and compact table, exposes multiple styles, calculates time/equipment, and offers an API, MCP interface, self-contained HTML, and an open `rgf/0-draft` format. The simplest V0 is to test its converter or reuse its open schema/layout components while this project concentrates on capture, review, personal cookbooks, cook mode, provenance, and share workflows.
- [Mealie](https://github.com/mealie-recipes/mealie) is a mature self-hosted recipe manager with URL import, manual entry, cookbooks, meal plans, shopping lists, and an API. It proves much of the library layer and could be used as the storage backend or benchmark rather than rebuilt immediately. Its discussion of [image/OCR import](https://github.com/mealie-recipes/mealie/discussions/660) is also a warning that OCR maintenance and correction UX are real product work.
- Google's official [Recipe structured-data documentation](https://developers.google.com/search/docs/appearance/structured-data/recipe) describes the Recipe, HowToStep, HowToSection, ingredient, instruction, and time fields already embedded in many food pages. Parse this before using browser automation or an LLM.
- [recipe-scrapers](https://github.com/hhursev/recipe-scrapers) extracts recipe fields from supported websites and is already used by recipe-management projects. Keep a generic JSON-LD path so new sites do not always require custom scrapers.
- [Cooklang](https://github.com/cooklang/spec) provides a human-readable, machine-processable recipe notation for ingredients, cookware, timers, and metadata. A Cooklang import/export adapter gives the library a portable source format even though its syntax is not the visual layout.
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) is the free local fallback for printed cards and screenshots. Treat it as a text proposal with bounding boxes and confidence, not truth—fractions, units, superscripts, and multi-column layouts need review.
- [Android's receive-simple-data flow](https://developer.android.com/training/sharing/receive) supports text and image input through the system Sharesheet. An installed PWA can declare a [Web Share Target](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Manifest/Reference/share_target), but support is not universal; an [iOS Share Extension](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html) or native wrapper is the reliable later path.
- [YumML](https://gist.github.com/magarcia/5897a8078a0e816df04eb7b56f026b02) is useful prior art for modeling recipes as graphs with parallel branches. It reinforces the decision to separate the semantic recipe graph from any one rendering style.

## Recommended Free-First Stack

- **Web/PWA:** React, TypeScript, and Vite PWA for a fast responsive interface, Tailwind or ordinary CSS tokens for the kitchen theme, and Workbox/service-worker primitives for offline use. This choice also leaves a familiar path to a later React Native/Expo client; the data model matters more than the framework.
- **Local service:** Python 3.12 with FastAPI and Pydantic because the recipe extraction, OCR, text-processing, and evaluation ecosystem is strongest there. Package it as one local process and keep the UI usable without cloud accounts.
- **Storage:** SQLite for approved recipes, graphs, tags, cookbooks, corrections, and manifests; filesystem/object folder for source snapshots and renders; FTS5 for local search. Use schema migrations from the first saved recipe.
- **URL extraction:** JSON-LD and Microdata parser first, `recipe-scrapers` second, readability/DOM cleanup third. Browser automation is a last fallback because it is slower and more brittle.
- **OCR:** OpenCV preprocessing plus Tesseract for printed text. Add a local vision model or paid OCR provider only for a measured set of failures, behind the same adapter and confidence contract.
- **Language model:** a local instruction/vision model through an OpenAI-compatible Ollama or vLLM endpoint for operation linking and ambiguity proposals. Paid models may be benchmarked behind the same adapter; no provider should write directly to approved records.
- **Canonical model:** Pydantic/JSON Schema for a recipe graph, plus Cooklang and Recipe JSON-LD import/export adapters. Version both the schema and parser manifest.
- **Renderer:** deterministic SVG generated from the graph using CSS Grid-like layout rules, a small custom layerer, or reused Tabular Recipe layout code. SVG is canonical because text stays sharp and editable; use resvg or Sharp for PNG thumbnails and social cards, and browser print styles for PDF.
- **Mobile capture:** begin with PWA file/URL import and Android Web Share Target if supported on the user's phone. Move to Capacitor or a thin native shell only when share-receiver and background-file limitations are the proven bottleneck.
- **Testing:** pytest and property tests for graph validation; Vitest for UI/model contracts; Playwright for import/review/cook flows; pixel-diff and OCR-back tests for exported cards.
- **Observability:** local structured logs plus a parsing scorecard. Store input hash, extractor, model/prompt version, validator results, corrections, render version, latency, and optional model cost for every import.

## Architecture and Data Model

The semantic core is a directed acyclic material-and-operation graph, not an image.

- `Recipe` owns identity, title, yield, language, cuisines, tags, notes, approved revision, and source references.
- `SourceSnapshot` stores URL or file identity, capture time, content hash, raw structured data, original text/image, extraction method, and provenance offsets.
- `Ingredient` stores canonical name, original phrase, quantity interval, unit, preparation state, optionality, alternatives, allergens, and provenance.
- `Equipment` records vessel/tool identity, size, capacity, preparation, and whether it can be reused concurrently.
- `Operation` stores verb, human instruction, active/passive/blocking time, temperature, equipment, doneness cue, safety note, and provenance.
- `MaterialEdge` connects an ingredient or intermediate output to an operation with amount, division/reservation, ordering, and confidence.
- `Intermediate` names the result of an operation so later phrases such as “add the wet mixture” resolve explicitly.
- `Constraint` represents dependency, parallel eligibility, rest/chill/marinate window, preheat lead time, deadline, and serving order.
- `Cookbook` groups recipes and owns cover, kitchen theme, sort order, tags, and share/export settings.
- `RenderPreset` defines dimensions, typography, palette, density, abbreviations, pagination, and accessibility rules—never recipe truth.
- `Correction` stores proposed value, approved value, supporting source fragment, parser/model version, reason, and time.
- `RecipeRevision` freezes the complete graph and source hashes used for a cooking session or shared card.

Derived views—TRN, chronological checklist, critical-path timeline, grocery list, Cooklang file, Recipe JSON-LD, PNG, and printable page—compile from a pinned `RecipeRevision`. Editing a generated SVG must not create a second hidden source of truth.

## Layout and Rendering Rules

1. Topologically sort operations while preserving source order as a tie-breaker.
2. Place ingredient leaves in stable source order, then minimize crossings by grouping inputs that share their earliest consumer.
3. Assign one layer/column per dependency stage; allow parallel operations in the same layer.
4. Make an operation cell span exactly the vertical range of materials it consumes. When consumers are non-contiguous, insert a named intermediate lane rather than drawing a misleading giant span.
5. Keep action labels short in the card, with amount/time/temperature and sensory cues available in expanded or footnote form.
6. Detect overflow before export. Increase canvas height, split panels at stable intermediates, or switch to landscape; never shrink text below the preset's legibility floor.
7. Provide two optional modes: **compact dependency mode**, faithful to TRN, and **timeline mode**, where width genuinely represents active/passive time. Do not imply time through width in one mode and deny it in another.
8. Render with deterministic fonts, line breaking, and versioned presets so the same revision can be reproduced.

Kitchen themes should live in the surrounding bookshelf, cookbook covers, borders, and palette. The cooking information itself should remain high-contrast, sparse, and printable.

## Build Slices

1. **Notation spike:** hand-model five recipes as graphs and render faithful monochrome TRN SVGs, including a branched sauce, dough/rest, and multi-component meal.
2. **URL import:** Recipe JSON-LD ingestion, raw snapshot, canonical recipe view, and provenance links.
3. **Graph editor:** ingredient rows, draggable operation spans, split/merge, intermediate naming, validator, and revision approval.
4. **Compiler:** deterministic compact SVG, portrait/landscape overflow rules, PNG export, print view, and visual regression corpus.
5. **Personal library:** inbox, cookbooks, covers/themes, tags, favorites, local search, source/version history, backup and restore.
6. **Cook mode:** servings scaling, original-versus-normalized units, large current step, parallel path, timers, wake lock, and hands-dirty controls.
7. **Text and OCR fallback:** cleaned pasted text, screenshot/photo preprocessing, confidence overlays, source-linked correction queue.
8. **Model-assisted linking:** ambiguous references, operation grouping, intermediate naming, and uncertainty calibration; deterministic validators remain authoritative.
9. **Phone capture:** installed-PWA Android share target, then a native wrapper/extension only if actual use shows that is necessary.
10. **Battle test:** import and cook a balanced gold set, record corrections and cooking failures, then harden the largest failure clusters before expanding features.

## Drawbacks, Concerns, and Failure Modes

- **Dangerous confident extraction:** swapping teaspoons and tablespoons, losing “divided,” changing temperature units, or connecting an ingredient to the wrong step can ruin food. Preserve evidence, validate, and require review of low-confidence or critical fields.
- **Implicit material state:** recipes routinely say “add the remaining,” “return to the pan,” “repeat,” or “prepare as directed.” Without explicit intermediates and reservations, a diagram can look clean while being wrong.
- **False linearity:** sauces, marinades, proofing, preheating, chilling, and resting happen in parallel or over long windows. A flat row of steps hides the schedule that matters most.
- **Compression loss:** sensory cues, explanations, substitutions, food-safety notes, and equipment details may not fit a card. Keep them one tap away and mark omitted detail instead of silently deleting it.
- **Square-card pressure:** forcing a complex biryani, layer cake, or multi-component dinner into one square produces microscopic type. Use multiple cards or an adaptive canvas.
- **Unit-conversion traps:** volume-to-weight conversions are ingredient- and packing-specific; °F/°C conversion is safe, but “one cup flour” cannot use a universal mass. Store the original and attach conversions to sourced ingredient profiles.
- **Scaling is not always linear:** pan geometry, yeast, salt, leavening, cooking time, and evaporation may not scale with servings. Show arithmetic scaling as a proposal and preserve the original yield.
- **OCR brittleness:** `1/2`, `1½`, `1 1/2`, degree symbols, line wrapping, stains, handwriting, and multi-column cards generate plausible errors. Image imports need bounding-box review.
- **Scraping brittleness:** paywalls, dynamic pages, anti-bot controls, and malformed JSON-LD will break adapters. Paste and screenshot import remain first-class escape hatches.
- **Layout complexity:** merged-cell diagrams become difficult when an operation consumes distant branches. The semantic graph should remain valid even when the renderer falls back to connectors or multiple panels.
- **Hands-dirty ergonomics:** tiny tap targets, screen sleep, accidental navigation, and repeated scrolling destroy usefulness in the kitchen. Test while actually cooking, not only at a desk.
- **Library lock-in:** a beautiful database is still a trap if it cannot export. Preserve raw sources and support portable JSON/Cooklang/HTML bundles from V0.
- **Model drift:** a later model or prompt can parse the same recipe differently. Never mutate an approved revision automatically; compare and request reapproval.

For the current single-user build, use user-supplied recipes and preserve source attribution without changing the technical stack. Before public sharing, open-source release, hosted URL ingestion, creator monetization, or redistributing recipe text/images, run [[Scope Expansion Checklist]] for rights, licenses, site terms, privacy, accessibility, food-safety boundaries, and moderation.

## Clever Hacks and Simpler Alternative

- Parse structured Recipe JSON-LD before anything intelligent. Many apparently messy blogs already contain clean ingredients, steps, yield, and times for search engines.
- Use Tabular Recipe's API or open graph/layout components for the first renderer. Validate whether the personal cookbook workflow is valuable before inventing a second notation engine.
- Run an **OCR-back test** on every share image: render the card, OCR it, and compare critical amounts, units, temperatures, and times with the source graph. This catches clipped or microscopic text automatically.
- Treat every user correction as a fixture. A growing local regression corpus is more valuable than repeatedly changing the prompt from intuition.
- Ask the model for graph edges with source spans and confidence, not finished prose or pixels. A deterministic compiler makes failures inspectable.
- Highlight only branch-changing uncertainties: divided amounts, which mixture a pronoun refers to, temperature, time, equipment transfer, and doneness. Do not make users approve every obvious noun.
- Make “paste clean recipe” a bookmarklet/share shortcut: extract JSON-LD in the browser and open the local app with a compact payload, avoiding heavyweight page automation.
- Generate short names for intermediates automatically—`wet mix`, `dry mix`, `sauce`—but retain their full composition on hover/tap.
- Let users save **personal patches** such as “my oven: +5 minutes” or “halve the sugar” separately from the source recipe; applying a patch creates a new revision and share card.
- Simplest alternative: use Mealie for capture/library and Tabular Recipe for one-off diagrams, connected by a small export script or manual copy. If that already satisfies daily use, this project can begin as a polished adapter and cook-mode layer rather than a full recipe manager.

## Battle-Test Corpus and Evaluation

Create a versioned gold set of at least 100 legally retained/user-supplied recipes spanning:

- simple sequential dishes;
- separate wet/dry branches;
- sauces plus a main component;
- divided/reserved ingredients;
- resting, proofing, marinating, chilling, or overnight stages;
- concurrent stovetop and oven work;
- repeated sub-recipes and batch operations;
- ambiguous references and optional ingredients;
- screenshots, printed cards, poor photos, and multiple languages;
- recipes too dense for a single square.

Measure ingredient coverage, quantity/unit exactness, instruction coverage, operation typing, material-edge precision/recall, dependency validity, time/temperature/doneness accuracy, unused-ingredient rate, unsupported-reference rate, cycle rate, OCR character/field error, correction time, render overflow, minimum text size, import latency, and user-reported cooking defects. Report parser quality separately from renderer quality and cooking usability.

## Success Measures

- Import-to-reviewed-card median under two minutes for structured URLs and under five minutes for clean images.
- 100% preservation of source snapshots, source references, original quantities, and approved revisions.
- Zero unresolved graph cycles and zero silent orphan ingredients in an approved recipe.
- At least 98% exact critical-field accuracy—amount, unit, temperature, time, and divided-use state—on the personal gold set after review; 100% is the target before unattended use.
- At least 95% material-edge F1 on held-out structured recipes, with low-confidence edges surfaced rather than guessed.
- Every export passes text-overflow, contrast, and minimum-readable-size checks for its declared format.
- The user can find any saved recipe by title, ingredient, cuisine, tag, or source in under ten seconds.
- Twenty-five real recipes imported, ten cooked from the app, and five shared without returning to the source blog for a missing critical detail.
- Corrections per recipe and correction time fall across parser versions without regressions on older fixtures.
- Backup/export restores the full library, raw sources, revisions, themes, and renders on a clean machine.

## Product Path

Personal local recipe inbox and diagram compiler -> reliable offline cookbook and cook mode -> native share-to-app capture and private multi-device sync -> family recipe books and collaborative corrections -> creator/publisher visual exports, paid themes, embed/API, and portable recipe-graph ecosystem.

The defensible product is not the phrase “tabular recipe” by itself. It is the trustworthy capture-review-compile loop, the personal correction history, adaptive legible rendering, and a library people genuinely cook from. Keep the free-first local architecture while validating that loop; apply [[Scope Expansion Checklist]] before accounts, public links, payments, third-party data retention, or commercial distribution.

## Related

- [[Personal Library Website]]
- [[PhoneScan PDF]]
- [[Visual Token Compiler]]
- [[Auto-GTM Engine]]
- [[Project Similarity and Reuse Map]]
- [[Project Ideas Index]]
- [[Scope Expansion Checklist]]
