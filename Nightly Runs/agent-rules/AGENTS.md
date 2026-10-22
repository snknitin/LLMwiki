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

## Add the app to the dashboard once it's worth using
- When BUILD_SPEC describes something used on screen (a dashboard, an app, a web page), build toward a working app the owner can try, not only back-end pieces. Plan its screens into the build tree so a usable first version arrives early rather than in the last slice.
- Only when the app is substantial (an MVP or finished slice that shows how it works end to end, with demo data), add `scripts/preview.ps1` (desktop) and `scripts/preview.sh` (FirstSpark). That script is what puts it on the owner's dashboard, so never add it for a placeholder, a status page or a half-built screen. It serves the app in the foreground on 127.0.0.1 and the project's port from "Project previews" in `LLMWiki/Local_Setup/FirstSpark Port Registry.md`. A project with no row takes the next free dashboard port and registers it in the same change. Line 2 of each script is exactly `# preview: http://127.0.0.1:<port>/`.
- After that you don't deploy anything: the Agents board keeps the app running, restarts it on the new code when your commits land, publishes it on the tailnet, and gives it a tab in Dashboard Command Center's Projects group with its Tailscale link. Keep `preview.ps1` starting cleanly after every commit.
- The preview uses synthetic or demo data in a temp data root. No real data, no secrets or tokens in the URL, no login step the owner can't do in the tab.
- Verify never depends on a preview server running. Its screenshots start their own temporary server. Never edit the DCC registry yourself.

## Links for the owner: Tailscale, never localhost
The owner uses several computers and a phone. Any link you give them to something running on the desktop or a Spark (a preview, a review page, a dashboard) is its Tailscale link, never `localhost` or `127.0.0.1`.
- Serve on `127.0.0.1`, then publish the same port on the tailnet: `tailscale serve --bg --https=<port> http://127.0.0.1:<port>` (with `sudo` on FirstSpark). Never Funnel, never bind `0.0.0.0`.
- The link is `https://<host>.tail4a1242.ts.net:<port>/`: the desktop is `nike-workstation`, FirstSpark is `spark-07a8`.
- If the app checks Host or Origin headers, it must also accept that tailnet name, or the link answers 403.
- Open the link yourself first (a browser, or `curl` from another machine on the tailnet) and send it only once the page loads.
- Dashboard Command Center tabs use the tailnet link too. The Agents board registers previews with it; if a project tab points at localhost, report it instead of editing the registry.

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
- SSH from the desktop to a Spark: only `C:\Windows\System32\OpenSSH\ssh.exe FirstSpark` (or `SecondSpark`, `ThirdSpark`), e.g. from the PowerShell tool. Git Bash `ssh`, raw IPs and Tailscale names all fail (no key: the aliases live in the NVIDIA Sync ssh_config). Never report a Spark as unreachable without trying this exact command.
- FirstSpark ports: read `LLMWiki/Local_Setup/FirstSpark Port Registry.md` before binding any port on FirstSpark. Pick a free port from it and register the new one there in the same change.
- Project priorities live in `LLMWiki/Nightly Runs/Project Priorities.md`. When choosing what to work on next without instructions, follow it top to bottom.
