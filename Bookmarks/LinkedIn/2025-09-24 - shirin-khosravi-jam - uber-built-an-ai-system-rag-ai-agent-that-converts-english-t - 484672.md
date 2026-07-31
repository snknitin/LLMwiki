---
title: "Uber built an AI system (RAG + AI Agent) that converts English to SQL"
author: "Shirin Khosravi Jam"
author_url: "https://www.linkedin.com/in/ACoAACAffBABmg0i0TxuEnNvNKeuiy2-Kq7k_Ds"
headline: "Sr. Data Scientist/ AI Engineer | 400k+ AI/ML Community | Data Science, RAG, AI Agents, & MLOps | Germany’s Top Female Voice in AI (Favikon) 🇩🇪 | Opinions are my own!"
date: "2025-09-24"
posted_relative: "11mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7376532027539484672/"
activity_id: "7376532027539484672"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, agents, llm, rag, career, ml, prompting]
---

# Uber built an AI system (RAG + AI Agent) that converts English to SQL

> **Source:** [Shirin Khosravi Jam](https://www.linkedin.com/in/ACoAACAffBABmg0i0TxuEnNvNKeuiy2-Kq7k_Ds) · Sr. Data Scientist/ AI Engineer | 400k+ AI/ML Community | Data Science, RAG, AI Agents, & MLOps | Germany’s Top Female Voice in AI (Favikon) 🇩🇪 | Opinions are my own! · 11mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7376532027539484672/)

## Post

Uber built an AI system (RAG + AI Agent) that converts English to SQL 
Here's how 👇 
(saving 300 engineers 7 minutes per query)

Most companies talk about AI in production.
Uber actually shipped it at scale.

Here's how QueryGPT works ↓

𝐓𝐡𝐞 𝐏𝐫𝐨𝐛𝐥𝐞𝐦
→ 1.2M SQL queries per month at Uber
→ Each query takes ~10 minutes to write
→ Engineers spend hours searching schemas + writing SQL
→ Massive productivity bottleneck

𝐓𝐡𝐞 𝐒𝐨𝐥𝐮𝐭𝐢𝐨𝐧: 𝐌𝐮𝐥𝐭𝐢-𝐀𝐠𝐞𝐧𝐭 𝐑𝐀𝐆 𝐒𝐲𝐬𝐭𝐞𝐦

1️⃣ 𝐈𝐧𝐭𝐞𝐧𝐭 𝐀𝐠𝐞𝐧𝐭
→ Classifies user questions into business domains
→ Maps "trips in Seattle" to "Mobility workspace"
→ Dramatically narrows search radius

2️⃣ 𝐓𝐚𝐛𝐥𝐞 𝐀𝐠𝐞𝐧𝐭 
→ Identifies relevant tables for the query
→ Shows suggestions to user for confirmation
→ Prevents wrong table selection

3️⃣ 𝐂𝐨𝐥𝐮𝐦𝐧 𝐏𝐫𝐮𝐧𝐞 𝐀𝐠𝐞𝐧𝐭
→ Removes irrelevant columns from large schemas
→ Some tables have 200+ columns
→ Reduces token usage and improves speed

4️⃣ 𝐐𝐮𝐞𝐫𝐲 𝐆𝐞𝐧𝐞𝐫𝐚𝐭𝐢𝐨𝐧
→ Uses GPT-4 with curated SQL examples
→ Few-shot prompting with domain-specific samples
→ Includes Uber business logic and date handling

𝐏𝐫𝐨𝐝𝐮𝐜𝐭𝐢𝐨𝐧 𝐑𝐞𝐬𝐮𝐥𝐭𝐬
→ Query time: 10 minutes → 3 minutes (70% reduction)
→ 300 daily active users
→ 78% say it saves significant time
→ Handles complex multi-table joins

𝐊𝐞𝐲 𝐈𝐧𝐧𝐨𝐯𝐚𝐭𝐢𝐨𝐧: 𝐖𝐨𝐫𝐤𝐬𝐩𝐚𝐜𝐞𝐬
Instead of searching all schemas, they created curated collections:
→ Mobility (trips, drivers, vehicles)
→ Ads (campaigns, impressions, conversions) 
→ Core Services (payments, users, cities)
→ Custom workspaces for specialized needs

𝐓𝐡𝐞 𝐋𝐞𝐚𝐫𝐧𝐢𝐧𝐠
LLMs work best as specialized agents, not generalists.
→ Each agent has one focused job
→ Better accuracy than one mega-agent
→ Easier to debug and improve

This is how you actually ship AI in production, not just demos.
Full technical breakdown (in the comments) 

I hope this adds some insights to you 🙌 

♻️ Repost to share with your network 💚 
➕ Join 24.000+ AI/ML builders here: https://lnkd.in/ds_SzEUH

## Links

- https://lnkd.in/ds_SzEUH

## Images

![](https://media.licdn.com/dms/image/v2/D4D22AQGu2nx0VzKxTQ/feedshare-shrink_480/B4DZl60yWVJAAY-/0/1758702283119?e=1787184000&v=beta&t=F6NTeDGB1pm1kxxWaurxUvUQuoJ9m74nFFq1fsXyc88)

