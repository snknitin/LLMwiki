# RTX PRO 5000 Perplexity Portable Computer Tutorial

Status: research and user-run evaluation plan, 2026-09-28. No Perplexity app, subscription, model, connector, or local tool has been installed or authorized by this note.

## What changed since the capture

The captured [Perplexity announcement](https://x.com/perplexity_ai/status/2092268362386780270) described a DGX Spark launch of Portable Computer with an on-device agent harness, orchestrator, and PPLX 27B model. The current [official help page](https://www.perplexity.ai/help-center/en/articles/20260915-what-is-portable-computer) now explicitly supports **Windows 10/11** PCs with an NVIDIA GeForce RTX or RTX PRO GPU with **at least 24 GB VRAM**. The RTX PRO 5000 Blackwell recorded in [[Local Setup Index]] has 48,935 MiB, so Windows is the preferred first trial. The help page lists both PPLX 27B and Qwen 27B for supported Windows PCs. Its initial Windows PPLX download is approximately **19.6 GB** including engine and classifier; it says to allow additional unpack/update space. The original DGX Spark-only framing is stale.

Portable Computer is an application/runtime with a model inside it, rather than a standalone PPLX 27B checkpoint you can point Ollama or Hermes at. Perplexity distinguishes **Personal Computer** (local file tools) from **Portable Computer** (local inference and agent execution). On Windows, install the Perplexity desktop app, then enable a local model within it. Local file access is a separate permission. The official help page says the planner, tool router, scheduler, durable queue, search index, sandbox, and chosen model run locally; it also states that browser use and connected apps may involve cloud steps. Verify the actual workflow and approval prompts before calling a task fully local. [Official product/help documentation](https://www.perplexity.ai/help-center/en/articles/20260915-what-is-portable-computer).

## Source and reply audit

The exact captured status `2092268362386780270` returned Perplexity's root post and replies. It described local runtime without cloud dependency at launch. A [reply asks about headless/daemon use](https://x.com/tjv248/status/2095549523095433519); the checked official help page documents app and GUI setup, not a supported headless SSH path, so do not plan this as a Spark daemon without a separate official answer. Other replies ask about billing and hardware. The official help page, rather than those unanswered comments, is the source for current Windows availability, subscription, downloads, and cloud escalation. [X thread](https://x.com/perplexity_ai/status/2092268362386780270), [official help page](https://www.perplexity.ai/help-center/en/articles/20260915-what-is-portable-computer).

## Requirements and boundaries

- **Account:** Perplexity Pro or Max, personal or Enterprise; managed accounts may need administrator enablement for local inference.
- **Hardware/OS:** Windows 10/11 and an RTX/RTX PRO GPU with at least 24 GB VRAM. Only one local model runs at once.
- **Disk:** approximately 19.6 GB for initial Windows PPLX 27B and approximately 19.9 GB more if adding Qwen 27B; allow unpacking and update headroom.
- **Privacy/control:** according to Perplexity, local tasks do not consume Computer credits; a cloud step requires approval and then consumes credits. Sign-in, model download, and cloud steps need network access. Local MCP servers run outside Perplexity's sandbox with user permissions, so test without adding one first.

All four statements come from [Perplexity's current help page](https://www.perplexity.ai/help-center/en/articles/20260915-what-is-portable-computer). Model weights, inference precision, an open API endpoint, and a self-hosted standalone PPLX checkpoint are **not established** by that page; do not assume it can replace an existing Hermes or LiteLLM provider.

## Windows walkthrough

Use the **Windows desktop**, not the Spark terminal.

1. Check your current plan and disk free space in the Perplexity app/Windows, and run `nvidia-smi` in PowerShell to confirm the RTX PRO 5000 and available VRAM. If another large model is resident, unload it using its normal application controls before the benchmark; preserve its registration and configuration.
2. Install or open the [Perplexity Windows desktop app](https://www.perplexity.ai/help-center/en/articles/19800002-get-started) and sign in. The official guide offers the Microsoft Store listing (product ID `9P9XG917PWCJ`) or its website installer; the latter uses the Store update system. In the top-left Menu, open **Settings → Local Inference**. The official page says unsupported GPUs do not show the download controls; treat a missing control as a diagnostic signal, not a reason to hunt for an unverified installer.
3. Under **On-device models**, download **PPLX 27B**. This installs the inference engine too. Wait for completion, then choose **PPLX 27B under Local** in the composer model menu. The first local trial should use no connected apps, no local MCP server, and a disposable test folder. [Official Windows steps](https://www.perplexity.ai/help-center/en/articles/20260915-what-is-portable-computer).
4. Give the local model a harmless, fixed task, such as: “Read the three text files in this disposable folder, find the two differing invoice totals, and produce a short evidence table with filenames. Do not edit files or use the web.” To grant this folder, enable **Local file system access** and **Desktop tools** separately in **Settings → Permissions**, then select only the test folder. The [Windows desktop guide](https://www.perplexity.ai/help-center/en/articles/19800002-get-started) says the Permissions pane requires app version **26.8.1 or later**. Verify the model menu remains on Local and inspect whether any approval prompt appears.
5. Run the **identical input and task** in Hermes, using its existing local route and same disposable files. Record whether either system reads the right files, cites specific lines/pages, attempts an unauthorized edit, requires a cloud step, and finishes without user rescue. The products have different harnesses, so compare **task success and intervention**, not raw tokens/second alone.
6. If a step asks to escalate to Perplexity Search, a frontier model, browser, or connected app, record what would be sent and the quoted credit cost before choosing. For the strict local comparison, decline escalation and mark whether the local-only task still succeeds. A later hybrid comparison can explicitly allow one approved cloud step. [Official escalation behavior](https://www.perplexity.ai/help-center/en/articles/20260915-what-is-portable-computer).

Optionally test Qwen 27B inside the same app after PPLX 27B. Perplexity says it is an additional download and only one local model runs at a time. Keep its results distinct from the already installed workstation `qwen3.8:27b` through Ollama; packaging and harness differ. Do not assume the app's model can reuse Ollama's files. [Model availability and disk table](https://www.perplexity.ai/help-center/en/articles/20260915-what-is-portable-computer).

## Comparison sheet and decision

Use one row per run: date, Windows app version, local model, task input hash, model selection screenshot/observation, task success, file citations, attempted edits, cloud prompts, approval outcome, elapsed time, peak VRAM, disk used, number of interventions, and credits consumed. Repeat a warm run, since first load and model downloads distort time. Test at least a file summarization, one structured extraction, and one simple local tool workflow; include a failure or ambiguous input. Hermes should use the same permissions and input corpus where practical.

Promote Portable Computer for a specific workflow only if the local result is reliable enough and its app-bound workflow offers a useful advantage. The initial task does not authorize installing local MCP servers, giving it production vault access, scheduling unattended work, or changing existing Hermes routing. If the Windows app cannot expose Local Inference despite meeting the published hardware requirement, save app version and a screenshot of the Local Inference page; the [official troubleshooting table](https://www.perplexity.ai/help-center/en/articles/20260915-what-is-portable-computer) lists account controls and incomplete setup among causes.

## References

- [Captured Perplexity X announcement and replies](https://x.com/perplexity_ai/status/2092268362386780270)
- [Current official Portable Computer requirements, Windows setup, and limits](https://www.perplexity.ai/help-center/en/articles/20260915-what-is-portable-computer)
- [Initial product announcement](https://www.perplexity.ai/hub/blog/introducing-portable-computer-for-local-first-ai)
- [Perplexity desktop app download](https://www.perplexity.ai/download)
- [Official Windows app installation and permissions](https://www.perplexity.ai/help-center/en/articles/19800002-get-started)

Related: [[Local Setup Index]] · [[Task Checklist]]
