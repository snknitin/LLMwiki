---
updated: 2026-10-19
status: active
---

# AI Coding Playbook

How to run Claude Code, Codex and Hermes across many projects: design during the day, build at night, triage in the morning. Related: [[Project Priorities]] · [[FirstSpark Port Registry]] · [[Hermes Nightly Runs — Loop Engineering How-to]].

## 1. What's set up

| Piece | Status | Where | How you use it |
|---|---|---|---|
| Shared agent rules (git, verify, decide-don't-ask, loops, ports, priorities) | ✅ Done | `Local_Setup/agent-rules/AGENTS.md`, synced into `~/.claude/CLAUDE.md` + `~/.codex/AGENTS.md` (desktop) and `~/.claude/CLAUDE.md` + `~/.codex/AGENTS.md` + `~/.hermes/SOUL.md` (FirstSpark) | Edit the one file, then run the sync (section 7). Never edit the copies. |
| Commit and push after each unit; agent picks branch / worktree / PR | ✅ Done (in shared rules) | all three harnesses | Nothing to do; agents say which branch they chose in their first message |
| Project priorities | ✅ Done (markdown) | [[Project Priorities]] | Reorder lines; move a line between the Claude / Codex / Hermes lanes under **Tonight** to reassign it |
| Agents board in Dashboard Command Center (drag-and-drop lanes, status of all three tools) | ✅ Done | Own repo [agents-board](https://github.com/snknitin/agents-board), shown in Command Center → **Nightly** → **Agents board** (`http://127.0.0.1:8768/`), see [[Agents Board in Dashboard Command Center]] | Drag cards between lanes; every move is written to [[Project Priorities]], which stays the file the runner reads |
| Hermes main model = `glm53-flash` | ✅ Done 2026-10-19 | `~/.hermes/config.yaml` on FirstSpark (backup `config.yaml.bak-*-before-glm53-default`) | Used by `@hermes` runs and new Hermes chats; restart the gateway for Discord/etc. to pick it up |
| FirstSpark port registry | ✅ Done | [[FirstSpark Port Registry]] | Agents read it before binding a port; two ports are still marked unknown |
| Builder + reviewer subagents | ✅ Done | `~/.claude/agents/builder.md` (Sonnet), `reviewer.md` (Opus) | Say "use the builder for each milestone and the reviewer after" |
| Overnight-ready projects (CLAUDE.md, `scripts/verify.ps1`, Stop-hook gate, PROGRESS.md) | ✅ 5 projects | gauntlet, vocabulary, resume, batman, motto | Ask Claude "Make <folder> overnight-ready" for more |
| Overnight runner | ⚠️ Written and dry-run tested, **not committed, not scheduled** | `Local_Setup/scripts/overnight-run.ps1` + `agent-rules/overnight-prompt.md` | Three lanes in [[Project Priorities]] (Claude, Codex, Hermes), up to 3 projects per lane at once, so 9 in parallel (`-PerHarness`). Claude and Codex run on the desktop; Hermes runs on FirstSpark over SSH with `glm53-flash`. Claude's safety check won't let an agent launch unattended agents, so you do the 3 one-time steps in section 6 |
| Morning report | ✅ Done (written by the runner) | [[Overnight Report]] | One table: verify PASS/FAIL, git state, commits, log path |
| Hermes nightly loops | ✅ Already existed | Hermes cron on FirstSpark | [[Hermes Nightly Runs — Loop Engineering How-to]] |
| Codex/Claude using local Spark models | ❌ Not done | LiteLLM `127.0.0.1:4000` on FirstSpark isn't reachable from the desktop | Optional: publish LiteLLM on the tailnet, then add a Codex profile pointing at it |

## 2. Daily rhythm

| When | Time | What you do |
|---|---|---|
| **Morning** | 15 min | Open [[Overnight Report]]. For each PASS: skim that project's `REPORT.md`, look at its screenshots, answer its open questions in one message. For each FAIL: open the log path, then either fix the spec/CLAUDE.md or leave it queued. Move finished projects out of **Tonight**. |
| **Day** | your focus | One Claude session per project you're actively shaping (filed in the Projects sidebar group). Give feedback in batches, not one tweak per message. Use Opus. |
| **Evening** | 5–10 min | Update [[Project Priorities]]: fill the Claude, Codex and Hermes lanes under **Tonight** (up to 3 each). For each project already overnight-ready, widen its scope in CLAUDE.md ("Overnight target = Slice 1") if the last slice passed. Write tomorrow's feedback into each project's `FEEDBACK.md`. |
| **Night** | 0 min | The runner starts at 23:00. Hermes cron jobs run on FirstSpark. You don't watch transcripts. |

## 3. Prompts that work

| Goal | Say this |
|---|---|
| Make a spec'd project overnight-ready | "Make `<folder>` overnight-ready: read its BUILD_SPEC.md, scope the first slice, write CLAUDE.md (commands, boundaries, stop-when), `scripts/verify.ps1` that checks that slice, the Stop-hook gate like mock-interview-gauntlet's, and PROGRESS.md. Commit and push." |
| Advance to the next slice | "Slice N of `<folder>` passed. Update CLAUDE.md and verify.ps1 to target slice N+1 from BUILD_SPEC.md. Commit." |
| Big daytime feature | "Plan this, then use the builder subagent for each milestone and the reviewer after each one. Commit per milestone. Done = verify passes." |
| Batch of feedback | "Work through FEEDBACK.md top to bottom. For each item: make the change, take before/after screenshots at desktop and mobile width, commit, tick the item. Put questions in REPORT.md." |
| You're unsure what you want (look and feel) | "Make 3 variants of `<screen>` on separate branches `variant-a/b/c`, each with screenshots in REPORT.md. Don't merge any." Then pick one in the morning. |
| Repeated taste corrections | "Add this to the project's CLAUDE.md design rules so I never repeat it: <rule>." |
| Long goal in one session | `/goal <outcome> — verify: <command> passes` (Claude keeps going until the check is met) |
| Parallel independent work | "Split this into separate sessions" (each gets its own card and row) or "use a workflow" for a scripted fan-out |
| Morning triage, any harness | "Read Nightly Runs/Overnight Report.md and each project's REPORT.md. Summarize what passed, what failed and why, and list every open question with its recommended default." |

## 4. Which tool and model for what

| Work | Use | Why |
|---|---|---|
| Design, taste, specs, hard debugging (daytime, interactive) | **Claude Code · Opus 5.5** (high effort) | Best judgment per turn |
| Overnight coordinator | **Claude Code · Opus** via the runner (default) | Plans, delegates, reviews summaries |
| Overnight builders | **builder subagent · Sonnet** | Most of the tokens; stretches the Max 5-hour windows |
| Architecture calls, final review of an MVP | **Fable** | Separate small weekly bucket, so short high-value turns only |
| A second opinion, or a second overnight lane when Claude's window is spent | **Codex (ChatGPT subscription)**: `@codex` in Tonight | Separate quota; reads the same shared rules |
| Long grinding loops, private data, Spark-deployed services | **Hermes on FirstSpark** with `glm53-flash` (Second+Third Spark; default since 2026-10-19), or `spark-fast` (Qwen3.6-35B-A3B) for quick tasks | Free and unlimited; data stays local |
| Kaggle Learning Center's own in-app model calls | **Claude API credits ($250)** | Set `ANTHROPIC_API_KEY` only in that app's service env, never globally (otherwise Claude Code bills the API instead of Max). Use prompt caching and the Batch API for bulk work. |

Max (5x) has a 5-hour window and a weekly limit. Three Claude projects in parallel use the window about three times as fast, so mix in `@hermes` and `@codex` lines to spread the load. If a night hits the 5-hour wall, the runner marks the rest of the queue "usage limit" and they continue the next night from PROGRESS.md.

## 5. What carries across Claude, Codex and Hermes

| Practice | Claude Code | Codex | Hermes |
|---|---|---|---|
| Shared rules file | ✅ `~/.claude/CLAUDE.md` block | ✅ `~/.codex/AGENTS.md` block | ✅ `~/.hermes/SOUL.md` block (FirstSpark) |
| Project rules | CLAUDE.md | AGENTS.md | AGENTS.md / CLAUDE.md / .hermes.md |
| Verify script as "done" | ✅ plus a Stop hook that blocks stopping | ✅ the runner re-runs verify after Codex finishes (no Stop hook) | ✅ the loop gate in its prompt files |
| Unattended runs | runner (`@claude`), `/goal`, `/loop`, routines | runner (`@codex`, via `codex exec`) | runner (`@hermes`, via `hermes chat --query-file - -Q --yolo` over SSH), Hermes cron, background runs |
| Subagents | ✅ builder / reviewer | not set up | Hermes background review |
| PROGRESS.md / REPORT.md / DECISIONS.md | ✅ | ✅ | ✅ (its handoff file plays REPORT's role) |

Tip: keep project rules in **AGENTS.md** with a one-line **CLAUDE.md** containing `@AGENTS.md`. Then all three harnesses read the same file.

## 6. One-time steps for you (not done; blocked for agents)

1. **Review and commit the runner** (from `F:\Vaults\LLMWiki`):
   `git add Local_Setup/scripts/overnight-run.ps1 Local_Setup/agent-rules/overnight-prompt.md; git commit -m "Add overnight queue runner"; git push`
2. **First run while you watch** (catches auth or path problems). For a mixed test, put one project in Tonight as `@hermes` and leave the others as `@claude`:
   `powershell -NoProfile -ExecutionPolicy Bypass -File F:\Vaults\LLMWiki\Local_Setup\scripts\overnight-run.ps1 -HoursPerProject 0.5`
   Then open [[Overnight Report]] and the logs it names. Add `-PerHarness 1` to run one project per tool at a time.
   How `@hermes` works: the runner SSHes to FirstSpark, pulls the project, runs Hermes headless with the same prompt and a time budget, then pulls Hermes's pushed commits onto the desktop and runs `verify.ps1` here (FirstSpark has no PowerShell).
3. **Schedule it nightly at 23:00** (PowerShell):
   ```powershell
   $a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "F:\Vaults\LLMWiki\Local_Setup\scripts\overnight-run.ps1"'
   Register-ScheduledTask -TaskName 'Overnight Agents' -Action $a -Trigger (New-ScheduledTaskTrigger -Daily -At 11pm) -Settings (New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 9) -StartWhenAvailable)
   ```
   It runs only while you're logged in, which suits an always-on workstation. Remove it with `Unregister-ScheduledTask 'Overnight Agents'`.

## 7. Keeping it current

- **Change the shared rules:** edit `Local_Setup/agent-rules/AGENTS.md`, then run `python F:\Vaults\LLMWiki\Local_Setup\scripts\sync_agent_rules.py` on the desktop and `ssh FirstSpark python3 ~/vaults/LLMWiki/Local_Setup/scripts/sync_agent_rules.py` (copy the two files over first if Obsidian Sync hasn't). Start a new Hermes session to pick up SOUL.md.
- **New service on FirstSpark:** take a port from the free list in [[FirstSpark Port Registry]] and add its row.
- **Claude features worth knowing:** `/goal` (keep going until the check passes), `/loop` (repeat on an interval), "use a workflow" (scripted multi-agent fan-out), `/schedule` (cloud routines that run while the PC sleeps), side sessions and worktrees for parallel writers, `/code-review` before merging, `/fewer-permission-prompts`, Remote Control (answer blockers from your phone).
