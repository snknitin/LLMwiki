---
title: "The dirty secret of RL on LLMs"
author: "Akshay 🚀"
username: "@akshay_pachaar"
date: "2026-04-30"
tweet_url: "https://x.com/akshay_pachaar/status/2049916107923034300"
tweet_type: "original"
likes: 323
retweets: 37
replies: 5
bookmarks: 573
views: 93897
has_media: false
extraction_quality: full
article_id: "2049896113206149120"
tags: ["twitter-bookmark", "llm", "agents"]
---

# The dirty secret of RL on LLMs

> **Source:** [@akshay_pachaar](https://x.com/akshay_pachaar) · 2026-04-30 · 👍 323 · 💬 5 · 🔖 573 · 👁 93897

> 🔗 [View tweet on X](https://x.com/akshay_pachaar/status/2049916107923034300)

## Article Content

A team at Berkeley beat GRPO by 10 points with 35× fewer rollouts and no GPU training, and why most teams are still doing prompt optimization the wrong way.

You spent two weeks fine-tuning an 8B model with GRPO. Burned $40,000 in compute. Got a 7-point bump on your benchmark.

A team at Berkeley ran a different optimizer on the same setup. Spent under $1,000. Beat your score by 10 points.

No weight updates. No GPUs. Just prompts.

That's GEPA. The paper dropped in July 2025. Nine months later, it was accepted as an ICLR 2026. DSPy made it a first-class optimizer. Hugging Face and OpenAI shipped cookbooks. Shopify's CEO publicly said it's underhyped.

If you skipped GEPA when it came out, this is your second chance.

Let's break down why it works and how to use it in DSPy.

## The dirty secret of RL on LLMs

Here's the thing nobody tells you about reinforcement learning on language models.

Every rollout your agent produces is a 5,000-token document, containing:

- Reasoning steps
- Tool calls
- Self-corrections
- Compiler errors
- Judge rationales

Rich, structured, full of useful information.

GRPO takes all of that and reduces it to a single number.

Was this trajectory better or worse than the group average? +1 or -1. That's your learning signal.

You just threw away thousands of bits of structured information so you could backprop on one bit per trajectory. Then you wonder why RL needs tens of thousands of rollouts to converge.

****The signal isn't sparse. You made it sparse.****

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049898590353649664

## What if the signal could read itself?

Here's the GEPA bet in one sentence: the rollout is already a natural language artifact, so let an LLM read it.

Don't reduce the trace to a number. Hand it to a reflection model along with the failure mode, and ask: "What went wrong here, and how should the prompt change?"

The reflection model writes a new prompt. You test it. If it improves, keep it.

That's the entire core idea.

The rest is engineering details that make it work at scale.

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049899437955461120

## What GEPA actually optimizes

GEPA targets compound AI systems. Think [DSPy](https://dspy.ai/)

 programs.

A pipeline of LLM modules with their own prompts, glued together by Python control flow. A multi-hop QA agent might have:

- A first-hop query writer
- A retriever
- A summarizer
- A second-hop query writer
- A final answerer

Each module has a prompt. GEPA evolves all of them.

The optimization target is simple: maximize expected metric on your task, subject to a rollout budget B. The novelty is in how you spend that budget.

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049901403041300480

## The feedback function: where the magic lives

GEPA replaces your scalar metric with a feedback function μ_f. Same score, plus a natural language description of what happened.

- For HotpotQA, μ_f returns which gold docs you retrieved and which you still need.
- For instruction-following, it returns per-constraint pass/fail descriptions.
- For code generation, it returns the actual compiler errors and profiler traces.
- For privacy-preserving rewriting, it splits the score into quality and PII-leakage with breakdowns.

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049901751726419968

## The algorithm in six steps

Each iteration of the main loop does this:

1. ****Pick a candidate prompt set**** from the population (Pareto sampling, more on this below)
2. ****Pick a module**** to mutate (round-robin across modules)
3. ****Sample 3 examples**** from the training set
4. ****Run rollouts**** and collect full traces plus feedback from μ_f
5. ****Reflect****: feed traces and feedback to a reflection LLM, get a new prompt
6. ****Accept or reject****: rerun on the same 3 examples. If better, keep it. If not, discard.

Repeat until budget runs out. Return the best candidate.

That's it. No gradients. No PPO. No KL penalties.

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049902315994554368

## GEPA vs GRPO, head to head

A quick look at GRPO first:

![](https://pbs.twimg.com/amplify_video_thumb/2049903579922882560/img/XHWIF1Yo5fazdTVg.jpg)

Both take feedback and improve a system. That's where the similarity ends.

GRPO updates model weights with policy gradients on scalar rewards. GEPA updates prompts with natural language reflection on full traces.

Two completely different approaches.

Here's the side-by-side:

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049902866354356224

****One important caveat.**** GRPO can change what your model knows. GEPA can only change how you ask it.

If your base model can't do the task at all, no prompt evolution will save you. Fine-tune when you need new capabilities. Use GEPA when you need to extract more from what's already there.

## A real example

Let's make this concrete with a real example from the paper.

****The task:**** HotpotQA is a multi-hop question answering benchmark. You get a question that needs information from two different Wikipedia articles to answer. You can't find the answer in just one place.

Example question: "What is the population of the region containing the parish of São Vicente?"

To answer this, your agent has to:

1. ****First hop:**** Search for "São Vicente parish", retrieve a doc, learn it's in Madeira
2. ****Second hop:**** Search for "Madeira population", retrieve that doc, get the number
3. ****Answer:**** Combine both

The agent has separate modules for each hop. We're going to look at the prompt for the ****second-hop query writer****, the module that decides what to search for after the first retrieval.

****Inputs the module receives:****

- question: the original user question
- summary_1: a summary of what the first hop retrieved

****Output it produces:****

- query: the search query for the second hop

Here's the seed prompt that DSPy gives you by default:

> "Given the fields question, summary_1, produce the fields query."

Generic. Just describes the schema. Scores around 38% on validation.

GEPA runs this on a few examples and watches what happens. The query writer keeps doing the same thing wrong: it paraphrases the original question and retrieves the same documents it already had.

For our São Vicente example, given a summary about the parish, it would search "São Vicente parish population" again. Retrieves nothing new. Fails.

The reflection LLM sees this failure pattern across multiple examples in the trace. It writes a new prompt:

> "Generate a search query optimized for the second hop of multi-hop retrieval. The first-hop query was the original question, so first-hop docs already cover the entities mentioned directly. Your goal: retrieve documents NOT found in the first hop but necessary to answer completely. Avoid paraphrasing the original question. Target connected or higher-level entities mentioned in summary_1 but not explicitly in the question. Example: if summary_1 describes a parish but the question asks about the wider region's total population, your query should target the region, not the parish. So for a question about São Vicente's region, query 'Madeira archipelago population' rather than 'São Vicente population'."

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049906316223942657

New score: 69%.

Same model. Same task. The only thing that changed was the prompt for one module out of several.

Notice what happened. The reflection LLM didn't just rephrase the seed. It absorbed an actual strategy from observed failures:

- Don't paraphrase the question
- The first hop already covered the directly-mentioned entities
- Target the broader entity that connects them
- Here's a worked example of the pattern

That's the kind of information you cannot encode in a policy gradient. RL would just tell you "this trajectory was 0.3 below the group mean" and let backprop figure it out across thousands of tokens. GEPA writes the lesson down in plain English and ships it as the new prompt.

## Pareto selection: the move that makes it work

Here's where most evolutionary prompt optimizers die.

The naive approach: always mutate from the best candidate so far. Sounds reasonable. Collapses to local optima fast.

GEPA uses something smarter, borrowed from quality-diversity optimization.

Imagine three candidate prompts and four tasks:

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049907117021376513

Greedy picks C every time. C has the best average.

But A is the only one that handles Task 1 well. B is the only one that nails Task 2. If you only ever mutate from C, you lose those strategies forever.

Pareto selection keeps anyone who's best at at least one task. Then it samples parents weighted by how many tasks they win. So C is most likely to be picked, but A and B stay in the pool. Their distinctive strengths can later be combined with C's.

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049907373276635136

This single design choice is what separates GEPA from earlier evolutionary prompt methods.

## Where GEPA fits in the landscape

Quick map of who does what:

- ****APE, OPRO****: LLM-as-optimizer, single prompt, scalar feedback. Older generation.
- ****EvoPrompt, Promptbreeder****: Evolutionary, single prompt, scalar fitness. Genetic structure but no reflection.
- ****Reflexion****: Verbal feedback, but per-task memory rather than population evolution.
- ****TextGrad****: Textual gradients that propagate through computation graphs. No population.
- ****MIPROv2****: Bayesian search over instructions plus bootstrapped few-shot demos. DSPy's prior flagship.
- ****GRPO****: Actual RL with weight updates. Different beast entirely.

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049907804757196800

GEPA is the synthesis. Reflection from Reflexion. Population evolution from EvoPrompt. Compound system focus from MIPROv2. Pareto selection that's genuinely new.

## Using it in DSPy

The API is one line different from MIPROv2:

```python
optimizer = dspy.GEPA(
    metric=metric_with_feedback,
    auto="medium",
    reflection_minibatch_size=3,
    candidate_selection_strategy="pareto",
    reflection_lm=dspy.LM("gpt-5", temperature=1.0, max_tokens=32000),
    use_merge=True,
    track_stats=True,
)
optimized = optimizer.compile(program, trainset=train, valset=val)
```

The catch: your metric function needs the right signature.

```python
def metric(gold, pred, trace=None, pred_name=None, pred_trace=None):
    # return dspy.Prediction(score=float, feedback=str)
```

Return a prediction with both a score and a feedback string. The feedback is what gets fed to the reflection LLM. Make it diagnostic. Make it specific.

If your feedback string is just "wrong answer", you're back to scalar territory and GEPA degrades to a slower MIPROv2.

If your feedback says "missed entity X, retrieved doc Y when gold was Z, format violation in step 3", GEPA flies.

## A 2026 reality check

The "beats RL" headline is real, but worth being precise about.

GEPA beats GRPO specifically. Not every RL method. The field has stopped framing this as GEPA vs RL and started framing it as GEPA and RL. The paper itself points to hybrid recipes like BetterTogether and mmGRPO as the natural next step.

The honest summary: reflection is far more sample-efficient than RL on compound systems. The two are increasingly combined, not pitted against each other.

One more nuance worth knowing. Decagon's March 2026 production ablations found that more data isn't always better with GEPA. ****20 to 100 examples often beats 500.**** The reflection loop overfits when you feed it too much.

Hermes agent uses GEPA for evolving skills, which helps it learn with you and getting better with time.

Counter-intuitive, but it tracks. GEPA learns from patterns in failures. With 50 well-chosen examples, the reflector sees clean signal. With 500, it starts chasing noise.

Use small, high-quality training sets. Don't assume scale helps.

## When to reach for what

If you're building a compound AI system today, here's the decision tree.

- ****Use GEPA when:**** You have a small training set, expensive rollouts, no access to weights, and a metric you can describe in words.
- ****Use GRPO when:**** You have abundant cheap rollouts, open weights, and a verifiable terminal reward.
- ****Use MIPROv2 when:**** You specifically need bootstrapped few-shot exemplars in your prompts.
- ****Use TextGrad when:**** Your computation graph is deep and you want explicit per-variable critique propagation.

For most practical compound-system work in 2026, GEPA is the default to try first.

RL isn't dead. It's just no longer the obvious answer when reading a rollout costs less than running ten thousand more.

https://x.com/akshay_pachaar/article/2049916107923034300/media/2049908232978849792

References:

- [https://arxiv.org/abs/2507.19457](https://arxiv.org/abs/2507.19457)
- [https://dspy.ai/api/optimizers/GEPA/overview/](https://dspy.ai/api/optimizers/GEPA/overview/)

Thanks for reading!

If you found it insightful, reshare with your network.

Find me →[@akshay_pachaar](https://x.com/@akshay_pachaar)

 ✔️

For more insights and tutorials on LLMs, AI Agents, and Machine Learning!

> 📄 Original article URL: https://x.com/i/article/2049896113206149120

---

## Commentary from Other Bookmarks

### @akshay_pachaar (Akshay 🚀) — 2026-05-01

> RL isn't always the right answer!
> 
> (Berkeley beat GRPO without a GPU)
> 
> Same task, same base model, 10 points higher on the benchmark.
> 
> The technique is called 𝗚𝗘𝗣𝗔. It came out of Berkeley in mid-2025, got accepted at ICLR 2026, and is now a first-class optimizer in DSPy.
> 
> The reason it works points at something most teams get wrong about reinforcement learning on language models.
> 
> Every team running agents in production is sitting on a pile of rollouts. A rollout is just one full run of your agent on a task, from the user query down to the final answer, with everything that happened in between.
> 
> Most teams have thousands of these traces and no real idea what to do with them beyond eyeballing a few when something breaks.
> 
> This is the part worth paying attention to. Each rollout is roughly a 5,000-token document containing reasoning steps, tool calls, compiler errors, and judge rationales. Rich, structured, and full of signal.
> 
> 𝗚𝗥𝗣𝗢 compresses all of that to +1 or -1, scalar reward signal.
> 
> That single bit gets back-propagated across every token in the policy. The information that told you what went wrong and where gets thrown away on the way to the gradient.
> 
> This is why RL needs tens of thousands of rollouts to converge. The signal was never sparse, the optimizer made it sparse.
> 
> 𝗚𝗘𝗣𝗔 reads the trace instead.
> 
> A reflection LLM ingests the full rollout, diagnoses the failure, localizes it to one module in the pipeline, and rewrites that module's prompt.
> 
> Same rollout, vastly more signal extracted. Weights become prompts, and opaque becomes readable.
> 
> This is also why GEPA shines on multi-module workflows. Most real agents are pipelines of several modules glued together, and GEPA lets you target the exact module you want to improve instead of nudging the whole system at once.
> 
> The honest framing is this. RL changes what the model knows, while GEPA changes how you ask.
> 
> If your base model genuinely can't do the task, no prompt evolution will save you and you should fine-tune.
> 
> But most of what teams currently route to GRPO is the second case, not the first. The model can already do it, and the prompt is the bottleneck.
> 
> Reading a rollout costs less than running ten thousand more.
> 
> If you want to go deeper, here's the paper and the DSPy implementation:
> 
> Paper: http://arxiv.org/abs/2507.19457
> GEPA in DSPy: http://dspy.ai/api/optimizers/GEPA/overview/
> 
> The article below is a deep dive into exactly how GEPA works. Do give it a read.

[→ View quote tweet](https://x.com/akshay_pachaar/status/2050114132515623168)

![](https://pbs.twimg.com/media/HHN2W_raMAAfaZz.jpg)

