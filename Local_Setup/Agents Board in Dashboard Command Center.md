---
updated: 2026-10-19
status: completed
scope: workstation, dashboard-command-center, agents, overnight
---

# Agents Board in Dashboard Command Center

One screen to plan and check overnight agent work across Claude Code, Codex and Hermes. It is the **Agents board** tab in the Dashboard Command Center **Nightly** group. [[Project Priorities]] stays the source of truth: the board only reorders and moves its lines, so the overnight runner and every agent keep reading the same file. Related: [[AI Coding Playbook]] · [[Overnight Report]].

## Use it

- **Plan the night:** drag a project card between the Claude, Codex and Hermes lanes, or into Ready next, Active or Backlog. Dragging within a lane reorders it. Each card also has a **Move to…** menu (keyboard friendly). Every move is saved straight to `Ideas/Project Priorities.md`.
- **Not overnight-ready** cards (no `scripts/verify.ps1` in `E:\GIT_ROOT\Projects\<folder>`) can't be dropped into a Tonight lane.
- **Morning check:** each card shows last night's verify PASS/FAIL, git state, commits and log path from [[Overnight Report]], the last line of its `PROGRESS.md`, and a **REPORT.md** button (amber **REPORT: open questions** when its questions section has items). The button opens the report in the board.
- **Recent activity** under each lane: Claude Code sessions (newest `~/.claude/projects/*/*.jsonl` per project), Codex threads (`~/.codex/session_index.jsonl`), and Hermes sessions on FirstSpark (a read-only query of `~/.hermes/state.db` over `ssh FirstSpark`), with a link to the Hermes dashboard (`http://100.94.199.98:9120`). Activity is cached for 30 s (Hermes 60 s); **Refresh** reloads the board.

## Details

| Item | Value |
|---|---|
| URL | `http://127.0.0.1:8768/` (loopback only; health `/api/health`). Windows desktop ports in use by Command Center tabs: 8765 Signal Desk, 8767 Local Setup, **8768 Agents board**, 8079/8096 World Monitor, 8095 openGym, 8188 ComfyUI |
| Runs as | Part of the Command Center itself: its main process serves the page while the app is running (no separate service or scheduled task) |
| Dashboard | registry ids `agents-board`, endpoint `agents-board-local`, session `agents-board-session`, group `nightly`; backup `registry.pre-agents-board-20261019.json` |
| Code | dashboard-command-center `03bc8e6` (priorities parser), `4732137` (server + page), `973df7d` (Playwright check), `de17756` (phone width), `45f0476` (`DCC_OUT_DIR` build override); installed app 0.1.3 |
| Safety | A move rewrites the file only if it hasn't changed since the board loaded (otherwise it reloads and asks you to retry), writes through a temp file + rename, and refuses cross-origin or non-loopback requests. Header text, notes and `@tool:model` tags are kept byte for byte |
| Overrides (tests) | `DCC_AGENTS_BOARD_PORT`, `DCC_PRIORITIES_FILE`, `DCC_OVERNIGHT_REPORT`, `DCC_PROJECTS_ROOT`, `DCC_LLMWIKI_DIR`, `DCC_AGENTS_BOARD_HERMES=off` |
