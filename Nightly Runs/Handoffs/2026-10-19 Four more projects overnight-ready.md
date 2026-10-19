# Four more overnight-ready projects (2026-10-19)

All on main, pushed to github.com/snknitin/<name>. Each has CLAUDE.md + identical AGENTS.md, scripts/verify.ps1 (red now), stop-gate.ps1, .claude/settings.json (denies only edits to verify/gate/settings), PROGRESS.md, .gitignore.

| Project | Lane | Slice | Commit |
|---|---|---|---|
| bionic-reading-trainer | Claude | T1–T2 (SvelteKit reader + modes; verify needs desktop + mobile screenshots) | 18a84c2 |
| epub-highlights-bridge | Codex | T1–T3 (import, identity store, commentary kept) — data root BRIDGE_DATA_ROOT | 9ade6dd |
| latte-into-lambo | Codex | Slice 0 = T1–T2 (pure kernel; calc output must equal tests/golden/smoke byte-for-byte; .gitattributes keeps golden -text) | ebd1696 |
| leetcode-pattern-curriculum | Hermes | T1 + T3 (lcpc predict/attempt/hint) — also scripts/verify.sh for Linux; already cloned on FirstSpark, pulled, verify.sh red there | f65935a |

Vault: Project Priorities.md lanes updated (728b359; the file now lives in Nightly Runs/); the 4 removed from Backlog. Dry run shows 9 rows, 3 per lane.
FirstSpark has no pwsh; uv is at ~/.local/bin/uv (verify.sh adds it to PATH).
