---
updated: 2026-10-19
status: completed
scope: workstation, dashboard-command-center, agents, overnight
---

# Agents Board in Dashboard Command Center

One screen to plan and check overnight agent work across Claude Code, Codex and Hermes. It is its own project ([agents-board](https://github.com/snknitin/agents-board), `E:\GIT_ROOT\Projects\agents-board`) and shows up as the **Agents board** tab in the Dashboard Command Center **Nightly** group, registered by URL like any other dashboard; the Command Center holds no board code. [[Project Priorities]] stays the source of truth: the board only reorders and moves its lines, so the overnight runner and every agent keep reading the same file. Related: [[AI Coding Playbook]] · [[Overnight Report]].

## Use it

- **Plan the night:** drag a project card between the Claude, Codex and Hermes lanes, or into Ready next, Active or Backlog. Dragging within a lane reorders it. Each card also has a **Move to…** menu (keyboard friendly). Every move is saved straight to `Ideas/Project Priorities.md`.
- **Not overnight-ready** cards (no `scripts/verify.ps1` in `E:\GIT_ROOT\Projects\<folder>`) can't be dropped into a Tonight lane.
- **Morning check:** each card shows last night's verify PASS/FAIL, git state, commits and log path from [[Overnight Report]], the last line of its `PROGRESS.md`, and a **REPORT.md** button (amber **REPORT: open questions** when its questions section has items). The button opens the report in the board.
- **Recent activity** under each lane: Claude Code sessions (newest `~/.claude/projects/*/*.jsonl` per project), Codex threads (`~/.codex/session_index.jsonl`), and Hermes sessions on FirstSpark (a read-only query of `~/.hermes/state.db` over `ssh FirstSpark`), with a link to the Hermes dashboard (`http://100.94.199.98:9120`). Activity is cached for 30 s (Hermes 60 s); **Refresh** reloads the board.

## Details

| Item | Value |
|---|---|
| URL | `http://127.0.0.1:8768/` (loopback only; health `/api/health`). Windows desktop ports in use by Command Center tabs: 8765 Signal Desk, 8767 Local Setup, **8768 Agents board**, 8079/8096 World Monitor, 8095 openGym, 8188 ComfyUI |
| Runs as | Scheduled task **Agents Board** at logon: hidden PowerShell running `node src\main.ts` from the repo (Node 22.18+ runs the TypeScript directly; today that is Hermes' bundled `node.exe`, the only Node on PATH). Log: `%LOCALAPPDATA%\agents-board\board.log`. Re-register with `scripts\install-logon-task.ps1` |
| Dashboard | registry ids `agents-board`, endpoint `agents-board-local`, session `agents-board-session`, group `nightly`; backup `registry.pre-agents-board-20261019.json` |
| Code | repo [snknitin/agents-board](https://github.com/snknitin/agents-board) (private). Verify: `scripts\verify.ps1` (typecheck, unit tests, Playwright drag-and-drop check in installed Edge). It first lived inside dashboard-command-center; that code was reverted there (`679e3c3`…`aa3ec00`, app 0.1.4) |
| Safety | A move rewrites the file only if it hasn't changed since the board loaded (otherwise it reloads and asks you to retry), writes through a temp file + rename, and refuses cross-origin or non-loopback requests. Header text, notes and `@tool:model` tags are kept byte for byte |
| Overrides (tests) | `AGENTS_BOARD_PORT`, `AGENTS_BOARD_VAULT`, `AGENTS_BOARD_PRIORITIES`, `AGENTS_BOARD_REPORT`, `AGENTS_BOARD_PROJECTS`, `AGENTS_BOARD_HERMES=off` |
