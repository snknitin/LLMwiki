---
title: "X"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2026-05-21"
tweet_url: "https://x.com/TheAhmadOsman/status/2057590224729911346"
tweet_type: "original"
likes: 650
retweets: 98
replies: 20
bookmarks: 1837
views: 262576
has_media: false
article_id: "2057582083208257538"
tags: ["twitter-bookmark", "llm", "agents"]
---

# X

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2026-05-21 · 👍 650 · 💬 20 · 🔖 1837 · 👁 262576

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/2057590224729911346)

## Article Content

Start with the loop. Text becomes tokens. Tokens move through a Transformer. Attention decides which earlier tokens matter. The runtime keeps a KV cache so the model does not recompute the whole conversation every time. Then the model picks the next token and does it again.

> A practical guide to how LLMs work, how models think 1 token at a time, and how to run them locally.

Once that loop clicks, the hardware and software choices become easier to reason about. VRAM, quantization, context length, chat templates, decoding, RAG, serving engines, and model selection all fall out of the same mechanics.

> Start with the loop: Tokens in, probabilities out, one next token at a time.Weights tell the model what patterns it learned. Context tells it what it is looking at now. The KV cache is the working memory that keeps the loop usable.Hardware, runtimes, and model selection only make sense after you understand the memory, context, and formatting rules the model is obeying.

The goal is to make local LLM mechanics intuitive first, then give you a practical path into hardware, runtimes, serving, and current LLM research as of ****May 21, 2026****.

### Focus

This is a ****model-first**** guide. It starts with the mechanics: ****inference, tokens, Transformers, attention, KV cache, prefill, decode, decoding controls, model packages, chat templates, model types, long context, RAG, agents, fine-tuning, and multimodal models****.

After that, it moves into the local deployment layer: ****what local really means, quantization, VRAM math, hardware tiers, runtime choices, serving modes, licenses, model selection, privacy, troubleshooting, benchmarks, setup paths, and practical use cases****.

That order matters. You should understand why a long prompt costs memory before choosing a GPU. You should understand why chat templates matter before judging a model. You should understand whydecode is sequential before caring about tokens per second.

****For the deeper hardware and software path,**** I have a three-part series teaching self-hosted LLMs / local AI:

