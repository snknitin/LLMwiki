---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Color Analysis and Depth-Aware Relighting#1. Personal Color Relighting Studio]]"
status: concept
difficulty: hard
priority: p2
category: personal styling and computational photography
form_factor:
  - mobile-first local web app
  - guided selfie capture tool
  - WebGPU virtual draping studio
deployment: browser and desktop workstation first then optional native mobile
source_ideas:
  - Korean-style personal color analysis for clothes from a selfie or portrait
  - depth-aware light injection for interactive garment color and lighting previews
tags:
  - personal-color
  - color-science
  - computational-photography
  - WebGPU
  - depth-estimation
  - virtual-try-on
  - fashion
---

# Personal Color Relighting Studio

> Turn a calibrated selfie into a private digital draping room: compare clothing palettes without changing the face, understand which color dimensions consistently work, and preview garments under explicitly simulated lighting with a depth-aware WebGPU renderer.

## Product Outcome

Build a local-first personal styling studio with two deliberately separate jobs:

1. **Personal-color analysis:** guide the user through a controlled capture and pairwise digital draping session, then rank clothing colors along temperature, value, chroma, and contrast dimensions. A familiar Korean-style four-, twelve-, or sixteen-season label can summarize the result, but the useful output is a ranked palette with evidence and uncertainty.
2. **Depth-aware visualization:** segment the person and garment, estimate monocular depth, and let the user move a virtual light or recolor clothing while approximately preserving shading, texture, facial identity, occlusion, and scene depth.

The product should answer practical questions—“does this muted teal work better than this bright coral?”, “is the issue hue, brightness, saturation, or contrast?”, “would this shirt still work under warm indoor light?”—rather than issuing an unexplained seasonal verdict from one uncontrolled selfie.

The output is a personal **color passport**: best and difficult color ranges, neutrals, accent colors, contrast level, comparison cards, capture confidence, lighting assumptions, saved wardrobe swatches, and corrections from real wear. It should help the user shop and combine clothes, not diagnose health or claim that a palette objectively changes the person's body.

## What the Field Is Called

The Korean fashion/beauty practice is usually called **personal color analysis** (`퍼스널 컬러`) or **seasonal color analysis**, not color therapy. “Color therapy” can imply chromotherapy or a health treatment and should not be the product category.

Korean analysis often describes colors through dimensions such as warm/yellow-base versus cool/blue-base, light versus deep value, clear/bright versus muted/soft chroma, and the wearer's contrast. Systems then package those axes as four seasons or finer twelve-, sixteen-, or tone-based palettes. A 2007 Korean study proposed a KOSCOTE textile-color analysis method using face, eye, hair, wrist, and scalp observations, while a 2024 comparison found that four consumer apps all used seasonal palettes but differed in diagnostic color ranges and interaction methods ([KOSCOTE study](https://www.kci.go.kr/kciportal/ci/sereArticleSearch/ciSereArtiView.kci?sereArticleSearchBean.artiId=ART001220845), [application comparison](https://www.kci.go.kr/kciportal/ci/sereArticleSearch/ciSereArtiView.kci?sereArticleSearchBean.artiId=ART003166084)). That variation is a reason to preserve measured axes and user preference evidence instead of presenting the season name as scientific ground truth.

## How Depth-Aware Light Injection Fits

