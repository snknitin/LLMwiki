---
title: "Start engineering the CONTEXT"
saved: "August 30, 2025 8:57 AM"
date: "2025-08-30"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7361278884132102144/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7361278884132102144%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7361278884132102144"
notion_tags: "Context"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, context]
---

# Start engineering the CONTEXT

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7361278884132102144/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7361278884132102144%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved August 30, 2025 8:57 AM · tags: Context

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7361278884132102144/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7361278884132102144%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Stop worshipping prompts. Start engineering the CONTEXT.

If the LLM sounds smart but generates nonsense, that’s not really “hallucination” anymore… That’s due to the incomplete context one feeds it, which is (most of the time) unstructured, stale, or missing the things that mattered. But we need to understand that context isn't just the icing anymore, it's the whole damn CAKE that makes or breaks modern AI apps.
We’re seeing a shift where initially RAG gave models a library card, and now context engineering principles teach them what to pull, when to pull, and how to best use it without polluting context windows. The most effective systems today are modular, with retrieval, memory, and tool use working together seamlessly.

What a modern context-engineered system looks like:
• Working memory: the last few turns and interim tool results needed right now. • Long-term memory: user preferences, prior outcomes, and facts stored in vector stores, referenced when useful. • Dynamic retrieval: query rewriting, reranking, and compression before anything hits the context window. • Tools as first-class citizens: APIs, search, MCP servers, etc., invoked when necessary.

𝐄𝐱𝐚𝐦𝐩𝐥𝐞: In an AI coding agent, working memory stores the latest compiler errors and recent changes, while long-term memory stores project dependencies and indexed files. The tools fetch API documentation and run web searches when knowledge falls short. The result is faster, more accurate code without hallucinations.

So, if you’re building smart Agents today, do this:
• Start with optimizing retrieval quality: query rewriting, rerankers, and context compression before the LLM sees anything. • Separate memories: working (short-term) vs. long-term, write back only distilled facts (not entire transcripts) to the long-term memory. • Treat tools like sensors: call them when evidence is missing. Never assume the model just “knows” everything. • Make the context contract explicit: schemas for tools/outputs and lightweight, enforceable system rules.

The good news is that your existing RAG stack isn’t obsolete with the emergence of these new principles - it is the foundation. The difference now is orchestration: curating the smallest, sharpest slice of context the model needs to fulfill its job… no more, no less.

So, if the model’s output is off, don’t just rewrite the prompt. Review and fix that context, and then watch the model act like it finally understands the assignment!
