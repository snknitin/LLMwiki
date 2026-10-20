# Hermes Nightly Runs — Loop Engineering How-to

Beginner-first guide for running unattended (nightly) work in Hermes, based on real session forensics (Sep–Oct 2026) and the canonical loop policy now in every active project's `AGENTS.md`.

## The mental model (read this once)

```
IDEA  ──>  SESSION A (brainstorm)          SESSION B (run)              MORNING
           human in the loop                unattended, no human         you triage
           output: goal doc + prompt file   output: gates + handoff      output: done OR
           "one job: design"                "one job: execute"           a 15-min fix
```

Three rules that make it work:

1. **One session = one job.** Session A thinks; Session B runs. Mixing them is why sessions "degenerate".
2. **Unattended work is a LOOP, never a goal.** A goal is one shot — if the agent dies mid-goal, the night is lost. A loop has a gate, a max, a handoff, and a queue on disk — if the agent dies, one step is lost, and the next session resumes from the queue.
3. **The human's job changes shape:** during the day you *design* (Session A); at night you are *absent*; in the morning you *triage* 3 files (status, git log, the handoff). You never watch the transcript.

## How the desktop app maps to this (what you actually touch)

| What you do | In the app |
|---|---|
| Start a clean session | **New Chat** button in the sidebar |
| Name it (findable later) | Type `/title Night-Plan` in the chat box |
| Load skills | Just name them in your prompt ("load the prompt-speak skill…") or a bundle name like `/tenx` |
| Send the run | Type the one-liner (or `/background` + the one-liner) into the **chat input**, press Enter. **No terminal.** |
| Watch the running work | The status strip / task chip under the input; the **Files** pane for commits and the handoff file |
| Switch model | The **model picker at the top of the chat** (hover to change session model) |
| Approve things (memory writes, etc.) | The **approval card in the chat** — one click |
| Kill a bad run | `/stop` in the chat input, or the stop button on the running task |

Slash commands work by typing them **into the chat input box** — an autocomplete menu pops on `/`, and `/help` lists what's live in your build. Same commands, zero terminal.

## The five pieces every loop must have

