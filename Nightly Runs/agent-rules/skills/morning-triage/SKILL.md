---
name: morning-triage
description: Use in the morning after an overnight run, or when the owner asks how last night went. Summarizes the Overnight Report, the Prep Report and every project's REPORT.md into one decision list. Works the same in Claude Code, Codex and Hermes.
---

# Morning triage

1. **Read the reports:**
   - `LLMWiki/Nightly Runs/Overnight Report.md`. If the owner asks about an older night, read the dated copy in `Nightly Runs/Logs/`.
   - If the report mentions prep, read `Nightly Runs/Prep Report.md`: which top-10 projects were made overnight-ready, given a build tree, queued or advanced before the lanes ran.

2. **Go through each project in the table:**
   - **PASS:** read its `REPORT.md`. Note what was built, the screenshots and the open questions. Tonight's target is done, so the next run's prep will advance it (or run the `advance-slice` skill now if the owner wants). If every non-gate node of its build tree is done, ask whether to move it to Active; the next top-10 project then takes its slot automatically.
   - **FAIL:** open the log path and the `.verify.txt` next to it. Classify the cause: a spec gap, a test problem, an environment problem (CLI, auth, SSH, usage limit, missing tool on FirstSpark), or a real bug. Name the one-line fix.
   - **Skipped by preflight / not run:** give the reason and what clears it.
   - Re-run nothing and change nothing unless the owner asks.

3. **Check the build trees.** The Agents board's Build tree tab (http://127.0.0.1:8768/#tree, one tab per project) colors each node from PROGRESS.md: green done, amber in progress, blue ready, purple dashed owner gate awaiting approval, grey blocked. Point out nodes that stayed amber (started, never passed) and gates now waiting on the owner.

4. **Reply with three short sections:**
   - **Decide now:** every open question and every gate awaiting approval, each with its recommended default.
   - **Fix:** failures, each with its cause and one-line fix.
   - **Next:** projects to advance, projects the runner moved to Active (the report's "Moved in Project Priorities.md" list; move one back if it isn't done), and which top-10 projects will take freed slots.
