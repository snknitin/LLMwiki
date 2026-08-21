---
type: research-note
status: active
created: 2026-08-21
scope: personal-color-analysis-and-depth-aware-portrait-relighting
tags:
  - research
  - personal-color
  - color-science
  - computer-vision
  - relighting
  - webgpu
  - local-first
  - fashion
  - privacy
---

# Research - Personal Color Analysis and Depth-Aware Relighting

This dossier refines the rough idea of “Korean color therapy for clothes” into a technically honest local-first styling tool. It identifies the linked graphics demonstration from its released source code, separates seasonal personal-color analysis from medical chromotherapy, maps the relevant color-science and computer-vision building blocks, and proposes a build that treats uncertainty, capture conditions, and repeatability as product features rather than hiding them behind an authoritative season label.

## 1. Personal Color Relighting Studio

### Executive finding

The strongest version of the idea is **Personal Color Relighting Studio**: a private camera and photo app that helps a person compare clothing palettes around their own face, records a continuous color profile, and previews garments or colored virtual drapes with depth-aware lighting and occlusion. It should have two explicitly separated modes:

1. **Analysis mode** estimates a useful styling profile from a controlled capture and repeated A/B drape comparisons. It reports warm–cool direction, light–deep value, clear–muted chroma, and preferred contrast as continuous scores with confidence. A familiar 4-, 12-, or 16-season label is a summary, not the raw measurement.
2. **Visualization mode** makes virtual drapes, tops, and nearby colored light look spatially plausible. It is an aesthetic simulator and decision aid, not evidence that the analysis is correct.

The linked demo is highly relevant to the second mode but does not solve the first. It estimates monocular depth, derives approximate surface normals and occlusion, and applies a synthetic point light to the existing camera image. It does **not** recover the subject's illumination-independent skin reflectance, know the spectral properties of fabric and skin, remove the original light, or measure how real cloth would bounce light onto the face. Treating the demo as a diagnostic engine would create confident but camera-dependent results.

A better product promise is:

> Compare color families on your own face under a quality-checked capture, understand which dimensions you consistently prefer, and preview clothes with honest uncertainty—without uploading your selfie.

### Use the right name: personal color, not color therapy

The fashion practice is generally called **personal color analysis**, **seasonal color analysis**, **color typing**, or, in Korean, **퍼스널컬러 진단**. It aims to find clothing, hair, accessory, and makeup colors that a client or consultant judges harmonious with the client's appearance. “Korean personal-color analysis” usually signals the studio-style experience, detailed tone vocabulary, physical draping, and the Korean beauty/fashion market; it is not a separate law of optics.

**Color therapy/chromotherapy** is a different category. The US National Library of Medicine's MeSH vocabulary defines it as using color to influence health or treat physical or mental disorders ([NCBI MeSH: Color Therapy](https://www.ncbi.nlm.nih.gov/mesh/68016500)). This project should make no therapeutic, dermatological, psychological, or medical claim. Naming it “color therapy” would confuse a style tool with a complementary-health intervention and burden an otherwise playful product with claims it does not need.

Use these terms in the product:

- **personal-color profile** for the stored result;
- **virtual drape** for a flat or garment-shaped color placed near the face;
- **season palette** only for the optional label layer;
- **relighting preview** for synthetic light and color bounce;
- **capture confidence** for the reliability of the source image;
- **style inspiration, not diagnosis** in the public-facing disclaimer.

### What the linked depth-aware light injection actually is

