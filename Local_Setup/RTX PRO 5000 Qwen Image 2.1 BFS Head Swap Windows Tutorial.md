---
updated: 2026-09-28
status: research-ready; runtime-unverified
machine: Windows RTX PRO 5000 Blackwell workstation
---

# BFS Head Swap for Qwen Image 2.1

## Goal and exact files

Transfer a reference person's head, face, hair, and identity into a target scene while retaining its body and background. The author provides three compatible **Qwen Image 2.1** adapters: [`bfs_head_v1.1_qwen_2.1.safetensors`](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/bfs_head_v1.1_qwen_2.1.safetensors) (recommended, 260.1 MB), [`bfs_head_v1.1_alternative_qwen_2.1.safetensors`](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/bfs_head_v1.1_alternative_qwen_2.1.safetensors) (318.8 MB), and the earlier [`bfs_head_v1_qwen_2.1.safetensors`](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/bfs_head_v1_qwen_2.1.safetensors) (318.8 MB). The similarly named `bfs_face_v1_qwen_image_edit_2509.safetensors` and Qwen Image Edit 2511 files target **different bases**; do not use them for this 2.1 test. [BFS repository](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap), [author's head guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1.md)

The author's controlled comparison says V1.1 reduces V1's waxy skin while retaining head rotation better. The V1.1 alternative retains more skin detail and transfers strong mouth/eye expressions better, with a small head-angle tradeoff. These are **author-reported five-pair results**, not measurements on this workstation. Start with V1.1; evaluate the alternative only where expression is important. [Author's version analysis](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1.md)

## Prerequisite and installation

Complete [[RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial]] first. Use the isolated ComfyUI on the **Windows desktop** with the same Qwen 2.1 diffusion model, Qwen3-VL text encoder, and VAE. Put the selected BFS file in `ComfyUI/models/loras/`, record revision/hash, restart, and load it with `LoraLoaderModelOnly` at **1.0**. Use consented local photos only. The BFS HF repository labels its adapters MIT; the underlying Qwen base remains Qwen Research licensed. [BFS model card](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap), [Qwen model card](https://huggingface.co/Qwen/Qwen-Image-2.1)

The author supplies a [Qwen 2.1 head workflow JSON](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/workflows/Head%20Swap%20V1%20Qwen%202.1%20Workflow.json). Inspection shows it includes an **optional Pruna 8-step LoRA** plus optional nodes such as rgthree comparer, KJ image resize, Set/Get nodes, and a RES4LYF sampler choice. Those are not required to evaluate BFS. If importing the JSON shows missing nodes, bypass optional presentation/resizing nodes, disable the Pruna LoRA, and use the plain [official Qwen 2.1 edit workflow](https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_image_edit.json) with BFS `LoraLoaderModelOnly`, Euler/simple, CFG 1, and 25 steps as a first reproducible pass. Do not run the saved eight-step graph with a missing acceleration LoRA. [Author's guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1.md), [workflow JSON](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/workflows/Head%20Swap%20V1%20Qwen%202.1%20Workflow.json)

## Inputs and prompt

- **Image 1 / `<image1>`:** target/scene. Keep its body, pose, composition, lighting, and environment.
- **Image 2 / `<image2>`:** reference head/face. Transfer its identity, hair, eye color, and facial structure.

Do not reverse the images. Start with the author's prompt:

```text
head_swap: start with <image1> as the base image, keeping its lighting, environment, and background. remove the head from <image1> completely and replace it with the head from <image2>, strictly preserving the hair, eye color, nose structure from <image2>. copy the direction of the eye, head rotation, micro expressions from <image1>, high quality, sharp details, 4k
```

In the graph, confirm `image1` and `image2` reach `TextEncodeQwenImage21`, model passes through the BFS LoRA loader, and VAE/output match the base run. The supplied workflow starts around 2 MP; the author's guide says larger output can reduce softness/color shifts, although it increases memory and does not guarantee scene fidelity. Establish a 1024-class baseline before a 2K attempt. [Author's head guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1.md)

## Compare and score

Hold inputs, prompt, seed, resolution, sampler, CFG, and steps fixed. Run (1) base without BFS, (2) V1.1, (3) V1.1 alternative. Compare facial identity, hair boundary, eye color, skin texture, expression, head angle, body/clothing preservation, scene lighting, and text/background drift. Include an easy frontal pair and one expression/pose stress pair. Keep the original V1 only if reproducing an older result or if it demonstrably wins on your images; the author reports more skin softening in V1. [Author's version analysis](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1.md)

**Pass:** V1.1 improves identity over no LoRA on two consented pairs without unacceptable body/background changes; the alternative is judged separately. **Stop/defer:** severe boundary artifacts, unintentional body transfer, repeated OOM, or missing core Qwen nodes. Small faces, extreme head angles, occlusion, hands over face, and large lighting differences are stated limits. Close ComfyUI and check VRAM release after the session. [BFS head guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/blob/main/docs/qwen-image-2.1.md)

## Record

For each output note the LoRA exact filename/hash, base diffusion/encoder/VAE filenames and hashes, ComfyUI commit, optional nodes installed, seed, prompt, inputs, resolution, steps/CFG/sampler, generation time, peak VRAM, and visual score. Do not use or share public figures' or nonconsenting people's images, following the author's stated limitation. [BFS model card](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap)

## Source provenance

Head-swap files were found while auditing the [BFS repository](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/tree/main) attached to live Social Capture task `sc_2ab42ca49ac53673`; the queue title itself calls out **body** swap. The direct head guide and supplied workflow are first-party BFS documentation. See the exact captured-link audit in [[RTX PRO 5000 Qwen Image 2.1 BFS Body Swap Windows Tutorial]].
