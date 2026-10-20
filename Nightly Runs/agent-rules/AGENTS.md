# Shared agent rules (Claude Code, Codex, Hermes)

Canonical copy: `LLMWiki/Nightly Runs/agent-rules/AGENTS.md`. Edit only this file, then run
`python "Nightly Runs/scripts/sync_agent_rules.py"` on each machine (see [[AI Coding Playbook]]).

## Git: commit early, commit often
Standing authorization in every git repo; no need to ask.
- Commit each self-contained unit as soon as it works and its checks pass (a fix, a feature step, a refactor, a config change). Many small, revertible commits; never one end-of-session commit.
- Stage only the paths you changed (`git add <paths>`, never `git add -A`). Never commit secrets, build output, private data, or half-broken code (finish or revert the unit first).
- Commit messages: short imperative subject, body only when the why isn't obvious. No AI co-author or attribution lines in commits or PRs.
- `git pull --rebase` then push after each commit. Never `--force`, never rewrite pushed history, never discard another session's commits. On a conflict you cannot resolve with certainty, stop and write the question down.
- Branch choice is yours, and say it in your first message:
  - Default: the current branch (usually `main`), small commits, push each one.
  - Uncommitted changes you did not make, or another session writing in the same checkout: do not touch those files. If your work overlaps them, use a worktree on a new branch (`git worktree add ../<repo>-<task> -b <task>`), then rebase and fast-forward into the base when verify passes.
  - Large or risky changes (multi-day feature, schema or data migration, deletions, public interface change): a branch plus a pull request with the verify output in the body.

## Done means verified
- "Done" = the project's verify command passes (in order: `scripts/verify.ps1`, `scripts/verify.sh`, else the test command in the project's CLAUDE.md or AGENTS.md) + committed + pushed. Re-run verify fresh before claiming success; a status code alone is not proof.
- UI work: take screenshots (desktop and mobile width) and link them in the report.

## Decide, don't ask (for reversible choices)
- Reversible choices (names, layout, which installed library, ordering): pick the simplest option, log it in `DECISIONS.md` (date, choice, why, how to undo), and keep going.
- Stop only for: missing credentials or access, destructive or irreversible actions, external side effects (sending, posting, paying), or a spec contradiction. Write the question into `REPORT.md` in the format below, then continue with other work.
- Before asking, read `DECISIONS.md` under `## Owner answers (from the Agents board)`: the owner may already have answered it.

## Owner context (read before asking anything)
`Nightly Runs/agent-rules/OWNER-CONTEXT.md` in the vault (desktop `F:\Vaults\LLMWiki`, FirstSpark `/home/snknitin/vaults/LLMWiki`) holds the owner's machines, models and endpoints, ports, standing decisions, and the list of what you decide yourself versus what only the owner can answer. Read it once per session before planning work or writing a question. If it answers your question, follow it and cite it in `DECISIONS.md` instead of asking.

## Never stall on the owner
Nobody answers during a run, so waiting is always wrong.
- Never wait, poll, sleep or end early because of a question or an approval step. Record it and move to the next unblocked task.
- Approval steps (owner gates `G<n>`, "ask before slice N", "needs owner approval"): look in `DECISIONS.md` under `## Owner answers (from the Agents board)` for a line `Approve: <gate title>: **Approved…**`. If it is there, the gate is passed: do that work. If not, or the answer is "Not yet", skip only the work behind the gate and keep going with everything else.
- Ask only what `OWNER-CONTEXT.md` section 5 lists as owner-only (credentials, money, sending, destructive actions, shared services, private data, a real spec conflict). Everything else you decide and log.
- A question is BLOCKING only for the tasks it actually blocks; name them. Always give a recommended option, and keep building the parts that don't depend on it (fixtures, fakes, tests, docs).

## How to ask the owner (multiple choice)
Questions go in `REPORT.md` under `## Open questions`, one block each, so the Agents board can show them as choices:

```
### Q1: Which storage should the app use?
One line on why it matters, and what you'll do if nobody answers.
- [ ] SQLite in the data folder (recommended)
- [ ] JSON files
```

Three kinds, marked in the heading:
- **Single choice** `### Q1: …`: 2–4 options, exactly one ending in `(recommended)`, which is what you proceed with.
- **Multi-select** `### Q2 (multi): …`: 2–6 options; mark every option you'd pick with `(recommended)` (at least one).
- **Text** `### Q3 (text): …`: for paths, names, URLs or other context. Put `Default: <value>` on its own line (or `Default: none, blocked until answered`), with no option lines.

Rules for all three:
- Number questions Q1, Q2, … per report, most important first. Never tick (`[x]`) an option yourself; a ticked line marks a question answered.
- The owner's answers are written to `DECISIONS.md` under `## Owner answers (from the Agents board)`. Follow them on your next run, and don't ask again.

## Unattended work is a loop
- Gate (one re-runnable command + pass condition), body (one bounded unit), max (attempts and minutes), no-progress exit (write the handoff with last gate output, recommended default, last commit hash, then end), queue of record on disk (`PROGRESS.md` or a JSON queue).
- A fresh session reads the queue of record first and resumes from the next open item; it never reconstructs state from chat history.
- End every unattended run by writing `REPORT.md`: what changed, verify result, commits, decisions made, questions for the owner.

## Shared machine resources
- FirstSpark ports: read `LLMWiki/Local_Setup/FirstSpark Port Registry.md` before binding any port on FirstSpark. Pick a free port from it and register the new one there in the same change.
- Project priorities live in `LLMWiki/Nightly Runs/Project Priorities.md`. When choosing what to work on next without instructions, follow it top to bottom.
