---
updated: 2026-09-28
status: research-ready; experiments pending
machine: Windows RTX PRO 5000 Blackwell workstation, with explicitly gated Spark exceptions
---

# Social Capture Local AI Model Exploration Guide

This is the execution order for the local-model leads in the live Social Capture dashboard as checked on 2026-09-28. It is **not** an installation receipt: no model, ComfyUI instance, application, or package was installed or benchmarked for this guide. The individual tutorials contain the exact captured source links, direct X-post/reply checks, model-card evidence, commands, pass/stop criteria, and limitations. Leave the existing ODS, Ollama, LM Studio, Hermes, LiteLLM, and `spark-fast` routes untouched during these trials.

## Start here: machine and safety boundary

The workstation has an NVIDIA RTX PRO 5000 Blackwell with **48,935 MiB VRAM** and approximately **127 GB system RAM**; the installed NVIDIA driver was **596.59** at the research snapshot. Recheck `nvidia-smi`, RAM, free disk, and other GPU processes before every trial. This machine is the first home for Qwen image work, H3 quantized video trials, small model experiments, EVIE retrieval, and Portable Computer. The two Sparks are separate production/experimental lanes; a tutorial's Spark fallback is not permission to interrupt their resident services.

Use a separate project directory and isolated environment for each family. Record a repository commit or Hugging Face revision and SHA-256 for every weight. Preview large downloads before fetching them; file size is not peak VRAM. Download only one candidate stack at a time, close/unload it, and check VRAM returns before proceeding. Do not add a new model to Ollama, ODS, LiteLLM, Hermes, or an always-on service until a raw local test passes and its role is chosen. For body/head swaps, use consented images, respect the model author's no-public-figure/no-nonconsensual-use request, and keep outputs private until rights are checked.

The names “Qwen Image 2.1 body swap,” “head swap,” and “uncensored” describe **different artifacts**. The Social Capture body-swap item links the BFS repository containing both Qwen 2.1 body and head LoRAs; the uncensored GGUF was found in follow-on research, not in that captured item's source list. “Phase swap” in the earlier question is not an independently verified model name in these sources; test the actual published **face/head** and **body** files, not a guessed download.

## Suggested order and decision gates

