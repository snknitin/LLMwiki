---
name: advance-slice
description: Use when an overnight project's verify passes (tonight's target is done) and it should move on to its next slices, so the next run has work. The runner's prep agent runs it automatically when a tonight project's verify already passes at the start of a run; morning-triage and plan-tonight suggest it. Works the same in Claude Code, Codex and Hermes.
---

# Advance a project to its next slices

1. **Confirm the current target is done.** Run `scripts/verify.ps1` (or `verify.sh`) fresh and confirm `git status` is clean and pushed. If not, stop and report why.

2. **Read the state:** `BUILD_SPEC.md`, `PROGRESS.md` (its `## Now` section first: the builder's handoff), `DECISIONS.md` (especially `## Owner answers (from the Agents board)`), `REPORT.md` and `.hermes/live-build-tree/model.json`. Carry every unanswered question forward; don't drop any.

3. **Choose the next scope** the same way as the `make-overnight-ready` skill (step 2). **MVP first:** if `verify.ps1` has no `MVP FLOW OK` gate yet, or the gate does not pass, the next scope is the MVP slice (shared rule "MVP first: a usable app every morning"), whatever the build tree says is next. Otherwise: every open node that can be built tonight, in dependency order, across as many slices as the lane can finish. A gate never stops the advance; resolve each unapproved owner gate (`G<n>`) in the way first:
   - **A gate you may decide** (its subject is on OWNER-CONTEXT.md section 5's "Just decide" list: a model or endpoint, a library, a port, a layout, a slice boundary, anything BUILD_SPEC gives a default or a recommendation for): decide it now. Take BUILD_SPEC's default, else your own recommended option. Log `Auto-decided <gate>: <choice> (why; how to undo)` in DECISIONS.md, add it to REPORT.md as a question with your choice `(recommended)` so the owner can override it, and plan the work behind it as approved.
   - **An owner-only gate** (section 5's "Wait for the owner" list: credentials, money, sending, destructive actions, shared services, real private data, an attended session): plan everything around it. Build the feature behind it against fakes, fixtures or synthetic data so only the owner's own step is left as one small gated node, and plan every later slice that does not need that step. Write the gate as a REPORT.md question with a recommended option.
   - **Only when no buildable node is left** (everything open needs the owner's own hands): if BUILD_SPEC lists further features or polish (screens, tests, docs, accessibility, performance), plan those instead of stopping. Only when nothing at all is left, the project is built: write one line under `## Status` in REPORT.md, `Project built: <the owner-only steps left, by gate>` (a statement, not a question), commit and push it. The runner then moves the project to Active and gives its lane to the next project in the priority order; the owner moves it back if they disagree.

4. **Update the contract.** Rewrite the target line in CLAUDE.md (or AGENTS.md), keeping exactly `Overnight MVP target = **Slices 3–4 = tasks T7–T11 + F-mood-T2**` with every task ID listed. Also update the scope and out-of-scope lists, the "Contract verify.ps1 checks" list and "Stop when".

5. **Extend `scripts/verify.ps1` and `scripts/verify.sh` together.** Add the new slices' checks (required files, per-slice gate test, smoke runs in a temp data root, reject fixtures) and **keep every earlier check**, so nothing regresses. Both must now fail cleanly: exit 1, `VERIFY FAIL`, no script errors.

6. **Refresh the build tree:**
   - Mark nodes `done` that PROGRESS.md shows as done.
   - Mark the new scope's nodes `"tonight": true` and clear the flag on finished ones.
   - Set the rest to `ready` or `blocked` from their dependencies.
   - Add any nodes the spec gained.
   - Re-render `index.html`.

6b. **Keep the app usable.** Every new scope keeps the `MVP FLOW OK` gate in both verify scripts and extends `tests/mvp/` with a flow for each new screen or feature the owner will use, so each morning the preview works and shows what the night built. Add `scripts/preview.ps1` and `scripts/preview.sh` when the MVP gate first passes; never for a placeholder. Only a BUILD_SPEC with a line `UI: none` skips this.

6b. **UI projects: bring the screens along.** If BUILD_SPEC has a UI and the build tree has no usable screen yet, put one into the next slices rather than leaving the UI for last. When the app becomes substantial enough to try end to end, add `scripts/preview.ps1` and `scripts/preview.sh` (shared rule "Add the app to the dashboard once it's worth using"); never for a placeholder. Projects with no UI skip this.

7. **Update the progress files.** Add the new tasks to PROGRESS.md's checklist, and log the scope choice in DECISIONS.md.

8. **Commit and push.** Commit as "Advance to slices N–M: <summary>", staging only your paths, then `git pull --rebase` and `git push`. On the Hermes lane, `git pull` the clone on FirstSpark.

9. **Optionally update the note.** You may update the project's note in `Nightly Runs/Project Priorities.md` (e.g. "slices 3–4: T7–T11"). Edit only that line and commit only that file with `git commit -- <path>`.