- Part 1: [GPU Memory Math for LLMs (2026 Edition)](https://x.com/TheAhmadOsman/status/2040103488714068245)

.
- Part 2: [Memory Bandwidth for Local AI Hardware (2026 Edition)](https://x.com/TheAhmadOsman/status/2041331757329285589)

.
- Part 3: [Inference Engines for LLMs & Local AI Hardware (2026 Edition)](https://x.com/TheAhmadOsman/status/2057183854444843202)

.

The first two pieces explain the ****hardware capacity and bandwidth math****. The third explains the ****software layer**** that turns that hardware into usable inference. This article gives you the model-side foundation first, then points back to those deployment layers once the mechanics are clear.

### What An LLM Actually Does

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586295992369152

Running a model is called ****inference****. For a standard decoder-only LLM, inference is the same loop repeated over and over:

1. Convert your text into tokens.
2. Feed those tokens into the model.
3. Compute scores for every possible next token.
4. Choose one token with a decoding policy.
5. Append that token to the sequence.
6. Repeat until the model stops, the user stops it, or a token limit is reached.

The model is not writing a whole answer in one shot. It is generating ****one token at a time****. Every new token becomes part of the sequence that influences the next token.

Mathematically, the model is a learned function:

> f(theta, sequence) -> probability distribution over next_token

Where:

- ****theta**** means the model weights.
- ****sequence**** means the prompt plus generated tokens so far.
- ****Logits**** are the raw scores before softmax.
- ****Probabilities**** are the normalized scores after softmax.
- ****Decoding**** turns those probabilities into one selected token.

This is why local generation speed is measured in ****tokens per second****. Your system repeatedly runs a forward pass, picks or samples a token, updates the KV cache, and continues.

Perception matters here. A long ****prefill**** means a long pause before the first word appears. Slow ****decode****means the answer streams slowly. Local builders often obsess over decode speed because it is what users feel, but prefill time is what hurts when you paste a 10K-token document.

### Tokens

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586520370929664

LLMs do not see raw text as words. They see ****tokens****: Small chunks of text represented internally as integer IDs.

A token might be:

- A whole word: "hello"
- A word fragment: "inter", "national", "ization"
- A punctuation mark
- A whitespace-prefixed string
- A byte-level fallback
- A special control marker such as <|user|>, <|assistant|>, , or

The ****tokenizer**** maps text to token IDs and token IDs back to text. Common tokenizer families include ****BPE-style tokenizers**** and ****SentencePiece-style tokenizers****. Different model families use different tokenizers, and that matters. A 4,000-word document may be 5,000 tokens in one tokenizer and 7,500 tokens in another.

Vocabulary size matters too. A tokenizer with a larger vocabulary can compress some text into fewer tokens, but it also changes embedding and output-projection size. This is one reason tokens per second is not perfectly comparable across model families.

Tokens matter because they determine:

- How much text fits in the context window.
- How large the KV cache becomes.
- How much latency you pay during prompt processing.
- Whether multilingual or code-heavy text is efficient.
- Whether the model sees special chat markers correctly.

A model's ****context window**** is the maximum number of tokens it can attend to at once. In 2026, common local-capable models range from 8K and 32K contexts to 128K, 256K, and even 1M-token contexts in server-class systems.

But supported context length is not the same as cheap, fast, or equally accurate context. A model that can technically handle 128K tokens may slow to a crawl at 64K and lose coherence at 100K. Always test the context lengths you actually plan to use.

****Tokens are the unit of work.**** Once you understand that, long context stops looking magical and starts looking like a bill you can estimate.

****Helpful Exercise:**** Try my [Tokenizer demo app](https://ahmadosman.com/tokenizer)

 to see how text gets broken into tokens in real time.

### Transformers

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586563513516033

Most modern LLMs are based on the ****Transformer**** architecture. Most local chat LLMs are ****decoder-only Transformers****: They predict the next token while looking back at previous tokens.

Everything above this point, including tokens, weights, config, and chat templates, is setup for the real engine underneath. The Transformer is the skeleton that moves the numbers around.

A simplified Transformer layer contains:

1. ****Token embeddings:**** Token IDs become vectors.
2. ****Positional information:**** The model needs token order. Many modern LLMs use ****RoPE**** (Rotary Position Embeddings), which encodes position by rotating representations.
3. ****Self-attention:**** Each token representation looks back at prior token representations and decides what matters.
4. ****MLP / feed-forward block:**** A dense nonlinear computation that expands and compresses representations. A large fraction of parameters live here.
5. ****Layer normalization and residual connections:**** These stabilize deep networks and help information flow through many layers.
6. ****Output projection:**** The final hidden state becomes logits over the vocabulary.

Stack this recipe dozens or hundreds of times and you get a language model.

****Transformer recap:**** Tokens become vectors, attention connects the sequence, MLPs reshape the representation, RoPE keeps position straight, and the final projection turns the last hidden state into next-token logits.

### Attention

****Attention**** is how a token decides which earlier tokens matter for the next prediction. It is also one of the reasons local inference is so memory-sensitive.

Classic ****MHA**** (multi-head attention) stores separate key/value state for many heads. It gives the model flexibility, but it makes the KV cache large.

Modern local models often use more efficient attention designs:

- ****MQA:**** Multiple query heads share one key/value head. It is memory-efficient, but can be less expressive.
- ****GQA:**** Groups of query heads share key/value heads. It is the common middle ground in many current local models.
- ****MHA:**** Full multi-head attention. It can be strong, but long context gets expensive quickly.

Modern kernels such as ****FlashAttention**** and SDPA-style implementations reduce attention memory traffic and keep the GPU busier. A runtime with good attention kernels can be dramatically faster than one without, even on the same model and hardware.

This is why two 7B models can behave very differently at long context. Parameter count is not the whole story. A 7B MHA model at 128K context can exhaust a 24 GB GPU, while a 7B GQA model with the same advertised context may fit with room to spare.

When comparing models, look at ****attention type, KV heads, context length, and runtime support****, not just parameter count.

### KV Cache

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586637371002880

The ****KV cache**** is the model's working memory during generation. It stores key/value attention states for previous tokens so the model does not recompute the entire history from scratch on every generated token.

Without a KV cache, generation would be brutally inefficient. With a KV cache, generation is usable, but the cache consumes memory proportional to:

> tokens x layers x kv_heads x head_dim x precision x 2

The x 2 is for keys and values.

A useful rule of thumb for older Llama-like 7B MHA models is roughly ****0.5 MiB per token**** in FP16 KV cache. That means 4K tokens can cost around 2 GiB just for KV cache. At 32K tokens, you may be looking at 16 GiB of KV cache alone.

Newer GQA/MQA models reduce this substantially. Some runtimes also support ****FP8 or INT8 KV cache****. That is often the practical compression floor I would recommend for local users in 2026.

****Do not treat sub-8-bit KV cache as a default.**** Research systems such as [KIVI](https://arxiv.org/abs/2402.02750)

, [KVQuant](https://arxiv.org/abs/2401.18079)

, and newer compressed-cache kernels show that 2-bit to 4-bit KV can work with careful algorithms, calibration, and custom kernels. That is not the same as casually flipping a Q4 KV toggle in a desktop runtime. Below 8-bit, benchmark hard, especially for coding, tool calls, JSON, long-context retrieval, and tasks where exact earlier tokens matter.

Also do not confuse KV-cache quantization with speculative decoding. [DFlash](https://arxiv.org/abs/2602.06036)

 and [DDTree](https://arxiv.org/abs/2604.12989)

, often shortened informally to DTree, attack decode latency by drafting future tokens and verifying them. They can improve speed, but they do not erase the KV-cache memory bill.

This is why a model can fit at an empty prompt but crash when you load a long document. The weights fit. The working memory did not.

### Prefill And Decode

LLM inference has two different performance regimes: ****prefill**** and ****decode****.

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587953103196160

****Prefill**** processes the prompt you gave the model. If you paste a 20,000-token document, the model must process those 20,000 tokens before it can produce the first answer token. Prefill is relatively parallelizable, so GPUs can handle it efficiently, but it can still be expensive.

The time you spend waiting for the first token to appear is usually ****prefill time****.

****Decode**** generates new tokens one at a time. Each generated token depends on the sequence so far, so decode is much more sequential. This is where the streaming typing effect comes from, and it is usually the phase that determines whether a model feels fast or slow.

Long prompts punish prefill. Long answers punish decode. Long conversations punish both because the KV cache grows.

In a chat session, every turn adds to the cache. If you let a conversation run to 16K tokens, you are paying the memory cost for all 16K tokens on every new token generated. This is why chat UIs that keep infinite history eventually slow down or crash.

### Decoding

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586728093810688

After the model produces logits, it has not written anything yet. It has only scored every possible next token. ****Decoding**** is the policy that turns those scores into one actual token, appends that token to the context, and repeats the loop.

The runtime, or [inference engine](https://x.com/TheAhmadOsman/status/2057183854444843202)

, can choose tokens in several ways. It can pick the highest-probability token every time. It can sample from a narrowed set of likely tokens. It can penalize repetition. It can stop at a delimiter. It can use a fixed seed so the same prompt behaves reproducibly.

These choices do not change the model weights, but they change the model's ****voice, determinism, creativity, risk profile, and tendency to loop****.

The important knobs answer three practical questions:

- ****Randomness:**** How much variation is allowed?
- ****Tail reach:**** How far into lower-probability tokens can the sampler go?
- ****Boundaries:**** What prevents loops, rambling, schema breaks, or runaway output?

For precise work, start narrow: ****low temperature, short max-token limits, explicit stop sequences, and constrained decoding**** when output must match JSON or a schema. For creative work, give the sampler more room with ****higher temperature, top-p, and multiple candidates ranked afterward****. For coding, keep the first pass conservative, then sample alternatives only when you are intentionally exploring.

Greedy decoding is not always more accurate. It is often brittle. A greedy decoder can get stuck in loops or produce generic answers because it never explores alternatives. For evals, use deterministic settings. For ideation, let the model breathe.

### What A Model Package Contains

A runnable local LLM is more than one big weight file. A model package usually includes:

- ****Architecture/config:**** Layer count, hidden size, attention type, RoPE settings, vocabulary size, special tokens, and context length.
- ****Weights:**** The learned parameters, often stored as safetensors, GGUF, GPTQ, AWQ, EXL2, or another runtime-specific format.
- ****Tokenizer:**** The rules that turn text into token IDs and token IDs back into text.
- ****Chat template:**** The exact markup for system, user, assistant, tool, and reasoning messages.
- ****Generation config:**** Defaults for temperature, top-p, stop tokens, repetition penalties, and max tokens.
- ****License and model card:**** The legal and operational instructions for how the model can be used.

The weights are the largest file, but they are not the whole model. If the tokenizer, config, or chat template is wrong, the same weights can feel broken.

The package section tells you what has to travel together. The next section explains why the chat template is the part people most often break.

### Chat Templates

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586803171872768

A chat model was trained with a specific conversation format. For example, it may expect something like:

> <|system|> You are a helpful assistant. <|user|> Explain KV cache. <|assistant|>

Another model may expect:

> [BOS] [INST] Explain KV cache. [/INST]

Another may use ChatML-style markers. Another may require special reasoning tokens. Another may need tool-call XML or JSON wrappers.

Using the wrong format can cause gibberish, role confusion, ignored system prompts, repeated prompts, refusal weirdness, broken tool calls, bad benchmark results, and conclusions that the model is dumb when the template is the actual bug.

Best practice:

- Use the tokenizer's apply_chat_template when using Transformers.
- Use model-specific templates in Harbor-backed frontends, llama.cpp, LM Studio, vLLM, or SGLang.
- Check whether the model is base, instruct, chat, reasoning, or tool-tuned.
- Ensure BOS/EOS tokens are correct.
- Keep system prompts short unless they need to be long.
- For tool use, follow the exact schema expected by the model/runtime.

If you are building an application that lets users switch models, you need template switching too. Hardcoding one template format and then loading a model that expects another is a common source of bad local-model evals.

Treat the template like an API contract. If you get it wrong, you are not really testing the model you think you are testing.

### Model Types

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586851800641536

Not all LLMs are tuned for the same behavior.

For most users, the default starting point should be a ****recent instruct/chat-tuned model**** in a size that fits comfortably in memory.

Do not start with a base model unless you know why. Base models complete your prompt rather than answer it. They are useful for researchers, fine-tuners, and people building custom pipelines. They are frustrating for everyone else.

If you ask a base model What is the capital of France?, it might continue with and what is the population of Paris? instead of answering Paris.

The practical split is simple:

- ****Base model:**** Good for pretraining research, fine-tuning, and custom pipelines.
- ****Instruct model:**** Good for direct instruction following.
- ****Chat model:**** Good for multi-turn dialogue with role formatting.
- ****Reasoning model:**** Good when the task benefits from extra thinking tokens and verification.
- ****Tool-tuned model:**** Good when structured calls, JSON, or function use matters.

### What Local Really Means

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586889121570816

A local LLM is a model whose ****weights**** and ****inference runtime**** are under your control. You decide what model runs, how it runs, what data it sees, and what happens to the outputs.

That freedom comes with work. You are now the ops team. You handle downloads, updates, compatibility, memory limits, and security. When something breaks, there is no support ticket to file. There is only you, the logs, and the documentation.

Local can mean:

- A 2B parameter model running on a phone.
- A 7B to 14B model running on a consumer GPU.
- A 30B to 70B model running on a high-end workstation.
- A sparse MoE model running on one or more datacenter GPUs.
- A private deployment using vLLM, SGLang, TensorRT-LLM, llama.cpp, Harbor, LM Studio, or a custom PyTorch stack.

The key point: ****local does not automatically mean offline, private, safe, cheap, or opensource.**** It only means you are running the model yourself. A local app can still phone home. A model can be open-weight but not opensource. A model can be local but unsafe to load. A quantized model can fit in memory but answer poorly.

The tradeoff is worth it when you need privacy, low latency, custom behavior, offline operation, or cost control at scale. It is not worth it when you need the absolute best model quality and do not have the hardware to match. In that case, a hosted API is the right tool.

Local LLMs are practical when you understand one equation:

> ****Local LLM success = model fit + correct prompt format + good runtime + realistic evals.****

Everything else is details. The details matter.

### Quantization

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586936164802560

****Quantization**** stores weights in lower precision to reduce memory and sometimes improve throughput.

The 2026 rule of thumb for local users:

- ****FP16/BF16:**** Best quality when memory is abundant. Use it as a baseline for evaluation.
- ****Q8 / INT8:**** Near-lossless for many tasks, but still large. Good when you have VRAM and want minimal quality loss.
- ****Q6 / Q5:**** Excellent quality with moderate savings. This is a strong middle ground.
- ****Q4:**** The default consumer sweet spot for many chat and document workflows.
- ****Q3 / Q2:**** Only when you must fit a bigger model. Math, code, structured output, and tool use degrade first.

Weight quantization is not the same as KV-cache quantization. Weight quantization shrinks the model. KV-cache quantization shrinks the live context memory.

For KV cache, treat ****FP16/BF16 as the clean baseline**** and ****FP8/INT8 as the practical local compression floor****. Below 8-bit is research-heavy and workload-sensitive. Use it only after measuring quality on your actual prompts.

Quantization failure shows up first in math, multi-step reasoning, code correctness, tool-use reliability, JSON/schema adherence, subtle instruction following, and long-context retrieval.

A smaller model at higher precision can beat a larger model crushed into too few bits. Do not worship parameter count. A 7B model at Q6 can beat a 13B model at Q2 on reasoning tasks while using less memory and running faster.

### File Formats And Load Safety

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057586972449783808

****safetensors**** is a safe tensor serialization format designed to store tensors without Python pickle behavior. Use safetensors when possible, especially for PyTorch/Transformers models.

Avoid random .bin files from untrusted sources. PyTorch pickle-based loading can execute arbitrary code during deserialization. Local AI security rule number one: ****do not let a stranger's model file become a stranger's code execution****.

****GGUF**** is the llama.cpp ecosystem's binary model format. Use GGUF when you want llama.cpp, CPU inference, Apple Silicon inference, simple local servers, portable quantized models, or desktop tools like LM Studio.

****ONNX**** is useful for standardized deployment and hardware-specific acceleration, especially outside the usual PyTorch stack. If you are deploying to Intel NPUs, ARM devices, or custom accelerators, ONNX is often the path of least resistance.

****TensorRT-LLM**** is NVIDIA's high-performance inference path for production GPU deployments. It is powerful, but more complex than llama.cpp or Harbor. You typically convert a checkpoint to TensorRT engines, which takes time and GPU memory, but yields excellent throughput once built.

****EXL2 / GPTQ / AWQ**** formats are common in GPU-focused local inference communities, especially for squeezing larger models onto single GPUs.

The file format choice is not cosmetic. It determines which runtimes can load the model, what quantization you can use, and how fast it runs.

### Runtimes And Serving Modes

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587011200892928

A ****runtime**** is the software that loads the model and performs inference. In 2026, the local LLM runtime ecosystem is mature, useful, and fragmented.

For a single person experimenting locally, start with [Harbor](https://github.com/av/harbor)

, ****LM Studio****, or ****llama.cpp****. Harbor is the best fit when you want a complete local stack with frontends, backends, and supporting services wired together. LM Studio is the easiest desktop-first path. llama.cpp is the portable low-level workhorse.

For a team or private service, look at ****vLLM or SGLang****. For maximum NVIDIA production performance, investigate ****TensorRT-LLM****. For browser or mobile deployment, look at ****MLC or WebLLM****.

The runtime choice often locks you into a format ecosystem. ****llama.cpp means GGUF.**** ****vLLM and SGLang usually mean safetensors or Hugging Face checkpoints.**** ****TensorRT-LLM means ONNX or optimized engines.**** Pick the runtime first, then find models in the right format.

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587056193236992

There are three practical serving modes.

****Single-user local**** means a desktop app, CLI stack, or command-line server for one person. Harbor, LM Studio, llama.cpp server, ExLlama/TabbyAPI, and small Transformers scripts all fit here. The goal is quick iteration: Compare behavior, speed, memory use, and prompt formats without building an ops platform.

****Team or private API**** means an OpenAI-compatible endpoint on a workstation or server. vLLM, SGLang, TensorRT-LLM, and llama.cpp server all show up here depending on model size and throughput needs. Once multiple people or jobs share a model, you need monitoring, prompt/version management, routing, and realistic latency measurements.

****Production serving**** is a different job. Now the conversation includes continuous batching, prefix caching, speculative decoding, paged attention, tensor parallelism, pipeline parallelism, quantized serving, structured outputs, load balancing, GPU utilization, latency percentiles, prompt caching, admission control, logging, failover, privacy, and cost controls.

At production scale, can I load the model? is the easy question. The hard question is can I serve it reliably under real traffic?

### VRAM Math For Local Models

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587105132318720

There are three main memory consumers:

1. ****Model weights****
2. ****KV cache****
3. ****Runtime overhead****

The rough weight memory formula is:

> weight_memory ~= parameters x bytes_per_parameter

Useful approximations:

- ****FP16/BF16:**** About 2 bytes per parameter.
- ****INT8/Q8:**** About 1 byte per parameter.
- ****Q4:**** About 0.5 bytes per parameter, plus format overhead.

Then add:

- ****Runtime overhead:**** Framework buffers, CUDA overhead, memory fragmentation, and temporary tensors.
- ****KV cache:**** Grows with every token in the active context.
- ****Batch/concurrency memory:**** Each concurrent request needs its own cache.
- ****Vision encoder memory:**** Images become tokens too.
- ****Speculative decoding memory:**** Draft models, draft heads, or extra verification structures are not free.
- ****Adapter memory:**** LoRA adapters are small, but still real.

MoE models add one more wrinkle. A model may activate only a fraction of its parameters per token, but the inactive experts usually still need to live somewhere in memory. Active parameters affect compute cost. Total parameters still affect loading and capacity planning.

A realistic estimate looks like:

> total_memory = quantized_weightsKV_cache_for_context
> runtime_overhead
> batch_or_concurrency_overhead
> safety_margin

Here is the trap: A 13B model in Q4 may fit easily at 8K context, then fail at 32K because the KV cache quadrupled. The weights did not change. The context did.

Leave ****10 to 20 percent headroom****. Running at 99 percent VRAM utilization is begging for out-of-memory errors and fragmentation failures.

### Hardware Tiers In Practice

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587158437838848

These are practical 2026 rules of thumb, assuming quantized inference and sane context lengths. Exact results depend on runtime, quantization, model architecture, attention type, context length, and OS/driver overhead.

For most serious local users in 2026, ****16 GB is the minimum comfortable GPU tier****, ****24 GB is the best value enthusiast tier****, and ****48 GB+ is where the stronger local world opens up****.

Performance depends on memory bandwidth, GPU FLOPs, VRAM capacity, KV-cache size, attention implementation, quantization, batch size, prompt length, generated length, and runtime maturity.

Decode is often ****memory-bandwidth-bound****: The GPU streams weights repeatedly while doing relatively little compute per byte. Prefill is more ****compute-bound**** because it can process the prompt in parallel. That is why two cards with the same VRAM capacity can have very different token speeds if one has much higher memory bandwidth.

The most painful local setup is one where the model almost fits and spills layers to CPU. It may technically run, but token speed can collapse. CPU offload is acceptable for experimentation. It is not a performance strategy.

### Choose A Model That Fits

The practical question is not what is the best model? It is ****what is the smallest model that wins your real workload on your hardware?****

Start with a recent ****instruct/chat model**** that fits comfortably with the context length you actually need. If you are on 8 GB to 12 GB of VRAM or unified memory, start small. If you are on 16 GB to 24 GB, test 7B to 14B class models first. If you have 48 GB or more, larger dense models and MoE models become realistic.

Use this memory gate before you fall in love with a checkpoint:

> weights + KV cache + runtime overhead <= 80 to 90 percent of available memory

Then run the same 20 to 50 prompts across candidates. Include your real tasks: Coding edits, document Q&A, JSON output, summaries, tool calls, long context, or whatever you actually need. Measure ****answer quality, latency, memory use, template reliability, and failure modes****.

A practical model choice usually comes down to five checks:

- ****Task fit:**** Chat, coding, documents, agents, multimodal, edge, or fine-tuning.
- ****Memory fit:**** Weights, KV cache, runtime overhead, and safety margin.
- ****Interface fit:**** Tokenizer, chat template, stop tokens, tool schema, and reasoning mode.
- ****Runtime fit:**** Does your runtime support this architecture, quantization, context length, and serving mode well?
- ****License fit:**** Can you actually use it where you plan to use it?

Leaderboards are useful for discovery. They are not a substitute for your own evals. Your workload is the benchmark that matters.

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587247877115904

For a ****simple local assistant****, pick a recent 7B to 14B instruct model, Q4/Q5 quantization, the correct chat template, 8K to 32K context, and Harbor, LM Studio, or llama.cpp. Prioritize responsiveness over giant size.

For a ****local coding assistant****, pick a code-capable 14B to 32B model if you have enough VRAM. Use low temperature, repository retrieval, test execution, and a patch-based workflow. A code model without tools is half a product.

For a ****private document assistant****, pick a strong instruct model, a local embedding model, a reranker, a RAG pipeline, citation enforcement, and moderate-to-long context. Do not paste a 200-page PDF and hope.

For a ****reasoning setup****, pick a reasoning-tuned model, budget extra tokens, use low-to-medium temperature, add verification, and use tools for math, code, or search. Reasoning models spend more tokens. Budget accordingly.

For a ****low-resource setup****, pick a 1B to 4B model, Q4/Q5, short prompts, structured tasks, retrieval or tools, and a tight output schema. Small models become useful when the task is constrained.

### What Controls Speed

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587312385548288

Tokens per second is not controlled by one thing. It is the result of ****model size, memory bandwidth, compute, attention kernels, context length, quantization, batching, and runtime quality****.

The main levers are:

- ****Memory bandwidth:**** Decode often streams model weights repeatedly, so bandwidth dominates single-user token speed.
- ****GPU FLOPs:**** Prefill and large batches use more parallel compute, so FLOPs matter more there.
- ****VRAM capacity:**** If the model or KV cache spills to CPU, performance can collapse.
- ****Attention implementation:**** FlashAttention, SDPA, paged attention, and runtime-specific kernels change both speed and memory behavior.
- ****Quantization:**** Smaller weights reduce memory movement, but aggressive quantization can hurt quality and sometimes add dequantization overhead.
- ****Batch size and concurrency:**** Batching improves throughput, but each active sequence needs KV cache.
- ****Prompt length:**** Long prompts increase prefill time.
- ****Generated length:**** Long answers expose decode speed.
- ****Speculative decoding:**** EAGLE-style methods, MTP, DFlash, and DDTree can verify more than one drafted token per target pass when supported.

The painful setup is the almost-fit setup. A model that spills layers or cache to CPU may technically run, but token speed can drop from usable to miserable.

Benchmark the exact runtime, quantization, context length, prompt shape, and workload you plan to use. A BF16 leaderboard number does not tell you what your Q4 local stack will feel like.

### Long Context

****Long context**** sounds magical: 128K, 256K, or even 1M tokens in one prompt. It is useful, but it has real costs.

More context means more KV cache memory, slower prompt processing, more attention work, harder evaluation, and more ways for irrelevant text to distract the model. Quality can also decay across distance. A model may handle the end of a long document well while missing critical details buried near the beginning.

Use long context for ****whole-document analysis, codebase slices, legal or technical review, transcript summarization, multi-file reasoning, and RAG fallback when retrieval misses context****.

Do not treat long context as a replacement for retrieval. It is a complement. Use RAG for large corpora and long context for the final selected evidence.

Practical habits help:

- Put critical instructions near the beginning and near the end.
- Use section headers and delimiters.
- Ask for citations tied to source chunks.
- Compress irrelevant history.
- Use summary memory instead of infinite chat history.

Think of long context as expensive attention, not a free notebook.

### Multimodality

****Multimodal**** local models accept images, and sometimes audio or video, in addition to text. Modern open-weight ecosystems increasingly include these models.

The hidden cost is that non-text input becomes tokens too. Vision encoders add memory. Image patches consume context. Audio and video can explode the input budget. Multimodal templates are also easier to get wrong than text-only templates.

A single high-resolution image can consume thousands of tokens in the context window. If you are running a multimodal model locally, count image tokens the same way you count text tokens. They come from the same budget.

Small VLMs can hallucinate visual details. OCR reliability varies. Charts and tables are still hard. For serious document or image workflows, evaluate with real samples. Do not trust a demo of a simple photo to prove invoice extraction quality.

### The 2026 Local Model Scene

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587487002828801

The model scene changes fast. As of ****May 21, 2026****, local LLM users should think in terms of ****families and ecosystems****, not one best model.

****Qwen 3.5 / Qwen 3.6**** is a major open-weight family because it covers the whole stack: Small models for laptops, dense mid-size models for workstations, MoE models for multi-GPU serving, FP8 variants, long context, multilingual work, coding, tools, and agentic workflows. The practical takeaway is simple: Qwen is a strong default family when you want one ecosystem that spans laptop experiments and serious local serving.

****Gemma 4**** matters because Google DeepMind is pushing the family toward useful local deployment: Efficient edge models, larger dense and MoE options, multimodality, long context on the larger models, broad language support, stronger coding/agent behavior, and Apache 2.0 licensing. That combination makes it worth testing when commercial use and device-side deployment matter.

****Kimi / Moonshot AI****, ****GLM / ****[Z.ai](https://x.com//Z.ai)

, ****DeepSeek****, ****MiniMax****, and ****Mistral**** are also core families to track. Kimi is relevant for long-horizon coding, multimodal reasoning, tool use, and agent workflows. GLM is important for coding agents, long-horizon tasks, MoE systems, and deployment-oriented model releases. DeepSeek remains influential because of large MoE systems, Multi-head Latent Attention, DeepSeekMoE, FP8 serving paths, sparse attention, and high-throughput self-hosting. MiniMax is worth watching for practical agent workloads and inference-efficient MoE models. Mistral still matters because its lineup covers generalist, coding, reasoning, multimodal, and specialist use cases with strong deployment support.

****Nemotron 3**** is NVIDIA's open model family for production-grade agent systems on NVIDIA hardware. The family includes Nano, Super, and Ultra sizes, uses hybrid Mamba-Transformer MoE designs, and is tied closely to TensorRT-LLM, NIM, Dynamo, Blackwell NVFP4/FP8 paths, and enterprise agent deployment. Treat it less like a casual desktop-chat family and more like a signal for where NVIDIA wants open-weight serving stacks to go.

Open-weight AI is no longer just ****Llama vs. everything else****. You are choosing an ecosystem: Weights, license, tokenizer, template, quantizations, runtime support, serving path, community tools, and failure modes.

****The Qwen 27B Dense Model****

Qwen 3.5 / 3.6 27B (Dense) is one of the most practical public-weight options for local users who care about coding, multilingual work, tool use, thinking/non-thinking modes, and long context. The [Qwen 3.5 27B](https://huggingface.co/Qwen/Qwen3.5-27B)

 and [Qwen 3.6 27B](https://huggingface.co/Qwen/Qwen3.6-27B)

 model cards describe OpenAI-compatible serving paths, thinking mode defaults, tool use, and context lengths up to 262,144 tokens, with longer-context extension through YaRN in supported frameworks.

****Qwen is a strong default for a 2x RTX 3090 setup when the runtime is configured correctly for coding, agents, or multilingual coverage.****

****Inference Research****

The 2026 frontier is not only model quality. It is also inference efficiency. [PagedAttention](https://arxiv.org/abs/2309.06180)

 attacks KV-cache memory waste in serving. FP8 KV cache is now a practical runtime feature in systems such as [vLLM](https://docs.vllm.ai/en/latest/features/quantization/quantized_kvcache/)

. DFlash and DDTree explore speculative decoding with block diffusion draft models and draft trees. NVFP4 is also worth watching on NVIDIA hardware because it changes the practical deployment conversation for supported stacks.

Some of this is production-ready. Some of it is still research. Some of it only matters if your runtime supports it cleanly. Do not treat paper speedups as a checkbox in a desktop app.

### Failure Modes And Fixes

Most local LLM failures are not mysterious. They usually come from ****memory fit, formatting, runtime support, decoding settings, or retrieval quality****.

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057588641975730176

****Out of memory:**** The weights, KV cache, runtime overhead, or batch size do not fit. Use a smaller model, reduce context, lower batch/concurrency, choose a better quantization, or leave more headroom.

****Gibberish or role confusion:**** The chat template, tokenizer, BOS/EOS token, reasoning-mode switch, or tool schema is wrong. Verify the model card and runtime template before blaming model quality.

****Slow first token:**** Prefill is expensive. Shorten the prompt, use prefix caching, improve retrieval, reduce context, or use a faster runtime.

****Slow streaming:**** Decode is the bottleneck. Check memory bandwidth, quantization, CPU spill, attention backend, speculative decoding support, and whether the model is simply too large for the hardware.

****Bad document answers:**** Retrieval probably failed. Inspect parsed text, chunk boundaries, metadata, top-k retrieval, reranking, and citation grounding.

****Bad JSON or tool calls:**** Use lower temperature, constrained decoding, stricter schemas, better examples, and a model tuned for tool use.

****Repeating loops:**** Reduce temperature or top-p, add repetition penalties, check stop tokens, and make sure the template is not causing the model to see its own answer as a new prompt.

Start with the boring checks. They fix more problems than model swapping does.

### How To Grow The Stack

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587583895375874

****Beginner: Easiest Useful Setup****

Use ****Harbor or LM Studio****, a recent ****4B to 9B instruct model****, Q4 quantization, 8K to 32K context, and a built-in chat UI. Download two or three models in the same size class and compare them on the same prompts.

****Goal:**** Learn prompting, compare models, understand speed and memory, and avoid custom code at first.

****Intermediate: Developer Setup****

Use ****llama.cpp or Transformers****, GGUF or safetensors, an OpenAI-compatible local server, a simple RAG pipeline, and a small eval set. Call your local server from a real application or script instead of only using a chat UI.

****Goal:**** Build local apps, test retrieval, measure quality, and serve from localhost.

****Advanced: Private Serving Setup****

Use ****vLLM or SGLang****, one or more GPUs, an OpenAI-compatible API, monitoring, prompt/version management, an evaluation suite, RAG with reranking, and tool sandboxing.

****Goal:**** Serve real users or internal workflows, optimize throughput and latency, and maintain safety and observability.

****Expert: Custom Optimization****

Use ****TensorRT-LLM****, custom kernels, specialized runtimes, quantization experiments, speculative decoding, multi-GPU parallelism, fine-tuning, distillation, and production evals.

****Goal:**** Trade engineering time for inference efficiency, lower cost, and higher quality at scale.

### Privacy Is Not Automatic

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587696189517824

Local LLMs improve privacy because prompts and outputs can remain on your hardware. But ****local does not automatically mean secure****.

Threats include malicious model files, pickle-based weight loading, untrusted trust_remote_code, prompt injection in retrieved documents, tool-call abuse, secret leakage through logs, telemetry from desktop apps, browser extensions or plugins, model hallucinations in high-stakes settings, license violations, and data contamination during fine-tuning.

A workable local AI security baseline has four habits:

- ****Load carefully:**** Prefer safetensors or GGUF from reputable sources, avoid untrusted .bin files, and do not enable trust_remote_code casually.
- ****Run with boundaries:**** Use an unprivileged user, containers or sandboxes for agents, and disabled network access when offline privacy matters.
- ****Protect secrets:**** Keep credentials out of prompts and RAG indexes, review desktop app telemetry settings, and validate tool calls before execution.
- ****Version what matters:**** Track model, prompt, adapter, runtime, and quantization versions, and log enough for debugging without creating a privacy disaster.

Local AI security is mostly boring operational discipline. That is also how you avoid downloading a random checkpoint, running it as root, and turning local AI into local compromise.

### Benchmarks That Matter

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057587732243738624

Benchmark the stack you will actually run. A model's BF16 leaderboard score is not your Q4 local reality.

Measure ****quality, latency, memory, reliability, and operating fit****:

- ****Quality:**** Correctness on your real tasks, not only generic benchmarks.
- ****Latency:**** Time to first token, decode tokens per second, and end-to-end time.
- ****Memory:**** Weight memory, KV-cache growth, peak VRAM, and headroom under load.
- ****Formatting:**** Chat template correctness, JSON/schema success, tool-call reliability, and stop-token behavior.
- ****Retrieval:**** Citation faithfulness, answer grounding, missing-evidence behavior, and reranker impact.
- ****Operations:**** Startup time, warmup behavior, crash recovery, logging, privacy, and version tracking.

Create a small eval set with ****30 to 100 representative prompts****. Include expected answers or scoring criteria, latency and memory measurements, failure categories, RAG-specific grounding checks, JSON compliance checks if relevant, and human review for ambiguous tasks.

Then compare models. Do not let a leaderboard choose your local stack for you.

### Coding With Local Models

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057588413524533249

Coding is one of the best local LLM use cases because prompts often include private code, latency matters, iteration is frequent, API costs can grow quickly, and local models can integrate with editors, shells, grep, test runners, and patch workflows.

The strongest local coding setup is not a naked chatbot. It is a ****code-capable instruct model**** connected to targeted repository context, retrieval over the codebase, file paths, relevant snippets, test execution, and a patch loop.

Keep decoding deterministic or low-temperature. Ask for patches instead of vague advice. Run tests automatically. Keep a small eval set of real bugs and tasks so you can tell when a new model is actually better.

Do not let a local model rewrite a large codebase without review. Local does not make a coding agent wise. It only makes the context private, the loop cheaper, and the integration easier to control.

### Local Agents Need Guardrails

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057588467572379648

A local LLM becomes much more useful when it can use tools: File search, shell commands, browser automation, databases, code execution, calendars, ticket systems, internal APIs, vector databases, home automation, robotics, or edge devices.

Tool use changes the safety model. A chatbot that hallucinates is annoying. An agent with filesystem access can delete things. An agent with browser access can leak secrets. An agent with shell access can damage the machine faster than you can read the logs.

Local agent safety has four layers. ****Scope the agent tightly**** by giving it only the directories, APIs, network access, and credentials it actually needs. ****Constrain execution**** with sandboxes, containers, least-privilege users, confirmations for destructive actions, and schema-validated tool arguments. ****Treat inputs as hostile**** because retrieved documents, web pages, tickets, and emails can contain prompt injection. ****Keep an audit trail**** by logging tool calls, model versions, prompts, and approvals without dumping secrets into logs.

Structured outputs help, but they are not a security boundary. JSON schemas, constrained decoding, and function signatures make tool calls easier to validate. They do not prove the model understood the request, chose the safe action, or avoided injected instructions.

For serious tool use, put policy checks outside the model.

### RAG Beats Giant Prompts

****RAG**** means Retrieval-Augmented Generation. Instead of stuffing all information into the prompt, you retrieve relevant chunks from a knowledge base and give only those chunks to the model.

A good local RAG system usually has ****document ingestion, parsing, chunking, embeddings, a vector index, retrieval, reranking, prompt construction, answer generation, grounding checks, and evaluation****. Each stage is a failure point.

Bad parsing turns tables into garbage. Bad chunking splits the answer across boundaries. Bad retrieval returns irrelevant paragraphs. Bad reranking buries the right answer at rank 20. A good model cannot reliably answer from evidence it never received.

Most bad RAG systems are not bad because of the LLM. They are bad because of ****chunking, retrieval, reranking, and evaluation****.

Chunking strategy is the silent killer. Fixed-size chunks with no overlap can split sentences and lose context. Semantic chunking or hierarchical chunking with parent-document retrieval often works better, but there is no universal answer. You have to evaluate chunk size, overlap, and splitting rules on your actual documents.

A good reranker can rescue mediocre retrieval. No reranker can fix chunks that lost the answer during ingestion.

### Documents And Knowledge Work

For private documents, local LLMs shine: Meeting transcript summaries, contract review, technical documentation Q&A, research note synthesis, email drafting, policy search, internal support assistants, and compliance workflows all benefit from keeping source material close to the machine or organization that owns it.

The workflow is simple but unforgiving. ****Parse documents carefully****, preserve page and section metadata, chunk semantically, use embeddings and rerankers, ask for citations, separate answer from sources from general reasoning, and evaluate citation faithfulness.

Do not assume the model knows what is in your documents. It only knows what you put into the prompt or retrieve into context.

For meeting transcripts, preserve speaker labels and timestamps. For contract review, chunk by clause or section instead of arbitrary token count. For technical documentation Q&A, include page numbers or section anchors in retrieved chunks so the model can cite sources accurately.

For document work, your ****parser and retriever**** matter as much as the model.

### Edge Deployment

https://x.com/TheAhmadOsman/article/2057590224729911346/media/2057589252796370944

Small models are increasingly useful on phones, laptops, robots, IoT gateways, factory devices, vehicles, medical devices, offline field equipment, and browser apps. The edge is not only a smaller version of the workstation. It has a different set of constraints.

Edge deployment is ruled by ****low memory, low power, thermal limits, intermittent connectivity, privacy requirements, real-time latency, small context windows, and predictable fallback behavior****. On those devices, a small reliable model beats a large fragile one.

A practical edge setup often uses a ****0.5B to 4B model****, aggressive weight quantization, tiny prompts, fixed schemas, tool-assisted workflows, local embeddings, caching, and no unnecessary chat history.

When connectivity drops, a local model that keeps working is more valuable than a larger model that fails. The future of local AI is not only giant workstation models. It is also small models doing useful work close to the data.

### A Local LLM Runbook

Use this as the final gate before trusting a local model for real work.

****Choose and fit:**** Pick a model family suited to the task, read the license, confirm hardware requirements, choose a quantization level, and estimate the full memory bill. Do not stop at weight size. Include KV cache, runtime overhead, batch/concurrency, and safety margin.

****Load and format:**** Prefer safetensors or GGUF from reputable sources, avoid untrusted pickle-based files, verify tokenizer and chat template, set context length intentionally, and choose decoding parameters for the task. If the template is wrong, the eval is invalid.

****Evaluate and operate:**** Test with representative prompts, measure time to first token and decode speed, track peak memory, evaluate retrieval before adding RAG, sandbox tools before adding agents, and fine-tune only after simpler methods fail.

****Version everything that matters:**** Model, quantization, runtime, prompt, chat template, adapter, embedding model, reranker, eval set, and hardware profile. Local systems are easier to control only when you can reproduce what you ran.

### Fine-Tuning

****Fine-tuning**** changes model behavior by training on additional data. For local users, the most important methods are ****LoRA**** and ****QLoRA****.

LoRA freezes the base model and trains small low-rank adapter weights. That reduces trainable parameters and lets you maintain multiple lightweight adapters. QLoRA extends this by fine-tuning through a frozen 4-bit quantized model into LoRA adapters.

Fine-tune when you need a consistent writing style, domain-specific output format, repetitive classification or extraction behavior, tool-call format reliability, a specialized assistant persona, domain adaptation that RAG cannot solve, or better small-model performance on a narrow task.

Do not fine-tune first. Try this order: ****correct chat template, better prompting, better model, better decoding, RAG, reranking, few-shot examples, then fine-tuning****.

Most problems that look like the model does not understand my domain are actually my prompt is vague, my template is wrong, or my retrieval is broken.

A good fine-tuning plan includes ****clean data, train/validation/test splits, baseline evals, clear target behavior, safety review, overfitting checks, regression evals, adapter versioning, license review, and a rollback plan****.

### Open-Weight Does Not Mean Opensource

In 2026, the phrase open model is often used sloppily. You should distinguish ****open-weight****, ****source-available****, ****opensource****, and ****local-compatible****.

****Open-weight**** usually means you can download the weights. It does not automatically mean you can use the model commercially, modify it freely, train on its outputs, deploy it at any scale, or ignore attribution requirements.

****Source-available**** means code or weights are visible. It does not necessarily mean the license is opensource.

****Opensource AI model**** is a stronger claim. OSI's Opensource AI Definition treats an AI system as including architecture, parameters/weights, inference code, and enough data information and code used to derive the parameters. That is a much higher bar than the weights are on Hugging Face.

Some licenses look permissive but contain restrictions: No competitive use, no training on outputs, no deployment above a certain scale, geographic exclusions, attribution requirements, patent clauses, or copyleft-like obligations on derivatives.

Rule: ****read the model card and license before using any model commercially****. A model can be excellent, downloadable, and locally runnable while still being a bad fit for your legal or deployment constraints.

### Glossary

****Model And Tuning Terms****

- ****Active Parameters:**** In an MoE model, only some parameters are used for a given token. A model may have hundreds of billions of total parameters but far fewer active parameters per token.
- ****Adapter:**** A small trainable module added to a base model, often through LoRA.
- ****Base Model:**** A pretrained model not specifically tuned for chat or instruction following.
- ****Fine-Tuning:**** Additional training that changes model behavior for a target domain or output style.
- ****Instruct Model:**** A model tuned to follow instructions.
- ****LoRA / QLoRA:**** Efficient fine-tuning methods using low-rank adapters, with QLoRA training through quantized base models.
- ****MoE:**** Mixture of Experts. A sparse architecture where only selected expert subnetworks activate per token.
- ****Weights / Parameters:**** The learned numerical values inside the model.

****Inference Mechanics****

- ****BOS / EOS:**** Beginning-of-sequence and end-of-sequence tokens.
- ****Chat Template:**** The formatting used to represent system, user, assistant, and tool messages.
- ****Context Window:**** The maximum number of tokens the model can process at once.
- ****Decode:**** The phase where the model generates new tokens one by one.
- ****DFlash:**** A 2026 speculative decoding approach that uses block diffusion for parallel drafting.
- ****DDTree / DTree:**** A speculative decoding method that builds a draft tree from block diffusion distributions and verifies it efficiently.
- ****GQA / MQA:**** Attention variants that reduce KV-cache size and improve inference efficiency.
- ****Inference:**** Running the model to produce outputs.
- ****KV Cache:**** Stored key/value attention states for previous tokens.
- ****Prefill:**** The phase where the model processes the input prompt before generating.
- ****RoPE:**** Rotary Position Embeddings, a positional encoding method common in modern LLMs.
- ****Speculative Decoding:**** A speed technique where a cheaper drafter proposes tokens and the target model verifies them.
- ****Tokenizer:**** The component that converts text into token IDs and back.
- ****Top-p / Top-k / Temperature:**** Sampling controls for token generation.

****Retrieval, Files, And Serving****

- ****AWQ:**** Activation-aware weight quantization.
- ****Embedding Model:**** A model that converts text into vectors for search/retrieval.
- ****FP8 KV Cache:**** A practical 8-bit KV-cache compression mode supported in some runtimes.
- ****GGUF:**** A model file format used heavily by llama.cpp.
- ****PagedAttention:**** A KV-cache memory-management technique used by vLLM-style serving.
- ****Quantization:**** Reducing numeric precision to save memory and improve efficiency.
- ****RAG:**** Retrieval-Augmented Generation. Retrieve relevant external context and give it to the model.
- ****Reranker:**** A model that reorders retrieved passages by relevance.
- ****Safetensors:**** A safer tensor serialization format that avoids pickle-based execution risks.

### Final Words

The local LLM ecosystem includes compact edge models, strong 7B to 32B consumer models, large MoE open-weight systems, multimodal models, long-context models, local reasoning models, mature inference runtimes, and increasingly capable private serving stacks.

But the fundamentals have not changed: ****the model predicts one token at a time, tokens are not words, weights are not the whole model, chat templates matter, KV cache is the hidden memory bill, quantization is a tradeoff, long context is not free, RAG quality depends on retrieval, fine-tuning needs evals, and local privacy still requires security discipline****.

You do not need mythology to run local models well. You need to know what fits in memory, which template the model expects, how the runtime behaves, and whether your evals match the work you care about.

Local LLMs are mostly ****memory math plus formatting plus evaluation****. Get those right, and the rest of the stack becomes much easier to reason about.

Until next time.

****-Ahmad****

> 📄 Original article URL: https://x.com/i/article/2057582083208257538

---

## Commentary from Other Bookmarks

### @TheAhmadOsman (Ahmad) — 2026-05-21

> INCREDIBLE
> 
> The MOST COMPLETE GUIDE for understanding LLMs from first principles is now available online to read for free
> 
> Covers the model mechanics
> 
> - Tokens / tokenizers
> - Transformers
> - Attention
> - KV cache
> - Prefill vs decode
> - Decoding controls
> - Model packages
> - Chat templates
> - Long context
> - RAG
> - Agents / tools
> - Fine-tuning
> - Multimodal models
> 
> Then connects that to running models locally
> 
> - What "local" really means
> - Open-weight vs opensource
> - Quantization
> - VRAM math
> - Hardware tiers
> - File formats / load safety
> - Runtimes / serving modes
> - Model selection
> - Privacy
> - Failure modes
> - Benchmarks
> - Practical setup paths
> 
> You should read this, and if you cannot now then you most definitely wanna bookmark it for later
> 
> Opensource AI FTW

[→ View quote tweet](https://x.com/TheAhmadOsman/status/2057590791241896254)