| Session | Read and run | Why this order; stop condition |
|---|---|---|
| 0. Preflight | Recheck hardware, free disk, GPU ownership, licenses, and source revisions; pick consented/sample inputs. | No downloads if an existing GPU service is already under pressure or the intended model/license is unclear. |
| 1. Qwen image baseline | [[RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial]] | Establish one plain text-to-image and one edit output with the base denoiser, Qwen3-VL encoder, VAE, and pinned workflow. Record peak VRAM and seed. Do not evaluate LoRAs on an unproven base. |
| 2. BFS body, then head | [[RTX PRO 5000 Qwen Image 2.1 BFS Body Swap Windows Tutorial]]; [[RTX PRO 5000 Qwen Image 2.1 BFS Head Swap Windows Tutorial]] | One LoRA at a time against a saved no-LoRA reference. For body, scene is `<image1>` and full-body plain-background identity reference is `<image2>`; compare identity, clothing, pose, framing, and background. Head V1.1 is the author's recommended head file. Stop if the easy consented case loses identity or alters the background. |
| 3. Qwen variant A/B | [[RTX PRO 5000 Qwen Image 2.1 Uncensored Variant Windows Tutorial]] | Only after the original base works. Verify publisher, license, weight relationship, and full-pipeline memory; “no safety checker” is not proof of an independently trained or demonstrably uncensored model. Use a benign matched prompt set first. |
| 4. Video baseline | [[MiniMax H3 Windows Video Exploration Tutorial]]; [[MiniMax H3 Handheld Shaky Cam LoRA Windows Tutorial]] | Try stock local H3 Base with quantized Comfy-Org files before community Turbo, Realism, or Handheld Shaky Cam LoRAs. Test camera LoRA off/on with the Civitai author's high-noise/strength guidance isolated from other adapters. H3 Max's livestream is a hosted-service lead, not a local downloadable H3 Max recipe. Stop on missing nodes, OOM, broken audio, or an API-only dependency. |
| 5. H3 motion-guided character swap | [[MiniMax H3 Character Swap LoRA Windows Tutorial]] | This is a **Ref2VA** video-edit adapter, distinct from both Qwen image swaps and H3 FL2VA text-to-video. Test short consented source-video/reference-image pairs after H3 Ref2VA works. The [specific fnoji post](https://x.com/fnoji/status/2103865411754459347) suggests enabling the LoRA on a Context continuation when motion tracing drifts; fresh-generation use may also pull the reference body shape. Treat this as a creator observation to A/B, not a reliable correction. |
| 6. Longer avatar video | [[LongCat Video Avatar 1.5 Workstation Feasibility Tutorial]] | Establish whether the official code/weights and 48 GB Windows path are practical before any large download. Preserve the one-Spark fallback as a separate, approved experiment; it does not inherit the H3 setup. |
| 7. Separate LTX conversation stack | [[Realtime Conversation Video Windows Feasibility Tutorial]] | The captured repository is a client in a multi-service LTX-2.5/LLM/TTS system, **not H3**. Qualify renderer, audio-input LLM, and client separately in an isolated WSL2/Linux environment; one-GPU real-time performance is unproved on this desktop. |
| 8. Retrieval and decisions | [[RTX PRO 5000 EVIE Visual Document Retrieval Tutorial]]; [[RTX PRO 5000 Laya Decision Model Tutorial]] | EVIE ranks page images; it is not a chat answerer. Compare Preview with the newer publisher 4.5B on the same labeled pages. Compare Laya's typed decisions against a deterministic baseline and human labels; speed alone is not accuracy. |
| 9. Application and audit | [[RTX PRO 5000 Perplexity Portable Computer Tutorial]]; [[RTX PRO 5000 Qwen 3.8 BF16 LM Head Audit Tutorial]] | Portable Computer is an application/device trial with its own Windows requirements and privacy boundary. The Qwen `lm_head` item is a checkpoint/quantization claim audit, not a request to overwrite the existing Qwen 3.8 Ollama or Spark routes. |
| 10. Evaluation methods | [[RTX PRO 5000 Jev Agent Decision Evaluation Tutorial]]; [[RTX PRO 5000 Local Inference Measurement Tutorial]] | Validate judge/routing claims against human-labeled held-out cases; use llama.cpp flags in a disposable benchmark, not by silently replacing the production model shelf. |

The [local real-time video conversation client](https://github.com/animede/Realtime_Conversation_Video) captured alongside Shaky Cam is **not** MiniMax H3. It composes an audio-input LLM, TTS, and LTX-2.5 video services. Its prerequisites and reply-level latency hints are documented in [[Realtime Conversation Video Windows Feasibility Tutorial]]; do not mistake the client's `run.sh` for a complete one-GPU Windows installer. The [OpenMontage repository](https://github.com/calesthio/OpenMontage), if retained for later testing, is a separate video-tool lead, not an H3 weight.

The separately supplied [fnoji X post](https://x.com/fnoji/status/2103865411754459347) was checked by its exact root ID and links [akatz-ai's H3 Character Swap LoRA](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA). It was **not** in the initial captured task list. It adds a concrete continuation-versus-fresh-generation tip; the adapter's published card supplies the base-model, strength, prompt, short-shot, and license details in its own tutorial.

## What to record for every experiment

Save one plain-text record plus representative inputs/outputs outside this vault (avoid private images or large weights in Obsidian):

```text
Experiment/date:
Machine/GPU/driver and free VRAM at start:
Repository URL/commit; model URL/revision; exact filenames/SHA-256; license:
Runtime/version and isolated install path:
Input rights/consent and test-set ID:
Task, prompt, seed, resolution, frames/steps, adapters and strengths:
Cold load, warm run, peak VRAM/RAM, disk consumed, errors:
Baseline result versus candidate; quality rubric and failure cases:
Cleanup/unload proof; keep, adapt-and-retest, or reject; next action:
```

For image editing, score identity, clothing, pose, background, text, and artifacts separately. For video, add audio synchronization, temporal consistency, render duration, and end-to-end time—not just VAE timing. For retrieval, add recall/precision at K and index bytes per page. For decisions/evals, add a confusion matrix, false-action cost, coverage/abstention, held-out accuracy, and p50/p95 *end-to-end* latency. For application agents, record privacy boundary, actual tool permissions, success/failure and rollback. Do not promote a model based on a viral screenshot, publisher benchmark, or X reply alone.

## Social Capture provenance and scope

The live Spark dashboard's `/api/tasks` was the source of the following open tasks; the Windows-synced action queue was older at the time of research. Each individual tutorial names its applicable task IDs and lists **all captured URLs for that model** with access/result notes. Exact X `status` IDs were checked using thread lookups that returned matching root posts; useful replies are cited individually in the tutorials. A home-page redirect in a visual browser is not evidence that a specific post or its replies were inspected.

| Captured task | Model/repo/tip carried into this guide |
|---|---|
| `sc_2ab42ca49ac53673` | BFS Qwen Image 2.1 body/head source repository and body author/repost X threads. |
| `sc_acdf7e80cbebe89d` | Qwen Image 2.1 GGUF/ComfyUI release; MiniMax H3 5070 creator stack and ComfyUI VAE optimization. |
| `sc_24747b719124dc16` | MiniMax H3 Handheld Shaky Cam LoRA; separate real-time video conversation client. |
| `sc_4348b5fff10f6ef9` | MiniMax H3 Max livestream claim, checked against official hosted/local product identity. |
| `sc_c03359e24eacea9c` | LongCat-Video-Avatar 1.5 source X post among an unrelated combined task. |
| `sc_b6ec853131d3d3ce` | EVIE visual document retrieval source X post among unrelated infrastructure tips. |
| `sc_79e697fa7ff15714` | Laya model, Jev decision/evaluation articles, Hermes Jev skill repo and social pointers. |
| `sc_db74d7ad59d793e8` | MiniMax H3 Max, Qwen 3.8 BF16 `lm_head`, PPLX Portable Computer, and other unrelated consolidated links. |
| `sc_455689100f3c696a` | Hamel Husain's Jev eval validation and llama.cpp CLI study. |

The dashboard's consolidated tasks also contain unrelated links (finance, marketing, coding prompts, general video tools). This guide does not claim to complete those tasks or change their open status. The uncensored Qwen variant is a clearly marked follow-on comparison, not an original Social Capture URL. See [[Task Checklist#8J — Social Capture Windows local-model exploration]] for the pending execution checkboxes; **writing these notes does not tick off any model run**.

## Exact source tweets opened in the Codex in-app browser

These **19 exact status URLs** were opened as separate in-app tabs and checked by URL and post title on 2026-09-28; the user's pre-existing browser tab was left untouched. The individual tutorials explain what each post and its material replies actually establish. The fnoji and toyxyz posts were supplemental to the live Social Capture queue.

| Topic | Direct post links |
|---|---|
| Qwen Image 2.1 and BFS | [Unsloth GGUF](https://x.com/UnslothAI/status/2102431304591761728) · [BFS author](https://x.com/Alissonerdx/status/2104336590826840303) · [BFS repost](https://x.com/aisearchio/status/2104366377977196668) |
| MiniMax H3 and other video | [TomW H3 creator stack](https://x.com/Tomw852/status/2102593811503271963) · [ComfyUI H3 VAE](https://x.com/ComfyUI/status/2102499304724381707) · [H3 Max](https://x.com/rehan_shei/status/2093528415576211819) · [Handheld Shaky Cam](https://x.com/SD_Tutorial/status/2103763712356356167) · [fnoji Character Swap tip](https://x.com/fnoji/status/2103865411754459347) · [toyxyz Character Swap demo](https://x.com/toyxyz3/status/2103933651797045300) · [real-time video chat](https://x.com/uzuki425/status/2104115350614995055) · [LongCat Avatar](https://x.com/0xJokker/status/2090441836317811176) |
| Other models/apps | [EVIE](https://x.com/TeksEdge/status/2091924068681625781) · [Laya](https://x.com/NFT_Chen/status/2101675124747338229) · [Portable Computer](https://x.com/perplexity_ai/status/2092268362386780270) · [Qwen BF16 head](https://x.com/MiaAI_lab/status/2092017038319386782) |
| Evaluation and runtime | [Hamel on Jev evals](https://x.com/HamelHusain/status/2104305090743992821) · [llama.cpp flags](https://x.com/sudoingX/status/2104017679908540472) · [Jev decision harness](https://x.com/omarsar0/status/2103139055013646646) · [Jev-as-a-Judge](https://x.com/dair_ai/status/2103147453717545278) |

