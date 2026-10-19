# Nightly Runs

Everything the overnight runner (`Local_Setup/scripts/overnight-run.ps1`) reads or writes. Related: [[AI Coding Playbook]] · [[Agents Board in Dashboard Command Center]].

- [[Project Priorities]]: what runs tonight, in the Claude / Codex / Hermes lanes. Edit it each evening (or use the Agents board).
- [[Overnight Report]]: last night's table. The runner overwrites it every run, so it's git-ignored.
- `Logs/`: one dated copy of each real run's report (`YYYY-MM-DD_HHmm Overnight Report.md`), kept for history. Dry runs aren't saved. Add notes under a log's table if a night needs explaining.
- `Handoffs/`: dated notes from sessions that set up or changed the nightly pipeline (`YYYY-MM-DD <what changed>.md`). Read the newest one first when picking the work up.
