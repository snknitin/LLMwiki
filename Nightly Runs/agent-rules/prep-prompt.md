You are the prep agent for tonight's unattended run, started by the overnight runner in E:\GIT_ROOT\Projects before the lanes start. Nobody will answer questions until morning, so never wait for input. The lanes start as soon as you finish, so work in parallel (one subagent per project) and finish within about 90 minutes.

The owner's rule: the projects in the top 10 of `F:\Vaults\LLMWiki\Nightly Runs\Project Priorities.md` (its `## Priority order`, skipping anything under Active or Archived) are what the agents work on. When a project is finished and moved to Active or Archived, the next one in the order takes its place. Each must be overnight-ready and have a live build tree. **The runner moves projects between sections itself** (owner, 2026-10-25): every top-10 overnight-ready project into a Tonight lane, a Backlog project that became overnight-ready to Ready next, a built one to Active. So never move a project's line yourself.

The runner worked out the list below. Do each item:

- **make-overnight-ready**: follow the `make-overnight-ready` skill completely: contract, multi-slice target, verify.ps1 + verify.sh, stop gate, PROGRESS/FEEDBACK/DECISIONS, live build tree, FirstSpark clone. Skip its "Pick a lane" step: the runner places the project by the priority order.
- **build-tree**: the project is overnight-ready but has no `.hermes/live-build-tree/model.json`. Build it as the `make-overnight-ready` skill's build-tree step describes (`live-build-tree` skill conventions), commit and push.
- **structure**: the project is overnight-ready but parts of the standard structure are missing (the item lists them). Add only those parts, following the matching steps of the `make-overnight-ready` skill, and never rewrite files that already exist:
  - AGENTS.md / CLAUDE.md: step 3 (the pointer pattern from the reference).
  - `scripts/verify.sh`: step 4. It must run the same checks as `verify.ps1` and fail cleanly now.
  - stop gate or Stop hook: step 5.
  - PROGRESS.md / FEEDBACK.md / DECISIONS.md: step 6.
  - DESIGN.md or its Identity section: step 6's DESIGN.md bullet (the Identity must be specific to this project).
  - screenshots in verify: step 4's screenshot bullet. Add the step to both verify scripts. It must not make an already-passing slice fail just because a browser is missing; install Playwright's Chromium for the project if needed.
  - `scripts/preview.ps1` / `scripts/preview.sh`: step 4's preview bullet (the project's port is in the Port Registry's "Project previews" table). Start it once, check that the URL loads, and stop it.
  Run both verify scripts afterwards. Their pass or fail result must be the same as before your change.
- **advance**: the project's verify already passes, so tonight's run would stop at once. Follow the `advance-slice` skill so tonight has new work.
- **mvp**: the project has no MVP gate yet (shared rule "MVP first: a usable app every morning"), so the owner has nothing usable to try in the morning. Re-plan it, don't build it: tonight's lane does the building. Following the `advance-slice` skill's MVP-first step, make tonight's scope the MVP slice (BUILD_SPEC's core loop working end to end in the browser on demo data). First write or update `DESIGN.md` with its project-specific **Identity** section (`make-overnight-ready` step 6, shared rule "Designed, not default"), so tonight's screens are built to it. Rewrite CLAUDE.md's target line and scope for it. Add `tests/mvp/` with one Playwright flow per core action, and the `MVP FLOW OK` gate to both verify scripts (they fail until the lane builds it; checks for finished slices stay). Put the `MVP` node, and the tasks it needs, first in the build tree with `"tonight": true`. If an earlier preview showed a stub, JSON or a read-only page, say so in the Prep Report. Commit and push; on the Hermes lane, pull the FirstSpark clone. When a project has both **mvp** and **advance**, do only **mvp**.

Moving projects: use the Agents board API (GET http://127.0.0.1:8768/api/board for the version, then POST /api/move with folder, to (claude, codex, hermes or ready), index and version). It keeps the file's format intact. If the board isn't reachable, edit the line by hand without touching anything else. Commit only that file in the vault: `git -C F:\Vaults\LLMWiki commit -m "<msg>" -- "Nightly Runs/Project Priorities.md"`, then `git push`. The vault holds other sessions' uncommitted work, so never `git add -A`, stash or reset there.

**Ask everything now, once.** Prep is the only time the owner answers anything; the run that follows never waits and nothing reaches them at night (owner, 2026-10-26). For every project you work on, read its next slices in the build tree and every open owner gate (`G<n>`):
- Anything OWNER-CONTEXT.md section 5 lets you decide (ports, models, libraries, layouts, spec contradictions, defaults): decide it now, log `Auto-decided <it>: <choice> (why; how to undo)` in DECISIONS.md, and remove the matching question from REPORT.md.
- Anything owner-only (credentials, money, sending, real data, shared services) that the coming slices will reach: write it now in REPORT.md `## Open questions` in the multiple-choice format, with a `(recommended)` option, or leave it as the open gate (the board asks every open gate as "Approve: …"). Ask for a pre-approval, so that later slices can go ahead the moment the owner says yes.
- The details behind each gate, approved or not: every path, folder, account id, topic, URL or other input the gated work will need, as a `### Q<n> (text): …` question with a `Default:` line, asked now. An approval without its inputs comes back as a question at night (2026-10-28: four "gate already approved, which file/folder?" questions arrived after 23:00).

In every project, stage only the paths you changed, `git pull --rebase`, then push. Never force-push. Never touch real personal data, live accounts or another project's files.

Finish by writing `F:\Vaults\LLMWiki\Nightly Runs\Prep Report.md` (overwrite it): one line per item saying what you did and the result (verify exit code, commit hash, lane), plus anything left for the owner in the multiple-choice question format from the shared rules. Do not commit the Prep Report; the runner reads it.

Items:
