---
title: "Everyone is talking about AI agents. 'Deploy an agent.' 'Multi-agent systems.' 'Agentic workflows.'"
author: "0xMorty"
username: "@0xMortyx"
date: "2026-05-31"
tweet_url: "https://x.com/0xMortyx/status/2061106244610408566"
tweet_type: "original"
likes: 279
retweets: 43
replies: 3
bookmarks: 1063
views: 585172
has_media: false
extraction_quality: full
article_id: "2061083387498991617"
tags: ["twitter-bookmark", "claude", "mcp", "agents"]
---

# Everyone is talking about AI agents. "Deploy an agent." "Multi-agent systems." "Agentic workflows."

> **Source:** [@0xMortyx](https://x.com/0xMortyx) · 2026-05-31 · 👍 279 · 💬 3 · 🔖 1063 · 👁 585172

> 🔗 [View tweet on X](https://x.com/0xMortyx/status/2061106244610408566)

## Article Content

Everyone is talking about AI agents. "Deploy an agent." "Multi-agent systems." "Agentic workflows."

Most people hear this and assume it's for developers. It isn't. ****You don't need to write a single line of code to build a useful AI agent in Claude.**** You need three things: a clear goal, the right tools turned on, and a system prompt that tells Claude how to behave.

This is the full build. Start to finish. 30 minutes.

> ****What you'll have by the end:****A working Claude agent with a specific job, persistent memory, web search access, and a behaviour ruleset - running in a Claude Project you can use every day.

### First: What's the Difference Between Claude and an Agent?

https://x.com/0xMortyx/article/2061106244610408566/media/2061083845206679555

The key shift: a regular chat is a question-answer machine. An agent is a ****role with instructions****. Same Claude underneath - different setup on top.

https://x.com/0xMortyx/article/2061106244610408566/media/2061085481689837568

### Step 0 - Choose What Your Agent Actually Does

Before touching anything in Claude, answer this: ****what is the one repeatable job you want this agent to own?****

The most common beginner mistake is building a "general assistant." That's not an agent - that's just Claude chat with extra steps. Pick one specific job.

https://x.com/0xMortyx/article/2061106244610408566/media/2061085731712331778

> ****For this tutorial ****we'll build a ****Research Agent -**** it's the most universally useful and shows every concept clearly. Swap the goal and system prompt for any of the others above.

### The Build: 5 Steps, 30 Minutes

1. ****Create a Claude Project - 2 min
****Go to [claude.ai](https://x.com//claude.ai)

 → click "Projects" in the left sidebar → "New Project". Name it something specific: "Research Agent - AI & Tech". Not "My Agent". Specific names keep you honest about what the agent is for.
2. ****Turn On the Right Tools - 5 min
****Inside the project settings, enable Web Search. This is what separates a static assistant from an agent that can actually go get current information. If you have documents you want it to reference, upload them here too.
3. ****Write the System Prompt - 10 min
****This is the most important step. The system prompt is your agent's operating manual. It defines the role, the behaviour, the format, and the rules. Copy the template below - it works out of the box.
4. ****Upload Your Context File - 8 min****
Create a simple .txt file with everything the agent needs to know about you: your focus areas, what matters, what doesn't, your preferred format. Upload it to the project. This is the agent's persistent memory.
5. ****Test and Calibrate - 5 min
****Run 3 test prompts. Check: does it stay in role? Does it use web search when it should? Does the output match the format you want? Adjust the system prompt until it does. One iteration usually fixes 90% of issues.

### The System Prompt (Copy This Exactly)

This is the complete system prompt for a Research Agent. Paste it into your Project's custom instructions field. Replace the brackets with your specifics.

```python
RESEARCH AGENT — SYSTEM PROMPT
You are a research agent for [your name].
Your job: surface what matters in [your topics] and filter everything else.

YOUR ROLE:
- You are not a general assistant. You are a focused researcher.
- You search the web when asked, or when current information improves your answer.
- You have access to context files about [your name]'s focus areas. Use them.

HOW YOU WORK:
When given a research request:
1. Identify the core question behind the request
2. Search for current, relevant information (use web search)
3. Filter ruthlessly — only include what's actually useful
4. Synthesise into a structured output, not a data dump

OUTPUT FORMAT (always use this structure):
## Summary (2 sentences max)
## Key Findings (3–5 bullets, each with a source)
## What This Means (1 paragraph — your analysis)
## Worth Watching (1–2 things to follow up on)

RULES:
- Never pad output with filler. If you don't have 5 key findings, give 3.
- Always flag when information is older than 6 months.
- If you can't find good sources, say so — don't hallucinate.
- Do not start responses with "Certainly!" or "Great question!"
- End every response with: "Confidence level: [High / Medium / Low] — [one sentence why]"
```

### The Context File (Your Agent's Memory)

Claude Projects don't have automatic memory - but they have something better: ****uploaded files that persist across every conversation****. Your context file is how your agent knows who you are.

```python
CONTEXT.TXT — TEMPLATE (save as a .txt and upload to your project)
ABOUT ME
Name: [your name]
Role: [what you do]
Working on: [current projects or goals]

MY FOCUS AREAS
Primary: [e.g. AI tools, crypto, SaaS]
Secondary: [e.g. productivity, content creation]
Ignore: [e.g. politics, sports, celebrity news]

MY STANDARDS
- I prefer original sources over summaries
- I want contrarian takes, not consensus
- Flag things I might have missed
- Don't waste my time with obvious points

ONGOING CONTEXT
[Add anything specific to your current situation —
e.g. "I'm building a Twitter audience about AI tools"
or "I'm evaluating tools for automating my newsletter"]
```

> ****Pro move:****Update this file monthly. As your focus shifts, update the context file and your agent immediately adjusts. No reconfiguration needed - just edit the .txt and re-upload.

https://x.com/0xMortyx/article/2061106244610408566/media/2061087517739216905

### 3 Test Prompts to Run First

Once your agent is set up, run these three to check it's working correctly:

https://x.com/0xMortyx/article/2061106244610408566/media/2061087801899094021

> ****If any test fails:****Don't rebuild - edit. Go back to the system prompt, find the instruction that should have caught it, and make it more explicit. One sentence usually fixes it.

### What You'll Notice After 1 Week

- Research that used to take 30 minutes takes 3 - because your agent filters before you even read
- You stop asking vague questions - because you know the agent needs a clear request to do its best work
- You start building a second agent - because once you see it work, you want one for every repeatable job
- The context file becomes invaluable - every update makes the agent smarter about your specific situation
- You realise most "AI tools" you've paid for are just this - a Claude Project with a good system prompt

### What to Build Next

Once your first agent is running for a week, the natural next step is a ****second agent with a different job**** - and then making them work together. That's what multi-agent systems are: multiple Claude Projects, each with one role, called in sequence.

But start with one. One agent that does one job well is worth more than five that do five things poorly.

> ****Save this.**** Build it today - not this weekend, not "when you have time." The setup takes 30 minutes and the value starts immediately.

> 📄 Original article URL: https://x.com/i/article/2061083387498991617

---

## Commentary from Other Bookmarks

### @0xMortyx (0xMorty) — 2026-06-01

> Andrej Karpathy: "90% of what AI twitter tells you to learn will be dead in 6 months"
> 
> 90% of what ai twitter tells you to learn dies in 6 months
> 
> senior engineers already stopped chasing it
> 
> the dead list: autogen, crewai, autonomous agent pitches, agent marketplaces, benchmark leaderboards, semantic kernel, dspy as a general framework, horizontal "build any agent" platforms, per-seat pricing for agents
> 
> the pattern is obvious. demos that break in production. hype that never ships. frameworks that go viral on monday and vanish by spring
> 
> what actually compounds:
> context engineering
> tool design
> orchestrator-subagent pattern
> eval discipline
> the harness mindset. harness > model, always
> mcp as the protocol layer
> 
> the edge isn't the newest framework. it's staying a few steps ahead until your signal becomes everyone's mass-opinion
> 
> book and study this

[→ View quote tweet](https://x.com/0xMortyx/status/2061491256107159736)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

