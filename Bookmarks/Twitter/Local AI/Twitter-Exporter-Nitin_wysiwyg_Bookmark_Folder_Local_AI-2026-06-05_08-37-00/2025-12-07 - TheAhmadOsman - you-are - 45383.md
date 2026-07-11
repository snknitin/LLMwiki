---
title: "> you are"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2025-12-07"
tweet_url: "https://x.com/TheAhmadOsman/status/1997816634006745383"
tweet_type: "original"
likes: 132
retweets: 13
replies: 11
bookmarks: 144
views: 9720
has_media: false
tags: ["twitter-bookmark", "llm"]
---

# > you are

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2025-12-07 · 👍 132 · 💬 11 · 🔖 144 · 👁 9720

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/1997816634006745383)

## Tweet Content

> you are
> a person neck-deep in LLMs, wading through a sea of jargon
> “shards,” “experts,” “layers across nodes,” “tensor parallelism,”
> “pipeline parallelism,” “data parallelism”
> you keep hearing epic claims like
  > “8 million tokens/sec on 1024 GPUs”
  > and wonder, what the hell does that even look like on real hardware?
> we'll start with what “layers” even are,
> then walk the five parallelism axes,
> and then show how they combine

> is every GPU running a full copy of the model?
> or are the weights sharded across the cluster?
> are layers sliced up? what are “layers” to begin with?
  > a “layer” = attention + MLP + residual glue
  > ≈ a transformer block; then we stack 24 to 160 of them
  > more on that below
> do whole blocks migrate to different nodes?
> does the batch get carved into pieces?
> is the context length split? or both?
> when do all these devices need to chat with each other?
> and what are they sending?
> what’s an “expert” in a Mixture-of-Experts model?
> and why do people make it sound like air-traffic control for tokens?

> as LLMs got bigger, nothing fit on one GPU
> so parallelism became the only way out
> but the word “parallelism” hides a zoo of strategies
> each one optimized for a different kind of problem

> sometimes you duplicate the model for raw throughput
  > data parallelism
> sometimes you break each giant matrix multiply across devices
  > tensor/model parallelism
> sometimes you hand off entire layers to the next GPU
  > pipeline parallelism
> sometimes you dispatch tokens to “experts” scattered all over
  > expert parallelism
> and sometimes, when the context is massive
  > you even split the sequence itself

inference vs training? whole different beast
> inference:
  > cares about context length
  > key/value cache (KV cache)  size
  > serving tons of requests with minimal idle time
  > prefill vs decode become separate bottlenecks
> training:
  > wants big batches
  > needs fast gradient sync
  > huge memory for activations
  > relentless all-reduce ops

so, when you see those monster numbers and wild claims, ask:
> what’s split?
> what’s duplicated?
> what’s just being pipelined through?
> who’s doing all the talking?
  > GPUs?
  > CPUs?
  > or the people writing the framework hacks?

parallelism 101 isn’t just for LLM nerds
> it’s survival for anyone who wants to
  > train
  > fine-tune
  > or serve
> models bigger than a single graphics card
> and we’re gonna break it all down, once and for all

first, a quick recap of how LLMs work
> llms are giant next-token guessers
> feed in tokens, model returns probabilities for what comes next
> this is conditional modeling: p(x_{t+1} | x_{1:t}); all "reasoning" is just maximizing next-token prediction over long contexts
> parallelism pressure: high accuracy means bigger models, longer contexts; both shatter single-device limits

> inference: just a loop
> sample → append → feed back in; repeat until done
> really two stages: prefill (encode the prompt, attention-heavy) and decode (one token at a time, cache-heavy)
> parallelism pressure: prefill wants maximum compute in parallel; decode needs memory bandwidth and batching

> training: minimizes how wrong those guesses are
> cross-entropy loss between predicted and actual token
> scale up data, parameters, context → better loss, but optimizer states and gradients balloon memory usage
> parallelism pressure: gradient sync and optimizer memory dominate; communication overhead becomes a first-class problem

