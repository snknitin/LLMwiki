# RTX PRO 5000 EVIE Visual Document Retrieval Tutorial

Status: research and user-run evaluation plan, 2026-09-28. No model or package has been installed by this note.

## What this evaluates

The Social Capture item calls for **EVIE-Preview-4.5B** to retrieve PDF, chart, table, and scan *pages* visually. EVIE is a retriever: it ranks page images against a text query and returns scores. It does not write a cited answer; a separate reader or human must inspect the retrieved page. The captured [X post](https://x.com/TeksEdge/status/2091924068681625781?s=20) correctly points to a PyTorch/ColPali route, rather than an Ollama or LM Studio chat model. Tencent's [preview card](https://huggingface.co/tencent/EVIE-Preview-4.5B) specifies 4.54B parameters, an approximately 8.5 GB BF16 checkpoint, 128-dimensional token embeddings, and Apache 2.0.

**Release update:** Tencent now calls Preview a legacy checkpoint and offers [EVIE-4.5B](https://huggingface.co/tencent/EVIE-4.5B) and [EVIE-8B](https://huggingface.co/tencent/EVIE-8B). The current 4.5B has variable 64–2048 dimensional embeddings and optional HAC token compression; its published ViDoRe V3 score is 66.02 versus Preview's 65.36. These are publisher benchmark results, not a local measurement. Begin with Preview to answer the captured question, then test the newer 4.5B on the *same* documents if Preview is useful. Do not mix their indexes or compare different page-resolution/token budgets. [Tencent repository](https://github.com/Tencent/EVIE), [model card](https://huggingface.co/tencent/EVIE-4.5B).

## Source and reply audit

The exact captured X status `2091924068681625781` returned the TeksEdge post and its replies. The post's useful setup clue is that current use is PyTorch + ColPali. [One reply](https://x.com/dusangran/status/2092587882032644207) asks about multi-vector index cost; Tencent's preview card quantifies roughly **179.2 GiB per million pages** at 768 visual tokens and **420.5 GiB** at 1,792, using BF16 vectors. [Another reply](https://x.com/sebuzdugan/status/2092241507205992878) warns about poor low-DPI scans; that is an evaluation case, not a proven EVIE failure. Current EVIE-4.5B's HAC claims a much smaller index at a measurable ranking tradeoff. Record both accuracy and bytes/page rather than accepting a headline score. The source post's “#1” claim referred to the preview's release-time comparison and is now superseded by Tencent's later models.

## Fit on this workstation

The vault records an **RTX PRO 5000 Blackwell with 48,935 MiB VRAM** in [[Local Setup Index]]. A single 8.5 GB BF16 retriever should be a sensible GPU trial, but actual peak VRAM depends on image resolution, batch size, PyTorch, and attention backend. Start with four pages and one query, then raise the page count. Keep the existing native Ollama, ODS, and Hermes routes untouched. The official repository's `infer.py` automatically selects FlashAttention when available and SDPA otherwise; SDPA is a reasonable first Windows path. The publisher has not supplied an end-to-end Windows validation claim, so treat native Windows execution as a local test, with WSL2 as the fallback if ColPali dependencies fail. [Official inference script](https://github.com/Tencent/EVIE/blob/main/infer.py), [requirements](https://github.com/Tencent/EVIE/blob/main/requirements.txt).

## Windows PowerShell trial

Run in **Windows PowerShell**. Choose an ordinary project directory outside the vault for the clone, models, and generated page images. This example uses `E:\GIT_ROOT\Projects`; change only that path if your test workspace differs. The commands download packages and model weights when you choose to run them.

1. Preflight: `nvidia-smi`, `py -3.11 --version`, `git --version`, and `Get-PSDrive E`. Stop if Python 3.11 or the target drive is unavailable. Record free VRAM and free disk.
2. Clone the [publisher repository](https://github.com/Tencent/EVIE) and pin its current commit before testing:

   ```powershell
   Set-Location 'E:\GIT_ROOT\Projects'
   git clone https://github.com/Tencent/EVIE.git EVIE-eval
   Set-Location '.\EVIE-eval'
   git rev-parse HEAD
   py -3.11 -m venv .venv
   .\.venv\Scripts\python.exe -m pip install --upgrade pip
   ```

3. Install a CUDA-enabled PyTorch build selected from the [official PyTorch installer](https://pytorch.org/get-started/locally/) for the installed driver and Python. Then install Tencent's requirements in the same environment:

   ```powershell
   .\.venv\Scripts\python.exe -m pip install -r requirements.txt
   .\.venv\Scripts\python.exe -c "import torch; print(torch.__version__, torch.cuda.is_available(), torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'NO CUDA')"
   ```

   Stop if CUDA is false; CPU fallback can obscure the intended workstation benchmark.

4. Prepare 4–8 **non-sensitive** page images, one page per `.png` or `.jpg`, including a chart, table, text page, and low-quality scan. For PDFs, export page images at a fixed DPI using a PDF tool you already trust; keep `document_id`, `page_number`, and image path together in a manifest. Use a separate ground-truth table of query → relevant page(s). Do not use the publisher's 22-dataset reproduction script for this small trial; its card says that downloads about 55 GB of benchmark data.
5. Run the publisher's CLI from the cloned repository. The `--attn sdpa` choice avoids needing a native Windows FlashAttention build. Replace the two sample paths with your actual files:

   ```powershell
   .\.venv\Scripts\python.exe infer.py --model tencent/EVIE-Preview-4.5B --attn sdpa --query 'Which page shows quarterly revenue by year?' --image 'E:\EVIE-test\chart.png' --image 'E:\EVIE-test\table.png'
   ```

   Confirm the right page is first. `infer.py` applies the required bidirectional attention conversion and resets `rope_deltas` before query inference; the preview card says skipping either can change scores. [Inference code](https://github.com/Tencent/EVIE/blob/main/infer.py), [preview card](https://huggingface.co/tencent/EVIE-Preview-4.5B).
6. If Preview passes, rerun *exactly the same images and queries* with `--model tencent/EVIE-4.5B --head 128 --attn sdpa`. The 128D head approximates Preview's vector width. Then optionally measure 64D and 256D; the new model's HAC implementation is a separate index experiment, not automatic in this command. [Current EVIE card](https://huggingface.co/tencent/EVIE-4.5B).

If native Windows fails at model loading, capture the error, Python/PyTorch/Transformers versions, and GPU state. The publisher's Linux-oriented command is `pip install -r requirements.txt` and `python infer.py ...`; a WSL2 Ubuntu environment with NVIDIA GPU passthrough is the next isolated path, using the same repository and frozen test set. Do not change the global Python environment to work around it.

## Measure and decide

For every query, record top-1 and top-5 relevant-page hits, rank of the first correct page, cold load, page indexing time, warm query time, peak VRAM, and index bytes/page. Test a chart, table, normal text, multilingual query, and a low-DPI scan. Keep page DPI, token budget, and head dimension fixed when comparing models. A retrieval score is not a citation: manually open the returned page and verify it supports the answer. If scan retrieval fails, try a higher-quality page rendering and log the difference before changing the model.

The first gate is whether Preview and current 4.5B work on this Windows GPU. The promotion gate is a measured gain over your existing text retrieval path on the **same labelled corpus**, at acceptable index size and latency. If no gain appears, keep the source note but defer a production index.

## References

- [Social Capture source post and replies](https://x.com/TeksEdge/status/2091924068681625781?s=20)
- [Tencent Preview model card](https://huggingface.co/tencent/EVIE-Preview-4.5B)
- [Tencent current 4.5B model card](https://huggingface.co/tencent/EVIE-4.5B)
- [Tencent EVIE repository and inference script](https://github.com/Tencent/EVIE/blob/main/infer.py)
- [PyTorch official Windows installer selector](https://pytorch.org/get-started/locally/)

Related: [[Local Setup Index]] · [[Task Checklist]]
