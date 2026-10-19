---
name: design-variants
description: Use when the owner is unsure what a screen or flow should look like and wants several options to pick from. Builds 2-3 variants on separate branches with screenshots. Works the same in Claude Code, Codex and Hermes.
---

# Build design variants to pick from

1. Read `DESIGN.md`, `FEEDBACK.md` and the screen's current code. Name 2–3 genuinely different directions in one line each (e.g. "A: dense table, B: card grid, C: split list/detail"). Respect existing DESIGN.md rules in all of them.
2. For each direction, from the current base branch: `git worktree add ../<repo>-variant-<x> -b variant-<x>`, implement only that screen, run verify, take screenshots at 1440px and 390px into `screenshots/variants/<x>-*.png`, commit and push the branch.
3. Never merge a variant. Write `REPORT.md` on the base branch: a comparison table (direction, screenshots, trade-offs, effort to finish), your recommendation, and the exact command to merge the chosen one.
4. After the owner picks: merge that branch, delete the others (`git worktree remove`, `git branch -D`, `git push origin --delete`), and record the choice in `DESIGN.md`.
