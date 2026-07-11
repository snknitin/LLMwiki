---
title: "[@NousResearch](https://x.com/@NousResearch)"
author: "0xJeff"
username: "@0xJeff"
date: "2026-05-18"
tweet_url: "https://x.com/0xJeff/status/2056269840009318569"
tweet_type: "original"
likes: 845
retweets: 74
replies: 30
bookmarks: 1741
views: 155484
has_media: false
extraction_quality: full
article_id: "2056268562051022848"
tags: ["twitter-bookmark", "claude", "mcp", "agents"]
---

# [@NousResearch](https://x.com/@NousResearch)

> **Source:** [@0xJeff](https://x.com/0xJeff) · 2026-05-18 · 👍 845 · 💬 30 · 🔖 1741 · 👁 155484

> 🔗 [View tweet on X](https://x.com/0xJeff/status/2056269840009318569)

## Article Content

[@NousResearch](https://x.com/@NousResearch)

 just partnered with [@xai](https://x.com/@xai)

 and Hermes just got a HUGE boost in research capability.

https://x.com/NousResearch

****Nous Research****

@NousResearch

·

[May 17](https://x.com/NousResearch/status/2055748546679472322)

xAI has expanded access to X Premium+ subscribers in Hermes Agent. 

Enjoy!

https://x.com/NousResearch/status/2055748546679472322/photo/1

Quote

****xAI****

@xai

·

May 17

You can now use X Premium subscriptions in Hermes Agent, and Hermes Agent can now search X posts.

https://x.ai/news/grok-hermes…

****Here are the highlights****

- Directly Grok subscription, X Premium (and Premium+) users who have Grok subs can now plug that into Hermes
- x_search tool is live which allows Hermes (with Grok models) to natively search X just like when you’re prompting SuperGrok to do research on X

This is massive because X is the town square for macro, geopolitics, tech, AI, and crypto news, articles, and media.

In order to get the insights, before you would need to use X API to fetch accounts, content, and data. While the X API is decent, you can’t really do deep research on it like you would with SuperGrok on X. The research capability for Hermes was quite limited.

But now, Hermes can use x_search natively. Hermes can output better research report + reduce X API credit cost + able to analyze X articles (which wasn’t possible before with X API).

### How I’m adjusting my workflow

If you remember from my previous Hermes articles, I run Hermes as an data/investment analyst that has all my investment theses, preference, portfolio holdings. He delivers briefs every morning on macro, geopolitics, tech, AI, crypto, and more so I can stay on top of things. He learns from all the reports that he delivers. He’s like my second brain + analyst all in one.

There were couple of challenges I had with my workflows and these new updates help fix them

****1. X bookmark cron job****

Hermes uses X API to fetch for last 24 hrs bookmark (it dedups anything I’ve already seen and only shows fresh ones).

I often bookmark articles but X API can’t read X article content, it can only read the headline, the author, and a few lines (for some reasons).

With x_search, I can just say “summarize with x_search” and drop an X article. I don’t have to switch the model to Grok 4.3 first because the x_search tool automatically default to Grok 4.3 already.

x_search fetches X article -> my base model DeepSeek-v4-flash analyzes and summarizes the content

Make sure you set up the xai-oauth + configure x_search first before testing it out.

“xai-oauth” part is very essential here because if you put xai, it’ll go towards xai API instead of the Grok subscription.

^Before you do this, make sure to sign up for a Grok subscription and authenticate it first with “hermes model” command in the terminal (if you have X Premium or Premium+ you can login to Grok and authenticate with that as well)

****2. Deep Research Pipeline****

With x_search, deep research leveraging rich X data is easier than ever. I’ve worked/brainstormed with Claude Opus 4.7 and it came up with a 6-stage research pipeline.

The reason why I did this is because x_search doesn’t produce high quality result comparable to using SuperGrok directly on X or on Grok(.)com. The because the web interface has more optimized post-processing, fresher context, and better prompt engineering behind the scenes. The agent x_search tool is more raw.

https://x.com/0xJeff/article/2056269840009318569/media/2056268885767434241

****The 6-stage research pipeline uses****

- x_search to perform targeted search
- [@cookiedotfun](https://x.com/@cookiedotfun)

 MCP tool great for sentiment trend/analysis, KOL discussions
- browser CDP which is Hermes native browser tool (let Hermes open up Grok manually on Chrome and prompt it directly on SuperGrok)

DeepSeek synthesizes everything while Hindsight recall/reflect to draw past insights and cross-reference it with the new synthesized information

https://x.com/0xJeff/article/2056269840009318569/media/2056268949248200704

https://x.com/0xJeff/article/2056269840009318569/media/2056268986044862464

The result is end-to-end comprehensive report that captures the past, the present, the future taken into account our knowledge base/our context.

The prompt was “Deep dive on geopolitics, macro, and their impact on stock market and crypto - focus on current state of things and forward looking things that could happen and what to watch out for in the next 2 weeks”

****Key thing to note****: I’ve tried running this end-to-end research workflow with Grok 4.3 and the result is beyond horrible. Grok 4.3 kept failing with browser harness, it’s bad with AI agent tools, it kept asking at every single turn instead of actually doing the job. Better stick to DeepSeek v4.

****3. X Tracker workflow****

One of my main category of cron jobs is tracking smart X accounts who regularly publish great insights in their own field every single day. I’m tracking about 7-8 people now.

Previously, I used X API to fetch their content and DeepSeek analyzes, synthesizes, and prioritizes them based on my preference. It costs about ~$0.5 per day across all cron jobs (not too bad).

With x_search feature live, I switched X API for x_search feature and pretty much saved up on the $0.5 per day. It only costs about $0.1 per day now since I’m only using it for X bookmark cron job.

### What I learnt so far

****You can get Grok subscription for $10/month instead of $30/month****

I bought Grok subscription for $30/month before xai announced that X Premium users can use their Grok subscription with Hermes (sucks for me).

Anyway, there’s a strategy you can explore to only pay $10/month instead of $30.

First, get Grok subscription for $30/month -> cancel -> you’ll get offered 3 months for only $30/month (pay $0.30 more for 3 months of sub)

xai is pretty generous rn.

****Configure x_search first before you use it****

Once you have Grok subscription

- Go to “hermes tools” and “tools for CLI” and turn on x_search
- Go to config.yaml and set x_search timeout to 240 or 300 seconds to prevent x_search tool timing out (it timeout and me many times, i switched to 300 and everything worked fine)

“x_search:

timeout_seconds: 240   # or 300

retries: 2

model: grok-4.3”

****Don’t use Grok 4.3 as a default model, it’s very bad****

It sucks

- browser harness
- reasoning/summarizing/connecting dots together
- multi-turn agent tool calling & execution

https://x.com/0xJeff/article/2056269840009318569/media/2056269038452604928

Screenshot of me trying to get Grok 4.3 to complete the research pipeline (he kept crashing on me so I had to switch back to DeepSeek)

Better stick to your favorite open models.

Since x_search tool defaults to Grok-4.3 with Grok subscription already, there’s no need to switch to Grok-4.3 as the base model for your Hermes

****x_search + Cookie MCP is a great combination****

Cookie is great at getting structured data that’s immediately usable — KOL leaderboards, mindshare timeseries, social decay metrics. It’s also great at project analytics.

But it’s weak at getting real-time news, explaining the “why”, and search reliability which is where x_search comes in very handy.

### Wrapping it up

After almost 2 months of using Hermes, I found myself slowly moving from relying on Hermes to think & execute to identifying problems & setting up hypothesis and testing that hypothesis with the agent.

AI as a learning augment really helps me get up to speed on how things work, what tools are great for what purposes, and more importantly how to get the desired outcome while I continue to learn, make money from our strats, and not spend hundreds or thousands in inference costs.

With the new research capability, I'm a lot more excited to continue learning with Hermes than ever.

Anyway, that’s it for today. If you enjoy this piece and ****want to learn more about the tools I use****, do ****check out this page ****[HERE](https://defi0xjeff.substack.com/p/the-analyst-agent-tools)

. New tools update coming every week.

Thanks for reading and see you guys in the next one!

> 📄 Original article URL: https://x.com/i/article/2056268562051022848

