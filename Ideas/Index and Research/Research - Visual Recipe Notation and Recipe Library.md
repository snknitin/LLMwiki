---
type: research-note
status: active
created: 2026-08-15
scope: visual-recipe-notation-and-personal-recipe-library
tags:
  - research
  - recipes
  - information-design
  - knowledge-graph
  - ocr
  - local-first
  - pwa
  - svg
---

# Research - Visual Recipe Notation and Recipe Library

This dossier identifies the diagram in the supplied screenshot, separates it from superficially similar market maps, and turns the rough “recipe to image” concept into a technically honest local-first application. Sources are the original recipe/site, standards, official documentation, first-party product pages, and source repositories rather than copied social-media captions.

## 1. Visual Recipe Book

### Exact identification and lineage

The image is an example of **Tabular Recipe Notation (TRN)**, also described by its creator as a **recipe summary table**. Michael Chu devised and used the notation on **Cooking for Engineers**, a site he started in June 2004 to store recipes and kitchen notes; his first article appeared on 8 June 2004 ([Cooking for Engineers: About](https://www.cookingforengineers.com/article/138/About-Cooking-For-Engineers), [site press/history](https://www.cookingforengineers.com/article/141/In-the-Press)). By August 2004, Chu was publicly discussing browser-rendering problems in his “recipe summaries,” including vertical text and the need for non-rectangular/intersecting table regions ([Recipe Summaries - Standards and Microsoft](https://www.cookingforengineers.com/article/29/Recipe-Summaries-Standards-and-Microsoft)). In a first-party forum reply he later said the tables were formatted by hand in HTML and CSS and that no authoring tool existed at the time ([Cooking for Engineers forum: flow chart style recipe formatting](https://www.cookingforengineers.com/forums/viewtopic.php?t=338)).

The screenshot is traceable, not merely similar. Its text and geometry match the **Espresso Brownies** table published by Samantha Joyce on 27 June 2013: butter and flour an 8×8-inch pan, preheat to 350°F/170°C, melt the butter, combine the wet ingredients and eggs, fold in the dry ingredients, and bake for 30–40 minutes ([original Espresso Brownies recipe and printable table](https://www.cookingforengineers.com/recipe/327/Espresso-Brownies/print)). The viral screenshot cropped away the recipe title and surrounding article. The claim that the particular brownie image is “decades old” is therefore imprecise: the notation dates to the site's 2004 era, while this instance dates to 2013.

The most precise way to describe it technically is:

> A **material-flow operation graph rendered as a left-to-right merged-cell recipe table**. Ingredient rows are leaves; operation cells span the contiguous inputs they consume; intermediate mixtures are implicit outputs carried into later operations; setup prerequisites sit above the material flow.

Cooking for Engineers continues to label the approach “Tabular Recipe Notation” in its site footer. A 2005 first-party forum discussion says Chu had filed for a patent to preserve a possible licensing path, but the discussion and the site's long-running “patent pending” label are not evidence of an issued, currently enforceable patent ([Cooking for Engineers forum: Patent Pending](https://www.cookingforengineers.com/forums/viewtopic.php?t=240)). This is only a future-release diligence item; it does not change the private/local build stack.

### What the geometry means

Read the Espresso Brownies table as a dependency program:

1. **Full-width rows at the top are prerequisites**, not ingredients: prepare the pan and preheat the oven.
2. **The left column is material inventory**, one row per ingredient use. It preserves quantities and preparation qualifiers.
3. **Process columns advance from left to right.** “Melt” consumes butter. The first “mix” joins the melted butter with sugar, vanilla, and espresso. The next “mix” introduces eggs. “Fold in” joins the dry ingredients. “Bake” consumes the resulting batter.
4. **A vertically spanning operation is an AND-join.** Every ingredient or previous output whose row reaches that cell belongs to the operation. The tall cell is semantic, not decorative.
5. **Intermediate products are implicit.** “Melted butter,” “wet mixture,” and “batter” are not repeated as text, but each operation's output flows rightward into the next operation.
6. **Time and temperature are attributes of an operation.** The final cell says 350°F/170°C and 30–40 minutes. Column width and rectangle area do not encode duration.

The notation excels at answering “where does this ingredient enter?”, “what gets combined here?”, and “what is the shape of the preparation?” It is weaker at detailed technique, sensory doneness cues, branching alternatives, long waits, repeated batches, and simultaneous subrecipes unless those are modeled explicitly.

### What it is not

The user's stock-market analogy points to a different visualization. A FINVIZ-style market map is a **treemap/heatmap**: a space-filling display of hierarchy in which leaf-node area and color encode quantitative attributes. The University of Maryland's original treemap project defines treemaps as space-constrained hierarchy visualizations using size and color, and notes that Ben Shneiderman developed the concept in 1991; Shneiderman's own history connects the later SmartMoney market map to the technology used by FINVIZ ([UMD Treemap project](https://www.cs.umd.edu/projects/hcil/treemap/), [Shneiderman's information-visualization history](https://www.cs.umd.edu/~ben/about.html), [FINVIZ stock market map](https://finviz.com/map?t=sec_all)). A recipe could use a treemap for ingredient-cost, nutrition, or mise-en-place proportions, but the screenshot does not encode area quantitatively.

It is also not:

- a conventional **flowchart**, because it omits explicit arrows, decisions, start/end nodes, and most control-flow symbols;
- a **Nassi-Shneiderman diagram**, whose nested blocks were introduced to model structured-program control without unrestricted jumps ([Nassi and Shneiderman, 1973, in Shneiderman's publication record](https://www.cs.umd.edu/~ben/publications.html));
- a **Sankey diagram**, where link width is proportional to a flow quantity ([Highcharts Sankey API](https://api.highcharts.com/highcharts/plotOptions.sankey.minLinkWidth));
- a **swimlane diagram**, whose lanes partition activities by participant, role, or responsibility ([OMG introduction to BPMN swimlanes](https://www.omg.org/bpmn/Documents/Introduction_to_BPMN.pdf));
- a **Gantt chart or timeline**, because horizontal extent is not elapsed time.

“Recipe flowchart” is understandable casual language. For the product and data model, use **tabular recipe**, **recipe process grid**, or **material-flow recipe graph**. Avoid calling it a treemap, and do not promise that cell dimensions show time unless a separate proportional timeline is deliberately added.

### Refined product thesis

Build **Visual Recipe Book**, a capture-to-comprehension recipe library. A user shares a blog URL, image, PDF page, screenshot, or pasted recipe into the app. The app extracts the recipe, turns the method into a reviewable material-flow graph, renders a one-glance recipe process grid, and saves the canonical recipe with source provenance in a themed personal cookbook. From any saved recipe the user can open a readable cook view, export a social image, print a clean card, or share a link/file.

The promise should be narrower and stronger than “AI summarizes any recipe”:

> Save a recipe from anywhere, verify how ingredients and intermediate mixtures move through it, and get a compact visual that remains faithful to the source.

The app is not primarily another meal planner, grocery list, or recipe generator. Its wedge is the **verified process view** plus attractive book/library presentation. Meal planning, nutrition, pantry, and community discovery are later modules if actual use proves they matter.

Four complementary views should come from one canonical graph:

1. **Process Grid:** the TRN-inspired overview for tracing ingredient joins and transformations.
2. **Cook Mode:** one atomic instruction at a time, preserving full detail, doneness cues, timers, and substitutions.
3. **Mise-en-place List:** grouped ingredients, equipment, and advance preparation.
4. **Share Card:** a 1:1 or 4:5 branded export, with automatic carousel fallback when one image would make the text illegible.

The grid is the signature visualization, not the only representation. Forcing every recipe into one square would turn a readability project into unreadable poster generation.

### Existing products and the actual differentiation

There is now a direct modern comparator: **Tabular Recipe** converts pasted prose into an operation graph and a one-glance table, offers card fallback, self-contained HTML, a hosted API, and an open draft graph format called `rgf/0-draft` ([Tabular Recipe](https://tabularrecipe.com/), [its process-graph design guide](https://tabularrecipe.com/guides/recipe-data-formats/), [machine-readable product description](https://tabularrecipe.com/llms.txt)). It explicitly credits Michael Chu. This means “paste prose and receive a table” is no longer an empty product niche. It is also the best shortcut for benchmarking the local implementation. Its website says the schema, renderer, themes, and CLI are MIT licensed, but verify the actual package/repository and version before making it a dependency; the public site/API claim alone is not a pinned supply-chain artifact.

Recipe-library products already solve much of the surrounding workflow:

- **Paprika** imports recipes through its built-in browser, organizes recipes, synchronizes devices, builds grocery lists, and supports meal planning ([Paprika official features](https://www.paprikaapp.com/)).
- **Samsung Food** accepts URLs, browser-extension captures, OS share-sheet input, and recipe photos, then stores recipes in collections and shares recipes or collections ([Samsung Food save/search/share guide](https://support.samsungfood.com/hc/en-us/articles/18365507924372-Getting-Started-with-Samsung-Food-Save-Search-and-Share-Recipes), [photo and URL capture guide](https://support.samsungfood.com/hc/en-us/articles/18756427379476-How-to-Save-Recipes-to-Your-Samsung-Food-Recipe-Box)).
- **Recipe Keeper** focuses on preserving recipes from handwritten cards, cookbook pages, printouts, PDFs, and images ([Recipe Keeper official site](https://www.recipekeeper.org/)).
- **Mealie** is a self-hosted recipe manager with URL import, cookbooks, meal planning, shopping lists, an API, and offline-friendly clients ([Mealie repository](https://github.com/mealie-recipes/mealie)).
- **Tandoor Recipes** imports sites with JSON-LD/microdata, manages cookbooks, planning, scaling and shopping, and supports many migration formats ([Tandoor repository](https://github.com/TandoorRecipes/recipes), [import/export documentation](https://docs.tandoor.dev/features/import_export/)).
- **RecipeSage** is an open-source PWA that imports URLs, images, PDFs, and text; supports offline search, sharing, scaling, cookbooks, meal plans, and JSON-LD export ([RecipeSage repository](https://github.com/julianpoy/recipesage), [image-import documentation](https://docs.recipesage.com/docs/tutorials/settings/import/images/)).
- **Nextcloud Cookbook** is a lighter local/cloud alternative that stores recipe files in Nextcloud and imports sites exposing Schema.org Recipe JSON-LD ([Nextcloud Cookbook usage documentation](https://nextcloud.github.io/cookbook/user/)).

The defensible product combination is therefore:

- verified dependency/ingredient flow rather than a conventional recipe card;
- local-first and offline ownership;
- a fast share-in path from blogs and images;
- evidence-linked correction rather than invisible AI extraction;
- kitchen-themed bookshelves, covers, and social exports;
- cook mode and timers generated from the same graph;
- optional compatibility with Mealie, Tandoor, RecipeSage, Cooklang, and Schema.org rather than a closed archive.

### Canonical data model: store the recipe, graph, and evidence separately

Search markup is a useful intake format, not a sufficient process model. Schema.org defines `Recipe` fields such as ingredients, instructions, yield, times, category, cuisine, nutrition and method; `recipeInstructions` may be text or an ordered list of `HowToStep`/`HowToSection` items ([Schema.org Recipe](https://schema.org/Recipe), [Schema.org recipeInstructions](https://schema.org/recipeInstructions)). Google's official recipe structured-data example uses JSON-LD with `recipeIngredient` strings and `HowToStep` objects ([Google Recipe structured data](https://developers.google.com/search/docs/appearance/structured-data/recipe)). Those two arrays do not say which ingredient quantity enters which step, which intermediate output a later pronoun refers to, or which branches can run in parallel.

Use a graph-native internal model with at least these records:

```yaml
recipe:
  id: recipe_uuid
  title: Espresso Brownies
  yield: 16 squares
  source:
    url: https://...
    author: Samantha Joyce
    captured_at: 2026-08-15T...
    raw_snapshot_hash: sha256:...
  tags: [dessert, baking, chocolate]

ingredient:
  id: butter
  phrase_original: 4 oz (115 g) unsalted butter
  quantity_original: 4
  unit_original: oz
  normalized_quantity: 115
  normalized_unit: g
  item: unsalted butter
  preparation: null
  confidence: 1.0
  evidence: {source_span: [0, 31]}

operation:
  id: mix-wet
  kind: transform
  label: mix
  instruction_original: Stir together the melted butter, sugar, vanilla and espresso.
  uses:
    - {kind: output, ref: melted-butter}
    - {kind: ingredient, ref: sugar}
    - {kind: ingredient, ref: vanilla}
    - {kind: ingredient, ref: espresso}
  after: []
  outputs: [{id: wet-mixture, name: wet mixture}]
  duration: {raw: null, min_minutes: null, max_minutes: null}
  temperature: null
  doneness: thoroughly mixed
  attention: active
  equipment: [mixing bowl, spatula]
  confidence: 0.93
  evidence: {step_id: source-step-3, source_span: [0, 74]}
```

Important distinctions:

- `uses` means material consumption; `after` means a prerequisite or ordering constraint. Preheating the oven is `after`, not an ingredient edge.
- Ingredients, operation outputs, and equipment are different entities.
- A divided ingredient needs separate **use occurrences** referencing one canonical ingredient, not duplicate inventory lines.
- An operation may produce multiple outputs: separating eggs yields whites and yolks; straining yogurt yields curds and whey.
- Original quantities and wording remain immutable. Normalized values are derived and may be corrected.
- Durations should be ranges and marked active/passive; doneness cues remain first-class text.
- Every inferred field and edge carries confidence plus a source text span or image bounding box.

Validate both JSON shape and graph semantics: unique IDs, resolvable references, one producer per output, valid unit/range pairs, and acyclicity after loop constructs are normalized. [Cooklang](https://github.com/cooklang/spec) is a useful portable text export because it marks ingredients, cookware, time, and metadata inline, but it does not by itself replace the material-flow graph.

### Visual grammar and deterministic layout

Treat rendering as a compiler from the graph, never as image generation by a vision model.

1. Topologically order operation nodes while preserving explicit source order where dependencies permit.
2. Assign ingredient-use leaves to rows. Reorder within source-defined groups to make the inputs of each join contiguous.
3. Assign each transformation a rank/column based on dependency depth.
4. Compute the row interval consumed by each operation. A merged rectangular cell is valid only when every row in its span is genuinely consumed by that operation or represents the carried output.
5. Minimize width by packing independent same-rank operations only when the visual still exposes parallelism.
6. Place prerequisites such as preheat, soak, chill, or prepare-pan in a separate setup band connected by ordering constraints.
7. Render duration, temperature, attention, and doneness as badges/text inside an operation; do not encode invented quantitative meaning in width or area.
8. Generate a legend and a plain-language linearization from the same graph.

Some recipe graphs cannot be represented as nested rectangles without lying. Cross-cutting ingredient reuse, multiple outputs, reconverging branches, and loops can make the desired leaf sets noncontiguous. The correct behavior is one of:

- repeat a **use occurrence** with a visible divided-ingredient marker;
- switch to an expanded lane/connector view;
- split the recipe into named components, such as sauce, filling, dough, and assembly;
- fall back to ordered cards or a multi-slide carousel and explain why.

For generic connector layout, [ELK.js](https://github.com/kieler/elkjs) provides layered directed-graph layout with ports. The signature compact grid should still use a custom deterministic span algorithm; a generic graph layout will not automatically reproduce TRN semantics.

### Intake and normalization pipeline

Use an ordered extraction cascade. The early stages should be deterministic and free; the local language model is a repair/graph-inference stage, not the first scraper.

#### Blog or webpage URL

1. Fetch the page in a backend process and keep the canonical URL, retrieval time, raw HTML hash, and visible-title/author evidence.
2. Inspect every `script[type="application/ld+json"]` block and select a `Recipe` object, including objects nested in `@graph`.
3. Fall back to microdata/RDFa and site-specific extraction. The Python [recipe-scrapers](https://docs.recipe-scrapers.com/getting-started/supported-sites/) project supports hundreds of sites plus a heuristic `wild_mode`; Mealie's own source shows endpoints that accept a URL, raw HTML, or a Schema.org Recipe JSON object ([Mealie recipe ingestion route](https://github.com/mealie-recipes/mealie/blob/mealie-next/mealie/routes/recipe/recipe_crud_routes.py)).
4. Compare extracted structured data with visible recipe text. Publishers sometimes omit details from markup or leave stale markup after editing.
5. Only then send the smallest necessary source bundle to the graph parser: ingredients, instructions, yield, notes, equipment, and relevant headings—not the surrounding biography and ads.

The value of this ordering is large: many recipe sites already publish the exact ingredient/instruction fields to qualify for search enhancements. Google recommends JSON-LD among its supported structured-data formats, while also warning that markup must represent the visible page ([Google structured-data introduction](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data), [general structured-data guidelines](https://developers.google.com/search/docs/appearance/structured-data/sd-policies)).

#### Photo, screenshot, or scanned page

1. Let the user crop to the recipe and correct four page corners.
2. Deskew/dewarp with OpenCV; `getPerspectiveTransform` and `warpPerspective` map a photographed quadrilateral to a rectangle ([OpenCV geometric transforms](https://docs.opencv.org/4.13.0/da/d54/group__imgproc__transform.html)).
3. Run local OCR with bounding boxes and confidence. [PaddleOCR PP-StructureV3](https://github.com/PaddlePaddle/PaddleOCR/blob/main/docs/version3.x/pipeline_usage/PP-StructureV3.en.md) combines orientation, layout analysis, OCR and table/document structure; lightweight [Tesseract](https://github.com/tesseract-ocr/tesseract/blob/main/doc/tesseract.1.asc) can emit TSV, hOCR, ALTO or PAGE XML with positional output.
4. Reconstruct reading order and preserve image bounding boxes for every token.
5. Ask the user to confirm high-risk OCR tokens: fractions, decimal points, temperatures, time ranges, unit abbreviations, negation, and ingredient names with low confidence.
6. Classify ingredient, heading, instruction, note, yield and metadata blocks; then pass those blocks through the same normalizer and graph parser as web input.

Do not infer a complete recipe from a photograph of the finished dish. If the image contains no readable recipe, label it as inspiration and request text/source. A vision model may suggest a recipe in a separate generation feature, but it cannot claim fidelity to an absent source.

#### Pasted or typed text

Preserve the raw text, identify likely sections and split instructions into atomic actions. Show the normalized ingredient list and the `uses` assignments beside each action. A small correction UI—checkboxes for which inputs each action uses, plus a name for the output—is more valuable than an elaborate freeform graph editor in V0.

### Ambiguity policy: model output is a proposal

Recipe language routinely leaves material flow implicit. The parser must detect rather than silently “solve” these cases:

- “add half,” “reserve the rest,” or “divide among bowls”;
- “mix the dry ingredients” when group membership is only implied by an earlier heading;
- pronouns such as “it,” “them,” “the mixture,” or “the reserved liquid”;
- an ingredient used at multiple stages, including garnish;
- subrecipes prepared in parallel and assembled later;
- one operation yielding multiple products;
- loops such as fry in batches, whisk every two minutes, or repeat until absorbed;
- optional ingredients and alternative branches;
- passive waits whose end is sensory rather than timed;
- time ranges that overlap through “meanwhile” or depend on equipment capacity;
- instructions that omit an ingredient listed above, or mention an unlisted ingredient;
- conflicting visible text, structured data, caption, or image.

Use three confidence bands:

- **Verified:** direct source evidence and deterministic relation.
- **Review:** plausible relation with an explicit highlighted evidence passage.
- **Unresolved:** more than one graph fits; the user must select or leave it unrendered.

Numerical fields deserve stricter thresholds than descriptive tags. Never convert cups to grams without an ingredient-specific density source, never scale cooking time linearly with servings by default, and never “correct” a source temperature from general culinary knowledge. Preserve the original phrase alongside any conversion.

### Free-first local stack

Recommended product-shaped V0:

- **Client:** React + TypeScript + Vite PWA, responsive bookshelf/process-grid/cook views, service worker for the app shell and recent recipes.
- **API and workers:** Python 3.12 + FastAPI + Pydantic. Python has the strongest immediate path to recipe-scrapers, PaddleOCR, OpenCV and local model adapters.
- **Canonical store:** SQLite with JSON columns for captured source and graph versions plus normalized tables for recipes, ingredients, operations, uses, outputs, collections and exports. Use FTS5 for title, ingredient, cuisine and note search.
- **Assets:** content-addressed local folders for source images, thumbnails and rendered exports; store hashes and dimensions in SQLite.
- **Model:** any local OpenAI-compatible instruction/VLM endpoint on the workstation or DGX Spark. Require JSON-Schema output, then validate graph invariants independently. Escalate only low-confidence cases to a paid model if the user enables it.
- **Extraction:** recipe-scrapers/JSON-LD first; Beautiful Soup or equivalent DOM parsing as glue; Playwright only for pages whose recipe is rendered after JavaScript or must be captured through the user's browser session.
- **OCR:** PaddleOCR for structure-heavy/multilingual pages; Tesseract as a small CPU fallback; OpenCV preprocessing.
- **Layout:** custom TypeScript span compiler producing pure SVG rectangles, lines and `<text>`; ELK.js only for expanded non-tabular graphs.
- **Raster export:** [resvg](https://github.com/linebender/resvg) or [Sharp](https://sharp.pixelplumbing.com/api-output/) to turn SVG into deterministic PNG/WebP; keep SVG as the lossless master.
- **Tests:** Pytest for extraction/graph semantics, Vitest for layout calculations, Playwright for end-to-end capture and export, and golden SVG/PNG fixtures for rendering.

Avoid generating the final card with an image model. It will misspell quantities and cannot guarantee cell semantics. Image generation is appropriate only for optional decorative backgrounds or covers; layer those behind a high-contrast deterministic SVG card.

### Share-in, share-out, and offline behavior

An installed PWA can declare `share_target` in its manifest to receive shared URLs, text and files, including multipart image input. MDN marks this capability as limited/experimental rather than universally available ([Web app manifest `share_target`](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Manifest/Reference/share_target), [WICG Web Share Target draft](https://wicg.github.io/web-share-target/)). Therefore:

- implement paste URL, upload, camera, drag-and-drop and a bookmarklet/browser extension as universal paths;
- add Android/Chromium PWA share-target intake as a convenience, not the only intake;
- consider an iOS Shortcut or thin native share extension only after the web workflow proves useful;
- queue incoming shares locally when offline and parse them when the local service/source becomes available.

For export, `navigator.share()` can send text, URLs and supported files through the device share sheet, but it requires HTTPS, user activation and feature detection with `navigator.canShare()` ([MDN `navigator.share`](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share)). Always retain explicit Download PNG, Download SVG, Copy Image, Copy Link, and Print actions.

### Export system and kitchen-book design

Generate from one layout specification into:

- responsive interactive SVG/HTML;
- 1080×1080 square social card;
- 1080×1350 portrait card for feeds;
- multi-slide carousel when content exceeds minimum type size;
- printable A4/Letter PDF or browser print view;
- raw graph JSON and Schema.org/Cooklang interoperability exports;
- a plain-text recipe and accessible HTML table/card sequence.

Kitchen theming should live in tokens: paper/linen background, accent palette, border style, ingredient/operation fills, typography, icon set and cookbook-cover template. Keep the semantic grid on an opaque or near-opaque surface; decorative countertops, tiles, herbs and cookware remain outside the content safe area. Provide monochrome and high-contrast themes for printing.

Use pure SVG groups with visible text rather than flattening early. The SVG 2 specification says `title` and `desc` content is exposed through accessibility APIs and recommends grouping meaningful graphic objects ([W3C SVG document structure](https://www.w3.org/TR/SVG/latest/struct.html)). Still provide a full DOM recipe next to the SVG because social platforms commonly flatten images and may discard embedded accessibility semantics. Generate a concise copyable alt text, for example:

> Espresso Brownies process grid: prepare pan and preheat oven; melt butter; mix with sugar, vanilla and espresso; mix in eggs; fold in flour, cocoa, baking soda and salt; bake at 170°C for 30–40 minutes.

Color must never be the only signal. Preserve cell borders, labels, icons/patterns and reading order; allow zoom and text-size changes. A beautiful image that cannot be read at ordinary phone size fails the product goal.

### Clever shortcuts and simpler alternatives

1. **JSON-LD first:** inspect the page source before using OCR, DOM heuristics or a model. For many blogs the publisher has already separated title, yield, ingredients, steps and times.
2. **Build an alternate renderer, not a whole recipe manager:** store recipes in Mealie, Tandoor or RecipeSage and build only the graph-review plus SVG export layer against its API/export. This is the fastest way to test whether the visualization changes cooking behavior.
3. **Use Tabular Recipe as a benchmark and temporary parser:** compare its output on a fixed corpus, and prototype the bookshelf/share layer around exported graph/HTML if the service or verified open package satisfies the private workflow. Do not make an unpinned hosted service the only copy of a recipe.
4. **Make the review UI the editor:** show atomic steps with “uses these ingredients/outputs” chips. This captures the hard graph edges without requiring users to manipulate graph nodes.
5. **Complexity-gated output:** use the compact process grid only below a measured readability/topology threshold. Automatically choose landscape, portrait, or carousel instead of shrinking fonts.
6. **Two-pass model call:** first extract source-faithful atomic actions; then infer edges only among stable IDs. Smaller prompts and independent validation make errors easier to locate.
7. **Evidence-on-click:** selecting a cell highlights the exact source sentence or OCR bounding box. Corrections become training/evaluation data.
8. **Golden starter set:** hand-author 20 varied recipe graphs, including the Espresso Brownies table, rather than trying to evaluate against arbitrary web output on day one.
9. **Reuse browser-native print:** defer a custom PDF engine; a deterministic print stylesheet can produce useful recipe cards immediately.
10. **Cook from the graph:** let tapping an operation start its timer and reveal full instructions. This differentiates the app from static infographic generators while reusing the same data.

The minimum useful personal prototype can be even smaller: paste a Recipe JSON-LD/text block, review ingredient-to-step links in one form, generate an SVG, and save the JSON/SVG in one local directory. URL fetchers, OCR, PWA share targets, themes and cookbook shelves can arrive after the graph and layout survive real recipes.

### Build sequence

#### Slice 0 - Notation fixture

Hand-encode the Espresso Brownies graph. Reproduce its semantics—not necessarily its copyrighted styling—as SVG and also linearize it back into complete text. This establishes the graph schema, layout rules and visual regression fixture.

#### Slice 1 - Paste to verified grid

Accept pasted ingredients/instructions, parse into structured JSON, show the step/use review form, validate the graph, render SVG, export PNG and store locally. Support only simple acyclic recipes; reject or card-render unsupported graphs.

#### Slice 2 - URL import and library

Add Schema.org/recipe-scrapers import, source snapshots, SQLite search, tags, favorites, cookbook collections, cover themes and re-import comparison. A source update should create a new version, not overwrite user corrections.

#### Slice 3 - Image/PDF capture

Add crop/deskew, OCR, bounding-box evidence and high-risk numeric review. Test cookbook photos, screenshots, handwritten cards and multi-page scans separately because their failure modes differ.

#### Slice 4 - Share and cook

Add PWA installation, supported share-target intake, `navigator.share`, cook mode, timers, offline queueing and carousel export.

#### Slice 5 - Interoperability and expansion

Add Schema.org/Cooklang/Mealie/Tandoor/RecipeSage import-export adapters, multi-language/unit packs, book PDF generation, collaborative sharing, meal planning or publishing only if the personal workflow demands them.

### Evaluation and battle testing

Build a gold corpus of at least 100 recipes stratified by topology and source:

- linear one-pot recipes;
- baking with global preheat/pan prerequisites;
- wet/dry joins;
- divided ingredients;
- parallel sauce-and-base components;
- dough/proof/fill/assemble branches;
- repeated batches and loops;
- multiple outputs;
- optional branches and garnishes;
- webpages with clean, stale and absent JSON-LD;
- clear/poor photos, handwriting, fractions and multiple languages.

Score the layers independently:

| Layer | Metrics |
|---|---|
| Source extraction | recipe detection rate; title/yield/time exactness; ingredient and instruction field F1; visible-text conflict detection |
| OCR | character/word error rate; numeric/fraction/unit error rate; reading-order accuracy; percentage of high-risk errors surfaced |
| Graph | ingredient-use edge precision/recall; output-reference accuracy; prerequisite accuracy; graph-valid rate; false-span count |
| Layout | clipped/overlapping text; minimum font size; unsupported graph correctly routed to fallback; deterministic snapshot stability |
| Usability | time to answer “when is X used?”; first-attempt correctness; source reopens during cooking; correction time; task completion |
| Library | import-to-save latency; search success; offline reopen; duplicate detection; successful export/share rate |

The decisive experiment is not aesthetic preference. Give cooks a conventional recipe and a process-grid version, then ask them to locate when an ingredient enters, identify what can be prepared in parallel, and cook without losing their place. Record errors, glances back to the source, completion time and confidence. Include novice and experienced cooks: experts may infer omitted states that novices cannot.

Regression invariants should include:

- every rendered operation corresponds to one canonical operation ID;
- every merged span exactly matches its ingredient/output uses;
- no quantity, time, temperature or negation appears without source evidence;
- every output has one producer and every reference resolves;
- changing a theme cannot change the graph;
- SVG, PNG, print and cook mode linearize to the same recipe facts;
- uncertain fields remain marked uncertain after rendering.

### Drawbacks, failure modes, and design responses

- **Direct competitor exists:** Tabular Recipe already offers prose-to-operation-graph-to-table conversion. Differentiate through capture, local library, correction evidence, cook mode, themes and book/social workflows; do not pitch the renderer alone as novel.
- **A confident wrong edge is worse than prose:** the graphic's clarity can amplify a parsing error. Require edge confidence, review on ambiguity and source-on-click.
- **Not every recipe is rectangular:** crossing dependencies and loops make merged cells misleading. Use a correctness-preserving fallback rather than decorative contortions.
- **Square images create illegible type:** set a minimum font size and use portrait/carousel/landscape output when the layout exceeds it.
- **Compact verbs omit technique:** “fold in” cannot replace how, how long, with what tool, or until what cue. Cook mode and expandable cell details must preserve the original instruction.
- **OCR mistakes are culinary mistakes:** `1/2` vs `1 1/2`, °F vs °C, teaspoon vs tablespoon and missing “not” can ruin a recipe. Route numeric/negation uncertainty through explicit review.
- **Structured data can be incomplete or stale:** compare it with visible recipe content and preserve both evidence streams.
- **Time is not a reliable geometry by default:** total time, active time and critical-path time differ. Label what is computed and keep ranges/unknowns.
- **Unit conversion is ingredient-dependent:** volume-to-mass conversion needs density and preparation state. Preserve original units and make conversions opt-in.
- **Remote imports break:** anti-bot pages, login walls, JavaScript rendering, CORS and redesigns require adapters or browser capture. Track connector success instead of promising “any site.”
- **Images are not accessible archives:** keep structured text/HTML and alt text alongside every social card.
- **The notation needs onboarding:** a three-step legend and animated ingredient trace can teach the left-to-right join grammar.
- **Feature gravity is strong:** pantry, nutrition, shopping, communities and meal planning can bury the visualization. Hold them until capture → verify → understand → cook → share works repeatedly.

### Success definition

The private V1 is successful when the owner can share or paste ten real recipes from mixed sources, correct each in under two minutes, reopen them offline, understand ingredient flow faster than from the original, cook from the full-detail view, and export an attractive readable image without manual layout work. A stronger battle-tested target is:

- at least 90% correct ingredient-use edges before correction on the supported simple-recipe class;
- 100% graph-valid saved recipes;
- zero known false merged spans;
- high-risk numeric OCR errors always surfaced rather than silently accepted;
- a median under 30 seconds from clean JSON-LD URL to preview;
- a median under two minutes from ordinary photo to verified preview;
- users answer ingredient-entry questions faster and with fewer errors than with the source recipe;
- every recipe remains recoverable as portable structured data plus source evidence, independent of a generated image.

### Scope-expansion reminder

For a public, collaborative, open-source, or paid release, verify the current status and permitted use of names/notation, imported recipe text and images, publisher/platform access rules, model/OCR licenses, accessibility obligations, user-data handling, safety-sensitive transformations and social-platform export requirements. These future checks should not change the recommended private/local technology stack; they belong in the release checklist and connector policy.

### Related ideas

- [[Creator Content Engine]] — reusable social-card themes, export presets and publishing queue.
- [[Personal Signal Intelligence OS]] — share-in capture, source provenance and review-queue patterns.
- [[Longform-to-Shorts Studio]] — deterministic layout/export pipeline and multi-slide fallback.
- [[Scope Expansion Checklist]] — deferred public-release diligence.
