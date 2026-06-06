---
title: "Learning this single slash command will completely change how you use AI."
author: "AI Edge"
username: "@aiedge_"
date: "2026-05-13"
tweet_url: "https://x.com/aiedge_/status/2054569766418108797"
tweet_type: "original"
likes: 980
retweets: 111
replies: 18
bookmarks: 3191
views: 875464
has_media: false
extraction_quality: full
article_id: "2054279489774120960"
tags: ["twitter-bookmark", "claude", "agents"]
---

# Learning this single slash command will completely change how you use AI.

> **Source:** [@aiedge_](https://x.com/aiedge_) · 2026-05-13 · 👍 980 · 💬 18 · 🔖 3191 · 👁 875464

> 🔗 [View tweet on X](https://x.com/aiedge_/status/2054569766418108797)

## Article Content

Learning this single slash command will completely change how you use AI.

Anthropic, OpenAI, and other major AI players are all shipping the same feature right now.

That's not a coincidence; the /goal command is fundamentally changing how we interact with AI agents in real time.

By learning this command, you're essentially activating a 24/7 AI agent that can work on your behalf with zero manual intervention.

It's genuinely one of the most powerful AI features that's shipped recently.

In this guide, I'll teach you exactly what /goal is, how it works, how to optimize it, & show you some real-world examples to get you started.

By the time you're done reading, you'll have a 24/7 mini AI employee that completes any task for you autonomously.

****Note:**** I'll focus on using /goals in Codex as the primary tool for this article, but many of the principles discussed can be applied to other AI tools, such as Claude Code.

### What even is /goal?

****In one line: ****/goal allows AI agents to work in a "loop" to complete tasks without needing permission (like the Ralph loop that went viral months ago).

****Example: ****You tell Claude Code "/goal create a landing page," and it completes the entire task on your behalf. The research, coding, debugging & so on, and then it returns a final product to you.

It's like telling an employee to complete a task and only return when it's done.

Without /goal, we are the "bottleneck," as we have to approve, send prompts, tell the agent to continue, and that loop repeats.

https://x.com/aiedge_/article/2054569766418108797/media/2054290454590767104

Without /goal

With the introduction of /goal, Claude validates everything on its own and "closes" the loop.

https://x.com/aiedge_/article/2054569766418108797/media/2054290606978187264

With /goal

This works because a fast, small model validates whether the conditions are met to proceed to the next step.

### How to use /goals

Using /goals is extremely simple.

You just type: /goal [your task/goal] inside your AI tool of choice (CLI/desktop), and it actively works towards the new goal you set.

https://x.com/aiedge_/article/2054569766418108797/media/2054298712667770881

/goal at its core

Once you set your goal, you'll receive confirmation that it was set, and in this case, Codex will begin working toward completion.

This works in the Claude Code CLI, Codex CLI, Hermes agent, and now even in the Codex app (as shown above).

I recommend most non-technical people start with /goal inside the Codex desktop, but if you're setting it up in Codex CLI, follow these steps:

1. ****Enable goals****

Codex desktop → Settings → Configuration and ensure goals = true

2.    ****Open Terminal & ****launch Codex in full-auto mode if you want fewer approval prompts

```
codex --approval-mode full-auto
```

3.     Start prompting

```
/goal [insert goal]
```

If you're using Claude Code, just make sure to launch Claude Code CLI and start prompting for the /goal you want to set (the steps are similar to Codex):

[https://code.claude.com/docs/en/goal](https://code.claude.com/docs/en/goal)

https://x.com/aiedge_/article/2054569766418108797/media/2054313725084237824

Setting goals in Claude Code CLI (very similar to Codex)

****Keep in mind: i****f you run into issues during setup, you can ask Codex/Claude Code for help.

****Building effective /goal prompts****

The difficult part isn't writing the syntax - it's writing good prompts so that your AI tools actually come back to you with the result you want.

At the bare bones, your /goal prompts should have three things:

1. ****Your goal: ****your task/goal in one line
2. ****Measurable end state: ****define what done actually looks like
3. ****Constraints: ****rules and constraints the model must abide by

Putting these three things together, your /goal prompts should look like this:

/goal [do the work] until [measurable end state] without [constraints that must hold]

****Real example:****

"/goal fix every failing test until npm test exits 0 without modifying any file outside the /auth directory."

Of course, you can make your prompts much more detailed by adding context, success criteria, and other details.

For complex projects, I recommend following this advanced /goal prompting structure (save this):

https://x.com/aiedge_/article/2054569766418108797/media/2054294074589659136

/goal prompting for advanced projects

At its core, this is how you use /goal, and it's relatively simple!

### /goal examples + prompting examples

You can use /goal for a variety of tasks (not just coding).

This section should give you some good ideas for what you can use /goal for - specifically in Codex.

1. ****Research****

"/goal research everything recent about the new /goal command"

![](https://pbs.twimg.com/amplify_video_thumb/2054303883082731520/img/cFYp610Yl5EW8BqB.jpg)

/goal for research

2.     ****Visuals ****

"/goal create a cool visual for everything related to the new /goal command."

https://x.com/aiedge_/article/2054569766418108797/media/2054305188291436544

Visuals

3.     ****Local Files ****

Some cool prompts I experimented with for accessing local files/folders:

"/goal Improve the README so a new contributor can install, run, test, and understand the project."

"/goal Find dead code, unused dependencies, and stale files, then propose what can be safely removed."

"/goal Turn the current notes and markdown files into a clean one-page summary document."

4.     ****Coding****

"/goal Add a dark/light theme toggle to this project, persist the choice in localStorage, update the UI styles to support both themes, and verify it works in the browser."

"/goal Add a command palette that can search pages/actions and open with Cmd+K."

Essentially, any project or task you have can now be handed to Codex/Claude Code/Hermes for autonomous completion.

### Pro Tips

A section on /goal pro tips:

- Only one /goal can be set at a time - use it wisely
- In Claude Code, you can see how many tokens the goal is actively taking up, and the progress bar of the task
- /goal shines on long-running work. For a small one-off, a normal prompt is enough.
- Pair it with /plan. A nice workflow is /goal → /plan → /goal clear
- Utilize /pause to pause goals, and /goal clear to reset your goals
- Don't be afraid to use /goal for unconventional use cases - you'd do yourself a disservice by only using /goal for coding/technical work
- You can get the model to set its own /goal (it will likely write better prompts than you anyway)
- Provide a "checklist" in your prompts
- Give your agent .md files for tracking

This is a good article to read on optimizing /goal inside Codex for those interested:

https://x.com/ChrisHayduk

****Chris Hayduk****

@ChrisHayduk

·

[May 11](https://x.com/ChrisHayduk/status/2053807198870880743)

** Article**

**Using Codex Goals Effectively**

Perceptive Codex users have noticed that the /goal command is now available in the Codex app - just start your prompt with /goal, and specify what you want your agent to do.
This will trigger Codex to...

### Closing

I hope you found this /goals quickstart guide valuable.

If you did, be sure to follow me [@aiedge_](https://x.com/@aiedge_)

 - I post AI articles just like this 2-3x/week!

If you enjoy written AI content, feel free to subscribe to my free weekly newsletter.

[https://www.aiedgehq.co/](https://www.aiedgehq.co/)

https://x.com/aiedge_/article/2054569766418108797/media/2054310038995615744

[https://www.aiedgehq.co/](https://www.aiedgehq.co/)

100% free, no spam ever & unsub anytime

Lastly, if you can, please Like/Repost this article so others can find it.💙

> 📄 Original article URL: https://x.com/i/article/2054279489774120960

---

## Commentary from Other Bookmarks

### @milesdeutscher (Miles Deutscher) — 2026-05-13

> /goal is f*cking insane.
> 
> You can literally turn your AI agents into 24/7 employees that work for HOURS with zero manual intervention.
> 
> This has to be the most powerful AI feature release of the month.
> 
> If you try one thing in AI this week, make it this.

[→ View quote tweet](https://x.com/milesdeutscher/status/2054617939123605898)

![](https://pbs.twimg.com/media/HIN4IKma0AAi5tz.jpg)

