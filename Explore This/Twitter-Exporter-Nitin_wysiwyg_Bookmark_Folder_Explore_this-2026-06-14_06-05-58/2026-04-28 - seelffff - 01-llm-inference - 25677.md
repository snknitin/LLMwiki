---
title: "01 llm inference"
author: "self.dll"
username: "@seelffff"
date: "2026-04-28"
tweet_url: "https://x.com/seelffff/status/2049214021430325677"
tweet_type: "original"
likes: 590
retweets: 62
replies: 20
bookmarks: 2416
views: 690978
has_media: false
extraction_quality: full
article_id: "2049150348128886785"
tags: ["twitter-bookmark", "claude", "mcp", "llm", "agents"]
---

# 01 llm inference

> **Source:** [@seelffff](https://x.com/seelffff) · 2026-04-28 · 👍 590 · 💬 20 · 🔖 2416 · 👁 690978

> 🔗 [View tweet on X](https://x.com/seelffff/status/2049214021430325677)

## Article Content

the average AI startup pays $8,000â€“$50,000/year in tool subscriptions.

the people actually building AI - researchers, engineers, indie hackers - use open-source. they always have.

i went through 300+ repos. pulled out 69 that are production-ready, actively maintained, and genuinely useful.

****this is the full AI stack. free.****

### This is the toolbox.

****what's inside:****

- ****01 llm inference -**** run models locally. no api. no limits. no bill.
- ****02 rag & knowledge -**** make ai answer from your own data.
- ****03 ai agents -**** let the model act, not just answer.
- ****04 prompts & evals -**** stop guessing. start measuring.
- ****05 fine-tuning -****make the model yours.
- ****06 tools & context -****feed the model what it actually needs.
- ****07 deployment -****ship it. then scale it.
- ****08 claude-specific -**** if you use claude, these are not optional.
- ****09 data prep -**** garbage in, garbage out. fix the input.
- ****10 vision & multimodal -**** beyond text.
- ****69 bonus -**** don't want to run all this yourself?

https://x.com/seelffff/article/2049214021430325677/media/2049213532974231552

## 01 llm inference

run models locally. no api. no limits. no bill.

### 01 ollama â˜… 98K - github.com/ollama/ollama

run llama, mistral, qwen, gemma locally with one command. the fastest way to get a model running on your machine. `ollama run llama3` and you're done. supports gpu acceleration, rest api, openai-compatible endpoints.

### 02 llama.cpp â˜… 72K - github.com/ggml-org/llama.cpp

llm inference in pure c++. runs on cpu, gpu, apple silicon. the engine behind most local ai tools. if ollama is the car, llama.cpp is the engine. extremely fast, low memory usage.

### 03 vllm â˜… 44K - github.com/vllm-project/vllm

high-throughput llm serving engine for production. continuous batching, paged attention, openai-compatible api. the standard for deploying models at scale. used by most serious ai companies.

### 04 lm studio â˜… 28K

desktop app for running local llms with a clean ui. download models from hugging face, run them locally, get an openai-compatible local server. best onboarding for non-developers.

[github.com/lmstudio-ai/lmstudio.js](https://x.com//github.com/lmstudio-ai/lmstudio.js)

### 05 jan â˜… 26K - github.com/janhq/jan

open-source chatgpt alternative that runs 100% offline. clean ui, model management, local api server. works on mac, windows, linux. no data leaves your machine.

### 06 text-generation-webui â˜… 42K - github.com/oobabooga/text-generation-webui

the swiss army knife for local llms. supports every model format, every backend, every sampler. character mode, notebook mode, api mode. the most feature-complete local ui that exists.

### 07 localai â˜… 26K - github.com/mudler/LocalAI

self-hosted openai drop-in replacement. same api, local models. swap claude/gpt with local llms in any app without changing a single line of code.

## 02 rag & knowledge

make ai answer from your own data.

### 08 langchain â˜… 98K - github.com/langchain-ai/langchain

the most popular llm framework. chains, agents, retrievers, memory. connects llms to any data source or tool. massive ecosystem of integrations. if you're building anything with ai, you'll hit langchain eventually.

### 09 llamaindex â˜… 38K - github.com/langchain-ai/langchain

data framework for llm applications. index any data source - pdf, sql, notion, slack - and query it with natural language. better than langchain for pure rag use cases.

### 10 rag-anything â˜… 12K - github.com/HKUDS/RAG-Anything

multimodal rag for claude and other llms. handles text, tables, images, charts, graphs. not just pdfs - actually everything. 6 lines to set up. used in production by serious teams.

### 11 chroma â˜… 16K - github.com/chroma-core/chroma

the open-source vector database. store embeddings, search by similarity, filter by metadata. runs in-memory or persistent. the simplest way to add semantic search to any project.

### 12 weaviate â˜… 12K - github.com/weaviate/weaviate

vector database with built-in ml models. hybrid search, multi-tenancy, real-time updates. production-ready, scales to billions of objects. used by companies you've heard of.

### 13 haystack â˜… 18K - github.com/deepset-ai/haystack

end-to-end nlp framework for rag pipelines. modular, production-ready, works with any llm or vector db. the most mature rag framework available.

### 14 docling â˜… 22K - github.com/DS4SD/docling

convert documents to structured markdown for ai. handles pdfs with tables, figures, formulas - not just plain text extraction. built by ibm research.

## 03 ai agents

let the model act, not just answer.

### 15 autogen â˜… 40K - github.com/microsoft/autogen

multi-agent conversation framework by microsoft. agents talk to each other, delegate tasks, write and execute code. the most powerful framework for complex agentic workflows.

### 16 crewai â˜… 28K - github.com/crewAIInc/crewAI

orchestrate role-playing ai agents. define a crew, assign roles, set goals â€” agents collaborate like a team. easiest way to build multi-agent systems that actually work.

### 17 langgraph â˜… 10K - github.com/langchain-ai/langgraph

build stateful multi-agent workflows as graphs. nodes are agents or functions, edges are transitions. handles complex logic, loops, human-in-the-loop. the production-grade agent framework.

### 18 agno â˜… 22K - github.com/agno-agi/agno

build fast multi-modal ai agents. supports any llm, any tool, memory, knowledge, storage. 10x faster than langchain for simple agents. clean api, excellent documentation.

### 19 smolagents â˜… 14K - github.com/huggingface/smolagents

minimal agent framework by hugging face. code agents that write and execute python to solve tasks. incredibly simple - 1000 lines of code total. the anti-langchain.

### 20 openhands â˜… 48K - github.com/All-Hands-AI/OpenHands

open-source devin alternative. ai software engineer that writes code, runs tests, fixes bugs, deploys. works with claude, gpt-4, local models. the most capable coding agent.

### 21 superagi â˜… 16K - github.com/TransformerOptimus/SuperAGI

self-hosted autonomous ai agent infrastructure. agent marketplace, performance telemetry, concurrent agents, graphical ui. run multiple agents in parallel on your own server.

### 04 prompts & evals

stop guessing. start measuring.

### 29 dspy â˜… 22K - github.com/stanfordnlp/dspy

programming - not prompting - llms. define what you want, dspy optimizes the prompts automatically. from stanford nlp. replaces manual prompt engineering with systematic optimization.

### 30 guidance â˜… 20K - github.com/guidance-ai/guidance

control llm output structure with code. interleave generation with logic, force json schemas, constrain outputs. when you need the model to output exactly what you need.

### 31 outlines â˜… 11K - github.com/dottxt-ai/outlines

structured text generation. force models to output valid json, regex patterns, specific formats. zero prompt engineering needed - guaranteed output structure.

****32 ****[promptfoo](https://github.com/promptfoo/promptfoo)

 â˜… 6K - [github.com/promptfoo/promptfoo](https://github.com/promptfoo/promptfoo)

test and eval your prompts. run automated tests, compare models, catch regressions. like unit tests but for ai. essential before shipping anything to production.

### 33 braintrust â˜… 3K - github.com/brainlid/langchain

eval framework for llm apps. track quality across model versions, prompts, and configurations. because vibes aren't a metric.

### 34 instructor â˜… 9K - github.com/instructor-ai/instructor

structured outputs from llms using pydantic. define a schema, get back a validated python object. works with openai, anthropic, google, local models. the cleanest structured output solution.

## 05 fine-tuning

****make the model yours.****

### 35 unsloth â˜… 24K - github.com/unslothai/unsloth

fine-tune llms 2x faster, 80% less memory. supports llama, mistral, qwen, gemma. runs on a single gpu. the only fine-tuning library you need if you're resource-constrained.

### 36 axolotl â˜… 8K - github.com/axolotl-org/axolotl

streamlined fine-tuning for llms. yaml config, every dataset format, every training technique. the ops layer on top of hugging face transformers. used by most serious fine-tuners.

### 37 llama-factory â˜… 40K - github.com/hiyouga/LLaMA-Factory

fine-tune 100+ llms with zero code. web ui, supports lora, qlora, full fine-tuning. the most user-friendly fine-tuning tool available. 40K stars for a reason.

### 38 trl â˜… 12K - github.com/huggingface/trl

transformer reinforcement learning. rlhf, dpo, ppo - the techniques used to align gpt-4 and claude. by hugging face. for when you want to train models to do what you actually want.

### 39 torchtune â˜… 5K - github.com/pytorch/torchtune

pytorch-native fine-tuning library from meta. simple, hackable, well-documented. the reference implementation for fine-tuning in pure pytorch.

### 40 mergekit â˜… 4K - github.com/arcee-ai/mergekit

merge multiple fine-tuned models into one. slerp, ties, dare, linear merge - all the techniques. no gpu needed for merging. create frankenstein models that outperform their parents. used by everyone releasing merged models on hugging face.

## 06 tools & context

feed the model what it actually needs

### 41 markitdown â˜… 38K - github.com/microsoft/markitdown

convert any file to markdown. pdf, word, excel, powerpoint, images, audio. feeds clean structured text to your llm instead of garbage. by microsoft. 38K stars.

### 42 files-to-prompt â˜… 3K - github.com/simonw/files-to-prompt

turn your entire codebase into one prompt. respects .gitignore, recursive, filterable. by simon willison. the simplest tool for feeding projects to claude.

### 43 crawl4ai â˜… 30K - github.com/unclecode/crawl4ai

web scraping for ai. extracts clean markdown from any url, handles js-heavy sites, structured data extraction. the web data layer for any ai pipeline.

### 44 firecrawl â˜… 25K - github.com/mendableai/firecrawl

turn any website into llm-ready data. full site crawling, structured extraction, clean markdown output. the production-grade web scraper for ai apps.

### 45 playwright-mcp â˜… 31K - github.com/microsoft/playwright-mcp

give claude a real browser. navigate, click, screenshot, read dynamic content. analyze any site in 30 seconds. the most powerful mcp server for web tasks.

### 46 model-context-protocol â˜… 11K - github.com/anthropics/model-context-protocol

the standard for connecting claude to external tools. official anthropic mcp. plug in any api, database, service. hundreds of servers in the ecosystem.

### 47 awesome-mcp-servers â˜… 27K - github.com/punkpeye/awesome-mcp-servers

500+ ready-made mcp servers. github, slack, notion, databases, browsers, finance. every integration you'll ever need in one catalog.

### 48 n8n â˜… 47K - github.com/n8n-io/n8n

self-hosted workflow automation with 400+ integrations. connect llms to any app. trigger ai workflows on schedules or webhooks. run custom js/python in nodes. the automation layer behind serious ai pipelines. replaces $50K/year zapier.

## 07 deployment

ship it. then scale it.

### 49 litellm â˜… 16K - github.com/BerriAI/litellm

one api for 100+ llms. openai format, works with claude, gpt, gemini, local models. load balancing, fallbacks, cost tracking. the proxy layer between your app and every llm provider.

### 50 bentoml â˜… 7K - github.com/bentoml/BentoML

build and deploy ai services. package models, create apis, deploy anywhere. from local testing to production kubernetes. the mlops layer that doesn't require a devops team.

### 51 ray serve â˜… 34K - github.com/ray-project/ray

distributed ai inference at scale. serve multiple models, autoscale, handle millions of requests. used by openai, anyscale, production ai companies. overkill until you need it.

### 52 triton inference server â˜… 8K - github.com/triton-inference-server/server

nvidia's production inference server. maximum gpu utilization, dynamic batching, multi-model serving. the standard for gpu inference in enterprise.

### 53 lorax â˜… 3K - github.com/predibase/lorax

serve hundreds of lora fine-tuned models on one gpu. one base model, hundreds of adapters loaded dynamically. 10x cost reduction for serving fine-tuned models.

### 54 supabase â˜… 73K - github.com/supabase/supabase

the default backend for ai applications. open-source firebase alternative built on postgres. real-time database, auth, storage, edge functions, vector search. 73K stars. replaces firebase + auth0 ($15K/year).

## 08 claude-specific

if you use claude, these are not optional.

### 55 obra/superpowers â˜… 160K - github.com/obra/superpowers

adds superpowers to claude code. deep code analysis, auto-refactor, project-wide editing. works as a layer on top of the official cli. 160K stars. the most popular claude enhancement.

### 56 claude-code-skills â˜… official - github.com/anthropics/claude-code-skills

official anthropic skills framework. skill.md patterns that teach claude to handle documents, automations, workflows without errors. the foundation of how claude code handles complex tasks.

### 57 free-claude-code â˜… 2K - github.com/Alishahryar1/free-claude-code

run claude code completely free via github models api. trending #1 on github. step by step guide + setup scripts. $0. forever.

### 58 claude-mem â˜… 1K - github.com/thedotmack/claude-mem

persistent memory for claude. auto-captures everything claude does across sessions. replaces paid context management tools. claude remembers who you are and what you're working on.

## 09 data prep

garbage in, garbage out. fix the input.

### 59 unstructured â˜… 10K - github.com/Unstructured-IO/unstructured

extract and transform unstructured data for llms. pdfs, html, word, images, emails - all parsed into clean chunks ready for rag. the data layer most ai pipelines are missing.

### 60 datatrove â˜… 3K - github.com/huggingface/datatrove

large-scale data processing for llm training. by hugging face. process terabytes of text with deduplication, quality filtering, and content classification. what the big labs use.

### 61 trafilatura â˜… 3K -github.com/adbar/trafilatura

web content extraction for ai. strips boilerplate, keeps content, outputs clean text or markdown. the best single-page web extractor for feeding text to models.

****62 ****[semchunk](https://github.com/umarbutler/semchunk)

 â˜… 1K - [github.com/umarbutler/semchunk](https://github.com/umarbutler/semchunk)

semantic text chunking for rag. splits text at natural boundaries instead of arbitrary token counts. better chunks â†’ better retrieval â†’ better answers.

### 63 datachain â˜… 2K - github.com/iterative/datachain

ai-native dataset management. version, query, and transform multimodal datasets. works with images, video, text, embeddings. built for llm training workflows

## 10 vision & multimodal

beyond text.

### 64 moondream â˜… 10K - github.com/vikhyat/moondream

tiny vision language model that runs anywhere. 1.6B parameters. describe images, answer visual questions, detect objects. runs on a raspberry pi. the smallest useful vision model.

### 65 internvl â˜… 7K - github.com/OpenGVLab/InternVL

state of the art open-source vision model. matches gpt-4v on most benchmarks. understand images, charts, documents, screenshots. the open alternative to claude's vision.

### 66 whisper â˜… 74K - github.com/openai/whisper

open-source speech recognition by openai. transcribes audio in 99 languages. runs locally, handles accents, background noise, technical jargon. feed audio to your llm pipeline.

### 67 insanely-fast-whisper â˜… 8K - github.com/Vaibhavs10/insanely-fast-whisper

whisper but 10-20x faster. one command, automatic gpu optimization, batch processing. transcribe a 2-hour podcast in 2 minutes on consumer hardware.

### 68 stable-diffusion-webui â˜… 143K - github.com/AUTOMATIC1111/stable-diffusion-webui

the browser interface for stable diffusion. generate, edit, upscale images from text. 143K stars - the most starred ai repo outside llms. hundreds of extensions, styles, controlnet, inpainting. runs on your gpu.

## 69 kreo - copy the top polymarket traders â˜… - http://t.me/KreoPolyBot?start=ref-kreohub

kreo tracks the top-performing wallets on polymarket in real time and automatically copies their trades. no code, no monitoring, runs 24/7. the top polymarket traders use sophisticated models to find mispriced markets -kreo lets you follow them without building the infrastructure yourself.a

## that's all 69

> 📄 Original article URL: https://x.com/i/article/2049150348128886785

---

## Commentary from Other Bookmarks

### @ArchiveExplorer (Archive) — 2026-04-28

> This guy works at coinbase. in his spare time he built the largest open dataset for polymarket and kalshi
> 
> 72,100,000 trades. 7,680,000 markets. open source
> 
> - figured out who actually makes money on prediction markets
> - wrote a research paper with the math to prove it
> - 3,100 stars on github just for that
> 
> also built heimdall-rs - rust toolkit for evm bytecode analysis. 1,500 stars. serious dev
> 3,008 contributions in the last year
> 
> while everyone's posting takes about polymarket - he's building the infrastructure underneath it
> 
> → http://github.com/Jon-Becker
> 
> like + bookmark. you'll need this when you build your first polymarket bot

[→ View quote tweet](https://x.com/ArchiveExplorer/status/2049240711887790264)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