A loop = **gate + body + max + no-progress exit + queue of record** (the canonical wording is in every active repo's `AGENTS.md` and in `prompt-speak` skill → `references/24x7-loop-graph-playbook.md` §6).

- **Gate** — one exact re-runnable command + pass condition. `curl` returning 200 is NOT a gate; `status=="ready" AND stale==false` is.
- **Body** — one bounded unit (one slice, one playlist, one batch). Never "do all four at once".
- **Max** — attempts and minutes, per step AND total.
- **No-progress exit** — the handoff line the agent writes when the gate fails twice or a cap hits. Writing it IS done, not failure.
- **Queue of record** — a JSON ledger on disk (e.g. `Docs/regen-queue.json`) that survives session death. A fresh session reads it FIRST.

## Session A — Brainstorm (human in the loop)

Do this in the daytime, 30–60 min.

1. **Open a fresh session.** `/new`, then `/title YLC-night-plan`.
   Fresh context means no stale state; the skills below load clean.
2. **Load the right skills by naming them.** First line of the session:
   > "I'm planning an unattended evening run for YouTube Learning Center. Load the **prompt-speak** and **design-doc-to-goal** skills and follow them."
   (Naming a skill in prose loads it; or use `/skills` to list and search.)
3. **State the outcome in one sentence** — what should be TRUE in the morning?
   > "In the morning I want the four target playlists to show fresh Atlas + Reference on the live dashboard, all committed, pushed, deployed, and verified through the Tailscale endpoint."
4. **Let it interview you.** The skill turns your answers into slices, each tagged with: body / gate / retry cap / no-progress exit. Push back on anything vague. The single most important question to force is: *"What is the exact command that proves step N passed?"* If it can't name one, the design is not done.
5. **Ask for the deliverables — two files, committed:**
   > "Write the goal doc to `Docs/goal-<name>.md` with the slice table, the exact gate commands (URLs and JSON fields from AGENTS.md), and an open-decisions block with a recommended default for each question. Then write the execution prompt — **loop shape, ≤450 words, prompt-speak grammar** — to `Docs/prompts/night-<name>.md`. Commit both as one small `docs:` commit. Paste the execution prompt inline here so I can read it."
   Why the prompt is a FILE: Session B becomes a one-line start, the prompt has a permanent record, and you can re-run it any time ("Resume") — including from a new machine.
6. **Read the inline prompt before you approve.** Use the 5 pre-paste checks (they're in `prompt-speak`): last step checkable? `<exit>` block present? every loop capped? no secrets in plaintext? would every branch run at 3 AM with nobody online? If any fails, send it back to the agent in the SAME session.
7. **Approve the commit, close Session A.** `/title` it, that's it. Nothing runs yet.

## Session B — The run (unattended)

Evening, 2 minutes, then you leave.

1. **Fresh session again.** `/new`, `/title YLC-night-run`.
   - Fresh context is load-bearing: the run inherits the *files*, not your daytime conversation.
   - `/status` once to confirm the right model/provider is active for the night (the AGENTS.md names the one the project expects).
2. **Kick it off — one line:**
   > "Run `Docs/prompts/night-<name>.md` exactly as written. Treat that file as the full instruction set — every cap, gate, and handoff rule in it applies. Start in background with exit notification."
   - Or the slash form: `/background Run Docs/prompts/night-<name>.md exactly as written`
3. **Leave it.** Watch it only if you stay up: `/agents` lists running work; `/status` shows progress. That's it — the agent commits each step, writes the queue, and writes the handoff if it stops. `/stop` aborts a runaway.

## Morning triage (10 minutes max)

In *any* new session (or `Resume` the run session): `/status` → then ask:

1. **"Show me the queue."** → the agent `cat`s `Docs/<name>-queue.json`; you see which steps are `review` (pass) / `blocked` (fail) / `ready` (next).
2. **"Did each committed step actually deploy?"** → it re-runs each gate FRESH (a 200 is not proof).
3. If one step is `blocked`: its handoff line names the last failing gate output, the recommended default, and the last commit hash. **That line is your next 15-minute job** — one session, one step, gate re-run, done. If all green: you're home.

**Verify the guard works (do this ONCE per project):** deliberately `/stop` a run mid-step, open a fresh session, and say "Resume this run." The agent must pick up from the queue with zero lost state. After one clean injection-resume, trust the mechanism until evidence says otherwise.

## Example — what the Oct 9 YLC night would have looked like

**What actually happened (the forensics):** a single goal with four "phases" (Atlas + Reference across playlists), no gate, no retry, no queue. The agent spent the night inside phase 1, never reached the others, and ended with nothing committed. You found out in the morning. Failure type: *no-exit goal + no gate = lost night.* Your Oct 3 variant of the same bug: ended "staged but not committed, pushed, deployed, or restarted" — work done, unusable, because "done" wasn't defined as deploy-verified.

**What would have happened instead:**

- Session A (~45 min) produced `Docs/prompts/night-regen-loop.md` — a 4-step loop, one step per playlist:
  - Gate (verbatim): `curl -sS <Tailscale-URL-from-AGENTS.md>/api/playlists/<id>/status` passes only if `status=="ready" AND stale==false`.
  - Body: regenerate ONE playlist's Atlas + Reference; update its queue row; commit → push → restart `youtube-learning-center.service` → re-run the gate.
  - Max: 2 restarts per step, 45 min per step, 4 steps total, 240 min total; 2 retries per step before the no-progress handoff.
  - No-progress exit: write `Docs/regen-handoff.md` (states of all four rows, last gate output, last commit, recommended default) and end.
  - Queue of record: `Docs/regen-queue.json`, re-read before every step.
- Session B: one line — "Run `Docs/prompts/night-regen-loop.md` exactly as written." → leave.
- Worst case at 3 AM after step 2: handoff file on disk, two steps already **committed + pushed + deployed + verified** (so you have a deploy-verified partial result — the exact thing Oct 3 didn't give you), queue says step 3 is next. Morning: one 15-minute session, not a re-run night.

## Beginner failure checklist (read when a night goes wrong)

| Symptom | Root cause | Fix for next time |
|---|---|---|
| Agent ended mid-task, nothing committed | Goal with no `<exit>` + no deploy gate | Loop prompt with per-step gate; "staged = FAILED gate, not progress" |
| Agent kept asking a question at 3 AM | No default for that branch | Add the question to Session A's open-decisions with a recommended default |
| Agent "verified" what it didn't run | Evidence gate missing | Session A forces a gate command per step; Session B re-runs gates fresh |
| Whole night lost to one bad step | One long session | Steps with retry caps + handoff; a dead session must cost at most one step |
| Can't figure out what was done in the morning | State lived in the chat only | Queue of record on disk; "Show me the queue" always answers it |

## Pointers

- Canonical policy block: `prompt-speak` skill → `references/24x7-loop-graph-playbook.md` §6 (also already in the AGENTS.md of YLC, Dunbar Dossier, Kaggle Learning Center, social-capture as of 2026-10-09).
- Related skills: `prompt-speak` (prompt grammar, Template E loop), `tenx-engineer` (graph/scheduler, lanes), `design-doc-to-goal` (Session A output rules), `session-forensics` (post-mortems), `portable-python-projects` (AGENTS.md is part of the scaffold for every new project).
- Every new project gets AGENTS.md with the loop policy **at scaffold time** — it's basic functionality, not something to ask for.
