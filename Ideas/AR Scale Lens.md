---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#1. AR Scale Lens]]"
status: concept
difficulty: hard
priority: p2
category: augmented reality
form_factor:
  - mobile app
deployment: on-device
source_ideas:
  - visualize distances and measurements with a phone camera and AR
tags:
  - ar
  - computer-vision
  - mobile
---

# AR Scale Lens

> A camera tool that makes an abstract measurement feel physical by placing correctly scaled lines, rectangles, rooms, and familiar reference objects into the live scene.

## Product Outcome

Typing “91 cm,” “2,000 sq ft,” or a known object dimension should create a spatial overlay the user can walk around. A photo mode can anchor dimensions to selected points; an imagination mode can place a known-size object in a room for comparison.

## Personal V0

- Choose length, area, or height and enter a value with units.
- Detect a floor or wall plane and place a dimension line or rectangle.
- Drag endpoints, snap to surfaces, and show uncertainty.
- Save an annotated photo with units and scale assumptions.
- Offer reference objects such as a door, bed, parking space, or person silhouette.
- Reopen saved scenes when platform anchors permit it.

## Build Boundary

**MVP:** Android first, horizontal floor measurements, manual anchor placement, supported ARCore device, and photo export.

**Later:** depth-aware occlusion, automatic object measurement, iOS ARKit version, room plans, shared scenes, and real-estate workflows. It must not claim survey-grade accuracy.

## Existing Products, Building Blocks, and Shortcuts

- Apple’s Measure app is the consumer baseline and explicitly treats measurements as approximate. [ARKit scene depth](https://developer.apple.com/documentation/arkit/arframe/scenedepth) adds depth/confidence on supported devices.
- [ARCore Depth](https://developers.google.com/ar/develop/depth) combines depth-from-motion with available sensors and documents its distance/texture limitations; native hit testing and anchors replace most custom world-tracking work.
- AR Ruler-style apps demonstrate two-point measurement, while furniture retailers demonstrate known-size placement. The latter is the easier and more reliable product cut.
- A web proof can use the [WebXR Hit Test API](https://www.w3.org/TR/webxr-hit-test-1/), but native ARKit/ARCore should remain the recommended stack for depth and capability checks. Photo-only shortcut: ask the user to mark one known-size reference such as A4 paper or a floor tile.

## Free-First Stack

- **Client:** native Kotlin for direct ARCore access; Unity is an alternative if cross-platform 3D iteration matters more than native learning.
- **AR:** ARCore plane detection, hit testing, anchors, and Depth API where supported.
- **Rendering:** SceneView/Filament or Unity.
- **Math:** unit conversion plus camera pose and world-coordinate transforms.
- **Storage:** local Room/SQLite and image files.
- **AI:** optional on-device segmentation for suggested surfaces; not required for v0.

## Accuracy Contract

Every result shows device capability, tracking quality, and an estimated error band. Include a calibration mode using an object with known dimensions. Save raw anchor positions and camera metadata alongside the rendered image so incorrect assumptions are inspectable.

## Build Slices

1. AR session with plane placement and one-meter reference line.
2. Unit input and draggable endpoints.
3. Area rectangle and reference-object library.
4. Screenshot/export with uncertainty label.
5. Depth-assisted occlusion and calibration tests.

## Success Measures

- Placement-to-result under fifteen seconds.
- Median error measured against tape references on supported devices.
- Overlay remains stable while walking around it.
- Users can correctly judge whether an object fits more often than with a number alone.

## Product Path

Begin as a free visualizer. Vertical products could serve furniture shopping, event planning, fitness-space layout, construction prechecks, and real-estate listings. Professional claims would require device qualification and a much stricter validation program.

## Related

- [[Drone Mission Mapper]]
- [[Adaptive Vision Glasses]]
- [[Field Pokedex]]
- [[Project Ideas Index]]
