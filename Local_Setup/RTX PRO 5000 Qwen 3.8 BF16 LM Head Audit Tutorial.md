# RTX PRO 5000 Qwen 3.8 BF16 LM Head Audit Tutorial

Status: research and user-run variant audit, 2026-09-28. No second Qwen checkpoint has been downloaded or served by this note.

## Identify the actual model change

The captured [MiaAI Lab post](https://x.com/MiaAI_lab/status/2092017038319386782) says “BF16 `lm_head`,” which is easy to misread as a **full BF16** Qwen3.8-27B. The linked [RadixArk checkpoint](https://huggingface.co/RadixArk/Qwen3.8-27B-NVFP4-BF16-LMHead) instead keeps the model body in mixed **NVFP4 W4A4/FP8** and leaves only the output `lm_head` in BF16. Its sibling [packed-head checkpoint](https://huggingface.co/RadixArk/Qwen3.8-27B-NVFP4) has the same other tensors. SGLang says the dense head adds about **1.7 GB on disk and 3.2 GB at runtime**. Full BF16 Qwen is approximately 54 GB of weights and is outside this 48 GB workstation's clean single-GPU path. [SGLang Qwen3.8 cookbook](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B), [model card](https://huggingface.co/RadixArk/Qwen3.8-27B-NVFP4-BF16-LMHead).

The existing Windows `qwen3.8:27b` in [[Local Setup Index]] is an **Ollama Q4_K_M** package, approximately 18 GB, already tested at 262,144 context. It is a useful practical baseline, but changing both quantization and runtime prevents attributing any quality difference to the head alone. The causal A/B is **RadixArk packed FP4 head versus RadixArk BF16 head**, held at the same SGLang build, prompts, decoding settings, KV precision, and hardware.

## Source and reply audit

The exact captured X status `2092017038319386782` returned MiaAI Lab's post, the quoted [SGLang announcement](https://x.com/sgl_project/status/2092001140179431523), and replies. SGLang claimed improved accuracy for a combination of **FP8 KV cache and BF16 output head** in its testing. The post's prebuilt recipes target [RTX PRO 6000 with 96 GB](https://github.com/MiaAI-Lab/Qwen3.8-27B-RTX-6000-PRO-SGLang-DSpark) and [DGX Spark with 128 GB unified memory](https://github.com/MiaAI-Lab/Qwen3.8-27B-SGLang-DGX-Spark); neither is a drop-in 48 GB Windows recipe. A [reply](https://x.com/marcozerbato/status/2092148317916401882) says generation nearly doubled over full BF16, but that compares a quantized serving stack with full BF16, not BF16 versus FP4 heads. Another [reply](https://x.com/carlito_oliveir/status/2092202124578791871) recommends speed tests at several contexts. A [paired GB10 report](https://x.com/oscarmendetz/status/2092157065804349664) found no significant gain in a 200-question test; it is a community observation, not controlled publisher evidence. Asked whether the head fixes “overthinking,” [MiaAI Lab answered no](https://x.com/MiaAI_lab/status/2092158355653439564). These comments point to the right tests but do not settle them.

The checkpoint publisher now reports **GSM8K 96.13% (1,268/1,319)** for BF16 head versus **96.36% (1,271/1,319)** for the packed head on its stated protocol, and calls the difference sampling noise. Thus “significant accuracy improvement” is **not established on this published test**. There could be other tasks where the head helps; the local audit should target those tasks. [RadixArk model card](https://huggingface.co/RadixArk/Qwen3.8-27B-NVFP4-BF16-LMHead).

## Windows workstation feasibility

The model publisher lists Linux as preferred, and SGLang's [official cookbook](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B) measures RTX 5090 32 GB, RTX PRO 6000 96 GB, and DGX Spark, **not this RTX PRO 5000 48 GB**. The 5090's 32 GB NVFP4 recipe is a reasonable starting point for a Windows host using WSL2 Ubuntu and NVIDIA GPU passthrough, but its success on this exact card remains to be verified. SGLang's cookbook has a live command generator: select **RTX 5090 → NVFP4 with BF16 head → no speculative decoding → one request**, and copy the emitted command for the *pinned* SGLang version. Starting without a drafter isolates the head and avoids additional VRAM. Do not run the 96 GB MiaAI Lab startup script unchanged; it budgets for eight concurrent streams and a large KV pool.

### Preflight and staged trial

1. In **Windows PowerShell**, run `nvidia-smi`, `wsl --status`, `wsl -l -v`, and `Get-PSDrive` for the drive that would hold approximately **24 GB per BF16-head repo** plus the packed-head copy and runtime cache. Confirm that your current Ollama model can be unloaded before each SGLang run without removing its package. Record driver, total/free VRAM, WSL distribution, disk free, and current `ollama list`/`ollama ps`.
2. In **WSL2 Ubuntu**, run `nvidia-smi` and confirm the GPU is visible there. Follow the [official SGLang install instructions](https://docs.sglang.io/docs/get-started/install) in a dedicated environment. The cookbook's Python route currently calls for a prerelease-capable `sglang` install; record `sglang` version and avoid unpinned upgrades between A/B runs. [Cookbook install section](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B).
3. Open the [SGLang Qwen3.8 deployment generator](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B). Use its **RTX 5090 32 GB** cell as a conservative baseline on this 48 GB Blackwell GPU. Select **RadixArk NVFP4 BF16-head**, **no speculation**, **FP8 KV**, and **one concurrent request**. Keep model access on `127.0.0.1`. Save the exact generated command, model revision, and runtime version in the experiment log. If the generated command binds `0.0.0.0`, change only that bind to loopback for this workstation test.
4. Start with a modest context such as **8K or 16K** in the trial command, then attempt 32K and longer only after recording VRAM and an actual long-input pass. The 262K context is a model capability, not a promise that every serving configuration leaves enough KV/cache/graph space. The official cookbook explains that hybrid GDN state and KV pools can silently cap concurrency; check `max_running_requests`, KV capacity, and the memory lines in the server log. [SGLang configuration tips](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B).
5. Verify `http://127.0.0.1:30000/v1/models` from the Windows host or WSL. Run one harmless fixed prompt, a short tool-call request, and a long prompt. The cookbook specifies `--reasoning-parser qwen3` and `--tool-call-parser qwen3_coder`; without these, an agent may receive raw tool-call text. Do not register the endpoint with Hermes/LiteLLM at this stage. [SGLang agent-harness section](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B).
6. Stop that isolated server, then repeat with the sibling [RadixArk packed-head checkpoint](https://huggingface.co/RadixArk/Qwen3.8-27B-NVFP4), changing **only** `--model-path` and a matching served-model label. Cache copies are separate Hugging Face repos; confirm storage before both downloads. Do not delete an existing cache as part of the first comparison.

If SGLang fails to load on the Windows/WSL GPU, save the exact error and stop. The Spark recipe is a later, separately controlled experiment; using it would test a different machine and operational budget. The existing Ollama path remains the workstation baseline.

## Paired benchmark and decision

Use a frozen task set that reflects this workstation's real use: short factual questions, coding/tool-call format, visual input if used, multilingual questions, and “stop thinking and answer” prompts. Include at least 20–50 labelled cases to see gross regressions; use more before claiming a small accuracy difference. Alternate run order (packed/BF16/BF16/packed) to reduce cache and thermal bias. Keep prompt template, temperature/seed, max output tokens, reasoning effort, context, KV dtype, and runtime build fixed. Record accuracy or human rubric, invalid tool calls, thinking-token use, time to first token, decode tokens/s, wall time, peak VRAM, and KV capacity at 8K/32K/long context. The [captured llama.cpp serving tip](https://x.com/sudoingX/status/2104017679908540472) and a [reply](https://x.com/thenightshipper/status/2104220634360492076) reinforce measuring time to first token as well as decode speed; those flags apply to llama.cpp, while this variant's reference path is SGLang. Use [[RTX PRO 5000 Local Inference Measurement Tutorial]] for a separate GGUF lab, not for this checkpoint.

Promote the BF16 head only if a paired test shows a meaningful quality gain without unacceptable VRAM or latency cost. If the variants tie, prefer the smaller packed-head copy or retain the already working Ollama package for normal use. Record the result as an audit decision; do not silently replace `qwen3.8:27b`, ODS, Hermes, or `spark-fast`.

## References

- [Captured MiaAI Lab post and replies](https://x.com/MiaAI_lab/status/2092017038319386782)
- [Quoted SGLang announcement](https://x.com/sgl_project/status/2092001140179431523)
- [RadixArk BF16-head model card and its own evaluation](https://huggingface.co/RadixArk/Qwen3.8-27B-NVFP4-BF16-LMHead)
- [RadixArk packed-head comparison model](https://huggingface.co/RadixArk/Qwen3.8-27B-NVFP4)
- [Official SGLang Qwen3.8-27B cookbook](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B)
- [MiaAI Lab 96 GB RTX PRO 6000 recipe](https://github.com/MiaAI-Lab/Qwen3.8-27B-RTX-6000-PRO-SGLang-DSpark)
- [MiaAI Lab DGX Spark recipe](https://github.com/MiaAI-Lab/Qwen3.8-27B-SGLang-DGX-Spark)

Related: [[Local Setup Index]] · [[Task Checklist]] · [[RTX PRO 5000 Local Inference Measurement Tutorial]]
