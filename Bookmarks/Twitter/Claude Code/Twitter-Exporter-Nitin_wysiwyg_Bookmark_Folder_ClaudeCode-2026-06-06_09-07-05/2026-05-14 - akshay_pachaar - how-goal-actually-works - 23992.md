---
title: "How /goal Actually Works"
author: "Akshay 🚀"
username: "@akshay_pachaar"
date: "2026-05-14"
tweet_url: "https://x.com/akshay_pachaar/status/2054915602171723992"
tweet_type: "original"
likes: 276
retweets: 48
replies: 9
bookmarks: 502
views: 55876
has_media: false
extraction_quality: full
article_id: "2054806436883070977"
tags: ["twitter-bookmark", "claude", "agents"]
---

# How /goal Actually Works

> **Source:** [@akshay_pachaar](https://x.com/akshay_pachaar) · 2026-05-14 · 👍 276 · 💬 9 · 🔖 502 · 👁 55876

> 🔗 [View tweet on X](https://x.com/akshay_pachaar/status/2054915602171723992)

## Article Content

/goal is the most time-saving feature in all of AI right now. Let's break down how it works and the best way to use it.

You know the drill.

You give Claude Code a task, it does one turn of work, then stops and waits for you to say "keep going." You nudge it forward. It does another turn. Stops again. For small tasks, this is fine. For a 200-file refactor or a full feature implementation? It's exhausting.

The /goal command recently released by Claude fixes this entirely.

You set a completion condition. Claude works autonomously, turn after turn, until that condition is met. No babysitting. No "continue" prompts. You can literally walk away from the terminal and come back when it's done.

Here's how it works, how to use it well, and where it breaks down.

## How /goal Actually Works

The mechanic is surprisingly simple:

1. You type /goal followed by a clear completion condition.
2. Claude takes a full turn (reasons, plans, edits files, runs tests, etc.).
3. A fast evaluator model (Claude Haiku by default) reads the conversation transcript and answers one question: "Is the goal condition met yet?"
4. If ****no****, Claude immediately starts another turn.
5. If ****yes****, the goal auto-clears, and control returns to you.

That's it. A loop with a model-verified exit condition.

https://x.com/akshay_pachaar/article/2054915602171723992/media/2054911177088811008

How /goal works

### What Good Goals Look Like

This is where 80% of your success (or failure) lives. The goal condition needs to be ****specific, measurable, and verifiable from the transcript****.

****Goals that work well:****

plaintext

```
/goal all tests in test/auth pass and the lint step is clean
```

plaintext

```
/goal CHANGELOG.md has an entry for every PR merged this week
```

plaintext

```
/goal every call site of the old API has been migrated and the build succeeds
```

Notice the pattern: each one describes an observable end state. Claude can run the tests, show the output, and the evaluator can confirm "yes, all tests passed."

https://x.com/akshay_pachaar/article/2054915602171723992/media/2054912238574837760

Good Goals vs Bad Goals

Vague goals lead to two failure modes: Claude loops forever trying to satisfy an unclear condition, or the evaluator halluccinates success because there's nothing concrete to check against. Both burn tokens for nothing.

****The mental model that helps:****

> Treat /goal like a ticket you're assigning to a very literal junior developer who never gets tired. Write the exact acceptance criteria you'd put in that ticket.Setting Up Your Project for /goal Success

## Setting Up Your Project for /goal Success

The goal command works best when Claude already understands your project. Three things make a massive difference:

- ****CLAUDE.md at your project root.**** Define architecture decisions, coding conventions, and your "Definition of Done." Claude reads this automatically during every turn.
- ****Hooks for auto-validation.**** Auto-run lint or type-checking after every file edit so Claude catches issues mid-run.
- ****Auto Mode enabled.**** Reduces permission prompts for tool use. Without it, a 30-turn run stalls waiting for you to approve every file write.

Workflow Patterns Worth Trying

https://x.com/akshay_pachaar/article/2054915602171723992/media/2054912627990765569

> Combine /goal with Agent View (the dashboard for multiple Claude Code sessions) and you're managing a team of autonomous agents across different parts of your codebase.

## Where It Falls Short

- ****Token burn on vague goals.**** Loose conditions mean Claude spins on turns that don't make progress.
- ****The evaluator only sees the transcript.**** If Claude doesn't explicitly print a test result or file diff, the evaluator can't verify it.
- ****Complex multi-step objectives overwhelm it.**** "Redesign auth, add OAuth, write tests, update docs, deploy" is too much for one goal. Break it into sequential goals.
- ****No built-in token budget.**** Claude keeps going until done or interrupted (Ctrl+C). Community plugins add token caps and adversarial review for longer runs.

## /goal vs. /loop vs. Stop Hooks

- ****/goal**** stops when a condition is model-verified met. Best for outcome-based work.
- ****/loop**** repeats on a schedule. Better for polling or periodic tasks.
- ****Stop hooks**** give you custom evaluation logic after every turn. More flexible, more setup.

For any coding task with a defined end state, /goal is the right pick.

## Try It Now

If you're not sure how to phrase your goal, let Claude write it for you. Paste something like this into Claude Code before running /goal:

> Write me a /goal prompt. Ask me what I'm trying to do first, then keep asking follow-up questions until you can describe 'done' in specific, measurable terms.

Take what it gives you, put /goal at the front, and run it. Then close the terminal and go do something else.

Start with something well-scoped before graduating to larger runs. The more precise your condition, the more reliable the result.

The feature doesn't solve every problem. But for any task where you can write a clear finish line, it removes the biggest friction in AI-assisted coding: you, sitting there, pressing enter over and over.

That's it for today.

Cheers! :)

> 📄 Original article URL: https://x.com/i/article/2054806436883070977

