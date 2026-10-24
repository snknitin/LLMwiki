---
updated: 2026-10-24
status: active
---

# Local OCR Models (GLM-OCR and Unlimited-OCR)

Two offline OCR models, installed 24 October 2026: one on each machine. Both turn images and PDFs into Markdown text and never call the network after the first download. Index: [[Local Setup Index]].

| | Desktop workstation (RTX PRO 5000) | FirstSpark (GB10) |
|---|---|---|
| Model | **GLM-OCR** (Zhipu, 0.9B, MIT) | **Unlimited-OCR** (Baidu, 3B MoE / ~0.5B active, MIT) |
| Runs through | Ollama tray app, tag `glm-ocr:8k` | Python (`transformers`), command `unlimited-ocr` |
| GPU memory | 2.0 GB while loaded (unloads after 5 min idle) | ~10 GB while a call runs, freed when it exits |
| Speed (synthetic receipt) | 9 s cold, 0.13 s warm | ~25 s per call incl. ~20 s model load; ~6 s per page after |
| Best at | single pages, receipts, screenshots, tables, formulas: fast, small, #1 on OmniDocBench v1.5 (94.6, vendor claim) | long PDFs: up to 16 pages in **one** pass, with layout boxes for every block |
| Disk | 2.7 GB in `D:\LocalLLama\models\ollama` | 6.3 GB model in `~/.cache/huggingface/hub`, 4.9 GB venv in `~/ai/services/unlimited-ocr/.venv` |

**Why this placement:** the desktop GPU already holds Qwen 3.8 27B (~39 GB of 48 GB), so only a small model fits beside it, and GLM-OCR at 8K context needs 2 GB. FirstSpark has 128 GB unified memory and is always on, so the bigger multi-page model goes there. Neither is a resident service: no port, nothing to register in [[FirstSpark Port Registry]].

**Why not vLLM:** Baidu ships a vLLM image (`vllm/vllm-openai:unlimited-ocr`) and an SGLang recipe. Both reserve GPU memory up front and run as an always-on server. Use them only if something needs OCR as an API on FirstSpark many times a day.

## Desktop: GLM-OCR through Ollama

```powershell
ollama run glm-ocr:8k "Text Recognition:" .\receipt.png
```

Other prompts the model understands: `Table Recognition:`, `Formula Recognition:`. The API is the same as any Ollama model (`http://127.0.0.1:11434/api/generate` with `"images": [<base64>]`), so Open WebUI can use it too: pick `glm-ocr:8k` and attach an image.

- `glm-ocr:8k` is `glm-ocr` with `num_ctx 8192` and `temperature 0` (Modelfile: `FROM glm-ocr` + those two `PARAMETER` lines). The plain `glm-ocr` tag loads a 131K context and takes 6.9 GB; avoid it next to Qwen.
- Ollama must be running (tray app). See [[Desktop Qwen Runbook]] for the one-big-GPU-job rule; GLM-OCR is small enough to sit beside Qwen.
- Remove: `ollama rm glm-ocr:8k glm-ocr`.

## FirstSpark: Unlimited-OCR

```bash
unlimited-ocr scan.pdf                  # Markdown to stdout; each page starts with <PAGE>
unlimited-ocr p1.png p2.png -o ~/ocr-out  # also keeps result.md and images with boxes drawn
unlimited-ocr doc.pdf --boxes           # keep <|det|>label [x1,y1,x2,y2]<|/det|> layout boxes (0–999 page coordinates)
```

From the desktop: `ssh FirstSpark 'unlimited-ocr ~/path/to/file.pdf'` (copy the file over first with `scp`).

- Folder: `~/ai/services/unlimited-ocr` (`ocr.py` + `ocr` wrapper, uv project, Python 3.13, `torch 2.10.0+cu130`, `transformers 4.57.1`). `~/.local/bin/unlimited-ocr` links to the wrapper.
- PDFs are rendered at 300 dpi and read 16 pages per pass; single images use Baidu's "gundam" mode (1024 base, 640 crops).
- `HF_MODULES_CACHE` points at the folder's own `.hf-modules`, because `~/.cache/huggingface/modules` is not writable by `snknitin` (created by a container).
- PyTorch warns that GB10 is compute capability 12.1 and the wheel goes up to 12.0. The wrapper hides it; the model runs correctly.
- Remove: `rm -rf ~/ai/services/unlimited-ocr ~/.local/bin/unlimited-ocr ~/.cache/huggingface/hub/models--baidu--Unlimited-OCR`.

## Lighter option for apps: RapidOCR

Projects that need OCR inside their own code use Docling with **RapidOCR** (`rapidocr` + `onnxruntime` from pip, CPU, no GPU or sudo). Paisa Vasool's Renewal Guard switched to it on 24 October 2026 instead of Tesseract, which needed `sudo apt install`. If its results on real receipt photos are weak, GLM-OCR through Ollama is the planned upgrade.

## Not installed

- **Unlimited-OCR MLX / Core ML** (`FluidInference/unlimited-ocr-mlx-coreml`, from Social Capture): the Apple Silicon conversion of the same model. It does not run on Windows or Linux.
- **EVIE-Preview-4.5B** (also in Social Capture): visual document *retrieval* (finds the right page), not OCR.
- Also current (Oct 2026), not tried here: Chandra OCR 2 (Datalab, OpenRAIL), DeepSeek-OCR 2, Surya OCR 2.
