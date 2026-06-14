---
title: "At our last DSPy meetup, @kshetrajna shared this amazing case study about how he's using DSPy at @Sh..."
author: "Drew Breunig"
username: "@dbreunig"
date: "2026-03-30"
tweet_url: "https://x.com/dbreunig/status/2038650860843245814"
tweet_type: "original"
likes: 823
retweets: 76
replies: 18
bookmarks: 1033
views: 268748
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "llm", "agents"]
---

# At our last DSPy meetup, @kshetrajna shared this amazing case study about how he's using DSPy at @Sh...

> **Source:** [@dbreunig](https://x.com/dbreunig) · 2026-03-30 · 👍 823 · 💬 18 · 🔖 1033 · 👁 268748

> 🔗 [View tweet on X](https://x.com/dbreunig/status/2038650860843245814)

## Tweet Content

At our last DSPy meetup, 
@kshetrajna
 shared this amazing case study about how he's using DSPy at 
@Shopify
 scale. I think this was my favorite slide.

## Media

![](https://pbs.twimg.com/media/HEq-J5vboAE5zmo.jpg)

---

## Commentary from Other Bookmarks

### @koylanai (Muratcan Koylan) — 2026-03-31

> The journey from a one-shot LLM to a single agent with DSPy, and finally to specialized sub-agents + MIPRO, is very valuable here.
> 
> 1. Let agents control their own context retrieval.
> The shift from "here are the pages" to "here are tools, go investigate" is an important architectural decision. The store is the knowledge base. The agent is the retrieval system. Manual context curation doesn't scale.
> 
> 2. Context isolation > shared context.
> Give specialized agents access to the context relevant to them while hiding it from other agents. Shared context between unrelated objectives creates noise. An isolated context per objective creates a signal. 
> 
> 3. Prompt optimization requires architectural prerequisites.
> MIPRO didn't work well on the monolithic single-agent setup. It worked extremely well on the specialized sub-agents. The architecture determines the optimization surface. Clean modules with isolated objectives give optimizers clean signal to work with. Optimize after you architect, not before.
> 
> 4. DSPy as architectural discipline.
> Even before they had labelled data, building in DSPy (wrap it as a ReAct agent in DSPy) forced them to think about evals. The framework's structure makes you define metrics, build evaluation pipelines and design for optimization.
> 
> 5. Snapshot your evaluation context.
> For any system where agents interact with live, changing data, deterministic eval requires freezing the data at labelling time. This applies to any agentic system that touches external data sources.
> 
> 6. Smaller model + better architecture > bigger model + worse architecture.
> Self-hosted Qwen 3 outperformed GPT-5 in this pipeline. The agentic loop, specialized tools, and MIPRO-optimized prompts compensate for the smaller model's limitations. The model is the cheapest part of the system to improve; the architecture is where the leverage is.
> 
> 7. Good architecture makes extension trivial.
> When each sub-agent is a self-contained DSPy module with its own tools and optimization, adding a new capability is just adding a new module. The marginal cost of the next agent approaches zero.
> 
> Great work by @Shopify and @kshetrajna, thanks for the interview @dbreunig 🙏

[→ View quote tweet](https://x.com/koylanai/status/2039027239304433767)

### @LakshyAAAgrawal (Lakshya A Agrawal) — 2026-03-31

> DSPy+GEPA can help your teams achieve 2x better production performance, while minimizing costs 75-90x (as validated by @Shopify and @DbrxMosaicAI)!
> 
> Have a look at the amazing talk by @kshetrajna sharing lots of knowledge for deplying these at scale! 
> 
> https://x.com/dbreunig/status/2038650860843245814?s=20

[→ View quote tweet](https://x.com/LakshyAAAgrawal/status/2038882849353527504)

