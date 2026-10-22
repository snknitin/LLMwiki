---
name: advance-slice
description: Use when an overnight project's verify passes (tonight's target is done) and it should move on to its next slices, so the next run has work. The runner's prep agent runs it automatically when a tonight project's verify already passes at the start of a run; morning-triage and plan-tonight suggest it. Works the same in Claude Code, Codex and Hermes.
---

# Advance a project to its next slices

1. **Confirm the current target is done.** Run `scripts/verify.ps1` (or `verify.sh`) fresh and confirm `git status` is clean and pushed. If not, stop and report why.

2. **Read the state:** `BUILD_SPEC.md`, `PROGRESS.md`, `DECISIONS.md` (especially `## Owner answers (from the Agents board)`), `REPORT.md` and `.hermes/live-build-tree/model.json`. Carry every unanswered question forward; don't drop any.

3. **Choose the next scope** the same way as the `make-overnight-ready` skill (step 2). **MVP first:** if `verify.ps1` has no `MVP FLOW OK` gate yet, or the gate does not pass, the next scope is the MVP slice (shared rule "MVP first: a usable app every morning"), whatever the build tree says is next. Otherwise: consecutive slices from the next open task, stopping before the first owner gate (`G<n>`) that has no approval evidence in DECISIONS.md. Size it for the project's lane.
   - **The next work starts with an unapproved gate:** don't advance. Write the gate as a question in REPORT.md (multiple-choice format, with a recommended option) and say "waiting on G<n>" in the Prep Report or your reply.
   - **Every non-gate node is done:** the project is built. Add a REPORT.md question "Move <project> to Active?" with "Yes (recommended)" / "Keep building". Moving it to Active is the owner's call; once they do, the next top-10 project takes its slot automatically.

4. **Update the contract.** Rewrite the target line in CLAUDE.md (or AGENTS.md), keeping exactly `Overnight MVP target = **Slices 3–4 = tasks T7–T11 + F-mood-T2**` with every task ID listed. Also update the scope and out-of-scope lists, the "Contract verify.ps1 checks" list and "Stop when".

5. **Extend `scripts/verify.ps1` and `scripts/verify.sh` together.** Add the new slices' checks (required files, per-slice gate test, smoke runs in a temp data root, reject fixtures) and **keep every earlier check**, so nothing regresses. Both must now fail cleanly: exit 1, `VERIFY FAIL`, no script errors.

6. **Refresh the build tree:**
   - Mark nodes `done` that PROGRESS.md shows as done.
   - Mark the new scope's nodes `"tonight": true` and clear the flag on finished ones.
   - Set the rest to `ready` or `blocked` from their dependencies.
   - Add any nodes the spec gained.
   - Re-render `index.html`.

6b. **Keep the app usable.** Every new scope keeps the `MVP FLOW OK` gate in both verify scripts and extends `tests/mvp/` with a flow for each new screen or feature the owner will use, so each morning the preview works and shows what the night built. Add `scripts/preview.ps1` and `scripts/preview.sh` when the MVP gate first passes; never for a placeholder. Only a BUILD_SPEC that says the project is headless skips this.

7. **Update the progress files.** Add the new tasks to PROGRESS.md's checklist, and log the scope choice in DECISIONS.md.

8. **Commit and push.** Commit as "Advance to slices N–M: <summary>", staging only your paths, then `git pull --rebase` and `git push`. On the Hermes lane, `git pull` the clone on FirstSpark.

9. **Optionally update the note.** You may update the project's note in `Nightly Runs/Project Priorities.md` (e.g. "slices 3–4: T7–T11"). Edit only that line and commit only that file with `git commit -- <path>`.
