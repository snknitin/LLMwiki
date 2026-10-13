# Graph Report - Local_Setup  (2026-10-13)

## Corpus Check
- 1 files · ~300,941 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1777 nodes · 5302 edges · 94 communities (68 shown, 26 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 214 edges (avg confidence: 0.84)
- Token cost: 76,519 input · 0 output

## Community Hubs (Navigation)
- Admission Proxy
- VoiceStudio Risk Audit
- Dashboard app.js
- Qwen 3.8 27B Native Spark Setup
- Agent Tooling Catalog
- Desktop Qwen Runbook
- Add Desktop Qwen and Patches
- Gemma and Hot-Swap Rules
- Spark vs Workstation Model Placement
- Additional Models and Runtimes
- Dual-Node Spark Configuration
- Frontier Model Probe
- Power Recovery and Frontier Aliases
- Spark Safe Appliance Phase 0
- Native Speed and Memory Diagnostics
- Obsidian Sync and Route Catalog
- Additional Services Controller
- Native Qwen Long Probe
- Dual-Node Frontier Recipes Research
- Workstation Tools and Desktop-Qwen Controls
- Dual-Node Frontier Runbook
- Parallel Native Downloader
- Native Reviewed Continuation Script
- MiniMax H3 LoRA Tutorials
- Nemotron Omni and Gemma Recipes
- Qwen 3.8 TensorFold Replacement
- LM Studio and LM Link
- Subscriptions and Agent Tools
- Qwen Image 2.1 ComfyUI
- Probe Test Fakes
- Spark Operations Setup
- Qwen Image BFS Body Swap
- One-Large-Model Rule and Profiles
- GLM 5.3 Flash EXL3 Tutorial
- SparkFast vs Qwen27B Capacity
- DGX Spark Aug 2026 Deployment Research
- Markdown Dashboard and Vault Sync
- Jev and Laya Decision Models
- Hermes Bootstrap and Production Probes
- Pressure Qualification Tests
- Spark Twitter Bookmarks Research
- Workstation Inference Measurement
- Always-On Hermes on Spark
- Fresh Brief and Qwen 3.8 Intake
- DeepSeek 131K Comparison
- Hermes Provider Migration Script
- Spark Multi-Model Runtime
- Downloader and Dashboard Builder
- Muse Glimmer Readiness
- Engine Decisions and Roadmap
- Qwen 3.8 Flash Next v0.30
- GLM Reasoning Bridge Handler
- Hermes LM Link Routing
- LongCat Video Avatar
- DFlash Draft Config Tests
- Device Allocation and Vision Test
- Frontier Qualification Results
- Spark Unified Memory Co-Residency
- Workstation ODS and Ollama
- ODS Playbook Phases 2-5
- LM Studio Qwen Loader
- Memory Readiness Tests
- Realtime Conversation Video
- EVIE Retrieval Tutorial
- Hermes Timeout Tests
- Perplexity Portable Computer
- Social Capture Pipeline
- Systemctl Start-Limit Tests
- Spark Ollama and ODS Tutorial
- spark-fast NVFP4 Memory Profile
- Named Custom Timeout Tests
- GLM Shim Server
- Production Wire Tests
- MTP and DFlash Speculative Decoding
- Hermes Catalog Tests
- Native Qwen HF Download Script
- Local Setup Dashboard
- Desktop Qwen Transform Tests
- Graphify Project Rules
- vLLM Cold-Start Optimization
- Ollama Context Reload Fix
- Monitors on RTX Lag Fix
- Two-Slot Migration Off Ollama
- Windows Display GPU Contention
- Fresh Brief Context Thrash
- Spark Download Relay
- Run-At-Boot Result
- Pre-Fix Ollama Env

## God Nodes (most connected - your core abstractions)
1. `Hermes Agent` - 133 edges
2. `Task Checklist` - 109 edges
3. `LiteLLM` - 99 edges
4. `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)` - 83 edges
5. `vLLM` - 83 edges
6. `LM Studio` - 83 edges
7. `Ollama` - 81 edges
8. `ODS` - 79 edges
9. `RTX PRO 5000 Workstation` - 77 edges
10. `DGX Spark ODS Playbook and Model Roadmap` - 77 edges

## Surprising Connections (you probably didn't know these)
- `Unified 524K Q8 KV Alternative` --semantically_similar_to--> `Two-Slot 262K Context and Memory Plan`  [INFERRED] [semantically similar]
  Qwen Spark Migration/LONG-PROBE-GUARDS.md → Qwen 3.8 27B Spark Serving Options.md
- `request()` --indirect_call--> `error()`  [INFERRED]
  .setup-dashboard/test_writer.py → Qwen Spark Migration/admission_proxy.py
- `DGX Spark Frontier Model Qualification Results` --references--> `Frontier Model Vision Test (image)`  [INFERRED]
  DGX Spark Frontier Model Qualification Results.md → Frontier Model Vision Test.png
- `DGX Spark Additional Services Controller` --references--> `Local Setup Dashboard`  [EXTRACTED]
  DGX Spark Additional Services Controller.md → .setup-dashboard/template.html
- `Four-Slot Q8 Memory Estimate` --references--> `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)`  [EXTRACTED]
  Qwen Spark Migration/LONG-PROBE-GUARDS.md → DGX Spark Additional Model Tutorials Index.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Desktop lag causal chain on shared display GPU** — ent_qwen_3_8_27b, ent_ollama, ent_rtx_pro_5000_workstation, ent_desktop_window_manager, ent_handy, hermes_qwen_desktop_lag_handoff_2026_09_28_gpu_display_contention [EXTRACTED 1.00]
- **Dual-Spark Frontier Hot-Swap Lane** — ent_dual_spark_cluster, ent_qwen_3_8_flash_next, ent_glm_5_3_flash, ent_deepseek_v4_1_flash, ent_spark_frontier, ent_spark_fast [EXTRACTED 1.00]
- **MiaAI Dual-Spark Frontier Recipes** — ent_qwen_3_8_flash_next, ent_glm_5_3_flash, ent_deepseek_v4_1_flash, ent_dual_spark_cluster, ent_miaai_lab [EXTRACTED 1.00]
- **Frontier hot-swap control plane** — ent_spark_frontier, ent_litellm, ent_hermes, ent_glm_reasoning_shim, ent_spark_fast, ent_dual_spark_cluster [EXTRACTED 1.00]
- **Hermes cross-machine provider routing via LM Link and Tailscale** — ent_hermes, ent_lm_link, ent_lm_studio, ent_ollama, ent_tailscale, hermes_lm_link_and_workstation_model_routing_research_spark_lmstudio_provider, hermes_lm_link_and_workstation_model_routing_research_desktop_ollama_provider [EXTRACTED 1.00]
- **MiniMax H3 local ComfyUI bench with community LoRAs** — minimax_h3_windows_video_exploration_tutorial_isolated_comfyui_bench, ent_minimax_h3, ent_comfyui, minimax_h3_character_swap_lora_windows_tutorial_character_swap_lora, minimax_h3_handheld_shaky_cam_lora_windows_tutorial_handheld_shaky_cam_lora, ent_rtx_pro_5000_workstation [EXTRACTED 1.00]
- **Performance-first Hermes serving stack** — ent_hermes, ent_litellm, ent_spark_fast, ent_vllm, ent_qwen_3_6_35b_a3b [EXTRACTED 1.00]
- **Boot recovery ordering chain** — ent_docker, ent_spark_fast, dgx_spark_pre_shutdown_and_automatic_recovery_snapshot_2026_08_20_wait_for_spark_fast, dgx_spark_pre_shutdown_and_automatic_recovery_snapshot_2026_08_20_lmstudio_service, ent_nemotron_3_5_lightning [EXTRACTED 1.00]
- **Qwen Image 2.1 ComfyUI pipeline (denoiser + encoder + VAE + LoRA)** — ent_qwen_image_2_1, ent_qwen3_vl_8b_encoder, rtx_pro_5000_qwen_image_2_1_base_windows_tutorial_qwen_image_vae, rtx_pro_5000_qwen_image_2_1_base_windows_tutorial_text_encode_qwen_image21_node, rtx_pro_5000_qwen_image_2_1_bfs_body_swap_windows_tutorial_lora_loader_model_only, ent_comfyui [EXTRACTED 1.00]
- **Native Qwen 3.8 27B serving stack on FirstSpark** — qwen_3_8_27b_native_spark_setup_tutorial_qwen38_native_service, qwen_3_8_27b_native_spark_setup_tutorial_qwen38_admission_service, qwen_3_8_27b_native_spark_setup_tutorial_spark_qwen38_provider, ent_llama_cpp, ent_unsloth_qwen3_8_27b_gguf, ent_firstspark, ent_hermes [EXTRACTED 1.00]
- **Realtime conversation video service chain** — realtime_conversation_video_windows_feasibility_tutorial_realtime_conversation_client, realtime_conversation_video_windows_feasibility_tutorial_audio_input_llm, realtime_conversation_video_windows_feasibility_tutorial_realtime_narration_video, ent_aivisspeech, realtime_conversation_video_windows_feasibility_tutorial_diffusers_movie_server, ent_ltx_2_5 [EXTRACTED 1.00]
- **SecondSpark single-node Qwen raw-qualify then LiteLLM/Hermes promotion** — ent_tensorfold, ent_secondspark, ent_litellm, ent_hermes, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_alias_qwen38_tensorfold_second, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_full_raw_qualification [EXTRACTED 1.00]
- **Dual Spark cluster bring-up** — ent_firstspark, ent_secondspark, dgx_spark_second_node_and_dual_spark_readiness_research_2026_08_20_qsfp112_dac_cable, dgx_spark_second_node_and_dual_spark_readiness_research_2026_08_20_cluster_assistant, ent_nccl, ent_dual_spark_cluster [EXTRACTED 1.00]
- **Spark alias-based model routing plane** — ent_hermes, ent_litellm, ent_spark_fast, ent_spark_small, ent_vllm, ent_llama_cpp, ent_dgx_spark [EXTRACTED 1.00]
- **Spark-authoritative Hermes with remote Desktop clients over Tailscale** — ent_hermes, ent_hermes_desktop, ent_dgx_spark, ent_tailscale, local_ai_architecture_research_hermes_serve, local_ai_architecture_research_hermes_gateway [EXTRACTED 1.00]
- **spark-fast vLLM memory and scheduling controls** — dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_kv_cache_memory_bytes, dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_gpu_memory_utilization_preflight, dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_chunked_prefill, dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_cuda_graphs, dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_spark_fast_production_profile [EXTRACTED 1.00]
- **Spark Hermes Control Plane** — ent_hermes, always_on_hermes_on_dgx_spark_hermes_serve, always_on_hermes_on_dgx_spark_hermes_gateway, ent_litellm, ent_tailscale, ent_hermes_desktop [EXTRACTED 1.00]
- **Spark Inference Engine Learning Ladder** — ent_llama_cpp, ent_vllm, ent_sglang, ent_tensorrt_llm, ent_nim [EXTRACTED 1.00]
- **Windows Qwen lag root causes** — qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_ollama_gui_context_slider, qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_context_size_mismatch_reloads, qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_monitors_on_rtx_desktop_lag, qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_ollama_qwen35_no_parallel [EXTRACTED 1.00]
- **Workstation Ollama reached from Spark Hermes via Tailscale Serve** — ent_ollama, ent_tailscale_serve, ent_desktop_ollama_provider, ent_hermes, ent_qwen_3_8_27b, ent_rtx_pro_5000_workstation [EXTRACTED 1.00]
- **Mutually exclusive dual-node frontier lanes on port 8100** — dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_baseline, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_fp8_comparison, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_mtp_850k_accepted, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_deepseek_recipe, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_port_8100 [INFERRED 0.85]
- **Frontier Lane Hot-Swap Lifecycle** — ent_aux_services, ent_spark_frontier, ent_spark_model, ent_spark_fast, dgx_spark_dual_node_community_frontier_models_runbook_common_drain_rollback, dgx_spark_dual_node_community_frontier_models_runbook_litellm_hermes_aliases [INFERRED 0.85]
- **Frontier qualification evidence pipeline** — dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_probe_suite, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_evidence_suite, dgx_spark_frontier_model_qualification_results_headline_table, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_perf_results, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_vs_fp8_results, ent_spark_frontier_check [INFERRED 0.85]
- **Gateway-routed logical aliases with controlled model swap** — dgx_spark_twitter_bookmarks_analysis_safe_swap_controller, local_ai_architecture_research_hotswap_as_routing, personal_hermes_obsidian_multinode_design_gateway_hot_swap_policy, ent_litellm, personal_hermes_obsidian_multinode_design_logical_routes [INFERRED 0.85]
- **Unified-memory safety qualification gates (MemAvailable >=10 GiB, no NV_ERR_NO_MEMORY)** — dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_100k_memory_gate, dgx_spark_single_node_qwen_3_8_flash_next_v0_30_tutorial_memory_kernel_gate, dgx_spark_sparkdash_monitoring_tutorial_coexistence_decision, ent_unified_memory_128gb [INFERRED 0.85]
- **VoiceStudio Readiness Failure Chain** — voicestudio_risk_audit_shutdown_latch, voicestudio_risk_audit_false_negative_health, voicestudio_risk_audit_no_deliverable_baseline, voicestudio_risk_audit_lifecycle_confusion [INFERRED 0.85]
- **Clients sharing the 2 llama-server slots** — desktop_qwen_runbook_llama_server, desktop_qwen_runbook_hermes, desktop_qwen_runbook_fresh_brief, desktop_qwen_runbook_tailscale_serve_8444 [EXTRACTED 1.00]
- **Desktop Qwen server lifecycle control** — scripts_desktop_qwen_apply, scripts_qwen_on, scripts_qwen_off, desktop_qwen_runbook_task_scheduler_boot_task [INFERRED 0.85]
- **Single-GPU contention (Qwen vs ComfyUI vs Ollama)** — desktop_qwen_runbook_rtx_pro_5000, desktop_qwen_runbook_llama_server, desktop_qwen_runbook_comfyui, desktop_qwen_runbook_ollama_tray [EXTRACTED 1.00]

## Communities (94 total, 26 thin omitted)

### Community 0 - "Admission Proxy"
Cohesion: 0.06
Nodes (15): Admission, create_app(), chat(), health(), json_call(), models(), recover_loop(), startup() (+7 more)

### Community 1 - "VoiceStudio Risk Audit"
Cohesion: 0.06
Nodes (50): Safe Download Order, Downloaded vs running distinction, Model store ownership rules, Hugging Face Hub cache, OmniVoice TTS Model, Parakeet TDT 0.6B v3, Whisper, VoiceStudio v0.5.0 Portable Install (+42 more)

### Community 2 - "Dashboard app.js"
Cohesion: 0.10
Nodes (44): applyLibrarySnapshot(), closeDrawer(), decodeSafe(), download(), drawTask(), empty(), exportHTML(), exportProgress() (+36 more)

### Community 3 - "Qwen 3.8 27B Native Spark Setup"
Cohesion: 0.09
Nodes (37): Unsloth Qwen3.8-27B GGUF, Auxiliary Services Locked Inventory Entries, Qwen 3.8 27B Native Spark Setup Tutorial, Named-Provider Timeout Patch for Hermes, LM Studio Residency Retirement on FirstSpark, qwen38-admission Service, qwen38-native Service (llama-server worker), Hermes spark-qwen38 Provider (qwen38-27b-spark) (+29 more)

### Community 4 - "Agent Tooling Catalog"
Cohesion: 0.06
Nodes (45): Addy Osmani Agent Skills, Anthropic Claude Skills, AutoGen, Browser Use, Buffer MCP, Caveman, Claude Design, Composio (+37 more)

### Community 5 - "Desktop Qwen Runbook"
Cohesion: 0.07
Nodes (37): After an Ollama update, ComfyUI video generation, CPU fallback (~4 tok/s) from missing CUDA DLLs in bin, Daily use, Desktop Qwen Runbook, Fresh Brief (Docker, OLLAMA_URL host.docker.internal:11435), Hermes (FirstSpark, 6 profiles), How it fits together (+29 more)

### Community 6 - "Add Desktop Qwen and Patches"
Cohesion: 0.10
Nodes (12): config_paths(), main(), transform(), digest(), main(), atomic(), digest(), main() (+4 more)

### Community 7 - "Gemma and Hot-Swap Rules"
Cohesion: 0.11
Nodes (31): Stop GLM and restore spark-fast, Gemma vLLM compose configuration, DGX Spark Gemma 4 Models Tutorial, Gemma 4 26B-A4B vLLM profile, Gemma 4 31B vLLM profile, Gemma OOM tuning guidance, prepare-gemma4-profile.sh, DGX Spark Model Installation And Switching Guide (+23 more)

### Community 8 - "Spark vs Workstation Model Placement"
Cohesion: 0.09
Nodes (26): DGX Spark And RTX 5000 Workstation Model Placement Research, Fine-Tuning Scope On 48 GB, Open WebUI Provider Prefixes, Model Placement Matrix, Verify Which RTX 5000, Workstation Model Shortlist, Fixed Cluster Values, gpt-oss 20B (+18 more)

### Community 9 - "Additional Models and Runtimes"
Cohesion: 0.11
Nodes (24): Unverified Or Deferred Items, DGX Spark Additional Models And Convenience Runtimes Research, LM Studio JIT Loading And Auto-Evict, Machine State Snapshot 2026-08-14, MiaAI-Lab Nemotron 3.5 SGLang Recipe, Nemotron 3.5 Lightning Official vLLM Recipe, Outdated ODS Ollama Extension, DGX Spark Nemotron 3.5 Lightning Tutorial (+16 more)

### Community 10 - "Dual-Node Spark Configuration"
Cohesion: 0.14
Nodes (24): NVIDIA Driver CDI Recovery, Dual-Spark Usage Options, DGX Spark Dual-Node Configuration And Operations Reference, NCCL all_gather_perf Result, NCCL Test Procedure, CX-7 Physical Topology, Software Baseline Audit 2026-09-18, Qwen fixed cluster values (+16 more)

### Community 11 - "Frontier Model Probe"
Cohesion: 0.25
Nodes (24): atomic_json(), capture_record(), chat_content(), cmd_chat(), cmd_compare(), cmd_concurrency(), cmd_context(), cmd_identity() (+16 more)

### Community 12 - "Power Recovery and Frontier Aliases"
Cohesion: 0.10
Nodes (27): Spark/Workstation Ownership Architecture, After Power Loss Behavior = Auto Boot, DGX Spark Automatic Power Recovery Research, Safe Power-Loss Test Plan, Proposed LiteLLM/Hermes frontier aliases, Cold-route rejection test, Hermes custom_providers mapping, LiteLLM frontier timeouts (+19 more)

### Community 13 - "Spark Safe Appliance Phase 0"
Cohesion: 0.13
Nodes (26): Phase 0 - Make the Spark a safe appliance, Phase 0 — Safe Remote Appliance, Recommended software versions (2026-08-20), NVIDIA DGX Dashboard, Discord, Langfuse, n8n, ODS (+18 more)

### Community 14 - "Native Speed and Memory Diagnostics"
Cohesion: 0.13
Nodes (9): measure(), check_co_residents(), command(), dflash_model_metadata(), main(), target_model_metadata(), validate_artifacts(), wait_for_memory() (+1 more)

### Community 15 - "Obsidian Sync and Route Catalog"
Cohesion: 0.09
Nodes (22): Spark Obsidian Headless Sync Replica, DGX Spark Qwen NVFP4 Memory And Startup Optimization Research, Hermes MEMORY.md and USER.md, Obsidian, Obsidian Headless Sync, Logical route catalog (local/fast, local/code, local/deep, local/vision, cloud/*), Local Setup Index, Meta Bind Plugin (+14 more)

### Community 16 - "Additional Services Controller"
Cohesion: 0.12
Nodes (23): aux-services Allow-List Entry Format, Dashboard Command Center Service Mapping, DGX Spark Additional Services Controller, Drain And Restore Workflow, Refresh Bounded Recovery Path, DGX Spark sparkDash Tunnel Scheduled Task, sparkDash acceptance checklist, Authenticated model probe on port 8100 (+15 more)

### Community 17 - "Native Qwen Long Probe"
Cohesion: 0.13
Nodes (17): Native Qwen Qualification Results, error(), main(), one(), close_sockets(), main(), cancel(), monitor() (+9 more)

### Community 18 - "Dual-Node Frontier Recipes Research"
Cohesion: 0.14
Nodes (18): Raw endpoint acceptance gate, Independent dual-Spark Qwen FP8 recipes, DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18, Official vLLM Qwen3.8 Flash Next FP8 recipe, Frontier API port 8100, MiaAI-Lab Qwen3.8 Flash Next Dual DGX Sparks recipe, Acceptance and rollback run receipt, sparkDash known issues (+10 more)

### Community 19 - "Workstation Tools and Desktop-Qwen Controls"
Cohesion: 0.13
Nodes (24): annas-archive-epub-downloads skill, Windows Desktop Window Manager, Handy, Vivaldi browser (remote debugger), ylc-searxng, YouTube Learning Center, Background review routed to SecondSpark, Backups and rollback ledger (+16 more)

### Community 20 - "Dual-Node Frontier Runbook"
Cohesion: 0.15
Nodes (26): Common Drain And Universal Rollback, DGX Spark Dual-Node Community Frontier Models Runbook, GLM 5.3 Local Baseline Result, Immediate Stop Conditions, Frontier LiteLLM/Hermes Aliases, Memory And Coexistence Matrix, Reviewed And Pinned Source Set, Readiness Gate Repairs (+18 more)

### Community 21 - "Parallel Native Downloader"
Cohesion: 0.16
Nodes (18): atomic_json(), Canceled, digest(), download_file(), transfer(), fetch_range(), main(), probe_ranges() (+10 more)

### Community 22 - "Native Reviewed Continuation Script"
Cohesion: 0.15
Nodes (17): install_hooks(), qualify_long(), main(), pressure_failures(), pressure_wrapped_run(), monitor(), sample(), reviewed_evidence() (+9 more)

### Community 23 - "MiniMax H3 LoRA Tutorials"
Cohesion: 0.15
Nodes (23): MiniMax H3, Akatz MiniMax H3 Character Swap LoRA v1, LoRA-on-Continuation Experiment (fnoji tip), MiniMax H3 Character Swap LoRA Windows Tutorial, MiniMax H3 Community License Agreement, Ref2VA Pinned Baseline, Shaky Cam Author Settings, MiniMax H3 Handheld Shaky Cam LoRA Windows Tutorial (+15 more)

### Community 26 - "Nemotron Omni and Gemma Recipes"
Cohesion: 0.12
Nodes (23): Gemma 4 26B A4B vLLM Spark Recipe, Gemma 4 31B Experimental Profile, Nemotron Omni vLLM 0.20 Recipe, Nemotron Omni 12 GiB KV profile, Nemotron Omni vLLM compose profile, Derived vLLM audio image, DGX Spark Nemotron 3 Nano Omni Tutorial, InvalidDefaultArgInFrom build warning (+15 more)

### Community 27 - "Qwen 3.8 TensorFold Replacement"
Cohesion: 0.11
Nodes (21): Known local blockers before dual-node launch, Second Spark read-only baseline checks, LiteLLM alias qwen38-tensorfold-second, LiteLLM alias qwen38-tp1-second (old v0.30), FirstSpark LiteLLM and Hermes config backup, DGX Spark Single-Node Qwen 3.8 Flash Next TensorFold Replacement Tutorial, frontier-model-probe.py, Full saved TensorFold raw qualification (+13 more)

### Community 28 - "LM Studio and LM Link"
Cohesion: 0.12
Nodes (20): Permanent Nemotron 1M x 1 profile, DGX Spark LM Studio And LM Link Tutorial, JIT loading and auto-eviction, lms headless CLI / llmster daemon, lmstudio-link.service user unit, Nemotron 3.5 Lightning LM Studio load, Tailscale Serve for Spark LM Studio, Devstral Small 2 24B (+12 more)

### Community 29 - "Subscriptions and Agent Tools"
Cohesion: 0.12
Nodes (20): Caddy, ChatGPT Plus subscription, Claude Code, Claude Pro subscription, Codex, Gemini API / Gemini CLI, Google AI Pro subscription, Herdr (+12 more)

### Community 30 - "Qwen Image 2.1 ComfyUI"
Cohesion: 0.19
Nodes (20): ComfyUI, Qwen3-VL 8B text encoder, Qwen Image 2.1, BF16 quality comparison lane, RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial, INT8 ConvRot baseline lane, Isolated portable ComfyUI install, Official Qwen Image 2.1 image-edit workflow (+12 more)

### Community 32 - "Spark Operations Setup"
Cohesion: 0.15
Nodes (14): Hermes Remote Gateway basic auth, DGX Spark Operations Setup Guide, ~/ai navigable layout with store symlinks, qwen35 prepare.sh, Promote tested stack to 24x7, One persistent Hermes for every device (Remote Gateway), spark-fast vLLM compose profile, capture-dgx-state.sh audit (+6 more)

### Community 33 - "Qwen Image BFS Body Swap"
Cohesion: 0.19
Nodes (17): BFS Best Face Swap repository, OpenMontage, bfs_body_swap_v1.0_qwen_2.1 LoRA, body_swap prompt, RTX PRO 5000 Qwen Image 2.1 BFS Body Swap Windows Tutorial, LoraLoaderModelOnly node, Reference image preparation, bfs_head_v1.1_alternative_qwen_2.1 LoRA (+9 more)

### Community 35 - "One-Large-Model Rule and Profiles"
Cohesion: 0.17
Nodes (16): Context and Concurrency Profiles, dgx-spark-current-models-report, Install and Experiment Matrix, DGX Spark ODS Playbook and Model Roadmap, Operational context profiles (interactive/batch/long/huge-experimental), Phase 3 - FDE portfolio applications, Phase 4 - Agent security, not agent sprawl, NVIDIA DGX Spark playbook catalog (44 playbooks) (+8 more)

### Community 36 - "GLM 5.3 Flash EXL3 Tutorial"
Cohesion: 0.16
Nodes (17): GLM recipe open failure issues, Shared frontier API key, GLM context ladder, DFlash/500K profile (GMU 0.86), DFlash/850K baseline profile, DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial, Step 16e shared evidence suite, GLM containers glm53-exl3-head / glm53-exl3-worker (+9 more)

### Community 38 - "SparkFast vs Qwen27B Capacity"
Cohesion: 0.15
Nodes (13): Duplicate Lightning instance removal, spark-qwen38 (native Qwen27B), 128 GB Unified Memory, SparkFast And Qwen 27B Capacity Comparison, F16 MMA flash-attention temp buffer, Four 100K-input test, Four 240K-input long test, Four isolated Hermes sessions (+5 more)

### Community 39 - "DGX Spark Aug 2026 Deployment Research"
Cohesion: 0.14
Nodes (14): 0xSero DeepSeek V4 Flash SparkInfer, DGX Spark Aug 2026 Model Deployment Research, Evidence Labels Standard, Hermes-Ready Tool Contract, NVIDIA Playbook Issue #89 Tool-Call Quant Bisect, Local Acceptance Benchmark Contract, NVIDIA Qwen3.6 35B First-Party Control, 24x7 Promotion Gates (+6 more)

### Community 40 - "Markdown Dashboard and Vault Sync"
Cohesion: 0.16
Nodes (15): Claude Messages API, Hermes desktop-ollama Named Provider, LLMWiki Vault, Obsidian Sync, Personal-Sync Vault, Tailscale Serve, Dashboard MVP Acceptance Tests, Chokidar File Watcher + Server-Sent Events (+7 more)

### Community 41 - "Jev and Laya Decision Models"
Cohesion: 0.21
Nodes (15): Jev (TypeSafe AI hosted decision API), Laya Local Decision Model, RTX PRO 5000 Jev Agent Decision Evaluation Tutorial, hermes-jev-skills Repository, JEV-as-a-Judge Cascade, Shadow-to-Active Progression, Jev Windows Trial (Playground then API), RTX PRO 5000 Laya Decision Model Tutorial (+7 more)

### Community 42 - "Hermes Bootstrap and Production Probes"
Cohesion: 0.15
Nodes (9): main(), qualification_environment(), child(), send(), guard_socket_connector(), main(), production_python_command(), save_failure() (+1 more)

### Community 43 - "Pressure Qualification Tests"
Cohesion: 0.14
Nodes (3): PressureTests, ReuseTests, sample()

### Community 44 - "Spark Twitter Bookmarks Research"
Cohesion: 0.20
Nodes (15): Install-later / experimental models, Final model shelf for one 128 GB Spark, Capacity acceptance metrics, dgx-spark-twitter-bookmarks-analysis, Model evidence matrix, Post-OOM low-power state, Candidate reproduction checklist, spark-big alias (+7 more)

### Community 45 - "Workstation Inference Measurement"
Cohesion: 0.18
Nodes (16): RTX PRO 5000 Local Inference Measurement Tutorial, llama-server Windows CUDA build, Inference measurement decision record, MTP draft speculative decoding, One-GGUF experiment, Quantized KV cache (-ctk/-ctv), sudoingX llama.cpp flags X post, Time to first token (+8 more)

### Community 46 - "Always-On Hermes on Spark"
Cohesion: 0.14
Nodes (17): Stable Capability Model Aliases, Workstation-local desktop-files Profile, Discord Primary Phone Interface, Always-On Hermes on DGX Spark, hermes gateway, hermes serve, ODS Hermes Auth Proxy, Always-On Hermes Rollout Plan (+9 more)

### Community 47 - "Fresh Brief and Qwen 3.8 Intake"
Cohesion: 0.16
Nodes (15): Qwen 3.8 Release Intake Sequence, Native Qwen 3.8 Inventory Entries, Qwen 3.8 27B LM Studio migration pointer, Fresh Brief, FreshRSS, Qwen 3.8 27B, Fresh Brief acceptance gates, Cutover and preservation procedure (+7 more)

### Community 48 - "DeepSeek 131K Comparison"
Cohesion: 0.16
Nodes (13): DeepSeek 131K Bring-Up Profile, DGX Spark DeepSeek 131K And SparkFast Comparison Protocol, Eight-Profile Raw Comparison Table, spark-fast Raw Reference Benchmark, Baseline .env Values, DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial, Host-Side Source Tests, DeepSeek LiteLLM Promotion (+5 more)

### Community 49 - "Hermes Provider Migration Script"
Cohesion: 0.22
Nodes (14): atomic_write(), digest(), explicit_desktop_references(), inside(), main(), endpoint(), lmstudio_references(), main() (+6 more)

### Community 50 - "Spark Multi-Model Runtime"
Cohesion: 0.19
Nodes (10): DGX Spark Multi-Model Runtime Research, One-time LiteLLM HTTP 500 on stopped upstream, Model order for requested tests, Nemotron 3.5 vs Nemotron 3 Nano Omni naming note, Qwen 27B compose lacks persisted vLLM compile cache, Qwen 27 optimized MTP-3 profile (qwen27-dflash legacy route), FlashInfer, Gemma 4 26B A4B (+2 more)

### Community 51 - "Downloader and Dashboard Builder"
Cohesion: 0.26
Nodes (7): atomic_write(), Dashboard, library_state(), markdown_path(), note_state(), plain(), sha256()

### Community 52 - "Muse Glimmer Readiness"
Cohesion: 0.21
Nodes (11): DGX Spark Additional Model Tutorials Index, Recommended Model Testing Order, Per-Runtime Model Stores, Muse Glimmer vLLM compose profile, DGX Spark Muse Glimmer 30B Readiness Tutorial, Inferact/Muse-Glimmer-30B-NVFP4-W4A4 (not to substitute), LiteLLM route muse-glimmer, Muse-Glimmer-30B-assistant DFlash draft (+3 more)

### Community 53 - "Engine Decisions and Roadmap"
Cohesion: 0.23
Nodes (13): Engine Decisions, Phase 1 - Serving and inference engineering, Human-readable registries (models.tsv, services.tsv, ports.tsv), dgx-status / dgx-models / dgx-space functions, Phase 1 — Inference Engineering, DeepSeek-R1 671B, llama.cpp, NVIDIA NIM (+5 more)

### Community 54 - "Qwen 3.8 Flash Next v0.30"
Cohesion: 0.17
Nodes (14): 100K-token context memory gate, 100-turn long-agent tool gate, Controlled LiteLLM and Hermes promotion (Steps 14-24), DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial, v0.30 fixed launch values, Upstream issue #48 long-agent premature stop, Memory, kernel, and preemption gate, memwatch memory watchdog (+6 more)

### Community 56 - "Hermes LM Link Routing"
Cohesion: 0.19
Nodes (10): LM Link, Hermes provider desktop-ollama, Hermes LM Link And Workstation Model Routing Research, Hermes Desktop, provider_models_cache.json warm restart, Recommended Hermes/LM Link/Ollama topology, Hermes provider spark-lmstudio, LM Link routing verification gates (+2 more)

### Community 57 - "LongCat Video Avatar"
Cohesion: 0.20
Nodes (14): FlashAttention, LongCat-Video-Avatar 1.5, PyTorch, Whisper Large V3, WSL2 Ubuntu, LongCat Video Avatar 1.5 Workstation Feasibility Tutorial, One-clip 480p smoke test, LongCat pass criteria (+6 more)

### Community 59 - "Device Allocation and Vision Test"
Cohesion: 0.19
Nodes (10): Suggested resident allocation across Spark/workstation/laptop, DGX Spark, Gaming laptop (RTX 3060 6 GB), Blue Circles (2, top-right), Vision Check: Shape, Color, Count, Position, Frontier Model Vision Test (image), Green Squares (3, bottom-left), Red Triangle (1, top-left) (+2 more)

### Community 60 - "Frontier Qualification Results"
Cohesion: 0.21
Nodes (12): GLM local performance results, Optional Qwen TP1 lane on SecondSpark, DGX Spark Frontier Model Qualification Results, Spark-Fast + Nemotron five-session co-residency retest, GLM v2 concurrency regression flag, Standardized frontier headline results, SparkFast orphan-request guard, SecondSpark Qwen TensorFold qualification (+4 more)

### Community 61 - "Spark Unified Memory Co-Residency"
Cohesion: 0.14
Nodes (11): Co-residency acceptance test matrix, Qwen vLLM + LM Studio Nemotron co-residency, DGX Spark 128 GB unified LPDDR5X pool (273 GB/s), Spark LM Studio Nemotron 3.5 Lightning (historical, disabled), Native Qwen3.8 27B llama.cpp on FirstSpark (qwen38-27b-spark), DFlash2 speculative decoding (draft-dflash), measure_interactive_speed.py / probe_qwen.py / probe_hermes_production.py, native-config.json / run_native_qwen.py launcher (+3 more)

### Community 62 - "Workstation ODS and Ollama"
Cohesion: 0.19
Nodes (10): ODS DeepSeek 70B removal, Desktop Ollama via Tailscale Hermes provider, RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial, gemma3:4b connector test, What runs on each machine, Native Ollama connection (host.docker.internal:11434), ODS llama-server, qwen27-dflash alias (+2 more)

### Community 63 - "ODS Playbook Phases 2-5"
Cohesion: 0.26
Nodes (13): Phase 2 - Fine-tuning and SLM engineering, Roadmap Completion Criteria, dgx-spark-playbook-roadmap-draft, Phase 2 — SLM and Fine-Tuning, Phase 3 — FDE Case Studies, Phase 4 — Agent Security, Phase 5 — Electives and Deferrals, NVIDIA DGX Spark Playbook Catalog (+5 more)

### Community 64 - "LM Studio Qwen Loader"
Cohesion: 0.17
Nodes (6): args, client, config, options, require, sdkDirectory

### Community 66 - "Realtime Conversation Video"
Cohesion: 0.33
Nodes (8): AivisSpeech TTS, LTX-2.5, OpenAI-compatible input_audio LLM, diffusers-movie-server gateway, Realtime Conversation Video Windows Feasibility Tutorial, Time to first audio/frame and chunk metrics, Realtime_Conversation_Video client, Realtime_Narration_Video renderer

### Community 67 - "EVIE Retrieval Tutorial"
Cohesion: 0.36
Nodes (8): Tencent EVIE Visual Retriever, RTX PRO 5000 Workstation, WSL2 Ubuntu isolated ai-lab environment, PyTorch + ColPali Route, RTX PRO 5000 EVIE Visual Document Retrieval Tutorial, Multi-Vector Index Cost, EVIE Windows PowerShell Trial, Sequence 8J — Social Capture Windows Local-Model Exploration

### Community 69 - "Perplexity Portable Computer"
Cohesion: 0.39
Nodes (8): Perplexity Portable Computer, PPLX 27B, Cloud step escalation and credits, Original DGX Spark-only launch framing, RTX PRO 5000 Perplexity Portable Computer Tutorial, Settings > Local Inference, Personal Computer vs Portable Computer, Qwen 27B (Perplexity app)

### Community 70 - "Social Capture Pipeline"
Cohesion: 0.42
Nodes (7): Social Capture, Social Capture task provenance table, Social Capture Action Queue.md, Social Capture Pipeline, Queue lifecycle and monthly archive, Social Capture desktop dashboard, WhatsApp backlog importer

### Community 72 - "Spark Ollama and ODS Tutorial"
Cohesion: 0.43
Nodes (6): DGX Spark Ollama And ODS Tutorial, LiteLLM route ollama-gemma4-e4b, ODS public Ollama extension (0.5.7, 8 GB limit), ollama-current container, Open WebUI Ollama connection (http://ollama-current:11434), prepare-ollama-current.sh

### Community 73 - "spark-fast NVFP4 Memory Profile"
Cohesion: 0.25
Nodes (6): Chunked prefill with 8,192 batched tokens, nvidia/Qwen3.6-35B-A3B-NVFP4 checkpoint, spark-fast 262K / 18 GiB FP8 KV production profile, Dual-Spark exclusive frontier lane (qwen38-nvfp4/fp8, glm53, deepseek41), Standalone Hermes Gateway/Serve on FirstSpark, Standalone LiteLLM router (port 4000)

### Community 77 - "MTP and DFlash Speculative Decoding"
Cohesion: 0.33
Nodes (6): Muse Glimmer vLLM Recipe, MiaAI Qwen3.6 27B DFlash Profile, NVIDIA Qwen3.6 35B NVFP4 Spark vLLM recipe, DFlash Speculative Decoding, MTP speculative decoding, Tweets and Replies Findings (ggerganov MTP/DFlash)

### Community 80 - "Native Qwen HF Download Script"
Cohesion: 0.40
Nodes (4): HF_HUB_DISABLE_IMPLICIT_TOKEN, HF_XET_CACHE, HF_XET_NUM_CONCURRENT_RANGE_GETS, download_native_qwen.sh script

### Community 81 - "Local Setup Dashboard"
Cohesion: 0.50
Nodes (3): Local Setup Dashboard, Local Setup Field Guide Dashboard Template, Markdown Folder Import And Progress JSON

### Community 85 - "Ollama Context Reload Fix"
Cohesion: 0.67
Nodes (3): Context-size mismatch reloads (Fresh Brief 16K vs Hermes 262K), Ollama env fix: 131072 context, q8_0 KV, parallel 1, Ollama GUI 256K context slider overrides OLLAMA_CONTEXT_LENGTH

## Ambiguous Edges - Review These
- `Background review routed to SecondSpark` → `spark-fast alias`  [AMBIGUOUS]
  hermes-qwen-desktop-lag-handoff-2026-09-28.md · relation: conceptually_related_to
- `qwen27-dflash alias` → `DFlash2`  [AMBIGUOUS]
  RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial.md · relation: conceptually_related_to
- `Inference vs Windows display GPU contention (Sept 28 measurement)` → `October 6 NVIDIA TDR during Qwen serving`  [AMBIGUOUS]
  Qwen Spark Migration Evidence 2026-10-12.md · relation: conceptually_related_to

## Knowledge Gaps
- **150 isolated node(s):** `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_CACHE`, `HF_XET_NUM_CONCURRENT_RANGE_GETS`, `Workstation-local desktop-files Profile`, `Discord Primary Phone Interface` (+145 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 353 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **26 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Qwen 3.8 27B Native Spark Setup Tutorial` connect `Qwen 3.8 27B Native Spark Setup` to `Admission Proxy`, `Add Desktop Qwen and Patches`, `Gemma and Hot-Swap Rules`, `Spark vs Workstation Model Placement`, `Additional Models and Runtimes`, `Dual-Node Spark Configuration`, `Power Recovery and Frontier Aliases`, `Native Speed and Memory Diagnostics`, `Additional Services Controller`, `Native Qwen Long Probe`, `Parallel Native Downloader`, `Native Reviewed Continuation Script`, `Nemotron Omni and Gemma Recipes`, `Qwen 3.8 TensorFold Replacement`, `LM Studio and LM Link`, `GLM 5.3 Flash EXL3 Tutorial`, `SparkFast vs Qwen27B Capacity`, `Hermes Bootstrap and Production Probes`, `Fresh Brief and Qwen 3.8 Intake`, `Hermes Provider Migration Script`, `Engine Decisions and Roadmap`, `MTP and DFlash Speculative Decoding`?**
  _High betweenness centrality (0.274) - this node is a cross-community bridge._
- **What connects `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_CACHE`, `HF_XET_NUM_CONCURRENT_RANGE_GETS` to the rest of the system?**
  _150 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Admission Proxy` be split into smaller, more focused modules?**
  _Cohesion score 0.06274509803921569 - nodes in this community are weakly interconnected._
- **Why does `Task Checklist` connect `Power Recovery and Frontier Aliases` to `VoiceStudio Risk Audit`, `Qwen 3.8 27B Native Spark Setup`, `Agent Tooling Catalog`, `Gemma and Hot-Swap Rules`, `Spark vs Workstation Model Placement`, `Additional Models and Runtimes`, `Dual-Node Spark Configuration`, `Spark Safe Appliance Phase 0`, `Obsidian Sync and Route Catalog`, `Additional Services Controller`, `Dual-Node Frontier Recipes Research`, `Dual-Node Frontier Runbook`, `MiniMax H3 LoRA Tutorials`, `Nemotron Omni and Gemma Recipes`, `LM Studio and LM Link`, `Subscriptions and Agent Tools`, `Qwen Image 2.1 ComfyUI`, `Spark Operations Setup`, `Qwen Image BFS Body Swap`, `One-Large-Model Rule and Profiles`, `GLM 5.3 Flash EXL3 Tutorial`, `DGX Spark Aug 2026 Deployment Research`, `Markdown Dashboard and Vault Sync`, `Jev and Laya Decision Models`, `Spark Twitter Bookmarks Research`, `Workstation Inference Measurement`, `Always-On Hermes on Spark`, `Fresh Brief and Qwen 3.8 Intake`, `DeepSeek 131K Comparison`, `Spark Multi-Model Runtime`, `Muse Glimmer Readiness`, `Engine Decisions and Roadmap`, `Hermes LM Link Routing`, `LongCat Video Avatar`, `Frontier Qualification Results`, `Workstation ODS and Ollama`, `ODS Playbook Phases 2-5`, `Realtime Conversation Video`, `EVIE Retrieval Tutorial`, `Perplexity Portable Computer`, `Spark Ollama and ODS Tutorial`?**
  _High betweenness centrality (0.140) - this node is a cross-community bridge._
- **Should `VoiceStudio Risk Audit` be split into smaller, more focused modules?**
  _Cohesion score 0.06196078431372549 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `Background review routed to SecondSpark` and `spark-fast alias`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `qwen27-dflash alias` and `DFlash2`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._