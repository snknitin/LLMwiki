---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Information and Learning Ideas#9. Handwriting to LaTeX]]"
status: concept
difficulty: medium
priority: p1
category: math utility
form_factor:
  - desktop hotkey
  - mobile capture
deployment: local-first
source_ideas:
  - convert handwritten or printed equations into LaTeX for Overleaf
tags:
  - latex
  - ocr
  - handwriting
---

# Handwriting to LaTeX

> A local screenshot/camera utility that converts one isolated handwritten or printed equation into editable LaTeX, renders it immediately, and makes ambiguity correction faster than retyping.

## Product Outcome

Press a hotkey, drag around an equation, receive LaTeX plus a rendered preview, fix uncertain symbols, and copy to Overleaf or Markdown. The tool earns trust through a correction loop rather than a single confidence score.

## Personal V0

- Capture a screen region or import a cropped image.
- Normalize contrast, orientation, padding, and resolution.
- Run local math OCR and parse the output.
- Render with KaTeX/MathJax beside the original crop.
- Highlight likely ambiguous tokens and show alternatives.
- Let corrections update a private confusion map.
- Copy LaTeX or a complete display/inline wrapper.

## Build Boundary

**MVP:** one isolated equation, desktop hotkey, local inference, rendered preview, correction, and clipboard.

**Later:** phone capture, matrices/cases, full mixed pages, stylus strokes, Overleaf extension, and batch notebooks. Full-page handwriting introduces layout and separate text/math recognition and should not block the high-value crop tool.

## Existing Products, Building Blocks, and Shortcuts

- [LaTeX-OCR/pix2tex](https://github.com/lukas-blecher/LaTeX-OCR) already supports local image-to-LaTeX, screenshots, GUI, clipboard, and an API. Benchmark it before training anything.
- [Mathpix OCR](https://docs.mathpix.com/) is a paid fallback for difficult handwriting and mixed math; call it only for low-confidence crops and compare cost against manual correction.
- [KaTeX](https://katex.org/) or [MathJax](https://www.mathjax.org/) gives instant rendered validation, while [TrOCR](https://github.com/microsoft/unilm/tree/master/trocr) can help with surrounding prose but is not a two-dimensional math parser.
- Simplest alternative: a tray hotkey that captures one equation, calls `pix2tex`, renders the result, and copies on confirmation. This captures most value without notebooks, accounts, or a full-page layout model.

## Free-First Stack

- **Model:** local `pix2tex`/LaTeX-OCR for the first benchmark.
- **Pipeline:** Python, PyTorch, Pillow/OpenCV, and a LaTeX parser.
- **Shell:** Tauri system tray or a lightweight Qt app.
- **Preview:** KaTeX/MathJax.
- **Data:** SQLite correction history with input hash, model version, prediction, and corrected LaTeX.
- **Paid fallback:** Mathpix only for low-confidence cases after measuring correction time and privacy tradeoffs.

## Clever Hacks and Simpler Alternative

- Try a small set of normalized resolutions; agreement between predictions is a useful confidence signal.
- Show alternatives only for ambiguous spans rather than five full equations.
- Validate brace balance and command syntax before rendering “success.”
- Preserve stylus stroke order when available; it contains information absent from a photo.
- Crop narrowly. Equation segmentation is often harder than recognition.

## Build Slices

1. Hotkey/crop and local model call.
2. Preview, parser errors, and clipboard.
3. Ambiguity/correction UI.
4. Resolution ensemble and regression corpus.
5. Phone/stylus adapter.

## Battle-Testing Gates

- A rights-clean corpus of at least one hundred personal equations with corrected ground truth.
- Exact or normalized structural accuracy tracked by expression type.
- Low-confidence and parse-failure states are explicit.
- A correction never contaminates unrelated symbols.
- The time saved exceeds correction time on the user’s real notes.

## Product Path

The isolated-equation hotkey is a useful free/open tool. A paid product must win on messy handwriting, mixed pages, collaboration, or mobile workflow; audit model and training-data licenses before commercial use.

## Related

- [[Understand This Paper]]
- [[Half-Blood PDF]]
- [[Personal Study Curriculum]]
- [[Project Ideas Index]]
