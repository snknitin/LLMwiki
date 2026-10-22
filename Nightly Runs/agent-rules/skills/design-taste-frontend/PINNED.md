# Pinned third-party skill

- Repository: https://github.com/Leonxlnx/taste-skill
- Full commit: `6010f91a9935f1c167dfc500fb1a475681892e6b`
- License: MIT (full text included).
- Pinned date: 2026-10-22 (Asia/Calcutta).
- Upstream folder: `skills/taste-skill`
- Copied: Entire skills/taste-skill folder: SKILL.md, references, scripts, library and assets; root MIT LICENSE added.
- Left out and why: Installer install.sh, plugin manifests, repository tests/examples and Git metadata. Only the requested standalone skill is shared; no installer, hook or plugin is installed.
- Execution/download/network behavior: Node 22+: scripts/draw.mjs, assets.mjs, lint.mjs, inspect.mjs and scenes.mjs (Node 18+ lint fallback). draw/lint use local files; draw writes .taste-skill and emits Picsum and Google Fonts URLs. inspect/scenes launch installed Chrome/Edge/Chromium, serve local files on a temporary loopback server, visit the target, load its assets/network requests and save screenshots/reports. assets sends search terms to Openverse, Wikimedia Commons, Art Institute of Chicago, Met Museum, Internet Archive and NASA; --get downloads selected images/video/posters into the project and records credits. No API keys or package installation required. Do not send private brief content in asset queries.
- Installation verification: file and hash inspection only. No script, installer, npm/npx/pip command or hook from the downloaded repositories was executed.
- Size pruning: none required; all four folders together must remain below 25,000,000 bytes, checked after PINNED.md creation.
