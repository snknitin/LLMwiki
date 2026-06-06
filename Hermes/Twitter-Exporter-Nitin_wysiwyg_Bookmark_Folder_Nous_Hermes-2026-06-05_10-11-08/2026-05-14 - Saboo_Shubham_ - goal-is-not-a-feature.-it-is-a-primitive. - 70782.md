---
title: "****/goal is not a feature. It is a primitive. ****"
author: "Shubham Saboo"
username: "@Saboo_Shubham_"
date: "2026-05-14"
tweet_url: "https://x.com/Saboo_Shubham_/status/2054988166541770782"
tweet_type: "original"
likes: 1006
retweets: 118
replies: 29
bookmarks: 2508
views: 227623
has_media: false
article_id: "2054805605995696128"
tags: ["twitter-bookmark", "claude", "agents"]
---

# ****/goal is not a feature. It is a primitive. ****

> **Source:** [@Saboo_Shubham_](https://x.com/Saboo_Shubham_) · 2026-05-14 · 👍 1006 · 💬 29 · 🔖 2508 · 👁 227623

> 🔗 [View tweet on X](https://x.com/Saboo_Shubham_/status/2054988166541770782)

## Article Content

****/goal is not a feature. It is a primitive. ****

HTTP is a primitive. JSON is a primitive. /goal is becoming one for coding agents.

A few weeks ago, OpenAI's Codex CLI added /goal as a way to give the coding worker a job with a defined done state. Claude Code added it this week.

Hermes Agent, the orchestrator I run on a Mac Mini to coordinate work between coding workers, has had /goal built in for a while.

So I now have a builder, a reviewer, and an orchestrator that all accept the same instruction format, even though they share nothing else.

If you've only seen /goal used as a fancier prompt, you've missed what it changes.

### What /goal actually is

A regular prompt asks an agent for the next response. You read what comes back, decide if it's right, and push the agent forward to the next step. You're steering every turn.

/goal flips that. You write down what "done" looks like, submit it once, and the agent works toward it until it gets there. Here's a real one:

```
/goal Build the app described in SPEC.md. Done means tests pass, 
build passes, README is accurate, and git status only shows 
relevant project files.
```

The goal stays active until it's achieved, paused, blocked, cleared, or it runs out of budget.

This is different from putting the word "goal" inside a normal one-shot command. If you write codex exec 'goal: build the app', that's still a prompt with a label. The real primitive lives inside an interactive worker session. You launch the CLI, you submit /goal, and you walk away.

The shift is from prompting (you driving) to assigning (the agent driving toward a target you defined).

![](https://pbs.twimg.com/tweet_video_thumb/HIQtyk7aYAEwJoI.jpg)

GIF

### The three tools that currently speak /goal

The three tools accepting /goal aren't all the same kind of thing, so it's worth being specific.

****Codex**** is OpenAI's coding CLI. Strong at implementation, especially when given a clear spec. /goal is how you give it that spec.

****Claude Code**** is Anthropic's coding CLI. Strong at the inverse: finding what's wrong with code that looks right. Spec compliance, safety issues, error states, security holes. /goal is how you point it at code and ask for a review.

****Hermes Agent**** is a different kind of tool entirely. Not a coding worker, but an orchestrator that coordinates work between coding workers like the two above. /goal is how Hermes hands off tasks to whichever tool is right for the job, and also how I tell Hermes what I want in the first place.

What matters isn't that any one of them shipped /goal. It's that three different teams converged on the same primitive, and that convergence is what makes it possible to compose them.

![](https://pbs.twimg.com/tweet_video_thumb/HIQvSeHagAApJfS.jpg)

GIF

### Setting things up

The first time I needed Codex and Claude Code on the Mac Mini that runs Hermes, I didn't install them by hand. I sent Hermes a message asking it to install both and log me in. It handled the rest.

That's the workflow now. You don't type install commands. Setup is just another goal.

If you don't have an orchestrator running yet, the install pages for Codex and Claude Code are easy enough to follow. But once you do, you shouldn't set up another tool by hand. The point of having an orchestrator is that mechanical work stops being yours.

### What Hermes adds on top of /goal

A raw /goal is useful on its own. But it leaves you with a coordination problem.

If Codex is running in one terminal and Claude Code is running in another, you have to remember which process is doing what. You have to check logs. You have to manually pass review findings from one tool to the other.

Hermes turns those loose runs into a workflow:

1. You message Hermes (in my case, over Telegram from my phone)
2. Hermes creates goal cards on a Kanban board
3. Hermes picks the right worker for each card
4. The worker runs the goal in the background
5. The card stores the process id, PID, repo, and done criteria
6. When the build is ready, Hermes hands the repo to the reviewer
7. If the review blocks, Hermes sends the findings back as a fix goal
8. Hermes verifies the final output by inspecting the filesystem, tests, build, and git state

The board is what /goal becomes when there's an orchestrator on top of it. Every goal has a card, every card has a status, every handoff leaves a trail. Instead of hunting through terminals, you watch the work move across columns on your phone.

https://x.com/Saboo_Shubham_/article/2054988166541770782/media/2054814154419257344

### The three roles

The tools change. The roles don't.

****Orchestrator.**** Owns the control loop. Task decomposition, worker selection, Kanban cards, background processes, dependencies, final verification, the user-facing summary. In my setup, Hermes.

****Builder.**** Takes a spec and produces working code. Implementation is the bottleneck this role solves. Codex tends to be strong here.

****Reviewer.**** Reads what the builder produced and finds what's wrong with it. Correctness is the bottleneck. Claude Code tends to be strong here.

### A real run, end to end

I gave Hermes agent a goal to do this:

```
/goal Build a CLI tool that finds X mentions of me and pings me when 
something blows up.
```

Hermes broke the request into six cards.

****Card 1: Spec.**** Hermes wrote SPEC.md itself, capturing the stack, repo path, read-only constraints, mock mode requirements, tests, and verification commands. Owned by the PM role.

****Card 2: Codex builds.**** Codex ran /goal against SPEC.md. It created the project files, implemented the UI and backend, added tests, and got the app to a passing state. About 15 minutes. When it finished, npm test passed, npm run build passed, and git status showed only relevant new files.

****Card 3: Claude Code reviews.**** Claude Code ran /goal to review what Codex built. Checked spec compliance, read-only safety, API key handling, error states, tests, UI usefulness, bugs, and security issues. Result: PASS, no blocking issues.

****Card 4: Codex fix loop.**** Skipped, because the review passed. The card still matters when skipped. It shows Hermes can model conditional work. If Claude Code had blocked, Hermes would have handed the findings back to Codex as a new /goal.

****Card 5: Claude Code final verification.**** Skipped for the same reason.

****Card 6: Hermes final summary.**** Working app at the local path, UI and API both verified in mock mode. Codex built it with /goal. Claude Code reviewed it with /goal and returned PASS.

All of that came from one message. Three different tools did the actual work, but I only ever talked to Hermes.

### The verification rule

Hermes never trusted Codex's self-report. After Codex marked the build done, Hermes ran the commands itself:

```bash
npm test         # 17 tests passed
npm run build    # vite build passed
```

The verifier is what makes a /goal a contract instead of a promise. Don't trust the worker's self-report as final. Trust the verifier.

Coding agents are confident. They'll tell you the build passes when the build was never run. They'll tell you tests pass when they wrote tests that never executed. The verifier closes that gap.

Without verification, /goal is just a fancier prompt. With verification, it becomes a contract.

![](https://pbs.twimg.com/tweet_video_thumb/HIQtWv8awAAl3eC.jpg)

GIF

### Running multiple goals

You can run multiple /goals in parallel, but you can't point multiple coding workers at the same files without thinking about it first.

My default is one main builder per repo. If I want parallelism, I add it across clear boundaries. Different repos, different branches, git worktrees, separate packages, docs vs code, tests vs implementation. Anywhere two workers can't step on each other.

The bad pattern is three workers all editing the same file in the same repo. You get conflicts, partial overwrites, and one worker silently undoing another's work.

The better pattern is one writer at a time on any given file. Builder writes, reviewer only reads, fix goals stay scoped to the fix. Or run three builders in three worktrees on three competing approaches and let the orchestrator pick the best one.

The board is what makes this practical. Without it, parallel background workers become terminal chaos.

### What changes for me

The useful framing here is not "I can run agents in the background."

It's that one message turns into a pipeline across three different coding tools, and I watch the whole thing move across one board.

You stop sitting in a terminal waiting for one agent to finish, and start managing a queue of work with visible state.

If Codex and Claude Code had each invented their own job-handoff format, no orchestrator could route between them. The board is impressive, but the primitive makes the board even more useful.

The workers can change, but the primitive stays the same. The next coding tool that adopts /goal will join this pipeline without me changing anything. I'll just route work to it.

That's what good primitives do.

For more such cool tips and interesting ideas around Hermes, OpenClaw, Claude Code, Codex and other 24/7 agent teams.

Follow → [@Saboo_Shubham_](https://x.com/@Saboo_Shubham_)

> 📄 Original article URL: https://x.com/i/article/2054805605995696128