> inside the model: a tall stack of transformer blocks
> each processes a sequence of vectors (tokens → embeddings)
> all blocks edit a shared “residual stream”
> parallelism hint: deep? pipeline split; wide? tensor split

> each block does two things
> self-attention: mix info across tokens (global context)
> mlp: rewrite each token’s vector (local transform)
> this global-then-local alternates for dozens to hundreds of layers
> parallelism hint: attention is sequence-bottlenecked, MLPs are flop-bottlenecked; each wants its own split

> layernorm + residuals keep things stable
> helps gradients flow; most use pre-norm
> deep stacks become trainable, but activations stay huge
> parallelism hint: activation memory = batch × seq × hidden; target for sequence/context sharding and activation checkpointing

> self-attention = queries, keys, values
> dot-products score “who attends to whom”; softmax makes weights; multi-heads see different relationships
> compute is O(L²) during prefill, O(L) per token in decode
> parallelism hint: quadratic prefill drives context parallelism; big KV drives KV sharding

> to scale: GQA / MQA (grouped/multi-query attention)
> fewer key/value sets per head, saves bandwidth/memory
> tiny quality hit, huge efficiency win (at ≤128 k context; when tuned)
> smaller KV → more requests/longer contexts per GPU
  > rough rule: every extra 65k tokens at 70B costs ~2 GB/GPU even with GQA—yes, that adds up fast
> parallelism hint: makes tensor/data parallel more efficient with fixed memory

> position info: added or rotated
> learned embeddings or rotary encodings (RoPE)
> lets models generalize to longer sequences; RoPE directly encodes relative position in attention
> parallelism hint: long contexts make context/sequence parallelism indispensable

> mlp is the heavy lifter
> expand → activate → project down
> MoE = many mlps, only a few active per token; scale params without scaling compute, but adds network overhead
> dense MLPs dominate FLOPs; MoE swaps dense compute for routing and all-to-all comms
> parallelism hint: dense → tensor/pipeline, MoE → expert parallel + token shuffling

> top of the model: one last layernorm, then lm head
> maps hidden states to vocab logits; often reuses input embedding weights
> weight tying helps parameter and cache efficiency
> parallelism hint: LM head is another big matmul; follows tensor/pipeline split of previous layers

> decoding: pick a sampler
> greedy, temp, top-k/p, beam, speculative; just ways to choose the next token
> speculative/batch schedulers keep GPUs busy
> parallelism hint: data parallel absorbs throughput, tensor/context sharding fights latency for long prompts

> alignment (rlhf, dpo, etc.): guide preferences
> tweaks outputs, core compute is unchanged
> fine-tunes shift sampling tendencies, not compute graph
> parallelism hint: training still needs gradient sync, same memory/comm bottlenecks

> systems view: 95% is big matrix multiplies (gemms)
> rest is cheap elementwise ops
> hardware lives or dies by gemm performance
> memory bandwidth, interconnect, and collectives (all-reduce/all-to-all) are the real ceilings
> parallelism hint: pick the axis that minimizes your dominant comms pattern

> two compute phases:
> prefill: quadratic attention, load whole prompt
> decode: one token at a time, kv cache is bottleneck
> kv cache per layer ≈ (B × L × 2 × n_kv × d_head × bytes); multiply by layers = why memory vanishes
> parallelism hint: prefill likes context/sequence sharding, decode likes batching and kv sharding

> why split the model at all? simple concept, ugly in practice:
  > VRAM runs out
  > bandwidth bottlenecks
  > FLOPS max out
> only way out: parallelism
> weights, work, and state are each huge; but for different reasons
  > and each one pushes you toward a different split axis

parallelism 101
> single GPU:
  > can’t hold the weights
  > can’t fit the KV cache
  > doesn’t have enough compute
