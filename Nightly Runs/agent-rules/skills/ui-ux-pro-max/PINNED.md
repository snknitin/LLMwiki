# Pinned third-party skill

- Repository: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- Full commit: `623a9a9037d006ea727f8213f084d02a6b6f11b5`
- License: MIT (full text included).
- Pinned date: 2026-10-22 (Asia/Calcutta).
- Upstream folder: `.claude/skills/ui-ux-pro-max`
- Copied: Entire .claude/skills/ui-ux-pro-max folder: SKILL.md, scripts, data and references; root MIT LICENSE added. All are ordinary directories in this commit.
- Left out and why: CLI, plugin components, other skills, source duplicates, installers and Git metadata. Only the requested standalone skill is shared; no installer, hook or plugin is installed.
- Execution/download/network behavior: Python 3.x scripts/search.py with query plus --domain, --stack or --design-system; optional --persist --output-dir writes design-system documents. python3 or py -3 are documented fallbacks. Standard library and local data only; no external dependencies or network requests in search. Results may suggest Google Fonts or other external asset URLs, fetched only if later incorporated into a page. Do not put private project data in queries/persisted output.
- Installation verification: file and hash inspection only. No script, installer, npm/npx/pip command or hook from the downloaded repositories was executed.
- Size pruning: none required; all four folders together must remain below 25,000,000 bytes, checked after PINNED.md creation.
