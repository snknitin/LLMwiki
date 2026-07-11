---
title: "Using Claude Code While Writing a Research Paper"
author: "Licheng Liu"
username: "@liulicheng10"
date: "2026-03-13"
tweet_url: "https://x.com/liulicheng10/status/2032487597214490969"
tweet_type: "original"
likes: 713
retweets: 76
replies: 8
bookmarks: 1266
views: 63656
has_media: false
extraction_quality: full
article_id: "2032337794388148224"
tags: ["twitter-bookmark", "claude"]
---

# Using Claude Code While Writing a Research Paper

> **Source:** [@liulicheng10](https://x.com/liulicheng10) · 2026-03-13 · 👍 713 · 💬 8 · 🔖 1266 · 👁 63656

> 🔗 [View tweet on X](https://x.com/liulicheng10/status/2032487597214490969)

## Article Content

## Using Claude Code While Writing a Research Paper

We just wrapped up a paper, and Claude Code ended up doing a surprising amount of the grunt work. The big takeaway: it's incredibly good at tasks where the goal is obvious and the workflow is repeatable. But the moment a problem requires you to think about the system as a whole, it hits a wall.

Here's what that looked like in practice.

### Where it crushed it

The tasks Claude Code nailed all had something in common: clear inputs, clear outputs, and mostly execution, not judgment calls.

****Plotting.**** I had it generate three figures for the paper. For one of them (reasoning length trends across eight environments) I literally just said "plot the reasoning length trends for me." It picked a 2×4 subplot layout on its own, added variance bands with smoothed curves, and even annotated each panel with the early-to-late-stage percentage change (e.g., "-40%", "-87%"). I never asked for that. Then I said "make it look better," and it applied Savitzky-Golay smoothing, swapped the color scheme, cleaned up the spines and ticks, and adjusted fonts to look publication-ready. We tried the same task with Codex; the main gap was in aesthetic judgment. Claude Code is weirdly good at inferring what you mean from vague instructions.

https://x.com/liulicheng10/article/2032487597214490969/media/2032470850797228032

Previous version

https://x.com/liulicheng10/article/2032487597214490969/media/2032574937387683840

Edited by CC

****Code migration.**** We had a multi-turn search environment that needed porting from one codebase to our codebase. Completely different architectures: ToolEnvironment on one side, BaseLanguageBasedEnv + gym.Env dual inheritance on the other, plus 128 concurrent instances hitting the retrieval server during training. Doing it by hand would've been a solid half-day to full-day job. Claude Code knocked it out in under an hour. It had everything it needed: clear goal, source code on both ends, and the work was mostly "understand the architecture, then adapt."

****Formatting math proofs.**** This one surprised me, since Claude Code is fundamentally a coding tool. Our appendix has a bunch of mathematical proofs, and the workflow was: write a rough draft, then hand it off for formatting. But it went beyond formatting. In a gradient decomposition derivation for the SNR mechanism, my draft used the Cauchy-Schwarz inequality to bound a quantity but left the bound conditions incomplete. Claude Code caught this and filled in the definition and constraints for the constant C. It was also solid at writing section overviews, usually tighter and more accurate than what I'd write manually. The entire appendix (12+ pages of LaTeX) could be reviewed in one pass with edits throughout.

### The compounding effect

https://x.com/liulicheng10/article/2032487597214490969/media/2032482783613050880

Plotting is the clearest example. The first figure took some back-and-forth to nail the interaction pattern: feed it a csv, give a vague request, let it pick the layout and colors, then iterate on details. Figures two and three followed the same flow and came together fast. Same with proof formatting: the first section took time to calibrate, but the rest were basically free.

This is where Claude Code really pays off. The prompting patterns you develop carry over directly. You're not starting from zero each time.

### Where it can't help

A bug after the search environment went live is a good example of the boundary.

https://x.com/liulicheng10/article/2032487597214490969/media/2032480214371225600

Some context: the search environment was migrated from a large open-source RL framework, which is a pretty large and established codebase. So when things broke, the setup itself was the last thing we'd suspect. On top of that, everything had been running fine on our Slurm cluster. After migrating to [Vast.ai](https://x.com//Vast.ai)

, training started hitting constant timeouts and random crashes. Logs showed the Flask server slowing down, timeouts cascading, but the root cause was nowhere in sight. I asked Claude Code to take a look; it went through the code, configs, and logs, and came up empty. The code hadn't changed at all. What used to work just… didn't.

Turns out the [Vast.ai](https://x.com//Vast.ai)

 machine simply didn't have enough CPU cores for the concurrency load. On Slurm this was never an issue because Slurm silently allocates generous CPU resources when you submit a job, totally invisible to the user.

The hard part about this kind of bug is that you know something's wrong, but the answer isn't in the code or the logs. You have to go check the machine's resource allocation yourself. That's not something a code tool can do for you.

### TL;DR

Plotting, code migration, proof formatting: all went smoothly because the goals were clear and the workflows were reusable. The  debugging didn't, because the problem lived outside the codebase. If you're doing research: find the task types where it fits, build repeatable workflows around them, and don't expect it to debug your infra.

> 📄 Original article URL: https://x.com/i/article/2032337794388148224

