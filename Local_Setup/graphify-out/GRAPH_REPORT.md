# Graph Report - Local_Setup  (2026-10-13)

## Corpus Check
- 5 files · ~301,786 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2373 nodes · 5946 edges · 124 communities (97 shown, 27 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 305 edges (avg confidence: 0.84)
- Token cost: 562,641 input · 0 output

## Community Hubs (Navigation)
- DGX Spark Aug 2026 Deployment Research
- Local Setup Index Note Links
- spark-fast Benchmarks and Co-Residency
- Spark Safe Appliance Phase 0
- Index Architecture and Decisions
- Admission Proxy
- Spark vs Workstation Model Placement
- Dashboard app.js
- Hermes Bootstrap and Boot Probes
- VoiceStudio Risk Audit
- Always-On Hermes on Spark
- Native Qwen Runner and Diagnostics
- Index Model Inventory
- Desktop Qwen Runbook
- LiteLLM Lifecycle and Ownership
- spark-fast NVFP4 Memory Profile
- Model Tutorials Index and Runtimes
- Index Current Confirmed State
- Frontier Model Probe
- Ops Guide State Capture
- Parallel Native Downloader
- DeepSeek and Frontier Comparison
- Qwen 3.8 Flash Next Dual-Node
- Fresh Brief and Qwen 3.8 Intake
- Downloader and Dashboard Builder
- Native Reviewed Continuation Script
- Agent Tooling Catalog
- Finish Native Install Script
- Checklist Skills and Plugins
- Checklist Dual-Spark Frontier Lane
- Ops Guide bashrc and Functions
- TensorFold Runtime and Context
- MiniMax H3 LoRA Tutorials
- GLM 5.3 Flash EXL3 Tutorial
- Qwen Image 2.1 ComfyUI
- Two-Slot 262K Memory Plan
- Probe Test Fakes
- Ops Guide Hermes Serve Setup
- Dual-Node Spark Configuration
- Frontier Hot-Swap and Routing
- Index Canonical Decisions
- TensorFold Private CX-7 Setup
- Markdown Dashboard and Vault Sync
- Index Done Sections
- TensorFold Backup and LiteLLM Gates
- Agent Platforms and MCP Tools
- Pressure Qualification Tests
- Ops Guide vLLM Launch Settings
- TensorFold Hermes Profile Cutover
- Jev and Laya Decision Models
- Ops Guide Model Shelf
- Spark Twitter Bookmarks Research
- Add Desktop Qwen and Patches
- Additional Services Controller
- Gemma 4 Tutorial and Ops Guides
- Model Installation and Switching
- Ops Guide Hermes LiteLLM Wiring
- Obsidian Replicas and Sync
- GLM Reasoning Bridge Handler
- Ops Guide ODS LiteLLM
- TensorFold Alias Checks
- Qwen Image BFS Body Swap
- LongCat Video Avatar
- Index Qwen Migration Evidence
- DFlash Draft Config Tests
- SecondSpark Qwen Lane
- TensorFold Download and Cache Fix
- Qwen 3.8 Flash Next v0.30
- EVIE Retrieval Tutorial
- Provider Rename Config Targets
- TensorFold v0.30 Retirement
- Realtime Conversation Video
- GLM Shim Server
- LM Studio Qwen Loader
- Hermes Provider Migration Script
- Memory Readiness Tests
- Spark Unified Memory Co-Residency
- Second Spark Readiness
- Checklist Codex Tasks
- Desktop Qwen Naming
- SparkFast vs Qwen27B Capacity
- Muse Glimmer and Lightning Tutorials
- ODS Phase 2 Fine-Tuning
- Ops Guide Store Layout
- TensorFold Comparison Profiles
- sparkDash Monitoring
- Hermes Timeout Tests
- Perplexity Portable Computer
- Social Capture Pipeline
- FirstSpark Standalone LiteLLM
- Unchanged Internal spark-fast Names
- Systemctl Start-Limit Tests
- Workstation Inference Measurement
- Named Custom Timeout Tests
- Production Wire Tests
- TensorFold Safety Checks
- YouTube and Social Capture Helpers
- Hermes Catalog Tests
- Agent Memory and Crawl Tools
- Frontier Vision Test
- Provider Models Cache Clearing
- Native Qwen HF Download Script
- Nemotron 3 Nano Omni
- Local Setup Dashboard
- local-models LiteLLM Aliases
- Desktop Qwen Transform Tests
- Graphify Project Rules
- vLLM Cold-Start Optimization
- Obsidian Agent Inbox Pattern
- Index Done and Exclusions
- Ollama Context Reload Fix
- Monitors on RTX Lag Fix
- Two-Slot Migration Off Ollama
- Native Runtime Build Script
- Windows Display GPU Contention
- Fresh Brief Context Thrash
- Spark Download Relay
- LM Studio Residency Retirement
- Run-At-Boot Result
- Pre-Fix Ollama Env

## God Nodes (most connected - your core abstractions)
1. `Task Checklist` - 94 edges
2. `Hermes Agent` - 89 edges
3. `Local Setup Index` - 79 edges
4. `DGX Spark ODS Playbook and Model Roadmap` - 69 edges
5. `RTX PRO 5000 Workstation` - 67 edges
6. `LiteLLM` - 65 edges
7. `local-ai-tooling-catalog-and-rollout` - 64 edges
8. `LM Studio` - 63 edges
9. `Ollama` - 61 edges
10. `vLLM` - 60 edges

## Surprising Connections (you probably didn't know these)
- `Unified 524K Q8 KV Alternative` --semantically_similar_to--> `Two-Slot 262K Context and Memory Plan`  [INFERRED] [semantically similar]
  Qwen Spark Migration/LONG-PROBE-GUARDS.md → Qwen 3.8 27B Spark Serving Options.md
- `request()` --indirect_call--> `error()`  [INFERRED]
  .setup-dashboard/test_writer.py → Qwen Spark Migration/admission_proxy.py
- `Four-Slot Q8 Memory Estimate` --references--> `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)`  [EXTRACTED]
  Qwen Spark Migration/LONG-PROBE-GUARDS.md → DGX Spark Additional Model Tutorials Index.md
- `DGX Spark Frontier Model Qualification Results` --references--> `Frontier Model Vision Test (image)`  [INFERRED]
  DGX Spark Frontier Model Qualification Results.md → Frontier Model Vision Test.png
- `Frontier Model Vision Test (image)` --conceptually_related_to--> `DGX Spark`  [INFERRED]
  Frontier Model Vision Test.png → Always-On Hermes on DGX Spark.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Desktop lag causal chain on shared display GPU** — ent_qwen_3_8_27b, ent_ollama, ent_rtx_pro_5000_workstation, ent_desktop_window_manager, ent_handy, hermes_qwen_desktop_lag_handoff_2026_09_28_gpu_display_contention [EXTRACTED 1.00]
- **Clients sharing the 2 llama-server slots** — desktop_qwen_runbook_llama_server, desktop_qwen_runbook_hermes, desktop_qwen_runbook_fresh_brief, desktop_qwen_runbook_tailscale_serve_8444 [EXTRACTED 1.00]
- **Single-GPU contention (Qwen vs ComfyUI vs Ollama)** — desktop_qwen_runbook_rtx_pro_5000, desktop_qwen_runbook_llama_server, desktop_qwen_runbook_comfyui, desktop_qwen_runbook_ollama_tray [EXTRACTED 1.00]
- **MiaAI Dual-Spark Frontier Recipes** — ent_qwen_3_8_flash_next, ent_glm_5_3_flash, ent_deepseek_v4_1_flash, ent_dual_spark_cluster, ent_miaai_lab [EXTRACTED 1.00]
- **Four permanent Frontier aliases hot-swapped by spark-frontier** — dgx_spark_frontier_model_hot_swap_and_routing_guide_spark_frontier, dgx_spark_frontier_model_hot_swap_and_routing_guide_qwen38_nvfp4, dgx_spark_frontier_model_hot_swap_and_routing_guide_qwen38_fp8, dgx_spark_frontier_model_hot_swap_and_routing_guide_glm53_flash, dgx_spark_frontier_model_hot_swap_and_routing_guide_deepseek41_flash [EXTRACTED 1.00]
- **Hermes cross-machine provider routing via LM Link and Tailscale** — ent_hermes, ent_lm_link, ent_lm_studio, ent_ollama, ent_tailscale, hermes_lm_link_and_workstation_model_routing_research_spark_lmstudio_provider, hermes_lm_link_and_workstation_model_routing_research_desktop_ollama_provider [EXTRACTED 1.00]
- **MiniMax H3 local ComfyUI bench with community LoRAs** — minimax_h3_windows_video_exploration_tutorial_isolated_comfyui_bench, ent_comfyui, minimax_h3_character_swap_lora_windows_tutorial_character_swap_lora, minimax_h3_handheld_shaky_cam_lora_windows_tutorial_handheld_shaky_cam_lora, ent_rtx_pro_5000_workstation [EXTRACTED 1.00]
- **Performance-first Hermes serving stack** — ent_hermes, ent_litellm, ent_spark_fast, ent_vllm, ent_qwen_3_6_35b_a3b [EXTRACTED 1.00]
- **Protected control plane kept out of bulk drains** — dgx_spark_frontier_model_hot_swap_and_routing_guide_spark_litellm, spark_hermes_setup_runbook_hermes_serve, spark_hermes_setup_runbook_hermes_gateway, dgx_spark_frontier_model_hot_swap_and_routing_guide_glm_reasoning_shim, dgx_spark_additional_services_controller_policy_tiers [EXTRACTED 1.00]
- **Boot recovery ordering chain** — ent_spark_fast, dgx_spark_pre_shutdown_and_automatic_recovery_snapshot_2026_08_20_wait_for_spark_fast, dgx_spark_pre_shutdown_and_automatic_recovery_snapshot_2026_08_20_lmstudio_service, ent_nemotron_3_5_lightning [EXTRACTED 1.00]
- **Qwen Image 2.1 ComfyUI pipeline (denoiser + encoder + VAE + LoRA)** — ent_qwen_image_2_1, ent_qwen3_vl_8b_encoder, rtx_pro_5000_qwen_image_2_1_base_windows_tutorial_qwen_image_vae, rtx_pro_5000_qwen_image_2_1_base_windows_tutorial_text_encode_qwen_image21_node, rtx_pro_5000_qwen_image_2_1_bfs_body_swap_windows_tutorial_lora_loader_model_only, ent_comfyui [EXTRACTED 1.00]
- **Realtime conversation video service chain** — realtime_conversation_video_windows_feasibility_tutorial_realtime_conversation_client, realtime_conversation_video_windows_feasibility_tutorial_audio_input_llm, realtime_conversation_video_windows_feasibility_tutorial_realtime_narration_video, ent_aivisspeech, realtime_conversation_video_windows_feasibility_tutorial_diffusers_movie_server, ent_ltx_2_5 [EXTRACTED 1.00]
- **Dual Spark cluster bring-up** — ent_secondspark, dgx_spark_second_node_and_dual_spark_readiness_research_2026_08_20_qsfp112_dac_cable, dgx_spark_second_node_and_dual_spark_readiness_research_2026_08_20_cluster_assistant, ent_nccl, ent_dual_spark_cluster [EXTRACTED 1.00]
- **Spark-authoritative Hermes with remote Desktop clients over Tailscale** — ent_hermes, ent_hermes_desktop, ent_dgx_spark, ent_tailscale, local_ai_architecture_research_hermes_serve, local_ai_architecture_research_hermes_gateway [EXTRACTED 1.00]
- **spark-fast vLLM memory and scheduling controls** — dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_kv_cache_memory_bytes, dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_gpu_memory_utilization_preflight, dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_chunked_prefill, dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_cuda_graphs, dgx_spark_qwen_nvfp4_memory_and_startup_optimization_research_spark_fast_production_profile [EXTRACTED 1.00]
- **Spark Hermes Control Plane** — ent_hermes, always_on_hermes_on_dgx_spark_hermes_serve, always_on_hermes_on_dgx_spark_hermes_gateway, ent_litellm, ent_tailscale, ent_hermes_desktop [EXTRACTED 1.00]
- **Spark Inference Engine Learning Ladder** — ent_llama_cpp, ent_vllm, ent_sglang, ent_tensorrt_llm, ent_nim [EXTRACTED 1.00]
- **Windows Qwen lag root causes** — qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_ollama_gui_context_slider, qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_context_size_mismatch_reloads, qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_monitors_on_rtx_desktop_lag, qwen_27b_windows_lag_and_spark_download_fix_2026_10_13_ollama_qwen35_no_parallel [EXTRACTED 1.00]
- **Workstation Ollama reached from Spark Hermes via Tailscale Serve** — ent_ollama, ent_tailscale_serve, ent_desktop_ollama_provider, ent_hermes, ent_qwen_3_8_27b, ent_rtx_pro_5000_workstation [EXTRACTED 1.00]
- **Desktop Qwen server lifecycle control** — scripts_desktop_qwen_apply, scripts_qwen_on, scripts_qwen_off, desktop_qwen_runbook_task_scheduler_boot_task [INFERRED 0.85]
- **FirstSpark resident set routed through LiteLLM/Hermes** — model_and_provider_names_qwen3_6_35b_a3b, qwen_3_8_27b_native_spark_setup_tutorial_qwen38_27b_spark, firstspark_standalone_litellm_operations_spark_litellm [INFERRED 0.85]
- **Mutually exclusive dual-node frontier lanes on port 8100** — dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_baseline, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_fp8_comparison, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_mtp_850k_accepted, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_deepseek_recipe, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_port_8100 [INFERRED 0.85]
- **Frontier Lane Hot-Swap Lifecycle** — ent_spark_model, ent_spark_fast, dgx_spark_dual_node_community_frontier_models_runbook_common_drain_rollback, dgx_spark_dual_node_community_frontier_models_runbook_litellm_hermes_aliases [INFERRED 0.85]
- **Frontier qualification evidence pipeline** — dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_probe_suite, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_evidence_suite, dgx_spark_frontier_model_qualification_results_headline_table, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_perf_results, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_vs_fp8_results [INFERRED 0.85]
- **Gateway-routed logical aliases with controlled model swap** — dgx_spark_twitter_bookmarks_analysis_safe_swap_controller, local_ai_architecture_research_hotswap_as_routing, personal_hermes_obsidian_multinode_design_gateway_hot_swap_policy, ent_litellm, personal_hermes_obsidian_multinode_design_logical_routes [INFERRED 0.85]
- **Unified-memory safety qualification gates (MemAvailable >=10 GiB, no NV_ERR_NO_MEMORY)** — dgx_spark_single_node_qwen_3_8_flash_next_v0_30_tutorial_memory_kernel_gate, dgx_spark_sparkdash_monitoring_tutorial_coexistence_decision, ent_unified_memory_128gb [INFERRED 0.85]
- **Prepare script, stop Qwen, raw test, LiteLLM, Hermes, restore Qwen profile pattern** — dgx_spark_gemma_4_models_tutorial_prepare_gemma4_profile, dgx_spark_nemotron_3_nano_omni_tutorial_prepare_nemotron3_omni, dgx_spark_nemotron_3_5_lightning_tutorial_prepare_nemotron35_lightning, dgx_spark_muse_glimmer_30b_readiness_tutorial_prepare_muse_glimmer, dgx_spark_model_installation_and_switching_guide_additional_model_rules, spark_hermes_setup_runbook_qwen3_6_35b_a3b [INFERRED 0.85]
- **VoiceStudio Readiness Failure Chain** — voicestudio_risk_audit_shutdown_latch, voicestudio_risk_audit_false_negative_health, voicestudio_risk_audit_no_deliverable_baseline, voicestudio_risk_audit_lifecycle_confusion [INFERRED 0.85]
- **Exclusive dual-Spark frontier hot-swap profiles** — task_checklist_qwen38_nvfp4, task_checklist_qwen38_fp8, task_checklist_glm53_flash, task_checklist_deepseek41_flash, task_checklist_spark_frontier_manager, task_checklist_qwen3_6_35b_a3b [EXTRACTED 1.00]
- **Operational P0 baseline sequences** — task_checklist_sequence_0_baseline_ownership, task_checklist_sequence_1_backups_failover, task_checklist_sequence_2_laptop_thin_client, task_checklist_sequence_3a_skill_intake, task_checklist_sequence_4_local_coding, task_checklist_sequence_5_safe_automation, task_checklist_sequence_6_obsidian_replica_retrieval [EXTRACTED 1.00]
- **Qwen desktop relief native Spark serving stack** — task_checklist_native_llama_cpp_cuda_runtime, task_checklist_ud_q5_k_xl, task_checklist_q4_kv_cache_262k_sessions, task_checklist_native_worker_1236, task_checklist_admission_1235, task_checklist_firstspark, task_checklist_pressure_aware_acceptance [INFERRED 0.85]
- **Hermes -> LiteLLM -> vLLM -> Qwen3.6 serving stack** — dgx_spark_operations_setup_guide_hermes, dgx_spark_operations_setup_guide_ods_litellm, spark_hermes_setup_runbook_vllm_spark_fast, dgx_spark_operations_setup_guide_unsloth_qwen36_nvfp4, dgx_spark_operations_setup_guide_qwen36_35b_a3b_route [EXTRACTED 1.00]
- **24x7 promotion test gates** — dgx_spark_operations_setup_guide_spark_fast_ok, dgx_spark_operations_setup_guide_litellm_ok, dgx_spark_operations_setup_guide_tool_calls_gate, dgx_spark_operations_setup_guide_hermes_ok, dgx_spark_operations_setup_guide_promotion_gate [EXTRACTED 1.00]
- **Recommended personal Hermes mode components** — dgx_spark_operations_setup_guide_hermes_gateway, always_on_hermes_on_dgx_spark_hermes_serve, dgx_spark_operations_setup_guide_ods_litellm, ent_tailscale, dgx_spark_operations_setup_guide_hermes_desktop, dgx_spark_operations_setup_guide_personal_mode [EXTRACTED 1.00]
- **Exclusive dual-Spark frontier alias set** — local_setup_index_frontier_lane, dgx_spark_frontier_model_hot_swap_and_routing_guide_qwen38_nvfp4, dgx_spark_frontier_model_hot_swap_and_routing_guide_qwen38_fp8, dgx_spark_frontier_model_hot_swap_and_routing_guide_glm53_flash, dgx_spark_frontier_model_hot_swap_and_routing_guide_deepseek41_flash, local_setup_index_spark_frontier_manager, local_setup_index_port_8100 [EXTRACTED 1.00]
- **spark-model switchable lanes** — local_setup_index_spark_model_lanes, local_setup_index_lane_qwen35, local_setup_index_lane_qwen27_dflash, local_setup_index_lane_nemotron3_omni, local_setup_index_lane_nemotron35_lightning, local_setup_index_spark_model_manager [EXTRACTED 1.00]
- **Hermes provider routing across Spark and workstation** — task_checklist_local_models_provider, local_setup_index_desktop_ollama_provider, local_setup_index_spark_lmstudio_provider, local_setup_index_litellm, local_setup_index_remote_gateway, local_setup_index_windows_local_gateway [INFERRED 0.85]
- **Step 8 LiteLLM route proof gates** — dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_gate_discovery, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_gate_fail_closed, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_gate_litellm_text, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_gate_stream, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_gate_tool [EXTRACTED 1.00]
- **Step 11 standardized raw qualification** — dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_frontier_probe, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_context_ladder, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_concurrency_ladder, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_check_safety, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_probe_markers, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_gate_full_raw [EXTRACTED 1.00]
- **Retained v0.30 rollback assets** — dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_alias_old, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_nvidia_checkpoint, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_ple_cache_v030, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_v030_checkout, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_spark_qwen38_single_key, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_cold_picker_entry [INFERRED 0.85]
- **Old names kept working for backward compatibility** — model_and_provider_names_litellm_spark_fast_hidden_alias, model_and_provider_names_hermes_auth_json, model_and_provider_names_desktop_server_any_model [EXTRACTED 1.00]
- **Unchanged spark-fast internal plumbing names** — model_and_provider_names_vllm_spark_fast_container, model_and_provider_names_spark_fast_hostname, model_and_provider_names_spark_fast_vllm_served_name, model_and_provider_names_wait_for_spark_fast, model_and_provider_names_ylc_model_profile, model_and_provider_names_ops_scripts [EXTRACTED 1.00]
- **Direct port-8000 callers using spark-fast served name** — ent_youtube_learning_center, model_and_provider_names_hermes_youtube_analysis_helper, model_and_provider_names_hermes_social_capture_vision_helper, model_and_provider_names_social_capture_plugin [EXTRACTED 1.00]

## Communities (124 total, 27 thin omitted)

### Community 0 - "DGX Spark Aug 2026 Deployment Research"
Cohesion: 0.06
Nodes (58): 0xSero DeepSeek V4 Flash SparkInfer, DGX Spark Aug 2026 Model Deployment Research, Evidence Labels Standard, Hermes-Ready Tool Contract, NVIDIA Playbook Issue #89 Tool-Call Quant Bisect, Local Acceptance Benchmark Contract, MiaAI Qwen3.6 27B DFlash Profile, NVIDIA Qwen3.6 35B First-Party Control (+50 more)

### Community 1 - "Local Setup Index Note Links"
Cohesion: 0.08
Nodes (61): Desktop Qwen Runbook, DGX Spark Additional Model Tutorials Index, DGX Spark Aug 2026 Model Deployment Research, DGX Spark Automatic Power Recovery Research, DGX Spark Current Models Report, DGX Spark DeepSeek 131K And SparkFast Comparison Protocol, DGX Spark Dual-Node Community Frontier Models Runbook, DGX Spark Dual-Node Configuration And Operations Reference (+53 more)

### Community 2 - "spark-fast Benchmarks and Co-Residency"
Cohesion: 0.07
Nodes (49): Nemotron 3.5 Lightning Official vLLM Recipe, DGX Spark DeepSeek 131K And SparkFast Comparison Protocol, spark-fast Raw Reference Benchmark, Stop GLM and restore spark-fast, DGX Spark Frontier Model Qualification Results, Spark-Fast + Nemotron five-session co-residency retest, Permanent Nemotron 1M x 1 profile, SparkFast orphan-request guard (+41 more)

### Community 3 - "Spark Safe Appliance Phase 0"
Cohesion: 0.07
Nodes (44): Phase 0 - Make the Spark a safe appliance, Phase 4 - Agent security, not agent sprawl, Roadmap Completion Criteria, dgx-spark-playbook-roadmap-draft, Phase 0 — Safe Remote Appliance, Phase 3 — FDE Case Studies, Phase 4 — Agent Security, Phase 5 — Electives and Deferrals (+36 more)

### Community 4 - "Index Architecture and Decisions"
Cohesion: 0.05
Nodes (36): DGX Spark And RTX 5000 Workstation Model Placement Research, Compare prompts against spark-fast in Hermes Desktop, Stale-write, simultaneous-edit, restart, sync-delay, rollback tests, desktop-ollama Hermes provider, Discord bot, FirstSpark (DGX Spark production node), Fresh Brief (scheduled Windows consumer), gemma3:4b (+28 more)

### Community 5 - "Admission Proxy"
Cohesion: 0.06
Nodes (15): Admission, create_app(), chat(), health(), json_call(), models(), recover_loop(), startup() (+7 more)

### Community 6 - "Spark vs Workstation Model Placement"
Cohesion: 0.08
Nodes (37): DGX Spark And RTX 5000 Workstation Model Placement Research, Fine-Tuning Scope On 48 GB, Open WebUI Provider Prefixes, Model Placement Matrix, Verify Which RTX 5000, Workstation Model Shortlist, Frontier API port 8100, Hermes desktop-ollama Named Provider (+29 more)

### Community 7 - "Dashboard app.js"
Cohesion: 0.10
Nodes (44): applyLibrarySnapshot(), closeDrawer(), decodeSafe(), download(), drawTask(), empty(), exportHTML(), exportProgress() (+36 more)

### Community 8 - "Hermes Bootstrap and Boot Probes"
Cohesion: 0.09
Nodes (9): atomic(), digest(), main(), transform(), child(), guard_socket_connector(), main(), production_python_command() (+1 more)

### Community 9 - "VoiceStudio Risk Audit"
Cohesion: 0.07
Nodes (46): Safe Download Order, Hugging Face Hub cache, OmniVoice TTS Model, Parakeet TDT 0.6B v3, Whisper, v0.5.0 Active Beta Contract Churn, API/Network Sharing Auth and TLS, Database/History Backup Verification (+38 more)

### Community 10 - "Always-On Hermes on Spark"
Cohesion: 0.08
Nodes (33): Stable Capability Model Aliases, Workstation-local desktop-files Profile, Discord Primary Phone Interface, Always-On Hermes on DGX Spark, hermes gateway, ODS Hermes Auth Proxy, Always-On Hermes Rollout Plan, 24x7 Hermes Service Shape (+25 more)

### Community 11 - "Native Qwen Runner and Diagnostics"
Cohesion: 0.09
Nodes (16): digest(), main(), measure(), main(), one(), post(), check_co_residents(), command() (+8 more)

### Community 12 - "Index Model Inventory"
Cohesion: 0.10
Nodes (36): DGX Spark Additional Models And Convenience Runtimes Research, DGX Spark Multi-Model Runtime Research, Muse Glimmer 30B, Local Setup Index, gemma4:26b-a4b-it-qat, gemma4:31b-it-qat, qwen3-coder:30b, gpt-oss:20b (+28 more)

### Community 13 - "Desktop Qwen Runbook"
Cohesion: 0.07
Nodes (35): After an Ollama update, ComfyUI video generation, CPU fallback (~4 tok/s) from missing CUDA DLLs in bin, Daily use, Desktop Qwen Runbook, Fresh Brief (Docker, OLLAMA_URL host.docker.internal:11435), Hermes (FirstSpark, 6 profiles), How it fits together (+27 more)

### Community 14 - "LiteLLM Lifecycle and Ownership"
Cohesion: 0.08
Nodes (30): Spark/Workstation Ownership Architecture, Add Services Back One Layer At A Time, Proposed LiteLLM/Hermes frontier aliases, One-time LiteLLM HTTP 500 on stopped upstream, Controlled LiteLLM and Hermes promotion (Steps 14-24), annas-archive-epub-downloads skill, Windows Desktop Window Manager, Handy (+22 more)

### Community 15 - "spark-fast NVFP4 Memory Profile"
Cohesion: 0.07
Nodes (29): Always-On Hermes on DGX Spark, DGX Spark Qwen NVFP4 Memory And Startup Optimization Research, Chunked prefill with 8,192 batched tokens, nvidia/Qwen3.6-35B-A3B-NVFP4 checkpoint, spark-fast 262K / 18 GiB FP8 KV production profile, Step 1: Remote-client checks (laptop, Telegram), Representative 24-hour soak before retiring rollback assets, #approvals channel (+21 more)

### Community 16 - "Model Tutorials Index and Runtimes"
Cohesion: 0.09
Nodes (27): DGX Spark Additional Model Tutorials Index, Qwen 3.8 Release Intake Sequence, Recommended Model Testing Order, Per-Runtime Model Stores, Unverified Or Deferred Items, DGX Spark Additional Models And Convenience Runtimes Research, Gemma 4 26B A4B vLLM Spark Recipe, Gemma 4 31B Experimental Profile (+19 more)

### Community 17 - "Index Current Confirmed State"
Cohesion: 0.07
Nodes (31): Hermes LM Link And Workstation Model Routing Research, Current confirmed state, Desktop Qwen 3.8 27B via Ollama bundled llama-server (desktop-qwen), 2 sessions x 262K, ~96 tok/s single / ~82 each, Follow-up memory test passed (15.115GiB available, zero swap-out/OOM), Four independent 262K contexts with Q4 K/V, no output cap, nemotron35-lightning lane, Optional laptop Local Gateway (tailnet 8443) (+23 more)

### Community 18 - "Frontier Model Probe"
Cohesion: 0.25
Nodes (24): atomic_json(), capture_record(), chat_content(), cmd_chat(), cmd_compare(), cmd_concurrency(), cmd_context(), cmd_identity() (+16 more)

### Community 19 - "Ops Guide State Capture"
Cohesion: 0.08
Nodes (25): DGX Spark Aug 2026 Model Deployment Research, capture-dgx-state.sh, DGX Spark Operations Setup Guide, ~/runs/host-audits before-models audit, Local Setup Index, Model And Provider Names, nano editor, NVIDIA DGX Spark catalog (+17 more)

### Community 20 - "Parallel Native Downloader"
Cohesion: 0.14
Nodes (18): atomic_json(), Canceled, digest(), download_file(), transfer(), fetch_range(), main(), probe_ranges() (+10 more)

### Community 21 - "DeepSeek and Frontier Comparison"
Cohesion: 0.10
Nodes (24): DeepSeek 131K Bring-Up Profile, Eight-Profile Raw Comparison Table, Common Drain And Universal Rollback, DGX Spark Dual-Node Community Frontier Models Runbook, Fixed Cluster Values, GLM 5.3 Local Baseline Result, Immediate Stop Conditions, Frontier LiteLLM/Hermes Aliases (+16 more)

### Community 22 - "Qwen 3.8 Flash Next Dual-Node"
Cohesion: 0.15
Nodes (17): Raw endpoint acceptance gate, Independent dual-Spark Qwen FP8 recipes, DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18, Official vLLM Qwen3.8 Flash Next FP8 recipe, MiaAI-Lab Qwen3.8 Flash Next Dual DGX Sparks recipe, Acceptance and rollback run receipt, sparkDash known issues, DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial (+9 more)

### Community 23 - "Fresh Brief and Qwen 3.8 Intake"
Cohesion: 0.12
Nodes (20): Fresh Brief, FreshRSS, Qwen 3.8 27B, Unsloth Qwen3.8-27B GGUF, Fresh Brief acceptance gates, Cutover and preservation procedure, Fresh Brief Spark Qwen Migration Requirements, OpenAI-mode JSON adapter specification (+12 more)

### Community 24 - "Downloader and Dashboard Builder"
Cohesion: 0.14
Nodes (11): main(), main(), one(), qualification_environment(), atomic_write(), Dashboard, library_state(), markdown_path() (+3 more)

### Community 25 - "Native Reviewed Continuation Script"
Cohesion: 0.15
Nodes (17): install_hooks(), qualify_long(), main(), pressure_failures(), pressure_wrapped_run(), monitor(), sample(), reviewed_evidence() (+9 more)

### Community 26 - "Agent Tooling Catalog"
Cohesion: 0.10
Nodes (24): Addy Osmani Agent Skills, Anthropic Claude Skills, AutoGen, Caveman, Claude Design, Composio, Compound Engineering plugin, CrewAI (+16 more)

### Community 27 - "Finish Native Install Script"
Cohesion: 0.20
Nodes (21): check_abort(), entrypoint(), get(), handle_shutdown(), kill_group(), main(), mem_available_gib(), memory_guard() (+13 more)

### Community 30 - "Checklist Skills and Plugins"
Cohesion: 0.09
Nodes (25): Addy Osmani Agent Skills (balanced baseline), Private canonical ai-fleet skills/config repository, Cloudflare plugin, Codex Security plugin, Compound Engineering, DCG — Destructive Command Guard, Figma or Canva (choose one), gstack by Garry Tan (+17 more)

### Community 31 - "Checklist Dual-Spark Frontier Lane"
Cohesion: 0.16
Nodes (24): DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial, DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial, Ling 3.0 Flash, Sequence 8I — Dual-Spark community frontier lane, Aiden stack (unreproduced; naming withheld), Capacity and coexistence decision table, deepseek41-flash (DeepSeek V4.1 Flash EXL3), DeepSeek 131K/one-sequence/1 GiB-KV safety boot then 600K baseline (+16 more)

### Community 32 - "Ops Guide bashrc and Functions"
Cohesion: 0.10
Nodes (24): ~/.bashrc, bashrc.backup.<timestamp>, bashrc.candidate, dgx-models, DGX SPARK .bashrc marker block, dgx-status, Emergency .bashrc restore, linear-backend flashinfer_b12x (+16 more)

### Community 33 - "TensorFold Runtime and Context"
Cohesion: 0.15
Nodes (25): tools/bench.py tf-second prefill/decode sample, Context 262,144 tokens, docker logs qwen38-flash-next-tf, Normal TensorFold operation (manual start, no boot supervisor), Old 206K stress test failed memory gate, Pinned scripts/config.sh, Pinned revision a3aa89835022c55ca8e55008c37785954834e04f (2026-09-29), qwen38-flash-next-tf container (+17 more)

### Community 34 - "MiniMax H3 LoRA Tutorials"
Cohesion: 0.13
Nodes (22): Akatz MiniMax H3 Character Swap LoRA v1, LoRA-on-Continuation Experiment (fnoji tip), MiniMax H3 Character Swap LoRA Windows Tutorial, MiniMax H3 Community License Agreement, Ref2VA Pinned Baseline, Shaky Cam Author Settings, MiniMax H3 Handheld Shaky Cam LoRA Windows Tutorial, Handheld Shaky Cam LoRA (neph1 / Civitai v3343481) (+14 more)

### Community 35 - "GLM 5.3 Flash EXL3 Tutorial"
Cohesion: 0.16
Nodes (21): GLM recipe open failure issues, MiaAI-Lab GLM-5.3-Flash-EXL3-2x-DGX-Sparks recipe, Shared frontier API key, GLM context ladder, DFlash/500K profile (GMU 0.86), DFlash/850K baseline profile, DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial, Step 16e shared evidence suite (+13 more)

### Community 36 - "Qwen Image 2.1 ComfyUI"
Cohesion: 0.19
Nodes (20): ComfyUI, Qwen3-VL 8B text encoder, Qwen Image 2.1, BF16 quality comparison lane, RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial, INT8 ConvRot baseline lane, Isolated portable ComfyUI install, Official Qwen Image 2.1 image-edit workflow (+12 more)

### Community 37 - "Two-Slot 262K Memory Plan"
Cohesion: 0.14
Nodes (18): Two-Slot 262K Context and Memory Plan, error(), Native Qwen Long-Input Qualification Guards (LONG-PROBE-GUARDS), Four-Slot Q8 Memory Estimate, Separate Four-Slot Q4_0 KV Mode, Unified 524K Q8 KV Alternative, send(), validate_payload() (+10 more)

### Community 39 - "Ops Guide Hermes Serve Setup"
Cohesion: 0.15
Nodes (19): hermes serve, /api/status auth_required + basic provider check, Connect via SSH mode, Hermes default profile, Desktop-shell plugin, Desktop Sign in with username nitin, Final success state, HERMES_DASHBOARD_BASIC_AUTH_USERNAME/PASSWORD/SECRET (+11 more)

### Community 40 - "Dual-Node Spark Configuration"
Cohesion: 0.15
Nodes (18): NVIDIA Driver CDI Recovery, Dual-Spark Usage Options, DGX Spark Dual-Node Configuration And Operations Reference, NCCL all_gather_perf Result, NCCL Test Procedure, CX-7 Physical Topology, Software Baseline Audit 2026-09-18, Qwen fixed cluster values (+10 more)

### Community 41 - "Frontier Hot-Swap and Routing"
Cohesion: 0.24
Nodes (17): DGX Spark Frontier Model Hot-Swap And Routing Guide, Cold-route rejection test, deepseek41-flash alias, glm53-flash alias, GLM accepted.env MTP/850K profile, glm-reasoning-shim.service, local-models Hermes custom provider, qwen38-fp8 alias (+9 more)

### Community 42 - "Index Canonical Decisions"
Cohesion: 0.10
Nodes (17): DGX Spark ODS Playbook and Model Roadmap, Fine-tune sequence: 7-14B LoRA, fixed dataset, eval, export, quantize, new LiteLLM alias, nemotron3-omni lane, qwen35 lane (resident), October 1 mixed-load audit (eight scheduled requests, no failures), Omni tests: text, tools, 70,025-token prompt, image, audio-path, video, Nemotron Omni 12 GiB KV pool, 131,072-token ceiling, ~43 GiB, Authenticated port 8100 (frontier lane) (+9 more)

### Community 43 - "TensorFold Private CX-7 Setup"
Cohesion: 0.16
Nodes (18): FirstSpark (spark-07a8), Private direct CX-7 interface 192.168.100.11, TensorFold .env (HOST=192.168.100.11, PORT=8888, PARALLEL=4, CONTEXT=262144, KV_DTYPE=int8, PLE_ON_SSD=1, VISION=1, VISION_URLS=0), Later five-stream experiment (needs own gate), Step 1 SecondSpark gate (hostname, port 8888 owner, disk, restart=no), KV_DTYPE=int8, LITELLM_MASTER_KEY, SecondSpark monitoring watch (free, nvidia-smi, journalctl) (+10 more)

### Community 44 - "Markdown Dashboard and Vault Sync"
Cohesion: 0.15
Nodes (16): Spark Obsidian Headless Sync Replica, Claude Messages API, Obsidian, Obsidian Sync, Personal-Sync Vault, Dashboard MVP Acceptance Tests, Chokidar File Watcher + Server-Sent Events, Markdown Backed Interactive Dashboard Research (+8 more)

### Community 45 - "Index Done Sections"
Cohesion: 0.10
Nodes (19): DGX Spark Operations Setup Guide, DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20, Steps 11-15: Hermes Gateway, Serve, authenticated Remote Gateway, 24x7, Operations Setup Guide Steps 1-6 (state capture, secrets, registries), Steps 7-10: Qwen 3.6 35B-A3B NVFP4 served and added to LiteLLM as spark-fast, Qwen-before-Lightning boot order, Recovery: power-cycle recovery; post-migration controlled reboot pending, Safe stop and rollback commands section (+11 more)

### Community 47 - "TensorFold Backup and LiteLLM Gates"
Cohesion: 0.15
Nodes (19): ~/backups/qwen38-tensorfold-replacement/<stamp>, ~/.config/frontier/qwen38-tensorfold-backup-dir, LiteLLM compose.yaml, LITELLM_ALIASES_ADDED_AND_PARKED gate, BACKUP_OK gate, OLD_ALIAS_REMOVED_FROM_CONFIGS, OLD_LITELLM_ROUTE_OK gate, Six per-profile <CLI>_TENSORFOLD_OK markers (+11 more)

### Community 48 - "Agent Platforms and MCP Tools"
Cohesion: 0.10
Nodes (20): Browser Use, Buffer MCP, Daytona, here.now, Higgsfield, Langflow, NotebookLM MCP (unofficial), RAGFlow (+12 more)

### Community 49 - "Pressure Qualification Tests"
Cohesion: 0.14
Nodes (3): PressureTests, ReuseTests, sample()

### Community 50 - "Ops Guide vLLM Launch Settings"
Cohesion: 0.13
Nodes (16): CUTE_DSL_ARCH sm_121a, FP8 KV cache, HF_HUB_OFFLINE=1, 260,016-token prompt completed without preemption/OOM (2026-08-15), max-model-len 262144, MTP speculative decoding (2 tokens), ~/ai/services/qwen35/compose.yaml, ~/ai/services/qwen35/.env (+8 more)

### Community 51 - "TensorFold Hermes Profile Cutover"
Cohesion: 0.16
Nodes (19): DGX Spark Single-Node Qwen 3.8 Flash Next TensorFold Replacement Tutorial, Main config background review setting, builder profile, Drain old-model builder/orchestrator work, HERMES_CONFIG_OK, hermes/profile config check, hermes-dashboard, hermes-gateway, hermes-serve services, Live-state snapshot: TensorFold already running, vllm-fn-tp1 stopped (+11 more)

### Community 52 - "Jev and Laya Decision Models"
Cohesion: 0.23
Nodes (15): Jev (TypeSafe AI hosted decision API), Laya Local Decision Model, RTX PRO 5000 Jev Agent Decision Evaluation Tutorial, hermes-jev-skills Repository, JEV-as-a-Judge Cascade, Shadow-to-Active Progression, Jev Windows Trial (Playground then API), RTX PRO 5000 Laya Decision Model Tutorial (+7 more)

### Community 53 - "Ops Guide Model Shelf"
Cohesion: 0.13
Nodes (17): DeepSeek V4 Flash SparkInfer derivative, NVIDIA/dgx-spark-playbooks, First working stack (Hermes -> LiteLLM -> vLLM -> Qwen3.6), Gemma 31B (hold), nvidia/Gemma-4-26B-A4B-NVFP4, dgx-spark-playbooks issue #89 (malformed tool calls, 46 tools), Laguna S 2.1 NVFP4 + DFlash, Ling 3.0 Flash (hold) (+9 more)

### Community 54 - "Spark Twitter Bookmarks Research"
Cohesion: 0.15
Nodes (12): Capacity acceptance metrics, dgx-spark-twitter-bookmarks-analysis, Hermes MEMORY.md and USER.md, Model evidence matrix, Post-OOM low-power state, Candidate reproduction checklist, spark-fast alias, Claude Code (+4 more)

### Community 55 - "Add Desktop Qwen and Patches"
Cohesion: 0.20
Nodes (7): config_paths(), main(), transform(), endpoint(), lmstudio_references(), main(), transform()

### Community 56 - "Additional Services Controller"
Cohesion: 0.19
Nodes (12): DGX Spark Additional Services Controller, aux-services controller, Dashboard Command Center, restore.list drain snapshot, Dashboard Command Center Refresh / sparkdash-recover, DGX Spark sparkDash Tunnel scheduled task, DGX Spark sparkDash Monitoring Tutorial, FirstSpark Standalone LiteLLM Operations (+4 more)

### Community 57 - "Gemma 4 Tutorial and Ops Guides"
Cohesion: 0.18
Nodes (15): DGX Spark Gemma 4 Models Tutorial, gemma4-26b-a4b (nvidia/Gemma-4-26B-A4B-NVFP4), gemma4-31b (nvidia/Gemma-4-31B-IT-NVFP4), prepare-gemma4-profile.sh, Static Hermes menu entry for stopped profiles, Spark Hermes Setup Runbook, Chaos test (reboot, stop vLLM, sleep workstation), code route with fallback to qwen3.6-35b-a3b (+7 more)

### Community 58 - "Model Installation and Switching"
Cohesion: 0.17
Nodes (13): DGX Spark Model Installation And Switching Guide, DeepSeek V4 Flash SparkInfer isolated appliance, Hermes discover_models and model --refresh, spark-model lanes.d lane definitions, Ling 3.0 Flash SGLang (experimental), Dynamic lmstudio:<model> lane, qwen27-dflash (Qwen 3.6 27B NVFP4 + DFlash), spark-model lane manager (+5 more)

### Community 59 - "Ops Guide Hermes LiteLLM Wiring"
Cohesion: 0.16
Nodes (15): Hermes, hermes config set, Hermes custom endpoint config (127.0.0.1:4000/v1, qwen3.6-35b-a3b, 131072 ctx), ~/.hermes/.env, .hermes/.env.before-remote backup, HERMES_OK test, LITELLM_KEY, LITELLM_OK test (+7 more)

### Community 60 - "Obsidian Replicas and Sync"
Cohesion: 0.20
Nodes (14): LLMWiki Vault, Obsidian headless replicas on FirstSpark (LLMWiki, Personal-Sync), Personal-Sync vault at F:\Vaults\Personal-Sync, Bidirectional SHA-256 sync verification, Personal-Sync moved out of Google Drive, Official obsidian-headless Sync replicas on FirstSpark, obsidian-sync-llmwiki.service, obsidian-sync-personal.service (+6 more)

### Community 62 - "Ops Guide ODS LiteLLM"
Cohesion: 0.16
Nodes (14): local.yaml.before-spark-fast backup, ~/ods/config/litellm/local.yaml, ods enable litellm, ods-litellm (ODS LiteLLM), ollama port 11434, lmstudio port 1234 (llmster), sglang-lab port 30000, litellm port 4000 (ODS) (+6 more)

### Community 63 - "TensorFold Alias Checks"
Cohesion: 0.23
Nodes (13): qwen38-tensorfold-second alias, qwen38-tp1-second alias, chat_template_kwargs enable_thinking False, LITELLM_DISCOVERY_OK, OLD_ALIAS_FAIL_CLOSED_OK, TENSORFOLD_LITELLM_OK, TENSORFOLD_RAW_OK raw check, LITELLM_STREAM_OK (+5 more)

### Community 64 - "Qwen Image BFS Body Swap"
Cohesion: 0.28
Nodes (11): BFS Best Face Swap repository, bfs_body_swap_v1.0_qwen_2.1 LoRA, body_swap prompt, RTX PRO 5000 Qwen Image 2.1 BFS Body Swap Windows Tutorial, LoraLoaderModelOnly node, Reference image preparation, bfs_head_v1.1_alternative_qwen_2.1 LoRA, bfs_head_v1.1_qwen_2.1 LoRA (+3 more)

### Community 65 - "LongCat Video Avatar"
Cohesion: 0.20
Nodes (14): FlashAttention, LongCat-Video-Avatar 1.5, PyTorch, Whisper Large V3, WSL2 Ubuntu, LongCat Video Avatar 1.5 Workstation Feasibility Tutorial, One-clip 480p smoke test, LongCat pass criteria (+6 more)

### Community 66 - "Index Qwen Migration Evidence"
Cohesion: 0.17
Nodes (15): Qwen Spark Migration Evidence 2026-10-12, Admission port 1235, aux-services service/port catalog, Desktop contention, runner reload and NVIDIA TDR evidence, FirstSpark, Four 240K-input functional/capacity test (strict zero-swap gate failed 176KiB), Fresh Brief (Windows Ollama, 8 AM/8 PM IST), LM Studio stopped/disabled with rollback assets preserved (+7 more)

### Community 68 - "SecondSpark Qwen Lane"
Cohesion: 0.16
Nodes (13): Known local blockers before dual-node launch, Optional Qwen TP1 lane on SecondSpark, SecondSpark Qwen v0.30 Attempt 1 (failed safety), SecondSpark Qwen v0.30 Attempt 2 (passed), Second Spark read-only baseline checks, SecondSpark, Saved Hermes profiles (main/builder/orchestrator/researcher/creator/reviewer), ED25519 host-key trust repair (no StrictHostKeyChecking=no) (+5 more)

### Community 69 - "TensorFold Download and Cache Fix"
Cohesion: 0.26
Nodes (13): ~106 GiB checkpoint download, sudo chown -R of Vontra cache and .locks, PermissionError Errno 13 on root-owned .lock files, VONTRA_CACHE_OWNERSHIP_OK gate, Hugging Face cache, Host hf CLI (~/.hf-cli/venv), TensorFold image (~11 GB compressed, ~24 GB in Docker), Hugging Face .locks directory (+5 more)

### Community 70 - "Qwen 3.8 Flash Next v0.30"
Cohesion: 0.21
Nodes (12): 100-turn long-agent tool gate, DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial, v0.30 fixed launch values, Upstream issue #48 long-agent premature stop, Memory, kernel, and preemption gate, memwatch memory watchdog, File-backed PLE mmap cache, SecondSpark preflight check (+4 more)

### Community 71 - "EVIE Retrieval Tutorial"
Cohesion: 0.22
Nodes (11): Tencent EVIE Visual Retriever, OpenMontage, PyTorch + ColPali Route, RTX PRO 5000 EVIE Visual Document Retrieval Tutorial, Multi-Vector Index Cost, EVIE Windows PowerShell Trial, Social Capture Local AI Model Exploration Guide, Per-experiment record template (+3 more)

### Community 72 - "Provider Rename Config Targets"
Cohesion: 0.26
Nodes (13): Model and provider names (naming reference), ~/.hermes/auth.json credential under custom:local-models and custom:spark-fast, ~/.hermes/config.yaml and profiles/*/config.yaml, Kaggle Learning Center isolated Hermes (custom:local-models / qwen3.6-35b-a3b), LiteLLM ~/ai/services/litellm/config.yaml, LiteLLM spark-fast hidden alias (router_settings.model_group_alias, hidden: true), Hermes provider local-models / custom:local-models (formerly spark-fast / custom:spark-fast), LiteLLM/Hermes model qwen3.6-35b-a3b (formerly spark-fast) - Qwen 3.6 35B-A3B NVFP4 (+5 more)

### Community 73 - "TensorFold v0.30 Retirement"
Cohesion: 0.29
Nodes (11): OLD_BACKEND_SECRET_REMOVED_OR_ABSENT, nvidia/Qwen3.8-Flash-Next-NVFP4 checkpoint (~124 GB), Old v0.30 PLE cache ple_mmap_v030 (~48 GB, root-owned), Dual-Spark qwen38-nvfp4 alias/recipe, ~/backups/qwen38-v030-retirement/<stamp>, rm -rI interactive deletion, Rollback after deletion (re-download NVIDIA checkpoint, rebuild PLE), LiteLLM runtime.env (+3 more)

### Community 74 - "Realtime Conversation Video"
Cohesion: 0.29
Nodes (9): AivisSpeech TTS, LTX-2.5, OpenAI-compatible input_audio LLM, diffusers-movie-server gateway, Realtime Conversation Video Windows Feasibility Tutorial, Time to first audio/frame and chunk metrics, Realtime_Conversation_Video client, Realtime_Narration_Video renderer (+1 more)

### Community 75 - "GLM Shim Server"
Cohesion: 0.18
Nodes (3): BridgeServer, main(), request()

### Community 76 - "LM Studio Qwen Loader"
Cohesion: 0.17
Nodes (6): args, client, config, options, require, sdkDirectory

### Community 77 - "Hermes Provider Migration Script"
Cohesion: 0.35
Nodes (10): atomic_write(), digest(), explicit_desktop_references(), inside(), main(), qwen_desktop(), rollback(), transform() (+2 more)

### Community 79 - "Spark Unified Memory Co-Residency"
Cohesion: 0.18
Nodes (8): Co-residency acceptance test matrix, Qwen vLLM + LM Studio Nemotron co-residency, DGX Spark 128 GB unified LPDDR5X pool (273 GB/s), DFlash2 speculative decoding (draft-dflash), measure_interactive_speed.py / probe_qwen.py / probe_hermes_production.py, native-config.json / run_native_qwen.py launcher, Q4_K_M target + Q4 DFlash draft7 conf 0.1 (live, 2x262K), Q5 + DFlash2 draft3 (previous, 4x262K)

### Community 80 - "Second Spark Readiness"
Cohesion: 0.27
Nodes (8): NemoClaw two-Spark DeepSeek V4 Flash recipe, DGX Spark Second Node And Dual Spark Readiness Research 2026-08-20, Dual Spark power budget, Recommended software versions (2026-08-20), DeepSeek-R1 671B, NemoClaw, Qwen3-235B-A22B NVFP4, UPS

### Community 81 - "Checklist Codex Tasks"
Cohesion: 0.18
Nodes (11): VoiceStudio v0.5.0 (D:\Apps\VoiceStudio), Blank Capture overlay recovery, Codex project completion audit (22 Aug 2026), Codex task: Connect Obsidian vaults to DGX Spark, Codex task: Create setup task checklist, Codex task: Install VoiceStudio portable, Parakeet dictation, Codex task: Plan Spark LM Link routing (+3 more)

### Community 82 - "Desktop Qwen Naming"
Cohesion: 0.18
Nodes (10): Hermes provider desktop-qwen, Desktop server accepts any model name (qwen3.8:27b-q4_k_m still works), Fresh Brief (keeps sending qwen3.8:27b-q4_k_m), qwen3.8-27b-desktop (formerly qwen3.8:27b-q4_k_m) Desktop Qwen 3.8 27B, 240K strict zero-swap gate failure and reviewed exception, configure_hermes_native.py catalog publisher, Hermes named-provider timeout patch (patch_hermes_timeouts.py), qwen38-27b-spark (Unsloth UD-Q5_K_XL, native llama.cpp, provider spark-qwen38) (+2 more)

### Community 83 - "SparkFast vs Qwen27B Capacity"
Cohesion: 0.36
Nodes (8): qwen38-native / qwen38-admission locked inventory pair, qwen3.6-35b-a3b (Qwen 3.6 35B-A3B NVFP4 alias, formerly spark-fast), SparkFast And Qwen 27B Capacity Comparison, fattn F16 temporary K/V buffer (~4 GiB), October 1 five-to-eight sequence change, Reviewed pressure qualification (13 Oct), spark-qwen38 native Qwen27B llama.cpp service (Q5 weights, Q4 KV), Strict global-swap gate failure (240K test)

### Community 84 - "Muse Glimmer and Lightning Tutorials"
Cohesion: 0.33
Nodes (9): DGX Spark Muse Glimmer 30B Readiness Tutorial, Muse-Glimmer-30B-assistant DFlash (optional), muse-glimmer (meta-models/Muse-Glimmer-30B), prepare-muse-glimmer.sh, DGX Spark Nemotron 3.5 Lightning Tutorial, DSpark speculative-decoding assistant, MiaAI-Lab SGLang Nemotron 3.5 recipe, nemotron35-lightning (NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4) (+1 more)

### Community 85 - "ODS Phase 2 Fine-Tuning"
Cohesion: 0.33
Nodes (9): Phase 2 - Fine-tuning and SLM engineering, Phase 2 — SLM and Fine-Tuning, LLaMA Factory, NVIDIA NeMo, Unsloth, NeMo, Register adapter under new LiteLLM alias, PyTorch/PEFT LoRA path (+1 more)

### Community 86 - "Ops Guide Store Layout"
Cohesion: 0.24
Nodes (9): ~/ai/stores symlink layout, ~/.config/dgx-spark, ~/.config/dgx-spark/env, dgx-space, ~/.cache/huggingface, HF_HOME, ~/.lmstudio/models, ~/.cache/nim (+1 more)

### Community 87 - "TensorFold Comparison Profiles"
Cohesion: 0.38
Nodes (10): Compared probe profiles: spark-fast, qwen38-nvfp4, qwen38-fp8, glm53-flash, glm53-flash-mtp-850k, glm53-flash-v2, glm53-flash-dflash-500k, deepseek41-bringup-131k, deepseek41-flash, qwen38-tensorfold-second, comparison-all-with-tensorfold.md, Concurrency C1 -> C2 -> C4 at 512 tokens, Context ladder 30K -> 100K -> 195K -> 235K, frontier-model-probe.py standardized qualification, TENSORFOLD_FULL_RAW_PASS, IDENTITY_TEST_OK, QUALITY_TEST_OK, TOOL_CALL_OK, VISION_TEST_OK, CONTEXT_LADDER_OK, CONCURRENCY_LADDER_OK, ~/frontier-results/qwen38-tensorfold-second/ (+2 more)

### Community 88 - "sparkDash Monitoring"
Cohesion: 0.20
Nodes (7): sparkDash acceptance checklist, Authenticated model probe on port 8100, docker-compose.local.yml override, Dashboard Command Center sparkdash-recover refresh, DGX Spark sparkDash Monitoring Tutorial, Windows SSH tunnel to 5555, SSH forward to Spark loopback LM Studio

### Community 90 - "Perplexity Portable Computer"
Cohesion: 0.39
Nodes (8): Perplexity Portable Computer, PPLX 27B, Cloud step escalation and credits, Original DGX Spark-only launch framing, RTX PRO 5000 Perplexity Portable Computer Tutorial, Settings > Local Inference, Personal Computer vs Portable Computer, Qwen 27B (Perplexity app)

### Community 91 - "Social Capture Pipeline"
Cohesion: 0.42
Nodes (7): Social Capture, Social Capture task provenance table, Social Capture Action Queue.md, Social Capture Pipeline, Queue lifecycle and monthly archive, Social Capture desktop dashboard, WhatsApp backlog importer

### Community 92 - "FirstSpark Standalone LiteLLM"
Cohesion: 0.22
Nodes (9): FirstSpark Standalone LiteLLM Operations, FirstSpark ODS retirement (2026-09-22), ODS-to-standalone LiteLLM rollback archive (20260922-142725), spark-litellm container (LiteLLM at 127.0.0.1:4000), spark-model-net Docker network, JIT loading and Auto-Evict, nvidia/nemotron-3.5-lightning@q4_k_m (24.52 GB), spark-model manager (list, status, use <lane>, lmstudio:<model-key>, lanes.d) (+1 more)

### Community 93 - "Unchanged Internal spark-fast Names"
Cohesion: 0.28
Nodes (7): Operations scripts (spark-frontier lanes, spark-gpu-audit, spark-clear-orphans, sparkDash), ~/ai/services/qwen35/compose.yaml, Spark Qwen 27B service, vllm-spark-fast Docker container (unchanged), wait-for-spark-fast startup helper (~/.local/bin, unchanged), qwen38-admission proxy (port 1235, four 262K slots), qwen38-native llama-server worker (port 1236)

### Community 95 - "Workstation Inference Measurement"
Cohesion: 0.39
Nodes (8): RTX PRO 5000 Local Inference Measurement Tutorial, llama-server Windows CUDA build, Inference measurement decision record, MTP draft speculative decoding, One-GGUF experiment, Quantized KV cache (-ctk/-ctv), sudoingX llama.cpp flags X post, Time to first token

### Community 98 - "TensorFold Safety Checks"
Cohesion: 0.52
Nodes (6): check_safety function (memory monitor, LiteLLM/TensorFold running, kernel log), TENSORFOLD_100K_MEMORY_PASS ~100K context gate, Kernel NV_ERR_NO_MEMORY / Out of memory / NVRM Xid check, Qwen3.8-Flash-Next is now LIVE! on port 8888, tools/needle.py (tf-second-100k 130000), 5. Start TensorFold and check the raw SecondSpark API

### Community 99 - "YouTube and Social Capture Helpers"
Cohesion: 0.29
Nodes (7): ylc-searxng, YouTube Learning Center, Hermes social_capture_vision helper, Hermes youtube_analysis helper, Social Capture plugin, spark-fast vLLM served model name on port 8000 (unchanged), YLC_MODEL_PROFILE=local-spark-fast (unchanged)

### Community 101 - "Agent Memory and Crawl Tools"
Cohesion: 0.33
Nodes (6): Crawl4AI, Firecrawl, Mem0, Multica, Paperclip, Tool overlap matrix

### Community 102 - "Frontier Vision Test"
Cohesion: 0.33
Nodes (6): Blue Circles (2, top-right), Vision Check: Shape, Color, Count, Position, Frontier Model Vision Test (image), Green Squares (3, bottom-left), Red Triangle (1, top-left), Yellow Star (1, bottom-right)

### Community 104 - "Provider Models Cache Clearing"
Cohesion: 0.40
Nodes (4): FirstSpark LiteLLM gateway (127.0.0.1:4000), /model --refresh (Hermes picker refresh), provider_models_cache.json (~/.hermes and profiles/*), spark-fast hostname (Docker network, http://spark-fast:8000/v1, unchanged)

### Community 105 - "Native Qwen HF Download Script"
Cohesion: 0.40
Nodes (4): HF_HUB_DISABLE_IMPLICIT_TOKEN, HF_XET_CACHE, HF_XET_NUM_CONCURRENT_RANGE_GETS, download_native_qwen.sh script

### Community 106 - "Nemotron 3 Nano Omni"
Cohesion: 0.83
Nodes (4): DGX Spark Nemotron 3 Nano Omni Tutorial, local/vllm-nemotron3-omni:v0.20.0 derived audio image, nemotron3-omni (Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4), prepare-nemotron3-omni.sh

### Community 107 - "Local Setup Dashboard"
Cohesion: 0.50
Nodes (3): Local Setup Dashboard, Local Setup Field Guide Dashboard Template, Markdown Folder Import And Progress JSON

### Community 108 - "local-models LiteLLM Aliases"
Cohesion: 0.50
Nodes (4): Other LiteLLM aliases on local-models (qwen27-dflash, nemotron3-omni, qwen38-tensorfold-second), qwen38-tensorfold-second (Qwen3.8-Flash-Next, container qwen38-flash-next-tf), qwen38-tp1-second retired alias (api_base 127.0.0.1:1), Tutorial command updates (Gemma 4, Muse Glimmer, Nemotron Omni, Nemotron 3.5, TensorFold)

### Community 114 - "Ollama Context Reload Fix"
Cohesion: 0.67
Nodes (3): Context-size mismatch reloads (Fresh Brief 16K vs Hermes 262K), Ollama env fix: 131072 context, q8_0 KV, parallel 1, Ollama GUI 256K context slider overrides OLLAMA_CONTEXT_LENGTH

## Ambiguous Edges - Review These
- `DFlash2` → `qwen27-dflash alias`  [AMBIGUOUS]
  RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial.md · relation: conceptually_related_to
- `spark-fast alias` → `Background review routed to SecondSpark`  [AMBIGUOUS]
  hermes-qwen-desktop-lag-handoff-2026-09-28.md · relation: conceptually_related_to
- `Inference vs Windows display GPU contention (Sept 28 measurement)` → `October 6 NVIDIA TDR during Qwen serving`  [AMBIGUOUS]
  Qwen Spark Migration Evidence 2026-10-12.md · relation: conceptually_related_to
- `Pinned native llama.cpp CUDA runtime on FirstSpark` → `local-models Hermes provider (formerly spark-fast)`  [AMBIGUOUS]
  Task Checklist.md · relation: conceptually_related_to
- `SearXNG (port 8888)` → `qwen38-tensorfold-second (TensorFold Qwen3.8-Flash-Next on SecondSpark 192.168.100.11:8888)`  [AMBIGUOUS]
  Local Setup Index.md · relation: conceptually_related_to

## Knowledge Gaps
- **307 isolated node(s):** `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_CACHE`, `HF_XET_NUM_CONCURRENT_RANGE_GETS`, `Baseline .env Values`, `Host-Side Source Tests` (+302 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 546 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **27 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Qwen 3.8 27B Spark LM Studio Migration Tutorial` connect `spark-fast Benchmarks and Co-Residency` to `DGX Spark Aug 2026 Deployment Research`, `SecondSpark Qwen Lane`, `Spark vs Workstation Model Placement`, `Hermes Bootstrap and Boot Probes`, `Always-On Hermes on Spark`, `Native Qwen Runner and Diagnostics`, `Hermes Provider Migration Script`, `Model Tutorials Index and Runtimes`, `Qwen 3.8 Flash Next Dual-Node`, `Fresh Brief and Qwen 3.8 Intake`, `sparkDash Monitoring`?**
  _High betweenness centrality (0.188) - this node is a cross-community bridge._
- **What connects `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_CACHE`, `HF_XET_NUM_CONCURRENT_RANGE_GETS` to the rest of the system?**
  _307 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `DGX Spark Aug 2026 Deployment Research` be split into smaller, more focused modules?**
  _Cohesion score 0.06392405063291139 - nodes in this community are weakly interconnected._
- **Why does `Local Setup Index` connect `Local Setup Index Note Links` to `Index Architecture and Decisions`, `Index Model Inventory`, `Desktop Qwen Runbook`, `spark-fast NVFP4 Memory Profile`, `Index Current Confirmed State`, `Ops Guide State Capture`, `Checklist Dual-Spark Frontier Lane`, `Frontier Hot-Swap and Routing`, `Index Canonical Decisions`, `Index Done Sections`, `TensorFold Hermes Profile Cutover`, `Additional Services Controller`, `Gemma 4 Tutorial and Ops Guides`, `Model Installation and Switching`, `Index Qwen Migration Evidence`, `SparkFast vs Qwen27B Capacity`, `Muse Glimmer and Lightning Tutorials`, `Nemotron 3 Nano Omni`, `Index Done and Exclusions`?**
  _High betweenness centrality (0.130) - this node is a cross-community bridge._
- **Should `Local Setup Index Note Links` be split into smaller, more focused modules?**
  _Cohesion score 0.08076923076923077 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `DFlash2` and `qwen27-dflash alias`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `spark-fast alias` and `Background review routed to SecondSpark`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._