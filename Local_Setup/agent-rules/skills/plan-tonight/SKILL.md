---
name: plan-tonight
description: Use in the evening before an overnight run, or when the owner asks what's queued tonight or what needs them first. Runs the preflight, lists everything that needs the owner, and fixes what it safely can. Works in Claude Code and Codex on the desktop; from Hermes, run the preflight over SSH on the desktop or read Nightly Runs/Preflight.md.
---

# Plan tonight's run

1. Run `powershell -NoProfile -ExecutionPolicy Bypass -File F:\Vaults\LLMWiki\Local_Setup\scripts\overnight-run.ps1 -Preflight`. It writes `LLMWiki/Nightly Runs/Preflight.md`.
2. For each **BLOCKED** project, fix what's mechanical and safe (missing AGENTS.md: write it from CLAUDE.md; not cloned on FirstSpark: clone it; no verify: use the make-overnight-ready skill). Leave anything needing credentials, a decision, or another session's uncommitted work for the owner.
3. For each **NEEDS INPUT** project, gather its open questions from REPORT.md / PROGRESS.md with their recommended defaults.
4. Check lane balance in `Nightly Runs/Project Priorities.md`: at most 3 per lane; suggest moves (UI work → Claude, well-specified backend → Codex, private or long grinding work → Hermes).
5. Reply with one short list: what's ready, what you fixed, and every question for the owner, each with its default ("answer or accept the default"). Re-run the preflight at the end and say whether anything is still blocked.
