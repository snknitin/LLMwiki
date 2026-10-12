---
updated: 2026-09-28
status: research-ready; runtime-unverified
machine: Windows RTX PRO 5000 Blackwell workstation
---

# BFS Body Swap V1.0 for Qwen Image 2.1

## What this changes

This 209.8 MB LoRA transfers a reference person's whole body, clothing, proportions, and face into a target scene while aiming to preserve the scene's pose, framing, lighting, and background. It is a **Qwen Image 2.1** adapter; `bfs_body_swap_v1_krea2.safetensors` in the same repository is for Krea 2 and must not be selected here. Establish the baseline in [[RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial]] before this test. The author explicitly reports worse face fidelity when the target person is small in frame, and says pose matching is approximate. [BFS repository](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap), [author's body guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1-body.md)

## Windows setup

On the **Windows workstation**, use the isolated ComfyUI instance and the same Qwen Image 2.1 diffusion model, Qwen3-VL encoder, and VAE that passed the base tutorial. Download exactly [`bfs_body_swap_v1.0_qwen_2.1.safetensors`](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/bfs_body_swap_v1.0_qwen_2.1.safetensors) to `ComfyUI/models/loras/`. Record its HF revision and SHA-256, restart ComfyUI, and confirm `LoraLoaderModelOnly` can select the file at strength **1.0**. The HF repo is labeled MIT for the LoRA, but the Qwen base model retains its own Qwen Research license. [BFS model card](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap), [Qwen base](https://huggingface.co/Qwen/Qwen-Image-2.1)

The practical graph is the [official Qwen Image 2.1 edit workflow](https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_image_edit.json), with `LoraLoaderModelOnly` between `UNETLoader` and sampler. Put scene **first** (`<image1>`) and person reference **second** (`<image2>`). The author directs both images into `TextEncodeQwenImage21` with its `resolution` at **0**, then uses that node's `latent` output for the sampler so output size follows the scene. If the official workflow hides these connections in a subgraph, unpack the subgraph or make a simple visible edit graph; do not assume its default resize and latent choices match the BFS recipe. [BFS body guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1-body.md)

## Prepare the two images

Use consented images that you can inspect and keep locally. Choose a scene with a person large enough to evaluate face fidelity. Choose a reference person standing full-body, front-facing, filling most of a square frame against a plain light background. The author's tests scale the scene to roughly **2 megapixels** and the reference to roughly **0.59 megapixels** (about 768×768 area), preserving each aspect ratio with `ImageScaleToTotalPixels`. Do not enlarge the reference to scene size: in the author's tests that increased background bleed. A tight portrait or busy reference background is an out-of-distribution input and should be recorded as a deliberate stress test rather than the first pass. [BFS body guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1-body.md), [author X announcement](https://x.com/Alissonerdx/status/2104336590826840303)

If only a portrait is available, the author documents a preliminary **base model, no LoRA** edit to construct a full-body studio reference. That pass invents unseen clothing/legs/shoes and may weaken likeness, so compare both the direct portrait and normalized reference. The full normalization prompt is in the [author's guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1-body.md).

## First run

Start with the author's prompt and keep the image tokens and order exact:

```text
body_swap: start with <image1> as the base image, keeping its lighting, environment, and background. replace the body from <image1> with the body from <image2>, strictly preserving the clothing, body shape and proportions from <image2>. copy the pose, direction of the eye, head rotation, micro expressions from <image1>
```

Run fixed seed, LoRA 1.0, one image pair, and the base tutorial's working model/encoder/VAE precision. Save the input pair beside the generated output and a no-LoRA edit with the same seed. Judge identity (face and hair), reference clothing/proportions, scene pose, background, lighting, and text preservation independently. Repeat at one higher resolution only if the first pass is stable. The X repost adds no distinct setup procedure; it points back to the same BFS weights. [Author guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1-body.md), [repost](https://x.com/aisearchio/status/2104366377977196668)

## Troubleshooting and decision gate

| Symptom | First check |
|---|---|
| Reference background appears in output | Confirm scene is `<image1>`, reference `<image2>`; use the plain-background reference at ~0.59 MP. |
| Clothing/body stayed from scene | Check exact LoRA file, Qwen 2.1 base family, strength 1.0, and the `LoraLoaderModelOnly` connection into sampler. |
| Face likeness is weak | Confirm subject size in scene and reference quality. A small target person is a known limit of V1.0. |
| Framing/aspect changed | Check sampler uses the `TextEncodeQwenImage21` latent, not an unrelated EmptyLatentImage. |
| Out-of-memory at ~2 MP | Return to 1024/INT8 baseline, then increase resolution in steps while measuring VRAM. |

**Pass:** at least two consented pairs, including one easy standing reference and one stress case, with before/after images and a score for identity, clothing, pose, background, and artifacts. **Defer:** repeated identity loss or scene corruption at the easy case. Close ComfyUI after the run and confirm GPU memory returns to its prior level. The author requests that results involving public figures or people without consent not be used or shared. [BFS body guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1-body.md)

## Social Capture source audit

Live task `sc_2ab42ca49ac53673` was consolidated from two captures. These four exact URLs were attached to it and checked on 2026-09-28:

| Captured source | Access/result |
|---|---|
| [Body weight file](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/bfs_body_swap_v1.0_qwen_2.1.safetensors) | HF repo tree confirms exact file and size, 209,753,576 bytes. |
| [Author X post](https://x.com/Alissonerdx/status/2104336590826840303) | Direct `opencli twitter thread 2104336590826840303` returned matching root ID and replies. Author says full-body, front-facing, plain-background reference; replies contained praise, not extra setup steps. |
| [BFS repository](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/tree/main) | Model card distinguishes Qwen 2.1 body/head files from Qwen Image Edit 2509/2511 and Krea 2 files. |
| [X repost](https://x.com/aisearchio/status/2104366377977196668) | Direct thread returned matching root ID and one nontechnical reply. It links the body swap announcement but contributes no additional settings. |

Related: [[RTX PRO 5000 Qwen Image 2.1 BFS Head Swap Windows Tutorial]].
