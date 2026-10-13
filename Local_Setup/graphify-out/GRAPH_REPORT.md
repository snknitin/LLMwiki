# Graph Report - Local_Setup  (2026-10-13)

## Corpus Check
- 1 files · ~300,567 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1776 nodes · 5298 edges · 89 communities (66 shown, 23 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 211 edges (avg confidence: 0.84)
- Token cost: 74,560 input · 0 output

## Community Hubs (Navigation)
- Spark vs Workstation Model Placement
- DGX Spark Aug 2026 Deployment Research
- Always-On Hermes on Spark
- Additional Models and Runtimes
- Boot and Hermes Timeout Patches
- Dashboard app.js
- VoiceStudio Risk Audit
- Gemma 4 and Model Tutorials Index
- Additional Services Controller
- Agent Tooling Catalog
- Qwen Image 2.1 ComfyUI
- Native Downloads and Memory Diagnostics
- Dual-Node Spark Configuration
- ODS Playbook and Model Roadmap
- Spark Recovery Snapshot
- DeepSeek 131K Comparison
- Frontier Model Probe
- Parallel Native Downloader
- Dual-Node Frontier Runbook
- Native Reviewed Continuation Script
- Native Qwen Long Probe
- MiniMax H3 LoRA Tutorials
- Finish Native Install Script
- LM Studio and LM Link
- Workstation Tools and Desktop-Qwen Controls
- GLM 5.3 Flash EXL3 Tutorial
- Qwen 3.8 TensorFold Replacement
- Qwen 3.8 27B Native Spark Setup
- Probe Test Fakes
- Qwen 3.8 Flash Next Dual-Node
- Spark Operations Setup
- Downloader and Dashboard Builder
- Hermes Native Provider Migration
- Qwen 3.8 Release and Remote Access
- Markdown Dashboard and Vault Sync
- Jev and Laya Decision Models
- Pressure Qualification Tests
- Dual-Node Frontier Recipes Research
- Admission Proxy
- Perplexity Portable Computer
- SparkFast vs Qwen27B Capacity
- GLM Reasoning Bridge Handler
- RTX PRO 5000 EVIE Retrieval
- Qwen 3.8 Flash Next v0.30
- LongCat Video Avatar
- DFlash Draft Config Tests
- Obsidian Headless Sync
- Desktop Qwen llama-server
- Hermes Provider Migration Script
- Admission Queue Core
- GLM Shim Server and Writer Test
- LM Studio Qwen Loader
- Windows Lag and Download Fix
- Memory Readiness Tests
- Realtime Conversation Video
- Hermes Timeout Tests
- Spark Unified Memory Co-Residency
- Fresh Brief Spark Migration
- Social Capture Pipeline
- Admission Proxy HTTP App
- Systemctl Start-Limit Tests
- Workstation Inference Measurement
- Desktop Qwen Runbook Sections
- Fresh Brief Context Thrash
- One-Large-Model Rule
- spark-fast NVFP4 Memory Profile
- Named Custom Timeout Tests
- Admission HTTP Tests
- Production Wire Tests
- Desktop GPU and Ollama Rules
- Agent Memory and Crawl Tools
- Admission Drain Test Server
- Hermes Catalog Tests
- Frontier Vision Test
- Native Spark Qwen DFlash Live
- Native Qwen HF Download Script
- Graphify Project Rules
- vLLM Cold-Start Optimization
- Three-Device Topology
- Windows Display GPU Contention
- Spark Download Relay
- Run-At-Boot Result

## God Nodes (most connected - your core abstractions)
1. `Hermes Agent` - 133 edges
2. `Task Checklist` - 109 edges
3. `LiteLLM` - 99 edges
4. `vLLM` - 83 edges
5. `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)` - 83 edges
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
- `Frontier Model Vision Test (image)` --conceptually_related_to--> `DGX Spark`  [INFERRED]
  Frontier Model Vision Test.png → Always-On Hermes on DGX Spark.md
- `Four-Slot Q8 Memory Estimate` --references--> `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)`  [EXTRACTED]
  Qwen Spark Migration/LONG-PROBE-GUARDS.md → DGX Spark Additional Model Tutorials Index.md
- `DGX Spark Frontier Model Qualification Results` --references--> `Frontier Model Vision Test (image)`  [INFERRED]
  DGX Spark Frontier Model Qualification Results.md → Frontier Model Vision Test.png

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
- **Windows Qwen lag root causes and llama-server two-slot fix** — qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_ollama_context_slider, qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_context_mismatch_reloads, qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_monitors_on_rtx, qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_ollama_no_parallel_qwen35, desktop_qwen_runbook_desktop_qwen_llama_server [EXTRACTED 1.00]
- **Workstation Ollama reached from Spark Hermes via Tailscale Serve** — ent_ollama, ent_tailscale_serve, ent_desktop_ollama_provider, ent_hermes, ent_qwen_3_8_27b, ent_rtx_pro_5000_workstation [EXTRACTED 1.00]
- **Mutually exclusive dual-node frontier lanes on port 8100** — dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_baseline, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_fp8_comparison, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_mtp_850k_accepted, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_deepseek_recipe, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_port_8100 [INFERRED 0.85]
- **Frontier Lane Hot-Swap Lifecycle** — ent_aux_services, ent_spark_frontier, ent_spark_model, ent_spark_fast, dgx_spark_dual_node_community_frontier_models_runbook_common_drain_rollback, dgx_spark_dual_node_community_frontier_models_runbook_litellm_hermes_aliases [INFERRED 0.85]
- **Frontier qualification evidence pipeline** — dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_probe_suite, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_evidence_suite, dgx_spark_frontier_model_qualification_results_headline_table, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_perf_results, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_vs_fp8_results, ent_spark_frontier_check [INFERRED 0.85]
- **Gateway-routed logical aliases with controlled model swap** — dgx_spark_twitter_bookmarks_analysis_safe_swap_controller, local_ai_architecture_research_hotswap_as_routing, personal_hermes_obsidian_multinode_design_gateway_hot_swap_policy, ent_litellm, personal_hermes_obsidian_multinode_design_logical_routes [INFERRED 0.85]
- **Unified-memory safety qualification gates (MemAvailable >=10 GiB, no NV_ERR_NO_MEMORY)** — dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_100k_memory_gate, dgx_spark_single_node_qwen_3_8_flash_next_v0_30_tutorial_memory_kernel_gate, dgx_spark_sparkdash_monitoring_tutorial_coexistence_decision, ent_unified_memory_128gb [INFERRED 0.85]
- **VoiceStudio Readiness Failure Chain** — voicestudio_risk_audit_shutdown_latch, voicestudio_risk_audit_false_negative_health, voicestudio_risk_audit_no_deliverable_baseline, voicestudio_risk_audit_lifecycle_confusion [INFERRED 0.85]
- **Clients sharing the 2-slot Desktop Qwen llama-server** — desktop_qwen_runbook_desktop_qwen_llama_server, desktop_qwen_runbook_hermes_desktop_qwen_provider, desktop_qwen_runbook_fresh_brief, desktop_qwen_runbook_tailscale_serve_8444 [EXTRACTED 1.00]
- **GPU contention: Qwen vs ComfyUI vs Ollama on one RTX** — desktop_qwen_runbook_rtx_pro_5000, desktop_qwen_runbook_desktop_qwen_llama_server, desktop_qwen_runbook_comfyui, desktop_qwen_runbook_ollama, desktop_qwen_runbook_one_big_gpu_job_rule [EXTRACTED 1.00]

## Communities (89 total, 23 thin omitted)

### Community 0 - "Spark vs Workstation Model Placement"
Cohesion: 0.06
Nodes (62): 24x7 Hermes Service Shape, DGX Spark And RTX 5000 Workstation Model Placement Research, Open WebUI Provider Prefixes, Spark/Workstation Ownership Architecture, Model Placement Matrix, Workstation Model Shortlist, Engine Decisions, FirstSpark ODS retirement 2026-09-22 (+54 more)

### Community 1 - "DGX Spark Aug 2026 Deployment Research"
Cohesion: 0.06
Nodes (52): 0xSero DeepSeek V4 Flash SparkInfer, DGX Spark Aug 2026 Model Deployment Research, Evidence Labels Standard, Hermes-Ready Tool Contract, NVIDIA Playbook Issue #89 Tool-Call Quant Bisect, Local Acceptance Benchmark Contract, MiaAI Qwen3.6 27B DFlash Profile, NVIDIA Qwen3.6 35B First-Party Control (+44 more)

### Community 2 - "Always-On Hermes on Spark"
Cohesion: 0.06
Nodes (50): Stable Capability Model Aliases, Workstation-local desktop-files Profile, Discord Primary Phone Interface, Always-On Hermes on DGX Spark, hermes gateway, hermes serve, ODS Hermes Auth Proxy, Always-On Hermes Rollout Plan (+42 more)

### Community 3 - "Additional Models and Runtimes"
Cohesion: 0.07
Nodes (48): Unverified Or Deferred Items, DGX Spark Additional Models And Convenience Runtimes Research, LM Studio JIT Loading And Auto-Evict, Machine State Snapshot 2026-08-14, MiaAI-Lab Nemotron 3.5 SGLang Recipe, Muse Glimmer vLLM Recipe, Nemotron 3.5 Lightning Official vLLM Recipe, Outdated ODS Ollama Extension (+40 more)

### Community 4 - "Boot and Hermes Timeout Patches"
Cohesion: 0.08
Nodes (14): Named-Provider Timeout Patch for Hermes, atomic(), digest(), main(), transform(), main(), qualification_environment(), child() (+6 more)

### Community 5 - "Dashboard app.js"
Cohesion: 0.10
Nodes (44): applyLibrarySnapshot(), closeDrawer(), decodeSafe(), download(), drawTask(), empty(), exportHTML(), exportProgress() (+36 more)

### Community 6 - "VoiceStudio Risk Audit"
Cohesion: 0.06
Nodes (49): Safe Download Order, Downloaded vs running distinction, Model store ownership rules, Hugging Face Hub cache, OmniVoice TTS Model, Parakeet TDT 0.6B v3, Whisper, VoiceStudio v0.5.0 Portable Install (+41 more)

### Community 7 - "Gemma 4 and Model Tutorials Index"
Cohesion: 0.08
Nodes (41): DGX Spark Additional Model Tutorials Index, Recommended Model Testing Order, Per-Runtime Model Stores, Gemma 4 26B A4B vLLM Spark Recipe, Gemma 4 31B Experimental Profile, Gemma vLLM compose configuration, DGX Spark Gemma 4 Models Tutorial, Gemma 4 26B-A4B vLLM profile (+33 more)

### Community 8 - "Additional Services Controller"
Cohesion: 0.08
Nodes (32): aux-services Allow-List Entry Format, Dashboard Command Center Service Mapping, DGX Spark Additional Services Controller, Refresh Bounded Recovery Path, DGX Spark sparkDash Tunnel Scheduled Task, sparkDash known issues, Pre-change capture 2026-08-20, Dual Spark power budget (+24 more)

### Community 9 - "Agent Tooling Catalog"
Cohesion: 0.07
Nodes (37): Addy Osmani Agent Skills, Anthropic Claude Skills, AutoGen, Browser Use, Buffer MCP, Caveman, Claude Design, Composio (+29 more)

### Community 10 - "Qwen Image 2.1 ComfyUI"
Cohesion: 0.13
Nodes (31): BFS Best Face Swap repository, ComfyUI, Qwen3-VL 8B text encoder, Qwen Image 2.1, BF16 quality comparison lane, RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial, INT8 ConvRot baseline lane, Isolated portable ComfyUI install (+23 more)

### Community 11 - "Native Downloads and Memory Diagnostics"
Cohesion: 0.11
Nodes (13): digest(), main(), measure(), check_co_residents(), command(), dflash_model_metadata(), main(), target_model_metadata() (+5 more)

### Community 12 - "Dual-Node Spark Configuration"
Cohesion: 0.11
Nodes (29): NVIDIA Driver CDI Recovery, Dual-Spark Usage Options, DGX Spark Dual-Node Configuration And Operations Reference, NCCL all_gather_perf Result, NCCL Test Procedure, CX-7 Physical Topology, Software Baseline Audit 2026-09-18, Known local blockers before dual-node launch (+21 more)

### Community 13 - "ODS Playbook and Model Roadmap"
Cohesion: 0.11
Nodes (29): DGX Spark ODS Playbook and Model Roadmap, Operational context profiles (interactive/batch/long/huge-experimental), Phase 2 - Fine-tuning and SLM engineering, Phase 3 - FDE portfolio applications, NVIDIA DGX Spark playbook catalog (44 playbooks), Recommended core model set, Roadmap Completion Criteria, dgx-spark-playbook-roadmap-draft (+21 more)

### Community 14 - "Spark Recovery Snapshot"
Cohesion: 0.10
Nodes (27): DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20, Health baseline endpoints, lmstudio.service systemd user unit, Targeted recovery commands per owner, wait-for-spark-fast script, gpt-oss 20B, hermes-dashboard service, hermes-serve service (+19 more)

### Community 15 - "DeepSeek 131K Comparison"
Cohesion: 0.10
Nodes (25): DeepSeek 131K Bring-Up Profile, DGX Spark DeepSeek 131K And SparkFast Comparison Protocol, Eight-Profile Raw Comparison Table, spark-fast Raw Reference Benchmark, Baseline .env Values, DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial, Host-Side Source Tests, DeepSeek LiteLLM Promotion (+17 more)

### Community 16 - "Frontier Model Probe"
Cohesion: 0.25
Nodes (24): atomic_json(), capture_record(), chat_content(), cmd_chat(), cmd_compare(), cmd_concurrency(), cmd_context(), cmd_identity() (+16 more)

### Community 17 - "Parallel Native Downloader"
Cohesion: 0.15
Nodes (18): atomic_json(), Canceled, digest(), download_file(), transfer(), fetch_range(), main(), probe_ranges() (+10 more)

### Community 18 - "Dual-Node Frontier Runbook"
Cohesion: 0.10
Nodes (23): Drain And Restore Workflow, Common Drain And Universal Rollback, DGX Spark Dual-Node Community Frontier Models Runbook, Fixed Cluster Values, GLM 5.3 Local Baseline Result, Immediate Stop Conditions, Frontier LiteLLM/Hermes Aliases, Memory And Coexistence Matrix (+15 more)

### Community 19 - "Native Reviewed Continuation Script"
Cohesion: 0.15
Nodes (17): install_hooks(), qualify_long(), main(), pressure_failures(), pressure_wrapped_run(), monitor(), sample(), reviewed_evidence() (+9 more)

### Community 20 - "Native Qwen Long Probe"
Cohesion: 0.14
Nodes (15): Native Qwen Qualification Results, main(), close_sockets(), main(), cancel(), monitor(), observe_slots(), request() (+7 more)

### Community 21 - "MiniMax H3 LoRA Tutorials"
Cohesion: 0.15
Nodes (23): MiniMax H3, Akatz MiniMax H3 Character Swap LoRA v1, LoRA-on-Continuation Experiment (fnoji tip), MiniMax H3 Character Swap LoRA Windows Tutorial, MiniMax H3 Community License Agreement, Ref2VA Pinned Baseline, Shaky Cam Author Settings, MiniMax H3 Handheld Shaky Cam LoRA Windows Tutorial (+15 more)

### Community 22 - "Finish Native Install Script"
Cohesion: 0.20
Nodes (21): check_abort(), entrypoint(), get(), handle_shutdown(), kill_group(), main(), mem_available_gib(), memory_guard() (+13 more)

### Community 25 - "LM Studio and LM Link"
Cohesion: 0.13
Nodes (20): Permanent Nemotron 1M x 1 profile, DGX Spark LM Studio And LM Link Tutorial, JIT loading and auto-eviction, lms headless CLI / llmster daemon, lmstudio-link.service user unit, Nemotron 3.5 Lightning LM Studio load, Devstral Small 2 24B, LM Studio (+12 more)

### Community 26 - "Workstation Tools and Desktop-Qwen Controls"
Cohesion: 0.16
Nodes (21): annas-archive-epub-downloads skill, Windows Desktop Window Manager, Handy, Vivaldi browser (remote debugger), ylc-searxng, YouTube Learning Center, Background review routed to SecondSpark, Backups and rollback ledger (+13 more)

### Community 27 - "GLM 5.3 Flash EXL3 Tutorial"
Cohesion: 0.15
Nodes (19): Shared frontier API key, GLM context ladder, DFlash/500K profile (GMU 0.86), DFlash/850K baseline profile, DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial, Step 16e shared evidence suite, GLM containers glm53-exl3-head / glm53-exl3-worker, InstantTensor loader budget fix (+11 more)

### Community 28 - "Qwen 3.8 TensorFold Replacement"
Cohesion: 0.11
Nodes (20): LiteLLM alias qwen38-tensorfold-second, LiteLLM alias qwen38-tp1-second (old v0.30), FirstSpark LiteLLM and Hermes config backup, DGX Spark Single-Node Qwen 3.8 Flash Next TensorFold Replacement Tutorial, frontier-model-probe.py, Full saved TensorFold raw qualification, Hermes two-session and 12-tool workflow gate, Hugging Face cache root-ownership lock fix (+12 more)

### Community 29 - "Qwen 3.8 27B Native Spark Setup"
Cohesion: 0.13
Nodes (15): Unsloth Qwen3.8-27B GGUF, Auxiliary Services Locked Inventory Entries, Qwen 3.8 27B Native Spark Setup Tutorial, LM Studio Residency Retirement on FirstSpark, qwen38-admission Service, qwen38-native Service (llama-server worker), Hermes spark-qwen38 Provider (qwen38-27b-spark), Two-Slot 262K Context and Memory Plan (+7 more)

### Community 31 - "Qwen 3.8 Flash Next Dual-Node"
Cohesion: 0.14
Nodes (17): Independent dual-Spark Qwen FP8 recipes, Official vLLM Qwen3.8 Flash Next FP8 recipe, Qwen fixed cluster values, DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial, Qwen 3.8 Flash Next official FP8 lane, Dead huggingface-cli selection issue, Qwen 3.8 Flash Next NVFP4 dual-node baseline, NVFP4 per-node memory accounting (+9 more)

### Community 32 - "Spark Operations Setup"
Cohesion: 0.14
Nodes (15): Hermes Remote Gateway basic auth, DGX Spark Operations Setup Guide, LiteLLM route spark-fast, ~/ai navigable layout with store symlinks, qwen35 prepare.sh, Promote tested stack to 24x7, Human-readable registries (models.tsv, services.tsv, ports.tsv), One persistent Hermes for every device (Remote Gateway) (+7 more)

### Community 33 - "Downloader and Dashboard Builder"
Cohesion: 0.20
Nodes (7): atomic_write(), Dashboard, library_state(), markdown_path(), note_state(), plain(), sha256()

### Community 35 - "Hermes Native Provider Migration"
Cohesion: 0.16
Nodes (8): config_paths(), main(), transform(), endpoint(), lmstudio_references(), main(), transform(), TransformTests

### Community 36 - "Qwen 3.8 Release and Remote Access"
Cohesion: 0.16
Nodes (17): Qwen 3.8 Release Intake Sequence, Native Qwen 3.8 Inventory Entries, Qwen 3.8 27B LM Studio migration pointer, Qwen 3.8 27B, 65K desktop-Qwen control, 262K runtime GPU allocation, Qwen 3.8 27B Ollama Remote Access Research, Live Installation Record 2026-08-20 (+9 more)

### Community 37 - "Markdown Dashboard and Vault Sync"
Cohesion: 0.16
Nodes (15): Claude Messages API, Hermes desktop-ollama Named Provider, LLMWiki Vault, Obsidian Sync, Personal-Sync Vault, Tailscale Serve, Dashboard MVP Acceptance Tests, Chokidar File Watcher + Server-Sent Events (+7 more)

### Community 38 - "Jev and Laya Decision Models"
Cohesion: 0.21
Nodes (15): Jev (TypeSafe AI hosted decision API), Laya Local Decision Model, RTX PRO 5000 Jev Agent Decision Evaluation Tutorial, hermes-jev-skills Repository, JEV-as-a-Judge Cascade, Shadow-to-Active Progression, Jev Windows Trial (Playground then API), RTX PRO 5000 Laya Decision Model Tutorial (+7 more)

### Community 39 - "Pressure Qualification Tests"
Cohesion: 0.14
Nodes (3): PressureTests, ReuseTests, sample()

### Community 40 - "Dual-Node Frontier Recipes Research"
Cohesion: 0.26
Nodes (13): DeepSeek V4.1 Flash EXL3 2x Spark Recipe, Raw endpoint acceptance gate, MiaAI-Lab DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks recipe, DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18, GLM recipe open failure issues, MiaAI-Lab GLM-5.3-Flash-EXL3-2x-DGX-Sparks recipe, Frontier API port 8100, MiaAI-Lab Qwen3.8 Flash Next Dual DGX Sparks recipe (+5 more)

### Community 41 - "Admission Proxy"
Cohesion: 0.17
Nodes (4): chat(), Rejected, reservation(), validate()

### Community 42 - "Perplexity Portable Computer"
Cohesion: 0.20
Nodes (14): OpenMontage, Perplexity Portable Computer, PPLX 27B, Cloud step escalation and credits, Original DGX Spark-only launch framing, RTX PRO 5000 Perplexity Portable Computer Tutorial, Settings > Local Inference, Personal Computer vs Portable Computer (+6 more)

### Community 43 - "SparkFast vs Qwen27B Capacity"
Cohesion: 0.19
Nodes (13): spark-qwen38 (native Qwen27B), qwen3.8:27b Ollama install, Phase 3 Coding on local models, SparkFast And Qwen 27B Capacity Comparison, F16 MMA flash-attention temp buffer, Four 100K-input test, Four 240K-input long test, Four isolated Hermes sessions (+5 more)

### Community 45 - "RTX PRO 5000 EVIE Retrieval"
Cohesion: 0.20
Nodes (10): Fine-Tuning Scope On 48 GB, Verify Which RTX 5000, Tencent EVIE Visual Retriever, RTX PRO 5000 Workstation, WSL2 Ubuntu isolated ai-lab environment, PyTorch + ColPali Route, RTX PRO 5000 EVIE Visual Document Retrieval Tutorial, Multi-Vector Index Cost (+2 more)

### Community 46 - "Qwen 3.8 Flash Next v0.30"
Cohesion: 0.19
Nodes (13): 100K-token context memory gate, 100-turn long-agent tool gate, DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial, v0.30 fixed launch values, Upstream issue #48 long-agent premature stop, Memory, kernel, and preemption gate, memwatch memory watchdog, File-backed PLE mmap cache (+5 more)

### Community 47 - "LongCat Video Avatar"
Cohesion: 0.20
Nodes (14): FlashAttention, LongCat-Video-Avatar 1.5, PyTorch, Whisper Large V3, WSL2 Ubuntu, LongCat Video Avatar 1.5 Workstation Feasibility Tutorial, One-clip 480p smoke test, LongCat pass criteria (+6 more)

### Community 49 - "Obsidian Headless Sync"
Cohesion: 0.19
Nodes (11): Spark Obsidian Headless Sync Replica, DGX Spark Qwen NVFP4 Memory And Startup Optimization Research, Obsidian, Obsidian Headless Sync, Local Setup Index, Meta Bind Plugin, Obsidian Bases, Agent Inbox safe-writing pattern (+3 more)

### Community 50 - "Desktop Qwen llama-server"
Cohesion: 0.21
Nodes (11): ComfyUI video generation, CPU fallback when CUDA folder not found, Desktop Qwen llama-server (:11435), Hermes (FirstSpark), Hermes provider desktop-qwen, MTP speculative decoding (draft-mtp), Qwen ON / Qwen OFF desktop shortcuts, Spark Qwen fallback (+3 more)

### Community 51 - "Hermes Provider Migration Script"
Cohesion: 0.31
Nodes (11): Hermes Catalog Simplification (Gemmas once, Spark Qwen once), atomic_write(), digest(), explicit_desktop_references(), inside(), main(), qwen_desktop(), rollback() (+3 more)

### Community 52 - "Admission Queue Core"
Cohesion: 0.26
Nodes (3): Admission, Lease, CoreTests

### Community 53 - "GLM Shim Server and Writer Test"
Cohesion: 0.18
Nodes (3): BridgeServer, main(), request()

### Community 54 - "LM Studio Qwen Loader"
Cohesion: 0.17
Nodes (6): args, client, config, options, require, sdkDirectory

### Community 55 - "Windows Lag and Download Fix"
Cohesion: 0.17
Nodes (12): Tailscale Serve tailnet-only HTTPS routes (:8443 Ollama, :8444 desktop Qwen), Native Windows Ollama (port 11434, D:\LocalLLama store), Qwen 27B Windows Lag And Spark Download Fix 2026-10-13, Applied, Ollama GUI 256K context slider overrides OLLAMA_CONTEXT_LENGTH, Ollama env fix: 131072 context, q8_0 KV, parallel 1, Pending (user, hardware), Qwen 27B Windows lag and Spark download fix — 13 October 2026 (+4 more)

### Community 57 - "Realtime Conversation Video"
Cohesion: 0.33
Nodes (8): AivisSpeech TTS, LTX-2.5, OpenAI-compatible input_audio LLM, diffusers-movie-server gateway, Realtime Conversation Video Windows Feasibility Tutorial, Time to first audio/frame and chunk metrics, Realtime_Conversation_Video client, Realtime_Narration_Video renderer

### Community 59 - "Spark Unified Memory Co-Residency"
Cohesion: 0.22
Nodes (6): Co-residency acceptance test matrix, Qwen vLLM + LM Studio Nemotron co-residency, DGX Spark 128 GB unified LPDDR5X pool (273 GB/s), Spark LM Studio Nemotron 3.5 Lightning (historical, disabled), DFlash2 speculative decoding (draft-dflash), Q5 + DFlash2 draft3 (previous, 4x262K)

### Community 60 - "Fresh Brief Spark Migration"
Cohesion: 0.36
Nodes (6): Fresh Brief, FreshRSS, Fresh Brief acceptance gates, Cutover and preservation procedure, Fresh Brief Spark Qwen Migration Requirements, OpenAI-mode JSON adapter specification

### Community 61 - "Social Capture Pipeline"
Cohesion: 0.42
Nodes (7): Social Capture, Social Capture task provenance table, Social Capture Action Queue.md, Social Capture Pipeline, Queue lifecycle and monthly archive, Social Capture desktop dashboard, WhatsApp backlog importer

### Community 62 - "Admission Proxy HTTP App"
Cohesion: 0.39
Nodes (8): create_app(), error(), health(), json_call(), models(), recover_loop(), startup(), one()

### Community 64 - "Workstation Inference Measurement"
Cohesion: 0.39
Nodes (8): RTX PRO 5000 Local Inference Measurement Tutorial, llama-server Windows CUDA build, Inference measurement decision record, MTP draft speculative decoding, One-GGUF experiment, Quantized KV cache (-ctk/-ctv), sudoingX llama.cpp flags X post, Time to first token

### Community 65 - "Desktop Qwen Runbook Sections"
Cohesion: 0.25
Nodes (8): After an Ollama update, Daily use, Desktop Qwen Runbook, How it fits together, Not covered yet, Rules that keep the desktop smooth, Switching to a newer Qwen model, Troubleshooting

### Community 66 - "Fresh Brief Context Thrash"
Cohesion: 0.25
Nodes (7): Task Scheduler: Desktop Qwen - llama-server, Fresh Brief (Docker), Rollback to Ollama, Context-size mismatch reloads (Fresh Brief 16K vs Hermes 262K), Fresh Brief /api/chat to /v1/chat/completions adapter, Fresh Brief as scheduled Windows Qwen consumer (num_ctx 16384), 245 Qwen runner launches alternating 16K/262K contexts

### Community 67 - "One-Large-Model Rule"
Cohesion: 0.29
Nodes (3): Duplicate Lightning instance removal, 128 GB Unified Memory, MiaAI Lab SGLang recipes

### Community 68 - "spark-fast NVFP4 Memory Profile"
Cohesion: 0.25
Nodes (6): Chunked prefill with 8,192 batched tokens, nvidia/Qwen3.6-35B-A3B-NVFP4 checkpoint, spark-fast 262K / 18 GiB FP8 KV production profile, Dual-Spark exclusive frontier lane (qwen38-nvfp4/fp8, glm53, deepseek41), Standalone Hermes Gateway/Serve on FirstSpark, Standalone LiteLLM router (port 4000)

### Community 72 - "Desktop GPU and Ollama Rules"
Cohesion: 0.29
Nodes (5): NVIDIA driver updates via Windows Update, Ollama (tray app :11434), Open WebUI / Perplexica / Gemmas, Qwen 3.8 27B Q4_K_M, RTX PRO 5000 (48 GB)

### Community 73 - "Agent Memory and Crawl Tools"
Cohesion: 0.29
Nodes (7): Crawl4AI, Firecrawl, Honcho, Mem0, Multica, Paperclip, Tool overlap matrix

### Community 76 - "Frontier Vision Test"
Cohesion: 0.33
Nodes (6): Blue Circles (2, top-right), Vision Check: Shape, Color, Count, Position, Frontier Model Vision Test (image), Green Squares (3, bottom-left), Red Triangle (1, top-left), Yellow Star (1, bottom-right)

### Community 78 - "Native Spark Qwen DFlash Live"
Cohesion: 0.40
Nodes (5): Native Qwen3.8 27B llama.cpp on FirstSpark (qwen38-27b-spark), measure_interactive_speed.py / probe_qwen.py / probe_hermes_production.py, native-config.json / run_native_qwen.py launcher, Q4_K_M target + Q4 DFlash draft7 conf 0.1 (live, 2x262K), Qwen Spark Migration Evidence 2026-10-12

### Community 79 - "Native Qwen HF Download Script"
Cohesion: 0.40
Nodes (4): HF_HUB_DISABLE_IMPLICIT_TOKEN, HF_XET_CACHE, HF_XET_NUM_CONCURRENT_RANGE_GETS, download_native_qwen.sh script

### Community 83 - "Windows Display GPU Contention"
Cohesion: 0.67
Nodes (3): Monitors on RTX GPU causing DWM/inference contention, Inference vs Windows display GPU contention (Sept 28 measurement), October 6 NVIDIA TDR during Qwen serving

## Ambiguous Edges - Review These
- `spark-fast alias` → `Background review routed to SecondSpark`  [AMBIGUOUS]
  hermes-qwen-desktop-lag-handoff-2026-09-28.md · relation: conceptually_related_to
- `qwen27-dflash alias` → `DFlash2`  [AMBIGUOUS]
  RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial.md · relation: conceptually_related_to
- `Inference vs Windows display GPU contention (Sept 28 measurement)` → `October 6 NVIDIA TDR during Qwen serving`  [AMBIGUOUS]
  Qwen Spark Migration Evidence 2026-10-12.md · relation: conceptually_related_to

## Knowledge Gaps
- **142 isolated node(s):** `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_CACHE`, `HF_XET_NUM_CONCURRENT_RANGE_GETS`, `Gaming Laptop Thin Client`, `12-step rollout order` (+137 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 348 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **23 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Qwen 3.8 27B Native Spark Setup Tutorial` connect `Qwen 3.8 27B Native Spark Setup` to `Spark vs Workstation Model Placement`, `Always-On Hermes on Spark`, `Additional Models and Runtimes`, `Boot and Hermes Timeout Patches`, `Gemma 4 and Model Tutorials Index`, `Additional Services Controller`, `Native Downloads and Memory Diagnostics`, `Spark Recovery Snapshot`, `DeepSeek 131K Comparison`, `Parallel Native Downloader`, `Native Reviewed Continuation Script`, `Native Qwen Long Probe`, `Finish Native Install Script`, `LM Studio and LM Link`, `GLM 5.3 Flash EXL3 Tutorial`, `Hermes Native Provider Migration`, `Qwen 3.8 Release and Remote Access`, `Admission Proxy`, `SparkFast vs Qwen27B Capacity`, `Fresh Brief Spark Migration`?**
  _High betweenness centrality (0.313) - this node is a cross-community bridge._
- **What connects `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_CACHE`, `HF_XET_NUM_CONCURRENT_RANGE_GETS` to the rest of the system?**
  _142 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Spark vs Workstation Model Placement` be split into smaller, more focused modules?**
  _Cohesion score 0.05777345017851347 - nodes in this community are weakly interconnected._
- **Why does `Task Checklist` connect `Spark Recovery Snapshot` to `Spark vs Workstation Model Placement`, `DGX Spark Aug 2026 Deployment Research`, `Always-On Hermes on Spark`, `Additional Models and Runtimes`, `VoiceStudio Risk Audit`, `Gemma 4 and Model Tutorials Index`, `Additional Services Controller`, `Agent Tooling Catalog`, `Qwen Image 2.1 ComfyUI`, `Dual-Node Spark Configuration`, `ODS Playbook and Model Roadmap`, `DeepSeek 131K Comparison`, `Dual-Node Frontier Runbook`, `MiniMax H3 LoRA Tutorials`, `LM Studio and LM Link`, `GLM 5.3 Flash EXL3 Tutorial`, `Qwen 3.8 27B Native Spark Setup`, `Qwen 3.8 Flash Next Dual-Node`, `Spark Operations Setup`, `Qwen 3.8 Release and Remote Access`, `Markdown Dashboard and Vault Sync`, `Jev and Laya Decision Models`, `Dual-Node Frontier Recipes Research`, `Perplexity Portable Computer`, `RTX PRO 5000 EVIE Retrieval`, `LongCat Video Avatar`, `Obsidian Headless Sync`, `Realtime Conversation Video`, `Workstation Inference Measurement`?**
  _High betweenness centrality (0.138) - this node is a cross-community bridge._
- **Should `DGX Spark Aug 2026 Deployment Research` be split into smaller, more focused modules?**
  _Cohesion score 0.05701592002961866 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `spark-fast alias` and `Background review routed to SecondSpark`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `qwen27-dflash alias` and `DFlash2`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._