# Realtime Conversation Video Windows Feasibility Tutorial

> [!info] Research and execution status — 2026-09-28
> Repositories and captured X thread audited; the client and renderer were not installed or run. This is a separate LTX-2.5 character conversation stack, not a MiniMax H3 workflow. The first trial belongs in an isolated WSL2/Linux environment on the RTX PRO 5000 desktop.

## What the repo actually contains

[Realtime_Conversation_Video](https://github.com/animede/Realtime_Conversation_Video) is a small FastAPI/browser **conversation client**. It receives microphone or text input, calls an OpenAI-compatible audio-input LLM, and sends finished replies to [Realtime_Narration_Video](https://github.com/animede/Realtime_Narration_Video) for TTS and video playback. The renderer in turn uses [diffusers-movie-server](https://github.com/animede/diffusers-movie-server) and [diffusers-ltx2_5](https://github.com/animede/diffusers-ltx2_5) with LTX-2.5 weights. AivisSpeech supplies voice. The client repo contains **no model weights**. The [English README](https://github.com/animede/Realtime_Conversation_Video/blob/main/README.en.md) documents these boundaries and ports.

```text
Browser mic/text → conversation client :8791 → audio-input LLM
                → renderer :8782 → TTS :10101 + movie gateway :8630 → LTX-2.5 video
```

The [author's captured X post](https://x.com/uzuki425/status/2104115350614995055) calls the demo “fully local, single GPU” and says microphone audio goes directly to the LLM as `input_audio`, so ASR is outside the **reply-critical path**. The repository clarifies that transcription still runs in parallel for display/history, browser VAD cuts after about **900 ms silence**, recent turns are kept and older ones summarized, and the UI stores per-character ROLE prompts in browser localStorage. Those are implementation details to verify in the user-run trial, not proof of the workstation's end-to-end latency. [Client README](https://github.com/animede/Realtime_Conversation_Video/blob/main/README.en.md).

## Windows workstation feasibility

The lightweight FastAPI client could run under Windows Python, but its shipped `run.sh` is Bash and its renderer/movies stack are documented as Unix-style services. Use **WSL2 Ubuntu** or an isolated Linux host for the first complete test rather than patching each layer for native Windows. The desktop's RTX PRO 5000 Blackwell has 48 GB-class VRAM; the [renderer README](https://github.com/animede/Realtime_Narration_Video) estimates roughly **33 GB resident** for its 48 GB `nvfp4-fast` video path. That is renderer-only headroom: a second GPU or CPU/other local host may be needed for the audio-input LLM and TTS. The author's 32 GB-equivalent demo explicitly placed AivisSpeech on a **second GPU**, while the renderer README warns that one-GPU generation can fall behind playback and buffer. Do not claim this workstation's complete stack is one-GPU real time until measured.

The [LTX-2.5 optimization notes](https://github.com/animede/diffusers-ltx2_5/blob/main/docs/lowvram-techniques.en.md) explain `nvfp4` as Blackwell-only, the 32 GB model placement, and peak-memory tradeoffs. Their 48 GB path is a plausible starting point for this GPU, but CUDA version, SM120 PyTorch support, wheel availability, and disk/cache requirements still need a dependency check. Current Ollama Gemma installations should not be assumed to accept OpenAI `input_audio`; verify the exact route/model with a small audio request before wiring microphone input. Text chat is a separate first smoke test.

## Stepwise user-run setup plan

1. **PowerShell on the workstation:** inspect `wsl --status`, `nvidia-smi`, free disk, and GPU processes. In **Ubuntu WSL**, confirm `nvidia-smi` sees the Blackwell card and that Python 3.11+, `ffmpeg`, and a current CUDA-capable PyTorch environment can run. Keep this stack in its own `ai-lab` directory and virtual environments; preserve existing ODS/Ollama/Hermes routes. Do not stop unrelated services to gain VRAM without checking which processes own it. [NVIDIA CUDA on WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html), [renderer requirements](https://github.com/animede/Realtime_Narration_Video).
2. Qualify the **renderer first** using the upstream order: movie gateway **8630**, AivisSpeech **10101**, Realtime_Narration_Video **8782**. Follow each repository's current install and `.env.example`, keep listeners on `127.0.0.1` during the trial, and render a text-driven one-character test with its documented LTX-2.5 `nvfp4-fast` preset. The renderer's README warns that its gateway owns backends exclusively; an unmanaged H3/LTX process on its backend ports can return HTTP 409. Record exact package/model revisions, startup memory and clip latency before bringing up the conversation client. [Renderer README](https://github.com/animede/Realtime_Narration_Video), [movie gateway](https://github.com/animede/diffusers-movie-server), [LTX-2.5 implementation](https://github.com/animede/diffusers-ltx2_5).
3. Qualify one **OpenAI-compatible LLM with `input_audio`** using a short consented WAV sent to its API. Confirm it yields a correct reply locally and measure latency. If no local audio-input route works, stop voice mode; the client can still be smoke-tested with typed text. The author's demo used **Gemma 4 E4B**, but this is a model choice in their environment rather than a bundled client dependency. [X author post](https://x.com/uzuki425/status/2104115350614995055), [client README](https://github.com/animede/Realtime_Conversation_Video/blob/main/README.en.md).
4. Only after those pass, clone the **client** at the reviewed commit and create its small `.venv`. Its `run.sh` creates a venv and installs `requirements.txt` automatically, then starts Uvicorn on **0.0.0.0:8791**. For a local trial, use the same app entry point with `127.0.0.1` to avoid an unintended LAN listener; source the copied `.env` first. Do not put API keys in the tutorial or command history. [Client run.sh](https://github.com/animede/Realtime_Conversation_Video/blob/main/run.sh), [.env.example](https://github.com/animede/Realtime_Conversation_Video/blob/main/.env.example), [requirements](https://github.com/animede/Realtime_Conversation_Video/blob/main/requirements.txt).

```bash
git clone https://github.com/animede/Realtime_Conversation_Video.git
cd Realtime_Conversation_Video
git checkout 1f13fffec312582f48af51f47fed69656f20b57a
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
cp .env.example .env
# Edit .env for the verified loopback LLM and narration endpoints.
set -a
. ./.env
set +a
.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8791
```

The example `.env` has `LLM_BASE_URL=http://localhost:8000/v1`, an optional `LLM_MODEL`/`LLM_API_KEY`, and a commented `NARRATION_URL=http://localhost:8782`. Confirm actual process and host addresses in WSL; `localhost` can resolve differently if services are split across Windows and WSL. Use only the selected loopback endpoints for this first trial. [Exact `.env.example`](https://github.com/animede/Realtime_Conversation_Video/blob/main/.env.example).

## The useful X replies and measurements

The exact [X root post](https://x.com/uzuki425/status/2104115350614995055) returned status `2104115350614995055` in a read-only thread lookup on 2026-09-28. The [author's latency reply](https://x.com/uzuki425/status/2104152914453471258) says omitting ASR from the response path saved **several hundred milliseconds** in their Gemma 4 E4B experiment. A later [author reply](https://x.com/uzuki425/status/2104380525607797074) explains that long TTS WAV chunks make real-time video slower, especially in the **first few chunks**; later chunks can be prefetched. This points to measuring **time to first audio**, **time to first rendered frame**, **per-chunk generation/playback duration**, and **buffer stalls**, rather than only average tokens per second. The author also [acknowledges](https://x.com/uzuki425/status/2104115734939107455) occasional seed-dependent lip-sync misses. Those are reports from their setup, not acceptance results for this desktop.

Run three stages with one character/preset: typed question, short microphone question, then a five-turn conversation. Save elapsed times and peak VRAM/RAM for renderer alone and the whole stack, ASR/display accuracy, speech recognition via `input_audio`, voice quality, lip-sync offset, dropped chunks, stalls, and consistency of the character's look. Repeat one prompt with the same seed if the renderer exposes it. Check microphone permission in the browser and that the ROLE/preset survives a reload only in the intended browser profile.

## Pass, stop, and source audit

**Pass:** text conversation reaches the renderer; microphone WAV reaches an audio-input LLM; one response plays with coherent audio/video; three repeated turns stay within memory and avoid unexplained stalls. **Stop:** no compatible `input_audio` endpoint, GPU OOM, service 409 ownership conflict, client on an unintended network interface, significant lip-sync drift, or a next chunk taking longer than playback repeatedly. Preserve logs, chosen model/preset, exact `git` commits, latency breakdown, and failure cause.

The conversation client's **application code** is [Apache-2.0](https://github.com/animede/Realtime_Conversation_Video/blob/main/LICENSE). The renderer, LTX-2.5, Gemma, AivisSpeech, and any model weights have their own terms; the client license does not cover them. The live Social Capture item `sc_24747b719124dc16` supplied the [X post](https://x.com/uzuki425/status/2104115350614995055) and [client repository](https://github.com/animede/Realtime_Conversation_Video). The root post, cited replies, client README, run script, environment example, renderer README, and LTX implementation were checked directly. No service was started in this research pass.

## Related notes

- [[MiniMax H3 Windows Video Exploration Tutorial]]
- [[Local Setup Index]]
- [[Task Checklist]]
