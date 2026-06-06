---
title: "Most people think Claude is something you talk to, tho it is now something you deploy."
author: "Defileo🔮"
username: "@defileo"
date: "2026-04-18"
tweet_url: "https://x.com/defileo/status/2045466421036007527"
tweet_type: "original"
likes: 918
retweets: 85
replies: 14
bookmarks: 4290
views: 4995031
has_media: false
extraction_quality: full
article_id: "2045262387041730560"
tags: ["twitter-bookmark", "claude", "mcp"]
---

# Most people think Claude is something you talk to, tho it is now something you deploy.

> **Source:** [@defileo](https://x.com/defileo) · 2026-04-18 · 👍 918 · 💬 14 · 🔖 4290 · 👁 4995031

> 🔗 [View tweet on X](https://x.com/defileo/status/2045466421036007527)

## Article Content

Most people think Claude is something you talk to, tho it is now something you deploy.

Anthropic quietly shipped something that changes how you think about AI entirely, it is called Routines.  

And if you build things, run a team, or manage any kind of recurring work, this is the most important thing Claude has shipped this year.

![](https://pbs.twimg.com/amplify_video_thumb/2045453498024648704/img/UF7p1Xjkqr_yV_Or.jpg)

[https://code.claude.com/docs/en/routines#example-use-cases](https://code.claude.com/docs/en/routines#example-use-cases)

Here is what it does:

You define a task once, a prompt, a repo, a trigger, claude runs it automatically on Anthropic's cloud infrastructure.

Your laptop can be closed -> Claude is still working, not a chatbot, not a copilot a deployed worker.

### The three triggers

Every routine needs a trigger, there are three types, you can combine them on the same routine.

****>**** ****Schedule****

Runs on a recurring cadence. Hourly, daily, weekdays, weekly, or a custom cron expression.

You set the time in your local timezone and Claude converts it automatically.

Use this for anything that needs to happen on a clock. Daily standups. Weekly doc reviews. Nightly backlog maintenance. Morning digests.

****>**** ****API****

Gives your routine a dedicated HTTP endpoint. You POST to it with a bearer token and Claude starts a run immediately. You can pass extra context in the request body using a text field.

Use this to wire Claude into anything that can make an HTTP request. Alerting tools. Deploy pipelines. Internal dashboards. Anywhere you want Claude to react to something your system detected.

****>**** ****GitHub****

Runs automatically when something happens in a repository. Pull request opened. 

Commit pushed. Issue created. Workflow completed. You pick the event and optionally add filters so it only triggers on exactly what you care about.

Use this for code review, PR triage, changelog generation, or anything that should happen every time code moves.

### Five routines you can set up today

These are real use cases from the docs, each one has the trigger type, the prompt structure, and what Claude actually does.

### Routine 1: Morning backlog digest

Trigger: schedule, every weekday at 7am

Prompt structure:

```
Read all issues opened in the last 24 hours. 
Apply labels based on the area of code referenced. 
Assign owners based on who owns that area. 
Post a summary to #dev-standup in Slack with 
the new issues, their labels, and assigned owners. 
Keep it under 10 lines.
```

What happens: you wake up, open Slack, and your backlog is already groomed.

Nobody had to touch it. No Monday morning surprise of 30 unlabeled tickets from the weekend.

### Routine 2: Auto PR reviewer

Trigger: GitHub, pull_request.opened

Prompt structure:

```
Review this pull request against our team checklist.
Check for: security issues, performance problems, 
style violations, and missing tests.
Leave inline comments for specific issues.
Post a summary comment with a pass or flag verdict
so human reviewers can focus on design decisions,
not mechanical checks.
```

What happens: every new PR gets reviewed before a human looks at it.

The mechanical stuff is already caught, your team spends review time on architecture and logic, not missing semicolons.

You can add filters too, only trigger on PRs targeting main, only trigger on non-draft PRs. 

Only trigger on PRs from forks. You control exactly what fires the routine.

### Routine 3: Alert Triage Bot

Trigger: API (called by your monitoring tool)

Prompt structure:

```
An alert has fired in production. 
The alert details are in the context below.
Pull the relevant stack trace.
Correlate with commits from the last 48 hours.
Open a draft pull request with a proposed fix.
Link the PR back to the alert.
Post the PR link to #on-call in Slack.
```

Call it like this:

Your monitoring tool sends a POST request to the routine's endpoint with your bearer token in the header and the alert details in the body.

Claude picks up the context from that text and starts working immediately.

What happens: your monitoring tool fires an alert at 3am -> Claude wakes up, finds the relevant commits, opens a draft PR with a proposed fix, and posts it to Slack.

Your on-call engineer reviews a PR instead of staring at a blank terminal at 3am.

### Routine 4: Docs Drift Checker

Trigger: schedule, every Monday at 9am

Prompt structure:

```
Scan all PRs merged in the last 7 days.
Find documentation that references APIs or functions 
that were changed in those PRs.
For each outdated doc, open an update PR in the 
docs repository with the correct information.
Add a comment linking the code PR that caused the drift.
```

What happens: documentation stays current automatically. 

The most hated maintenance task on any engineering team runs itself every week without anyone asking for it.

### Routine 5: Deploy Verification

Trigger: API (called by your CD pipeline after deploy)

Prompt structure:

```
A new build was just deployed to production.
Run smoke checks against the new build.
Scan error logs for regressions compared to the 
previous deploy.
Post a go or no-go verdict to #releases in Slack 
before the deploy window closes.
If no-go, include the specific errors found.
```

What happens: every deploy gets verified automatically. Your team gets a go or no-go in Slack before anyone has to manually check anything.

The deploy window does not close with everyone hoping nothing broke.

### How to Set Up Your First Routine

Ten minutes, here is the exact path, from the web:

https://x.com/defileo/article/2045466421036007527/media/2045451870647279616

Go to [claude.ai/code/routines](https://x.com//claude.ai/code/routines)

 & click new routine

Give it a name, write the prompt, the prompt is the most important part. 

Claude runs autonomously so it needs to be specific, not "review PRs" but "review PRs targeting main, check for missing error handling and security issues, leave inline comments, post a summary verdict."

Select your GitHub repository, claude clones it at the start of every run starting from the default branch.

Pick an environment. The default one works for most cases. Custom environments let you set API keys, install dependencies, or control network access.

Choose your trigger: Schedule, API, or GitHub event, add filters if needed.

Review your connectors. All your connected MCP connectors are included by default. Remove any the routine does not need, click create.

****From the CLI:****

Run /schedule in any Claude Code session, claude walks you through everything conversationally and saves the routine to your account.

```
/schedule daily PR review at 9am
```

That is it, claude asks the right questions, you answer, and the routine is live.

To manage existing routines from the CLI:

```
/schedule list
/schedule update
/schedule run
```

### What You Need to Know About Limits:

https://x.com/defileo/article/2045466421036007527/media/2045455466763894784

[https://claude.ai/settings/usage](https://claude.ai/settings/usage)

> Routines use your subscription quota like interactive sessions.

> There’s a daily cap on routine runs per account, check usage at /routines or settings/usage.

> If you hit the cap: with extra usage, runs continue as metered overage, without it, new runs are rejected until reset.

> By default, Claude can only push to claude/* branches to avoid protected branches, to push anywhere, enable Allow unrestricted branch pushes when creating the routine.

> Routines are per-user, not shared. All actions via your GitHub identity (commits, PRs, Slack, Linear) show up as you.

> During the research preview, GitHub triggers also have per-routine and per-account hourly caps; extra events are dropped until reset.

### Psst... For those who are interested in deep AI learning:

****If you're interested in learning more about AI here's how you go from zero to building real things with it.****

![](https://pbs.twimg.com/amplify_video_thumb/2045458306848690176/img/KLPljxt2aYaEtnuq.jpg)

Leaving a link for y'all: [https://tally.so/r/2ExKYV](https://tally.so/r/2ExKYV)

****You do not need a tech background to build AI tools that make money. 

AI Launchpad takes you from zero to building chatbots, automations, and custom AI assistants for real businesses.****

****-**** Leo

> 📄 Original article URL: https://x.com/i/article/2045262387041730560

