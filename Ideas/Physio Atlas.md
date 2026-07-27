---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#9. Physio Atlas]]"
status: concept
difficulty: medium
priority: p2
category: health and movement
form_factor:
  - mobile app
  - web app
deployment: local-first
source_ideas:
  - physical-therapy exercise tracker with a MuscleWiki-style body selector and saved social videos
tags:
  - physical-therapy
  - exercise
  - health
---

# Physio Atlas

> A body-map exercise library and adherence tracker for routines already prescribed or self-selected, with careful provenance and pain-response logging rather than automated diagnosis.

## Product Outcome

Tap a body region or movement goal, view reviewed exercises with clear setup and contraindication notes, assemble a routine, and track reps, load, range, symptoms, and consistency. Saved social videos become private references until they are reviewed and normalized.

## Personal V0

- Interactive anterior/posterior body map with regions and movement patterns.
- Exercise cards with video/link, steps, dosage, equipment, target region, and source.
- Import a shared URL from YouTube/Instagram/TikTok as a bookmark without redistributing the media.
- Build a routine from clinician-provided or user-selected exercises.
- Log completion, effort, pain before/after, and notes.
- Show trends and a concise report to share with a clinician.
- Stop and surface a warning when user-defined red flags or worsening patterns appear.

## Build Boundary

**MVP:** manually curated personal exercise library, body map, routines, local logs, and PDF/Markdown report.

**Later:** pose feedback, clinician collaboration, vetted content catalog, wearable integration, and reminders. Do not diagnose injuries, prescribe rehabilitation, or infer a condition from a selected muscle.

## Existing Products, Building Blocks, and Shortcuts

- MuscleWiki is the obvious body-map product reference; the local differentiator is a personal prescribed routine, provenance, symptoms, and adherence rather than a generic exercise catalog.
- [MediaPipe Pose Landmarker](https://ai.google.dev/edge/mediapipe/solutions/vision/pose_landmarker) or MoveNet can power one narrowly validated form cue later. Start with playback and logging because pose quality varies by camera angle and exercise.
- [ExerciseDB](https://github.com/ExerciseDB/exercisedb-api) and clinician platforms such as Physitrack show reusable exercise-card schemas: region, movement, equipment, steps, dosage, contraindications, media, and source.
- Simplest alternative: a structured private “physio playlist” that captures shared URLs, tags them on an SVG body map, plays the routine, and exports a progress report.

## Free-First Stack

- **App:** Expo/React Native.
- **Body map:** layered SVG regions with accessible list fallback.
- **Data:** encrypted local SQLite.
- **Video:** links/embeds under source platform rules; user-owned clips stored locally.
- **Pose later:** MediaPipe/MoveNet on-device for coarse form cues, validated per exercise.
- **Models:** local model may rewrite a clinician plan into a checklist but cannot invent contraindications or dosage.
- **Export:** HTML/PDF report with dates and symptom trends.

## Clever Shortcut

Build it as a structured “physio playlist” first: body-map tags, exercise cards, routines, and logs. Pose estimation is expensive to validate and often unnecessary for adherence—the actual first problem.

## Build Slices

1. Exercise schema, body map, and manual cards.
2. Routine player and logs.
3. Link capture/share target.
4. Trend report and clinician export.
5. Reviewed red-flag logic.
6. One narrowly validated pose cue.

## Success Measures

- The prescribed routine is easier to follow than scattered links.
- Exercise source and version are always visible.
- Worsening symptoms are not hidden by streak mechanics.
- A clinician can understand the exported history.

## Product Path

Keep the first build a personal organizer. A product route is clinician-authored programs and patient adherence, which requires privacy, medical-device, and content-governance analysis in each market.

## Related

- [[Measure Life]]
- [[Feedback Mirror]]
- [[Paper Logbook]]
- [[Project Ideas Index]]
