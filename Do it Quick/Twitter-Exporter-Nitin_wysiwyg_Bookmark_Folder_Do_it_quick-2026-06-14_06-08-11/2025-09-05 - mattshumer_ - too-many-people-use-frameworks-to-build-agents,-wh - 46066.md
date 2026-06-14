---
title: "Too many people use frameworks to build agents, when really, all you need are the raw LLM APIs and a..."
author: "Matt Shumer"
username: "@mattshumer_"
date: "2025-09-05"
tweet_url: "https://x.com/mattshumer_/status/1963843389918446066"
tweet_type: "original"
likes: 857
retweets: 43
replies: 134
bookmarks: 272
views: 160955
has_media: false
extraction_quality: full
tags: ["twitter-bookmark", "claude", "mcp", "llm", "agents"]
---

# Too many people use frameworks to build agents, when really, all you need are the raw LLM APIs and a...

> **Source:** [@mattshumer_](https://x.com/mattshumer_) · 2025-09-05 · 👍 857 · 💬 134 · 🔖 272 · 👁 160955

> 🔗 [View tweet on X](https://x.com/mattshumer_/status/1963843389918446066)

## Tweet Content

Too many people use frameworks to build agents, when really, all you need are the raw LLM APIs and a while loop.

Don't overcomplicate what doesn't need to be overcomplicated.

---

## Commentary from Other Bookmarks

### @ashpreetbedi (Ashpreet Bedi) — 2025-09-06

> Grifters like this are wasting your time and their Dunning-Kruger opinions should be ignored by serious builders. You either build on a framework or live long enough to roll your own (which is fine btw). Here’s why:
> 
> 1. The "LLM API in a while loop" is your underlying agentic step - the unit of work in your agent system. You’ll wrap this in a function and call it when you want to run your agent. This is just the starting line, and also where these idiots are usually stuck. 
> 
> 2. As you start building Agents, you turn this function into a class and add logic for prompting, message management, tool calling, retries and error handling. Congrats, you’ve started to roll your own framework.
> 
> 3. Then, you’ll want to try different models or chain agents to build a workflow. Each has its quirks, custom settings, different response formats, prompting hacks (eg: claude needs "Do not reflect on the quality of the returned search results in your response"). You start adding more layers to your homegrown framework.
> 
> Till now this is a solvable problem and you can vibecode it.
> 
> 4. Then things really start to get frustrating. You learn quickly that you need to maintain session history and state across runs because, unlike these grifters, you’re not actually going to run a jupyter notebook in your mom’s basement. Guess what — your agents need a database. You’ll design tables like agent_sessions, wire up session IDs, store/retrieve history and state on each run. Weeks later, you’ll find your schema is inefficient because you forgot to add the right indexes, and now you’ve got to learn about database migrations.
> 
> FUCCKKKK! Wasn’t this supposed to just be a while loop? And we haven’t even started with RAG, chunking, embedding, retrieval, context management, tool management, MCP, monitoring, and logging. Why did the grifter grift?
> 
> Now we're weeks into a vibecoded nightmare and the CEO is asking when can we launch.
> 
> 5. Finally, you confront the real problem: how do I serve this as an API and build a product on top of? 
> 
> You hack together a FastAPI app, throw it in a container, and think you’re done. You breathe a sigh of relief and hand it to your CEO. He hammers it like a madman, chunks start dropping, agents mix context, and you suddenly need to learn about SSE. You implement SSE, things work well for a while and then your requests start timing out and your container memory blows up - memory leaaakk. You blame python, but deep down, you know, you know.
> 
> You start searching for solutions and come across this code snippet from @AgnoAgi 
> 
> In 25 lines of code you get:
> 
> ✅ An Agent with memory, state, knowledge, and everything you could ask for.
> ✅ Access to 1000s of tools and MCP servers.
> ✅ A production-grade FastAPI app with pre-built SSE-compatible endpoints.
> 
> You also get a vibrant community and a team of experts to help you every step of the way. This is a systems engineering problem and you get the right tools for the job.
> 
> You start seeing the light, give up your masochism, and repeat the mantra: JUST USE THE FUCKING FRAMEWORK!

[→ View quote tweet](https://x.com/ashpreetbedi/status/1964362446627299598)

![](https://pbs.twimg.com/media/G0LKwZ8XgAA4ecj.jpg)

