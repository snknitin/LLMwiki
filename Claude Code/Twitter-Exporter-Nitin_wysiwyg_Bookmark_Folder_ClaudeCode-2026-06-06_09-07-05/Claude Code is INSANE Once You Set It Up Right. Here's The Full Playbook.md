---
title: "Claude Code is INSANE Once You Set It Up Right. Here's The Full Playbook."
source: "https://x.com/PrajwalTomar_/status/2063238968125333581"
author:
  - "[[@PrajwalTomar_]]"
published: 2026-06-06
created: 2026-06-08
description: "Most builders open Claude Code, paste a prompt, and pray.Some are paying $300 for courses that don't even cover what Anthropic put out for f..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/HKIU0RQbEAA-2Mb?format=jpg&name=large)

Most builders open Claude Code, paste a prompt, and pray.

Some are paying $300 for courses that don't even cover what Anthropic put out for free.

And then there's a small group who actually watched the creator of Claude Code show his workflow a year ago. They've been compounding ever since.

The gap is starting to show.

AI Twitter rediscovers this playbook every few months. The video dropped over a year ago. May 22, 2025. 1.3 million views. ZERO captions. Most people just refused to watch it.

The playbook below is what separates the builders shipping in days from the ones stuck in prompt loops. It's also what most people are still missing in 2026.

Here's the full breakdown of the system Boris Cherny actually runs at Anthropic. And the parts you should not skip.

