---
title: "- local llms 101"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2025-12-21"
tweet_url: "https://x.com/TheAhmadOsman/status/2002825756938752234"
tweet_type: "original"
likes: 222
retweets: 23
replies: 11
bookmarks: 308
views: 15927
has_media: false
tags: ["twitter-bookmark", "llm"]
---

# - local llms 101

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2025-12-21 · 👍 222 · 💬 11 · 🔖 308 · 👁 15927

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/2002825756938752234)

## Tweet Content

- local llms 101

- tired of guides that just tell you to run a script and call it a day?
- want to actually know what your GPU is doing, not just trust a black box?
- here's what really happens when you run a local LLM
- what gets loaded, why, and how it all fits together
- no gatekeeping, just the real explanations nobody gives you
- the elite don't want you to know this

- running a model = inference (using model weights)
- inference = predicting the next token based on your input plus all tokens generated so far
- together, these make up the "sequence"

- tokens ≠ words
- they're the chunks representing the text a model sees
- they are represented by integers (token IDs) in the model
- "tokenizer" = the algorithm that splits text into tokens
- common types: BPE (byte pair encoding), SentencePiece
- token examples:
- "hello" = 1 token or maybe 2 or 3 tokens
- "internationalization" = 5–8 tokens
- context window = max tokens model can "see" at once (2K, 8K, 32K+)
- longer context = more VRAM for KV cache, slower decode

- during inference, the model predicts next token
- by running lots of math on its "weights"
- model weights = billions of learned parameters (the knowledge and patterns from training)

- model parameters: usually billions of numbers (called weights) that the model learns during training
- these weights encode all the model's "knowledge" (patterns, language, facts, reasoning)
- think of them as the knobs and dials inside the model, specifically computed to recognize what could come next
- when you run inference, the model uses these parameters to compute its predictions, one token at a time

- every prediction is just: model weights + current sequence → probabilities for what comes next
- pick a token, append it, repeat, each new token becomes part of the sequence for the next prediction

- models are more than weight files
- neural network architecture: transformer skeleton (layers, heads, RoPE, MQA/GQA, more below)
- weights: billions of learned numbers (parameters, not "tokens", but calculated from tokens)
- tokenizer: how text gets chunked into tokens (BPE/SentencePiece)
- config: metadata, shapes, special tokens, license, intended use, etc
- sometimes: chat template are required for chat/instruct models, or else you get gibberish
- you give a model a prompt (your text, converted into tokens)

- models differ in parameter size:
- 7B means ~7 billion learned numbers
- common sizes: 7B, 13B, 70B
- bigger = stronger, but eats more VRAM/memory & compute
- the model computes a probability for every possible next token (softmax over vocab)
- picks one: either the highest (greedy) or
- samples from the probability distribution (temperature, top-p, etc)
- then appends that token to the sequence, then repeats the whole process
- this is generation:
- generate; predict, sample, append
- over and over, one token at a time
- rinse and repeat
- each new token depends on everything before it; the model re-reads the sequence every step

- generation is always stepwise: token by token, not all at once
- mathematically: model is a learned function, f_θ(seq) → p(next_token)
- all the "magic" is just repeating "what's likely next?" until you stop

- all conversation "tokens" live in the KV cache, or the "session memory"

- so what's actually inside the model?
- everything above-tokens, weights, config-is just setup for the real engine underneath

- the core of almost every modern llm is a transformer architecture
- this is the skeleton that moves all those numbers around
- it's what turns token sequences and weights into predictions
- designed for sequence data (like language),
- transformers can "look back" at previous tokens and
- decide which ones matter for the next prediction

- transformers work in layers, passing your sequence through the same recipe over and over
- each layer refines the representation, using attention to focus on the important parts of your input and context
- every time you generate a new token, it goes through this stack of layers-every single step

- inside each transformer layer:
- self-attention: figures out which previous tokens are important to the current prediction
- MLPs (multi-layer perceptrons): further process token representations, adding non-linearity and expressiveness
- layer norms and residuals: stabilize learning and prediction, making deep networks possible
- positional encodings (like RoPE): tell the model where each token sits in the sequence
- so "cat" and "catastrophe" aren't confused by position

- by stacking these layers (sometimes dozens or even hundreds)
- transformers build a complex understanding of your prompt, context, and conversation history

- transformer recap:
- decoder-only: model only predicts what comes next, each token looks back at all previous tokens
- self-attention picks what to focus on (MQA/GQA = efficient versions for less memory)
- feed-forward MLP after attention for every token (usually 2 layers, GELU activation)
- everything's wrapped in layer norms + linear layers (QKV projections, MLPs, outputs)
- residuals + norms = stable, trainable, no exploding/vanishing gradients
- RoPE (rotary embeddings): tells the model where each token sits in the sequence
- stack N layers of this → final logits → pick the next token
- scale up: more layers, more heads, wider MLPs = bigger brains

- VRAM: memory, the bottleneck
- VRAM must must fit:
1. weights (main model, whether quantized or not)
2. KV cache (per token, per layer, per head)
- weights:
- FP16: ~2 bytes/param → 7B = ~14GB
- 8-bit: ~1 byte/param → 7B = ~7GB
- 4-bit: ~0.5 byte/param → 7B = ~3.5GB
- add 10–30% for runtime overheads
- KV cache:
- rule of thumb: 0.5MB per token (Llama-like 7B, 32 layers, 4K tokens = ~2GB)
- some runtimes support KV cache quantization (8/4-bit) = big savings

- throughput = memory bandwidth + GPU FLOPs + attention implementation (FlashAttention/SDPA help) + quantization + batch size
- offload to CPU? expect MASSIVE slowdown

- GPU or bust: CPUs run quantized models (slow), but any real context/model needs CUDA/ROCm/Metal
- CPU spill = sadness (check device_map and memory fit)