The linked [Reddit demonstration](https://www.reddit.com/r/GraphicsProgramming/comments/1vtecd8/depthaware_light_injection_all_running_in_browser/) credits Konrad Reczko's [X post](https://x.com/reczko_konrad/status/2089670934009413751). Its description reports a 448×448 monocular-depth model running around 8 ms on an M4 Pro across roughly 250 GPU dispatches. Inference is written directly in TypeGPU, so the depth buffer flows into the lighting pass and draw commands through one GPU command encoder without a CPU readback. The implementation is now available as TypeGPU's [Monocular Light Injection example](https://github.com/software-mansion/TypeGPU/tree/main/apps/typegpu-docs/src/examples/image-processing/monocular-light-injection), backed by converted [DepthART TypeGPU bundles](https://huggingface.co/reczkok/depthart-typegpu) that output affine-invariant relative disparity rather than metric depth.

That is excellent prior art for an interactive **appearance renderer**:

- Depth discontinuities let a virtual light fall differently on the face, hair, torso, hand, wall, and background.
- Depth gradients can approximate surface normals for diffuse lighting.
- Screen-space depth can produce approximate occlusion and cast-shadow cues.
- Keeping inference and rendering on the GPU can make live comparison responsive in a browser.

It does **not** solve personal-color measurement by itself. Monocular depth estimates geometry, not the true surface reflectance, camera white balance, spectral power of the real light, subsurface skin scattering, garment BRDF, or indirect illumination. The released shader gamma-decodes the observed camera color and treats it as the albedo-like base, so original shadows, white balance, tone mapping, makeup, and colored reflections remain baked in. Relighting an already tinted selfie can compound the original color error. Use it after capture validation for visualization and robustness experiments, never as a magic recovery of “true skin tone.”

## Product Modes

### Calibrated Capture

Guide distance, pose, exposure, neutral background, natural or high-CRI diffuse light, removal of filters, and placement of an inexpensive gray/color reference. Reject captures with clipped channels, mixed color temperatures, deep facial shadows, strong makeup, colored bounce, motion, beauty filters, or unreliable face size. Save the untouched original plus metadata before processing.

### Digital Draping

Place standardized fabric-color panels around the face while keeping face pixels unchanged. Show A/B pairs or small sets in random order, first isolating value and chroma and then temperature and contrast. Let the user record “better,” “worse,” “both,” or “cannot tell,” plus what changed: redness, shadows, jaw definition, eye contrast, perceived evenness, or simply personal preference.

### Wardrobe Mirror

Segment an existing shirt, jacket, scarf, or top and recolor it in a color-managed space while retaining luminance variation and texture. Compare saved garments against the ranked palette and generate side-by-side contact sheets. This is an approximation, not a product-color guarantee.

### Relighting Lab

Move a virtual key/fill light, change its color temperature and intensity, and compare the same palette under declared conditions. The renderer may show depth-aware direct light and shadows; it must label whether ambient/indirect light, material reflectance, and de-lighting are approximated or absent.

### Color Passport and Closet

Save measured axes, season hypotheses, best/worst swatches, neutrals, combinations, real garment photos, confidence, capture conditions, and real-world feedback. The model should be allowed to learn that a person prefers a color despite a consultant/system classification.

## Personal V0

Build a useful version before real-time depth or an autonomous classifier:

- Capture one front-facing portrait under diffuse daylight with a neutral gray card or known reference swatches in frame.
- Run automatic quality checks and let the user correct the face/hair/clothing masks.
- Keep the skin and hair unchanged; render standardized digital fabric drapes around the face.
- Present 30–50 pairwise comparisons chosen to isolate value, chroma, temperature, and contrast rather than asking whether hundreds of colors “look good.”
- Fit a personal preference/ranking model from those comparisons and produce a palette with uncertainty, adjacent-season candidates, and avoided extremes.
- Recolor one manually selected top using a texture-preserving blend and export a comparison contact sheet.
- Save the capture, masks, decisions, palette, and user notes locally so a second session can test repeatability.
- Compare the result with ten garments the user already knows they love or avoid.

Only after this static workflow is useful should V0.2 add monocular depth, estimated normals, and an interactive point/key light. The first “alpha” is the controlled comparison protocol and correction data, not a visually impressive relighting demo.

## Capture and Color-Management Protocol

1. **Original preservation:** retain the original image, EXIF/metadata where available, browser/device identifiers, dimensions, transfer function assumption, and a content hash. Never evaluate from a social-media screenshot when the original is available.
2. **Camera gate:** ask the native/browser camera for fixed exposure and white balance where supported; otherwise capture several frames and reject unstable automatic-white-balance changes.
3. **Reference detection:** detect a neutral gray card or small reference palette and record confidence. Apply a documented correction transform; never silently “beautify” skin.
4. **Linearization:** convert sRGB-like input to linear-light values before photometric blending. Keep display-referred and corrected working images as separate derived assets.
5. **Region selection:** use landmarks and segmentation to propose cheek, forehead, neck, hair, iris, lip, garment, and background regions. Exclude highlights, deep shadow, facial hair, glasses, makeup, and occlusion; show the sample mask to the user.
6. **Feature extraction:** compute robust region statistics in CIE Lab/OKLab and explicit contrast measures. Treat undertone/season as an inference over features and comparisons, not a direct pixel label.
7. **Drape comparisons:** render colors around the face instead of recoloring the face. Randomize left/right and repeat anchor comparisons to measure intra-session consistency.
8. **Confidence:** combine capture quality, reference quality, mask confidence, repeated-choice agreement, and model uncertainty. If the image is unsuitable, request another capture instead of inventing a precise palette.

Display calibration remains a boundary: an uncalibrated phone cannot guarantee that a swatch appears colorimetrically identical to fabric. Store numerical color values and profiles, expose a calibration card/test, and phrase remote results as comparative guidance.

Browser camera controls are capability-dependent. Inspect `getCapabilities()` and verify `getSettings()` rather than assuming a requested constraint was applied; the W3C [MediaStream Image Capture specification](https://www.w3.org/TR/image-capture/) defines optional white-balance, color-temperature, exposure, ISO, focus, and zoom capabilities. A later native client can expose stronger Camera2/AVFoundation locks only if V0 repeatability proves that browser control is the limiting error.

## Build Boundary

**MVP:** guided still-image capture/upload; reference-card correction; face/garment masks with manual edits; digital drape A/B comparisons; ranked palette and season hypotheses; static garment recoloring; local color passport; repeatability/evaluation report.

**Later:** real-time WebGPU depth and relighting; native camera-control client; live video; multi-garment closet; retailer/product swatch ingestion; material-aware recoloring; haircut/makeup accessories; professional-consultant mode; calibrated multi-device sync; social sharing.

Do not begin with generative outfit replacement, an e-commerce marketplace, autonomous shopping, skin-health analysis, or a claim of professional diagnostic equivalence. Each adds separate data and evaluation problems before the color-comparison loop is trustworthy.

## Existing Products, Building Blocks, and Shortcuts

- The linked [depth-aware light-injection demo](https://www.reddit.com/r/GraphicsProgramming/comments/1vtecd8/depthaware_light_injection_all_running_in_browser/) is the closest rendering inspiration. [TypeGPU](https://github.com/software-mansion/TypeGPU) provides a typed TypeScript layer for WebGPU and a route for keeping model dispatches, depth, lighting, and drawing in one GPU pipeline. Treat the post's performance as one M4 Pro demonstration, not a cross-device target.
- [Saekkal: Korean Color Analysis](https://apps.apple.com/kr/app/saekkal-korean-color-analysis/id6780220092) is the closest consumer comparator: its listing already combines a Korean studio-style season/palette, shopping checks, an AI relit-face “glow-up,” and a retry path when a selfie cannot be read. This project must differentiate through calibration, unchanged-face trials, local ownership, continuous axes, session repeatability, and an inspectable interactive renderer.
- [Dressika](https://dressika.com/) and [My Best Colors](https://www.mybestcolors.com/) represent the existing selfie/season/palette product category. The 2024 Korean [consumer-app comparison](https://www.kci.go.kr/kciportal/ci/sereArticleSearch/ciSereArtiView.kci?sereArticleSearchBean.artiId=ART003166084) found meaningful differences among application palettes, reinforcing the need for a transparent axis/ranking model and repeatability tests.
- [MediaPipe Face Landmarker](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker) provides on-device face landmarks and blendshape/transformation outputs for images and live streams. Use landmarks for stable regions and UI alignment; they do not by themselves provide photometric skin truth.
- [MediaPipe Image Segmenter](https://ai.google.dev/edge/mediapipe/solutions/vision/image_segmenter) and Meta's [Segment Anything 2](https://github.com/facebookresearch/sam2) are useful segmentation references. A small person/clothing model with manual mask correction is faster than making SAM2 a browser requirement.
- [Depth Anything V2](https://github.com/DepthAnything/Depth-Anything-V2) provides monocular relative-depth models at multiple sizes. Pin the exact model and license; relative depth is sufficient for approximate ordering/normals but not metric geometry or true material reconstruction.
- [ONNX Runtime Web](https://onnxruntime.ai/docs/tutorials/web/) supports browser inference with WebAssembly, WebGL, WebGPU, and WebNN execution paths subject to model/operator/device support. [Transformers.js](https://huggingface.co/docs/transformers.js/index) is another convenient browser model route; benchmark rather than assuming all mobile GPUs behave like a laptop M4 Pro.
- The W3C [WebGPU specification](https://www.w3.org/TR/webgpu/) defines the portable GPU interface, while browser support and adapter limits still require feature detection and a still-image/WASM fallback.
- [OpenCV](https://docs.opencv.org/4.x/d8/d01/group__imgproc__color__conversions.html) supplies explicit color conversion, calibration, masking, and image-processing primitives. The Python [Colour](https://github.com/colour-science/colour) project implements color-science conversions and color-difference calculations useful for an offline evaluation harness.
- [IC-Light](https://github.com/lllyasviel/IC-Light) is strong local prior art for prompt/condition-guided image relighting. It is better suited to an optional high-quality offline render than to the measurement path because generative relighting can alter identity, skin, garment details, and color.
- The [KOSCOTE personal-color study](https://www.kci.go.kr/kciportal/ci/sereArticleSearch/ciSereArtiView.kci?sereArticleSearchBean.artiId=ART001220845) and later Korean color-coordinate studies are domain prior art, not universal validation of one seasonal ontology. Use them to seed drape libraries and evaluation questions while retaining neutral/adjacent outcomes.
- South Korea's KATS publishes [Korean color-standard information](https://www.kats.go.kr/content.do?cmsid=83) and a [Korean Standard Color Analysis](https://kats.go.kr/content.do?cmsid=87) program grounded in color coordinates and differences; Japan Color Research Institute documents [PCCS](https://www.jcri.jp/achievement_1) as a hue/tone design system. These are useful color-description and palette systems, not official algorithms for assigning people to seasons.

## Recommended Free-First Stack

- **Client:** React, TypeScript, Vite PWA, Canvas/SVG for static drapes, and a color-managed comparison UI. Keep file upload and static rendering usable when WebGPU is absent.
- **GPU renderer:** WebGPU through TypeGPU for compute, depth-to-normal, lighting, masks, and compositing. Use one canonical shader/pipeline manifest and capture GPU/browser/device telemetry.
- **Browser inference:** ONNX Runtime Web or Transformers.js for a small face/person segmenter and compact monocular-depth model. Gate model choice by operator coverage, download size, memory, latency, and actual device benchmarks.
- **Local analysis service:** Python 3.12, FastAPI, Pydantic, OpenCV, NumPy, PyTorch/ONNX, and Colour for calibration, offline model comparison, ground-truth fixture generation, and report creation.
- **Models:** MediaPipe face landmarks; a small portrait/garment segmenter; the pinned `depthart-relative-*-448` TypeGPU bundle for reproducing the linked relighting path; Depth Anything V2 Small as a comparative relative-depth baseline; optional SAM2 and IC-Light only on the desktop/DGX path.
- **Storage:** IndexedDB through Dexie for a browser-only V0; SQLite in the optional local sidecar for larger libraries, evaluation runs, and cross-tool queries; content-addressed local folders for originals, masks, depth, corrected working images, and exports.
- **Color representation:** retain original device values and assumed/profiled input; do math in linear RGB and CIE Lab/OKLab as appropriate; use ΔE00 for controlled target/reference evaluation while avoiding the claim that one color-difference formula predicts human attractiveness.
- **Testing:** Vitest for transforms/ranking/layout, Playwright for capture-to-passport flows, pytest for calibration and metrics, golden images for shaders, and cross-browser/device benchmark manifests.
- **Packaging:** local web service first. Add a Tauri desktop wrapper or native React Native/Expo camera client only when browser camera controls, performance, or file access are demonstrated bottlenecks.

## Architecture and Data Model

`CaptureSession` stores original hash, timestamp, device/browser/camera metadata, dimensions, declared lighting, exposure/white-balance stability, filters/makeup/context answers, and quality gates. `ReferenceTarget` stores patch identities, expected color values/profile, detected polygons, observed values, correction transform, residual errors, and confidence. `RegionMask` stores semantic class, model/version, probability map, manual patch, and provenance. `AppearanceSample` stores the exact derived-image version, region, pixel-selection rules, linear-RGB/Lab/OKLab statistics, exclusions, and uncertainty.

`ColorAxisProfile` stores posterior/ranking estimates for temperature, value, chroma, and contrast plus neutral/unknown states. `PaletteHypothesis` maps those axes to a named system and stores alternatives, not one irreversible label. `DrapeTrial` stores colors, order/randomization, render manifest, choice, reason tags, response time, and repeated-anchor consistency. `Garment` stores source image, mask, original sampled colors, material notes, favorite/avoid feedback, and real-world observations. `RelightingFrame` stores depth/model, scale convention, normals, light parameters, occlusion/shadow settings, color space, shader version, and artifacts. `ColorPassportRevision` freezes the source sessions, comparisons, palette, confidence, model versions, and corrections used for an export.

Keep three image layers distinct:

1. **Original evidence:** immutable camera/image input.
2. **Analysis working image:** explicitly corrected/linearized image used for region features.
3. **Visualization render:** synthetic drapes, recoloring, or relighting that must never feed back into measurement as if it were captured evidence.

## Analysis and Ranking Model

Start with pairwise preference learning rather than a black-box season classifier. Choose comparison pairs that isolate one or two dimensions, include repeated anchors, and fit a Bradley–Terry/Elo-like score or a small Bayesian preference model. Use active learning to show the next pair whose answer most reduces uncertainty around the user's boundaries.

Generate the passport in layers:

- measured/corrected appearance features with capture confidence;
- repeated user comparisons and consistency;
- ranked swatches and axis ranges;
- best-fit and adjacent named seasonal/tone palettes;
- garments that confirm or contradict the lab result;
- explicit “insufficient evidence” where capture or choices disagree.

If a trained classifier is added, compare it with the pairwise system and professional drape labels on people, cameras, and skin tones held out by identity. Never use celebrity images split randomly across frames; that leaks identity and styling correlations.

## Depth-Aware Rendering Pipeline

1. Decode and linearize the frame; preserve the original.
2. Run person/face/garment segmentation and temporal smoothing for video.
3. Run pinned DepthART relative-disparity inference for the released TypeGPU path and compare it with an alternative such as Depth Anything V2; apply edge-aware refinement around hair, hands, shoulders, and garment boundaries.
4. Derive approximate view-space normals from depth gradients, with confidence/edge guards.
5. Construct a simple screen-space light: direction/position, color, intensity, falloff, diffuse term, optional rim/fill, and depth-based visibility/shadow approximation.
6. Estimate or expose an ambient/base-light term. Do not subtract the unknown original illumination so aggressively that face or fabric identity changes.
7. Recolor the garment in linear/OKLab space, preserving selected luminance/texture bands and compositing with an edge-aware alpha mask.
8. Re-encode for the target display/export and attach a manifest saying which effects are simulated.

Single-image de-lighting, albedo estimation, indirect light, specular fabric, translucent hair, and subsurface skin are underdetermined. A conservative renderer that lets the original shading remain visible is more trustworthy than a “physically accurate” label it cannot support.

## Build Slices

1. **Color truth fixture:** create controlled photos with gray/color references; implement decoding, reference detection, correction, region sampling, and ΔE/reporting.
2. **Static drape lab:** face alignment, unchanged-face fabric panels, randomized A/B trials, repeated anchors, and session export.
3. **Preference passport:** axis ranking, active pair selection, uncertainty, adjacent palette mapping, saved garments, and local history.
4. **Garment recolor:** manual mask first, texture-preserving swatches, comparison contact sheet, and face-pixel invariance tests.
5. **Automatic masks:** landmarks plus lightweight portrait/garment segmentation, confidence overlay, and manual correction.
6. **Depth spike:** pinned compact depth model in browser, depth visualization, edge metrics, latency/memory telemetry, and still-image normals.
7. **Interactive relighting:** TypeGPU light injection, occlusion/shadow approximations, preset manifests, static fallback, and before/after export.
8. **Repeatability battle test:** multiple days, phones, daylight/indoor conditions, makeup/no makeup, garments, and skin tones; quantify drift and refusal quality.
9. **Native capture only if needed:** lock camera controls, raw/wide-gamut input, or live performance through a thin mobile client after the PWA proves value.

## Evaluation and Battle Testing

Build a consented personal test set with controlled neutral/reference captures, deliberately bad captures, professional or multi-rater drape assessments where available, pairwise user judgments, and real garment outcomes. Keep all images local and separate identities across train/test if any classifier is trained.

Measure each layer separately:

| Layer | Measures |
|---|---|
| Capture | clipped-channel rate, AWB/exposure drift, reference detection, correction residual ΔE00, quality-gate precision/recall |
| Regions | face/skin/hair/garment IoU, boundary error, excluded-shadow/highlight accuracy, manual correction time |
| Color profile | same-session and cross-day repeatability, device/lighting drift, adjacent-palette uncertainty, pairwise test-retest agreement |
| Garment render | unchanged-face pixel error, hue/value target error in cloth, texture/edge preservation, halo rate, blind realism/preference |
| Depth/relighting | depth boundary quality, temporal flicker, latency, GPU memory, light-direction consistency, occlusion/shadow artifacts |
| Product utility | time to a usable passport, known-garment agreement, shopping decisions avoided or improved, later correction rate |

Use professional seasonal labels as one noisy reference, not absolute truth. Report inter-rater agreement and let the user's repeated real-world preference/outcome outrank a brittle label. Compare at least: raw one-selfie classifier, calibrated feature classifier, pairwise draping, pairwise plus real-garment feedback, and professional consultation where possible.

## Drawbacks, Concerns, and Failure Modes

- **Single-selfie color error:** automatic white balance, exposure, HDR, display tone mapping, compression, filters, and mixed light can change skin and fabric more than the seasonal boundary. Reject or recalibrate rather than overconfidently classify.
- **Relighting is not de-lighting:** adding virtual light to an image with unknown illumination does not recover albedo or ground-truth appearance. Keep analysis and visualization pipelines separate.
- **Season systems disagree:** four-, twelve-, sixteen-, PCCS-, and consultant-specific palettes do not share one ontology. Store axes, source system, alternatives, and uncertainty.
- **Subjectivity disguised as measurement:** “harmonious,” “healthy,” or “washed out” can encode preference, culture, makeup, styling, and observer bias. Capture reason tags and outcomes instead of pretending one metric defines beauty.
- **Skin-tone and demographic bias:** face detectors, segmenters, color correction, reference datasets, and consultant labels may fail unevenly. Evaluate across a broad range of skin tones, ages, facial hair, head coverings, and hair colors; measure refusal and error separately.
- **Makeup and modifications:** foundation, blush, tanning, dyed hair, colored contacts, skin treatments, and camera beauty filters confound both measurement and the intended styling context. Record rather than silently remove them.
- **Colored environmental bounce:** walls, clothes, screens, windows, and mixed bulbs tint skin. A gray card can help global correction but cannot fully undo spatially varying illumination.
- **Display/fabric mismatch:** screens emit RGB light; fabric reflects a spectrum and changes under illuminants. A screen preview cannot guarantee an online garment or real textile match, especially with fluorescent or iridescent materials.
- **Metamerism:** two samples can match under one light and diverge under another. RGB photos cannot reconstruct full spectral reflectance.
- **Garment segmentation artifacts:** hair, fingers, jewelry, scarves, sheer fabric, patterns, and similar backgrounds cause halos or recolor skin. Manual mask correction remains first-class.
- **Depth artifacts:** monocular models can flatten hair, confuse mirrors, misorder hands/torso, and produce unstable video edges. Confidence masks and static fallback matter more than forcing a live effect.
- **Generated relighting drift:** diffusion relighters may change facial structure, skin tone, garment design, logos, or body shape. Never use their output as measurement evidence.
- **False precision:** a 16-season label and exact hex palette can look objective despite weak input. Show capture, model, and preference confidence separately.
- **Privacy:** unfiltered face/body images and wardrobe history are sensitive. Keep originals and embeddings local by default, offer deletion/export, and avoid cloud inference unless explicitly selected.
- **Performance variability:** the linked M4 Pro number does not predict ordinary Android/iPhone/Windows browser behavior. Benchmark feature support, thermals, downloads, memory, and battery on target devices.

For the current single-user prototype, process the user's own images locally and keep the proposed stack. Before public release, professional-consultant claims, retailer ingestion, multi-user face storage, or hosted inference, use [[Scope Expansion Checklist]] for consent, biometric/privacy treatment, model/data licenses, fashion-image rights, accessibility, bias evaluation, consumer-protection language, and platform terms.

## Clever Hacks and Simpler Alternative

- **Do not recolor the face.** Put standardized virtual fabric around it. This protects the measurement target and makes before/after comparisons auditable.
- Ask the user to include a small neutral/color target. A ₹200–₹1,000 physical reference can add more diagnostic value than a much larger relighting model.
- Use repeated blind A/B trials and active learning. Thirty informative comparisons can reveal stable boundaries better than a one-shot “you are Soft Summer” prompt.
- Begin with manual garment masks. Five seconds of correction produces cleaner evidence than weeks spent chasing universal clothing segmentation.
- Save favorite and regretted garments as weak supervision. Real-world wear feedback grounds the palette in the user's goals and can reveal that one axis matters more than the season label.
- Add a **lighting stress test**: render or recapture top colors under cool daylight, warm indoor, and mixed-light warnings. Show which rankings are stable.
- Compute a face-invariance assertion for every garment render; fail export if protected face pixels changed beyond a tiny compositing tolerance.
- Offer an honest `flat drape`, `texture-preserving recolor`, and `depth-lit preview` badge so users know what was simulated.
- Precompile depth/segmentation models and cache GPU pipelines; keep the depth buffer on-device/GPU and never round-trip it through JavaScript each frame.
- Make a contact-sheet export that includes original, calibrated capture, top drapes, avoided drapes, capture confidence, and color values. This is more useful for shopping than a glamorous generated portrait.
- Simplest alternative: skip depth, automatic season classification, and garment segmentation. Build a calibrated digital swatch A/B tester plus a local wardrobe log. If repeated choices do not predict favorite garments, the full relighting studio has no validated product signal.

## Success Measures

- A guided capture either passes documented quality gates or clearly explains why another image is required; it never silently forces a result.
- Reference-patch correction reaches a defined ΔE00 target on the controlled devices/lighting used for V0.
- Protected face pixels remain unchanged in flat-drape and garment-recolor modes, apart from explicitly displayed global color-management transforms.
- Pairwise choices show useful repeatability across randomized repeats and a second day, with uncertainty when they do not.
- Top-ranked colors agree more often with known favorite garments and blinded user comparisons than raw one-selfie and generic seasonal baselines.
- Results remain reasonably stable across two devices and declared acceptable lighting, or the confidence score correctly drops.
- Garment-mask correction takes under thirty seconds for ordinary tops and exports have no visible skin recolor or edge halo in the accepted set.
- The still-image depth/relighting path meets a target-device latency and memory budget before live video is attempted.
- A model/pipeline manifest can reproduce every passport and render from the stored original and user decisions.
- All originals, masks, profiles, and corrections can be exported and deleted locally without an account.

## Product Path

Calibrated personal drape tester -> repeatable private color passport and wardrobe log -> static garment recoloring -> depth-aware WebGPU lighting lab -> native live mirror -> optional consultant collaboration and retailer swatch/product integrations.

The valuable moat is longitudinal correction and controlled comparison, not a magical season label or a generic relit-face effect that close competitors already ship. Keep the personal build local and free-first; add cloud synchronization, accounts, professional reports, affiliate shopping, or public sharing only after repeatability and user utility survive real wardrobe decisions.

## Related

- [[Feedback Mirror]]
- [[Adaptive Vision Glasses]]
- [[Visual Token Compiler]]
- [[Local Video Generation Evaluation Lab]]
- [[Project Similarity and Reuse Map]]
- [[Project Ideas Index]]
- [[Scope Expansion Checklist]]
