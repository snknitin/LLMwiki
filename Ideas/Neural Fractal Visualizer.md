---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#12. Neural Fractal Visualizer]]"
status: concept
difficulty: medium
priority: p1
category: creative coding
form_factor:
  - desktop visualizer
  - browser app
deployment: local-first
source_ideas:
  - fractal geometry with neural networks, spectral and sacred geometry, Winamp-style playback
tags:
  - fractals
  - audio-reactive
  - shaders
  - creative-coding
---

# Neural Fractal Visualizer

> A deterministic audio-reactive fractal and spectral-shape engine with patchable presets; neural models are optional controllers, not a requirement for rendering.

## Product Outcome

Play local audio or microphone input and produce a responsive visual performance from FFT bands, onsets, tempo, and slowly changing “mood” state. Users design or remix presets, record deterministic performances, and export smooth offline video.

## Personal V0

- Analyze FFT, RMS, spectral bands, onset, and beat candidates.
- Render ten shader presets spanning fractals, symmetry, particles, and geometric motifs.
- Map audio features to parameters through an editable matrix.
- Save presets, transitions, random seed, and audio hash.
- Provide reduced-motion and safe-flash controls.
- Record parameter streams or rerender offline at a fixed timestep.
- Export frames/video through FFmpeg.

## Build Boundary

**MVP:** browser/desktop audio input, WebGL2 shaders, five stable presets, mapping editor, and safe-flash mode.

**Later:** WebGPU, preset graph, section detection, tiny neural interpolation model, live performance controls, and community packs. A neural network should be added only when it beats transparent mappings in a named task.

## Existing Products, Building Blocks, and Shortcuts

- Winamp MilkDrop and [projectM](https://github.com/projectM-visualizer/projectm) are direct prior art for audio-reactive presets. You can embed or learn from projectM before writing an entire preset ecosystem.
- [Shadertoy](https://www.shadertoy.com/) demonstrates portable fragment-shader experiments; [Web Audio AnalyserNode](https://www.w3.org/TR/webaudio-1.1/) provides FFT/time-domain data in the browser.
- Three.js/regl/WebGL2 supplies rendering, Tauri wraps the desktop app, and FFmpeg handles fixed-timestep offline export. ONNX Runtime Web is optional for a tiny section/interpolation model.
- Simplest alternative: five hand-authored shaders plus an audio-feature-to-parameter matrix. Neural rendering is unnecessary until transparent mappings hit a specific limitation.

## Free-First Stack

- **App:** TypeScript, Web Audio, WebGL2/Three.js/regl, and Tauri.
- **Shaders:** GLSL with performance budgets and fallback quality tiers.
- **Export:** FFmpeg with offline fixed-step rendering.
- **Optional ML:** ONNX Runtime Web for section classification/interpolation.
- **Data:** JSON preset/mapping schema and deterministic seeds.
- **Testing:** GPU timing, screenshot snapshots, and flash-rate analysis.

## Clever Hacks and Simpler Alternative

- Use a slow latent “mood” state plus fast onset pulses; direct FFT-to-pixel mapping is noisy.
- Hash audio plus preset so a performance is reproducible.
- Train a small model to interpolate hand-designed parameter states rather than generate pixels.
- Render exports offline even if live preview drops frames.
- Cap luminance changes and iteration count per quality tier.

## Build Slices

1. Audio feature bus and one shader.
2. Preset/mapping schema and five presets.
3. Transition/mood state and performance controls.
4. Safe-flash/reduced-motion modes.
5. Deterministic offline export.
6. Optional neural controller experiment.

## Battle-Testing Gates

- Frame-time budgets hold on the target workstation and a weaker device.
- No preset exceeds configured flash thresholds in safe mode.
- Audio/preset/seed reproduces the same parameter stream.
- Offline exports preserve timing and avoid dropped-frame artifacts.

## Product Path

This is a fast, satisfying personal creative-coding project with potential as an open-source visualizer, VJ tool, or preset platform. DGX training is optional; the shader and interaction quality are the product.

## Related

- [[Audio Watermark and Perception Lab]]
- [[Manga-to-Animatic Studio]]
- [[Yu-Gi-Oh RL Lab]]
- [[Project Ideas Index]]
