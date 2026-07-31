---
title: "We just dropped 7 multi-agent design patterns in 7 days 🤯"
author: "Shubham Saboo"
author_url: "https://www.linkedin.com/in/ACoAABzPLp4BT8-7xERTxR17vS8edCgAiBTIkTM"
headline: "Senior AI Product Manager @ Google | Awesome LLM Apps (#1 AI Agents GitHub repo with 128k+ stars) | 3x AI Author | Community of 350k+ AI developers | Views are my Own"
date: "2026-03-21"
posted_relative: "4mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7440947282524479488/"
activity_id: "7440947282524479488"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, agents, llm, mcp, career]
---

# We just dropped 7 multi-agent design patterns in 7 days 🤯

> **Source:** [Shubham Saboo](https://www.linkedin.com/in/ACoAABzPLp4BT8-7xERTxR17vS8edCgAiBTIkTM) · Senior AI Product Manager @ Google | Awesome LLM Apps (#1 AI Agents GitHub repo with 128k+ stars) | 3x AI Author | Community of 350k+ AI developers | Views are my Own · 4mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7440947282524479488/)

## Post

We just dropped 7 multi-agent design patterns in 7 days 🤯

With 100% open-source code for every single one of them.

No theory. No slides. No "imagine if you could."

Copy-paste code that actually builds working multi-agent systems.

This was Week 2 of Google Cloud's Advent of Agents Season 2. 

One pattern per day. Each one solves a real orchestration problem you hit when agents need to work together.

Here's what we shipped:
• Sequential Agents: Output of one agent feeds straight into the next. No guessing. No wasted reasoning tokens. Predictable pipelines.

• Coordinator/Dispatcher: An LLM root agent dynamically routes tasks to specialist sub-agents. We built a full video generation pipeline where the coordinator hands off between a script sequencer and a video agent to maintain visual consistency across shots.

• Parallel Fanout: Run independent agents concurrently instead of sequentially. State interpolation lets a downstream synthesizer read all parallel outputs using simple bracket templating. No custom data-passing code.

• Hierarchical Decomposition: A Manager agent calls a Planner tool at runtime to break complex problems into steps, then kicks off a SequentialAgent pipeline to execute the plan autonomously.

• Generator-Critic Loop: A Writer and Critic iterate inside a LoopAgent until the output passes a strict rubric. The Critic can call an approval tool to break the loop early once everything checks out.

• Iterative Refinement: A meta-agent that builds, tests, and refines other ADK agents. Composes Skills, MCP, and Code Execution into one loop that keeps fixing until tests pass.

• Human in the Loop: Approval breakpoints that pause agent execution before sensitive tool calls. The agent suspends, waits for human confirmation, then resumes exactly where it left off.

Every pattern runs on Google Agent Development Kit with Gemini 3.1 Pro. Every one is open-source.

150,000 developers joined Season 1. Season 2 is now live.

Week 3 goes deeper. Real-time voice agents, multimodal processing, and cross-framework orchestration with A2A.

Join here for free daily tutorials: https://lnkd.in/dsCF8_Fb

## Links

- https://lnkd.in/dsCF8_Fb

## Images

![](https://media.licdn.com/dms/image/v2/D5622AQEQAfQsFX9ENw/feedshare-shrink_480/B56Z0OOHySKIAk-/0/1774060076701?e=1787184000&v=beta&t=XMuvZ2UtsXbh8NIZ88hggNmKJiwAhs4Il7SP6TU2GHg)

