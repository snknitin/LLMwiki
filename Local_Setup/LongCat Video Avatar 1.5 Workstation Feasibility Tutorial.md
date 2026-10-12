# LongCat Video Avatar 1.5 Workstation Feasibility Tutorial

> [!info] Research and execution status — 2026-09-28
> Source audit complete; installation, download, and inference remain untested on this workstation. The goal is to learn whether one RTX PRO 5000 Blackwell (48,935 MiB) can render a short, consented talking-person clip. The upstream program is Linux/NCCL oriented, so **WSL2 Ubuntu on the Windows desktop** is the first workstation path. DGX Spark is a later fallback after its CUDA/ARM package support is checked.

## Identity and the actual model

[LongCat-Video-Avatar 1.5](https://huggingface.co/meituan-longcat/LongCat-Video-Avatar-1.5) is Meituan's audio-driven video model. It can condition on text, a still image, and speech; `ai2v` uses an image and audio, while `at2v` uses text and audio. Its 1.5 release changes the audio encoder to Whisper Large V3 and supplies an 8-step distilled path; the repository also has an earlier Avatar v1.0 and a distinct foundational LongCat-Video model. The official code and weight card identify the code and weights as MIT licensed. [Official repository](https://github.com/meituan-longcat/LongCat-Video), [1.5 model card](https://huggingface.co/meituan-longcat/LongCat-Video-Avatar-1.5), [technical report](https://github.com/meituan-longcat/LongCat-Video/blob/main/assets/LongCat-Video-Avatar-1.5-Tech-Report.pdf).

The [captured Spanish post](https://x.com/0xJokker/status/2090441836317811176) demonstrates photo plus audio and calls it a free studio replacement. Its thread contains neither a complete install recipe nor a measured one-GPU run; a [reply](https://x.com/kicoes/status/2091080495509455248) guesses two 80 GB A100s, and another [reply](https://x.com/Alexistwa/status/2091518466687701365) confuses a hosted credit service with the downloadable weights. Treat those as comments, not hardware or pricing facts. The test below resolves the workstation question using the upstream code and measured memory.

## The binding constraints

The published single-audio script explicitly initializes `torch.distributed` with the **NCCL** backend even with one process. PyTorch's [distributed documentation](https://docs.pytorch.org/docs/stable/distributed.html) says Windows does not ship NCCL. Thus native PowerShell/Conda is not the supported path for this script; use WSL2 Linux or a Linux host. The upstream [README](https://github.com/meituan-longcat/LongCat-Video#quick-start) pins Python 3.10, PyTorch 2.6.0 cu124, FlashAttention 2.7.4.post1, and additional video/audio dependencies. The release's examples use **two GPUs**, but the source supports `--context_parallel_size=1` with a one-process `torchrun`; a one-GPU run is a test hypothesis, not an upstream benchmark. [Single-audio runner](https://github.com/meituan-longcat/LongCat-Video/blob/main/run_demo_avatar_single_audio_to_video.py).

The weight manifest matters before any download:

| Component | Observed bytes, approximately | Purpose |
|---|---|
| Avatar 1.5 INT8 DiT | 15.88 GB | `--use_int8` alternative to the 31.7 GB BF16 DiT |
| Avatar distilled LoRA | 2.52 GB | Required by `--use_distill` for 8-step path |
| Avatar Whisper model safetensors | 3.09 GB | Audio encoder |
| Foundational LongCat text encoder + VAE | 23.23 GB | Shared dependencies loaded by avatar runner |

Those selected weights sum to about **41.65 GiB before runtime activations, CUDA kernels, and allocator overhead**. The upstream repository also contains duplicate Whisper formats and BF16 avatar weights, so a full `hf download` wastes considerable disk and may fetch more than the first trial needs. A 48 GB card is **plausible but unproven**, with narrow headroom; the 31.7 GB BF16 DiT plus shared encoder is not a first one-GPU candidate. File sizes come from the [Avatar 1.5 manifest](https://huggingface.co/meituan-longcat/LongCat-Video-Avatar-1.5/tree/main) and [foundational model manifest](https://huggingface.co/meituan-longcat/LongCat-Video/tree/main).

## Workstation preparation, with a stop gate after each stage

**PowerShell on the Windows desktop:** run `wsl --status` and `nvidia-smi`. If WSL2 Ubuntu is absent, set it up deliberately as a separate environment; no change to ODS, Ollama, LM Studio, Hermes, or Spark is required. Confirm a new Ubuntu terminal can run `nvidia-smi` and see the RTX PRO 5000. Keep the code and weights on a Linux filesystem or a sufficiently roomy dedicated WSL data disk; model I/O over `/mnt/c` or `/mnt/d` can be slow. Reserve at least **100 GB** free for selected weights, package builds, output, and temporary files. [NVIDIA CUDA on WSL guide](https://docs.nvidia.com/cuda/wsl-user-guide/index.html).

**Ubuntu WSL terminal:** use an isolated Python 3.10 Conda or Miniforge environment and clone a pinned upstream commit. The commands below are a plan for the user-run trial after the prerequisites are in place; the upstream dependency pins and Blackwell CUDA support must pass the checks that follow.

```bash
mkdir -p "$HOME/ai-lab"
cd "$HOME/ai-lab"
git clone https://github.com/meituan-longcat/LongCat-Video.git
cd LongCat-Video
git checkout 6b3f4b8582a8bc3f20f795735f5383716c4ba794
conda create -n longcat-video python=3.10
conda activate longcat-video
```

The upstream package recipe is [here](https://github.com/meituan-longcat/LongCat-Video#installation): PyTorch cu124, then `ninja`, `psutil`, `packaging`, `flash_attn==2.7.4.post1`, `requirements.txt`, Conda `librosa`/`ffmpeg`, and `requirements_avatar.txt`. Run it **only in this environment**. Immediately after PyTorch installation, check:

```bash
python -c 'import torch; print(torch.__version__, torch.cuda.is_available(), torch.cuda.get_device_name(0)); print(torch.cuda.get_arch_list()); print(torch.distributed.is_nccl_available())'
```

Pass only if CUDA and NCCL are true and the PyTorch build supports the Blackwell GPU architecture. If upstream PyTorch 2.6.0 cu124 lacks this GPU's compute capability or FlashAttention fails to build/import, **stop and record the exact error**. Substituting a newer PyTorch or attention implementation changes the tested software stack and needs its own compatibility check. Do not patch the LongCat code blindly.

### Selective weights

Use the modern `hf` CLI, scoped to the needed folders. These revision IDs were current at research time; check that the repository still serves them. Preview the transfer before downloading:

```bash
hf download meituan-longcat/LongCat-Video --revision 03b55529b1d1d4045f5fbe14d65c8c6e8116b278 --include 'text_encoder/*' 'tokenizer/*' 'vae/*' 'scheduler/*' --local-dir ./weights/LongCat-Video --dry-run
hf download meituan-longcat/LongCat-Video-Avatar-1.5 --revision 92016c71d5d318d0f5d84e4db30015a571484ab6 --include 'base_model_int8/*' 'lora/*' 'scheduler/*' 'whisper-large-v3/model.safetensors' 'whisper-large-v3/*.json' 'whisper-large-v3/*.txt' 'vocal_separator/*' --local-dir ./weights/LongCat-Video-Avatar-1.5 --dry-run
```

Before a real download, compare the selective list with the runner's `from_pretrained` paths and model card. These globs exclude the unused foundational DiT and duplicate Whisper formats, but a first load could reveal another metadata file dependency. Download a missing file explicitly and record it rather than switching silently to the full repository. Do not publish a successful install status until the runner loads and renders. [Upstream download instructions](https://github.com/meituan-longcat/LongCat-Video#model-download), [Hugging Face CLI](https://huggingface.co/docs/huggingface_hub/guides/cli).

## One-clip smoke test

The upstream `assets/avatar/single_example_1.json` supplies a prompt, `cond_image`, and `cond_audio.person1` path. It points to repository sample files and is a good first syntax check. For a real evaluation, copy it to a local JSON and change only those paths to one consented image/audio pair; use a **short 3–5 second clean speech clip** and a clear prompt that describes the same person and setting. Avoid multi-person mode and video continuation until one segment works. [Example JSON](https://github.com/meituan-longcat/LongCat-Video/blob/main/assets/avatar/single_example_1.json).

```bash
torchrun --nproc_per_node=1 run_demo_avatar_single_audio_to_video.py \
  --context_parallel_size=1 \
  --checkpoint_dir=./weights/LongCat-Video-Avatar-1.5 \
  --stage_1=ai2v \
  --input_json=assets/avatar/single_example_1.json \
  --resolution=480p \
  --num_segments=1 \
  --use_distill --model_type avatar-v1.5 --use_int8
```

This is a one-GPU adaptation of the [official two-GPU 1.5 example](https://github.com/meituan-longcat/LongCat-Video#longcat-video-avatar-15), supported syntactically by the [runner's defaults and flags](https://github.com/meituan-longcat/LongCat-Video/blob/main/run_demo_avatar_single_audio_to_video.py). The script uses 93 frames at 25 fps for v1.5 and defaults to 480p. Save the command, package versions, commit and weight hashes, peak GPU/system memory, elapsed time, output path, and the generated MP4. If the script fails before a frame is made, that is a feasibility result; do not claim successful Windows support.

## Quality tuning only after the first pass

- **Lip sync:** the upstream guide recommends audio CFG **3–5**; its code defaults to 4. In distilled mode the runner sets audio guidance to 1 internally, so do not promise this knob will have the same effect with `--use_distill`. Compare actual mouth timing to the original WAV, ideally frame by frame. [Upstream tips](https://github.com/meituan-longcat/LongCat-Video#run-longcat-video-avatar), [runner](https://github.com/meituan-longcat/LongCat-Video/blob/main/run_demo_avatar_single_audio_to_video.py).
- **Identity and prompt:** describe appearance, clothing, action, and scene consistently with the reference image. The upstream card says richer descriptions improve consistency. Compare face and clothing at the first and last frame, not merely a good still. [Model card](https://huggingface.co/meituan-longcat/LongCat-Video-Avatar-1.5).
- **Continuation:** only after one segment passes, test `--num_segments=2`, then longer. The author's starting points are `--ref_img_index=10` and `--mask_frame_range=3`; a 30 reference index may reduce repeated actions, but can alter consistency. Keep the same reference/audio and change one variable at a time. [Official README tips](https://github.com/meituan-longcat/LongCat-Video#run-longcat-video-avatar).
- **Resolution:** 480p first, 720p only after memory headroom is measured. The runner maps them to 832×480 and 1280×768. Multi-character audio has `para` (equal-length merged clips) and `add` (sequential clips), which is a separate later test. [Runner](https://github.com/meituan-longcat/LongCat-Video/blob/main/run_demo_avatar_single_audio_to_video.py), [README](https://github.com/meituan-longcat/LongCat-Video#run-longcat-video-avatar).

## If the workstation cannot pass

Record whether the failure is **software** (PyTorch SM120, FlashAttention, NCCL/WSL package issue), **memory**, or **quality/latency**. A one-DGX-Spark Linux test is the next candidate for memory headroom, using the same one-process INT8/480p input and no changes to its live model routes. Spark's ARM64 userspace and PyTorch/FlashAttention wheel availability need separate verification; the official x86/CUDA install recipe does not itself prove Spark compatibility. Avoid escalating to multi-Spark context parallelism before a one-device load succeeds. If neither environment supports the pinned stack, defer the model with the exact blocker.

## Pass criteria and research record

Pass only when a 480p, one-segment video renders from one image and one WAV, plays with synchronized speech, retains identity through the clip, and fits repeatably within measured VRAM/RAM. Save an unmodified baseline and a second render with the same seed. Track at least: cold/warm time, peak VRAM, CUDA/WSL/package versions, clip duration, audio-video offset, facial drift, blinking and mouth artifacts, and two-run reproducibility. For continuation, record seam quality and repeated action separately. The viral post's “studio replacement” claim is a use-case hypothesis, not a pass criterion.

## Capture/source audit

The live Social Capture item `sc_c03359e24eacea9c` points to the exact [0xJokker post](https://x.com/0xJokker/status/2090441836317811176). A read-only X thread lookup on 2026-09-28 returned that status ID and the replies described above. The first-party repository, model card, runner, and weight manifests were checked separately; no X reply supplied a reliable Windows installation or quantitative one-GPU benchmark.

## Related notes

- [[Local Setup Index]]
- [[Task Checklist]]
- [[MiniMax H3 Windows Video Exploration Tutorial]]
