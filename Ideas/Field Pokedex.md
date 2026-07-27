---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#7. Field Pokédex]]"
status: concept
difficulty: medium
priority: p1
category: nature learning
form_factor:
  - mobile app
deployment: on-device plus optional lookup
source_ideas:
  - Pokedex-style identification for real animals, flora, and fauna
tags:
  - biodiversity
  - computer-vision
  - citizen-science
---

# Field Pokedex

> A playful field guide that identifies likely species from a photo, exposes uncertainty and lookalikes, and turns observations into a collectible learning journal with trusted taxonomy and facts.

## Product Outcome

Take a photo or record a sound, receive a ranked set of candidates with diagnostic features, range/season context, safety notes, taxonomy, fascinating facts, and a spoken “field guide” entry. The user confirms or leaves the observation unresolved.

## Personal V0

- Capture or import a photo with optional location/date.
- Run a broad local classifier or send a privacy-reviewed query to an identification service.
- Show top candidates, confidence, visual cues, and common confusions.
- Retrieve taxonomy and facts from authoritative/open biodiversity sources.
- Save an observation card with photo, candidate, location precision, and notes.
- Build a private collection, streak-free local checklist, and taxonomy tree.
- Generate an original device voice; avoid copying a copyrighted character voice.

## Build Boundary

**MVP:** one region and one kingdom/group, online lookup permitted, user confirmation, and private observation log.

**Later:** offline regional packs, audio identification, community verification, AR overlays, and conservation exports. Never give unsafe edibility, venom, handling, or medical advice from an image alone; obscure coordinates for sensitive species.

## Existing Products, Building Blocks, and Shortcuts

- iNaturalist/Seek, PlantNet, and Merlin Bird ID are product references for camera/audio identification and community verification. The differentiator is a collectible personal field journal and explainable lookalike comparison.
- [iNaturalist API](https://api.inaturalist.org/v1/docs/), [GBIF Species API](https://techdocs.gbif.org/en/openapi/v1/species), and [Catalogue of Life](https://www.catalogueoflife.org/data/download) provide taxonomy, observations, names, and source IDs.
- TensorFlow Lite or ONNX Runtime Mobile can run a regional classifier; a hosted identification API is the fastest first candidate generator. Cache species cards locally.
- Simplest alternative: photo + location/date → API top candidates → user confirmation → saved card. Train/fine-tune only after a local error set reveals which taxa the generic service misses.

## Free-First Stack

- **App:** Expo for speed; native camera modules if on-device inference demands them.
- **Vision:** TensorFlow Lite/ONNX Runtime mobile with a regional model, or a permitted API for candidate suggestions.
- **Data:** SQLite for observations and cached species cards.
- **Taxonomy:** GBIF/iNaturalist/Wikidata/Wikipedia-compatible sources subject to their licenses and attribution.
- **Maps:** local/online OpenStreetMap-compatible view with privacy rounding.
- **Speech:** on-device TTS with an original presentation style.
- **Training later:** DGX Spark for fine-tuning/evaluating regional classifiers.

## Accuracy Design

Identification is a ranked hypothesis. Ask follow-up questions about leaf arrangement, size, habitat, underside, call, or behavior. Display model and geographic evidence separately. A low-confidence result should teach how to collect a better observation.

## Build Slices

1. Photo capture and manual species journal.
2. Candidate classifier and uncertainty UI.
3. Taxonomy/fact retrieval with attribution.
4. Lookalike comparison and follow-up questions.
5. Regional offline pack and audio narration.
6. Community verification/export.

## Success Measures

- Top-k accuracy is measured on regional, seasonally relevant images.
- Users leave uncertain observations unresolved rather than accepting a false label.
- Facts and taxonomy retain source attribution.
- Sensitive locations are protected.

## Product Path

Start with a local nature club, campus, or city and a narrow species set. An educational collectible layer can differentiate the experience, but rename before commercialization because “Pokédex” is a protected franchise term.

## Related

- [[Taxonomy Cluster Explorer]]
- [[Drone Mission Mapper]]
- [[AR Scale Lens]]
- [[Project Ideas Index]]