> doesn’t scale to real LLMs
> goal:
  > break up the compute
  > split the memory
  > keep every GPU doing something useful
  > avoid idle cycles and bottlenecks

tensor parallelism (TP)
> step up: model is too big, so shard within layers (split big matmuls/attn heads across GPUs)
> for inference:
  > single prompt can use all TP devices; shard weights and KV cache across GPUs
  > unlocks longer context/one-shot mega-prompts (because each GPU only needs its chunk)
  > minimal latency penalty; comms are per-token and per-layer, but hidden in GEMM (if intra-node NVLink)
  > first thing you do when the model won’t fit in one GPU but you want max single-query performance
> for training:
  > you split GEMMs (e.g., QKV/MLP) across N devices; everyone computes a slice, then you all-reduce at the end of the layer
  > comms: ~2 all-reduce ops per layer forward/backward
  > all math, no waiting for whole layers to finish
  > works best when all GPUs on fast local links (NVLink/NVSwitch), otherwise, you’re bottlenecked
  > pair with “sequence parallelism” (SP): shard along sequence axis for even bigger speedups/memory wins
> rule: TP is your go-to for splitting big layers/weights/KV; always keep it intra-node if you can

pipeline parallelism (PP)
> think “assembly line”: split the model by layers into stages, put each stage on a GPU (or group)
> for inference:
  > each token passes through the pipeline (latency = num_stages × per-stage time)
  > adds overhead for low concurrency (pipeline bubbles)
  > but: lets you split very tall models across more GPUs (and multiple nodes)
  > often combined with TP (per stage) + DP (across nodes)
> for training:
  > feed microbatches in like cars on a factory line
  > early GPUs start on batch N+1 while late GPUs are still finishing batch N
  > scheduling: “1F1B” (one-forward-one-backward) is classic, interleaved is better (reduces bubbles, keeps more cards hot)
  > comms: point-to-point; just send activations/gradients to the next/prev stage
  > fills/drains pipeline at start/end, so latency is worse for small batches
> rule: use PP when model depth > what fits per device/group; throughput wins, single-token latency suffers

data parallelism (DP)
> start simple: every GPU/node gets a full copy of the model
> for inference: each replica can serve requests independently; easy throughput scaling, zero comms
  > but: each replica needs its own KV cache; you burn VRAM linearly with batch count
> for training: each works on a different chunk of the data, then they sync gradients (all-reduce)
  > memory: each replica has full weights, grads, optimizer state
  > comms: one big all-reduce per step (bottleneck: slow interconnect or huge models)
  > modern fix: ZeRO/FSDP; shard optimizer states, grads, even params across devices
    > ZeRO-3: sharded everything; now any one GPU sees a fraction of the model/optimizer
    > lets you squeeze 100B+ params onto commodity hardware
> rule: DP is how you get more throughput; for bigger models, combine with model parallelism

expert parallelism (EP, MoE)
> Mixture of Experts (MoE): only some parameters get used per token; rest sleep, save FLOPs
> for inference:
  > tokens routed to experts (ideally local); all-to-all overhead dominates small batch serving unless you get smart with locality/routing
  > top-1 routing + local experts is the new meta; keeps network from killing tail latency
  > MoE good for “big brain, small budget”; huge capacity, modest compute, but only if you nail the routing and don’t bottleneck network
> for training:
  > “experts” (sub-MLPs) spread across GPUs; router sends each token to top-1/2/4 experts
  > comms: two big all-to-all shuffles per MoE layer (tokens to experts, then back)
  > modern tricks: Expert-Choice, dropless routing, hierarchical shuffles; less network pain, better load balance
  > only the selected experts do work, so you scale parameter count without scaling compute linearly
  > parallelize: TED = Tensor × Expert × Data (often add Pipeline for 4D grid)
> rule: use EP to unlock parameter scaling beyond dense; just mind the network, and tune routing for your hardware