![Image](https://pbs.twimg.com/media/HKIPIIWaQAAKgPE?format=jpg&name=large)

The 28-minute video that's been free on YouTube for over a year.

# What This Playbook Actually Is

This isn't a prompt list. It's not one of those 50-tip threads either. It's a full operating system for working with Claude Code.

The core idea Boris demos in the video is what he calls compound engineering. Every mistake becomes a permanent rule. Every repeated task becomes a reusable command. Every long task becomes a sub-agent. Every verification step becomes a hook. The system gets smarter every session because the context, the commands, and the routines all live inside the codebase.

His personal setup is surprisingly vanilla. Claude Code out of the box does most of the work. The leverage comes from five things stacked on top.

→ Persistent context through CLAUDE.md files

→ Reusable workflows through slash commands and sub-agents

→ Deterministic post-actions through hooks

→ Parallel execution through git worktrees

→ Plan-first, verify-always discipline

That's the whole playbook. The rest is execution.

This is suddenly everywhere again because Hermes Agent swarms, SOUL.md templates, and Claude Routines all run on these exact 5 primitives. The orchestrators changed. The foundation didn't. Set this up once and every new agent tool that drops in 2026 just plugs into your existing infrastructure.

# The Problem With How Most People Use Claude Code

Here's what most builders do.

They open Claude Code. They paste a feature request. Something looks off. They prompt again. Try a different angle. Re-paste with more context. The session runs out of memory. They restart. They re-explain the codebase. They re-explain the conventions. They re-explain the same edge case they explained yesterday.

This is what people mean when they say vibe coding doesn't work.

The model isn't the problem. Opus is the best coding model that's ever shipped. The problem is the workflow. Every panic prompt session starts from zero context, the output drifts, and by morning Claude has forgotten everything you taught it.

Boris fixed all five of these in one stack. And the parts aren't even hidden. They live inside Claude Code itself.

You just have to actually use them.

# Step 1: CLAUDE.md as Living Institutional Memory

This is the first thing you set up. It's also the part most builders treat as optional.

A CLAUDE.md is a Markdown file Claude reads at the start of every session. It tells Claude how your codebase works, what conventions to follow, what mistakes to avoid, and what shortcuts your team uses.

Boris uses three versions.

→ A project-root CLAUDE.md checked into Git. Shared by the whole team. Updated multiple times a week.

→ A user-level ~/.claude/CLAUDE.md for personal preferences across all projects.

→ A CLAUDE.local.md that stays out of Git for personal overrides.

The team-shared one is where the magic happens.

Boris said the line that should be tattooed on every builder's screen.

> "Anytime we see Claude do something incorrectly we add it to the CLAUDE.md, so Claude knows not to do it next time."

That's the whole mental model. Every Claude mistake is a one-time tax. Add the rule. Never pay it again.

The contents are simple. Things like:

→ Always use bun, not npm

→ Prefer type over interface. Never use enum. Use string literal unions instead

→ Numbered dev workflow. Typecheck. Test. Lint. Then PR

→ Never touch the migrations folder without confirming first

At [@ignytlabs](https://x.com/@ignytlabs) our team CLAUDE.md is around 90 lines now. Every line is a scar from a real mistake on a real client project. Every line saves us from making that mistake again.

A quick note on size. Boris keeps his short on purpose. His personal one is about 100 lines or 2,500 tokens. Bloated CLAUDE.md files are a real anti-pattern. The bigger it gets, the more it dilutes the rules that actually matter. Trim ruthlessly.

You can bootstrap one with /init inside Claude Code. It scans your codebase and writes you a starter file. From there you live edit it as you ship.

![Image](https://pbs.twimg.com/media/HKIPpfRaMAA59fA?format=jpg&name=large)

Sample CLAUDE .md showing the kind of rules to add. Real ones grow line by line, every rule earned from a Claude mistake.

## Step 2: Custom Slash Commands for Inner-Loop Work

The next leverage point. Slash commands.

These are reusable workflow recipes stored as Markdown files in .claude/commands/. You invoke them with /commandname and Claude runs the full recipe. Anything you do five times a day belongs in here.

The ones Boris references in the video.

→ /commit-push-pr stages changes, writes a commit message, pushes the branch, opens a PR. Used daily.

→ /techdebt runs at the end of a session. Finds duplication, dead code, and inconsistencies. Cleans them up.

→ Context-sync commands pull the latest state of related files into context before a multi-file change.

You don't write these from scratch. You ask Claude to write them for you. Describe the workflow once. Claude writes the command file. You commit it. Now your whole team has the same shortcut.

This is the part where most builders stall. They keep manually prompting the same five-step sequence every time. Boris turned every one of those sequences into a single slash command that ships in the repo.

At our agency we have around 12 slash commands across our standard MVP starter. The four we use every single day.

→ /plan invokes a plan-only session for the next feature

→ /ship runs the full commit, push, and PR pipeline with our commit conventions

→ /audit runs Claude across the repo looking for unused exports, drift, and obvious bugs

→ /sync pulls the latest design tokens from our design source of truth into the codebase

You do this once. You use it forever.

![Image](https://pbs.twimg.com/media/HKIP68HaEAEvGlk?format=png&name=large)

Sample commands folder. Every workflow you run more than three times a week belongs in here.

## Step 3: Sub-Agents for Separation of Concerns

This is where the workflow stops looking like prompting and starts looking like infrastructure.

A sub-agent is a specialized Claude instance with its own role, prompt, and instructions. It lives as a Markdown file in .claude/agents/. Your main Claude session calls these sub-agents like functions. The sub-agent runs in isolation, finishes its job, hands the result back, and your main context stays clean.

Boris demos several.

→ code-simplifier.md runs on the final diff and removes any cleverness Claude over-engineered

→ verify-app.md runs full end-to-end testing on the feature that just shipped

→ build-validator.md confirms the build passes on every supported environment

→ code-architect.md gets used during plan mode to think through structural decisions before any code gets written

The reason this matters is context bloat. A single Claude session that does the planning, the coding, the testing, the reviewing, and the documenting in one window will eventually hit context limits and start forgetting earlier decisions. Sub-agents are how you scale compute on a hard task without bloating the main session.

You can call them explicitly. "Use 3 parallel sub-agents to brainstorm three different approaches to this auth flow. Compare them. Pick the best."

Or you can chain them. The plan agent hands off to the coder. The coder hands off to the verifier. The verifier hands off to the simplifier. Each agent has one job. Each agent is reusable across every feature.

This is the part of the playbook that feels closest to running a small engineering team. Except every team member ships in parallel and NEVER sleeps.

![Image](https://pbs.twimg.com/media/HKIRmmTbQAAcepC?format=jpg&name=large)

Code-simplifier sub-agent running. Three review agents spawn in parallel and enforce CLAUDE .md rules automatically.

## Step 4: Hooks for Deterministic Post-Actions

Hooks are the boring part of the playbook. They're also the part that quietly saves hours every week.

A hook is a deterministic action that fires on a Claude Code event. You configure them in your project settings. The two events Boris uses most.

→ PostToolUse fires after Claude edits a file. Boris runs bun run format here to catch formatting edge cases before they hit CI.

→ Stop or agent-stop fires when an agent finishes its task. Boris runs verification here. Tests. Type checks. Whatever has to pass before you trust the output.

The difference between a hook and a slash command comes down to who's in charge. Slash commands you invoke. Hooks fire automatically. You set them up once. They run forever.

This is what turns Claude Code from a tool into infrastructure. The model can write any code it wants. Your hooks decide whether that code is allowed to ship.

If you've ever shipped a Claude diff to production and watched CI explode on a missing format pass, hooks fix that problem permanently. They're the cheapest insurance you'll ever buy.

![Image](https://pbs.twimg.com/media/HKITxpvagAAUcxq?format=jpg&name=large)

Sample hooks config. Format on edit. Test and typecheck on stop. Set it up once, it runs forever.

## Step 5: Parallel Sessions With Git Worktrees

This is the biggest single productivity unlock in the whole video. Boris said it's the thing his team gained the most from.

The setup. Open three to five terminal tabs. Each tab is a different git worktree pointed at the same repo but a different branch. Each tab runs its own Claude Code session. Each session is working on a different task at the same time.

One tab on a new feature. One tab on the test suite for the previous feature. One tab refactoring an old module. One tab writing documentation. One tab debugging a production issue.

Boris also mixes in [claude.ai/code](http://claude.ai/code) on the web and the mobile app. You start work on the desktop. You hand off to web. You check progress from mobile. The agent doesn't care which client you're on. The work continues.

Worktrees matter because of conflict isolation. Five Claude sessions writing into the same checkout will collide. Five Claude sessions writing into five worktrees won't. Each agent has its own clean working directory. You merge when you're ready.

This is the moment Claude Code stops feeling like a coding assistant and starts feeling like real-time strategy with your codebase. You orchestrate. Each agent executes. The bottleneck stops being how fast you can prompt and starts being how fast you can plan.

At [@ignytlabs](https://x.com/@ignytlabs) we run an average of 3 parallel sessions per active client project. Feature work in one. Tests in another. Docs in the third. We ship clients faster now. Same quality, same scope, fewer calendar days. The bottleneck moved from prompting to planning.

# Step 6: Plan First. Verify Always. Then Execute.

The last piece of the playbook is the part that doesn't show up in any file. It's a discipline.

Boris hammers it twice in the video.

> "A good plan is really important to avoid issues down the line."

And the one that should be the first thing every builder reads.

> "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result."

Here's the workflow.

→ Start every non-trivial task in plan mode. Hit Shift+Tab twice. Claude switches into a read-only thinking mode. No edits get made. You iterate on the plan until it's solid. Then you switch to auto-accept and Claude one-shots the implementation.

→ Always give Claude a way to check its own work before declaring done. Tests are the obvious one. Browser screenshots for UI work. Simulators for mobile. A type checker for typed code. A linter for style. Any feedback loop is better than no feedback loop.

→ When something goes sideways, re-plan. Don't keep pushing the broken plan harder.

This is the difference between vibe coding and architecting. The prompt is the last step, not the first. 80% of the work happens before you tell Claude to execute. The execution itself is usually one or two prompts.

If you skip this step, you'll spend the whole afternoon fighting with Claude. If you respect it, Claude ships the right thing in one pass and you move on.

![Image](https://pbs.twimg.com/media/HKIWChvbcAA5wzR?format=jpg&name=large)

Claude Code in plan mode. Hit Shift+Tab twice. No code gets written until you approve the plan.

## When This Playbook Won't Work

This isn't the right setup for every team. Be honest about the fit.

Use it when:

→ You're shipping production code with Claude Code more than once a week

→ Your team has more than one engineer using Claude

→ You keep correcting the same Claude mistakes over and over

→ Your codebase has real conventions worth enforcing

→ You're shipping multiple features in parallel

Skip it when:

→ You're vibing on a weekend project and don't care about consistency

→ You're using Claude for one-off scripts that never touch a real repo

→ Your codebase is so small that a CLAUDE.md feels heavier than the code itself

For most builders shipping real products, the playbook is worth setting up once. The investment is about a day. The compounding is permanent.

# What to Watch Out For

Four honest flags before you run this.

CLAUDE.md bloat is real. Boris keeps his short on purpose. A 500-line CLAUDE.md will dilute the rules that actually matter. Trim ruthlessly. Every rule should have earned its spot.

Sub-agents aren't free. Every sub-agent call burns tokens. Plan their use. Don't chain six sub-agents on a task that one well-prompted main session could handle.

Hooks can mask problems. A PostToolUse hook that auto-formats can hide subtle bugs in how Claude is structuring code. Read your diffs. Don't trust the hook to catch everything.

Parallel sessions need a clear head. Five Claude sessions on five worktrees is powerful only if you can keep track of what each one is doing. If you can't, you'll end up merging conflicting work and losing time. Start with two parallel sessions. Add more once you can orchestrate them cleanly.

# What This Actually Means

Here's my honest take.

The builders who win in 2026 aren't the ones with access to a better model. Everyone has access to the best models now. Opus 4.7. Composer 2.5. Gemini 3. Take your pick.

The builders who win are the ones with a real workflow stacked on top of the model. Persistent context. Reusable commands. Specialized sub-agents. Deterministic hooks. Parallel execution. Plan-first discipline.

That's the difference between panic prompting and shipping. The model doesn't change. The system around it does.

The creator of Claude Code told us this a year ago. Most builders didn't listen. The ones who did are now shipping in half the time at twice the quality.

2026 is going to be UNFAIR for builders who set this up early. The gap is already widening. Bookmark the playbook. Set it up this week.

# TLDR

→ The "viral" Boris Cherny video is over a year old. The playbook has been free the entire time. Most builders never watched it.

→ The playbook is compound engineering. Every mistake becomes a rule. Every repeated task becomes a command. Every long task becomes a sub-agent. Every verification becomes a hook.

→ Step 1: Set up a CLAUDE.md. Keep it short. Update it every time Claude makes a mistake.

→ Step 2: Build slash commands for any workflow you run more than three times a week. /ship. /audit. /plan. /sync.

→ Step 3: Build sub-agents for specialized roles. Planner. Coder. Verifier. Simplifier. Reviewer.

→ Step 4: Configure hooks for the post-actions you never want to skip. Format on edit. Tests on stop.

→ Step 5: Run 3 to 5 parallel Claude sessions on git worktrees. Feature. Tests. Docs. Refactor. Debug.

→ Step 6: Always plan before you execute. Always give Claude a way to verify its work. Always re-plan when things go sideways.

→ The model isn't the problem. The workflow is. The fix has been free for a year.

LFG.