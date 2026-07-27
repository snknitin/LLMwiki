---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#6. Drone Mission Mapper]]"
status: concept
difficulty: hard
priority: p3
category: robotics and vision
form_factor:
  - mission-planning desktop app
  - mobile field app
deployment: local control station
source_ideas:
  - draw drone flight patterns on maps or use an omni POV
  - locate objects with a Nemotron-style visual model
tags:
  - drone
  - mapping
  - computer-vision
  - robotics
---

# Drone Mission Mapper

> A simulation-first mission planner where the user draws a survey/search area, generates a safe flight path, and optionally runs visual object search over captured imagery.

## Product Outcome

The app converts an area, altitude, overlap, camera field of view, battery limits, and no-go zones into an inspectable mission. After a simulated or authorized flight, it georeferences frames and proposes candidate locations for user review.

## Personal V0

- Import a map and draw a polygon, path, orbit, or point grid.
- Generate lawnmower, spiral, orbit, and custom waypoint patterns.
- Estimate distance, flight time, battery reserve, image footprint, and coverage.
- Simulate the path in 2D/3D with altitude and return-to-home behavior.
- Export to a supported open mission format or simulator.
- Ingest recorded imagery with telemetry.
- Run a local vision model for text-prompted object candidates and place detections on the map.
- Require human confirmation before any detection is treated as found.

## Build Boundary

**MVP:** offline planner and PX4/ArduPilot simulation, no physical takeoff, one camera model, and post-flight image analysis.

**Later:** hardware-in-the-loop, supported drone SDK, live preview, terrain following, multi-drone coordination, and optimized inference. Real flight requires local regulatory compliance, airspace checks, pilot responsibility, geofencing, and emergency procedures.

## Existing Products, Building Blocks, and Shortcuts

- [QGroundControl](https://github.com/mavlink/qgroundcontrol) and ArduPilot Mission Planner already provide waypoint/mission planning; your custom UI should focus on drawing patterns, coverage explanation, and visual-search review.
- [PX4 SITL](https://docs.px4.io/main/en/simulation/) and [ArduPilot SITL](https://ardupilot.org/dev/docs/sitl-simulator-software-in-the-loop.html) simulate missions before any aircraft moves. [MAVSDK](https://mavsdk.mavlink.io/main/en/) supplies a typed control/telemetry API.
- [Grounding DINO](https://github.com/IDEA-Research/GroundingDINO) and segmentation models can search geotagged frame tiles after flight; run coarse frame retrieval before expensive detection.
- Useful shortcut: replay recorded footage plus synthetic telemetry. Validate path coverage and object-review UX without buying, arming, or flying hardware.

## Free-First Stack

- **Planner:** Tauri + TypeScript map UI using MapLibre and local OpenStreetMap-compatible data.
- **Mission math:** Python or Rust geometry with GeoJSON and tested coordinate transforms.
- **Simulation:** PX4 SITL/Gazebo or ArduPilot SITL before any hardware.
- **Protocol:** MAVSDK/MAVLink for supported autopilots.
- **Data:** SQLite/GeoPackage plus image/telemetry files.
- **Vision:** Grounding DINO/OWL-style detection, segmentation, or vendor-permitted open VLM; use tiling for small objects.
- **GPU:** workstation for development; DGX Spark for batch image search.

## Clever Hacks

- Build against recorded drone footage and synthetic telemetry before buying or flying hardware.
- Use mission coverage and detection review as two separate products.
- Perform coarse embedding search over frames, then expensive detection only on shortlisted tiles.

## Build Slices

1. Polygon drawing and waypoint generation.
2. Battery/coverage estimator and mission validation.
3. SITL execution with telemetry replay.
4. Geotagged frame extractor.
5. Candidate detector and review map.
6. Hardware-in-loop with explicit arming approval.

## Success Measures

- Simulator completes missions without boundary violations.
- Estimates stay within a measured tolerance of simulated results.
- Detection recall/precision is measured on a labeled set.
- No command path can arm a real drone during development by accident.

## Product Path

An open-source mission-design and post-flight search tool is viable for education, inspection, agriculture, or conservation. The product should target one regulated use case rather than a generic autonomous-drone promise.

## Related

- [[AR Scale Lens]]
- [[Field Pokedex]]
- [[Adaptive Vision Glasses]]
- [[Project Ideas Index]]
