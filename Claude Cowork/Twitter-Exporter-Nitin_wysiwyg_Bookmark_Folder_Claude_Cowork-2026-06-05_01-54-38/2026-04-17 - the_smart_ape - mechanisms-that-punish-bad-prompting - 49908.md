---
title: "mechanisms that punish bad prompting"
author: "The Smart Ape 🔥"
username: "@the_smart_ape"
date: "2026-04-17"
tweet_url: "https://x.com/the_smart_ape/status/2045070676063649908"
tweet_type: "original"
likes: 744
retweets: 81
replies: 24
bookmarks: 2365
views: 999811
has_media: false
extraction_quality: full
article_id: "2045033678791716864"
tags: ["twitter-bookmark", "claude", "agents"]
---

# mechanisms that punish bad prompting

> **Source:** [@the_smart_ape](https://x.com/the_smart_ape) · 2026-04-17 · 👍 744 · 💬 24 · 🔖 2365 · 👁 999811

> 🔗 [View tweet on X](https://x.com/the_smart_ape/status/2045070676063649908)

## Article Content

opus 4.7 dropped yesterday. everyone is excited about it, but the ones who actually tested it are noticing real changes, and not all of them go in the right direction.

if you use it like opus 4.6, your results will be worse. and more expensive.

https://x.com/SuhailKakar

****Suhail Kakar****

@SuhailKakar

·

[Apr 16](https://x.com/SuhailKakar/status/2044788114628264281)

ANTHROPIC HAS RELEASED OPUS 4.7!!

i asked claude opus 4.7 to refactor a large codebase. 68 minutes, millions of tokens burned - it finished

nothing worked. app completely broken

but god it was beautiful

https://x.com/SuhailKakar/status/2044788114628264281/photo/1

yeah i know it sounds insane. new model, better benchmarks, higher-res vision, self-verification, +13% on coding tasks, how can it produce worse outputs than the old one?

because 4.7 isn't a better 4.6. it's a different product with a different logic. the design choices anthropic made this time actively penalize vague, lazy prompts on purpose.

if you prompt 4.7 the way you prompted 4.6, you'll pay a tax, in money, in quality, or both. this article will show you how to fix this.

## mechanisms that punish bad prompting

### temperature, top_p, top_k

literally. set any non-default value on these sampling parameters in the api, and the request fails.

for non-devs: these are the knobs that let you make a model more "creative" (high temperature) or more deterministic (temperature=0). for years people used temperature=0 as a default, same prompt, same output, no surprises. it was the duct tape that held sloppy prompts together.

https://x.com/the_smart_ape/article/2045070676063649908/media/2045040059980660736

anthropic removed the duct tape. if your prompt is ambiguous, you can't stabilize the output with sampling anymore. you prompt precisely, or you get variance you can't control.

https://x.com/the_smart_ape/article/2045070676063649908/media/2045046709244526592

every codebase hardcoding temperature: 0 on the anthropic api is broken on 4.7 right now.

### extended thinking budgets are gone.

adaptive thinking is the only mode.

before: you could tell the model "think for at most N tokens." cost ceiling, predictable.

now: the model decides how long to think. and it thinks longer when your prompt is ambiguous.

https://x.com/the_smart_ape/article/2045070676063649908/media/2045047080352428033

so a vague prompt makes the model overthink trying to reconstruct what you meant. you pay for that reasoning. you can't cap it. imprecision is now directly priced in.

### xhigh effort is the new default on every plan

claude code used to default to "high" effort. on 4.7 it defaults to "xhigh" across pro, max, teams, and enterprise, more thinking tokens, higher cost, slightly better output on average.

https://x.com/the_smart_ape/article/2045070676063649908/media/2045047577196843008

which means every ambiguous prompt now costs more than it did yesterday. the baseline price of imprecision went up overnight, even before you touch anything.

### task budgets

the agent now watches a clock on your prompt.

https://x.com/the_smart_ape/article/2045070676063649908/media/2045048114046717952

a task budget tells claude roughly how many tokens to spend across a full agentic loop, thinking, tool calls, tool results, final output. it's not a hard cap; the model sees a running countdown and uses it to prioritize and "finish the task gracefully as the budget is consumed."

here's the trap. if your prompt is fuzzy, the model spends early budget trying to figure out what you mean instead of doing the work. by the time it focuses, the countdown is low, output gets rushed or truncated.

the docs literally warn: "if the model is given a task budget that is too restrictive for a given task, it may complete the task less thoroughly or refuse to do the task entirely."

the "throw an agent at it and pray" era is over. imprecision doesn't blow through the budget, it eats the budget upfront, before any real work happens.

### more literal instruction following

the model will NOT guess what you meant.

this one is the least flashy and the most important. straight from the official docs, in the "Behavior changes" section:

https://x.com/the_smart_ape/article/2045070676063649908/media/2045049159548334080

older claude versions filled in the blanks. if you asked for "a summary" without specifying format or length, the model picked something reasonable. 4.7 won't. it does exactly what you said, and if what you said was incomplete, what you get back is incomplete.

this is the punishment you'll feel without noticing. the output will technically match your prompt. it just won't match your intent, because you didn't spell out your intent, and the model has stopped covering for you.

### the pattern

look at these five changes together. they all push in one direction: the cost of imprecision went up.

removed: the knobs that let you paper over bad prompts.

added: cost multipliers that scale with how ambiguous your input is.

enforced: a model that takes your prompt literally without interpretation.

anthropic converted prompt ambiguity into revenue. the imprecise now pay, in dollars, in output quality, or both. 4.7 is less a model upgrade than a repricing of your prompting habits.

## how to stop being punished

good news: the fix is mostly free if you're willing to change habits.

here's what to actually do:

- api parameters, updated defaults
- omit temperature, top_p, top_k entirely from your requests. don't set them to defaults, remove them. any value triggers a 400.
- turn thinking off for short tasks: classification, extraction, formatting, simple rewrites, tagging. adaptive thinking is overkill when there's nothing to reason about, and it's the biggest single source of invisible cost bleed on 4.7.
- keep thinking on for: coding, multi-step reasoning, anything with trade-offs or ambiguity. this is where 4.7 earns its price
- set task budgets explicitly on anything agentic. a decent starting rule: 2–3x the tokens a competent human engineer would need to do the task themselves. if the model burns through that budget, your prompt is the problem, not the model.
- drop effort from xhigh to medium or low on trivial tasks. stop paying xhigh prices to summarize an email. xhigh is the right default for hard work, not for all work.

https://x.com/the_smart_ape/article/2045070676063649908/media/2045051571600310272

## how to prompt

### coding / engineering

be explicit about: the language and framework, the style or pattern expected, the tests or acceptance criteria, and, critically, what the model should NOT do.

instead of: "write a function to parse dates." try: "write a python function using dateutil that parses iso 8601 and us date formats, raises valueerror on ambiguous input, never falls back to today's date."

the second one takes twenty extra seconds to write. it saves you fifty dollars in token waste and three iterations.

https://x.com/the_smart_ape/article/2045070676063649908/media/2045052503679483904

### analysis / reasoning

don't over-structure the reasoning itself, adaptive thinking is good at that. DO frame the output: who is this for, what decision does it inform, what format should it take, how long should it be.

the model can reason. it can't read your mind about what you'll do with the output.

agentic workflows (claude code, autonomous agents)

non-negotiable checklist:

- task budget set explicitly
- step-by-step plan in the system prompt
- stop criteria defined ("stop when tests pass" beats "stop when done")
- fallbacks defined ("if you can't find x, return y, don't guess")

4.7 agents without these will eat your budget and hand you mush.

https://x.com/the_smart_ape/article/2045070676063649908/media/2045053606064209920

### creative / writing

paradoxically, this is where 4.7 is most forgiving. you can be looser with structure. but you still need: style references, tone examples, and a clear point of view.

"write a creative post about xxxx" gets you corporate pablum. "write like a pissed-off senior engineer who's tired of hearing about prompt engineering" gets you something worth posting.

### long-context / rag

pre-structure your documents with clear anchors. tell the model which sections to prioritize. require citations in the instructions, not just the output format. 4.7's self-verification will silently downweight shaky sources if you let it, make that explicit instead of hoping.

## the 4.6 → 4.7 migration checklist

before you send a prompt to 4.7, ask:

1. is my intent explicit, or am i hoping the model guesses?

2. have i stated what success looks like?

3. have i listed constraints, not just desires?

4. for agents: task budget and stop criteria set?

5. have i removed temperature, top_p, top_k from my api call?

five yeses = you're getting 4.7's actual upside. anything less = you're paying the tax.

https://x.com/the_smart_ape/article/2045070676063649908/media/2045055256728305664

## the bigger point

there's a story the industry has been telling since chatgpt: "natural language is the new programming." no skills required. anyone can use ai.

opus 4.7 just renegotiated that deal. the new message: speak our dialect, or pay the ambiguity tax.

this will upset people. it should. "democratization" was the promise. now the best prompt engineer isn't the person with the fanciest tricks, it's the one who knows what they want before they ask.

4.7 is a contract change.

the ones who adapt win on both quality and cost. the ones who don't will blame the model.

it's not the model. it's you. that's the whole point.

> 📄 Original article URL: https://x.com/i/article/2045033678791716864

