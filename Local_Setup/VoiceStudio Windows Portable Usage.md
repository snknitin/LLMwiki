---
updated: 2026-08-20
status: active
version: 0.5.0
platform: Windows 11 x64
install_mode: portable
---

# VoiceStudio Windows Portable Usage

> [!summary] Recommended starting point
> The portable installation is healthy. Keep the **VoiceStudio** TTS engine, CUDA routing, portable storage, and default generation controls as they are. Learn the Voice workspace with the bundled demo voice first, then make one short clone or designed voice. Do not install the optional ASR, dictation, diarization, or heavyweight TTS models until a workflow actually needs one.

This note is pinned to [VoiceStudio v0.5.0](https://github.com/debpalash/VoiceStudio/releases/tag/v0.5.0), the version installed on this workstation. VoiceStudio is an active beta, so re-check the tagged documentation when the application is updated. The v0.5.0 release moved engines and model downloads into the **Model Catalogue** and added `Ctrl+E` as the ready-engine switcher. [Official v0.5.0 release notes](https://github.com/debpalash/VoiceStudio/releases/tag/v0.5.0)

## Live Baseline — 2026-08-20

The following was verified read-only from the portable configuration, model folder, logs, and the local `/system/info`, `/system/diagnose`, `/engines`, `/dictation/models`, and `/model/loaded` endpoints:

| Area | Verified state | Meaning |
|---|---|---|
| Application | VoiceStudio `0.5.0` at `D:\Apps\VoiceStudio` | Correct installed version and target drive |
| Portable root | `D:\Apps\VoiceStudio\OmniVoiceStudio-Data` | Environment, settings, data, voices, projects, outputs, and models remain together |
| Required model | `k2-fsa/OmniVoice`, approximately 2.4 GB | The only required model is installed; a TTS-only installation is complete |
| Compute | `cuda` on NVIDIA RTX PRO 5000 Blackwell, 47.8 GB VRAM | The default TTS engine is GPU-accelerated |
| Worker sizing | Four GPU workers selected automatically | Appropriate for the available VRAM; do not raise it manually |
| Self-check | 10 passed, 0 warnings, 0 failures | Python, CUDA, FFmpeg, token, storage, engine, and network checks are healthy |
| Hugging Face | Token configured; official endpoint reachable | No token change is needed now |
| Disk | Approximately 358 GB free on the portable data volume | Adequate for current use; optional engines can still consume many GB |
| ASR/dictation models | None installed | Deliberate TTS-only state; dictation, transcription, and dubbing will offer optional downloads |
| TTS residency | No model resident while idle | Normal: the default 900-second idle timeout unloads it and the next generation reloads it |
| `torch.compile` | Triton unavailable, so VoiceStudio selected eager mode automatically | Do not enable the Windows disable-workaround merely as a precaution; the app has already selected the compatible path |
| Privacy | Anonymous analytics off | Preserve the user's choice |

VoiceStudio's tagged model catalogue confirms that only the 2.4 GB TTS model is required and that ASR is optional until dictation, dubbing, or reference transcription needs it. [Tagged model catalogue](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/config/models.yaml#L33-L53)

The portable tree matches the documented layout. Because the data folder uses the historical default name beside the executable, the tagged source can rediscover it even without a `portable.path` file. Keep the application folder and `OmniVoiceStudio-Data` together when moving or backing it up. [Portable Windows guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/windows.md#portable-install-windows), [portable-path resolution source](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src-tauri/src/setup.rs#L176-L218)

## The First Obstacle Already Identified

> [!warning] Do not use arbitrary prose in the Style or identity instruction
> The live log shows that the attempted instruction `A warm, friendly narrator voice, medium pace` was rejected. `warm`, `friendly narrator voice`, and `medium pace` are not valid identity attributes for the default engine. This is an input-validation failure, not a CUDA, model, or installation failure.

Use the **By design** chips and presets, or use only this documented taxonomy:

- Gender: `male`, `female`
- Age: `child`, `teenager`, `young adult`, `middle-aged`, `elderly`
- Pitch: `very low pitch`, `low pitch`, `moderate pitch`, `high pitch`, `very high pitch`
- Style: `whisper` only
- English accent: `american accent`, `british accent`, `australian accent`, `canadian accent`, `indian accent`, `chinese accent`, `korean accent`, `japanese accent`, `portuguese accent`, or `russian accent`
- Chinese dialect: use one of the dialect choices shown in the app

Attributes from different categories can be combined, but only one item from each category is allowed. Control pace with **Speed**, not words such as “medium pace.” [Voice Design documentation](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/voice-design.md)

A valid example is:

```text
female, young adult, moderate pitch, british accent
```

## First-Use Workflow

### 1. Prove The Voice Workspace With No Personal Recording

1. Open **Voice** from the left workspace rail.
2. Set **Define voice** to **From audio**.
3. Select the bundled **VoiceStudio Demo Voice** profile.
4. Enter one short sentence, for example: `Welcome to my local voice studio.`
5. Leave **Language** on **Auto** and leave **Production Overrides** at their defaults.
6. Select **Synthesize Audio**, or press `Ctrl+Enter`.
7. Expect the first generation after launch to be slower because the model loads lazily; judge speed from the second generation. [Performance guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md#first-the-classic-causes-of-it-got-slow)
8. In the right-side History rail, play the take, star it if worth keeping, and use the download icon to export the WAV through the Windows save dialog. [Tagged History controls](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src/components/WorkspaceHistory.jsx#L331-L421), [tagged native export flow](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src/App.jsx#L857-L915)

The tagged UI source defines `Ctrl+Enter` as the Voice-workspace generate shortcut. [Tagged Voice workspace source](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src/pages/CloneDesignTab.jsx#L213-L218)

### 2. Clone A Voice From Audio

Only clone a voice that belongs to the user or that the user has permission to use.

1. In **Voice → From audio**, drop a WAV, MP3, M4A, FLAC, or OGG file, or select **Record**.
2. Prefer **5–15 seconds** of continuous, clean, dry speech; approximately eight seconds is a good target. Use one speaker, no music, little room echo, and a close microphone. More audio is not automatically better. [Official migration and first-clone guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/migration/real-time-voice-cloning.md#bring-your-reference-audio-over)
3. Select the correct microphone and use **Auto** or **Mono** channels. Confirm that the live input meter reacts while recording. [Generation-parameter recording note](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/generation-parameters.md#prepost-processing)
4. Fill **Transcript** with the exact words in the reference clip. This improves similarity and avoids downloading/running ASR merely to discover the reference text. An empty transcript is also a common cause of unexpectedly slow cloning. [Performance guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md#first-the-classic-causes-of-it-got-slow)
5. Leave **Style** empty unless the desired supported style is exactly `whisper`.
6. Enter a short output script, keep **Language** on Auto or choose the actual target language, and synthesize.
7. When the reference works, select **Save as Voice Profile**, give it a clear name, and reuse it in Voice, Stories, Audiobook, Dubbing, and the API. [Official first-clone steps](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/migration/real-time-voice-cloning.md#your-first-clone)

Reference quality transfers to the generated voice: an echoey, noisy, or flat performance tends to produce echoey, noisy, or flat output. [Generation parameters](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/generation-parameters.md#prepost-processing)

### 3. Design A New Voice Without Reference Audio

1. Set **Define voice** to **By design**.
2. Start with one of the **Starting points** or select the identity chips directly.
3. If using the description box, watch the identity chips that it maps. If the UI reports unmatched words, remove them rather than forcing the generation.
4. A reliable starter recipe is `female, young adult, moderate pitch, british accent`.
5. Control delivery speed with **Speed**. Do not put speed, warmth, friendliness, narrator role, or unsupported emotion words in the identity instruction.
6. Generate several short takes before saving the design as a profile.
7. Leave the seed unpinned while exploring. After choosing a voice, use **Keep this seed** or lock the saved profile for repeatable identity. The default engine otherwise produces variation between takes. [Expressive-speech guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/expressive-speech.md#default-engine-voicestudio)

The v0.5.0 Voice workspace exposes the identity description, presets, design chips, seed, save-profile action, and `Ctrl+Enter` generation in one screen. [Tagged Voice workspace source](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src/pages/CloneDesignTab.jsx), [tagged design panel](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src/components/clone/DesignMethodPanel.jsx)

## Expression That Works In The Default Engine

| Goal | Supported method |
|---|---|
| Pause | `[pause]`, `[pause 500ms]`, or `[pause 1.5s]` |
| Laughter | Insert `[laughter]` |
| Sigh | Insert `[sigh]` |
| Whisper | Set the Style/identity attribute to `whisper` |
| Pacing | Use punctuation, short fragments, pause tags, and the Speed control |
| Repeat the same result | Pin the seed or lock the profile |

The default engine does **not** support `[breath]`, `[happy]`, `[sad]`, or arbitrary ElevenLabs-style tags. Unknown tags are not stripped; an engine may try to speak them literally. CosyVoice 3 is the documented opt-in engine for a direct `[breath]` tag, while IndexTTS 2.5 offers graded emotion controls in long-form workflows. [Expressive-speech guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/expressive-speech.md)

Keep the production defaults for initial testing:

| Control | Voice default | Guidance |
|---|---:|---|
| Steps | `16` | Fast Voice-workspace default; use 32 only when a measured quality gain is worth the slower render |
| CFG | `2.0` | Leave unchanged initially |
| Speed | `1.0` | Values above 1 speak faster; below 1 speak slower |
| Denoise | On | Leave on for ordinary speech |
| Postprocess | On | Leave on; turn off only when intentional long silences are part of the performance |
| Duration | Auto/blank | A fixed duration overrides Speed and is mainly useful for timing work |
| Position temperature | `5.0` | Variation; leave unchanged initially |
| Class temperature | `0.0` | Greedy/deterministic token sampling; raise only to audition expressiveness and accept more artifacts |

The tagged UI stores these Voice defaults, including 16 steps, while the model documentation explains what each parameter does. [Tagged UI defaults](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src/store/generateSlice.ts#L96-L122), [generation-parameter reference](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/generation-parameters.md)

## Recommended Settings For This Workstation

| Surface | Target state | Change now? | Rationale |
|---|---|---|---|
| **Model Catalogue → Engines → TTS** | VoiceStudio active; `GPU active`/CUDA | Verify only | Best-supported first path; already healthy and installed |
| **Model Catalogue → Models** | Only VoiceStudio TTS installed | No | TTS-only use is complete; avoid speculative multi-GB downloads |
| **Settings → Performance → Device & compute** | CUDA, RTX PRO 5000 Blackwell | Verify only | The live self-check already confirms acceleration |
| **Disable torch.compile (Windows)** | Off | No | The workaround is for Triton/compile OOM, especially below 16 GB VRAM. This 47.8 GB card is not in that risk class, and the live runtime already chose eager mode because Triton is unavailable. [Windows guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/windows.md#triton--torchcompile-oom) |
| **Show live system metrics in header** | Optional | Safe UI-only choice | Helpful while learning VRAM behavior, but not required |
| **Auto-play preview** | On | Keep initially | Immediate feedback; turn off only for batch-style generation |
| **Settings → Storage** | Data and models under `D:\Apps\VoiceStudio\OmniVoiceStudio-Data` | No | Moving only Models would split the portable install and weaken one-folder backup/mobility |
| **Settings → API Keys** | Hugging Face App source valid/green | Verify status only | A valid token is already present; never expose it in screenshots or notes |
| **Settings → Privacy → Analytics** | Off | No | Preserve the completed privacy choice |
| **Invisible watermark** | On by default | User choice | It affects only newly generated audio; changing it is a policy/privacy choice, not a technical fix. [Release notes](https://github.com/debpalash/VoiceStudio/releases/tag/v0.5.0) |
| **Remote workers / Sharing** | Off | No | Local RTX GPU is already more than adequate; enabling this changes the network boundary |
| **Update channel** | Stable | No | Remain on the installed, documented version during first-use validation |
| **Generation history** | Default cap of 200 takes | Keep; star/export winners | Oldest unstarred takes and their WAVs are pruned after the cap; starred takes survive. [Tagged retention source](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/api/routers/generation.py#L2158-L2197) |

Windows needs only a regular NVIDIA driver for the packaged CUDA build; it does not require a separately installed CUDA Toolkit. [Windows GPU guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/windows.md#gpu-support-on-windows)

The app automatically sizes GPU concurrency at one worker per approximately 5 GB free VRAM, capped at four. Leave that automation in control; manually raising it can overcommit VRAM. The first render after launch or idle unload pays the model-load cost, while the next one should be faster. [Performance guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md#knobs-you-can-actually-turn)

## Optional Downloads — Decide By Job

| Need | Recommended decision | Download/caveat |
|---|---|---|
| Basic TTS, designed voices, or cloning when the transcript is typed | Stay with the current install | No additional model |
| Crash isolation for unattended generation | Consider **OmniVoice subprocess** only after a repeatable native crash | Uses the same installed model; it isolates a wedged render in a killable child process. [README engine notes](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#-tts-engines) |
| Simple Windows dictation | Prefer **Whisper Tiny** as the first reliable low-cost trial | Approximately 0.104 GB, 90+ languages, CPU; lower accuracy than a large ASR model |
| Default Parakeet dictation | Install only if willing to test and fall back | Approximately 0.67 GB. The tagged tests document a Windows case where Parakeet loads but emits no text; v0.5.0 detects real speech with empty output, demotes that model on the machine, and falls back rather than failing silently. [Tagged model sizes](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/services/sherpa_dictation.py#L106-L234), [Windows silent-model regression test](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/tests/test_dictation_silent_model.py), [demotion behavior test](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/tests/test_dictation_model_demotion.py) |
| High-quality transcription, dubbing, or automatic reference transcript | Install Faster-Whisper large-v3 when first needed | Approximately 2.9 GB; the current default ASR family is WhisperX. Smaller Whisper variants trade accuracy for disk/VRAM. [Tagged model catalogue](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/config/models.yaml#L45-L114) |
| Speaker diarization | Defer until a multi-speaker dub needs it | Requires a valid HF token plus accepting both pyannote model licenses. [HF token guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/setup/huggingface-token.md#accepting-model-licenses) |
| An audible `[breath]` exactly on cue | Consider CosyVoice 3 | Non-trivial optional engine setup; install only for this concrete need. [Expressive-speech guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/expressive-speech.md#cosyvoice-3-opt-in) |
| Graded emotion control | Consider IndexTTS 2.5 | Optional sidecar and gated model/license; the richest controls are in Audiobook/API, not the single-shot Voice page. [Expressive-speech guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/expressive-speech.md#indextts2-opt-in) |
| CPU-only English preview without cloning | KittenTTS is available | Small and fast, but it cannot clone a reference voice; do not make it the default for cloning or dubbing. [README engine matrix](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#-tts-engines) |
| Dictation cleanup with an LLM | Leave off until a provider/model is chosen explicitly | Raw dictation still pastes if refinement is off or fails. A local Ollama/LM Studio provider can keep it local; do not accept an implicitly discovered model without review. [README dictation feature](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#-features) |

Do not install every recommended model. VoiceStudio's 16 TTS engines have different cloning, instruction, language, license, platform, and resource behavior. Some are large, some have no Windows path, and clone-less engines fail reference-identity jobs instead of silently switching engines. [Official v0.5.0 engine matrix and caveats](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#-tts-engines)

## Dictation On Windows

Dictation is optional and separate from the Voice workspace's TTS generation.

1. Open **Settings → Dictation**.
2. Choose **Toggle** to press once to start and again to stop, or **Hold** to record only while the shortcut is held.
3. The default Windows shortcut is `Ctrl+Shift+Space`. If another application claims it, record a different modifier-plus-key shortcut.
4. Choose and download one dictation model. For the first Windows trial, **Whisper Tiny** is the conservative small option; test the default Parakeet only with the fallback caveat above.
5. Windows must have **Settings → Privacy & security → Microphone → Microphone access** and **Let desktop apps access your microphone** enabled. [Tagged Windows microphone implementation](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src-tauri/src/commands.rs#L618-L674)
6. Focus a harmless text field, press the shortcut, speak one sentence, stop, and confirm the text is pasted.
7. Leave **dictation refinement** off initially. Enable it only after explicitly selecting and testing a local LLM provider.
8. Leave experimental echo cancellation off unless dictating while VoiceStudio itself is playing audio.

The tagged Windows implementation pastes with `Ctrl+V` and restores the prior text clipboard shortly afterward. [Tagged paste implementation](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src-tauri/src/commands.rs#L760-L822)

## Export, Retention, And Portable Backup

### Export A Generated Take

- Generated Voice takes appear in the right-side **History** rail.
- Use the star to exempt a good take from retention cleanup.
- Use the download icon to open a native Windows save dialog and copy the WAV to the chosen destination.
- Use **Load settings** when a prior take's configuration should be restored.

[Tagged History controls](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/frontend/src/components/WorkspaceHistory.jsx#L331-L421)

### Export A Reusable Voice

Open a saved voice and choose **Export persona** to create an `.ovsvoice` bundle. Including the voice clip gives the best clone fidelity but places the raw reference recording in the bundle. Turning **Include voice clip** off creates a preview-only bundle so the raw recording does not travel. Export and import are local; the optional AudioSeal preview watermark may require a one-time model download. [Portable persona documentation](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/persona-format.md)

### Back Up Or Move The Portable Installation

1. Quit VoiceStudio and wait for the backend to stop.
2. Copy the whole `D:\Apps\VoiceStudio` folder, including `omnivoice-studio.exe` and `OmniVoiceStudio-Data`.
3. Treat the backup as sensitive: it can contain reference recordings, cloned profiles, project audio, transcripts, outputs, and settings.
4. On a different machine, re-save the Hugging Face token in **Settings → API Keys**. App-stored token encryption is derived from the machine/install identity, so a copied token may not decrypt on the destination. [HF token portability limitation](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/setup/huggingface-token.md#setting-via-the-app-recommended)

## Common Obstacles And Their Smallest Fix

| Symptom | Likely cause | Smallest corrective action |
|---|---|---|
| “Unsupported instruct items” | Arbitrary prose in the default engine's style/identity input | Use the supported design chips or the exact taxonomy above; use Speed for pace |
| First render is slow | Lazy model load and kernel/device warm-up | Wait for completion and compare the second render |
| Clone is slow even on a short line | Saved profile has an empty reference transcript, causing an ASR pass | Fill the exact Transcript once |
| Dictation asks for a model | No dictation model is installed | This is expected; choose one only if dictation is desired |
| Parakeet hears speech but returns nothing on Windows | Known tagged sherpa-onnx TDT decoder behavior | Let v0.5.0 demote/fall back, or select Whisper Tiny |
| Generated audio varies between takes | Seed is unpinned | Explore first, then keep the winning seed or lock the profile |
| Part of a long script is missing | One chunk produced no audio | Regenerate with a different seed; the app identifies the dropped text |
| Model appears unloaded after a break | Normal 900-second idle release | Generate again; expect one cold-load delay |
| VRAM is fragmented or a previous engine remains resident | Cached or resident model memory | Use **Flush caches**; use **Unload all + flush** only when maximum recovery is needed. It does not delete data. [Performance guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md#flush-caches--unload-resident-model) |
| Flush immediately after a timeout does not help | The abandoned Python worker may still be computing and holding VRAM | Wait for it to drain or restart the backend, then flush |
| Model download is partial/corrupt | Interrupted transfer | In Model Catalogue, remove that model and install it again; do not reset voices/projects. [Download troubleshooting](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/downloading-models.md#troubleshooting) |
| A prior-run warning appears | The app recorded an unclean backend stop during an earlier generate attempt | Current self-check is healthy; dismiss/acknowledge it. If it recurs during normal use, run self-check and save a diagnostic bundle before changing the install |
| Port 3900 is in use | A second VoiceStudio or orphaned backend owns the local API port | Quit the other instance and relaunch; avoid starting multiple copies |

## Safe To Apply Now

- [ ] Verify CUDA/RTX routing and the 10-pass self-check.
- [ ] Keep VoiceStudio as the active TTS engine.
- [ ] Keep the current portable data/model paths.
- [ ] Leave Production Overrides at their defaults for the first two tests.
- [ ] Test the bundled demo profile with one short, valid script.
- [ ] Test one valid By-design recipe using the chips or `female, young adult, moderate pitch, british accent`.
- [ ] Star the best sample and inspect the export action.
- [ ] Optionally show live RAM/VRAM metrics in the header.

## Requires The User's Choice

- [ ] Which microphone/input channel to use.
- [ ] Whether to supply or record a voice-cloning reference and whether consent exists.
- [ ] Whether the invisible AI watermark stays on.
- [ ] Whether to download a dictation model and which language/accuracy tradeoff to choose.
- [ ] Whether to download the 2.9 GB high-quality ASR model for transcription/dubbing.
- [ ] Whether to accept any gated Hugging Face model license.
- [ ] Whether to install a specialized TTS engine for breaths, emotion, CPU speed, or isolation.
- [ ] Whether to connect VoiceStudio to an Ollama/LM Studio LLM for dictation refinement or translation.
- [ ] Where to export user-created WAV or `.ovsvoice` files.
- [ ] Whether any remote worker or network-sharing feature should be enabled.

## Live Computer-Use Audit Checklist

Apply this sequence without downloading an optional model or changing a privacy/network boundary:

- [ ] Open **Settings → About → Run self-check**. Confirm every row is green; expected live result is 10 passed, 0 warnings, 0 failures.
- [ ] Open **Settings → Performance & Device**. Confirm `cuda`, NVIDIA RTX PRO 5000 Blackwell, and GPU active.
- [ ] Confirm **Disable torch.compile (Windows)** is off. The current backend already reports eager mode because Triton is unavailable.
- [ ] Open **Model Catalogue → Engines → TTS**. Confirm **VoiceStudio** is active and routed to CUDA.
- [ ] Open **Model Catalogue → Models**. Confirm **VoiceStudio TTS** is installed. Do not install the optional recommendations during this audit.
- [ ] Open **Settings → Storage**. Confirm the effective data/model location remains under `D:\Apps\VoiceStudio\OmniVoiceStudio-Data`.
- [ ] Open **Settings → API Keys**. Confirm a valid/active Hugging Face source without revealing or editing the token.
- [ ] Open **Settings → Privacy**. Confirm analytics remains off; do not change the watermark without the user.
- [ ] Open **Voice → From audio**, select **VoiceStudio Demo Voice**, enter `Welcome to my local voice studio.`, leave overrides unchanged, and synthesize.
- [ ] Repeat the same short generation once to distinguish cold-load time from normal generation time.
- [ ] Open **Voice → By design**, use the identity controls for `female, young adult, moderate pitch, british accent`, and synthesize one short test.
- [ ] In History, verify playback, star, restore-settings, and download controls. Do not choose an export destination on the user's behalf.
- [ ] Open **Settings → Dictation** only to inspect the state. Confirm the model is not installed; do not trigger its download without the user.
- [ ] Finish when TTS demo + design both work, CUDA remains active, no optional download started, and no privacy/network setting changed.

## Source Set

- [VoiceStudio v0.5.0 release](https://github.com/debpalash/VoiceStudio/releases/tag/v0.5.0)
- [Tagged v0.5.0 README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md)
- [Windows installation and portable mode](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/windows.md)
- [Performance guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md)
- [Generation parameters](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/generation-parameters.md)
- [Voice Design](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/voice-design.md)
- [Expressive speech](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/expressive-speech.md)
- [Hugging Face token setup](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/setup/huggingface-token.md)
- [Model download behavior and troubleshooting](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/downloading-models.md)
- [Portable `.ovsvoice` personas](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/persona-format.md)
- [Tagged v0.5.0 source tree](https://github.com/debpalash/VoiceStudio/tree/v0.5.0)

## Related Notes

- [[Local Setup Index]]
- [[RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial]]
- [[Task Checklist]]
