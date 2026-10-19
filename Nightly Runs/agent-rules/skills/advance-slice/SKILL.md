---
name: advance-slice
description: Use when an overnight project's current slice passes verify and should move on to the next slice of its BUILD_SPEC. Works the same in Claude Code, Codex and Hermes.
---

# Advance a project to its next slice

1. Confirm the current slice is done: run `scripts/verify.ps1` (or `verify.sh`) fresh, and confirm `git status` is clean and pushed. If not, stop and report why.
2. Read `BUILD_SPEC.md`, `PROGRESS.md`, `DECISIONS.md` and `REPORT.md`. List any open questions the owner hasn't answered; carry them forward, don't drop them.
3. Choose the next slice: the smallest next set of spec tasks that a script can check. Write it in one line ("Slice 1 = T3–T4: ...").
4. Update `AGENTS.md` (scope line, commands, stop-when) and `scripts/verify.ps1` (+ `verify.sh`) to check the new slice **and** keep the old slice's checks, so nothing regresses. The new verify must fail cleanly now.
5. Add the new slice's tasks to `PROGRESS.md`. Commit as "Advance to slice N: <summary>" and push.
6. Update the project's note in `Nightly Runs/Project Priorities.md` (e.g. "slice 1: T3–T4").
