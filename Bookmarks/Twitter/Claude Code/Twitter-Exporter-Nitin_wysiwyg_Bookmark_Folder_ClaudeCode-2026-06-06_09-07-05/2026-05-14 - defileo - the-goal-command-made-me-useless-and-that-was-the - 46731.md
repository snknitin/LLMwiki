---
title: "The /goal Command made me useless and that was the point."
author: "Defileo🔮"
username: "@defileo"
date: "2026-05-14"
tweet_url: "https://x.com/defileo/status/2055035402294046731"
tweet_type: "original"
likes: 145
retweets: 17
replies: 13
bookmarks: 342
views: 160487
has_media: false
extraction_quality: full
article_id: "2055017221940727808"
tags: ["twitter-bookmark", "claude"]
---

# The /goal Command made me useless and that was the point.

> **Source:** [@defileo](https://x.com/defileo) · 2026-05-14 · 👍 145 · 💬 13 · 🔖 342 · 👁 160487

> 🔗 [View tweet on X](https://x.com/defileo/status/2055035402294046731)

## Article Content

## The /goal Command made me useless and that was the point.

For two years I have been the bottleneck in every Claude Code session.

Type a prompt, wait for the output, review it, type the next prompt, wait, review, repeat. Hundreds of these tiny approvals per project. The model does the work, I keep the rhythm. Without me sitting there pressing keys, nothing moves.

https://x.com/defileo/article/2055035402294046731/media/2055024248222052352

[https://code.claude.com/docs/en/goal](https://code.claude.com/docs/en/goal)

Last week that stopped. I typed one command, walked to the kitchen, made coffee, came back, and the work was done.

The command is ****/goal  ****it is the first feature that genuinely removes the human from the loop, and it changes how I use Claude Code more than any model upgrade has.

Most people are about to use it wrong this week. Here is the version that actually works.

### What /goal actually does

Normal Claude Code is a conversation. You ask, it acts, you respond, it acts again. Every turn is a check-in disguised as work.

/goal flips that. You define what done looks like, Claude runs in a closed loop, and the model itself decides when the work is finished. It writes, it tests, it hits errors, it fixes them, it checks its own output against your criteria, and it either keeps going or stops because the goal is met.

You are not in the loop anymore. You set the loop running and went somewhere else.

That sounds small. It is not. Every productivity tool you have ever used was designed around your attention. /goal is the first one designed around your absence.

### The formula that actually works

Every /goal prompt should answer three questions.

What needs to be done. How will we know it is done. What is off limits.

The skeleton:

```
/goal [task] until [measurable completion condition] without [hard constraints]
```

Weak prompt:

```
/goal improve the app performance
```

There is no finish line. Claude will tweak a few things, decide it improved, and stop. You will not know if anything changed.

Strong prompt:

```
/goal optimize image loading across all product pages until 
Google PageSpeed scores 85+ on mobile, without changing any 
HTML structure or removing existing images
```

Now Claude has a target (PageSpeed 85+), a scope (product pages only), and clear limits (don't touch the HTML or images). It can run, test against PageSpeed, fix what is not working, and self-verify until that target is hit.

The pattern repeats for any task. The clearer the finish line, the more reliably the loop terminates with real work done.

![](https://pbs.twimg.com/amplify_video_thumb/2055033125818834945/img/QIbFGHmaIqm1R9UP.jpg)

### The acceptance criteria problem

Here is the part most articles will skip this week.

/goal works because Claude grades its own work. That is the entire mechanism. A small evaluator checks each output against the criteria you set, decides if the goal is met, and either stops or keeps going.

The trap is obvious once you see it. If your criteria are weak, Claude declares victory on weak work.

"Improve performance" is graded against Claude's own definition of improvement. "Add tests" passes the moment any test exists. "Make it more user-friendly" is impossible to grade and the model will hand you something and call it done.

The criteria need to be the kind of thing a stranger could verify in 30 seconds without reading the code. PageSpeed scores. Test pass counts. Specific error states that no longer appear. Specific user flows that complete end to end.

If the success condition cannot be measured, the loop cannot close. If the loop cannot close, you are right back to being the bottleneck.

Write criteria the way you would write a bug report for a junior engineer. Concrete, observable, falsifiable.

### The Structure for Bigger Goals

For tasks that take more than a few minutes, the one-liner is not enough. Use this structure:

```
/goal [what needs to be achieved]

context:
[anything Claude needs to understand about your project, stack, 
or constraints that is not obvious from the codebase]

done when:
- [measurable condition]
- [measurable condition]  
- [measurable condition]

do not:
- [hard limit]
- [hard limit]

progress tracking:
log completed steps to progress.md as you ```go

The progress tracking line is the one most people skip and it matters more than they realize. Long runs drift.

The model spends context on its own outputs, forgets earlier decisions, contradicts itself.

A progress file gives Claude an external memory and gives you a way to check the run without interrupting it.

For multi-hour goals, also add plan.md and decisions.md. The plan file is the approach Claude commits to upfront.

The decisions file is why specific choices were made. Together they keep long autonomous runs coherent and give you a paper trail when you come back.

### Three use cases beyond coding

Both the articles I have seen on /goal this week focus on coding. That is half the value at most.

****Research and analysis:****

```
/goal find every credible source published in the last 90 days 
on [topic] until I have a structured summary with at least 20 
distinct sources, citing each one with author and date, without 
including any source from a site flagged as low credibility
```

Claude runs the research loop, validates sources, builds the summary, checks it against the count and quality conditions, hands you a finished document.

****Content production:****

```
/goal write a 1500-word article on [topic] until it passes three 
internal review passes (clarity, originality, voice match against 
the reference samples in /writing-samples) without using any of 
the banned phrases in style-guide.md
```

Claude drafts, self-reviews, rewrites, self-reviews again, until the piece passes its own quality bar.

****Ops and maintenance:****

```
/goal audit every dependency in package.json until I have a report 
showing version, last update date, known vulnerabilities, and a 
recommendation to keep, update, or replace each one, without 
actually changing any dependency yet
```

A task that used to take half a day, now runs while you do something else.

The pattern is the same in every domain. Define the deliverable, define the bar, define the limits, walk away.

### Running multiple goals at once

The unlock most people will not figure out for another month.

A single /goal running on one project is useful. Three /goals running on three projects in parallel while you sleep is a different category of leverage.

You open three terminal windows. Each one is a different project. Each one gets a different /goal. You go to bed. You wake up to three completed tasks.

This works because each loop is independent. There is no shared context, no cross-project interference. The operator running this setup is not three times faster than the prompt-by-prompt user. They are running three parallel streams that the prompt-by-prompt user physically cannot match.

The constraint is not Claude. The constraint is how clearly you can write three different acceptance criteria the night before.

### What /goal cannot do yet

The honest section nobody is writing.

/goal struggles with anything that requires real-time external verification. Tasks that need a human to look at a UI and react.

Tasks where success is aesthetic rather than measurable. Tasks that depend on services Claude cannot test against.

It also struggles with goals that have hidden dependencies. If finishing the task requires data you have not given Claude access to, the loop will spin until it gives up or hallucinates a solution.

The honest answer is to give Claude the access upfront or pick a different tool.

And it will not save you from a bad plan. A clearly defined goal pointed at the wrong objective just gets you to the wrong place faster. The autonomy amplifies whatever direction you set.

The rule: anything that has a measurable finish line and lives inside the environment Claude can touch is fair game. Anything else, stay in the loop.

### Fast setup:

Install if you do not have it:

```
npm install -g @anthropic-ai/claude-code
```

Launch Claude Code, then set a goal:

```
/goal [your task]
```

For longer runs where you do not want approval prompts:

```
claude --approval-mode full-auto
```

Useful commands:

```
/pause          pause the current goal
/goal clear     cancel and reset
/plan           generate a step-by-step plan before execution
```

That is the entire setup, less than two minutes.

### The real shift:

For two years the productive use of AI has been "how fast can I prompt." Speed of typing, quality of prompts, how many tabs you could juggle at once. The bottleneck was always you.

/goal moves the work out of your hands. You are no longer the operator. You are the person who briefs the operator and walks away.

That is a different role. Slower at the front, faster at the back. Less typing, more thinking. Worse for people who measure productivity by how busy they feel. Dramatically better for everyone else.

Spend two extra minutes writing the goal. Add the measurable finish line. Add the constraints. Then close the laptop and let the loop finish.

Welcome to being useless, it is the most productive thing you have done all year.

> 📄 Original article URL: https://x.com/i/article/2055017221940727808

