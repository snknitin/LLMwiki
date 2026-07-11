---
title: "Andrej Karpathy wrote something that every Claude Code user has felt but couldn't articulate."
author: "Tech with Mak"
username: "@techNmak"
date: "2026-05-16"
tweet_url: "https://x.com/techNmak/status/2055712886790701226"
tweet_type: "original"
likes: 998
retweets: 78
replies: 25
bookmarks: 2195
views: 89109
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "claude"]
---

# Andrej Karpathy wrote something that every Claude Code user has felt but couldn't articulate.

> **Source:** [@techNmak](https://x.com/techNmak) · 2026-05-16 · 👍 998 · 💬 25 · 🔖 2195 · 👁 89109

> 🔗 [View tweet on X](https://x.com/techNmak/status/2055712886790701226)

## Tweet Content

Andrej Karpathy wrote something that every Claude Code user has felt but couldn't articulate.

Three quotes. Read them slowly.

"The models make wrong assumptions on your behalf and just run along with them without checking. They don't manage their confusion, don't seek clarifications, don't surface inconsistencies, don't present tradeoffs, don't push back when they should."

"They really like to overcomplicate code and APIs, bloat abstractions, don't clean up dead code... implement a bloated construction over 1000 lines when 100 would do."

"They still sometimes change/remove comments and code they don't sufficiently understand as side effects, even if orthogonal to the task."

You've seen all three. Probably this week.

Someone turned these three observations into a single CLAUDE[.]md file. Four principles, one install, directly addresses each quote:

1./ Think before coding
Don't assume. Don't hide confusion. State ambiguity explicitly. Present multiple interpretations rather than silently picking one. Push back if a simpler approach exists. Stop and ask rather than guess.

2./ Simplicity first
No features beyond what was asked. No abstractions for single-use code. No "flexibility" that wasn't requested. No error handling for impossible scenarios. The test: would a senior engineer say this is overcomplicated? If yes, rewrite it.

3./ Surgical changes
Don't "improve" adjacent code. Don't refactor things that aren't broken. Match the existing style even if you'd do it differently. If you notice unrelated dead code, mention it, don't delete it. Every changed line should trace directly to the request.

4./ Goal-driven execution
Transform "fix the bug" into "write a test that reproduces it, then make it pass." Transform "add validation" into "write tests for invalid inputs, then make them pass." Give it success criteria and watch it loop until done.

This last one is Karpathy's key insight captured directly: "LLMs are exceptionally good at looping until they meet specific goals... Don't tell it what to do, give it success criteria and watch it go."

It's a single file. Drop it into any project.

## Media

![](https://pbs.twimg.com/media/HIdb4cMaEAAyOW0.jpg)

