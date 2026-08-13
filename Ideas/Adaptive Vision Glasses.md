---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#11. Adaptive Vision Glasses]]"
status: concept
difficulty: hard
priority: p3
category: assistive vision
form_factor:
  - mobile magnifier
  - optional wearable display
deployment: on-device
source_ideas:
  - self-adjusting AI glasses for zoom, focus, distance, and clarity
tags:
  - accessibility
  - glasses
  - computer-vision
  - health
---

# Adaptive Vision Glasses

> A safe electronic magnifier prototype with zoom, contrast, autofocus lock, OCR, and text-to-speech—not a self-prescribing optical or medical device.

## Product Outcome

Help with specific near/far tasks such as reading labels, seeing a whiteboard, freezing small text, or navigating a menu. The user selects a task profile; the camera pipeline prioritizes low latency, readable contrast, context preservation, and privacy.

## Personal V0

- Phone camera with optical/digital zoom and autofocus lock.
- Freeze frame and pan around a high-resolution still.
- Contrast, inversion, color filters, edge emphasis, and brightness presets.
- OCR plus reflowed large text and text-to-speech.
- Wide-context view with a zoomed inset.
- Large accessible controls and per-task profiles.
- No retention unless the user explicitly saves a frame.

## Build Boundary

**MVP:** phone-based magnifier tested for one personal task.

**Later:** clip-on monocular display, smart-glasses camera input, eye tracking, hands-free voice control, and professional user studies. Do not claim to measure or correct refractive error, diagnose eye disease, restore vision, or make driving/unsafe activities suitable.

## Existing Products, Building Blocks, and Shortcuts

- Apple [Magnifier](https://support.apple.com/en-us/111779) and Android Lookout/Magnification are the consumer baselines for zoom, filters, detection, and descriptions. Benchmark the target task against them before building hardware.
- CameraX/AVFoundation provides zoom and focus control; ML Kit/Apple Vision handles OCR; platform TTS reads reflowed text. These cover most of the first product without an AI model.
- OrCam, eSight, and wearable magnifiers are product references for hands-free assistive vision, but their hardware complexity should not influence the phone prototype.
- Simplest alternative: phone magnifier with freeze frame, wide-context + zoom inset, contrast profiles, OCR/reflow, and speech. A monocular display is justified only if hands-free use is the measured gap.

## Free-First Stack

- **Android:** Kotlin, CameraX, ML Kit/on-device OCR, OpenGL/RenderScript replacements or GPU shaders.
- **iOS alternative:** SwiftUI, AVFoundation, Vision, and Metal.
- **Speech:** platform TTS offline where supported.
- **Wearable:** prototype with a phone-in-headset or permitted wearable SDK only after the phone experience proves value.
- **Data:** local preferences; no frame history by default.
- **Models:** conventional image processing first; local vision model only for explicit scene/text tasks.

## Clever Hacks and Simpler Alternative

- OCR plus layout reflow often beats extreme zoom for dense text.
- Use a zoom inset over a wide view to preserve orientation.
- Create task profiles with a real user rather than a universal “AI clarity” slider.
- A freeze-frame button removes hand tremor from the hardest reading moment.
- Add a physical privacy shutter/visible camera state before building a wearable.

## Build Slices

1. Camera, freeze, zoom, and autofocus lock.
2. Contrast/filter profiles and large controls.
3. OCR, reflow, and speech.
4. Wide-plus-inset view and latency measurement.
5. Usability tests.
6. Optional display hardware with optical/accessibility expertise.

## Risks and Validation

Digital zoom loses detail; field of view, display brightness, latency, battery, heat, nausea, and obstructed peripheral vision can make wearable versions unsafe. Involve an optometrist/low-vision professional before prescription-like or medical claims, and test only in controlled non-driving contexts.

## Product Path

The phone magnifier can be a useful open assistive tool even though operating systems already offer strong baselines. A hardware product requires a specific unmet task, accessibility co-design, optical engineering, safety testing, and a regulatory review.

## Related

- [[AR Scale Lens]]
- [[Feedback Mirror]]
- [[Event Networking Copilot]]
- [[Project Ideas Index]]
