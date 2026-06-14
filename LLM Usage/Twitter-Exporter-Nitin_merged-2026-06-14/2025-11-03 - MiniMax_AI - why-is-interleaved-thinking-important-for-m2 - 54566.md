---
title: "Why is Interleaved Thinking Important for M2?"
author: "MiniMax (official)"
username: "@MiniMax_AI"
date: "2025-11-03"
tweet_url: "https://x.com/MiniMax_AI/status/1985375617622454566"
tweet_type: "original"
likes: 686
retweets: 67
replies: 12
bookmarks: 254
views: 636256
has_media: false
extraction_quality: full
article_id: "1985281548292157440"
tags: ["twitter-bookmark", "claude", "llm", "agents"]
---

# Why is Interleaved Thinking Important for M2?

> **Source:** [@MiniMax_AI](https://x.com/MiniMax_AI) · 2025-11-03 · 👍 686 · 💬 12 · 🔖 254 · 👁 636256

> 🔗 [View tweet on X](https://x.com/MiniMax_AI/status/1985375617622454566)

## Article Content

Since ****MiniMax-M2****'s launch last week, we have seen a surge in community adoption and usage. Yesterday M2 became one of the**** top 3 models in usage on OpenRouter****. However, we have also observed incorrrect implementations of M2, especially regarding ****interleaved thinking****, which significantly reduce the model's performance.

During the very early stage of developing M2, we discovered that**** interleaved thinking**** is important in both agentic and coding applications. Since most current models, apart from Anthropic Claude, do not fully support interleaved thinking, we believe it hasn't yet become a universal convention. From users' feedback, we've also noticed that interleaved thinking is sometimes not applied correctly in practice. To address this, we'd like to share our understanding on**** how to use it effectively across different API interfaces**** to achieve better results.

## Why is Interleaved Thinking Important for M2?

****Interleaved thinking**** is essential for LLM agents: it means alternating between explicit reasoning and tool use, while carrying that reasoning forward between steps.This process significantly enhances ****planning, self‑correction, and reliability**** in long workflows. (See [Anthropic’s guidance](https://docs.claude.com/en/docs/build-with-claude/extended-thinking#interleaved-thinking)

 on interleaved thinking for more background). In practice, it transforms long, tool‑heavy tasks into**** a stable plan → act → reflect**** loop, reducing state drift and repeated mistakes while keeping actions grounded in fresh evidence. Interleaved thinking also improves ****debuggability****: reasoning snapshots make failures explainable and recoverable, and raise ****sample‑efficiency**** by reusing hypotheses, constraints, and partial conclusions instead of re‑deriving them each step. For best results, ****interleave thinking with tool feedback ****rather than front‑loading it, and ****persist the chain of thought**** so it compounds across turns.

From community feedback, we've often observed failures to preserve prior-round thinking state across multi-turn interactions with M2. The root cause is that the widely-used ****OpenAI Chat Completion API does not support passing reasoning content back in subsequent requests****. Although the Anthropic API natively supports this capability, the community has provided less support for models beyond Claude, and many applications still omit passing back the previous turns' thinking in their Anthropic API implementations. This situation has resulted in poor support for Interleaved Thinking for new models. ****To fully unlock M2's capabilities, preserving the reasoning process across multi-turn interactions is essential.****

In ****MiniMax-M2****, ****interleaved CoT**** works most effectively when prior‑round reasoning is preserved and fed back across turns. The model reasons between tool calls and carries forward ****plans, hypotheses, constraints, and intermediate conclusions ****— this accumulated state is the backbone of reliability. When prior state is dropped,**** cumulative understanding breaks down****, ****state drift increases, self‑correction weakens, and planning degrades ****— especially on long‑horizon toolchains and run‑and‑fix loops.

Retaining prior‑round thinking state improves performance significantly compared to discarding it, as evident across benchmarks: ****SWE‑Bench Verified 69.4 vs. 67.2 (Δ=+2.2; +3.3%), Tau^2 87 vs. 64 (Δ=+23; +35.9%), BrowseComp 44.0 vs. 31.4 (Δ=+12.6; +40.1%), GAIA 75.7 vs. 67.9 (Δ=+7.8; +11.5%), and xBench 72.0 vs. 66.0 (Δ=+6.0; +9.1%).****

https://x.com/MiniMax_AI/article/1985375617622454566/media/1985371198377865216

****Keep the interleaved thinking state intact is important.**** Reliability isn’t just about what LLM think now; it’s about whether LLM can ****revisit and**** ****revise what it thought before****. Interleaved thinking operationalizes this: ****plan → act → reflect****, with state preserved so reflection compounds and corrections propagate across turns.

## Interleaved Thinking Implemented Correctly

https://x.com/MiniMax_AI/article/1985375617622454566/media/1985299963417690112

## Enabling Interleaved Thinking in MiniMax-M2

We provide best-in-class interleaved thinking support for MiniMax-M2 on our open API platform: [https://platform.minimax.io](https://platform.minimax.io)

. For best performance and compatibility, we strongly recommend using our ****official API****. In general, MiniMax offers ****two API interfaces****:

### OpenAI-Compatible API:

Now, when calling the M2 model through the MiniMax OpenAI-Compatible API, you can experience:

- ****A separate ********reasoning_details******** field:**** The model's reasoning process is returned in a separate reasoning_details field, no longer mixed with the content. This makes the API structure cleaner and easier to parse.
- ****A complete chain of thought:**** Passing the reasoning_details field in subsequent requests ensures that the model maintains a complete chain of thought across multiple tool calls, leading to more accurate judgments and planning.

Code examples are available in the [official guide](https://platform.minimax.io/docs/guides/text-m2-function-call#openai-sdk)

.

### Anthropic-Compatible API

The Anthropic API natively supports Interleaved Thinking. Simply append the model's complete output from each round (including thinking_blocks) to the messages history and send it to the API in subsequent requests.

For more details, please refer to the [official guide](https://platform.minimax.io/docs/guides/text-m2-function-call#anthropic-sdk)

.

## Advancing Industry Standards for the Future of Agents

In addition to our official API platform support of interleaved thinking, we are helping partners such as OpenRouter, Ollama, Droid, Vercel, Cline to test and implement interleaved thinking correctly. Through helping our ecosystem partners, ****we aim to establish a unified protocol paradigm for widely supporting Interleaved Thinking**** among applications, OpenAI-Compatible APIs, and Anthropic-Compatible APIs — setting a foundation for the industry to build on. We believe that an open and unified standard will empower developers worldwide to easily build more capable, reliable AI agents, and foster a thriving AI ecosystem.

For partnership and collaboration, please do not hesitate to contact us at ****API@minimax.io****.

****Links****

1. ****Anthropic’s guidance on interleaved thinking****: [https://docs.claude.com/en/docs/build-with-claude/extended-thinking#interleaved-thinking](https://docs.claude.com/en/docs/build-with-claude/extended-thinking#interleaved-thinking)
2. ****OpenAI-Compatible API****: [https://platform.minimax.io/docs/guides/text-m2-function-call#openai-sdk](https://platform.minimax.io/docs/guides/text-m2-function-call#openai-sdk)
3. ****Anthropic-Compatible API****: [https://platform.minimax.io/docs/guides/text-m2-function-call#anthropic-sdk](https://platform.minimax.io/docs/guides/text-m2-function-call#anthropic-sdk)
4. ****MiniMax Open Platform****: [http://platform.minimax.io](https://t.co/fHRdSV73Hr)

> 📄 Original article URL: https://x.com/i/article/1985281548292157440

---

## Commentary from Other Bookmarks

### @TheAhmadOsman (Ahmad) — 2025-11-04

> > be MiniMax
> > drop M2, everybody’s favorite new open agent LLM
> > hits top 3 on OpenRouter overnight
> > usage explodes
> > ...but something’s off
> > performance tanks, complaints start
> > users: “model bad!”
> > reality: “your infra bad!”
> > missing the “interleaved thinking” trick
> 
> > what’s interleaved thinking?
> > plan → act → reflect
> > LLM reasons, uses a tool, checks the outcome, updates its thoughts
> > rinse, repeat
> > your agent isn’t just one-and-done,
> > it remembers and refines its moves across the whole workflow
> > basically: LLM is not a goldfish, don’t treat it like one
> 
> > why does it matter?
> > turns a clunky one-shot agent into a chain that self-corrects
> > plans survive tool calls, state actually compounds
> > catch mistakes, course-correct, don’t drift into hallucination land
> > every step gets smarter, not dumber
> > debuggability goes up
> > sample-efficiency up
> > toolchains stop YOLO’ing into the abyss
> 
> > what does everyone get wrong?
> > OpenAI’s API can’t pass back “thoughts” between calls (unless you DIY)
> > Anthropic API can, but almost nobody uses it right for anything but Claude
> > people deploy M2 with old habits
> > prior reasoning state gets yeeted
> > agent memory reset to “potato” every turn
> > so your carefully-laid plan dissolves, model acts random, output gets trashy
> > users: “model bad!”
> > reality: “your infra bad!”
> 
> > what happens if you do it right?
> > preserve all that sweet reasoning between steps
> > agent keeps building on itself
> > reliability, planning, sample efficiency skyrocket
> > you get actual multi-step intelligence
> > benchmarks:
> > SWE-Bench 69.4 vs 67.2 (+3.3%)
> > Tau^2 87 vs 64 (+35.9%)
> > BrowseComp 44.0 vs 31.4 (+40.1%)
> > GAIA 75.7 vs 67.9 (+11.5%)
> > xBench 72.0 vs 66.0 (+9.1%)
> > “forgetful agent” is now a solved problem (if you bother to solve it)
> 
> > how to actually do it?
> > use MiniMax’s OpenAI-compatible API
> > look for reasoning_details: keep it, send it back next call
> > chain never breaks
> > or use Anthropic-compatible API
> > just keep appending the whole thinking block to your message history, send it in next call
> > it’s not hard, you just have to care
> 
> > why push for this?
> > agent infra needs to grow up
> > unified “interleaved thinking” protocol is next-gen agent standard
> > one API, one method, every agent actually smart
> > community wins, AI gets less dumb
> 
> > want more information?
> > check the official MiniMax API
> > see docs, grab code samples
> > stop running LLMs with amnesia
> > start building agents that remember, reflect, and improve
> > the future is chained, not stateless

[→ View quote tweet](https://x.com/TheAhmadOsman/status/1985598503872065637)

