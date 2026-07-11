---
title: "What Dreaming actually does"
author: "Mnimiy"
username: "@Mnilax"
date: "2026-05-14"
tweet_url: "https://x.com/Mnilax/status/2054955621829443903"
tweet_type: "original"
likes: 160
retweets: 20
replies: 9
bookmarks: 414
views: 124807
has_media: false
extraction_quality: full
article_id: "2054929277317939200"
tags: ["twitter-bookmark", "claude", "agents"]
---

# What Dreaming actually does

> **Source:** [@Mnilax](https://x.com/Mnilax) · 2026-05-14 · 👍 160 · 💬 9 · 🔖 414 · 👁 124807

> 🔗 [View tweet on X](https://x.com/Mnilax/status/2054955621829443903)

## Article Content

Not lying on purpose. Lying the way an old config file lies: rules I wrote months ago, for a context that no longer exists, that Claude still follows every session.

I found out by running Anthropic's new Dreaming feature locally. It reads up to 100 past sessions and rewrites your memory file. The official version is gated behind Managed Agents with beta headers. Mine is 80 lines of Python.

I fed it every Claude Code session from the last 90 days. 6M tokens. 100 sessions. 11 minutes. $4.20.

What came back was a 38-line file that deleted three quarters of my CLAUDE.md and resurfaced four patterns I had never written down.

This article is the file, the script, and what the deletion list says about how humans write CLAUDE.md.

## What Dreaming actually does

Anthropic's [official blog post](https://www.anthropic.com/news/dreaming)

 describes Dreaming as an asynchronous pass over an existing memory store. The agent reads transcripts from up to 100 prior sessions, finds patterns, and outputs a new memory store. The original is preserved. You review the new one and keep or discard.

Three numbers from the announcement matter:

- ****100 sessions**** is the cap per dream pass
- ****"tens of minutes"**** is the runtime
- ****Harvey reported 6x task completion improvement**** after running Dreaming on their drafting agent

Six times. Not 14%. Not 41%. Six.

That number is what made me skip the wait for general availability.

The official feature requires Managed Agents access with a beta header. I don't have that. Neither do you, probably. So the question became: can a single user with a Claude Code subscription and 90 days of session transcripts do the same thing locally?

Yes. Here's how.

## Why a local replica beats waiting

Managed Agents is enterprise-priced. Dreaming itself runs on standard API tokens, but the platform around it isn't designed for individual users. For me that's a non-starter.

The raw material is already on disk. Look at ~/.claude/projects/<project>/. Every session you've ever run sits there as JSONL. Memory subdirectory included. Nothing to upload, nothing to migrate.

So the question wasn't "should I wait." It was "is there anything in the Managed Agents version that a single Python script and one good rubric can't reproduce?"

After 90 minutes the answer was no. Not for a single-user workflow. The script below is what came out of that 90 minutes.

https://x.com/Mnilax/article/2054955621829443903/media/2054931059339354114

### The 90-minute local replica

The script lives in one file: [dream.py](https://x.com//dream.py)

. It does four things, in order.

```python
# dream.py — local Dreaming replica
# Reads ~/.claude/projects/*/sessions/*.jsonl
# Outputs a single memory file: ~/.claude/memory/dream_output.md

import os, json, glob
from pathlib import Path
from anthropic import Anthropic

client = Anthropic()
SESSION_DIR = Path.home() / ".claude" / "projects"
OUTPUT = Path.home() / ".claude" / "memory" / "dream_output.md"

# Phase 1 — Orient. Read existing memory if any.
existing = ""
existing_path = Path.home() / ".claude" / "memory" / "MEMORY.md"
if existing_path.exists():
    existing = existing_path.read_text()

# Phase 2 — Gather. Pull the last 100 sessions.
sessions = sorted(
    glob.glob(str(SESSION_DIR / "*" / "sessions" / "*.jsonl")),
    key=os.path.getmtime,
    reverse=True
)[:100]

transcripts = []
for s in sessions:
    with open(s) as f:
        msgs = [json.loads(line) for line in f if line.strip()]
        # Keep user messages and assistant responses only; drop tool noise
        clean = [m for m in msgs if m.get("type") in ("user", "assistant")]
        transcripts.append("\n".join(json.dumps(m) for m in clean))

# Phase 3 — Dream. Single API call with the rubric prompt.
rubric = Path(__file__).parent / "rubric.md"
prompt = rubric.read_text() + "\n\n" + \
         f"Existing memory:\n{existing}\n\n" + \
         f"100 sessions follow:\n\n" + "\n---\n".join(transcripts)

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=8000,
    messages=[{"role": "user", "content": prompt}]
)

# Phase 4 — Output. Write the new memory file.
OUTPUT.parent.mkdir(parents=True, exist_ok=True)
OUTPUT.write_text(response.content[0].text)
print(f"Dream complete. Output: {OUTPUT}")
```

That's it. Four phases. One API call. The rubric is a separate file I'll show in the next section. It's where the actual quality of the output lives.

Cost of one dream pass: $4.20 in API tokens. The 6M-token input is large but the output is small (a memory file is at most a few thousand tokens). Caching cuts the next pass to under $0.80 if you run again within an hour.

I ran this Saturday morning. It took 11 minutes.

https://x.com/Mnilax/article/2054955621829443903/media/2054931235433029632

## The rubric that made the difference

I ran the script twice. First pass: no rubric, just "summarize what you learned about this user." Output was useless. Generic statements like "User values efficiency" and "User prefers clear communication." Could have been written about anyone.

Second pass used this 12-line rubric. That run produced the 38-line file in the next section.

```markdown
# Dream pass rubric

You are doing a forensic pass over 100 of my Claude Code sessions.
Your job is not to summarize what I asked. It is to find patterns I would not write down myself.

Output a memory file with three sections:

## Workflow patterns observed
- Cite frequency: "[high-confidence, 50+ sessions]", "[medium]", "[low]"
- One line per pattern. No prose.
- Behavioral observations only. No declared preferences.

## Decisions and reasoning
- Capture architectural and stylistic choices I made and rejected
- Include the date of the decision if visible in transcript
- Note what was tried and rejected, not just what I picked

## Patterns to NOT re-suggest
- Things I've rejected multiple times across sessions
- Format: brief reason, no defense of why I should reconsider

Rules:
- Maximum 40 lines total. Trim anything that doesn't earn its line.
- If a "preference" appears once or contradicts another, delete it.
- Cite session count, not session names.
- One-off corrections are NOT preferences. Recurring patterns are.
```

The rubric is the article's biggest takeaway. Without it, Dreaming produces generic LinkedIn-style summaries. With it, you get something useful.

12 lines of rubric. 38 lines of output. 6M tokens of session data behind both.

https://x.com/Mnilax/article/2054955621829443903/media/2054931374704820224

## The memory file Claude wrote

38 lines. Behavior, not preferences.

```markdown
## Workflow patterns observed across 100 sessions

[high-confidence, 50+ sessions]
- Asks for "review" or "feedback" but accepts approval 73% of the time without revision
- Switches between TypeScript and Python mid-conversation; rarely re-states stack context
- Treats /clear as a checkpoint not a reset — expects context retention after /clear
- "Quick fix" requests average 12 turns to resolution; flag at turn 4 to redirect
- Corrects prose output 8.2x more than code output

[medium-confidence, 20-50 sessions]
- Prefers diffs over rewrites for changes >40 lines
- Asks "what did you change" after edits; pre-emptive summary saves a turn
- Uses Polymarket-related vocabulary; codebase context is trading infrastructure
- Discards 3-step explanations; keeps single-line answers
- Will ask for shorter output 3-5 messages in; default shorter from start

[low-confidence but worth keeping, <20 sessions]
- Sometimes builds in restricted networks (Hetzner / Riga / proxy hops); test commands accordingly
- Prefers ALL_CAPS for env var documentation
- Em-dashes flagged as "AI-sounding"; minimize unless rhythmic

## Decisions made and the reasoning behind them

[architectural]
- Hetzner Falkenstein chosen 2026-02: German jurisdiction, $4.51/mo, low latency to Polymarket EU
- 4-process screen pipeline (scanner -> brain -> executor -> exit_monitor): debugged once, never refactor
- Sonnet 4.6 for scoring, Opus 4.7 for full theses. Cost split, not capability split.

[style]
- Articles run 2,500-3,000 words target; drop below if filler
- Banner format locked: #EFEAE0 + serif + monospace strip
- "What didn't work" section mandatory for credibility load

## Patterns Claude should NOT re-suggest

- Switching from screen to systemd (rejected 4 times, complexity not worth it)
- Kubernetes deployment (rejected, single-VPS architecture is intentional)
- Switching trading from Polymarket to Kalshi as default (Polymarket-first is explicit)
- Adding Grafana / monitoring stack (rejected, logs + cron alerts are enough)
```

That's the whole file. 38 lines. Not a few hundred. Not "comprehensive." Not "About me: I am a developer who likes clean code."

It is a forensic summary of patterns Claude observed across 6 million tokens of actual work. Half of it is uncomfortable to read because it documents things I had never written down.

## The four patterns I didn't know I had

Reading the output, four lines hit hard. Not because they were surprising in isolation, but because seeing them in writing made the behavior visible enough to fix.

****Pattern 1. "Review" means "approve"****

> Asks for "review" or "feedback" but accepts approval 73% of the time without revision

I had written this prompt hundreds of times: "Review this and tell me what's wrong."

Claude would respond with a list of issues. I'd say "thanks, let's keep moving" and not address any of them.

Claude's read on me: I'm not asking for a review. I'm asking for permission. 73% of the time, the request resolves with no edit applied.

Once you see it, you can't unsee it. The fix: ask for "approval or block" with a binary decision, or actually ask for a rewrite. Stop pretending the middle option is what you wanted.

****Pattern 2. Stack switching without context****

> Switches between TypeScript and Python mid-conversation; rarely re-states stack context

I'd start a session in the trading bot (Python), then ask a question about the article builder (TypeScript), then go back to the bot. Claude doesn't know I switched. Half the broken outputs in my session history were Claude applying TS idioms to Python files because I never told it I had moved.

Fix is one line. Add to CLAUDE.md: "Always re-confirm language at the start of any new sub-task."

The reason this matters: Claude only flagged the issue in the dream pass, not in real time. Dreaming finds drift the model can't catch in-session, because in-session it's busy answering, not auditing.

****Pattern 3. Quick fixes are never quick****

> "Quick fix" requests average 12 turns to resolution; flag at turn 4 to redirect

This one I knew abstractly. I didn't know it averaged 12 turns. The dream output is concrete: by turn 4, the chance of resolving without a full restart is under 30%. The signal Claude wants to surface is "we're past the quick zone, do you want to start over."

I built a tiny hook for this. It triggers on any prompt containing "quick fix" or "small change" and starts a counter. At turn 4 it injects: "This thread has 4 turns of debugging. Restart or commit to a longer fix?" It's annoying. It also halved the average turn count.

****Pattern 4. Prose corrections 8x more than code****

> Corrects prose output 8.2x more than code output

I checked the number three times. It's correct.

Across 90 days I corrected Claude's prose output 8.2x more than its code output. ****That ratio is wrong in both directions:****

- Either my code is bad and Claude is silently absorbing my mistakes
- Or my prose taste is overcalibrated and I'm correcting things that are fine

Probably both, but the second matters more. I'm spending 80% of my editing energy on something that's already 90% there, and 20% on something that might be 60% there. The ratio is upside down.

The new memory file has this as a permanent line. Every new article session opens with Claude flagging that I'll over-edit and asking if I want to commit to the third draft early.

https://x.com/Mnilax/article/2054955621829443903/media/2054931547363409920

## What got deleted

73% of the preferences in my old CLAUDE.md got deleted by the dream pass. Reading the deletion list is more useful than reading the keep list.

****Here's a sample of what got cut:****

```
[deleted — one-off correction misclassified as preference]
- "User prefers TypeScript" (you used TS once, in 2026-02. You write Python.)
- "Always use bullet points" (you said this once, then asked to remove bullets in next 3 sessions)
- "Be concise" (you've said this 47 times. It's noise. You'll say it again. Not a preference, a tic.)

[deleted — context that aged]
- "Working on Polymarket V1 architecture" (V2 shipped 2026-03)
- "Prefer Hetzner Helsinki location" (moved to Falkenstein 2026-02)

[deleted — contradictory]
- "Use em-dashes for rhythm" AND "Em-dashes sound like AI" (both in same file)
```

Three categories. Each one explains a different failure mode of how humans write CLAUDE.md files:

1. ****One-off corrections become permanent rules.
****You correct Claude once, write it down, and now Claude is following a 6-month-old preference from a context that no longer applies.
2. ****Context ages out.
****Your tools change. Your projects change. The CLAUDE.md doesn't.
3. ****You contradict yourself.
****You write rules at different moments with different priorities. They pile up. Nobody audits them.

The dream pass cleans all three categories simultaneously because it has access to every session, not just the moment you decided to write a rule.

This is what Anthropic means when they say Harvey got 6x completion improvement. It's not that Dreaming makes the model smarter. It's that Dreaming deletes years of accumulated CLAUDE.md noise that was actively making the model worse.

https://x.com/Mnilax/article/2054955621829443903/media/2054931671170879488

## The compounding effect (7 days after)

I applied the new memory file as my CLAUDE.md on Saturday. Tracked the next 7 days against the prior 7 days.

The last row matters. After the dream pass Claude was more confident, and sometimes more confidently wrong. The memory file strips out hedging that was occasionally doing useful work.

Net effect is still positive: the other five rows pay for it. But anyone running this should expect the same trade. You buy speed and you lose a little of "Claude will second-guess itself before you do."

The token reduction is real money. At my usage volume that's about $90/month back if it holds. Will it hold? Probably not at this rate.

Patterns shift. Memory drifts. The honest answer: I'll re-run dream every 14-30 days to keep the file current.

https://x.com/Mnilax/article/2054955621829443903/media/2054931982837010432

That's the actual workflow Dreaming enables. Not "set it once." Run periodically. Audit drift. Re-dream.

## What didn't work

Five honest negatives.

****1. Dream output without a rubric is useless.
****First-pass output was generic enough to apply to any developer. The rubric is what made the difference. Don't run this script without one.

****2. 100 sessions is too few for confident pattern extraction.
****Claude flagged 11 patterns at "high confidence" and 14 at "medium." With 200+ sessions, that ratio should invert: more high-confidence, fewer hedged. Harvey was running thousands of agent transcripts. I was running 100. Smaller signal.

****3. File overwrite is risky.
****The script writes to a new file (dream_output.md), not your existing MEMORY.md. Diff before applying. I had three lines I disagreed with on first pass and would have lost them if the script overwrote directly.

****4. Local replica has no continuity feature.
****Anthropic's Dreaming runs as a managed service that can chain dream passes over time. Mine is a one-shot. If you want a continuous loop, you need a cron job plus diff tracking. Not in my script.
(For reference: a community repo, dream-skill, appeared on GitHub within 48 hours of the announcement and does add auto-triggering. Mine stays deliberately minimal.)

****5. The 6x number from Harvey doesn't transfer to individual users.
****Harvey ran one task type across thousands of sessions. I ran four task types across 100. The lift scales with that ratio. 41% is my number. 6x is Harvey's. Don't expect Harvey's.

## The workflow this actually enables

Dreaming isn't a one-time cleanup. It's a maintenance cycle.

Your CLAUDE.md decays. Every session you add a one-off correction. Every month a project name goes stale. Every few weeks you contradict a rule you wrote and forgot. Left alone, the file gets longer and worse at the same time.

The dream pass is the audit you'd never do by hand, because doing it by hand means re-reading 100 sessions. The script reads them for you and returns the 38 lines that survived contact with your actual behavior.

So the cycle is: ****dream -> diff -> apply -> work for 14-30 days -> dream again.****

Each pass deletes the noise the last two weeks added and promotes whatever new pattern became real. The file stays short because something is actively trimming it.

That's the part the blog post undersells. Dreaming isn't "the model learns about you once." It's "the model re-derives who you are from evidence, on a schedule, and throws out last month's version of you."

### The mental model

Stop thinking of CLAUDE.md as a config file you write once. Start thinking of it as a cache that goes stale.

- ****What you declare**** — the rules you type into CLAUDE.md by hand. High intent, low accuracy. You're guessing at your own patterns.
- ****What you do**** — the behavior sitting in 100 session transcripts. Zero intent, total accuracy. It's just the record.
- ****The dream pass**** — the function that turns the second into the first. It reads what you do and rewrites what you declared.

The reason 73% got deleted: declared preferences and actual behavior had drifted that far apart. Not because I lied. Because I wrote rules at a moment, and moments age, and nobody was reconciling the file against the evidence.

For things you think you want: write them in CLAUDE.md and let the next dream pass test them against reality. For things you actually do: you can't see those yourself. That's what the dream pass is for. For keeping the file honest: re-dream on a schedule. Drift is the default. The pass is the correction.

Your CLAUDE.md should be the output of your behavior, not your guess about it.

https://x.com/Mnilax/article/2054955621829443903/media/2054932120376680448

## Closing

The question Dreaming answered wasn't "what does Claude know about me." It was "what's in my CLAUDE.md that's actively making things worse."

73% of it, as it turned out.

This is part of the same family I've been documenting. The earlier piece was where your tokens actually go (73% wasted across 9 invisible patterns). This one is the layer underneath: the memory file those sessions were running against, and how far it had drifted from reality.

If you've been writing CLAUDE.md for a year, you have the same problem. One-off corrections piled up. Aged context. Contradictions you don't remember writing. The fix isn't a longer file. It's a forensic pass.

Run the script. Read the output. Disagree with three lines if you want. Apply the rest. Re-run in 14 days.

Pick the 38 lines that earn their place. Delete the 73% that doesn't.

If this saved you a week of debugging your own CLAUDE.md, repost.

Part 2 next week: ****the same dream pass on the Polymarket trading bot.**** The findings about my own risk discipline were worse than the CLAUDE.md ones.

> Bookmark this — the script and rubric are reusable across every project. 
> 
> Telegram for daily dream-rubric iterations and benchmark updates: [https://t.me/+_ZWrQN7GuDA3ZDEy](https://t.me/+_ZWrQN7GuDA3ZDEy)

> 📄 Original article URL: https://x.com/i/article/2054929277317939200

---

## Commentary from Other Bookmarks

### @Mnilax (Mnimiy) — 2026-05-14

> you can write a perfect CLAUDE.md today and it will still be lying to Claude in three months.
> 
> not because you wrote it wrong. because the file is static and your work isn't.
> 
> a correction you made once becomes a permanent rule. a project name goes stale.
> 
> a preference you typed in January quietly contradicts one you typed in March. the file never changes. you do.
> 
> writing a good CLAUDE.md is a solved problem. keeping it true to how you actually work is the part nobody has a process for.
> 
> i gave myself one: it reads 100 of my past Claude Code sessions and rewrites the file from what the transcripts show, not from what i remember typing.
> 
> the result on my own setup:
> > 73% of my CLAUDE.md got deleted on the first pass
> > most of it was one-off corrections that had hardened into rules
> > four patterns i had never written down got surfaced instead
> > one of them: i correct Claude's prose 8.2x more than its code
> 
> the keep list was 38 lines. the delete list taught me more.
> 
> learn to write the file from the video. then read the article for the part that comes after: keeping it honest.
> 
> a CLAUDE.md you never audit isn't a memory file. it's a museum.

[→ View quote tweet](https://x.com/Mnilax/status/2054997650160885841)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

