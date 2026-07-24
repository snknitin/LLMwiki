---
title: "I'm just going to dump my whole agentic setup out here, because I see too many people missing giant..."
author: "Jamon"
username: "@jamonholmgren"
date: "2026-07-11"
tweet_url: "https://x.com/jamonholmgren/status/2076001786700394610"
tweet_type: "original"
likes: 4026
retweets: 262
replies: 151
bookmarks: 10414
views: 342712
has_media: false
extraction_quality: full
tags: ["twitter-bookmark", "claude", "llm", "cursor", "agents"]
---

# I'm just going to dump my whole agentic setup out here, because I see too many people missing giant...

> **Source:** [@jamonholmgren](https://x.com/jamonholmgren) · 2026-07-11 · 👍 4026 · 💬 151 · 🔖 10414 · 👁 342712

> 🔗 [View tweet on X](https://x.com/jamonholmgren/status/2076001786700394610)

## Tweet Content

I'm just going to dump my whole agentic setup out here, because I see too many people missing giant chunks of this and it's hurting them.

Here's what I have and recommend:

0. an AGENTS.md that is a router -- it sends the agent to the right skills, docs, tools

1. a standard workflow doc/skill customized to my needs ... (grab Matt Pocock skills if you don't already have something) ... I tag this in most sessions with `@/AGENT_WORKFLOW.md` and it pulls it in.

2. self-healing docs for every system, and agents are instructed to keep them updated ... I tag the ones I know I need, or let the agent find them through AGENTS.md ... I also provide a more detailed summary in the first 7 lines of every doc, so they're easily greppable to find the right thing, and this is documented in AGENTS.md

3. agents always run the app ... the agent should always actually run the app itself, and test its work and fix issues as it goes, especially if running autonomously / asynchronously

4. end-to-end tests and instructions to write more and keep up to date, and docs on how to write tests, what to  avoid, and a list of all the tests and what they test in yet another markdown doc ... write and run targeted tests during implementation, improve and commit with work

5. custom linters at precommit hooks looking for any problems you run across, with `--fix` fixing the problems automatically, OR if that's not feasible, it shells out to a cheaper LLM like Composer 2.5 or Sonnet to fix the problems -- NOT just flagging them, but actually resulting in cleaned code

6. cross-agent review at each major point: research, plan, implementation, and wrap-up. I mean codex, claude, cursor, whatever -- but it shouldn't be the same model reviewing the same code. And specific docs for agent review, what to look for, how to approach it. Also, personas -- looking at the code from different perspectives, such as maintainability, code quality, security, performance, AI smells, domains (e.g. "financial services expert" or whatever) ... and each persona also "owns" a set of system docs too and keeps them up to date

7. agent traces / worksheets that track what the agent is doing each session. if the agent fails partway through, you should be able to hand this worksheet to another agent and it could finish the job. commit this worksheet with the work so it's all connected and easy to reference later (you will reference these later!!), also have the agent apply git tags that correspond to specific worksheet names so they're easy to find

8. automatic agent feedback to you at the end of the session, added to a doc that is also committed with the work, that you periodically ingest into an interactive session and improve your workflows

9. a tools or bin folder that contains python or bash scripts that the agent has skills to make to make its job easier (for example, I have an `agent_review` bash script that lets the agent kick off agent reviews via CLI without knowing each agent's particular incantations) ... docs on how to make scripts effectively, and instructions to constantly build these out more

10. periodic agent sweeps through recent commits, looking for problems / gotchas from a higher level across commits

11. a coding conventions doc that is just for specific coding conventions you want to see in the code base, your review agents use these a lot (but a lot of this should be in linters)

12. an agent loop / night shift skill for autonomous work, that lays out how the agent is to approach this, from an orchestration standpoint

13. a task queue that is accessible to the agent (mine is just a TODOS.md, but yours might be in Linear etc, with a CLI to fetch via API)

14. a periodic false-confidence test audit skill that looks for tests that aren't actually testing what you think they're testing, and that fix those

15. visual regression tests -- take screenshots, compare via tool and with agent visual review, commit with work (git lfs useful here) or at least push into the PR

16. automatic performance benchmark tests that notice when performance degrades

17. performance profiling tools that can be used by agents for targeted benchmarking, trying new techniques, comparing outputs, and comparing profiles

18. end-of-shift full validations, including running all tests, performance, agent reviews, sweeps, everything -- when you return, it's all as pristine as it can be

If you have all this, your agentic coding experience is going to be very different than dry prompting and manually guiding it toward the right thing every time.

