---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#5. Half-Blood PDF]]"
status: existing-prototype
difficulty: hard
priority: low
completion_estimate: 80-percent
category: document learning
form_factor:
  - desktop app
  - local web app
deployment: local-first
source_ideas:
  - Halfblood Prince PDF with handwritten annotations, diagrams, links, and aged-book export
tags:
  - pdf
  - annotation
  - excalidraw
  - learning
---

# Half-Blood PDF

> A local “annotated by a brilliant previous reader” pipeline that enriches a PDF with marginal questions, corrections, diagrams, cross-links, and optional worn-book styling while preserving the original text and provenance.

## Product Outcome

Turn a dense book chapter, manual, or paper into a navigable study artifact. Notes should appear where they are relevant, distinguish source text from generated commentary, and link to deeper explanations or editable diagrams. The final PDF is an output; the canonical project remains editable structured data.

## Personal V0

- Import a text-based PDF and select a chapter/page range.
- Extract text blocks and coordinates while retaining page references.
- Generate candidate annotations: clarification, correction, prerequisite, question, analogy, and diagram.
- Review every candidate in a side-by-side interface.
- Create editable Excalidraw-compatible diagrams and backlinks.
- Render approved marginalia, highlights, icons, and hyperlinks into a new PDF.
- Offer clean, study, and “beaten-up book” visual themes.
- Keep an annotation manifest that can regenerate the output.

## Build Boundary

**MVP:** text-based PDFs, one annotation style, human approval, page-local notes, and a regenerated PDF.

**Later:** scanned PDFs, handwriting fonts, mind-map overview, NotebookLM source handoff, collaborative review, and printed-book layouts. Never overwrite the source file.

### Current Disposition

An existing hackathon prototype is reported to be about 80% complete. Preserve and evaluate it rather than starting another implementation: render one representative chapter, validate anchors and links, inventory defects, and write a finish-or-archive decision after the urgent personal betas stabilize.

## Existing Products, Building Blocks, and Shortcuts

- [PyMuPDF](https://pymupdf.readthedocs.io/) exposes PDF text blocks, coordinates, annotations, links, and rendering; it can replace much of a custom PDF geometry layer.
- [Excalidraw](https://github.com/excalidraw/excalidraw) provides an embeddable hand-drawn diagram editor and portable JSON/SVG artifacts, while [Mermaid](https://mermaid.js.org/) is faster for deterministic generated diagrams.
- [OCRmyPDF](https://ocrmypdf.readthedocs.io/) can add OCR/text layers to scanned inputs before annotation. [Pandoc](https://pandoc.org/) plus an HTML/CSS or Eisvogel-style template is useful for clean derivative study books, while direct PyMuPDF overlays better preserve the original pagination.
- Existing alternatives such as Zotero’s PDF reader and Obsidian PDF annotation workflows solve highlight/note capture. The clever shortcut is a sidecar manifest and review panel first; regenerate the decorative PDF only after the notes are useful.

## Free-First Stack

- **Desktop shell:** Tauri with a React/Svelte review UI.
- **PDF parsing/rendering:** PyMuPDF or pdfplumber sidecar; HTML/CSS plus WeasyPrint/Pandoc where appropriate; preserve links with a PDF library.
- **Data:** SQLite or JSON manifest containing page anchors, source hashes, note types, and approvals.
- **Diagrams:** Excalidraw JSON/SVG and Mermaid.
- **Models:** local text/vision model; paid model only for selected difficult pages.
- **OCR later:** OCRmyPDF/Tesseract for authorized scans.

## Artifact Contract

Each annotation records source page, bounding box, source excerpt hash, author (`human` or model/recipe), confidence, review state, and target link. If source pagination changes, anchors fail visibly instead of silently attaching to the wrong text.

## Build Slices

1. PDF extraction and page-coordinate inspection.
2. Annotation manifest and review UI.
3. Grounded note generation with source excerpts.
4. Overlay renderer and hyperlink validation.
5. Diagram round-trip.
6. Theme layer and reproducible export.

## Success Measures

- Original content remains selectable and unchanged.
- Every annotation can be traced to its anchor and recipe.
- Links survive export and open the intended note/diagram.
- A chapter can be regenerated after editing annotations.
- The enriched PDF improves recall or problem-solving in a small self-test.

## Product Path

The personal tool can become an open-source document annotation studio. Paid versions could support teams, professional templates, stronger layout repair, and licensed educational annotation packs.

## Related

- [[Understand This Paper]]
- [[PhoneScan PDF]]
- [[Handwriting to LaTeX]]
- [[LongVid Learning Studio]]
- [[Project Ideas Index]]