- quantization: reduce precision for memory wins (sometimes a tiny quality hit)
- FP32/FP16/BF16 = full/floored
- INT8/INT4/NF4 = quantized
- 4-bit (NF4/GPTQ/AWQ) = sweet spot for most consumer GPUs (big memory win, small quality hit for most tasks)
- math-heavy or finicky tasks degrade first (math, logic, coding)

- KV cache quantization: even more memory saved for long contexts (check runtime support)

- formats/runtimes:
- PyTorch + safetensors: flexible, standard, GPU/TPU/CPU
- GGUF (llama.cpp): CPU/GPU/portable, best for quant + edge devices
- ONNX, TensorRT-LLM, MLC: advanced flavors for special hardware/use
- protip: avoid legacy .bin (pickle risk), use safetensors for safety

- everything is a tradeoff
- smaller = fits anywhere, less power
- more context = more latency + VRAM burn
- quantization = speed/memory, but maybe less accurate
- local = more control/knobs, more work

- what happens when you "load a model"?
- download weights, tokenizer, config
- resolve license/trust (don't use trust_remote_code unless you really trust the author)
- load to VRAM/CPU (check memory fit)
- warmup: kernels/caches initialized, first pass is slowest
- inference: forward passes per token, updating KV cache each step

- decoding = how next token is chosen:
- greedy: always top-1 (robotic)
- temperature: softens or sharpens probabilities (higher = more random)
- top-k: pick from top k
- top-p: pick from smallest set with ≥p prob
- typical sampling, repetition penalty, no-repeat n-gram: extra controls
- deterministic = set a seed and no sampling
- tune for your use-case: chat, summarization, code

- serving options?
- vLLM for high throughput, parallel serving
- llama.cpp server (OpenAI-compatible API)
- ExLlama V2/V3 w/ Tabby API (OpenAI-compatible API)
- run as a local script (CLI)
- FastAPI/Flask for local API endpoint

- local ≠ offline; run it, serve it, or build apps on top

- fine-tuning, ultra-brief:
- LoRA / QLoRA = adapter layers (efficient, minimal VRAM)
- still need a dataset and eval plan; adapters can be merged or kept separate
- most users get far with prompting + retrieval (RAG) or few-shot for niche tasks

- common pitfalls
- OOM? out of memory. Model or context too big, quantize or shrink context
- gibberish? used a base model with a chat prompt, or wrong template; check temperature/top_p
- slow? offload to CPU, wrong drivers, no FlashAttention; check CUDA/ROCm/Metal, memory fit
- unsafe? don't use random .bin or trust_remote_code; prefer safetensors, verify source

- why run locally?
- control: all the knobs are yours to tweak:
- sampler, chat templates, decoding, system prompts, quantization, context
- cost: no per-token API billing-just upfront hardware
- privacy: prompts and outputs stay on your machine
- latency: no network roundtrips, instant token streaming

- challenges:
- hardware limits (VRAM/memory = max model/context)
- ecosystem variance (different runtimes, quant schemes, templates)
- ops burden (setup, drivers, updates)

- running local checklist:
- pick a model (prefer chat-tuned, sized for your VRAM)
- pick precision (4-bit saves RAM, FP16 for max quality)
- install runtime (vLLM, llama.cpp, Transformers+PyTorch, etc)
- run it, get tokens/sec, check memory fit
- use correct chat template (apply_chat_template)
- tune decoding (temp/top_p)
- benchmark on your task
- serve as local API (or go wild and fine-tune it)

- glossary:
- token: smallest unit (subword/char)
- context window: max tokens visible to model
- KV cache: session memory, per-layer attention state
- quantization: lower precision for memory/speed
- RoPE: rotary position embeddings (for order)
- GQA/MQA: efficient attention for memory bandwidth
- decoding: method for picking next token
- RAG: retrieval-augmented generation, add real info

- misc:
- common architectures: LLaMA, Falcon, Mistral, GPT-NeoX, etc
- base model: not fine-tuned for chat (LLaMA, Falcon, etc)
- chat-tuned: fine-tuned for dialogue (Alpaca, Vicuna, etc)
- instruct-tuned: fine-tuned for following instructions (LLaMA-2-Chat, Mistral-Instruct, etc)

- chat/instruct models usually need a special prompt template to work well
- chat template: system/user/assistant markup is required; wrong template = junk output
- base models can do few-shot chat prompting, but not as well as chat-tuned ones

- quantized: weights stored in lower precision (8-bit, 4-bit) for memory savings, at some quality loss
- quantization is a tradeoff: memory/speed vs quality
- 4-bit (NF4/GPTQ/AWQ) is the sweet spot for most consumer GPUs (huge memory win, minor quality drop for most tasks)
- math-heavy or finicky tasks degrade first (math, logic, code)
- quantization types: FP16 (full), INT8 (quantized), INT4/NF4 (more quantized), etc.
- some runtimes support quantized KV cache (8/4-bit), big savings for long contexts

- formats/runtimes:
- PyTorch + safetensors: flexible, standard, works on GPU/TPU/CPU
- GGUF (llama.cpp): CPU/GPU, portable, best for quant + edge devices
- ONNX, TensorRT-LLM, MLC: advanced options for special hardware

- avoid legacy .bin (pickle risk), use safetensors for safety

- everything is a tradeoff:
- smaller = fits anywhere, less power
- more context = more latency + VRAM burn
- quantization = faster/leaner, maybe less accurate
- local = full control/knobs, but more work

- final words:
- local LLMs = memory math + correct formatting
- fit weights and KV cache in memory
- use the right chat template and decoding strategy
- know your knobs: quantization, context, decoding, batch, hardware

- master these, and you can run (and reason about) almost any modern model locally