The 20 August 2026 Reddit post says a 448×448 monocular-depth model runs in about 8 ms on an M4 Pro across roughly 250 GPU dispatches and that inference, lighting, and drawing share one command encoder ([original r/GraphicsProgramming post](https://www.reddit.com/r/GraphicsProgramming/comments/1vtecd8/depthaware_light_injection_all_running_in_browser/)). The credited X thread is by Konrad Reczko ([original X post](https://x.com/reczko_konrad/status/2089670934009413751)). The effect was released the following day as the **Monocular Light Injection** example in Software Mansion's open-source TypeGPU repository ([live source directory](https://github.com/software-mansion/TypeGPU/tree/main/apps/typegpu-docs/src/examples/image-processing/monocular-light-injection), [TypeGPU repository](https://github.com/software-mansion/TypeGPU)).

The source establishes a precise pipeline:

1. A camera frame is imported as a WebGPU external texture.
2. A converted **DepthART** model predicts 448×448 relative disparity. The published bundles are explicitly **affine-invariant relative disparity, not metric depth**; balanced bundles use selected FP16 tensors while keeping sensitive recurrence and reconstruction in FP32 ([reczkok/depthart-typegpu model card](https://huggingface.co/reczkok/depthart-typegpu), [upstream DepthART repository](https://github.com/xuefeng-cvr/DepthART)).
3. The renderer estimates and temporally stabilizes the disparity range, normalizes the map, and applies motion-aware temporal filtering ([renderer source](https://github.com/software-mansion/TypeGPU/blob/main/apps/typegpu-docs/src/examples/image-processing/monocular-light-injection/renderer.ts)).
4. A compute shader takes depth gradients to approximate surface slope/normals and samples neighboring depths for a height-field ambient-occlusion term.
5. A fragment shader places a user-controlled virtual point light, calculates wrapped Lambert-like diffuse lighting, an approximate specular lobe, distance falloff, ambient fill, local occlusion, and a screen-space shadow term. The shadow routine marches 32 samples through the relative-depth field; the result is a convincing 2.5D effect rather than full global illumination ([shader source](https://github.com/software-mansion/TypeGPU/blob/main/apps/typegpu-docs/src/examples/image-processing/monocular-light-injection/shaders.ts)).
6. Depth inference, surface preparation, and final rendering are encoded without reading the depth map back to JavaScript or CPU memory.

This is best described as **real-time monocular depth-assisted screen-space relighting** or **depth-aware light injection**. It is not neural radiance-field reconstruction, ray-traced path lighting, a measured reflectance field, or physically based relighting from a calibrated 3D scan.

The most consequential implementation detail is in the shader: it gamma-decodes the observed camera RGB and uses that value as `albedo` before multiplying in the new light. The original room illumination, white balance, facial shadows, makeup, camera tone mapping, specular highlights, and colored reflections are already baked into those pixels. Adding a new light does not undo them. The effect can make a virtual collar feel like it sits in the same scene, but it cannot turn an arbitrary selfie into a colorimetric measurement.

### Where depth helps—and where it does not

Depth is valuable for presentation:

- placing a colored virtual light in front of or behind the face;
- letting a hand or hair occlude a light or garment overlay;
- deriving coarse face/clothing normals so a flat tint follows apparent form;
- casting approximate shadows onto the background;
- separating foreground and background during an interactive live preview;
- making a drape below the chin feel less like a flat sticker.

Depth does not directly reveal:

- skin undertone or intrinsic pigmentation;
- the scene illuminant or camera white-balance transform;
- a fabric's spectral reflectance, weave, gloss, or translucency;
- the amount and spectrum of real interreflection from cloth to skin;
- metric distance in the released relative-depth bundle;
- the correct warm/cool season label;
- whether a color is aesthetically “harmonious” for a person.

The product architecture should therefore make relighting a downstream renderer that consumes a palette choice. It should never be the sole feature extractor that chooses that palette.

### Personal-color systems: useful vocabulary, not ground truth

The familiar four-season system groups palettes as Spring, Summer, Autumn, and Winter. Commercial systems expand these into 12 or 16 seasons with labels such as Light Spring, Soft Summer, Deep Autumn, or Bright Winter. Implementations disagree about boundaries and sometimes infer from hair and eye color, sometimes from skin response to physical drapes, and sometimes from a consultant's overall judgment. The Korean ecosystem often puts more emphasis on a detailed **tone** result and acceptable neighboring palettes than on a single exclusive season.

Two formal color systems can ground the palette data without pretending to standardize the person:

- South Korea's Agency for Technology and Standards provides Korean color standards covering color names, XYZ, three-attribute representations, CIELAB/CIELUV, and color differences. Its Korean Standard Color Analysis program was built around KS A 0062 and a digital palette of 2,676 standard and intermediate colors ([KATS color-standard information](https://www.kats.go.kr/content.do?cmsid=83), [KATS Korean Standard Color Analysis](https://kats.go.kr/content.do?cmsid=87)). These are standards for describing colors and communicating them, not an official algorithm that assigns humans to seasons.
- The Japan Color Research Institute's **Practical Color Co-ordinate System (PCCS)** is a hue–tone system. PCCS tone combines lightness and chroma into named families such as pale, vivid, dull, and deep, making it convenient for palette design and comparisons ([JCRI: What is PCCS?](https://www.jcri.jp/achievement_1)). Its official history describes PCCS as a color-design and harmony tool and notes that the original tone regions were not a continuous coordinate algorithm ([JCRI: PCCS revision](https://www.jcri.jp/square/journal/pccs_revision)).

Internally, store colors in a continuous device-independent working representation such as CIE XYZ/CIELAB or OKLab/OKLCH, then map them into KS/PCCS/season names for presentation. The open-source [Colour Science for Python](https://github.com/colour-science/colour) package supplies color-space conversion, chromatic adaptation, color correction, appearance models, and reference illuminants. For measured color differences, CIEDE2000 is standardized in ISO/CIE 11664-6:2022 ([CIE standard page](https://www.cie.co.at/publications/colorimetry-part-6-ciede2000-colour-difference-formula-1)).

The canonical profile should be continuous:

```yaml
personal_color_profile:
  temperature_direction: -0.32   # cool ... warm
  value_preference: 0.61         # deep ... light
  chroma_preference: -0.18       # muted ... clear
  contrast_preference: 0.74      # low ... high
  neutral_bias: 0.08
  season_posterior:
    cool_summer: 0.39
    soft_summer: 0.27
    clear_winter: 0.14
  capture_confidence: 0.76
  comparison_repeatability: 0.82
```

The season posterior can change when evidence changes. The continuous axes remain more useful for ranking an actual shirt than a hard label such as “Summer.”

### Refined product thesis

Build a **private personal-color laboratory**, not another one-shot selfie oracle. It combines:

- a guided, quality-scored capture;
- a neutral-card/calibrated mode for serious experiments;
- face, skin, hair, and clothing masks;
- pairwise virtual draping along controlled color axes;
- an optional season summary with competing alternatives and confidence;
- depth-aware interactive previews;
- a “does this garment suit my current profile?” camera/import check;
- a local palette and wardrobe decision log;
- repeated-session stability testing.

The product earns trust by saying “this capture is too warm,” “your last three sessions disagree,” or “the photo supports cool and muted but not a confident season” instead of manufacturing precision from every selfie.

A focused personal V0 should answer three questions:

1. Which warm/cool, light/deep, clear/muted, and contrast ranges do I repeatedly prefer around my face?
2. How does a particular clothing color compare with that profile?
3. Can I preview the color without uploading or regenerating my face?

Do not begin with makeup product matching, hair generation, body-shape typing, health/skin analysis, an influencer community, shopping affiliate links, or full virtual try-on. Each adds a different dataset and evaluation problem before the core color loop is credible.

### Existing products and the actual competitive wedge

The market is not empty. Several current products already promise one-selfie season typing and palettes:

- **Saekkal: Korean Color Analysis** is the closest comparator. Its App Store listing promises a Korean studio experience, a free season, palette, shopping checks, and an “AI Glow-Up” that relights the user's face in the season's light. Its release notes also acknowledge that a casual selfie cannot be perfect and include an honest retry path when a photo cannot be read ([Saekkal App Store listing](https://apps.apple.com/kr/app/saekkal-korean-color-analysis/id6780220092)). A product whose novelty claim is merely “selfie + Korean season + relit face” would already be behind this baseline.
- **Dressika** offers automatic or manual 12-season analysis, clothing and makeup palettes, hair/makeup try-on, and a virtual wardrobe ([Dressika App Store listing](https://apps.apple.com/kr/app/colour-analysis-dressika/id1536745174?l=en-GB)).
- **ColorNote** advertises a selfie-based season, 60+ palette swatches, a camera shopping checker, wardrobe coach, outfit calendar, and product-comparison flow ([ColorNote App Store listing](https://apps.apple.com/us/app/colornote-personal-color/id6761373344)).
- **Clad** is a Korean web service that shows a recommended and comparison color around the user's face as an AI drape ([Clad official site](https://www.your-personal-color.com/)).
- **MyColorLab** combines one-photo analysis with paid expert diagnosis ([MyColorLab official site](https://mycolorlab.com/landing)).
- **Color Lover Lab** provides palette cards, beauty-product tone checks, virtual makeup, and a Korean community app ([Color Lover App Store listing](https://apps.apple.com/kr/app/%EC%BB%AC%EB%9F%AC%EB%B2%84-%ED%8D%BC%EC%8A%A4%EB%84%90%EC%BB%AC%EB%9F%AC-%EC%A0%95%EB%B3%B4%EB%A5%BC-%ED%95%9C-%EB%B2%88%EC%97%90/id1516558813)).
- **Vella** claims on-device browser analysis without uploading the photo, showing that privacy can already be part of the value proposition ([Vella official site](https://www.getvella.app/)).

The practical differentiation is a combination competitors rarely expose together:

- local-first ownership with no account;
- capture calibration and visible quality gates;
- repeatability across sessions rather than one opaque answer;
- continuous profile axes plus uncertainty, not label-only output;
- user-controlled paired drapes rather than an unexplained classifier;
- open, depth-aware interactive relighting in the browser;
- an evaluation notebook/dashboard that measures device, lighting, and skin-tone stability;
- a correction/history trail that lets the owner learn whether the recommendations work in real outfits.

### Guided capture is the product's measurement instrument

An unconstrained JPEG selfie is a poor colorimeter. The pixel values depend on scene illumination, mixed lights, sensor spectral sensitivities, lens shading, exposure, auto white balance, HDR fusion, local tone mapping, skin-smoothing/beauty filters, image compression, display gamut, makeup, tanning, and nearby colored surfaces. Front and rear cameras on the same phone may produce different skin colors. A model can learn to imitate common labels despite these variables, but that is not the same as measuring stable personal color.

Offer two capture modes.

#### Casual mode

Designed for convenience and clearly lower confidence:

1. Use the rear camera when practical, at 1×, with no portrait/beauty/filter mode.
2. Ask for diffuse daylight or a high-quality neutral light; reject strong backlight, direct sun, mixed color temperatures, and large colored walls close to the face.
3. Frame face, neck, ears, and a little shoulder; remove colored glasses and, if the user wants undertone-oriented analysis, minimize tinted base makeup.
4. Detect clipping, motion blur, face angle, occlusion, underexposure, saturated highlights, and strong spatial color gradients.
5. Capture a short burst or video, then choose stable frames rather than trusting one instant.
6. Re-run with at least one materially different lighting condition and report agreement.

#### Calibrated mode

Designed for experiments and expert comparison:

1. Place a known neutral/ColorChecker target in the same plane and light as the face.
2. Let auto exposure and white balance converge, then lock them for the entire drape sequence where the device permits it.
3. Capture a neutral frame plus a physical warm/cool and muted/clear reference pair under unchanged camera settings.
4. Estimate a color-correction matrix or at minimum a neutral white-balance transform from the chart; store the transform and residual error.
5. Reject the session if reference-patch CIEDE2000 error or frame-to-frame neutral drift exceeds a chosen threshold.

Calibrite describes the ColorChecker Classic as a 24-patch physical reference for camera profiling and color accuracy ([ColorChecker Classic](https://calibrite.com/us/product/colorchecker-classic/?noredirect=en-US)). A cheap neutral card is a useful white-balance shortcut but cannot characterize the whole camera color response. A printed home-made chart is not automatically colorimetric because printer, ink, paper, age, and illumination change its patches.

Browser control is capability-dependent. The W3C Image Capture specification exposes optional capabilities for white-balance mode, color temperature, exposure mode/time/compensation, ISO, focus, and zoom ([W3C MediaStream Image Capture](https://www.w3.org/TR/image-capture/)). The app should inspect `getCapabilities()`, request or lock controls where supported, and record the actual `getSettings()` values. It must not assume that asking for a constraint means the camera applied it. A later native Android capture module can use Camera2 manual color-correction gains/transforms and AWB controls ([Android `CaptureRequest`](https://developer.android.com/reference/android/hardware/camera2/CaptureRequest)); AVFoundation exposes supported white-balance modes and locked gains/temperature/tint on iOS ([Apple AVFoundation white balance](https://developer.apple.com/documentation/avfoundation/capture-device-white-balance)).

### Capture-quality score

Compute a quality report before classifying:

| Signal | Example measurement | Response |
|---|---|---|
| Exposure | clipped skin-mask percentage; median linear luminance | retake if highlights or shadows destroy chroma |
| Sharpness | Laplacian/edge energy over eyes and skin | stabilize or retake |
| Lighting uniformity | CIELAB/chromaticity gradient across forehead and cheeks | warn on side light or mixed illumination |
| White balance | neutral-card a*/b* error, or illuminant estimate confidence | correct or reduce confidence |
| Face pose | yaw/pitch/roll and face-mask coverage | require near-frontal capture |
| Occlusion | hair, glasses, hand, mask, harsh specular coverage | exclude pixels or retake |
| Camera stability | burst-to-burst skin-patch ΔE and settings drift | lock controls or lower confidence |
| Skin coverage | number and spread of clean skin regions | do not classify from a tiny patch |
| Filter suspicion | inconsistent texture/tone curves or metadata | ask for unfiltered capture |

Never return a high-confidence personal profile from a capture that fails its own instrument checks.

### Face, skin, hair, and garment masks

Use geometry and semantic parsing together; neither alone is sufficient.

- Google's MediaPipe Face Landmarker runs in web/JavaScript, returns 478 3D landmarks, optional blendshapes, and transformation matrices, and is appropriate for stable facial regions and pose checks ([official Face Landmarker web guide](https://developers.google.com/edge/mediapipe/solutions/vision/face_landmarker/web_js)). Landmarks can define conservative cheek, forehead, jaw, neck, eye, and lip exclusion polygons.
- A face parser separates skin, hair, brows, eyes, lips, and background. The modified BiSeNet implementation trained on CelebAMask-HQ exposes a 19-class face parse and has an ONNX path suitable for local inference ([face-parsing repository](https://github.com/yakhyo/face-parsing)).
- MediaPipe Image Segmenter can return category or confidence masks in browser and is a small starting point for person/background separation ([official Image Segmenter web guide](https://developers.google.com/edge/mediapipe/solutions/vision/image_segmenter/web_js)).
- For garments, the official **Self-Correction for Human Parsing** implementation produces clothing/body labels; ATR and LIP taxonomies include upper clothes, dress, coat, pants, skirt, scarf, face, arms, and hair ([SCHP repository](https://github.com/GoGoDuck912/Self-Correction-Human-Parsing), [SCHP paper](https://arxiv.org/abs/1910.09777)). It is heavier than the face-only V0 but useful for wardrobe import and recoloring.

Create a **safe skin sampling mask**, not one average face color. Exclude eyes, brows, hair, lips, nostrils, beard-dense regions, glare, deep shadow, and pixels near segmentation boundaries. Sample multiple fixed anatomical regions and store robust statistics—median and interquartile range in linear RGB/XYZ/Lab—so one red cheek or forehead highlight cannot dominate the result. Keep the masks and quality overlays inspectable.

The [Monk Skin Tone scale](https://blog.google/innovation-and-ai/products/monk-skin-tone-scale/) is useful for stratifying evaluation and finding performance gaps, not for deciding a color season. Google's follow-up research shows that skin-tone annotation itself is subjective and can vary by annotator and geography ([Google Research: consensus and subjectivity of skin-tone annotation](https://research.google/blog/consensus-and-subjectivity-of-skin-tone-annotation-for-ml-fairness/)). Evaluate capture, segmentation, and recommendation stability across the full tone range; do not equate a tone bucket with race, undertone, or season.

### Analysis engine: prefer controlled comparisons over a mystery classifier

A one-shot vision model can be an optional opinion, but the first reliable engine should be a transparent comparison protocol.

#### Step 1: derive stable appearance descriptors

After capture correction and masking, estimate:

- skin-region Lab/OKLab distributions, not only a mean;
- hair and iris lightness/chroma when sufficiently visible, with low weight;
- face-to-hair/eye contrast at matched exposure;
- uncertainty caused by local lighting gradients and correction residuals;
- repeatability across frames and sessions.

Do not read “warm undertone” directly from positive `b*`. Nearly all skin photographs have warm/yellow components in a D65-referenced Lab representation, and camera/illuminant error can be larger than the difference the label claims to detect.

#### Step 2: run matched virtual drapes

Generate A/B pairs that differ primarily on one axis:

- warm versus cool hue direction with matched lightness/chroma;
- clear versus muted with matched hue/lightness;
- light versus deep with matched hue/chroma;
- low versus high face–garment contrast;
- bright neutral versus soft neutral;
- gold-like versus silver-like accessory surroundings as a separate visualization, not proof of undertone.

Show each pair in randomized left/right order and repeat a subset. Keep the face pixels unchanged in the baseline test so the user evaluates simultaneous contrast rather than an algorithm altering the evidence. Record choice, response time, certainty, and repeat consistency. A Bradley–Terry or Thurstone pairwise model can infer preference scores without pretending that any single comparison is decisive.

#### Step 3: optional simulated color bounce

Add a physically inspired but clearly labeled toggle that lets the drape contribute colored fill light to the lower face. Its strength should be conservative and controllable. Run this after the baseline, because changing the face can lead the user to prefer the renderer's effect rather than the garment color.

#### Step 4: map to palettes

Rank individual swatches and palette regions first. Then map the continuous scores into one or more season/tone labels. Show:

- primary result and two close alternatives;
- which comparisons drove the result;
- capture and repeatability confidence;
- colors that consistently won;
- colors that were inconclusive;
- a “use colors, hide season name” option.

This process produces personal evidence even when the seasonal taxonomy is disputed.

### Depth-aware virtual draping and garment recoloring

Implement visual realism in layers so each layer can be disabled and tested.

#### Layer A: flat virtual drape

Place a color field from shoulders downward, cut around neck/chin/hair with the face/person mask, and render it in a stable neutral viewing surround. This is enough for the core A/B experiment and should ship first.

#### Layer B: texture-preserving garment recolor

For an existing upper garment:

1. get an upper-clothes/dress mask from a human parser;
2. linearize the image;
3. separate low-frequency illumination from reflectance approximately, or preserve a luminance/shading channel;
4. replace target hue/chroma within the garment while retaining folds, edges, pattern detail, and specular structure;
5. protect skin, hair, jewelry, buttons, logos, and transparent material;
6. feather boundaries in a guided way rather than blurring across skin.

A simple OKLab/CIELAB recolor that preserves lightness can be useful for plain matte fabric. It is not physically exact: colored fabric changes diffuse reflectance across wavelengths, and glossy, patterned, translucent, very dark, or saturated clothing cannot be faithfully recolored by changing chroma alone.

#### Layer C: depth-aware light injection

Adapt TypeGPU's released Monocular Light Injection example. Use DepthART relative depth, reconstruct screen-space normals, and let a virtual drape or light source contribute a nearby tinted fill. Preserve debug views for camera/depth/normals so artifacts are visible. Add a slider that crossfades between unaltered-face baseline and simulated bounce.

For static photos, run depth once. Real-time inference is visually impressive but unnecessary for the first useful product. A precomputed depth map plus a small WebGPU shader lets the user explore hundreds of swatches with near-zero marginal model cost.

#### Layer D: higher-fidelity offline relighting

If the fast shader is insufficient, evaluate more expensive local approaches as a separate renderer:

- **Intrinsic image decomposition** attempts to separate reflectance/albedo from shading. The `compphoto/Intrinsic` research code outputs linear albedo, diffuse shading, residual/specular components, and white-balanced variants, enabling illumination-aware recoloring and per-pixel white balance ([project repository](https://github.com/compphoto/Intrinsic)). Its implementation is restricted to academic use, so it is a private research reference rather than a default product dependency.
- Google's **Total Relighting** research models foreground matting plus diffuse and specular appearance under a novel HDR environment from one RGB portrait ([project page](https://augmentedperception.github.io/total_relighting/)). It demonstrates the extra appearance components missing from a pure depth shader.
- **IC-Light** is an official Apache-2.0 diffusion-based illumination-editing project with text- and background-conditioned models ([official IC-Light repository](https://github.com/lllyasviel/IC-Light)). It can produce attractive offline renders on the DGX/workstation, but a generative model may modify identity, skin texture, makeup, hair, or clothing details and should never feed back into the analytical profile.

Keep analytical pixels and generated preview pixels in different data products. The app should always offer “show original face” and a difference heatmap.

### Local-first architecture and free-first stack

The best V0 is a browser application that can run entirely on one device, with an optional local GPU sidecar for heavier models.

#### Browser client

- **App:** React or SvelteKit + TypeScript + Vite PWA. No account; camera/file inputs; IndexedDB via Dexie for profiles, sessions, and small assets.
- **Camera:** `getUserMedia`, Image Capture capabilities, burst/video frame selection, capability-aware exposure/white-balance locks, and an explicit device/settings record.
- **Landmarks and coarse masks:** MediaPipe Tasks Vision in a Web Worker.
- **Depth and rendering:** fork the TypeGPU Monocular Light Injection example, pin a known TypeGPU commit, and cache the selected `depthart-relative-*-448` bundle. Use the small or balanced bundle only after comparing quality on hair, shoulders, hands, and background edges.
- **Color math:** TypeScript implementations backed by test vectors for sRGB linearization, XYZ/Lab/OKLab conversion, chromatic adaptation, gamut mapping, and CIEDE2000. Cross-check against Colour Science for Python.
- **Graphics:** WebGPU/TypeGPU for live relighting; Canvas 2D/WebGL2 fallback for masks and flat drapes.
- **Exports:** local PNG profile card, swatch palette, JSON/CSV session record, and an HTML report that includes confidence and capture metadata.

WebGPU is a good fit because compute and rendering can share GPU resources. ONNX Runtime Web is the safer generic inference fallback: its official WebGPU execution provider supports GPU tensors and IO binding so outputs can stay on the GPU, while its WASM provider covers devices without the required GPU/operator support ([ONNX Runtime Web WebGPU guide](https://onnxruntime.ai/docs/tutorials/web/ep-webgpu.html), [ONNX Runtime Web overview](https://onnxruntime.ai/docs/tutorials/web/)). Feature-detect, benchmark once, and route to TypeGPU, ONNX WebGPU, or WASM rather than assuming the demo's M4 Pro latency on every phone.

#### Optional local sidecar

- **API:** Python 3.12 + FastAPI/Pydantic bound to localhost.
- **Vision:** PyTorch/ONNX Runtime for face/human parsing, intrinsic decomposition experiments, and optional high-quality relighting.
- **Color:** Colour Science + OpenCV/NumPy.
- **Store:** SQLite with original assets in content-addressed local directories; face crops remain local and deletable.
- **Hardware routing:** CPU for color math and static masks, desktop GPU for heavy parsing/relighting, DGX Spark for batch evaluation or optional IC-Light-quality previews. The browser result remains usable when the sidecar is off.

#### Suggested records

```yaml
capture_session:
  id: uuid
  created_at: timestamp
  device_hash: local-pseudonymous-id
  camera_facing: environment
  resolution: [width, height]
  track_settings: {}
  exif: {}
  lighting_mode: casual_daylight | neutral_card | colorchecker
  correction_matrix: [ [...], [...], [...] ]
  correction_residual_delta_e: 2.4
  quality_signals: {}
  source_asset_hash: sha256:...

observation:
  session_id: uuid
  region_id: left_cheek
  mask_version: face-parser-v1
  linear_rgb_median: [...]
  lab_median: [...]
  dispersion: {}
  excluded_fraction: 0.18

drape_trial:
  session_id: uuid
  left_swatch_id: pccs-...
  right_swatch_id: pccs-...
  randomized_order: true
  renderer: flat_original_face | depth_bounce_v1
  choice: left | right | tie
  confidence: 0.7
  response_ms: 3120

garment_check:
  asset_hash: sha256:...
  sampled_colors: []
  profile_version: uuid
  match_distribution: {}
  user_outcome: loved | wore | returned | inconclusive
```

Version the capture pipeline, masks, palette, renderer, and inference model. Otherwise a software update can silently change a person's “season” without an audit trail.

### Build sequence

#### Slice 0 - Color laboratory fixtures

Implement tested sRGB/linear RGB/XYZ/Lab/OKLab conversions, chromatic adaptation, gamut mapping, and CIEDE2000. Create synthetic fixtures plus photographs of a ColorChecker under several lights. Verify against Colour Science outputs before touching season labels.

#### Slice 1 - Flat-drape personal experiment

Capture or upload one frontal photo, run Face Landmarker, create conservative facial/neck masks, and show randomized matched A/B drapes while preserving the face pixels. Store choices locally and infer four continuous preference axes. This is the smallest useful product.

#### Slice 2 - Capture quality and repeatability

Add burst capture, lighting/exposure/blur checks, supported camera locks, neutral-card correction, session comparison, and a refusal/retake state. Repeat the experiment under three sessions and visualize how stable the profile is.

#### Slice 3 - Depth-aware preview

Port the TypeGPU example behind a feature flag. Precompute depth for still photos, show depth/normals debug views, and add a conservative colored fill/drape bounce with an original-face crossfade. Measure latency, memory, battery, boundary quality, and crash rate on target devices.

#### Slice 4 - Garment checker

Add upper-clothing segmentation, representative garment-color extraction, a “matches profile” ranking with explanations, and texture-preserving recolor for plain garments. Let the user correct the garment mask and sampled color.

#### Slice 5 - Battle-test and expert calibration

Create a repeated-capture study and, if useful, compare with one or more in-person draping sessions. Record expert disagreement rather than manufacturing one ground-truth label. Tune capture rejection and profile uncertainty before adding a paid model.

#### Slice 6 - Product extensions

Only after the loop proves useful, consider wardrobe inventory, store-page/share-sheet intake, shopping comparison, native capture controls, family profiles, high-quality DGX relighting, or a hosted/private-sync product.

### Battle-testing plan

The evaluation must separate instrument quality, model behavior, renderer quality, and personal usefulness.

#### Capture and color repeatability

Use the same subject and reference chart across:

- front versus rear camera;
- at least three phone/camera models;
- daylight, neutral LED, tungsten, fluorescent/mixed light, side light, and backlight;
- exposure and white-balance lock on/off;
- casual versus neutral-card/ColorChecker correction;
- no makeup versus common base makeup if that is part of the intended use.

Measure neutral-patch and ColorChecker CIEDE2000 error, within-session skin-region ΔE, between-session ΔE after correction, clipping, and the rate at which quality gates reject bad inputs. A correction pipeline that lowers chart error but increases skin-region instability needs investigation, not celebration.

#### Segmentation and geometry

Build a consented personal fixture set with manual masks for clean skin, hair, face, neck, upper garment, glasses, jewelry, and background. Score IoU/F1 and boundary error. Stratify results by hair texture/color, facial hair, head coverings, glasses, pose, complexion, clothing pattern, and illumination. Inspect depth edges around hair, fingers, shoulders, and the chin; relative-depth temporal flicker can create crawling shadows even when average depth metrics look good.

#### Profile stability

For each participant/session, compute:

- axis-score variance and confidence-interval width;
- A/B repeat-trial agreement;
- top-1 and top-3 season agreement;
- rank correlation of favorite swatches;
- sensitivity to renderer mode: unchanged face versus simulated bounce;
- sensitivity to camera/lighting after correction;
- fraction of sessions correctly returned as “inconclusive.”

Do not define accuracy solely as agreement with one commercial consultant. If expert comparison is used, recruit multiple qualified analysts, measure inter-rater agreement, preserve their full palette judgments, and treat consensus as a reference—not physical truth.

#### Relighting fidelity

Test the fast shader on scenes with hands crossing the face, hair strands, glasses, specular skin, patterned clothes, dark clothes, a plain wall, cluttered background, and a real colored lamp. Evaluate:

- depth and normal stability;
- false shadows and light leaking at silhouettes;
- identity/texture preservation versus the original;
- frame-time percentiles, model-load time, memory, battery and heat;
- whether the added light preserves skin detail without clipping;
- whether users can distinguish the unchanged-face analytical view from the simulated view.

If a light-stage or synthetic ground-truth set is available, add PSNR/SSIM/LPIPS and illumination-direction error. For ordinary selfies without ground truth, qualitative realism is not evidence of physical correctness.

#### Real-world utility

The decisive outcome is not season-classification accuracy. Track whether the owner:

- reopens the palette while shopping;
- correctly extracts a garment color despite lighting;
- wears/reuses recommended colors;
- returns fewer color-mismatch purchases;
- can explain why a color was ranked;
- revises the profile from lived outcomes;
- trusts “inconclusive” more than an obviously unstable confident label.

Let users label purchases/outfits after a week. Those outcomes create a personal preference model that may outperform a generic seasonal taxonomy.

### Main drawbacks, concerns, and failure modes

- **A very close product already exists.** Saekkal already offers Korean season analysis, shopping checks, and a relit-face feature. The build must win on calibration, local processing, transparency, interactivity, and longitudinal evidence—not the headline feature list.
- **One selfie is underdetermined.** Unknown light and camera processing can move skin chromaticity enough to flip fine-grained labels. Bad captures should be rejected.
- **Personal color is partly subjective.** Different systems and consultants can disagree; a season label is not a biological fact. Prefer ranking and confidence.
- **The depth demo is not de-lighting.** It adds light to pixels that already contain illumination. Original shadows and color casts remain, and relative depth does not encode material reflectance.
- **Virtual drapes can manipulate the evidence.** If the renderer changes skin pixels, users may choose the nicest algorithmic retouch rather than the best clothing color. Always compare with an unaltered-face baseline.
- **Screen colors are not cloth colors.** Display gamut, calibration, ambient light, fabric spectra, texture, and finish change appearance. Hex codes are directions, not guarantees of a retail garment match.
- **Color extraction from shop photos is unreliable.** Product pages have studio lighting, edited white balance, multiple variants, compression, and screen/display transforms. Let the user sample/correct and show uncertainty.
- **Hair and eye inference can encode brittle heuristics.** Dyed hair, contacts, glare, dark irises, veiling reflections, and segmentation errors make these secondary signals.
- **Makeup changes observed color.** Foundation, blush, bronzer, lipstick, sunscreen and skin treatments can materially change the capture; the app must ask what use case is intended.
- **Darker skin is not a season.** Algorithms and training sets can conflate lightness with contrast or undertone. Slice every metric across the skin-tone range and test recommendation parity.
- **Mixed illuminants defeat global white balance.** Window daylight plus warm room light produces spatially varying casts. A single 3×3 correction matrix cannot fix local mixed lighting.
- **Monocular depth fails at fine boundaries.** Hair, glasses, hands near the face, transparent fabric, mirror reflections, and flat backgrounds can yield wrong occlusions and shadow trails.
- **WebGPU performance is device-specific.** The quoted 8 ms is one M4 Pro result, not a mobile guarantee. Model download, shader compilation, f16 support, thermal throttling, GPU driver blocks, and browser implementation all matter.
- **Generative relighting can alter identity.** Diffusion-based previews may smooth skin, change facial structure, or invent details. Keep them out of the measurement path and expose differences.
- **Privacy expectations are unusually high.** Selfies, inferred facial geometry, and wardrobe photos feel biometric even if not used for recognition. Default to ephemeral/local processing, explicit save, and one-click deletion.
- **Season labels can narrow rather than help.** Users may avoid loved colors due to an authoritative badge. Provide flexible ranges, neutrals, accent roles, and personal override history.
- **Calibration can create false seriousness.** A neutral card improves reproducibility but does not make aesthetic harmony objective. The app must explain what was calibrated and what remains judgment.

### Clever hacks and simpler alternatives

1. **Ship flat drapes before depth.** The core learning is whether structured A/B comparison and a local palette help the owner. Depth is a visual upgrade, not the minimum viable engine.
2. **Use the released TypeGPU example as the renderer fixture.** Fork and pin it instead of re-implementing depth inference, disparity stabilization, normals, shadows, and GPU plumbing from scratch. Keep its debug modes.
3. **Run depth once per still.** Real-time 8 ms inference is unnecessary when comparing a static selfie; cache depth/normals and render swatches interactively.
4. **Never relight the analytical baseline.** Put an unchanged-face view beside the preview. This single design rule prevents the prettification engine from becoming its own evidence.
5. **Pairwise comparisons beat a giant quiz.** Matched A/B drapes isolate one variable, produce consistency metrics, and train a personal preference model without requiring labeled season data.
6. **Calibrate only when calibration data exists.** Casual mode should not hallucinate a precise camera correction. Calibrated mode should show chart residuals and fail closed.
7. **Use the rear camera plus a mirror/voice countdown.** Rear cameras often provide better hardware and fewer beautification defaults; a spoken capture guide avoids needing the screen close to the face.
8. **Offer a neutral-surround mode.** Hide colorful app chrome and use a controlled gray background during comparisons so the interface does not bias color perception.
9. **Rank actual swatches, not just seasons.** A person can like one cobalt blue even if a taxonomy calls it outside their season. Store item-level outcomes and learn from them.
10. **Use physical drape photos as the gold personal dataset.** Record short, locked-exposure clips while real fabrics are swapped. This captures real interreflection and gives the virtual renderer a subject-specific comparison set.
11. **Make a browser bookmark/share intake later.** A user can screenshot or upload a garment image in V0; scraping e-commerce catalogs and handling variants can wait.
12. **Treat color names as views.** One canonical Lab/OKLCH swatch can display KS, PCCS, season, common, and user nicknames without duplicating color data.
13. **Store decisions, not selfies, by default.** Keep palette/profile JSON and discard raw frames after deriving approved measurements unless the owner chooses to save a source image.
14. **Use stability as the confidence model.** Repeated measurements on the same person under controlled variants are more informative than a language model's self-reported confidence.
15. **Simplest useful alternative:** a fully offline web page with one photo, a facial cutout, randomized flat drapes, four sliders, and local JSON export. It can validate the personal workflow before any classifier, depth model, database, or native app exists.

### Recommended product path

#### Private V0

Build the flat-drape comparison laboratory, guided capture, local profile, and cached depth-aware preview. Use it on the same person over several weeks, compare recommendations with worn clothes, and improve the capture rejection rules.

#### Personal wardrobe assistant

Add garment-photo import, mask correction, dominant fabric colors, match ranking, outfit history, and shopping screenshots. Keep the reason trace: “good hue direction, slightly too muted, strong contrast.”

#### Expert-assisted tool

Allow an analyst to run a physical draping session, record ranked swatches, and export a calibrated digital palette. The software becomes a repeatable capture/report tool rather than claiming to replace the expert.

#### Public product

Offer on-device analysis, a transparent confidence report, and premium native capture/wardrobe features. Depth-aware live preview is the demo-worthy acquisition hook; repeatability and private processing are the trust wedge.

#### Research/open-source path

Open-source the capture quality grader, pairwise draping protocol, color math, TypeGPU renderer adaptation, and evaluation harness. A consented, calibration-rich benchmark across devices, illuminants, skin tones, and expert opinions would be more valuable than another unlabeled selfie-season classifier.

### Future scope and release reminder

For a public, open-source, collaborative, medical-adjacent, or paid release, re-check model/code/data licenses, the current license and attribution requirements of TypeGPU and converted DepthART bundles, camera and platform policies, biometric/privacy laws, face-photo retention and deletion, user consent, accessibility and color-vision needs, fairness evaluation, advertising claims, expert credentials, age-related rules, e-commerce image access, and whether a generated/relit image must be labeled. Keep the product explicitly outside medical diagnosis or treatment. These future checks should not change the recommended private/local stack; they belong in the release checklist and deployment policy.

### Related ideas

- [[AR Scale Lens]] — shares monocular depth, capability checks, confidence overlays, and camera-device validation.
- [[Adaptive Vision Glasses]] — shares real-time camera processing, local privacy, color filters, and the need to distinguish assistive effects from medical claims.
- [[Visual Token Compiler]] — shares deterministic visual outputs, GPU rendering, source/debug views, and representation-specific evaluation.
- [[Personal Library Website]] — can later surface saved wardrobe palettes and outfit decisions without owning the vision pipeline.
- [[Scope Expansion Checklist]] — deferred public-release, data, accessibility, and product diligence.
- [[Project Ideas Index]] — portfolio navigation.
