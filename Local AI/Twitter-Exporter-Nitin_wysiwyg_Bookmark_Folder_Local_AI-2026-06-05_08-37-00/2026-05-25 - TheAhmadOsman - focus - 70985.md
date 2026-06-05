---
title: "Focus"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2026-05-25"
tweet_url: "https://x.com/TheAhmadOsman/status/2058745340895870985"
tweet_type: "original"
likes: 902
retweets: 124
replies: 18
bookmarks: 1967
views: 205899
has_media: false
article_id: "2058742259261014016"
tags: ["twitter-bookmark", "llm", "agents"]
---

# Focus

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2026-05-25 · 👍 902 · 💬 18 · 🔖 1967 · 👁 205899

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/2058745340895870985)

## Article Content

At some point, reading about LLMs stops being enough. You need to build the stack yourself: Tokenizer first, then embeddings, position, attention, Transformer blocks, objectives, decoding, cache, long context, routing, data, post-training, serving, evaluation, tools, and alignment / safety.

> A project-based roadmap for turning LLM fundamentals into working systems you can build, measure, break, and explain.

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058743729175900160The [Local AI](https://x.com/TheAhmadOsman/status/2058617968628551718)

 series gives you the hardware, runtime, and model-mechanics foundation. This article is what comes after that foundation clicks: A build order for learning the field by reproducing the important pieces, watching them fail, and writing down what the failure taught you.

> Tokenization, attention, KV cache, MoE, quantization, serving, RAG, agents, evaluation, and safety are not separate buzzwords. They are parts of one system.Start with the project loop: Implement the primitive, plot the behavior, break it on purpose, then explain what changed.Products and frameworks make more sense when you have already touched the model, memory, data, inference, and evaluation rules underneath them.

The goal is to move from "I understand the concepts" to "I can build it." As of ****May 2026****, that means learning the model architecture, the training loop, the inference path, the data pipeline, the serving layer, and the evaluation habits together.

## Focus

This is a ****projects-first**** guide. It starts with the mechanics: ****Tokenizers, embeddings, positional methods, attention, multi-head attention, Transformer blocks, training loops, objectives, decoding, speculative decoding, KV cache, MQA, GQA, MLA, long context, efficient attention, and hardware-aware modeling****.

After that, it moves into the wider systems and research layer: ****Mixture of Experts, sparse-model trade-offs, state-space and linear-attention alternatives, diffusion-style language models, data pipelines, synthetic data, scaling laws, post-training, RLHF, PPO, GRPO, RLVR, quantization, serving stacks, evaluation harnesses, RAG, tools, agents, multimodal adapters, interpretability, red-team suites, and a complete capstone model system****.

That order matters. You should understand why tokenization changes context length before training a model. You should understand why attention becomes memory-bound before choosing a serving stack. You should understand why evaluation and failure galleries matter before trusting an empty product demo.

****For the foundation this roadmap builds on,**** I have a four-part series teaching self-hosted LLMs / local AI:

- Part 1: [GPU Memory Math for LLMs (2026 Edition)](https://x.com/TheAhmadOsman/status/2040103488714068245)

.
- Part 2: [Memory Bandwidth for Local AI Hardware (2026 Edition)](https://x.com/TheAhmadOsman/status/2041331757329285589)

.
- Part 3: [Inference Engines for LLMs & Local AI Hardware (2026 Edition)](https://x.com/TheAhmadOsman/status/2057183854444843202)

.
- Part 4: [LLMs 101 (2026 Edition): How Models Think One Token At A Time](https://x.com/TheAhmadOsman/status/2057590224729911346)

.

The first two pieces explain the ****hardware capacity and bandwidth math****. The third explains the ****software layer**** that turns hardware into usable inference. The fourth explains the ****model-side mechanics****: Tokens, Transformers, attention, KV cache, decoding, context, RAG, agents, and local deployment mechanics. This article assumes that foundation and turns it into a sequence of projects you can build, test, and publish.

### The Principle: Each Project Teaches One Hard-Earned Concept

For every project below, follow the same loop:

****Build it.**** Implement the core idea yourself before using the library version.

****Plot it.**** Make loss curves, latency curves, memory curves, attention heatmaps, routing histograms, entropy plots, or failure galleries.

****Break it.**** Ablate the thing you just built. Remove positional encodings. Disable causal masks. Quantize too aggressively. Starve the data. Collapse the router. Overload the KV cache.

****Explain it.**** Write a short technical note: What you expected, what happened, what surprised you, and what you'd try next.

****Ship the artifact.**** A repo, notebook, blog post, small demo, benchmark chart, or reproducible experiment beats vague theory.

The stack below moves from tokens to systems, then from systems to research.

## Part I: Text Becomes Tensors

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058743781537538048### 1. Build a tokenizer from scratch

Before you train a model, you decide how the world becomes symbols. That decision affects compression, multilingual behavior, rare words, code, math, emojis, latency, context usage, and model quality.

Start by implementing byte-pair encoding. Train a tiny subword vocabulary on a small corpus. Then compare it with unigram/SentencePiece-style tokenization. BPE became central because it handles rare words by composing them from subword units, while SentencePiece made tokenization trainable directly from raw text without assuming pre-tokenized whitespace-separated words.

### 2. One-hot vectors, learned embeddings, and semantic geometry

A token ID by itself has no meaning. Meaning starts when IDs become vectors. Build the simplest possible embedding table and learn it on a next-token objective.

## Part II: Position Gives Tokens Order

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744281020432384### 3. Implement sinusoidal, learned, RoPE, and ALiBi positional methods

Attention alone is permutation-invariant. Without position, "dog bites man" and "man bites dog" look too similar. The original Transformer used sinusoidal positional encodings; later systems often use learned positions, rotary position embeddings, ALiBi, or RoPE-scaling variants. RoPE encodes relative position through rotations in embedding space, while ALiBi biases attention scores based on distance and was designed to improve length extrapolation.

## Part III: Attention Makes Context Useful

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744314809741312### 4. Hand-wire scaled dot-product attention for one token

Before implementing a Transformer block, implement attention for a single query. Compute Q, K, V manually. Take the dot product. Scale it. Softmax it. Use it to form a weighted sum of values.

The Transformer replaced recurrence with attention, making it possible to parallelize training over sequences while letting every token attend to other tokens. That design choice is still the foundation of most LLMs.

### 5. Scale attention to multi-head attention

Multi-head attention lets different subspaces learn different relational patterns. Some heads may specialize in local syntax, induction-like copying, delimiter tracking, or long-range dependencies.

## Part IV: The Transformer Block

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744354525626368### 6. Build a single Transformer decoder block

Now stack the pieces: Token embedding, positional method, masked multi-head attention, residual connection, normalization, feed-forward network, and output projection.

Modern decoder blocks are typically pre-norm, use RMSNorm or LayerNorm variants, and often use gated MLPs such as SwiGLU rather than the oldest ReLU-style feed-forward block. RMSNorm simplifies LayerNorm by focusing on rescaling, and GLU/SwiGLU-style feed-forward layers have been shown to improve Transformer performance in several settings.

### 7. Stack blocks into a "mini-former"

Train a tiny decoder-only model on toy text. The point is not to build a useful chatbot. The point is to understand the training loop.

## Part V: Objectives Define What The Model Learns

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744401740857344### 8. Compare causal LM, masked LM, prefix LM, and denoising objectives

Different objectives produce different capabilities. BERT used masked language modeling to build bidirectional representations. GPT-style models use causal next-token prediction. T5 framed many NLP tasks as text-to-text generation with denoising objectives. UL2 mixed several denoising modes to cover causal, prefix, and bidirectional behavior.

## Part VI: Decoding Turns Probabilities Into Text

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744448155086848### 9. Build a sampling dashboard

A model outputs logits. A product outputs text. Decoding is the bridge.

### 10. Implement speculative decoding

Autoregressive decoding is sequential: One token depends on the previous token. Speculative decoding accelerates generation by using a smaller draft model to propose tokens that a larger model verifies, preserving the target distribution when implemented correctly.

Newer variants reduce or remove the need for a separate draft model. Medusa adds extra decoding heads to propose multiple future tokens, while lookahead decoding explores parallel candidate n-grams without an auxiliary model.

## Part VII: KV Cache And Memory-Bound Inference

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744518602543104### 11. Build a KV cache

During autoregressive inference, past keys and values do not need to be recomputed every step. KV caching stores them. This is one of the most important practical differences between training and inference.

### 12. Implement MQA, GQA, and study MLA

Standard multi-head attention gives every query head its own key and value heads. Multi-query attention shares keys and values across query heads to reduce memory bandwidth. Grouped-query attention is a middle ground that keeps several KV heads rather than one, often preserving more quality while improving inference efficiency.

By 2026, KV-cache reduction is a major architecture design axis. DeepSeek-V2 introduced Multi-head Latent Attention, a low-rank KV compression approach, and DeepSeek-V3 continued combining MLA with sparse MoE scaling.

## Part VIII: Long Context Is A Systems Problem

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744561942351872### 13. Build sliding-window attention and attention-sink experiments

Long context is not solved by increasing a number in a config file. Models can lose information, over-attend to irrelevant tokens, collapse on long sequences, or become too expensive to serve.

Mistral 7B popularized a practical combination of sliding-window attention and grouped-query attention in an open model. StreamingLLM showed that preserving early "attention sink" tokens can stabilize streaming generation over very long token streams.

### 14. Extend context with RoPE scaling, YaRN-style interpolation, and memory mechanisms

Context extension often combines positional interpolation, fine-tuning, efficient attention, and evaluation. YaRN showed that RoPE-based context extension can be much more data- and compute-efficient than some previous approaches. Infini-attention introduced a compressive memory mechanism designed to scale Transformer-like models to unbounded input lengths with bounded memory and computation.

## Part IX: Efficient Attention And Hardware-Aware Modeling

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744609237352448### 15. Compare naive attention, PyTorch SDPA, and FlashAttention

The same mathematical operation can have radically different runtime depending on memory access patterns. FlashAttention made attention faster by reducing high-bandwidth-memory reads and writes. FlashAttention-3 further optimized attention for NVIDIA Hopper GPUs using hardware-aware scheduling, asynchronous operations, and FP8 support.

### 16. Learn the hardware budget: FLOPs, bandwidth, memory, and precision

By 2026, LLM engineering is deeply hardware-constrained. NVIDIA Blackwell systems emphasize FP4/FP8 inference and large NVLink domains; DGX B200-class systems expose massive HBM capacity and bandwidth. Google's Ironwood TPU generation is positioned heavily around inference. AMD's MI300X carries 192GB HBM3 per accelerator for memory-heavy workloads.

## Part X: Mixture Of Experts

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744646805647360### 17. Build a two-expert router

Sparse Mixture-of-Experts models increase parameter count without activating every parameter for every token. Switch Transformer showed that sparse expert routing could scale model capacity efficiently. Mixtral demonstrated a practical open sparse MoE design where each token routes to a subset of experts, and DeepSeek's MoE work explored finer-grained experts and shared experts.

### 18. Reproduce modern sparse-model trade-offs

Recent frontier and open-weight systems use sparse activation heavily. DeepSeek-V3 reports 671B total parameters with 37B activated per token, using MLA, DeepSeekMoE, auxiliary-loss-free load balancing, and multi-token prediction. Llama 4 introduced Meta's first open-weight natively multimodal MoE model family. Qwen3 open-weighted two MoE models, Qwen3-235B-A22B and Qwen3-30B-A3B, plus six dense models.

Moonshot's Kimi K2 line continued the large sparse-model trend. The Kimi K2.6 model card describes a native multimodal agentic MoE model with 1T total parameters, 32B activated parameters, 256K context window, and a MoonViT vision encoder.

## Part XI: Beyond Vanilla Transformers

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744730347782145### 19. Implement a toy state-space or linear-attention model

Transformers dominate, but they are not the only serious sequence architecture. Mamba introduced selective state-space models with linear-time sequence scaling and strong throughput claims. Mamba-2 connected state-space models and attention more directly through state-space duality. RetNet proposed retention mechanisms that can train in parallel while supporting recurrent-style inference.

### 20. Build a diffusion-style language model toy

Autoregressive generation is not the only possible decoding paradigm. LLaDA trained a diffusion-style language model from scratch using masking and denoising, challenging the assumption that high-quality language modeling must be autoregressive. Dream explored open diffusion language modeling with parallel denoising. Inception's Mercury models marketed diffusion LLMs around very high generation speed.

## Part XII: Data Is The Real Pretraining Substrate

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744773372956672### 21. Build a pretraining data pipeline

Data quality is one of the highest-impact parts of the stack. FineWeb released a 15-trillion-token dataset built from Common Crawl snapshots with filtering and deduplication choices aimed at strong open pretraining. Dolma provided the open corpus behind OLMo. DataComp-LM showed how standardized data curation experiments can substantially improve model quality at fixed compute.

### 22. Synthetic data: Generate, filter, and prove it helped

Synthetic data can help when it is targeted, filtered, and evaluated honestly. The phi-1 work showed that small models trained on high-quality "textbook-like" and synthetic code data could perform surprisingly well on coding benchmarks. But synthetic data can also amplify mistakes, collapse diversity, or contaminate evaluations if used carelessly.

## Part XIII: Scaling Laws And Capacity

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744814112280576### 23. Train tiny, small, and medium models and fit scaling curves

Scaling laws quantify how loss changes with model size, data size, and compute. Kaplan-style scaling laws showed smooth power-law relationships over several orders of magnitude. Chinchilla later argued that many large models were undertrained and that compute-optimal training should scale parameters and tokens together more carefully.

## Part XIV: Post-Training Turns A Base Model Into An Assistant

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744847192801280### 24. Fine-tune, instruction-tune, and preference-tune

A base model predicts text. An assistant follows instructions. InstructGPT showed that human-feedback fine-tuning can make models more aligned with user intent than simply scaling pretrained models. Direct Preference Optimization later simplified preference training by avoiding an explicit reward model and RL loop in many settings.

### 25. Build a toy RLHF, PPO, GRPO, and RLVR lab

Reinforcement learning became especially important for reasoning models. OpenAI's o1 system card emphasized that performance improves with more reinforcement learning and more inference-time thinking. DeepSeek-R1 popularized an open discussion of reasoning-oriented RL, including a pure-RL R1-Zero stage and a multi-stage pipeline for the final model. DeepSeekMath introduced Group Relative Policy Optimization as a PPO-style alternative that reduces memory overhead by avoiding a separate critic model.

## Part XV: Quantization And Compression

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744909868216320### 26. Quantize a model and measure the damage

Quantization is not just "make it smaller." It changes numerical behavior, latency, memory bandwidth, and sometimes model quality.

GPTQ demonstrated one-shot post-training quantization for very large language models. AWQ showed that protecting a small fraction of salient weights can improve low-bit quantization. GGUF became a widely used file format in the llama.cpp ecosystem for local inference.

## Part XVI: Serving Systems

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058744958484377600### 27. Serve the same model through multiple inference stacks

LLM serving is its own discipline. vLLM introduced PagedAttention to reduce KV-cache memory waste and support efficient serving. TensorRT-LLM includes features such as in-flight batching, paged attention, quantization, and multi-GPU execution. SGLang emphasizes fast structured generation with features such as RadixAttention, prefix caching, scheduling, speculative decoding, and disaggregated serving.

## Part XVII: Evaluation Stops Guessing

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058745008228814849### 28. Build an evaluation harness

If you cannot measure a model, you cannot improve it. HELM argued for broad evaluation across accuracy, calibration, robustness, fairness, bias, toxicity, and efficiency. MMLU became a standard benchmark for broad knowledge and reasoning across many subjects. The EleutherAI language-model evaluation harness became a common open tool for standardized evaluation.

## Part XVIII: Retrieval, Tools, And Agents As Capstones

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058745042609557504### 29. Build retrieval-augmented generation from scratch

RAG combines parametric memory in the model with non-parametric memory in an external corpus. The original RAG work showed that retrieval can improve knowledge-intensive tasks and make outputs easier to update or ground.

### 30. Build tool use and agent loops only after you understand the stack

Agents are not fake, but they are fragile when treated as magic. ReAct showed that interleaving reasoning traces with actions can improve task solving and interpretability. Toolformer showed that models can learn to use external APIs from self-supervised signals. DSPy reframed LM pipelines as programs whose prompts and weights can be optimized.

## Part XIX: Multimodal LLMs

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058745086888841216### 31. Build a tiny vision-language adapter

Modern LLMs increasingly consume text, images, audio, video, and structured tool outputs. CLIP showed the power of contrastive image-text pretraining. Flamingo connected frozen vision and language models for few-shot multimodal learning. LLaVA demonstrated visual instruction tuning by connecting a vision encoder to an LLM. By 2026, systems such as Llama 4 and Kimi K2.6 emphasize native multimodality rather than treating vision as a side feature.

## Part XX: Interpretability And Failure Modes

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058745128076926977### 32. Study circuits, probes, and sparse autoencoders

Mechanistic interpretability tries to understand what models compute internally. Transformer-circuits work decomposed attention and MLP behavior into more interpretable components. Anthropic's sparse-autoencoder work showed that learned features can be more interpretable than individual neurons and can sometimes isolate concepts across large models.

### 33. Build a red-team and safety evaluation suite

As models become more capable, safety evaluation becomes part of engineering. Constitutional AI explored using a written set of principles plus AI feedback to reduce reliance on direct human labels. Red-teaming research has shown how manual and automated adversarial attacks can uncover harmful behaviors. Broader AI safety reports synthesize risks across misuse, malfunction, systemic impacts, and loss of control.

## Part XXI: The Final Capstone Builds A Complete Small LLM System

https://x.com/TheAhmadOsman/article/2058745340895870985/media/2058745210885038080### 34. Train, tune, quantize, serve, evaluate, and document one model

Your final project should connect the entire stack.

## A realistic lock-in plan

A few weeks is enough to change your instincts. A few months is enough to build a serious foundation.

****Weeks 1-2: Representations and attention****

Build the tokenizer, embeddings, positional encodings, attention, masking, multi-head attention, and a one-block Transformer.

****Weeks 3-4: Training and objectives****

Train a mini-former, compare objectives, build sampling tools, study normalization and activations, and run your first ablations.

****Weeks 5-6: Inference systems****

Implement KV cache, MQA/GQA, speculative decoding, quantization, and serving benchmarks.

****Weeks 7-8: Long context, MoE, and data****

Build sliding-window attention, context-extension tests, a toy MoE, and a real data pipeline.

****Weeks 9-10: Post-training and evaluation****

Run SFT, LoRA/QLoRA, DPO, toy RL, benchmark harnesses, and safety evals.

****Weeks 11-12: Capstone****

Train or fine-tune one small model, quantize it, serve it, add RAG/tools, evaluate it, red-team it, and publish the full write-up.

The exact schedule matters less than the loop: Build, plot, break, explain.

## What to publish after every project

For each project, produce five artifacts:

1. ****Implementation:**** clean code with tests.
2. ****Notebook:**** one reproducible experiment.
3. ****Plots:**** at least three charts showing behavior.
4. ****Failure gallery:**** examples where the system breaks.
5. ****Short write-up:**** what you learned and what changed your mind.

Do not just post "I implemented attention." Post the heatmaps. Post the mask bug. Post the entropy curve. Post the latency chart. Post the weird repetition loop. Post the expert-routing collapse. Post the quantization regression. Post the safety failure you did not expect.

That is how fundamentals compound.

## The mindset

Do not get stuck in theory forever. But also do not mistake demos for understanding.

An agent framework can hide the model. A serving framework can hide the cache. A benchmark can hide leakage. A product can hide the failure modes. A wrapper can hide the fact that the model is doing all the work.

Fundamentals remove the hiding places.

Learn tokenization. Learn embeddings. Learn position. Learn attention. Learn residual streams. Learn normalization. Learn objectives. Learn sampling. Learn KV cache. Learn long context. Learn MoE. Learn quantization. Learn data. Learn scaling. Learn post-training. Learn serving. Learn evaluation. Learn safety. Learn failure modes.

Then build agents. Build products. Build companies. Build labs.

But build them on bedrock.

Your future self will thank you.

Until next time.

****-Ahmad****

> 📄 Original article URL: https://x.com/i/article/2058742259261014016

