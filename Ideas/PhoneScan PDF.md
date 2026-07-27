---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#10. PhoneScan PDF]]"
status: concept
difficulty: medium
priority: p2
category: document capture
form_factor:
  - mobile app
deployment: on-device
source_ideas:
  - phone scan PDF
tags:
  - scanner
  - pdf
  - ocr
  - privacy
---

# PhoneScan PDF

> A local-first document scanner that detects pages, corrects perspective and curl, improves readability, performs optional OCR, and exports a searchable PDF with explicit privacy presets.

## Product Outcome

Point the phone at a page, receive a clean preview, fix corners if needed, scan a batch, reorder/rotate, select a color mode, OCR locally, and export one standards-friendly PDF. The differentiator is inspectable local processing and reproducible quality, not generic “AI scanning.”

## Personal V0

- Live page-edge detection and capture-quality cues.
- Automatic crop, perspective correction, rotation, and shadow/background cleanup.
- Manual corner correction with magnified handles.
- Batch pages with reorder, delete, and rescan.
- Original, document-color, grayscale, and black/white outputs.
- Optional local OCR and searchable text layer.
- Export PDF plus a scan manifest; strip location metadata by default.

## Build Boundary

**MVP:** Android first, flat pages, edge detection, perspective correction, batch PDF, and local save/share.

**Later:** dewarping curved books, receipts/forms, OCR languages, redaction, archival PDF profiles, and desktop post-processing. The scanner market is mature, so treat this as a personal utility/learning project unless a specialist workflow appears.

## Existing Products, Building Blocks, and Shortcuts

- Adobe Scan, Microsoft Lens, Apple Notes scanner, and Google Drive scanning establish the expected capture/crop/OCR UX; a local prototype should target a specialist quality/privacy gap.
- [OpenCV](https://opencv.org/) covers contours, homography, thresholding, blur/sharpness, and dewarp primitives; Google [ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition/v2) or Tesseract supplies on-device OCR.
- [OCRmyPDF](https://ocrmypdf.readthedocs.io/) can deskew, OCR, optimize, and create searchable PDFs after phone capture; [ScanTailor Advanced](https://github.com/4lex4/scantailor-advanced) is desktop prior art for page cleanup.
- Simplest alternative: camera saves images to a watched folder; a desktop pipeline runs OpenCV/OCRmyPDF and returns a verified PDF. Build the native camera app only if capture guidance is the missing value.

## Free-First Stack

- **Client:** Kotlin/CameraX for Android or Swift/AVFoundation/VisionKit on iOS.
- **Vision:** OpenCV for contours/homography and quality metrics.
- **OCR:** ML Kit on-device, Tesseract, or PaddleOCR after benchmarking the target scripts.
- **PDF:** platform/PDF library that supports images, text layers, metadata, and page transforms.
- **Desktop helper:** OCRmyPDF for heavy local OCR/deskew on exported scans.
- **Data:** temporary local files with immediate cleanup and explicit retention.

## Clever Hacks and Simpler Alternative

- A desktop pipeline that watches a folder of phone photos may deliver value before a new camera app.
- Capture a short burst and select the sharpest frame instead of trusting one shutter moment.
- Use page-size priors and document corners to stabilize live guidance.
- Preserve the original image in the project until export is verified.
- Measure OCR word accuracy and PDF size together; aggressive thresholding can hurt both.

## Build Slices

1. Camera capture and manual corners.
2. Automatic edge/crop/perspective pipeline.
3. Batch editor and PDF export.
4. OCR text layer and search validation.
5. Dewarp, redaction, and specialist presets.

## Battle-Testing Gates

- A varied fixture set covers lighting, shadows, colored paper, glossy pages, and skew.
- Exported PDFs reopen, print, search, and preserve page order.
- Original images survive until the user confirms export.
- Temp files and EXIF are cleaned according to the selected privacy mode.
- OCR and file size meet a documented target for the personal corpus.

## Product Path

Use it to learn camera/PDF/OCR infrastructure and feed [[Half-Blood PDF]] or [[EPUB Highlights Bridge]]. A standalone paid scanner needs a defensible vertical such as private legal intake, field forms, or book dewarping.

## Related

- [[Half-Blood PDF]]
- [[Handwriting to LaTeX]]
- [[Visual Token Compiler]]
- [[Project Ideas Index]]
