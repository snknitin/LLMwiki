---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#8. Feedback Mirror]]"
status: concept
difficulty: hard
priority: p2
category: wellness and vision
form_factor:
  - local kiosk
  - mobile app
deployment: on-device
source_ideas:
  - mirror that uses computer vision to analyze sleep and skin issues
tags:
  - computer-vision
  - wellness
  - privacy
---

# Feedback Mirror

> A privacy-first daily appearance journal that standardizes photos and combines them with self-reported sleep and routine data to show change over time—without diagnosing health from a face.

## Product Outcome

Under consistent lighting and pose, capture a short morning check-in. The tool measures limited observable image features, lets the user annotate sleep and skin context, and shows trends with confidence and image comparability warnings.

## Personal V0

- Guided capture with fixed distance, pose, exposure, and lighting target.
- Record self-reported sleep duration/quality, hydration/routine notes, and relevant context.
- Track user-chosen visual features such as redness-region intensity, under-eye brightness, or blemish count candidates.
- Overlay prior capture for alignment and show change with raw images.
- Flag incomparable captures caused by lighting, blur, or pose.
- Keep all frames local with delete/export controls.
- Offer a neutral weekly journal, not a health or attractiveness score.

## Build Boundary

**MVP:** one device, standardized capture, local timeline, self-report fields, and two clearly defined non-diagnostic image measurements.

**Later:** calibrated lighting hardware, dermatologist-reviewed measures, routine experiments, or wearable sleep import. Do not infer sleep disorders, stress, intoxication, disease, emotion, age, or attractiveness from facial imagery.

## Existing Products, Building Blocks, and Shortcuts

- [MediaPipe Face Landmarker](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker) can align pose/regions locally; [OpenCV](https://opencv.org/) handles blur, exposure, color, and transparent image metrics.
- Android [Health Connect](https://developer.android.com/health-and-fitness/guides/health-connect) or Apple HealthKit can provide user-selected sleep records; do not infer sleep from one facial frame when the operating system already stores actual observations.
- Consumer skin-analysis mirrors/apps demonstrate the UX but often hide lighting sensitivity. A fixed lamp, distance guide, neutral color card, and prior-image overlay may improve repeatability more than a larger model.
- Simplest alternative: guided daily selfie plus structured notes and blind self-rating. Add computer-vision measurements only when repeated manual comparison is genuinely slow.

## Free-First Stack

- **Client:** native mobile camera or a local kiosk using OpenCV.
- **Alignment:** MediaPipe face landmarks used only on-device for pose/region consistency, not identity.
- **Data:** encrypted local SQLite plus image folder with retention settings.
- **Analysis:** deterministic color/texture metrics with calibration card support.
- **Models:** avoid a general facial diagnosis model; a segmenter may help define regions after validation.
- **Charts:** raw-value timeline with capture-quality indicators.

## Clever Hacks and Simpler Alternative

- A daily selfie plus structured notes may answer the behavior question without computer vision.
- Use a neutral gray/color card and fixed lamp to reduce lighting changes that masquerade as skin changes.
- Compare within the same device and setup; never claim cross-device comparability.
- Blind the timeline date during self-rating to reduce expectation bias.
- Store derived metrics separately so the user can delete images while retaining chosen measurements.

## Build Slices

1. Guided capture and local private timeline.
2. Pose/light/blur comparability checks.
3. Two transparent measurements with overlays.
4. Self-report and lagged review.
5. Controlled personal experiment.

## Success Measures

- Repeated captures under the same conditions produce stable metrics.
- Lighting/pose changes are rejected rather than interpreted.
- The app reduces uncertainty without increasing appearance anxiety.
- No identity template or cloud face database exists.

## Product Path

Keep the prototype a personal visual journal. Health claims, public users, and recommendations create substantial clinical, fairness, privacy, and regulatory work; a validated capture tool for professionals is a different product.

## Related

- [[Measure Life]]
- [[Adaptive Vision Glasses]]
- [[Physio Atlas]]
- [[Project Ideas Index]]
