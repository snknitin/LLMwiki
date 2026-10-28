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

## Engineering judgment
- **No speculative hardening.** Before adding complexity for an unlikely race, retry or security edge case, name the concrete failure mode (for a race, the event order: A reads, B writes, A overwrites), how likely it is, and what it costs in code. Interactive: get the owner's OK first. Unattended: ship the simple version and ask in `REPORT.md` (single choice), saying what would change the answer. Approved hardening lands in its own commit, with a test that reproduces the failure. Validation at trust boundaries and real security holes are not speculative: never skip them.
- **Fix the cause.** Fix a bug at its cause, reasoning from first principles; don't patch over the symptom. Add a regression test and confirm it fails without the fix when that's cheap.
- **Check the goal.** When a request prescribes a solution, check that it serves the underlying goal. If it looks like a workaround, name the real goal and the more direct path before building it; if it's sound, just build it.
- **Look back before executing.** For a non-trivial plan, think it through to its end state, then ask whether a simpler approach or reframing now shows; if so, propose (or, unattended, log and take) that one instead.
- **Simplify, don't extend.** Don't extend a pattern you'd recommend removing: understand why it exists, then say so and propose the simpler shape. Change a convention completely in one migration, never by adding a second way beside the first.
- **Abstract late.** Duplication is cheaper than the wrong abstraction: extract on the third copy, and don't pull single-use code into a helper. Check untrusted input once where it enters, not again at every layer.
- **Change the evidence when stuck.** When an approach isn't converging, shrink the repro, add logging or test an unchecked assumption instead of retrying variations.

## MVP first: a usable app every morning
The owner uses each project in the morning and gives feedback while the next night builds more, so a usable app comes before more back-end work. A green build tree with nothing usable on screen is not progress.
- **The MVP slice comes first.** For every project the owner uses on screen (any BUILD_SPEC with a UI, and back-end or CLI projects too unless BUILD_SPEC has a line `UI: none`), the next slice after setup is the MVP: BUILD_SPEC's core loop working end to end in a browser on demo data. Real inputs (forms, text, uploads), every visible button does something, results are saved and still there after a reload, readable at desktop and phone width. No placeholder or "coming soon" screens, no raw JSON pages, no disabled buttons in the core loop. Other back-end slices wait until the MVP gate passes.
- **The MVP gate.** `tests/mvp/` holds one Playwright test per core flow that drives the app like the owner: open the page, enter input, click, see the result, reload, see it again. `verify.ps1` and `verify.sh` start the app on a temp port with a temp data root, run those tests, and print `MVP FLOW OK` only when every flow passes. The build tree has an `MVP` node (kind `integration`) that is done only with that line in a fresh verify.
- **Designed, not default.** Each app gets its own visual identity drawn from its subject and its one user, decided in `DESIGN.md` before the first screen: a palette taken from the domain (never the stock blue, indigo or purple gradient), a type pairing, layout density, one signature element that makes it recognisable, and how it moves. A paper notebook should feel like paper; a finance tool like a precise instrument. No bare HTML, no browser-default controls, no unstyled framework defaults, and no two projects sharing a theme. Write the identity as a `ui-craft` brief: its concept is a structure from the subject's world that shapes the layout, not texture on a generic page.
- **Let the layout explain.** Avoid unnecessary secondary labels and descriptions: no eyebrow captions over headings, no slogans or taglines, no sentence explaining each panel, and never the instructions you were given printed on screen. Longer help goes behind an info icon tooltip. Keep the labels people need: units, amounts, what a button does, what a save covers.
- **Design skills.** `ui-craft` is the entry point for all UI work in every harness: its rules, brief and critique checklist are the must-follow part, and it says when to open `ui-ux-design-kole`, `impeccable`, `design-taste-frontend`, `ui-ux-pro-max` or `frontend-design` (at most two extra per task). If a skill is missing in your tool, skip it and say so in REPORT.md.
- **Design review.** Verify's desktop and phone screenshots are the evidence: before a UI slice is done, the reviewer checks them against `DESIGN.md` and `ui-craft`'s critique checklist, and the Blockers and top findings are fixed in the same slice. It includes the layout check: every eyebrow, slogan or explanatory line on screen is a finding unless a first-time user needs it to say what a control does.
- **Keep it usable.** Every later slice extends the working app and keeps the MVP gate green; a slice that breaks it is not done. Each night ends with the preview working, so the owner can try what was built.
- **The preview.** When the MVP gate first passes, add `scripts/preview.ps1` (desktop) and `scripts/preview.sh` (FirstSpark). That script is what puts it on the owner's dashboard, so never add it for a placeholder, a status page or a half-built screen. It serves the app in the foreground on 127.0.0.1 and the project's port from "Project previews" in `LLMWiki/Local_Setup/FirstSpark Port Registry.md`. The runner gives every project in the lanes, Ready next or with a preview script its row before the first session, so your port is already there: use it (if your preview scripts use another port, switch them to the row) and never ask the owner about a port. Only a project with no row yet takes the next free dashboard port and registers it in the same change; a contract line that keeps you out of the vault does not stop that one row. Line 2 of each script is exactly `# preview: http://127.0.0.1:<port>/`.
- After that you don't deploy anything: the Agents board keeps the app running, restarts it on the new code when your commits land, publishes it on the tailnet, and gives it a tab in Dashboard Command Center's Projects group with its Tailscale link. Keep `preview.ps1` starting cleanly after every commit.
- The preview uses synthetic or demo data in a temp data root. No real data, no secrets or tokens in the URL, no login step the owner can't do in the tab.
- Verify never depends on a preview server running. Its screenshots start their own temporary server. Never edit the DCC registry yourself.

