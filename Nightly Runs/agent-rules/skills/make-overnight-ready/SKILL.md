---
name: make-overnight-ready
description: Use when a project under E:\GIT_ROOT\Projects (or ~/Workspace/GIT_ROOT/Projects) must be able to run unattended overnight in Claude Code, Codex or Hermes. Adds the build contract, verify gate, stop gate and progress files. Works the same in all three tools.
---

# Make a project overnight-ready

Reference implementation: `mock-interview-gauntlet` (copy its patterns; don't invent new ones).

1. Read `BUILD_SPEC.md` and `README.md`. Pick the **first slice** that a script can check and that needs no live accounts, network or private data. If the spec has numbered tasks, name them (e.g. "Slice 0 = T1–T2").
2. Write `AGENTS.md` (the rules every tool reads): spec pointer and slice scope; commands (setup, test, run) for Windows and, if possible, Linux; the done check; boundaries (only this folder, synthetic fixtures, no network, never edit `scripts/verify.ps1`, `scripts/stop-gate.ps1`, `.claude/`); the git rule (commit and push each finished task, `git add <paths>`, `git pull --rebase`, never force); and a "Stop when" list.
3. Write `CLAUDE.md` containing just `@AGENTS.md` (so all three tools read the same file). If CLAUDE.md already has content, move it into AGENTS.md first.
4. Write `scripts/verify.ps1`: exit 0 only when the slice is done (tests pass, required files exist, a smoke run of the CLI or app works, rejected fixtures fail). For Hermes on Linux, also add `scripts/verify.sh` with the same steps. Run it now: it must **fail cleanly**, not crash.
5. Copy `scripts/stop-gate.ps1` and `.claude/settings.json` from the reference project. Deny rules may protect verify, stop-gate and settings; **never deny git commit or push**.
6. Create `PROGRESS.md` (task checklist for the slice plus an empty "Open decisions" section) and `FEEDBACK.md` (empty list, with a one-line explanation of how to use it).
7. Check `git rev-parse @{u}` works (a GitHub remote exists). If the project might run on Hermes, make sure it's cloned at `/home/snknitin/Workspace/GIT_ROOT/Projects/<name>` on FirstSpark.
8. Commit and push. Then add the project to a lane under `## Tonight` in `LLMWiki/Nightly Runs/Project Priorities.md` only if the owner asked; otherwise list it under "Ready next".
9. Run `overnight-run.ps1 -Preflight` and fix anything it marks BLOCKED for this project.
