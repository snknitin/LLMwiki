---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#6. Understand This Paper]]"
status: existing-prototype
difficulty: hard
priority: low
completion_estimate: 80-percent
category: research learning
form_factor:
  - web app
  - local desktop app
deployment: hybrid
source_ideas:
  - upload an arXiv link or PDF for color-coded equations, pseudocode, summaries, and 3D visualization
tags:
  - papers
  - math
  - visualization
  - subscription
---

# Understand This Paper

> An interactive research-paper tutor that maps claims to evidence, explains notation in context, derives equations step by step, emits executable pseudocode, and uses visualization only where it clarifies the model.

## Product Outcome

Uploading an arXiv link or PDF produces a layered reading experience: five-minute orientation, section map, glossary, equation dependency graph, method pseudocode, assumptions, results, limitations, and exercises. Clicking any explanation returns to the exact source region.

## Personal V0

- Import an arXiv identifier or local PDF and preserve metadata/version.
- Extract sections, figures, tables, equations, captions, and references with page anchors.
- Build a symbol table: symbol, meaning, units/shape, first definition, and later uses.
- Color-code equation terms consistently across the document.
- Provide three explanation levels: intuition, derivation, and implementation.
- Generate pseudocode with explicit tensor/data shapes and cited source spans.
- Create small interactive plots for selected equations.
- Maintain a question notebook whose answers cite the paper.

## Build Boundary

**MVP:** machine-learning arXiv papers with good source/PDF structure, orientation summary, symbol table, one equation walkthrough, pseudocode, and citation anchors.

**Later:** broader domains, 3D visualizations, code execution, related-work maps, collaboration, and monthly subscriptions. Do not promise mathematical correctness without validation.

### Current Disposition

An existing hackathon prototype is reported to be about 80% complete. The next work is evaluation, not feature expansion: select five representative papers, measure parsing/citation/equation failures, and turn those failures into the remaining backlog after the urgent personal betas stabilize.

## Existing Products, Building Blocks, and Shortcuts

- [arXiv’s API/manual](https://info.arxiv.org/help/api/index.html) supplies metadata and versioned source links; when TeX source exists, it is often a better equation/section input than reverse-engineering the PDF.
- [GROBID](https://github.com/kermitt2/grobid) converts scholarly PDFs into structured TEI, and [PyMuPDF](https://pymupdf.readthedocs.io/) preserves page coordinates. Use GROBID for logical structure and PyMuPDF for clickable visual anchors.
- [MathJax](https://www.mathjax.org/) or [KaTeX](https://katex.org/) handles equation rendering; [SymPy](https://www.sympy.org/) can check selected algebra and run toy symbolic examples. These replace a custom math renderer and some fragile LLM verification.
- NotebookLM already provides cited question answering and study artifacts over uploaded sources. A simpler differentiated tool is therefore an equation/symbol dependency viewer and executable pseudocode notebook, not another general PDF chat.

## Free-First Stack

- **Frontend:** Next.js/SvelteKit with KaTeX/MathJax and Observable Plot/Three.js.
- **Backend:** FastAPI job pipeline.
- **Parsing:** arXiv metadata/source when available, GROBID for scholarly structure, PyMuPDF for coordinates, and LaTeXML/Pandoc selectively.
- **Data:** Postgres/SQLite plus object files; store a document intermediate representation.
- **Models:** local text/vision model for extraction and teaching; paid frontier model for opt-in difficult derivations behind the same provider interface.
- **Verification:** SymPy for algebra where possible; executable unit tests for pseudocode; human-visible uncertainty.

## Document Intermediate Representation

Represent the paper as typed nodes—section, paragraph, equation, figure, table, citation—with source coordinates and semantic edges. All generated explanations reference node IDs. This allows the parser, tutor, renderer, and evaluators to evolve independently.

## Build Slices

1. One-domain parser and source-linked reader.
2. Symbol table and equation dependency graph.
3. Layered explanation with citation enforcement.
4. Pseudocode schema and runnable toy examples.
5. Interactive visualization templates.
6. Evaluation set of papers with expert-reviewed outputs.

## Success Measures

- Every explanation navigates to its supporting source.
- Symbols retain consistent definitions and shapes.
- Pseudocode passes toy tests or is marked non-executable.
- Users answer comprehension questions better after the walkthrough.
- Failure is explicit when parsing or derivation confidence is low.

## Product Path

Personal-first local processing validates the pedagogy. A paid web product can charge for compute, saved libraries, collaboration, and expert-verified collections. A strong open-source parser/IR could build trust and distribution.

## Related

- [[Half-Blood PDF]]
- [[Handwriting to LaTeX]]
- [[Visual Token Compiler]]
- [[Personal Study Curriculum]]
- [[Project Ideas Index]]
