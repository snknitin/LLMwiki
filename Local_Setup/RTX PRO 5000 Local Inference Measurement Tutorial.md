# RTX PRO 5000 Local Inference Measurement Tutorial

Status: research and optional Windows lab, 2026-09-28. No llama.cpp build or GGUF has been installed by this note. This lab explains the captured serving flags; the existing native Ollama/ODS route remains the daily workstation path.

## Why this separate lab exists

The captured [X post](https://x.com/sudoingX/status/2104017679908540472) recommends serving one GGUF directly with llama.cpp so context, GPU offload, KV cache, parallel slots, chat template, and speculative decoding are visible. The post reports personal speed/VRAM changes; they are not expected results on the RTX PRO 5000. The exact status `2104017679908540472` and its replies were read. A [reply](https://x.com/thenightshipper/status/2104220634360492076) adds **time to first token**, which is essential alongside decode tokens/s. The [llama.cpp build guide](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md), [server documentation](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md), and [current argument definitions](https://github.com/ggml-org/llama.cpp/blob/master/common/arg.cpp) confirm the flag names; record the exact Git commit because CLI behavior changes.

This is a GGUF runtime lab. It is **not** the serving route for RadixArk's SGLang-only NVFP4/BF16-head checkpoint in [[RTX PRO 5000 Qwen 3.8 BF16 LM Head Audit Tutorial]].

## Build once on Windows

Use **Developer PowerShell for Visual Studio 2022** with Desktop Development with C++, CMake, Git, and an NVIDIA CUDA Toolkit compatible with the installed driver. The [official llama.cpp Windows build guidance](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md) specifies that shell and the CUDA build option. Work in a separate project directory, not the vault:

```powershell
Set-Location 'E:\GIT_ROOT\Projects'
git clone https://github.com/ggml-org/llama.cpp.git llama-cpp-lab
Set-Location '.\llama-cpp-lab'
git rev-parse HEAD
cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release -j 8
```

Check `nvidia-smi` and run the built server with `--help`; on the standard multi-config Windows build the executable is `.\build\bin\Release\llama-server.exe`. If CMake reports CUDA not found, stop and follow the official build guide instead of installing arbitrary wheels or altering Ollama. Confirm the server log shows CUDA and the RTX PRO 5000, not CPU-only execution.

## One-model experiment

Pick **one legitimate GGUF** that fits the card, record its model card/license, exact Hugging Face revision and SHA-256, and save it outside the vault. The [official llama.cpp README](https://github.com/ggml-org/llama.cpp) gives `ggml-org/Qwen3.5-0.8B-GGUF` as a tiny starting example; it is a mechanics exercise, not an answer-quality competitor for the installed 27B Qwen. A local GGUF path avoids an implicit download during each run. In Developer PowerShell, substitute your exact file path:

```powershell
.\build\bin\Release\llama-server.exe -m 'E:\Models\test-model.gguf' -c 4096 -ngl all -fa on -np 1 --host 127.0.0.1 --port 8091 --jinja
```

Pass criteria: log names the CUDA device, says how many layers offloaded, shows the context/KV allocation, and responds at `http://127.0.0.1:8091/v1/models`. `--jinja` is appropriate when testing tool calls with a model that has a supported tool-call template; it is not evidence that every GGUF can call tools. The [server guide](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) documents the OpenAI-compatible route.

Record one fixed 1K input / 256 output probe and one 8K input / 256 output probe if the model permits. Measure cold load, time to first token, decode tokens/s, total wall time, process RAM, and peak VRAM; repeat warm runs. Use the same prompt, sampling settings, and seed for every changed flag. `nvidia-smi` gives coarse VRAM; server log/timings give token and allocation details. A fast decode after a slow prefill may still be a poor interactive result.

## Change one flag at a time

| Flag | What to vary | What to inspect |
|---|---|---|
| `-c` | 4K → 8K → 16K, with fixed prompt lengths | KV allocation, prefill time, peak VRAM, actual usable context. Requested context is a resource budget, not a claim of model quality at that length. |
| `-ngl` | `all` versus a lower exact layer count | GPU offloaded layers, CPU fallback, decode rate. On a fitting model, full offload is usually the starting point. |
| `-ctk` / `-ctv` | Default KV precision versus a supported quantized K/V format shown by `--help` | VRAM saved, model answer changes, time to first token and decode. Pair with `-fa on` where required by the backend; record format exactly. |
| `-fa` | `on` versus `off` if supported | VRAM, prefill/decode time, output parity. An unsupported combination should be logged as such, not forced. |
| `-np` | 1 versus 2 slots, at the same total context budget | Per-user latency, throughput, KV overhead. Record the actual slot/context split; the poster's 454 MiB example is not a forecast for this card. |
| `--jinja` | On for a supported tool template | Whether the API emits structured tool calls, not raw text. A model without a valid template remains unsuitable. |
| `--reasoning-effort` | Use model-supported levels only | Reasoning-token consumption and final-answer completion. This flag passes a value to the chat template; model support varies. |
| `--spec-type draft-mtp` | Try only when that GGUF and build expose a compatible MTP draft | Acceptance rate, end-to-end latency, VRAM, answer parity. The poster's 3060 result cannot be carried over to another model. |

The flag names and meanings are implemented in llama.cpp's [argument definitions](https://github.com/ggml-org/llama.cpp/blob/master/common/arg.cpp). Check `llama-server --help` at the pinned commit before copying a social-media command, particularly for speculative modes and reasoning effort. For speculative decoding, a speed gain must be measured against the same model with speculation off, including draft overhead and acceptance rate.

## Decision record

Keep a small table with commit, GGUF revision/hash, driver, exact command, prompt size, response size, TTFT, output tokens/s, total seconds, peak VRAM, output quality, and errors. If `-ngl all` fails due to VRAM, reduce context first, then decide whether partial offload is still useful. If a quantized KV result changes answers on your fixed set, record that quality cost alongside the memory gain. Do not copy a successful test into ODS/Hermes until it improves a real workflow and its chat/tool template passes a separate evaluation.

## References

- [Captured X post and replies](https://x.com/sudoingX/status/2104017679908540472)
- [Official llama.cpp repository](https://github.com/ggml-org/llama.cpp)
- [Official Windows/CUDA build guide](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md)
- [Official server guide](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)
- [Current CLI argument definitions](https://github.com/ggml-org/llama.cpp/blob/master/common/arg.cpp)

Related: [[Local Setup Index]] · [[Task Checklist]] · [[RTX PRO 5000 Qwen 3.8 BF16 LM Head Audit Tutorial]]