sequence/context parallelism (SP/CP)
> the bonus round: split the sequence axis, not just layers or weights
  > why: LLMs with 128k, 1M, or more context tokens = “KV cache and attention matrices are the new bottleneck”
> for inference/training:
  > shard activations/KV cache across sequence positions (instead of model dims or layers)
  > Megatron Context Parallelism, DeepSpeed-Ulysses, Ring-Attention: new tricks for linear scaling with context size
  > pairs well with TP/PP/EP, especially for long-context, high-concurrency serving
> rule: add SP/CP when context/KV cache eats your VRAM, or you want fast prefill for million-token prompts

putting it together: real-world layouts
> serving LLMs (inference)
  > model fits on one GPU? just use DP, batch requests, done
  > model too big? add TP (intra-node, 2-4 GPUs, shard weights/KV)
  > still too big? PP (split layers), then DP for multi-node throughput
  > long contexts? CP/SP (shard sequence/KV), paged attention, GQA/MQA to shrink KV
  > MoE? use EP, but always fight for local experts and top-1 routing
> training LLMs
  > start with DP (and ZeRO/FSDP) for throughput/memory relief
  > model too wide? add TP
  > model too deep? add PP, interleave for less pipeline bubble
  > MoE? grid up: TED (+ PP), tune batch/expert per device for best balance
  > context too big? SP/CP and activation checkpointing
  > always checkpoint activations if memory is tight; mix and match as needed

a quick bridge to parallelism (what each axis “fixes”):

> data parallelism (dp)
> replicate the whole model, split the batches
> fixes throughput and gradient noise, but not per-replica memory
> unless you also shard optimizer/params (e.g. ZeRO, FSDP)

> tensor (or model) parallelism (tp)
> shard within layers (split big matmuls/attn)
> fixes single-layer width/weight size and per-token compute;
> introduces per-layer collective ops

> pipeline parallelism (pp)
> shard across layers (depth)
> fixes total weight memory by spreading blocks across stages;
> introduces pipeline bubbles; hide with micro-batching

> expert parallelism (ep)
> shard MoE experts across devices, route tokens to a few experts
> fixes param count without dense compute; 
> introduces all-to-all comms and load-balancing.

> sequence/context parallelism (sp/cp)
> shard along the sequence axis
> fixes long-context prefill and kv memory by splitting tokens/devices;
> pairs well with tp and paged kv caches

systems cheat sheet: when to use what
> DP: for throughput and data sharding; ZeRO/FSDP to cut memory; inference just replicas
> TP: for single-model multi-GPU (shard big layers, weights, KV); keep within fast local links
> PP: for tall models (split by layer); more stages = more bubble, but necessary for true giants
> EP (MoE): for max params at fixed compute; tune routing and batch; network is the limiter
> SP/CP: for ultra-long context or when KV cache dominates; essential for 128k+ or high concurrency
> Combine: 3D, 4D, even 5D grids (e.g., TP×EP×DP×PP×SP) for trillion-param monsters

modern tricks
> paged attention, continuous batching (vLLM, TensorRT-LLM): unlock huge batch + context + utilization
> GQA/MQA: shrink KV cache and bandwidth, scale to long prompts
> context parallelism: finally scales prefill to dozens of GPUs for million-token demos
> interleaved pipelines: +10% throughput, almost free
> MoE: top-1 routing + expert-choice/hierarchical shuffling = practical at scale

keep this map in mind: always ask; what’s your bottleneck?
> weights, work, or state? 
> the right parallelism makes the big thing smaller,
> without making communication the new bottleneck

> you made it to the end
> now you know: every parallelism axis is a lever, not a panacea
> the real move is combining axes for your exact bottleneck; fit, throughput, context, or tail latency
> next time you see “we train at 8M tokens/sec on 1024 GPUs,” read between the lines: it’s all about how they split the problem

tl;dr: llms are simple, just brutal at scale
> hardware-aware optimization is survival
> the real skill is matching bottleneck to the right parallelism; otherwise you’re just moving the problem

