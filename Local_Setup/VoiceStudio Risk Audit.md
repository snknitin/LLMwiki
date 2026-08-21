# VoiceStudio Risk Audit

> [!summary]
> **Audit date:** 2026-08-20  
> **Installed build:** VoiceStudio v0.5.0, Windows portable, `D:\Apps\VoiceStudio\`  
> **Mode:** Read-only investigation. No fixes, setting changes, cancellations, restarts, installs, removals, or model changes were performed.  
> **Bottom line:** The installation and CUDA stack are substantially present, but VoiceStudio is **not yet working perfectly**. A live backend lifecycle defect leaves the HTTP health checks green while the model manager permanently refuses model loads with `backend shutting down`. No successful generated output or dictation acceptance baseline exists yet. Most setup and workflow risks are fixable by configuration or controlled verification; the shutdown-latch/health-check mismatch should also be reported upstream if it recurs after a clean quit/relaunch.

## Scope And Evidence Standard

This audit separates current local evidence from upstream/version reports and from risks that have not happened here. VoiceStudio is explicitly labelled an **active beta**, so absence of a local symptom is not proof that a workflow is production-safe ([v0.5.0 README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L278-L284), [v0.5.0 release](https://github.com/debpalash/VoiceStudio/releases/tag/v0.5.0)).

Local evidence reviewed without exposing credentials:

- `D:\Apps\VoiceStudio\omnivoice-studio.exe`
- `D:\Apps\VoiceStudio\OmniVoiceStudio-Data\config.json`
- `D:\Apps\VoiceStudio\OmniVoiceStudio-Data\data\omnivoice.log`
- `D:\Apps\VoiceStudio\OmniVoiceStudio-Data\data\last_run_crash.json`
- portable model cache, output/history folders, process tree, listening port, local health/diagnostic endpoints, and SQLite integrity

Classification used below:

- **Fix now:** likely resolvable in a controlled maintenance session without reinstalling or deleting user work.
- **Configuration:** resolved by choosing the intended supported setting/model/provider.
- **Workaround:** usable path exists, but the underlying defect or limitation remains.
- **Upstream only:** needs a VoiceStudio/engine code or packaging fix.
- **Monitor:** no action until a clear trigger or failed verification appears.

## Executive Findings

1. **High — confirmed:** the current Python backend still listens on port 3900 and `/health` plus `/system/diagnose` report healthy, but its model-manager shutdown latch rejects Gallery preview, Voice/Story synthesis, and model loading. This is a cross-workspace lifecycle defect, not a CUDA-install failure.
2. **High — confirmed acceptance gap:** `generation_history=0`, no generated WAV exists, and the only Story artifact is a failed resume record. A green health page is therefore not a valid success criterion.
3. **Medium — confirmed configuration error:** an earlier English voice-design request used a prose description where v0.5.0 expects its finite style taxonomy; the backend rejected it correctly.
4. **High — confirmed model/engine mismatch:** the general Transcription model `nvidia/parakeet-tdt-0.6b-v3` finished downloading (~5.73 GB), but v0.5.0 reports its `nemo-parakeet` ASR engine unavailable because installing `nemo_toolkit` would create an unsafe `transformers` dependency conflict. The weights are complete but unusable through that engine in this packaged environment. They are not the separate sherpa-onnx model used by system-wide dictation.
5. **Recommendation:** keep Handy for now. VoiceStudio's TTS, cloning, dubbing, audiobook, and API features do not replace a dedicated dictation utility; VoiceStudio could replace Handy only after its distinct dictation workflow passes the acceptance tests near the end of this note and only if Handy's richer paste/startup/history conveniences are not needed.

## A. Confirmed Local Issues And Evidence

### A1. Model-Manager Shutdown Latch Remains Set In A Live Backend

- **Severity / likelihood on this PC:** High / confirmed now.
- **Trigger:** An unclean or mismatched close/shutdown sequence; clicking the window **X** hid the app but did not replace the original backend process.
- **Visible symptom:** Gallery says `503 Service Unavailable ... model load skipped: backend shutting down`; Voice/Story jobs fail with `ModelLoadInterruptedByShutdown`; both Story chapters failed.
- **Evidence/source:** The local log repeats the shutdown guard after the backend had already logged shutdown completion. Tagged code refuses all loads when `_shutdown_event` is set ([model-manager guard](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/services/model_manager.py#L1825-L1840), [second guard](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/services/model_manager.py#L1892-L1900)). The project previously fixed a closely related shutdown/load race, so this local state is not expected normal operation ([v0.5.0 changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L545-L550)).
- **Fixability class:** Fix now; upstream only if reproducible.
- **Proposed non-destructive fix:** In a later authorized maintenance session, finish/cancel nothing in flight, use the tray's explicit **Quit**, confirm the desktop and backend process tree exits, then relaunch once. If the latch returns, collect the built-in diagnostic bundle and file a minimal upstream issue with sanitized logs.
- **Verification test:** After relaunch, preview one Gallery voice, generate a short Voice take, and render a two-chapter Story. Each must create playable audio and no new `backend shutting down` line.

### A2. Health And Diagnostic Endpoints Produce A False Negative

- **Severity / likelihood on this PC:** High / confirmed now.
- **Trigger:** Backend process remains reachable while internal model state is unusable.
- **Visible symptom:** `/health` reports `ok` and `/system/diagnose` reports 10/10 while every real model load returns 503.
- **Evidence/source:** Local requests and log correlate at the same time. The tagged health route checks CUDA availability and version, but not the model-manager shutdown latch ([health implementation](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/main.py#L1347-L1359)). Official troubleshooting distinguishes the ordinary self-check from `--deep`, which actually loads a model and synthesizes audio ([troubleshooting](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/troubleshooting.md#L196-L211)).
- **Fixability class:** Workaround now; upstream only for a true readiness endpoint.
- **Proposed non-destructive fix:** Treat `/health` as process/CUDA liveness only. Gate “working” on a deep self-check or a real short render, and report the readiness mismatch upstream with A1.
- **Verification test:** A readiness test must fail while the latch is set and pass only after a real WAV is produced; `/health` may remain a separate liveness check.

### A3. No Successful Deliverable Baseline; Activity Is Not Success

- **Severity / likelihood on this PC:** High / confirmed absence of baseline; false-success presentation remains a risk rather than a proven “success” label.
- **Trigger:** Relying on job start/progress, a green status, or a workspace card without checking the output and history record.
- **Visible symptom:** Local generation history is empty, the output area has no generated audio, and the Story folder contains only a failed `resume.json` after two chapter failures.
- **Evidence/source:** Local database, output folder, and log. The changelog explicitly describes prior cases where a model-load failure left the app looking healthy while producing nothing and where missing speech had to be surfaced honestly ([v0.5.0 changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L324-L341)).
- **Fixability class:** Fix now after A1; monitor UI honesty.
- **Proposed non-destructive fix:** Establish one known-good output per critical workspace and record its actual file, playability, duration, history row, and log terminal state.
- **Verification test:** A job passes only when a non-empty, playable audio/video file exists and the corresponding history/job state says complete; a start toast or 200 health response is insufficient.

### A4. Unsupported Voice-Design Style Description

- **Severity / likelihood on this PC:** Medium / confirmed once; likely again if free-form prose is reused.
- **Trigger:** Supplying `A warm, friendly narrator voice, medium pace` as the English instruct/style value.
- **Visible symptom:** Generation is rejected before synthesis with a message listing valid English values.
- **Evidence/source:** Local log at 22:42. Voice Design accepts one choice per supported category—accent, age, gender, pitch, and style/emotion—with language-specific applicability ([Voice Design](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/voice-design.md#L194-L216), [supported attributes](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/voice-design.md#L245-L308)).
- **Fixability class:** Configuration.
- **Proposed non-destructive fix:** Use only the UI's listed taxonomy for the selected language; put narrative intent in the text/direction tools rather than inventing a style label.
- **Verification test:** Generate the same short text with one supported style, then repeat with no style; both should complete and the supported style should change delivery without a validation error.

### A5. Hugging Face Token Has More Than One Active Source

- **Severity / likelihood on this PC:** Medium / confirmed ambiguity; no credential failure observed.
- **Trigger:** VoiceStudio's saved token and the process-level `HF_TOKEN` environment variable are both present, especially if they belong to different accounts or have different scope.
- **Visible symptom:** `huggingface_hub` warns that `HF_TOKEN` is independently active; the UI selection can appear ineffective or gated downloads can 401 under the unintended identity.
- **Evidence/source:** Local warning; token values were not read or recorded. v0.5.0 documents the app-encrypted setting → environment → CLI cascade and notes that saving in the app also writes the canonical Hugging Face token ([HF token guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/setup/huggingface-token.md#L196-L212)).
- **Fixability class:** Configuration.
- **Proposed non-destructive fix:** In a later settings session, choose one intended token source/account, confirm the UI's active-source/username check, and remove only the redundant source after explicit approval. Never paste a token into diagnostics or this vault.
- **Verification test:** Token status identifies the intended account; a public model request succeeds; gated diarization succeeds only after the same account accepts both model agreements.

### A6. Previous Run Was Unclean And MCP Manager Reported Reuse

- **Severity / likelihood on this PC:** Medium / confirmed marker and log; causal link to A1 is plausible, not proven.
- **Trigger:** Previous run ends without the clean-quit acknowledgement or a session manager instance is started twice across lifecycle transitions.
- **Visible symptom:** `last_run_crash.json` has an unacknowledged prior-run marker; startup says the previous backend was unclean; log says `StreamableHTTPSessionManager .run() can only be called once per instance`.
- **Evidence/source:** Local crash marker and log. VoiceStudio's changelog says an unclean-shutdown notice can have benign causes such as sleep or force-quit and is not itself proof of a crash ([v0.5.0 changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L349-L352)).
- **Fixability class:** Monitor; upstream only if it repeats after a clean lifecycle.
- **Proposed non-destructive fix:** Preserve the marker and log until the next controlled quit/start test; report the MCP message alongside the shutdown-latch trace if it recurs.
- **Verification test:** Clean quit/relaunch produces no new unclean-run notice, no MCP `.run()` reuse error, and MCP plus ordinary TTS both respond.

### A7. General Parakeet Weights Installed But Its NeMo Engine Is Unavailable

- **Severity / likelihood on this PC:** High usability and storage impact / confirmed now.
- **Trigger:** User installed `nvidia/parakeet-tdt-0.6b-v3` from the general Transcription catalogue in the packaged v0.5.0 environment.
- **Visible symptom:** `/models` marks the model installed and complete, but `/engines` marks `nemo-parakeet` unavailable and says there is **no safe install path in this app yet** and **do not install `nemo_toolkit` here**. Transcription therefore still has no runnable NeMo-Parakeet engine despite ~5.73 GB of complete weights.
- **Evidence/source:** Local install completed at 23:16:56; size on disk is 5,732,941,955 bytes. The tagged catalogue identifies these as the general Parakeet TDT v3 ASR weights ([models catalogue](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/config/models.yaml#L116-L130)); the tagged NeMo ASR implementation is separate from model presence ([NeMo ASR service](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/services/asr_nemo.py)). Local engine diagnostics name the conflict: NeMo requires `transformers>=4.57,<4.58` while this VoiceStudio environment requires `transformers>=5.3`.
- **Fixability class:** Workaround now; upstream only for a safe isolated engine/package path.
- **Proposed non-destructive fix:** **Do not install `nemo_toolkit` into the managed portable environment and do not force either `transformers` version.** Select a supported available general ASR such as the validated Whisper path. If the 5.73 GB weights are later unwanted, remove them only through VoiceStudio's model catalogue in a separate authorized cleanup after confirming no project depends on them.
- **Verification test:** A supported general ASR engine reports Available/Ready and transcribes a known 10-second sample. The managed environment retains its pinned dependencies and passes the deep self-check. If upstream later isolates NeMo safely, `nemo-parakeet` itself must become Available and pass the same sample before these weights are considered useful.

### A8. System-Wide Dictation Still Has No Installed Model

- **Severity / likelihood on this PC:** Medium / confirmed now.
- **Trigger:** Expecting the general `nvidia/parakeet-tdt-0.6b-v3` Transcription download to satisfy Capture/Dictation.
- **Visible symptom:** `/dictation/models` reports all dictation choices false even while the general ASR download proceeds.
- **Evidence/source:** Local endpoint. Dictation's recommended Windows model is a distinct sherpa-onnx package, `csukuangfj/sherpa-onnx-nemo-parakeet-tdt-0.6b-v3-int8`, shown separately in the tagged catalogue ([dictation catalogue](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/config/models.yaml#L152-L167)); its packaged download is about 0.67 GB ([sherpa dictation service](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/services/sherpa_dictation.py#L111-L141)).
- **Fixability class:** Configuration.
- **Proposed non-destructive fix:** After the current general ASR install has reached a terminal state and after A1 is cleared, deliberately install/select the separately labelled Dictation model rather than assuming one catalogue entry serves both jobs.
- **Verification test:** `/dictation/models` marks the intended dictation model installed, the global hotkey records, produces non-empty text, preserves clipboard/focus, and pastes into multiple ordinary applications.

## B. Known Upstream Or Version-Specific Issues

### B1. v0.5.0 Is An Active Beta With Rapidly Changing Contracts

- **Severity / likelihood on this PC:** Medium / high because this exact build is installed.
- **Trigger:** Depending on every workspace, engine, or UI label as production-stable, or mixing documentation from `main` with the v0.5.0 binary.
- **Visible symptom:** Changed controls, contradictory release text, engine regressions, or advice that applies only to a newer commit.
- **Evidence/source:** The tagged README says active beta and the v0.5.0 changelog shows broad lifecycle, engine, model-catalogue, remote-worker, and UI changes ([README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L278-L284), [v0.5.0 changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L197-L257)).
- **Fixability class:** Monitor; upstream only for defects.
- **Proposed non-destructive fix:** Pin audit decisions to the installed tag, read update release notes before applying, back up portable state, and re-run the acceptance checklist after every update.
- **Verification test:** About/version, backend version, and documentation tag agree; the full minimal checklist still passes after an update.

### B2. Windows Sherpa Parakeet Can Load But Decode Silence

- **Severity / likelihood on this PC:** Medium / medium on Windows if the recommended sherpa Parakeet model is used.
- **Trigger:** The sherpa-onnx NeMo-TDT dictation model downloads and loads but returns empty tokens for real speech.
- **Visible symptom:** Hotkey recording completes with an empty transcript; VoiceStudio demotes that model and falls back to the main Capture ASR.
- **Evidence/source:** v0.5.0's own Windows regression test documents empty tokens across int8/fp32 and multiple sherpa paths, with Whisper/Zipformer working ([silent-model test](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/tests/test_dictation_silent_model.py#L1-L27)); the demotion/fallback is tested separately ([demotion test](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/tests/test_dictation_model_demotion.py#L1-L33)) and recorded in the changelog ([changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L545-L550)).
- **Fixability class:** Workaround; upstream only for decoder compatibility.
- **Proposed non-destructive fix:** Let VoiceStudio's demotion stand and validate a Whisper/Zipformer-compatible fallback; do not repeatedly reinstall a model that is present but silent.
- **Verification test:** Speak a fixed phrase three times; each attempt yields non-empty text, and the log clearly names the selected or fallback ASR without oscillating every launch.

### B3. IndexTTS 2.5 Windows Configuration/Timeout Report

- **Severity / likelihood on this PC:** Medium / low unless IndexTTS 2.5 is installed and selected.
- **Trigger:** Enabling the optional IndexTTS 2.5 sidecar on Windows, especially for long text.
- **Visible symptom:** Missing/wrong `config_v2_5.yaml`, failed launch, or long jobs ending after sidecar timeout/termination.
- **Evidence/source:** First-party VoiceStudio issue [#1611](https://github.com/debpalash/VoiceStudio/issues/1611). This is a reporter-confirmed configuration/workaround, not proof that every v0.5.0 Windows install is affected.
- **Fixability class:** Workaround; upstream only for packaging and timeout behavior.
- **Proposed non-destructive fix:** Avoid enabling IndexTTS 2.5 until the core engine is accepted; if later needed, follow the upstream issue's exact validated config guidance and use short chunks while monitoring the sidecar.
- **Verification test:** Sidecar health passes, a short and a representative long sample both produce complete audio, and no process is killed by the timeout.

### B4. “Generation Capacity Is Busy” Can Persist On Low-VRAM Windows

- **Severity / likelihood on this PC:** Medium / low on this 48 GB GPU, but possible if all four workers wedge.
- **Trigger:** Repeated/concurrent generations or an abandoned worker semaphore, especially on low-VRAM hardware.
- **Visible symptom:** Retry/Abort dialog repeatedly says generation capacity is busy even when the user expects no active work.
- **Evidence/source:** First-party v0.5.0 Windows report [#1616](https://github.com/debpalash/VoiceStudio/issues/1616). The local backend sized four GPU workers from available VRAM; no local busy-capacity error was observed.
- **Fixability class:** Monitor; workaround; upstream only if capacity does not recover.
- **Proposed non-destructive fix:** Keep initial testing single-job/sequential, use the app's safe Flush/unload path only when no legitimate job is running, and capture worker status if capacity stays busy.
- **Verification test:** Four short sequential generations pass; after each, active-job/worker counts return to idle and a fifth job starts immediately.

### B5. v0.5.0 Dictation-Pill Documentation Contradicts Itself

- **Severity / likelihood on this PC:** Low / high as an expectation problem, not a runtime failure.
- **Trigger:** Using release prose to decide whether a floating dictation pill should appear.
- **Visible symptom:** User assumes the pill is missing or wrongly present.
- **Evidence/source:** The same tagged changelog says the pill is back ([line 207](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L197-L208)) and later says it no longer appears ([line 238](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L235-L239)); the detailed v0.5.0 change says it appears again ([line 222](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L220-L223)).
- **Fixability class:** Upstream only; monitor.
- **Proposed non-destructive fix:** Judge dictation by recording/transcription/paste outcome, not pill presence; document actual installed behavior during the acceptance test.
- **Verification test:** Hotkey starts and ends recording, provides some unambiguous feedback, and pastes text without stealing focus regardless of pill implementation.

### B6. Remote-Worker Security Documentation Is Internally Inconsistent

- **Severity / likelihood on this PC:** High if exposed / low now because remote workers are off.
- **Trigger:** Enabling “Accept connections” or sharing join details based on the TLS headline alone.
- **Visible symptom:** Operator believes traffic is encrypted/pinned while a documented mode may provide neither encryption nor server verification.
- **Evidence/source:** The official v0.5.0 guide first says inbound connections use TLS and no plaintext ([remote workers](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/remote-workers.md#L249-L267)) but then warns “Accept connections” trades away encryption and server verification ([same guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/remote-workers.md#L280-L289)). The release headline also claims certificate-pinned TLS ([changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L243-L250)).
- **Fixability class:** Workaround now; upstream only for clarification/implementation.
- **Proposed non-destructive fix:** Leave inbound multi-user “Accept connections” off until the exact transport is clarified upstream. If remote compute is later needed, restrict it to a trusted private network and verify certificate pinning empirically.
- **Verification test:** Packet/connection inspection shows TLS, the expected certificate fingerprint is enforced, revoked tokens fail, and no task/audio is accepted before approval.

## C. Plausible Environmental Or Configuration Risks Not Currently Observed

### C1. Close-To-Tray, Quit, Restart, And Startup Can Be Confused

- **Severity / likelihood on this PC:** High / high because clicking **X** already hid rather than terminated the app.
- **Trigger:** Treating the window close button as a full exit, launching a second copy, updating, or restarting while the original backend remains alive.
- **Visible symptom:** Old backend owns port 3900, new UI attaches to stale state, model loads refuse, or startup seems inconsistent.
- **Evidence/source:** Current process remained the original after **X**. The changelog documents prior stale/zombie-backend and port-conflict hardening, showing these are important lifecycle boundaries ([v0.5.0 changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L716-L724)).
- **Fixability class:** Configuration/workflow.
- **Proposed non-destructive fix:** Use **X** only to hide; use tray **Quit** when a complete stop is intended. Before relaunch/update, verify no VoiceStudio/Python backend owns port 3900.
- **Verification test:** Hide preserves dictation/tray operation; Quit removes the full process tree and port; one relaunch produces exactly one app tree and a clean backend run.

### C2. Portable Data Can Become Machine-Bound Or Be Lost During Folder Operations

- **Severity / likelihood on this PC:** High / medium.
- **Trigger:** Moving only the EXE, choosing an unwritable/outside data folder, copying while the database is live, overwriting the folder during update, or assuming encrypted secrets transfer to another PC.
- **Visible symptom:** Fresh setup screen, missing voices/history/projects, stranded model cache, database inconsistency, or HF token needing re-entry.
- **Evidence/source:** Portable mode is a whole-folder install; an in-folder writable target can stay relative, while an external/read-only target is recorded as an absolute machine-specific path ([Windows portable guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/windows.md#L235-L267)). Encrypted HF settings are per-machine and may require re-saving after copying portable data ([HF token guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/setup/huggingface-token.md#L196-L212)).
- **Fixability class:** Configuration/monitor.
- **Proposed non-destructive fix:** After a clean Quit, back up the complete portable folder to a versioned destination; separately record which caches are large/re-downloadable and which folders contain irreplaceable voices/projects/outputs. Never overwrite the only copy.
- **Verification test:** A read-only inventory/hash manifest matches the backup; a controlled restore to a separate path opens with voices/projects/history intact, while secrets are deliberately revalidated without exposing them.

### C3. Updates Can Interrupt Work Or Change Engine Compatibility

- **Severity / likelihood on this PC:** High / medium over time.
- **Trigger:** Installing an update with active uploads, downloads, transcription, translation, exports, or synthesis; skipping versioned backup/acceptance.
- **Visible symptom:** Incomplete work, old/new backend mismatch, sidecar/model incompatibility, or an apparent regression after update.
- **Evidence/source:** v0.4.2 added in-flight update protection because earlier behavior could discard many job types ([v0.5.0 changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L394-L409)). v0.5.0 preserves the renamed app's data folder/settings, but that is not a substitute for backup ([v0.5.0 changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L197-L203)).
- **Fixability class:** Workflow/monitor.
- **Proposed non-destructive fix:** Update only from an idle, cleanly quit state after a portable backup; record current version and rerun the acceptance checklist before deleting the older copy.
- **Verification test:** New version starts one backend, sees prior projects/history/models, passes the same test corpus, and the prior folder remains recoverable until accepted.

### C4. Blackwell/CUDA Core Works, But Optional Native Engines May Lag Compute Capability 12.0

- **Severity / likelihood on this PC:** High for an affected engine / medium across the optional catalogue.
- **Trigger:** Selecting an optional engine whose PyTorch extension, Triton kernel, cuDNN/CTranslate2 component, or sidecar binary was built before RTX PRO 5000 Blackwell support.
- **Visible symptom:** `no kernel image`, invalid device function, wrong-architecture DLL/PYD, silent CPU fallback, native abort, or backend restart.
- **Evidence/source:** Local core VoiceStudio model loaded CUDA successfully on driver 596.59 with compute capability 12.0 and ~48 GB VRAM. VoiceStudio ships CUDA-enabled PyTorch on Windows and does not need a separate CUDA Toolkit ([Windows guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/windows.md#L217-L220)); optional engines have independent runtime/dependency support matrices ([engine matrix](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L303-L355)).
- **Fixability class:** Monitor; workaround/upstream per engine.
- **Proposed non-destructive fix:** Keep the default core engine as the control. Introduce optional engines one at a time, run short/long acceptance samples, and reject any silent CPU fallback or native crash.
- **Verification test:** Engine status reports CUDA on the intended GPU, a representative job completes, GPU utilization rises, CPU-only fallback is not silently selected, and backend remains alive.

### C5. Triton/`torch.compile` Can Add Windows Instability Without Being Required

- **Severity / likelihood on this PC:** Medium / low for the current eager path; higher if partial Triton is added.
- **Trigger:** Installing a partially compatible Windows Triton build or enabling compile for engines that consume much more VRAM during compilation.
- **Visible symptom:** compile-time error, long first render, temporary VRAM spike, OOM, or kernel incompatibility.
- **Evidence/source:** Local log says Triton unavailable and eager mode selected. Official guidance says this is normal on Windows and suggests disabling compile only when actual compile/OOM trouble appears, particularly below 16 GB ([Windows troubleshooting](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/windows.md#L279-L288)).
- **Fixability class:** Configuration/monitor.
- **Proposed non-destructive fix:** Keep the known-good eager path unless a measured performance need justifies a controlled Triton test; do not install Triton merely to remove a warning.
- **Verification test:** Short and long synthesis complete in eager mode with stable VRAM; any compile experiment must beat the baseline without errors or worse peak memory.

### C6. Worker Concurrency Can Exhaust VRAM Or Leave Capacity Occupied

- **Severity / likelihood on this PC:** Medium / low-to-medium despite large VRAM.
- **Trigger:** Four concurrent GPU jobs, overlapping TTS and ASR/model loads, large optional engines, or abandoned jobs.
- **Visible symptom:** OOM, process kill/restart, “capacity busy,” very slow jobs, or Flush not helping an active task.
- **Evidence/source:** Local auto-sizing selected four workers. VoiceStudio documents roughly one worker per 5 GB with a maximum of four and recommends sequential work or manual limits when needed ([performance guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md#L214-L232)); Flush cannot cancel an abandoned job and should be used only when safe ([performance guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md#L243-L267)).
- **Fixability class:** Configuration/workaround.
- **Proposed non-destructive fix:** Begin at one job at a time, measure peak VRAM per engine, then raise concurrency only when representative loads leave comfortable headroom. Use Stop/Cancel semantics, not Flush, for a live job.
- **Verification test:** Representative concurrent load stays below VRAM capacity, jobs finish, worker count returns to idle, and a new job starts without restart.

### C7. Download, Cache, Mirror, Token, And Free-Space Failures Can Look Like Engine Failures

- **Severity / likelihood on this PC:** Medium / medium.
- **Trigger:** Interrupted network/TLS, stale mirror, different HF identity, gated license, antivirus locking `.part`, or insufficient free disk during a model/sidecar install.
- **Visible symptom:** Long `.part` file, 401/403, checksum retry, “not installed,” engine marked unavailable, or a load error blamed on missing weights.
- **Evidence/source:** Current Parakeet `.part` proves this path is active, not failed. VoiceStudio races/probes official and community HF endpoints, verifies checksums, and supports manual fallback ([troubleshooting](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/troubleshooting.md#L391-L404)); v0.5.0's changelog says interrupted model downloads repair/resume rather than requiring deletion ([changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L394-L422)).
- **Fixability class:** Monitor/configuration/workaround.
- **Proposed non-destructive fix:** Watch byte/timestamp progress and explicit terminal status; validate active HF source and free space; use built-in repair/resume before any manual cache deletion. Do not mix simultaneous installs of the same model.
- **Verification test:** Download reaches checksum-verified Installed/Ready state, no `.part` remains as the only weight, and a cold load works offline after the complete cache is present.

### C8. Database, History, Outputs, And Project References Need Independent Backup Verification

- **Severity / likelihood on this PC:** High impact / low currently; database integrity is healthy.
- **Trigger:** Live-copy backup, storage reset, folder move, history deletion, disk failure, or deleting a project/output referenced by another workflow.
- **Visible symptom:** Missing history/output, orphaned voice references, completed job with unavailable media, or SQLite lock/corruption.
- **Evidence/source:** Local database integrity passed, but history has no successful generation baseline. Official Reset & remove distinguishes settings, downloaded assets, models, created data, history, and logs; Windows portable model cache is VoiceStudio-owned ([uninstall/storage guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/uninstall.md#L205-L219)).
- **Fixability class:** Configuration/monitor.
- **Proposed non-destructive fix:** Back up only after clean Quit; include DB, voices, projects, source/reference audio, generated outputs, config, and logs. Treat model caches/environment as large but reconstructible only after recording their versions.
- **Verification test:** SQLite integrity passes before and after backup; sampled history rows resolve to playable files; a copied voice/profile resolves its reference audio.

### C9. Reference Audio And Transcript Mismatch Can Degrade Or Destabilize Cloning

- **Severity / likelihood on this PC:** Medium / high until a controlled reference is used.
- **Trigger:** Noisy/reverberant/music-backed/multi-speaker reference, more than one delivery style, too long a clip, or an inaccurate supplied transcript.
- **Visible symptom:** Wrong identity, copied background/noise, unstable delivery, pronunciation errors, or slower first generation while ASR reconstructs the transcript.
- **Evidence/source:** Official guidance recommends a natural 5–15 second, single-speaker clip without music/reverb and notes that delivery is copied; over 15 seconds is capped ([README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L450-L456)). Performance docs say an exact transcript avoids first-use ASR and can improve results ([performance](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md#L197-L213)).
- **Fixability class:** Configuration.
- **Proposed non-destructive fix:** Create a small acceptance set of clean, consented 5–15 second mono references with verified transcripts; do not normalize away natural delivery before the baseline test.
- **Verification test:** Same text/reference/seed produces a recognizable, clean voice across three takes; changing only the reference delivery changes performance in the expected direction.

### C10. Language, Style Taxonomy, SSML-Lite, And Expression Tags Are Engine/Workspace Specific

- **Severity / likelihood on this PC:** Medium / high if markup is copied across engines/workspaces.
- **Trigger:** Free-form styles, a language unsupported by the active engine, using long-form SSML-lite in the Voice workspace, or inserting an expression tag the active engine does not implement.
- **Visible symptom:** Validation error, tag spoken literally, wrong accent/dialect, missing pause, or different output between Voice and Stories/Audiobook.
- **Evidence/source:** Expression docs say `[pause]` is universal, other tags are engine-specific and may be spoken literally, `whisper` is a style, and SSML-lite is for Audiobook/Stories rather than the Voice workspace ([expressive speech](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/expressive-speech.md#L193-L232)). Voice-design attributes are language-specific ([voice design](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/voice-design.md#L245-L308)).
- **Fixability class:** Configuration/workaround.
- **Proposed non-destructive fix:** Use the active engine's capability matrix and UI-provided taxonomy; test markup one token at a time in the intended workspace; keep a plain-text fallback.
- **Verification test:** A tiny matrix covering pause, whisper/style, one expression tag, and one target language produces the documented behavior with no literal control tags in the audio.

### C11. FFmpeg/FFprobe/yt-dlp Are Healthy Now But Online Ingest Remains Fragile

- **Severity / likelihood on this PC:** Medium / low for local media, medium for website URLs.
- **Trigger:** Tool corruption/version drift, unsupported codec, site-side extractor change, age/login restriction, proxy/TLS, or cookie import failure.
- **Visible symptom:** URL ingest fails, no audio stream is found, remux/export fails, or site requests authentication.
- **Evidence/source:** Local media-tools endpoint reports bundled FFmpeg/FFprobe and yt-dlp 2026.07.04 healthy. VoiceStudio documents the resolution order, Audio Tools restore/update, and one-time browser cookie import with best-effort deletion ([troubleshooting](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/troubleshooting.md#L314-L324)).
- **Fixability class:** Monitor/configuration/workaround.
- **Proposed non-destructive fix:** Use a local media file as the baseline; for URL ingest, update/restore only through Audio Tools and treat cookies as sensitive credentials. Prefer user-owned downloads where site terms permit.
- **Verification test:** One local MP4 and one authorized URL import, transcribe, and export correctly; no cookie file remains where the import workflow says it should be deleted.

### C12. Microphone, Hotkey, Focus, Clipboard, And Elevation Can Break Dictation Independently Of ASR

- **Severity / likelihood on this PC:** High for the user experience / medium until tested.
- **Trigger:** Windows microphone privacy disabled, hotkey collision, wrong mic/channel, target window loses focus, clipboard timing, or attempting to inject into an elevated app from a normal process.
- **Visible symptom:** No recording, wrong device, blank text, transcript copied but not pasted, paste lands in the wrong window, or admin-window insertion fails.
- **Evidence/source:** VoiceStudio v0.5.0 added mic/channel selection and live level meters ([changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L253-L255)) and describes global dictation/autopaste in its feature matrix ([README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L303-L355)). These layers are separate from model installation.
- **Fixability class:** Configuration/workaround.
- **Proposed non-destructive fix:** Validate microphone meter and a unique hotkey first; then test paste into Notepad, browser, chat/editor, Windows Terminal, and one elevated/non-elevated boundary. Keep auto-submit off during validation.
- **Verification test:** Five fixed phrases produce the correct transcript in the intended field, clipboard content is preserved, focus does not move, Esc cancels safely, and elevated-app limitations are surfaced honestly.

### C13. General Transcription, Live Dictation, Dubbing ASR, And Diarization Are Distinct Pipelines

- **Severity / likelihood on this PC:** High / high risk of configuration confusion.
- **Trigger:** Assuming one installed Parakeet/Whisper model or one successful transcript proves every STT-consuming workspace.
- **Visible symptom:** Transcription works while Dictation says uninstalled, Dubbing falls back to another ASR, or multi-speaker audio collapses into one/fewer speakers.
- **Evidence/source:** VoiceStudio exposes 11 ASR engines plus separate sherpa-onnx live dictation ([README engine matrix](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L303-L355)). Diarization additionally requires gated pyannote models, two accepted agreements, and ~600 MB; otherwise it falls back to a less accurate silence-gap heuristic ([diarization guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/features/diarization.md#L204-L224)).
- **Fixability class:** Configuration/workaround.
- **Proposed non-destructive fix:** Maintain separate acceptance tests for file transcription, REST transcription, dictation hotkey, single-speaker dub, and multi-speaker diarization. Accept the pyannote terms only if that feature is wanted and the licensing/privacy decision is understood.
- **Verification test:** The same labelled two-speaker clip returns accurate text, timestamps, and two stable speaker labels; live dictation independently pastes a fixed phrase.

### C14. Dubbing Translation Quality Depends On Engine, Network, LLM, And Timing Mode

- **Severity / likelihood on this PC:** Medium / medium.
- **Trigger:** Choosing online Google/DeepL/Microsoft/MyMemory without packages/keys, Cinematic/Autofit without a configured LLM, or trusting automatic translation on names/technical terms/tight subtitle slots.
- **Visible symptom:** Package/key error, data leaves the PC, quality silently falls back to Fast, inconsistent terminology, “Tight fit/Won't fit” badges, or unnatural time-stretch.
- **Evidence/source:** Argos and NLLB are the documented offline packaged choices; other engines and LLM routes have package/key/network requirements. Cinematic/Autofit need an LLM and otherwise fall back to Fast with a notice ([translation engines](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/dubbing/translation-engines.md#L195-L207), [quality and providers](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/dubbing/translation-engines.md#L246-L276)).
- **Fixability class:** Configuration/workaround.
- **Proposed non-destructive fix:** Baseline with offline Argos or NLLB, manually review transcript/translation/timing, and use Paste Translation for human/external revisions. Enable a remote translator/LLM only after an explicit data-routing decision.
- **Verification test:** A short bilingual sample keeps names and meaning, fits every slot, preserves original transcript, and exports playable media/subtitles; network monitoring matches the chosen local/remote route.

### C15. Optional TTS/ASR Engines Have Independent Dependencies, Capabilities, And Licenses

- **Severity / likelihood on this PC:** High impact / medium as catalogue exploration expands.
- **Trigger:** Installing an engine because it appears in the catalogue without checking cloning, languages, GPU support, model/code license, gated access, and sidecar maturity.
- **Visible symptom:** Engine is installed but cannot clone, wrong-language error, separate multi-GB sidecar, license prompt, CPU-only performance, or native crash.
- **Evidence/source:** The official engine matrix distinguishes cloning, voice design, platform/runtime, optional dependencies, and separate licenses; clone-less engines cannot perform identity jobs ([README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L303-L355)). v0.5.0 specifically added opt-in IndexTTS 2.5 and PocketTTS with separate conditions ([changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L252-L260)).
- **Fixability class:** Configuration/monitor/upstream per engine.
- **Proposed non-destructive fix:** Keep an engine acceptance sheet: job type, language, clone/design ability, device, peak VRAM/RAM, install size, code/model license, sample outputs, and rollback path. Add one engine at a time.
- **Verification test:** The engine passes every job it claims to support and cleanly rejects unsupported jobs before consuming time; license evidence is recorded.

### C16. Packaged Portable Build Cannot Reliably Add Arbitrary Translation Packages In-App

- **Severity / likelihood on this PC:** Medium / high if Google/DeepL/Microsoft/MyMemory or OpenAI package is selected.
- **Trigger:** Pressing Install for an optional Python translation provider in the signed/packaged environment.
- **Visible symptom:** Install affordance says disabled/read-only or the chosen provider remains unavailable until backend restart in a from-source environment.
- **Evidence/source:** Official v0.5.0 translation docs say packaged builds intentionally disable such installs and recommend bundled Argos/NLLB; one-click optional Python installs are a from-source path ([translation engines](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/dubbing/translation-engines.md#L222-L245)).
- **Fixability class:** Workaround/configuration.
- **Proposed non-destructive fix:** Use Argos/NLLB in the portable build or run the optional provider from a separately managed source install; do not mutate the packaged Python environment manually.
- **Verification test:** Selected packaged translator reports Ready and completes offline; no ad-hoc package install disappears after update.

### C17. LLM Refinement Can Leak Content, Add Cost/Latency, Or Fall Back Silently

- **Severity / likelihood on this PC:** High for privacy / low until a provider is enabled.
- **Trigger:** Routing dictation cleanup, Cinematic/Autofit, glossary, direction parsing, or fit suggestions to a remote provider; conflicting saved/env provider selection; provider timeout/rate limit.
- **Visible symptom:** Audio transcript/text leaves the machine, bills accrue, refinement is slow, selected provider seems ignored, or translation falls back to Fast/raw transcript.
- **Evidence/source:** VoiceStudio supports many hosted providers plus local Ollama/LM Studio, encrypted local keys, an `LLM_DEFAULT_PROVIDER` environment override, and per-feature LLM Skills; disabled/failing skills degrade to non-LLM behavior ([translation/LLM provider guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/dubbing/translation-engines.md#L263-L276)).
- **Fixability class:** Configuration/monitor.
- **Proposed non-destructive fix:** Default sensitive dictation cleanup to a tested local OpenAI-compatible provider or leave it off. Record per-skill routes and verify environment overrides before enabling remote providers.
- **Verification test:** Provider Test names the intended endpoint/model, a canary phrase shows which route answered, failure produces the documented fallback, and network connections contain only approved destinations.

### C18. API, Browser UI, And Network Sharing Need Real Authentication And TLS

- **Severity / likelihood on this PC:** Critical if exposed / low while bound to loopback.
- **Trigger:** Binding beyond loopback, reverse proxying the UI/API, trusting a weak PIN, placing keys in URLs, broad trusted-network rules, or incorrect CORS.
- **Visible symptom:** Unauthenticated generation/admin access, leaked key in logs/history, session misuse, browser errors, or remote clients reaching privileged routes.
- **Evidence/source:** Loopback is unauthenticated by default; PIN is described as weak/HTTP-only, remote use should use an API key and TLS, and URL query keys can leak ([API auth](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/api-auth.md#L194-L268)). Dictation WebSockets and short sessions have separate auth rules; “trusted networks” do not erase admin requirements ([API auth](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/api-auth.md#L282-L322)).
- **Fixability class:** Configuration.
- **Proposed non-destructive fix:** Keep backend loopback-only unless a specific remote workflow exists. For remote use, require TLS plus a high-entropy API key, narrow allow-lists, short sessions, no key in URL, and private-network firewall controls.
- **Verification test:** Anonymous remote requests fail, admin routes reject trusted-network-only clients, revoked keys/sessions fail, CORS allows only intended origins, and packet capture shows TLS.

### C19. Remote Workers Move Text And Reference Audio; They Do Not Cover Dictation

- **Severity / likelihood on this PC:** High privacy / low now because feature is off.
- **Trigger:** Approving a remote GPU worker or assuming all jobs—including dictation—run remotely.
- **Visible symptom:** Synthesis text/reference audio travels to another machine; unsupported jobs fall back local; dropped worker changes performance or job placement.
- **Evidence/source:** Remote workers are off by default and send job text/reference audio only after approval ([remote worker guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/remote-workers.md#L194-L229)); dictation always remains local and only a synthesis subset is eligible ([remote worker guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/remote-workers.md#L259-L289)).
- **Fixability class:** Configuration/monitor.
- **Proposed non-destructive fix:** Leave remote compute off for the local baseline. If later enabled, document data owners, approved machines, revocation, TLS evidence, supported job list, and local fallback behavior.
- **Verification test:** An approved synthesis shows the intended remote worker; dictation remains local; revoked worker cannot reconnect; a disconnect yields documented safe fallback without duplicate output.

### C20. Voice Privacy, Consent, Licensing, And Watermarking Are Not Automatically Enforced

- **Severity / likelihood on this PC:** Critical legal/ethical impact / medium whenever cloning or sharing voices.
- **Trigger:** Cloning a voice without permission, exporting persona bundles with raw reference audio, using optional models under incompatible terms, disabling/assuming watermark, or publishing generated impersonation.
- **Visible symptom:** Unauthorized biometric/voice use, raw source audio shared in `.ovsvoice`, license breach, misleading synthetic media, or unwatermarked output.
- **Evidence/source:** Persona bundles may include raw reference audio; consent verification is required for agent/community flows but not local synthesis, and license metadata is not enforced ([persona format](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/persona-format.md#L194-L224)). App/model/optional-engine licenses differ, and network privacy depends on chosen engines ([README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L450-L472)). v0.5.0's invisible watermark is opt-out and affects only audio generated after the setting change ([changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L253-L258)).
- **Fixability class:** Configuration/governance.
- **Proposed non-destructive fix:** Use only owned or explicitly consented voices; retain permission and license records; exclude raw reference audio when sharing unless necessary; label synthetic media; verify watermark status rather than assuming it.
- **Verification test:** Every reusable voice has source, consent, permitted uses, retention, and license fields; a shared persona contains only intended assets; generated-audio metadata/watermark policy matches the release plan.

### C21. Logs And Diagnostics Can Be Misread Or Expose Sensitive Paths

- **Severity / likelihood on this PC:** Medium / high during troubleshooting.
- **Trigger:** Treating every warning as failure, trusting shallow diagnostics as readiness, or sharing full logs/config without review.
- **Visible symptom:** Unnecessary reinstall, missed initiating fault, exposed usernames/paths/endpoints, or false assurance from 10/10.
- **Evidence/source:** This audit found harmless eager-mode/process warnings alongside the high-impact shutdown latch and a shallow 10/10 result. VoiceStudio documents basic versus deep self-checks ([troubleshooting](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/troubleshooting.md#L196-L211)) and v0.5.0 carries run-specific error capture to avoid mixing a crashed run with a replacement process ([changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L266-L270)).
- **Fixability class:** Workflow/monitor.
- **Proposed non-destructive fix:** Correlate time, job ID, process lifecycle, terminal event, output file, and history. Redact tokens, private paths, media names, remote addresses, and reference content before sharing bundles.
- **Verification test:** A sanitized diagnostic package still contains version, hardware, job ID, timestamps, stack, and terminal state but no secrets or unrelated private content.

## D. Harmless Warnings And Non-Issues

### D1. `torch.compile` Skipped Because Triton Is Unavailable

- **Severity / likelihood on this PC:** None-to-low / confirmed.
- **Trigger:** Normal Windows startup without a supported Triton package.
- **Visible symptom:** Warning says eager mode is used.
- **Evidence/source:** Local log; official Windows guide says Triton is typically unavailable and eager mode is supported ([Windows guide](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/windows.md#L279-L288)).
- **Fixability class:** Monitor; no fix needed.
- **Proposed non-destructive fix:** Leave it alone unless a measured compile-specific problem exists.
- **Verification test:** Core synthesis completes with acceptable speed/VRAM in eager mode.

### D2. One `WinError 10054` Did Not Prevent A Later Successful Model Load

- **Severity / likelihood on this PC:** Low / observed once.
- **Trigger:** Local socket/client closes while asyncio is completing an operation.
- **Visible symptom:** Connection-reset stack line.
- **Evidence/source:** Local log chronology: the reset preceded a successful CUDA model load. No persistent external network or backend failure followed from that line.
- **Fixability class:** Monitor.
- **Proposed non-destructive fix:** Ignore as isolated; investigate only if it repeats at the same job stage and correlates with a failed terminal event.
- **Verification test:** Several jobs complete without a repeating reset/failure correlation.

### D3. Two Python Processes Are A Launcher/Interpreter Chain, Not Duplicate Backends

- **Severity / likelihood on this PC:** None / confirmed.
- **Trigger:** Inspecting Task Manager/process tree.
- **Visible symptom:** Two Python entries under the desktop app.
- **Evidence/source:** Local parent/child chain is app PID 70460 → managed-environment launcher PID 48688 → real Python backend PID 53984; only PID 53984 owns port 3900.
- **Fixability class:** Monitor; no fix needed.
- **Proposed non-destructive fix:** Diagnose duplicates by process ancestry and port ownership, not count alone.
- **Verification test:** Exactly one process tree owns one backend port; a clean Quit removes the entire chain.

### D4. `loaded=false` While Idle Is Normal Lazy Loading

- **Severity / likelihood on this PC:** None by itself / confirmed.
- **Trigger:** Checking model state before a generation or after unload/idle timeout.
- **Visible symptom:** Model catalogue/status says ready but not loaded.
- **Evidence/source:** Official performance guide says first generation is slower because models load lazily and can unload to free memory ([performance](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md#L197-L213), [unload behavior](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md#L243-L267)).
- **Fixability class:** Monitor; no fix needed.
- **Proposed non-destructive fix:** Distinguish Ready/Installed from resident-in-VRAM. Investigate only if load is attempted and fails.
- **Verification test:** A cold first request loads the model and produces audio; later status reflects residency or documented unload.

### D5. Unacknowledged Crash Marker Is Evidence To Preserve, Not Proof Of Current Crash

- **Severity / likelihood on this PC:** Low / confirmed marker.
- **Trigger:** Previous backend did not record a clean terminal acknowledgement.
- **Visible symptom:** Prior-run notice or marker with `acked_ts: 0`.
- **Evidence/source:** Local marker; changelog explicitly says unclean prior shutdowns can be benign (sleep, force-quit, VM stop) ([changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L349-L352)).
- **Fixability class:** Monitor.
- **Proposed non-destructive fix:** Preserve it until lifecycle verification; acknowledge only after evidence is captured and a clean run is proven.
- **Verification test:** Next clean Quit/relaunch does not create a new marker.

### D6. A Growing `.part` File During An Active Model Download Is Expected

- **Severity / likelihood on this PC:** None while growing / confirmed at audit time.
- **Trigger:** Model is still transferring.
- **Visible symptom:** Catalogue says not installed and a large `.part` blob exists.
- **Evidence/source:** Local blob grew and had a recent write time while the backend held HF/AWS HTTPS connections; VoiceStudio documents resumable/repairable interrupted downloads ([changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md#L394-L422)).
- **Fixability class:** Monitor.
- **Proposed non-destructive fix:** Wait for terminal state; do not delete/cancel/retry solely because `.part` exists.
- **Verification test:** Growth ends in Installed/Ready with complete weights, or a clear stalled/failed state persists long enough to justify repair.

## E. Feature Gaps And Honest Boundaries

### E1. VoiceStudio Is A Voice Production Studio First; Dictation Is One Feature

- **Severity / likelihood on this PC:** Medium decision impact / certain product boundary.
- **Trigger:** Expecting one app to replace every dedicated dictation behavior because it includes a global hotkey.
- **Visible symptom:** More startup/model/lifecycle surface than a small always-on dictation utility and missing or less-documented paste conveniences.
- **Evidence/source:** VoiceStudio spans cloning/design, 14+ TTS engines, 11 ASR engines, dubbing, audiobooks, Stories, API/MCP, and remote compute ([README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L303-L410)); system-wide dictation is only one row in that larger product.
- **Fixability class:** Product choice; monitor.
- **Proposed non-destructive fix:** Use VoiceStudio for production/cloning and keep a dedicated dictation tool until VoiceStudio's dictation proves equally reliable for the user's daily target apps.
- **Verification test:** Seven-day daily use produces no missed hotkeys, empty transcripts, misplaced paste, or backend-lifecycle failure while production work also runs.

### E2. Dictation Model Catalogue Is Separate From General ASR Catalogue

- **Severity / likelihood on this PC:** Medium / confirmed boundary.
- **Trigger:** Installing a general Transcription model and expecting Capture/Dictation readiness.
- **Visible symptom:** One catalogue says installed while `/dictation/models` remains false.
- **Evidence/source:** Separate tagged entries for general Parakeet ([general ASR](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/config/models.yaml#L116-L130)) and sherpa-onnx dictation ([dictation ASR](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/backend/config/models.yaml#L152-L167)).
- **Fixability class:** Configuration.
- **Proposed non-destructive fix:** Label and test both pipelines separately in the usage note.
- **Verification test:** Each model's install status and its own job type pass independently.

### E3. Remote Workers Do Not Replace Local Dictation Compute

- **Severity / likelihood on this PC:** Low now / certain feature limitation.
- **Trigger:** Trying to offload the always-on microphone/dictation model to another GPU.
- **Visible symptom:** Dictation still consumes local CPU/RAM/GPU and remote worker choice has no effect.
- **Evidence/source:** Official guide says dictation always runs locally and remote workers serve only eligible synthesis work ([remote workers](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/remote-workers.md#L259-L289)).
- **Fixability class:** Upstream only/product design.
- **Proposed non-destructive fix:** Size and validate dictation on this PC; use remote workers only for documented synthesis jobs.
- **Verification test:** Resource monitoring confirms dictation is local and a supported TTS job uses the selected worker.

### E4. Packaged Builds Favor Bundled Translators Over Arbitrary Python Extensions

- **Severity / likelihood on this PC:** Low-to-medium / certain packaged-build limitation.
- **Trigger:** Wanting online MT engines that need optional Python packages inside this portable build.
- **Visible symptom:** In-app installation is disabled and restart alone cannot make an absent package appear.
- **Evidence/source:** Official packaged-build guidance recommends Argos/NLLB and reserves dependency installation for source/dev environments ([translation engines](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/dubbing/translation-engines.md#L222-L245)).
- **Fixability class:** Workaround.
- **Proposed non-destructive fix:** Use bundled offline translators, Paste Translation, or a separate source install.
- **Verification test:** The selected path completes without modifying the packaged environment.

### E5. Consent And License Metadata Are Advisory For Local Work

- **Severity / likelihood on this PC:** High governance impact / certain limitation.
- **Trigger:** Assuming VoiceStudio will prevent unconsented cloning or illegal sharing.
- **Visible symptom:** Local synthesis/export remains possible without verified permission; persona metadata can be incomplete.
- **Evidence/source:** Official persona documentation states local synthesis does not require consent verification and license metadata is not enforced ([persona format](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/persona-format.md#L194-L224)).
- **Fixability class:** Governance; upstream only for stronger enforcement.
- **Proposed non-destructive fix:** Maintain an external consent/license gate before creating, exporting, or publishing any cloned persona.
- **Verification test:** No voice reaches production/export without the required evidence record and intended-use check.

## Prioritized Fixability Matrix

| Priority | Finding | Class | Can Be Addressed Without Reinstall? | Next Non-Destructive Action | Stop/Go Gate |
|---|---|---|---|---|---|
| P0 | A1 shutdown latch | Fix now; upstream if recurrent | Yes, likely | Controlled tray Quit, full process-exit check, one relaunch | No model testing until latch is gone |
| P0 | A2 false-negative diagnostics | Workaround/upstream | Yes | Require deep/real render readiness; include in upstream report | Do not call install “healthy” from `/health` alone |
| P0 | A3 no deliverable baseline | Fix now after A1 | Yes | Create one playable output + matching history per core workspace | No “perfect” claim until artifacts exist |
| P1 | A7 unusable 5.73 GB NeMo-Parakeet install | Workaround/upstream | Yes | Do not install `nemo_toolkit`; choose a supported general ASR; consider catalogue removal only in a separately authorized cleanup | General Transcription must pass with an Available engine |
| P1 | A8 dictation model absent | Configuration | Yes | Install/select the separate dictation model only after A7/A1 settle | Dictation must pass five-app paste test |
| P1 | A4 style taxonomy | Configuration | Yes | Use UI-supported attributes | One supported-style render succeeds |
| P1 | A5 HF token ambiguity | Configuration | Yes | Choose one intended identity/source without exposing token | Public + gated identity checks pass |
| P1 | C2/C8 portable backup | Configuration | Yes | Clean Quit, versioned whole-folder backup, manifest | Restore test resolves DB/voices/projects |
| P2 | B2 Windows silent sherpa decode | Workaround/upstream | Yes | Accept automatic demotion; validate Whisper/Zipformer fallback | Three non-empty fixed-phrase transcripts |
| P2 | C9/C10 voice/input quality | Configuration | Yes | Curated consented references + exact transcripts + tag matrix | Repeatable clean, recognizable output |
| P2 | C11–C14 media/STT/dub | Configuration/workaround | Yes | Local-file baseline, separate pipeline tests, offline translation first | End-to-end local dub/export passes |
| P2 | C15–C17 optional engines/LLM | Configuration/monitor | Yes | Add one at a time with license/privacy/route record | No silent fallback or unapproved network |
| P3 | B3/B4 optional reported bugs | Monitor/upstream | Usually | Avoid affected engine/load until needed | Test only with explicit use case |
| P3 | C18–C19 sharing/API/workers | Configuration | Yes | Leave off/loopback until threat model exists | TLS/auth/revocation tests required |
| P3 | D1–D6 warnings/non-issues | Monitor | N/A | Do nothing unless correlated with failure | No reinstall based on warning alone |

## Minimal “Perfect VoiceStudio” Acceptance Checklist

“Perfect” here means reliable for this PC and the user's intended workflows—not bug-free in every optional engine.

- [ ] About UI, backend `/health`, and installed documentation all say v0.5.0 (or the intentionally updated same version).
- [ ] Portable data remains under `D:\Apps\VoiceStudio\OmniVoiceStudio-Data`; no important path unexpectedly points to a machine-specific old location.
- [ ] Clicking **X** hides only; tray **Quit** terminates the full app/Python chain and releases port 3900; one relaunch creates one clean process tree.
- [ ] No fresh unclean-run, MCP-manager-reuse, or persistent `backend shutting down` messages after controlled relaunch.
- [ ] Basic health and system diagnostics pass **and** a deep self-check or real short synthesis produces playable audio.
- [ ] Gallery preview works and writes/streams actual audio.
- [ ] Voice workspace generates a non-empty WAV with a supported taxonomy value; output plays and history contains the matching complete row.
- [ ] A consented 5–15 second clean reference plus exact transcript produces a recognizable clone across three fixed-seed takes.
- [ ] A two-chapter Story/Audiobook containing a supported `[pause]` renders both chapters, resumes correctly, and exports playable combined audio.
- [ ] General Parakeet weights are not mistaken for a runnable engine: `nemo-parakeet` remains unused unless upstream supplies a safe isolated install path. A supported Available general ASR passes instead.
- [ ] General Transcription converts a known 10-second sample to accurate non-empty text with expected timestamps/export.
- [ ] Separate Dictation model is installed; hotkey start/stop/cancel, mic selection, feedback, focus, clipboard restoration, and paste all work in Notepad, browser, chat/editor, and Windows Terminal; admin boundary is understood.
- [ ] If sherpa Parakeet decodes silence, VoiceStudio demotes it once and the fallback produces three non-empty fixed-phrase transcripts.
- [ ] A local two-speaker clip transcribes and diarizes accurately after the intended HF identity has accepted both pyannote agreements; fallback mode is visibly labelled when used.
- [ ] Local MP4 dubbing completes transcribe → review → offline translate → synthesize → fit → export; SRT/VTT and media are playable and names/terminology are reviewed.
- [ ] FFmpeg, FFprobe, and yt-dlp show healthy; one local-media baseline passes before any authorized URL/cookie test.
- [ ] Peak VRAM/RAM is recorded for each accepted engine; sequential and intended concurrent jobs finish and worker capacity returns to idle.
- [ ] Every optional engine has a recorded code/model license, language/job compatibility, device route, install size, sample, and rollback/repair path.
- [ ] LLM skills are either off/local or deliberately mapped to approved providers; environment overrides do not silently steal selection; failure fallback is visible.
- [ ] Backend remains loopback-only unless a reviewed remote plan exists. Any remote API/worker path passes TLS, key, session, CORS, approval, revocation, and privacy tests.
- [ ] Every cloned voice has permission, intended-use, retention, and sharing rules; exported personas contain only intended reference assets and watermark policy is verified.
- [ ] A clean-Quit, versioned portable backup exists and a separate restore verification resolves DB, voices, projects, history, source media, and sampled outputs.
- [ ] The complete checklist is rerun after every VoiceStudio update, driver/PyTorch change, new engine, or storage move.

## Would A Perfect VoiceStudio Replace Handy?

### Which “Handy” Is Meant

This comparison assumes **Handy by CJ Pais at [handy.computer](https://handy.computer/)**. Confidence is high because the user's phrase “Handy computer” matches the official domain and product: a local system-wide speech-to-text app. If a different product named Handy was intended, this section must be redone rather than guessed. The current official Handy docs identify v0.9.4 and describe local model download followed by hotkey-to-focused-field dictation ([Getting Started](https://handy.computer/docs)).

### Feature-By-Feature Comparison

| Need | VoiceStudio v0.5.0 | Handy v0.9.4 | Replacement Verdict |
|---|---|---|---|
| System-wide local STT | Global hotkey, streaming/local ASR, auto-paste, optional LLM cleanup; currently unaccepted on this PC ([VoiceStudio README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L303-L355)) | Core product: click a field, hotkey, speak, local transcript/paste ([Handy Getting Started](https://handy.computer/docs)) | Potential overlap only after VoiceStudio passes the dictation checklist |
| STT model choice | 11 general ASR engines plus a separate sherpa dictation catalogue; Windows Parakeet may demote | Parakeet V3, Whisper variants, Breeze, Moonshine, GigaAM, Canary, SenseVoice, and custom models; models run locally ([Handy Models](https://handy.computer/docs/models)) | Handy is currently the clearer dedicated-model experience |
| Push-to-talk/toggle and hotkey | Supported global dictation, but v0.5.0 pill docs conflict | Dedicated PTT/toggle, remappable Windows default `Ctrl+Space`, mic/output/audio feedback ([Handy General](https://handy.computer/docs/general)) | Keep Handy unless VoiceStudio matches the exact daily controls |
| Paste compatibility | Auto-paste documented; fewer user-facing paste modes documented | Ctrl+V, Ctrl+Shift+V, Shift+Insert, direct input, clipboard-only, paste delay; terminal and elevated-app guidance ([Handy Paste Methods](https://handy.computer/docs/paste-methods)) | Handy remains stronger for mixed apps/terminals |
| Always-on behavior | Large studio/backend with tray lifecycle and current shutdown-latch defect | Start hidden, launch on startup, tray, overlay position, timed model unload ([Handy Advanced](https://handy.computer/docs/advanced)) | Handy remains lower-risk as dedicated always-on dictation today |
| Dictation history/privacy controls | VoiceStudio has broader generation/history stores; dedicated dictation retention controls must be verified | Text/audio history, limits, starring/copying/deletion, auto-delete controls ([Handy History](https://handy.computer/docs/history), [Handy Advanced](https://handy.computer/docs/advanced)) | Handy clearer if dictation-history policy matters |
| Custom vocabulary/output behavior | LLM cleanup and engine-dependent ASR options | Custom words, trailing space, auto-submit, clipboard handling, alternative shortcut backend ([Handy Advanced](https://handy.computer/docs/advanced)) | Handy has more documented dictation ergonomics |
| AI text cleanup | Per-feature LLM routing including local Ollama/LM Studio or hosted providers | Experimental dedicated post-processing hotkey with cloud or custom OpenAI-compatible endpoint ([Handy Post-Processing](https://handy.computer/docs/post-processing)) | Comparable category; privacy and latency depend on chosen provider |
| TTS and voice cloning/design | Core strength: local TTS, cloning/design, expressive controls, many engines | Not the purpose of Handy | VoiceStudio replaces cloud TTS tools, not Handy's distinct STT role |
| Dubbing, Stories, Audiobooks, API/MCP | Core VoiceStudio production capabilities ([VoiceStudio README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md#L336-L410)) | Not Handy's role | Handy cannot replace VoiceStudio here |

### Recommendation

**Do not uninstall Handy now.** The current VoiceStudio backend is unable to load models after entering its shutdown state, VoiceStudio's dictation model is not installed, the completed 5.73 GB general Parakeet weights have no safely installable NeMo engine in this packaged environment, and no end-to-end dictation acceptance test has passed.

Even after VoiceStudio becomes “perfect” for TTS/voice production, Handy is unnecessary **only if all of these are true**:

1. VoiceStudio's separate Dictation pipeline survives clean startup, hide, tray Quit, relaunch, sleep/wake, and seven days of daily use.
2. It reliably captures and pastes into every target app—including Windows Terminal/elevated boundaries—with acceptable clipboard/focus behavior.
3. The chosen local ASR model covers the user's languages and accuracy needs without silent Parakeet decoding or slow fallback.
4. Handy-specific conveniences—multiple paste methods, start hidden/startup, timed unload, custom words, trailing space, auto-submit, dedicated history/audio retention, and the separate post-processing hotkey—are not needed or VoiceStudio has verified equivalents.
5. Running VoiceStudio continuously does not interfere with TTS/ASR VRAM, backend lifecycle, or other AI workloads.

The practical long-term split may remain the best one: **VoiceStudio for TTS, cloning, dubbing, Stories/Audiobooks, and APIs; Handy for lightweight system-wide STT dictation.** If VoiceStudio later passes every dictation gate and the dedicated Handy conveniences add no value, then Handy becomes optional redundancy—not because TTS replaces STT, but because VoiceStudio has separately proven the same system-wide STT job.

## Direct Official Source Set

- [VoiceStudio v0.5.0 release](https://github.com/debpalash/VoiceStudio/releases/tag/v0.5.0)
- [VoiceStudio v0.5.0 README](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/README.md)
- [VoiceStudio v0.5.0 changelog](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/CHANGELOG.md)
- [Windows install and portable mode](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/windows.md)
- [Troubleshooting and diagnostics](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/troubleshooting.md)
- [Performance and VRAM](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/performance.md)
- [Voice Design](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/voice-design.md)
- [Expressive speech and markup](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/expressive-speech.md)
- [HF token handling](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/setup/huggingface-token.md)
- [Diarization](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/features/diarization.md)
- [Translation engines and LLM routing](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/dubbing/translation-engines.md)
- [API authentication](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/api-auth.md)
- [Remote workers](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/remote-workers.md)
- [Persona/consent format](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/persona-format.md)
- [Storage/reset/uninstall](https://github.com/debpalash/VoiceStudio/blob/v0.5.0/docs/install/uninstall.md)
- [VoiceStudio issue #1611 — IndexTTS 2.5 Windows](https://github.com/debpalash/VoiceStudio/issues/1611)
- [VoiceStudio issue #1616 — capacity busy](https://github.com/debpalash/VoiceStudio/issues/1616)
- [Handy official documentation](https://handy.computer/docs)
- [Handy models](https://handy.computer/docs/models)
- [Handy general dictation controls](https://handy.computer/docs/general)
- [Handy advanced behavior](https://handy.computer/docs/advanced)
- [Handy paste methods](https://handy.computer/docs/paste-methods)
- [Handy history](https://handy.computer/docs/history)
- [Handy post-processing](https://handy.computer/docs/post-processing)

## Related Notes

- [[VoiceStudio Windows Portable Usage]]
- [[Local Setup Index]]
