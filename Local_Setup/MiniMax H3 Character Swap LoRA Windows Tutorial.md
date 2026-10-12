# MiniMax H3 Character Swap LoRA Windows Tutorial

> [!info] Research and execution status — 2026-09-28
> Source and X post audited; no weights installed and no swap rendered. This tutorial uses the isolated ComfyUI bench from [[MiniMax H3 Windows Video Exploration Tutorial]] on the RTX PRO 5000 Blackwell. Use only source footage and replacement identities you have the right and consent to use.

## What the adapter does

[Akatz Labs' MiniMax H3 Character Swap LoRA v1](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA) is a **155,110,320-byte adapter** trained for 1,000 updates to replace one chosen character while preserving a source video scene. It is **not a standalone model** and requires H3 **Ref2VA** weights, text encoder, video/audio VAEs, and a compatible ComfyUI LoRA loader. Its intended references are `<Video 1>` = source motion/scene and `<Picture 1>` = replacement character image or sheet. The published final weight is `h3_character_swap_pro4500_1000.safetensors`, SHA-256 `4b2a3f420ae804c0aa3422761ff84dbd1bf52eef6900ffab6d2e66df63cb4e79`. [Model card](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA), [checksums](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA/blob/main/SHA256SUMS).

The repository card says the author tested against [Comfy-Org's Ref2VA pruned INT8 transformer](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors) and pins the exact baseline model revision and hashes in [base-model-files.json](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA/blob/main/training/base-model-files.json). The training assistant in that record was used to train the LoRA; **it is not a runtime dependency**. Avoid loading the FL2VA transformer used for ordinary T2V/I2V and expecting video-reference behavior.

## Isolated Windows setup

1. Follow [[MiniMax H3 Windows Video Exploration Tutorial]] through a successful stock T2V test. In the same isolated ComfyUI root, add the Ref2VA model and the adapter. Keep the shared NVFP4 text encoder and VAE files, but use the **FP16 video VAE** for the author's exact baseline if disk and VRAM permit. The stock first-trial INT8 VAE is a separate comparison, not part of the recorded Akatz baseline.
2. In **PowerShell**, point `$h3Models` at that isolated `ComfyUI/models` folder. Run the dry runs, inspect the file list and free disk, then repeat without `--dry-run`. This downloads the exact pinned baseline revision; it does not change the installed FL2VA file.

```powershell
$h3Models = 'D:\AI-Lab\ComfyUI-H3\ComfyUI\models'
hf download Comfy-Org/MiniMax-H3 --revision 1c41cfca8ebba91d0af792a05c5761fb2c3a7975 --include 'diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors' 'text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors' 'vae/minimax_h3_video_vae_fp16.safetensors' 'vae/minimax_h3_audio_vae_fp32.safetensors' --local-dir $h3Models --dry-run
hf download akatz-ai/MiniMax-H3-Character-Swap-LoRA h3_character_swap_pro4500_1000.safetensors --revision 62407e0cc8089c363abd9ce4b0b27662abb237af --local-dir (Join-Path $h3Models 'loras') --dry-run
```

3. Check the adapter after download with `Get-FileHash -Algorithm SHA256` against the checksum above. The tested Ref2VA transformer is about 20.97 GB; the shared NVFP4 encoder 15.69 GB; FP16 video VAE 5.21 GB; audio VAE 0.61 GB. This is approximately 42.5 GB of selected files on disk, not a promise of VRAM fit. If peak VRAM exceeds the 48 GB card, retry first with a shorter shot and lower resolution, then compare the 2.81 GB INT8 video VAE while documenting the changed baseline. [Pinned file list](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA/blob/main/training/base-model-files.json).
4. Start the stock **MiniMax H3 R2V** template from ComfyUI's Video template library. Use a model-only LoRA loader at **strength 1.0**, the author's starting value; no trigger word was trained. The repository includes an [example Ref2VA workflow JSON](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA/blob/main/examples/H3%20Character%20Swap%20v1%20Ref2VA.json). Import it only into the isolated ComfyUI and inspect missing nodes and selected filenames before pressing Queue. [Akatz model card](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA), [ComfyUI R2V guide](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-native).

## First comparison

Prepare one **4–5 second continuous shot** with a single identifiable target person, plus a clear replacement image or character sheet. Avoid hard cuts, occlusions, and multiple replacement targets in the first pass. Load the video as `<Video 1>` and the character image as `<Picture 1>` in that exact order. Prompt example adapted from the model card:

> Replace only the person in the blue jacket in `<Video 1>` with the character in `<Picture 1>`. Preserve the original camera, background, lighting, objects, and other people. Match the target person's position, scale, pose, and movement. Do not show the reference sheet or its background.

Run an **adapter-off** baseline and an **adapter-on** render with the same source, image, seed, resolution, duration, sampler, and prompt. Save both MP4s and a side-by-side review. Inspect target identity/clothes, body shape, location in frame, camera path, background, untouched people, expression, source action timing, cuts, and audio. The author's card says short shots were more promising than 14-second tests; it does **not** establish a precise maximum. Use H3's supported frame grid at 24 fps. [Model card and limitations](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA).

## The newly captured X tip: use continuation as a separate experiment

In the exact [fnoji post](https://x.com/fnoji/status/2103865411754459347?s=20), the creator says that, when Ref2VA character motion tracing drifts, enabling this LoRA **during context continuation** can pull the trace back while keeping the generated style. They caution that enabling it from a fresh generation may also pull the replacement character's **body shape** into the output. The read-only X thread returned status `2103865411754459347` and **no substantive replies** on 2026-09-28. This is a user observation, not a verified universal setting.

To test it, first make a short base Ref2VA segment without the LoRA and save the end frames/context. Continue the same source motion for one additional short segment twice: once without the LoRA, once enabling strength 1.0 only for continuation. Keep the context, source, seed, duration, prompt, and sampler fixed. Compare the traced position/action and body proportions. The author's model card independently notes that short-window continuation improved some joins but **did not guarantee** camera-cut timing or full source adherence. [fnoji post](https://x.com/fnoji/status/2103865411754459347?s=20), [Akatz findings](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA).

An independent [toyxyz test post](https://x.com/toyxyz3/status/2103933651797045300) has a useful [author reply](https://x.com/toyxyz3/status/2104192976956375401): load the LoRA into ComfyUI's **default R2V workflow**. A [different user's negative report](https://x.com/White_razors/status/2104398108163776834) says high steps/resolution sometimes caused the swap to fail and complex scenes introduced extra people. The post does not give a controlled configuration, so test those as failure modes rather than fixed thresholds; it strengthens the case for a short single-person baseline and changing one setting at a time.

## What to expect and when to stop

The author evaluated 94 synthetic edit triplets and 40 unchanged video/audio examples, with held-out items, but the edit targets were **single still frames** and the regularization controls only five static video frames. The card reports qualitative improvements in background preservation, while long sequences may drift, hard cuts can turn into zooms, facial expression can change, and audio can skip or drift. Some examples used the original source audio after rendering; remuxing is postprocessing and does not prove generated lip-sync. Two-character inference was tried, but multi-character swaps were not training targets. [Training details and findings](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA).

Stop and log the exact failure if ComfyUI rejects the Ref2VA/LoRA combination, the render exceeds available memory, the target is not replaced, untouched people change, a cut is lost, or audio/lip timing fails. Do not add Turbo, Sol/Spectrum attention, or a hybrid checkpoint until the plain Ref2VA comparison is understood; the model card lists those only as later experimental configurations. Decide **keep** only if the adapter improves the selected identity/scene metric without unacceptable temporal or audio loss.

## License and source record

The adapter inherits the [MiniMax H3 Community License Agreement](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA/blob/main/LICENSE), not Apache-2.0. Its card flags territorial and commercial terms, with separate authorization for the US, EU, UK, and South Korea. Check terms before distributing outputs or weights. The dataset's Apache-2.0 label does not alter the adapter's license. Use only people and footage for which you have consent and reuse rights. [Model card license section](https://huggingface.co/akatz-ai/MiniMax-H3-Character-Swap-LoRA).

Source audit: live user-supplied X link matched root ID `2103865411754459347`; the link led to the Akatz Hub repository. The optional toyxyz thread matched root ID `2103933651797045300` and returned the author and negative-report replies cited above. The Hub card, checksum, repository revision, and pinned base-file record were read directly on 2026-09-28. No model was installed or evaluated here.

## Related notes

- [[MiniMax H3 Windows Video Exploration Tutorial]]
- [[Local Setup Index]]
- [[Task Checklist]]
