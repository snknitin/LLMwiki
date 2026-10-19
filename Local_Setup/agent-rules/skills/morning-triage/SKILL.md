---
name: morning-triage
description: Use in the morning after an overnight run, or when the owner asks how last night went. Summarizes the Overnight Report and every project's REPORT.md into one decision list. Works the same in Claude Code, Codex and Hermes.
---

# Morning triage

1. Read `LLMWiki/Nightly Runs/Overnight Report.md` (and, if the owner asks about an older night, the dated copy in `Nightly Runs/Logs/`).
2. For each project in the table:
   - **PASS**: read its `REPORT.md`. Note what was built, the screenshots, and open questions.
   - **FAIL**: open the log path and the `.verify.txt` next to it. Classify the cause: a spec gap, a test problem, an environment problem (CLI, auth, SSH, usage limit), or a real bug. Name the one-line fix.
   - **skipped by preflight / not run**: give the reason and what clears it.
   - Re-run nothing and change nothing unless the owner asks.
3. Reply with three short sections:
   - **Decide now:** every open question, with its recommended default.
   - **Fix:** failures, each with its cause and one-line fix.
   - **Next:** projects whose slice passed (suggest advance-slice) and lane changes for tonight.
