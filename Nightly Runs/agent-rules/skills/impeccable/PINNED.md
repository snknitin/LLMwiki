# Pinned third-party skill

- Repository: https://github.com/pbakaus/impeccable
- Full commit: `8644175285360c166e57b1e35ecadfbc85ff5209`
- License: Apache-2.0 (full text included).
- Pinned date: 2026-10-22 (Asia/Calcutta).
- Upstream folder: `.claude/skills/impeccable`
- Copied: SKILL.md and reference/ only; root Apache-2.0 LICENSE added. Documentation retained verbatim.
- Left out and why: Entire scripts/ omitted because it includes CLI launchers, browser runtime and runtime data. No hooks.json, .codex/hooks, plugins, extensions, Rust engine, CLI binaries/source, installers or Git metadata copied. This intentionally makes the engine unavailable. Only the requested standalone skill is shared; no installer, hook or plugin is installed.
- Execution/download/network behavior: Upstream SKILL.md requests scripts/impeccable context (Windows impeccable.cmd), which can download a version-pinned Rust engine from GitHub releases; other references describe engine commands, hooks, live browser, asset generation and network integrations. None is installed or authorized here. Follow the explicit Launcher unavailable fallback: announce context loading did not run, read PRODUCT.md and DESIGN.md directly, and use critique/audit/polish reference guidance through permitted tools. Never fetch the missing runtime or enable hooks as a side effect. DO_NOT_TRACK=1 set on both machines; omission of the runtime also prevents its telemetry. External fonts/assets or generation services remain subject to project authorization.
- Installation verification: file and hash inspection only. No script, installer, npm/npx/pip command or hook from the downloaded repositories was executed.
- Size pruning: none required; all four folders together must remain below 25,000,000 bytes, checked after PINNED.md creation.
