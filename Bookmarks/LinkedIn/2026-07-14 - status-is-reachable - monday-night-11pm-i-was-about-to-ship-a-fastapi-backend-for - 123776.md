---
title: "Monday night, 11pm. I was about to ship a FastAPI backend for a RAG assistant when I decided to run..."
author: "Status is reachable"
author_url: "https://www.linkedin.com/in/ACoAAEBEf9MBtHoRa00CHe_nh7PjYe8oh884eg4"
headline: "Python Developer | AI • ML • Data Analysis • FastAPI • LangChain • n8n | Building Smart Systems & Automation Pipelines"
date: "2026-07-14"
posted_relative: "2w"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7482778421090123776/"
activity_id: "7482778421090123776"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, rag, ml]
---

# Monday night, 11pm. I was about to ship a FastAPI backend for a RAG assistant when I decided to run...

> **Source:** [Status is reachable](https://www.linkedin.com/in/ACoAAEBEf9MBtHoRa00CHe_nh7PjYe8oh884eg4) · Python Developer | AI • ML • Data Analysis • FastAPI • LangChain • n8n | Building Smart Systems & Automation Pipelines · 2w

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7482778421090123776/)

## Post

Monday night, 11pm. I was about to ship a FastAPI backend for a RAG assistant when I decided to run one more load test. Good thing I did.
The API worked perfectly for a single user. Question comes in, gets embedded, pulls context from pgvector, sends it to the LLM, returns an answer. Average response time: 1.2 seconds. Clean.

Then I opened five tabs and hit it at once.

Response times went from 1.2 seconds to 9 seconds. Not because the server was overloaded. CPU usage barely moved. The requests were just sitting in a queue, waiting their turn, even though FastAPI is supposed to handle concurrent requests natively.

Took me about two hours to find it. The embedding call inside my route was synchronous. So was the LLM call. FastAPI's async event loop was running the whole thing like a single-lane road, one request at a time, even though nothing about the work itself required that.

I rebuilt the flow. Moved embedding generation into a background task. Switched the Postgres connection to an async driver. Swapped LangChain's standard invoke methods for their async equivalents, which I hadn't even known existed until I went digging through their source code around 1am.

Ran the same five-tab test again. Response times held at 1.4 to 1.8 seconds across all five, instead of climbing with each additional user.

What got me was how invisible the problem was. Nothing in the code looked wrong. No errors, no warnings. It just quietly behaved like a synchronous app wearing an async framework as a costume.

Shipped it the next morning, three hours later than planned, but actually built to hold up under real traffic instead of just looking good in a demo.

If you're building LLM-backed APIs, test with concurrent requests before you call it done. Single-user testing will lie to you

#fastapi #aiengineer #pgvector #AI #ML

## Images

![](https://media.licdn.com/dms/image/v2/D4D22AQHgc15Zocy7sQ/feedshare-shrink_480/B4DZ9grUrmGkAg-/0/1784033397708?e=1787184000&v=beta&t=-gViJfl0hIKJMumuBhrnA9Dkmzu9OLxrPtVEWZKGSfI)

