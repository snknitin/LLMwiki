---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: maps-and-local-culture
form_factor:
  - local web app
  - interactive map
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#22. City Roast Map]]"
status: concept
parent_project: "[[Meet-in-the-Middle City Explorer]]"
tags:
  - maps
  - local-data
  - humor
---

# City Roast Map

> An evidence-aware neighborhood joke map that roasts places and habits, not protected groups or vulnerable people.

## Product Outcome

A user explores a city map and clicks a neighborhood to see a playful roast, the benign signals that inspired it, confidence/provenance, and a shareable card. The product succeeds when locals recognize the observation and still feel safe sharing it.

## User and Core Workflow

1. Creator selects a bounded city area and imports neighborhood polygons/names.
2. Collect public, non-sensitive place signals: café density, transit stops, parks, late-night venues, named landmarks, and creator-written lore.
3. Normalize counts by area and data coverage.
4. Generate several roast candidates under a strict humor policy.
5. Human approves/edits each neighborhood before publishing.
6. Viewer clicks, shares, or reports a card.

## Demo/Personal V0

Pick 8–12 neighborhoods in one familiar city. Use manually reviewed OpenStreetMap/Wikidata summaries and hand-authored seed jokes. Render a local MapLibre map and static PNG share cards. No live public submissions.

## Build Boundary

**MVP:** one city, fixed polygons, four benign signal families, human-reviewed copy, interactive map, evidence drawer, share-card export.

**Out:** crime scoring, property-value predictions, demographic inference, real-time social scraping, user-targeted insults, unmoderated submissions, and ranking “best/worst” residents.

## Existing Products, Building Blocks, and Shortcuts

- [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/) replaces a proprietary map renderer and supports interactive vector maps in the browser.
- [Overpass QL](https://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide) accelerates targeted extraction of OpenStreetMap features such as cafés, parks, or transit stops.
- [Wikidata Query Service](https://www.wikidata.org/wiki/Help:Query) supplies structured landmark and place facts with entity provenance.
- The public [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/) is an important shortcut boundary: cache results, stay under its limit, and do not build client-side autocomplete against the public service.

## Free-First Stack

- **Map:** MapLibre GL JS + OpenStreetMap-compatible tiles.
- **App:** Vite + TypeScript; static data is enough for V0.
- **Data prep:** Python, GeoPandas, Overpass queries, and a manually maintained lore CSV.
- **Generation:** local Ollama model with a blocked-topic policy and evidence fields.
- **Cards:** HTML/CSS templates captured with Playwright.
- **Storage:** GeoJSON plus versioned JSON/Markdown; no database until submissions exist.

## Architecture/Data Model

`Neighborhood` stores polygon, display name, and aliases. `SignalObservation` stores type, normalized value, source URL/query, capture date, and coverage note. `RoastDraft` references observation IDs and safety labels. `RoastPublication` stores approved text and revision. `Report` remains local in V0.

## Build Slices

1. City boundary and neighborhood GeoJSON.
2. Handwritten roasts and map interactions.
3. Signal ingestion with provenance/coverage.
4. Guardrailed candidate generation and human review.
5. Share cards and report button.

## Drawbacks/Concerns/Failure Modes

- OpenStreetMap completeness differs by neighborhood; show coverage and avoid interpreting missing tags as absence.
- Jokes can encode class, caste, race, religion, disability, or safety stereotypes. Ban protected-trait inference and roast amenities/behaviors instead.
- “Local fact” can be defamatory. Stick to aggregated public features and label the output as comedy.
- Tile/geocoder services have attribution and usage policies; cache and self-host only when necessary.
- AI humor becomes repetitive; maintain a human-written trope library and penalize repeated setups.

## Clever Hacks and Simpler Alternative

- Start as a static illustrated neighborhood list; add the map only after the jokes work.
- Use percentile buckets (“more cafés than 80% of included areas”) rather than raw counts.
- Ask locals to submit *observations*, not jokes; the creator retains editorial control.
- Create “roast / compliment” flip cards to soften tone and double shareability.

## Success Measures

- Every published roast has at least one visible non-sensitive source signal or is labeled creator lore.
- Zero protected-trait or individual-targeted jokes pass review.
- At least half of test locals rate a card “recognizable and shareable.”
- Initial map loads quickly from a static bundle and works without a backend.

## Product Path

One-city local map → curated city packs → moderated creator toolkit → sponsored cultural maps. Any public release needs stronger moderation, data licensing/attribution review, and reporting workflows.

For a more useful personal build, this becomes the optional local-character and voting layer inside [[Meet-in-the-Middle City Explorer]] while retaining its standalone static-map form.

## Related Wikilinks

- [[meet-in-the-middle|Meet in the Middle]]
- [[Meet-in-the-Middle City Explorer]]
- [[commute-copilot|Commute Copilot]]