## Links for the owner: Tailscale, never localhost
The owner uses several computers and a phone. Any link you give them to something running on the desktop or a Spark (a preview, a review page, a dashboard) is its Tailscale link, never `localhost` or `127.0.0.1`.
- Serve on `127.0.0.1`, then publish the same port on the tailnet: `tailscale serve --bg --https=<port> http://127.0.0.1:<port>` (with `sudo` on FirstSpark). Never Funnel, never bind `0.0.0.0`.
- The link is `https://<host>.tail4a1242.ts.net:<port>/`: the desktop is `nike-workstation`, FirstSpark is `spark-07a8`.
- If the app checks Host or Origin headers, it must also accept that tailnet name, or the link answers 403.
- Before publishing, run `tailscale serve status --json`: if that port already serves another project, take a free port from the registry instead of overwriting it.
- Open the link yourself first (a browser, or `curl` from another machine on the tailnet) and send it only once the page loads. If Tailscale or `tailscale serve` isn't working on that machine, say so and what fixes it; never fall back to a localhost link.
- A one-off link (a review page, not a project's registered preview) is turned off when the task ends: `tailscale serve --https=<port> off`.
- Dashboard Command Center tabs use the tailnet link too. The Agents board registers previews with it; if a project tab points at localhost, report it instead of editing the registry.

## Decide, don't ask (for reversible choices)
- Reversible choices (names, layout, which installed library, ordering): pick the simplest option, log it in `DECISIONS.md` (date, choice, why, how to undo), and keep going.
- Stop only for: missing credentials or access, destructive or irreversible actions, external side effects (sending, posting, paying). A contradiction in the spec or the project's files is yours to settle: take the reading closest to BUILD_SPEC's purpose, log it as `Auto-decided`, keep building. Write the question into `REPORT.md` in the format below, then continue with other work.
- Before asking, read `DECISIONS.md` under `## Owner answers (from the Agents board)`: the owner may already have answered it.

## Owner direction (Steer on the Agents board)
The owner steers a project from its board card: `DECISIONS.md` under `## Owner direction (from the Agents board)`, newest first, each entry `### <date time> · Add context|Change course · open` with the note quoted below it. It outranks prep, earlier plans, PROGRESS.md's queue and your own past decisions.
- At the start of every session (builder, planner, QA, prep), before any other work, apply every `open` entry, oldest first:
  - **Add context**: fold it into `BUILD_SPEC.md` (features, constraints, links) and, where it adds work, the build tree and PROGRESS.md's checklist; follow it from now on.
  - **Change course**: re-plan first. Update `BUILD_SPEC.md`, `.hermes/live-build-tree/model.json` and PROGRESS.md (`## Now` and the checklist); mark nodes it makes obsolete as dropped, redo finished work only where the note says it went the wrong way, then build the new way.
  - Read every link it gives. Use the skills or MCP servers it names if you have them; if one is missing or needs a credential, say so in `REPORT.md` and carry on without it.
- Then change that entry's `open` to `applied <date>: <one line on what changed>`, and commit it with the plan change. Never delete or reword the owner's text. A part that needs an owner-only answer: ask it in `REPORT.md` and apply the rest.
- QA reviews against it too: work that ignores an applied or open direction is a finding.

## Owner context (read before asking anything)
`Nightly Runs/agent-rules/OWNER-CONTEXT.md` in the vault (desktop `F:\Vaults\LLMWiki`, FirstSpark `/home/snknitin/vaults/LLMWiki`) holds the owner's machines, models and endpoints, ports, standing decisions, and the list of what you decide yourself versus what only the owner can answer. Read it once per session before planning work or writing a question. If it answers your question, follow it and cite it in `DECISIONS.md` instead of asking.

## Never stall on the owner
Nobody answers during a run, so waiting is always wrong.
- Never wait, poll, sleep or end early because of a question or an approval step. Record it and move to the next unblocked task.
- Approval steps (owner gates `G<n>`, "ask before slice N", "needs owner approval"): look in `DECISIONS.md` under `## Owner answers (from the Agents board)` for a line `Approve: <gate title>: **Approved…**`. If it is there, the gate is passed: do that work. If not:
  - A gate on something `OWNER-CONTEXT.md` section 5 lets you decide (a model or endpoint, a library, a port, a layout, a slice boundary, any default or recommendation BUILD_SPEC gives): decide it yourself with BUILD_SPEC's default, else your recommended option, log `Auto-decided <gate>: <choice> (why; how to undo)` in `DECISIONS.md`, list it in `REPORT.md` so the owner can override it, and do the work.
  - An owner-only gate, or the answer "Not yet": build everything around it (fakes, fixtures, synthetic data) so only the owner's own step is left, and keep going with every other node and slice.
  - Never stop, refuse to plan the next slices, or call a project built while any node you could build is open.
- Questions are asked once, at prep, before the run; the owner answers them all then (owner, 2026-10-26). During a run, never add a question you are allowed to decide. An owner-only step you reach mid-run: build around it and add its question for the next prep; it gets no answer tonight, and nothing waits for one.
- Ask only what `OWNER-CONTEXT.md` section 5 lists as owner-only (credentials, money, sending, destructive actions, shared services, private data). Everything else you decide and log.
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
