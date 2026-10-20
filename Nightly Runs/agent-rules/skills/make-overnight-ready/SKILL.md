---
name: make-overnight-ready
description: Use when a project under E:\GIT_ROOT\Projects (or ~/Workspace/GIT_ROOT/Projects) must run unattended overnight in Claude Code, Codex or Hermes, especially when it enters the top 10 of the priority order or the runner's prep lists it. Adds the build contract, a multi-slice verify gate, the stop gate, progress files and the live build tree, then puts it in a lane. Works the same in all three tools.
---

# Make a project overnight-ready

**When:** a project enters the top 10 of `## Priority order` in `F:\Vaults\LLMWiki\Nightly Runs\Project Priorities.md` (skipping Active and Archived). That happens when the owner ranks it up, or when a project above it moves to Active or Archived. The runner's preflight lists it under "Top 10 upkeep", and the 23:00 prep agent runs this skill for it. The owner can also ask directly.

**Reference projects** (copy their patterns, don't invent new ones): `mock-interview-gauntlet` (contract, verify, stop gate, settings) and `net-worth-command-center` (multi-slice verify, `verify.sh`, live build tree).

1. **Read everything:** the vault's `Nightly Runs/agent-rules/OWNER-CONTEXT.md` first (standing decisions answer most "owner decisions" in specs), then `BUILD_SPEC.md` (task table, slices, merged-feature sections, acceptance, owner decisions), `README.md`, every `features/*/` folder (merged features with their own task tables), and any existing CLAUDE.md/AGENTS.md, PROGRESS.md, DECISIONS.md and REPORT.md.

2. **Pick tonight's scope:** consecutive slices from the first open task, stopping before the first **owner gate**. A gate is anything that needs real or private data, live accounts/OAuth/keys, publishing or sending, a download the machine lacks, or a BLOCKING open question in REPORT.md. Model, endpoint, port and hosting choices are not gates when OWNER-CONTEXT.md settles them: decide, log in DECISIONS.md, and don't turn the spec's whole "owner decisions" list into REPORT.md questions; write only what OWNER-CONTEXT section 5 calls owner-only. Size it for a full night:
   - Claude lane (Opus coordinating Sonnet builders) or Codex lane: about 6–10 tasks.
   - Hermes lane (local glm53-flash): about 4–6 tasks.
   - Merged-feature tasks that only need fixtures may join if their dependencies are inside the scope.

3. **Write the contract.** CLAUDE.md holds it and AGENTS.md is the one-paragraph pointer from the reference (keep whichever way round the project already uses). The target line must have exactly this shape so the Agents board can parse it:
   `Overnight MVP target = **Slices 0–2 = tasks T1–T6 + F-mood-T1**`
   List every task ID, using ranges (`T1–T6`, `F-prep-T1–F-prep-T3`) or single IDs. Then include:
   - a scope sentence and an explicit out-of-scope list;
   - commands for setup, test and run (Windows, plus Linux when it may run on Hermes);
   - "Contract verify.ps1 checks (build to this)";
   - boundaries: only this folder; synthetic fixtures; no network or real accounts; never edit `scripts/verify.ps1`, `scripts/verify.sh`, `scripts/stop-gate.ps1`, `.claude/`, or the spec text;
   - the git rule: commit and push each finished task with `git add <paths>`, `git pull --rebase`, never force;
   - work order: slice by slice, so a partial night leaves green, pushed progress;
   - "Stop when".

4. **Write `scripts/verify.ps1` and `scripts/verify.sh` with the same checks** for every slice in tonight's scope. Exit 0 only when all of it is done. Per slice:
   - required files;
   - a gate test file (e.g. `tests/test_slice1_gate.py`) that must exist and pass;
   - smoke runs of the CLI/app in a temp data root;
   - reject fixtures that must exit non-zero.

   Draw them from the spec's acceptance evidence. In `verify.sh`, add `command -v uv >/dev/null || PATH="$HOME/.local/bin:$PATH"` near the top (the same for node/npm if needed), because Hermes runs it over a non-login SSH shell. Keep it LF (add `*.sh text eol=lf` to `.gitattributes` if needed). Run both now: each must exit 1 with `VERIFY FAIL` and no script errors. Read the exit code straight after the command (`cmd; c=$?`), never after another command.

5. **Copy** `scripts/stop-gate.ps1` and `.claude/settings.json` from the reference. Adjust only the allow list for the toolchain, and deny edits to both verify scripts, the stop gate and the settings. **Never deny git commit or push.**

6. **Write the progress files:**
   - `PROGRESS.md`: the checklist of tonight's tasks, an empty "Open decisions" section, and a log whose entries are `## YYYY-MM-DD HH:MM — <node ID> — <one line>`, saying "done"/"verify PASS" only when that node's check passed.
   - `FEEDBACK.md`: an empty list with a one-line explanation.
   - `DECISIONS.md`: log your scope choice and every invented contract detail (command names, env vars, fixture names).
   - `.gitignore`: data roots, venvs, node_modules, build output, `.claude/stop-retries`.

7. **Build the live build tree** at `.hermes/live-build-tree/model.json` (follow the `live-build-tree` skill), then render `index.html` with its renderer. Conventions the Agents board relies on:
   - Every spec task and every merged-feature task appears once, with its ID kept literally. `phase` is the slice or feature, in build order.
   - Each slice closes with its loop nodes: `S<n>-TEST` (kind `review`: unit and gate tests pass), `S<n>-REVIEW` (kind `review`: reviewer pass against the spec; findings loop back into fixes, at most 3 attempts) and `S<n>-VERIFY` (kind `integration`: verify green, committed, pushed). The next slice's first tasks depend on `S<n>-VERIFY`.
   - Cross-cutting quality work (reject fixtures, migrations up/down, crash or restart recovery, accessibility, screenshots at desktop and phone width, performance budgets, backups) gets its own nodes inside the right slice.
   - Owner gates are `G<n>` (kind `gate`), naming the REPORT.md question they wait on. Parallel branches rejoin at `J<n>` (kind `integration`).
   - Titles are plain English, at most ~50 characters; detail goes in `description`. Status is `done` only with PROGRESS.md evidence, otherwise `ready` or `blocked`, never `active`. Set `"tonight": true` on tonight's nodes and `runs_on` for the lane.
   - Validate it: unique IDs, every edge endpoint exists, no cycles. A real spec gives roughly 60–140 nodes.

8. **Commit and push:** check that `git rev-parse @{u}` works, stage only the paths you added or changed, use a short imperative message with no AI attribution, then `git pull --rebase` and `git push`.

9. **Pick a lane** (from "Which lane" in Project Priorities.md):
   - **Claude:** UI, product feel, tricky design.
   - **Codex:** well-specified backend or CLI slices. Tag `@codex:sol-6-1` for a big slice, `@codex:sol-5-6` for a smaller one.
   - **Hermes:** private-data work, Spark-hosted services, long grinding slices. Not for work whose spec forbids Spark seeing its data.

   Each lane holds at most 3 projects. If the best lane is full, use the next-best lane with a free slot; only if all lanes are full does the project go to "Ready next".

   Move it with the Agents board API: GET `http://127.0.0.1:8768/api/board` for `version`, then POST `/api/move` with `{folder, to: claude|codex|hermes|ready, index, version}`. Add a model tag by editing only that line. Commit only that vault file with `git -C F:\Vaults\LLMWiki commit -m "<msg>" -- "Nightly Runs/Project Priorities.md"` and push. The vault holds other sessions' work, so never `add -A`, stash or reset there.

10. **Hermes lane:** make sure the project is cloned at `/home/snknitin/Workspace/GIT_ROOT/Projects/<name>` on FirstSpark, run `git pull`, and run `bash scripts/verify.sh` there. It must fail cleanly, with no "command not found".

11. **Preflight:** run `powershell -NoProfile -ExecutionPolicy Bypass -File "F:\Vaults\LLMWiki\Nightly Runs\scripts\overnight-run.ps1" -Preflight` and fix anything it marks BLOCKED for this project.
