---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#8. Manga-to-Animatic Studio]]"
status: concept
difficulty: hard
priority: p3
category: generative media
form_factor:
  - desktop studio
deployment: DGX Spark plus workstation
source_ideas:
  - manga or webnovel to anime-style upcoming episodes
tags:
  - video-generation
  - animation
  - copyright
---

# Manga-to-Animatic Studio

> A local previsualization tool that turns user-supplied sequential art and prose into editable storyboards, timing, voices, and short animatics.

## Product Outcome

The system parses panels or scenes into shots, characters, locations, dialogue, camera direction, and continuity constraints. It proposes a storyboard and low-frame animatic that a human can edit before selectively generating expensive motion.

## Personal V0

- Import original/public-domain pages or a script.
- Segment panels and extract reading order, balloons, characters, and scene descriptions.
- Build a shot list with duration, framing, motion, dialogue, and asset references.
- Create consistent original character sheets and location boards.
- Render an editable storyboard timeline.
- Generate pan/zoom/parallax motion and synthetic scratch audio.
- Export an animatic plus project manifest and source attribution.

## Build Boundary

**MVP:** one short user-supplied scene, manual corrections, and storyboard-to-animatic.

**Later:** limited motion generation, lip sync, sound design, longer continuity, and collaborative editing. Release/licensing review is deferred until anything leaves the personal machine.

## Existing Products, Building Blocks, and Shortcuts

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI) is the practical node/workflow layer for local image/video generation and reproducible seeds. Use it as a render backend rather than embedding every model directly.
- [Blender Grease Pencil](https://docs.blender.org/manual/en/latest/grease_pencil/) handles storyboard/2D animation, camera moves, layers, and export; FFmpeg assembles frames/audio and applies deterministic timing.
- Storyboarder, EbSynth, Live2D-style rigs, and conventional 2.5D parallax are important alternatives to full video generation. Often they preserve continuity better at a fraction of the compute.
- Simplest alternative: panel crops → layer segmentation/depth → pan/zoom/parallax → mouth flaps → scratch audio. A strong animatic validates shot order and pacing before generated motion.

## Free-First Stack

- **Pipeline/UI:** ComfyUI workflows plus a Tauri/Gradio project editor.
- **Parsing:** OpenCV, OCR, and a vision-language model with manual panel/order correction.
- **Assets:** local image generation using original/reference-authorized designs; control maps and character adapters.
- **Motion:** Blender/Grease Pencil, FFmpeg, depth/parallax, and open video models for selected shots.
- **Audio:** local TTS for scratch tracks and royalty-free/user-owned effects.
- **Data:** JSON project manifest tracking source asset, prompt, seed, model/license, and shot versions.
- **Compute:** workstation for editing; DGX Spark queue for batch generations.

## Clever Shortcut

A compelling animatic does not need full video generation. Panel crops, layered depth, camera moves, mouth flaps, sound, and timing can communicate the episode at a fraction of the compute and continuity burden.

## Build Slices

1. Project/source manifest and manual shot list.
2. Panel segmentation and storyboard editor.
3. Character/location consistency sheets.
4. 2.5D animatic renderer and scratch audio.
5. One generated-motion shot with A/B evaluation.
6. Continuity checks and final export.

## Success Measures

- Shot order and dialogue remain faithful to authorized source material.
- Character/location continuity survives the full short scene.
- Human edits are retained across regeneration.
- Every generated asset records model and rights provenance.
- Animatic quality improves before compute use expands.

## Product Path

An eventual creator product could focus on project management, continuity, render queues, and collaboration. Run the deferred release audit before any public or commercial version.

## Related

- [[Neural Fractal Visualizer]]
- [[Song Phrase Mosaic]]
- [[Visual Token Compiler]]
- [[Project Ideas Index]]
