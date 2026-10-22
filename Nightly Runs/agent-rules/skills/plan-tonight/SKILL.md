---
name: plan-tonight
description: Use in the evening before an overnight run, when the owner asks what's queued tonight or what needs them first, or after the owner reorders priorities or moves a project to Active or Archived. Runs the preflight, keeps tonight's lanes equal to the top 10, lists everything that needs the owner, and fixes what it safely can. Works in Claude Code and Codex on the desktop; from Hermes, run the preflight over SSH on the desktop or read Nightly Runs/Preflight.md.
---

# Plan tonight's run

1. **Run the preflight:** `powershell -NoProfile -ExecutionPolicy Bypass -File "F:\Vaults\LLMWiki\Nightly Runs\scripts\overnight-run.ps1" -Preflight`. It writes `LLMWiki/Nightly Runs/Preflight.md`: tonight's lanes, then a "Top 10 upkeep" table.

2. **Do the Top 10 upkeep now.** The 23:00 run otherwise does it in a prep step that delays the lanes. The rule: the top 10 of `## Priority order`, skipping Active and Archived, must each be overnight-ready, have a live build tree, and sit in a Tonight lane (lanes have no size limit; every project in a lane runs at once). For each row:
   - **make-overnight-ready**: run that skill (it ends by choosing and moving the lane).
   - **build-tree**: build `.hermes/live-build-tree/model.json` with the `make-overnight-ready` skill's tree step.
   - **queue**: move it into a lane with that skill's "Pick a lane" step. Move any **dequeue** project (one no longer in the top 10) to Ready next.
   - **OWNER**: list it for the owner (e.g. no BUILD_SPEC.md yet).

   Use subagents in parallel, one per project.

3. **Advance finished projects:** for each tonight project whose `scripts/verify.ps1` already passes, run the `advance-slice` skill. Otherwise tonight's run would stop at once.

4. **Fix BLOCKED projects** where it's mechanical and safe:
   - missing AGENTS.md: write the pointer;
   - not cloned on FirstSpark: clone it;
   - no verify: use make-overnight-ready.

   Leave anything that needs credentials, a decision, or another session's uncommitted work for the owner.

5. **Gather NEEDS INPUT items:** for each NEEDS INPUT project, collect its open questions from REPORT.md / PROGRESS.md, each with its recommended default.

6. **Reply** with one short list: what's queued in each lane, what you fixed or advanced, and every question for the owner with its default ("answer or accept the default"). Re-run the preflight at the end and say whether anything is still BLOCKED or still listed under Top 10 upkeep.
