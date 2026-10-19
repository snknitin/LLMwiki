---
name: feedback-batch
description: Use when the owner has left look-and-feel or behaviour feedback in a project's FEEDBACK.md and it should be worked through, with before/after screenshots. Works the same in Claude Code, Codex and Hermes.
---

# Work through FEEDBACK.md

1. Read `FEEDBACK.md`, `DESIGN.md` (if present) and `AGENTS.md`. Unticked items (`- [ ]`) are the queue, top to bottom.
2. For each item:
   - If it's a lasting taste rule ("no gradients", "dense tables over cards"), also add it to `DESIGN.md` (create it if missing) so it applies everywhere and isn't undone later.
   - Take a **before** screenshot of the affected screen at desktop (1440px) and mobile (390px) widths, using Playwright or the project's screenshot script, into `screenshots/<date>/<item-slug>-before-*.png`.
   - Make the smallest change that satisfies the item. Run verify.
   - Take the **after** screenshots, tick the item (`- [x]`), commit ("Feedback: <item>") and push.
   - If the item is ambiguous, don't guess big: make the most conservative version, and add a question with your default to `REPORT.md`.
3. Finish with `REPORT.md`: a table of item → change → before/after screenshot links → commit, plus open questions.
