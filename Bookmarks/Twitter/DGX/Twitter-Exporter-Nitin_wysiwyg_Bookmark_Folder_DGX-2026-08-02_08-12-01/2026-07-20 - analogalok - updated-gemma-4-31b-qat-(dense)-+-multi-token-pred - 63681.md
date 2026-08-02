---
title: "Updated Gemma 4 31B QAT (dense) + Multi Token Prediction + a 1.3GB Vision Encoder + 110,000 Context...."
author: "Alok"
username: "@analogalok"
date: "2026-07-20"
tweet_url: "https://x.com/analogalok/status/2079212804809363681"
tweet_type: "quote"
likes: 272
retweets: 27
replies: 19
bookmarks: 316
views: 88937
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# Updated Gemma 4 31B QAT (dense) + Multi Token Prediction + a 1.3GB Vision Encoder + 110,000 Context....

> **Source:** [@analogalok](https://x.com/analogalok) · 2026-07-20 · 👍 272 · 💬 19 · 🔖 316 · 👁 88937

> 🔗 [View tweet on X](https://x.com/analogalok/status/2079212804809363681)

## Tweet Content

Updated Gemma 4 31B QAT (dense) + Multi Token Prediction + a 1.3GB Vision Encoder + 110,000 Context. Running locally at 60 t/s on a single NVIDIA RTX 4090.

Here is the exact llama.cpp stack to make multimodal VRAM limits obsolete.

Following up on the text only throughputs below, I compiled llama.cpp from source on Ubuntu 22 (CUDA 13) to see how much context we actually lose when loading the 1.3GB mmproj-F16.gguf alongside the main model and the MTP drafter.

Fed it a 28k token prompt + 1 image. Here is the breakdown:

# 1. The Pure Speed Run (Unquantized KV Cache)
The 1.3GB vision projector immediately eats into our VRAM, dropping our max context ceiling from 36k down to 20k (23.93 GB VRAM).

llama.cpp flags: 
./build/bin/llama-server -m gemma-4-31B-it-qat-UD-Q4_K_XL.gguf --mmproj mmproj-F16.gguf --spec-type draft-mtp --spec-draft-model mtp-gemma-4-31B-it.gguf --spec-draft-n-max 4 --spec-draft-p-min 0.7 -c 20000 -ngl 99 -fa on --port 8080 -v

Prefill: 1731.20 t/s | Decode: 78 t/s
(Still ridiculously fast, but a 20k context limit is tight for heavy document + image analysis).

# 2. The Mid Ground (Q8 KV Quantization)
Squeezed the cache to 8-bit. Context ceiling jumps to 58k (23.96 GB VRAM).

llama.cpp flags: 
./build/bin/llama-server -m gemma-4-31B-it-qat-UD-Q4_K_XL.gguf --mmproj mmproj-F16.gguf --spec-type draft-mtp --spec-draft-model mtp-gemma-4-31B-it.gguf --spec-draft-n-max 4 --spec-draft-p-min 0.7 -c 58000 -ngl 99 -fa on --cache-type-k q8_0 --cache-type-v q8_0 --port 8080 -v

Prefill: 2020.85 t/s | Decode: 64 t/s

# 3. The  Multimodal Tradeoff (Q4 KV Quant)

Dropped to 4-bit cache to push the absolute limits (23.97 GB VRAM - literally megabytes to spare).

llama.cpp command: 
./build/bin/llama-server -m gemma-4-31B-it-qat-UD-Q4_K_XL.gguf --mmproj mmproj-F16.gguf --spec-type draft-mtp --spec-draft-model mtp-gemma-4-31B-it.gguf --spec-draft-n-max 4 --spec-draft-p-min 0.7 -c 110000 -ngl 99 -fa on --cache-type-k q4_0 --cache-type-v q4_0 --port 8080 -v

Prefill: 2033.11 t/s | Decode: 60 t/s

By using the --mmproj flag to load the F16 vision encoder, we permanently lose about 1.3GB of our 24GB budget.

Text only Q4 (from previous post): 140k context @ 65 t/s

Multimodal Q4 (this test): 110k context @ 60 t/s

We sacrificed 30,000 tokens of context to give a 31B model flawless image recognition.

The fact that you can feed an image and a 100k+ codebase into a single RTX 4090 and get 60 t/s back is a paradigm shift for local multimodal agents.

Hugging Face links to the updated Unsloth's QAT quants with vision projectors, and performance graph are in the replies below.

If you haven't been following my previous posts, google recently patched the chat templates of gemma 4 family of models to improve tool calling. The agentic reasoning gains on the benchmark charts are massive:

- TB2 (Agents): +4.5% (to 25.8%) 
- Tau2 (Telecom): +10.1% (to 62.7%)

What are you building with local vision models right now? which models are you running on your single rtx 3090, 4090 or other 24 GB VRAM nodes?

## Media

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2079211786092658688/img/IkdB_QZJvUqn6-rc.jpg)

**Video:** [▶ Watch](https://video.twimg.com/amplify_video/2079211786092658688/vid/avc1/1920x1080/7k2Daf9-Z677QA6B.mp4?tag=29) (duration: 20s)

⚠️ Video content — see [[MEDIA-REVIEW]] for full list.

---

## Commentary from Other Bookmarks

### @analogalok (Alok) — 2026-07-27

> If you thought the Gemma 4 31B (dense) model was fast, sit down. I just benched the updated Gemma 4 26B A4B MoE on a single RTX 4090 (24 GB VRAM)
> 
> 9,200 t/s prefill. 160 t/s decode. 250,000 context window. All on a single consumer RTX 4090. The numbers are completely unhinged.
> 
> The 31B is a dense behemoth. But the 26B is a Mixture of Experts (MoE), specifically an Active 4 Billion (A4B). It holds 26B parameters of knowledge but only activates 4B per token. Because its inference memory footprint is so light, I didn’t even need KV cache quantization to hit a quarter million context.
> 
> Compiled the latest llama.cpp from source on Ubuntu 22 (CUDA 13). Fed it a 28k token prompt, and manually cranked the batch sizes (-b 2048 -ub 2048) to absolutely redline the Tensor Cores.
> 
> Here is the benchmarking breakdown:
>  
> # 1. The Baseline (No MTP)
> Even without speculative decoding, the A4B architecture flies.
> 
> llama.cpp flags:
> ./build/bin/llama-server -m gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf -c 250000 -ngl 99 -fa on -b 2048 -ub 2048 --port 8080 -v
> 
> Context Ceiling: 250,000 tokens (21.5 GB VRAM)
> Prefill: 9,200 t/s (Absurd)
> Decode: 124 t/s
> 
> # 2. The MTP Overdrive
> Injected the new MTP draft model to enable Speculative Decoding.
> 
> llama.cpp flags: 
> ./build/bin/llama-server -m gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf --spec-type draft-mtp --spec-draft-model mtp-gemma-4-26B-A4B-it.gguf --spec-draft-n-max 4 --spec-draft-p-min 0.7 -c 250000 -ngl 99 -fa on -b 2048 -ub 2048 --port 8080 -v
> 
> Context Ceiling: 250,000 tokens (22.96 GB VRAM)
> Prefill: 7,054 t/s (MTP draft overhead slightly caps prefill)
> Decode: 156 t/s
> 
> # The Agentic Architecture Insight
> Why does this matter? Because you can now build a killer local agentic loop on a consumer desktop.
> Use the 31B dense model (from the previous post) as your heavy, deliberate Orchestrator / Verifier / Planner.
> Pass the actual execution tasks to this 26B MoE.
> 
> At 160 t/s, this MoE can chew through code generation, tool calling, and massive RAG document retrieval over a 250k context window almost instantly, drastically speeding up your agentic loop.
> 
> If you own a single RTX 3090 or 4090 and haven't tried this specific stack yet, you need to pull these latest updates and run it. Local inference just leveled up.
> 
> Hugging Face links to the Unsloth 26B QAT quants and MTP drafters are in the replies. performance graphs also available in the replies.

[→ View quote tweet](https://x.com/analogalok/status/2081741327398826154)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

