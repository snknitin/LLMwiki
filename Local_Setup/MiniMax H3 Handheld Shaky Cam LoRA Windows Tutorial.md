# MiniMax H3 Handheld Shaky Cam LoRA Windows Tutorial

> [!info] Research and execution status — 2026-09-28
> Source audit complete. This LoRA was not downloaded or rendered. Use the isolated RTX PRO 5000 Blackwell ComfyUI bench in [[MiniMax H3 Windows Video Exploration Tutorial]].

## What this is

The [captured Stable Diffusion Tutorials X post](https://x.com/SD_Tutorial/status/2103763712356356167) links directly to the [neph1 MiniMax H3 Hugging Face mirror](https://huggingface.co/neph1/minimax_h3_handheld_shaky_camera). The mirror points back to [Civitai's Shaky, handheld camera model](https://civitai.com/models/2592748/shaky-handheld-camera?modelVersionId=3343481). Choose **version 3343481, “v1.0 - Minimax H3”**. The same Civitai page also hosts a *different Wan 2.2 I2V High* version; do not download that weight for H3.

The author describes a stronger handheld camera shake for static or moving camera shots. This adapter changes camera motion aesthetics; it does not create a new H3 checkpoint, and its 77.6 MB weight needs an H3 base model, text encoder, video/audio VAEs, and ComfyUI workflow. [Civitai model description](https://civitai.com/api/v1/models/2592748), [version file details](https://civitai.com/api/v1/model-versions/3343481), [HF mirror card](https://huggingface.co/neph1/minimax_h3_handheld_shaky_camera).

## File, license, and compatibility gate

The exact file is `handheld_h3_100.safetensors`, **77,580,048 bytes**, BF16 safetensors, SHA-256 `d56360bc9de18abec4298518ed630167ee4a3f64a7dbbc8bc0c2259d33f74069`. The Hugging Face mirror was at revision `c089b7833cbdffc05bdf17b188e7d7a4aa9e3d88` during research. Its model card labels the adapter with the **MiniMax H3 Community License Agreement**; Civitai's model settings permit commercial image use and derivatives, but the underlying H3 terms still apply. Review the [H3 license](https://huggingface.co/MiniMaxAI/MiniMax-H3/blob/main/LICENSE) for output/distribution scope. [HF file](https://huggingface.co/neph1/minimax_h3_handheld_shaky_camera/blob/main/handheld_h3_100.safetensors), [Civitai version metadata](https://civitai.com/api/v1/model-versions/3343481).

Start with a successful **stock MiniMax H3 FL2VA** 4–5 second text or image to video render as documented in [[MiniMax H3 Windows Video Exploration Tutorial]]. Do not combine this LoRA with DaSiWa Hybrid, Turbo, fal Realism, or Character Swap on the first test. This isolates the camera effect and checks that the same H3 runtime accepts the LoRA.

## Download in the isolated Windows ComfyUI bench

Run in **workstation PowerShell** after setting `$h3Models` to the actual isolated `ComfyUI/models` folder. The `hf` CLI's dry run previews the exact transfer; repeat without `--dry-run` only when the folder and license are confirmed. This does not affect Ollama, LM Studio, ODS, Hermes, or Spark. [Hugging Face CLI](https://huggingface.co/docs/huggingface_hub/guides/cli).

```powershell
$h3Models = 'D:\AI-Lab\ComfyUI-H3\ComfyUI\models'
hf download neph1/minimax_h3_handheld_shaky_camera handheld_h3_100.safetensors --revision c089b7833cbdffc05bdf17b188e7d7a4aa9e3d88 --local-dir (Join-Path $h3Models 'loras') --dry-run
```

After downloading, run `Get-FileHash -Algorithm SHA256` on the file and match the hash above. In ComfyUI, insert a **model LoRA loader** after the selected H3 transformer and before the sampler, select `handheld_h3_100.safetensors`, and save a new workflow copy. If the loader reports unmatched keys or no camera effect, preserve the log and the exact base transformer name; the author did not publish a tested ComfyUI graph in the mirror.

## Author settings and a controlled comparison

The [Civitai parent model description](https://civitai.com/api/v1/models/2592748) supplies tips missing from the thin Hugging Face mirror:

- The model-level description says **only the high-noise stage** needs the LoRA. It is shared across H3 and Wan variants and does not document a separate H3 high/low-noise graph. If the chosen H3 workflow has explicit stages, apply it to high noise first; if it has one model/LoRA path, record that limitation rather than inventing a split.
- The model-level description says a **high strength** is needed and showcase samples were around **1.7**, without identifying those samples as H3-specific. Test at 1.0 first as a compatibility check, then 1.7 as an author-inspired experiment; compare both with LoRA off at the same seed. A useful H3 ceiling is not established.
- The description says it was trained on the phrase **“shaky, handheld camera”**, yet may work without a trigger. The author advises omitting the word **“camera”** from the prompt because it may cause a visible camera object to appear. Compare a natural `subtle handheld sway` motion phrase with a no-trigger prompt, and check for unwanted objects.
- The author claims it works for static and moving camera scenes but gives **no guarantee when combined with other LoRAs**. Treat stacking as a later test, not a default.

For a first pair, use a simple 4–5 second scene with one person walking through an empty corridor, fixed duration/resolution/steps/seed, and no cuts. Render LoRA **off**, strength **1.0**, and **1.7**. Record camera shake amplitude and realism, subject/face stability, vertical horizon drift, rolling motion, blur, audio changes, time, and peak VRAM. A handheld look should come from the viewpoint while scene geometry and the person's anatomy remain stable. Repeat a second scene with a stationary subject so camera motion is easier to isolate. [Civitai model details](https://civitai.com/models/2592748/shaky-handheld-camera?modelVersionId=3343481).

## X source audit and pass criteria

The exact [X post](https://x.com/SD_Tutorial/status/2103763712356356167) returned root status `2103763712356356167` in a read-only thread lookup on 2026-09-28. It links the HF mirror and had **no substantive replies** in the returned thread; no additional settings or performance number can be sourced from it. The live Social Capture item is `sc_24747b719124dc16`. The Civitai model author, version API, Hugging Face mirror, and weight checksum supplied the instructions above.

Pass only if the adapter loads with the H3 base, the same-seed comparison adds plausible handheld motion, and the subject/background remain coherent. Stop on unmatched keys, no visible effect at the author-example strength, body/scene deformation, unstable audio, or repeated OOM. Save model revision, file hash, workflow JSON, prompt, seed, steps, duration, strength, time, and peak VRAM with the three outputs.

## Related notes

- [[MiniMax H3 Windows Video Exploration Tutorial]]
- [[MiniMax H3 Character Swap LoRA Windows Tutorial]]
- [[Local Setup Index]]
- [[Task Checklist]]
