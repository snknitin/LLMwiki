# Nightly Runs

Everything the overnight runner (`Nightly Runs/scripts/overnight-run.ps1`) reads or writes. Related: [[AI Coding Playbook]] · [[Agents Board in Dashboard Command Center]].

- [[Project Priorities]]: what runs tonight, in the Claude / Codex / Hermes lanes. Edit it each evening (or use the Agents board).
- [[Preflight]]: what needs you before tonight (READY / NEEDS INPUT / BLOCKED). Rewritten by every run and by `-Preflight`, so it's git-ignored.
- `scripts/overnight-run.ps1`: the runner. `scripts/sync_agent_rules.py`: copies the shared rules and skills into Claude, Codex and every Hermes profile.
- `agent-rules/`: the shared `AGENTS.md` rules, the `overnight-prompt.md` every agent gets, and `skills/` (make-overnight-ready, advance-slice, feedback-batch, design-variants, plan-tonight, morning-triage). Edit here only, then run the sync script.
- [[AI Coding Playbook]]: the daily rhythm, prompts and status table. [[Agents Board in Dashboard Command Center]]: the drag-and-drop board.
- [[Overnight Report]]: last night's table. The runner overwrites it every run, so it's git-ignored.
- `Logs/`: one dated copy of each real run's report (`YYYY-MM-DD_HHmm Overnight Report.md`), kept for history. Dry runs aren't saved. Add notes under a log's table if a night needs explaining.
- `Handoffs/`: dated notes from sessions that set up or changed the nightly pipeline (`YYYY-MM-DD <what changed>.md`). Read the newest one first when picking the work up.
