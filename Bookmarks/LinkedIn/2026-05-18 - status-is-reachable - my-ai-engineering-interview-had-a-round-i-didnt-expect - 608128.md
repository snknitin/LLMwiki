---
title: "My AI engineering interview had a round I didn't expect."
author: "Status is reachable"
author_url: "https://www.linkedin.com/in/ACoAADWyNrABDCszOy1Mgxmn6kpIZmKUOoEjdfs"
headline: "AI Engineer | Building production LLM systems | Azure AI-102 | Writing about what actually breaks"
date: "2026-05-18"
posted_relative: "2mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7461980224914608128/"
activity_id: "7461980224914608128"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, agents, llm, career]
---

# My AI engineering interview had a round I didn't expect.

> **Source:** [Status is reachable](https://www.linkedin.com/in/ACoAADWyNrABDCszOy1Mgxmn6kpIZmKUOoEjdfs) · AI Engineer | Building production LLM systems | Azure AI-102 | Writing about what actually breaks · 2mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7461980224914608128/)

## Post

My AI engineering interview had a round I didn't expect.

They didn't ask me to code. They gave me a blank draw.io canvas and said:

"Design us a production-grade agentic system. Use the components on the left. Go."

On the left: 
orchestrator, sub-agents, memory module, tool registry, vector store, LLM gateway, observability layer, guardrails.

No instructions.

The first five minutes were the hardest. I knew each component. I hadn't thought about how they connect under pressure, on a shared canvas, with someone watching every box I dragged.

I started with the LLM gateway. Everything flows through it: routing, rate limits, cost tracking.

Then the orchestrator → breaks tasks, routes to sub-agents.
Then tool registry → agents don’t call tools directly, they go through a controlled layer.

Then they asked one question: Where does memory live?

I had the vector store connected to the orchestrator. They pushed back - "why not at the sub-agent level?"

Both work. I hadn't thought about the trade-off explicitly. 
Centralised memory is consistent. 
Distributed memory is faster.

That's what they were actually testing - not whether I could drag boxes. Whether I understood the trade-offs well enough to defend my choices under pushback.

The lesson that stayed with me:

Knowing what each component does isn't enough. You need to know:
why it connects there? what breaks if you move it? what you gain and lose either way? 

That’s system design in AI. Not tools. Decisions.

Have you had a system design round with live diagramming? How did you approach it?

#AIEngineering #SystemDesign #InterviewPrep

