---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#16. Taxonomy Cluster Explorer]]"
status: concept
difficulty: medium
priority: p1
category: scientific visualization
form_factor:
  - local web app
deployment: local-first
source_ideas:
  - hierarchical agglomerative clustering for animal and plant taxonomy
tags:
  - taxonomy
  - clustering
  - visualization
---

# Taxonomy Cluster Explorer

> A dual-view explorer that keeps authoritative biological taxonomy separate from experimental similarity dendrograms, making agreement and disagreement between classification systems visible.

## Product Outcome

Choose a set of taxa and view the accepted hierarchy with source/version. Beside it, cluster the same taxa by selected image, morphology, habitat, text, or other features. Clicking a species highlights its true ancestors, nearest similarity neighbors, and the features driving an experimental merge.

## Personal V0

- Import a small versioned taxonomy slice from Catalogue of Life, GBIF, or NCBI.
- Preserve stable taxon IDs, accepted names, synonyms, ranks, and source.
- Attach a small manually curated feature table or precomputed embeddings.
- Run hierarchical agglomerative clustering with selectable distance/linkage.
- Render authoritative tree and experimental dendrogram side by side.
- Animate changes when metric or linkage changes.
- Explain merge distance and contributing features with clear “not phylogeny” labeling.

## Build Boundary

**MVP:** a few hundred taxa, one authoritative source, one feature set, three linkage choices, and linked D3 views.

**Later:** images, larger corpora, multiple taxonomies, user annotations, evolutionary trees, and educational narratives. Do not label embedding similarity as inferred evolutionary history.

## Existing Products, Building Blocks, and Shortcuts

- [Catalogue of Life](https://www.catalogueoflife.org/data/download), [GBIF Species API](https://techdocs.gbif.org/en/openapi/v1/species), and [NCBI Taxonomy](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/data-processing/taxonomy-processing/taxonomy/) provide versioned authoritative names, IDs, synonyms, ranks, and parents.
- [SciPy hierarchical clustering](https://docs.scipy.org/doc/scipy/reference/generated/scipy.cluster.hierarchy.linkage.html) implements linkage methods; [D3 hierarchy](https://d3js.org/d3-hierarchy/hierarchy) renders interactive trees/dendrograms.
- OneZoom and taxonomy browsers are product references for navigating huge biological trees. Your useful twist is a synchronized authoritative tree versus experimental similarity cluster.
- Simplest alternative: a few hundred taxa and manually meaningful morphology/habitat features. Switch metric/linkage interactively and make instability part of the lesson.

## Free-First Stack

- **Data:** Python, Polars, DuckDB/Parquet, and versioned source snapshots.
- **Clustering:** SciPy/scikit-learn with metric/linkage constraints enforced.
- **UI:** SvelteKit/React plus D3 hierarchy/dendrogram.
- **Embeddings later:** local vision/text encoders on a user-supplied corpus.
- **Scale:** cluster within family/order or use sampling; common hierarchical methods require quadratic memory.
- **Provenance:** source dataset/version and feature-generation config on every view.

## Clever Hacks and Simpler Alternative

- Start with manually meaningful morphology/habitat features; they are easier to explain than black-box embeddings.
- Use metric instability as a teaching feature.
- Constrain similarity clustering within a taxonomic branch for performance and interpretability.
- Preserve source IDs through name changes.
- Show pairwise feature contributions rather than a generic AI explanation.

## Build Slices

1. Taxonomy snapshot and tree viewer.
2. Feature table and clustering service.
3. Linked dual view.
4. Metric/linkage comparison and merge explanations.
5. Image/text embedding experiment.

## Battle-Testing Gates

- Tree relationships reproduce the selected source snapshot.
- Linkage/metric combinations are mathematically valid.
- Results are deterministic or record tie-breaking.
- Dataset updates produce an explicit diff.
- Experimental views never masquerade as authoritative taxonomy.

## Product Path

This can feed [[Field Pokedex]] and become a strong educational visualization. A public scientific product would need expert review and robust source/version governance; the personal tool can begin with local datasets immediately.

## Related

- [[Field Pokedex]]
- [[Personal Study Curriculum]]
- [[Visual Token Compiler]]
- [[Project Ideas Index]]
