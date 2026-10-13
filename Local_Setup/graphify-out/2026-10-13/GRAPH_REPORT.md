# Graph Report - Local_Setup  (2026-10-13)

## Corpus Check
- 138 files · ~298,677 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 16 file(s) not represented in the graph (top: .log 6, .service 4, (none) 1)

## Summary
- 1740 nodes · 5477 edges · 82 communities (68 shown, 14 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 204 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0d9b1ddf`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- dgx-spark-twitter-bookmarks-analysis
- Qwen 3.8 27B Native Spark Setup Tutorial
- Hermes Agent
- DGX Spark Qwen NVFP4 Memory And Startup Optimization Research
- LM Studio
- finish_native_install.py
- VoiceStudio Risk Audit
- app.js
- Ollama
- local-ai-tooling-catalog-and-rollout
- RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial
- LiteLLM
- FirstSpark
- DGX Spark Frontier Model Hot-Swap And Routing Guide
- DGX Spark ODS Playbook and Model Roadmap
- frontier_model_probe.py
- DGX Spark Additional Models And Convenience Runtimes Research
- pathlib
- vLLM
- json
- download_native_parallel.py
- Hermes + Qwen Desktop Lag Consolidated Investigation And Handoff
- probe_qwen_long.py
- continue_native_reviewed.py
- MiniMax H3 Windows Video Exploration Tutorial
- DGX Spark Multi-Model Runtime Research
- time
- DGX Spark Dual-Node Community Frontier Models Runbook
- .run_fake
- personal-hermes-obsidian-multinode-design
- Nemotron 3.5 Lightning 30B-A3B
- RTX PRO 5000 Workstation
- Social Capture Local AI Model Exploration Guide
- DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial
- local-ai-architecture-research
- RTX PRO 5000 Laya Decision Model Tutorial
- PressureTests
- RTX PRO 5000 Local Inference Measurement Tutorial
- os
- spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)
- DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial
- configure_hermes.py
- DGX Spark Operations Setup Guide
- Markdown Backed Interactive Dashboard Research
- hashlib
- ODS
- glm-reasoning-shim.py
- DGX Spark Additional Model Tutorials Index
- DGX Spark Nemotron 3 Nano Omni Tutorial
- LongCat Video Avatar 1.5 Workstation Feasibility Tutorial
- DraftConfigurationTests
- DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20
- Sequence 8J — Social Capture Windows Local-Model Exploration
- Realtime Conversation Video Windows Feasibility Tutorial
- load_qwen.mjs
- MemoryReadinessTests
- TimeoutTests
- Social Capture
- ResetStartLimitsTests
- test_named_custom_timeout_resolution.py
- ProductionWireTests
- CatalogTests
- Qwen 3.8 27B
- Frontier Model Vision Test (image)
- ComfyUI
- download_native_qwen.sh
- TransformTests
- Fresh Brief Spark Qwen Migration Requirements
- llama.cpp
- Qwen 3.8 27B DFlash2 Speed Upgrade
- Local Setup Index
- Hermes LM Link And Workstation Model Routing Research
- Task Checklist
- DGX Spark And RTX 5000 Workstation Model Placement Research
- DGX Spark Ollama And ODS Tutorial
- Qwen 3.8 27B Spark LM Studio Migration Tutorial
- Local Setup Field Guide Dashboard Template
- CLAUDE.md

## God Nodes (most connected - your core abstractions)
1. `Hermes Agent` - 138 edges
2. `Local Setup Index` - 117 edges
3. `Task Checklist` - 112 edges
4. `LiteLLM` - 102 edges
5. `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)` - 91 edges
6. `vLLM` - 87 edges
7. `LM Studio` - 87 edges
8. `Ollama` - 86 edges
9. `RTX PRO 5000 Workstation` - 84 edges
10. `ODS` - 80 edges

## Surprising Connections (you probably didn't know these)
- `Unified 524K Q8 KV Alternative` --semantically_similar_to--> `Two-Slot 262K Context and Memory Plan`  [INFERRED] [semantically similar]
  Qwen Spark Migration/LONG-PROBE-GUARDS.md → Qwen 3.8 27B Spark Serving Options.md
- `request()` --indirect_call--> `error()`  [INFERRED]
  .setup-dashboard/test_writer.py → Qwen Spark Migration/admission_proxy.py
- `Qwen Spark Migration Publication Status` --references--> `Hermes spark-qwen38 Provider (qwen38-27b-spark)`  [INFERRED]
  Qwen Spark Migration/DECISION-README.md → Qwen 3.8 27B Native Spark Setup Tutorial.md
- `Four-Slot Q8 Memory Estimate` --references--> `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)`  [EXTRACTED]
  Qwen Spark Migration/LONG-PROBE-GUARDS.md → DGX Spark Additional Model Tutorials Index.md
- `DGX Spark Additional Services Controller` --references--> `Local Setup Dashboard`  [EXTRACTED]
  DGX Spark Additional Services Controller.md → .setup-dashboard/template.html

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
- **Spark Hermes Control Plane** — ent_hermes, always_on_hermes_on_dgx_spark_hermes_serve, always_on_hermes_on_dgx_spark_hermes_gateway, ent_litellm, ent_tailscale, ent_hermes_desktop [EXTRACTED 1.00]
- **Spark Inference Engine Learning Ladder** — ent_llama_cpp, ent_vllm, ent_sglang, ent_tensorrt_llm, ent_nim [EXTRACTED 1.00]
- **Workstation Ollama reached from Spark Hermes via Tailscale Serve** — ent_ollama, ent_tailscale_serve, ent_desktop_ollama_provider, ent_hermes, ent_qwen_3_8_27b, ent_rtx_pro_5000_workstation [EXTRACTED 1.00]
- **Mutually exclusive dual-node frontier lanes on port 8100** — dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_baseline, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_fp8_comparison, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_mtp_850k_accepted, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_deepseek_recipe, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_port_8100 [INFERRED 0.85]
- **Frontier Lane Hot-Swap Lifecycle** — ent_aux_services, ent_spark_frontier, ent_spark_model, ent_spark_fast, dgx_spark_dual_node_community_frontier_models_runbook_common_drain_rollback, dgx_spark_dual_node_community_frontier_models_runbook_litellm_hermes_aliases [INFERRED 0.85]
- **Frontier qualification evidence pipeline** — dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_probe_suite, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_evidence_suite, dgx_spark_frontier_model_qualification_results_headline_table, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_perf_results, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_vs_fp8_results, ent_spark_frontier_check [INFERRED 0.85]
- **Gateway-routed logical aliases with controlled model swap** — dgx_spark_twitter_bookmarks_analysis_safe_swap_controller, local_ai_architecture_research_hotswap_as_routing, personal_hermes_obsidian_multinode_design_gateway_hot_swap_policy, ent_litellm, personal_hermes_obsidian_multinode_design_logical_routes [INFERRED 0.85]
- **Unified-memory safety qualification gates (MemAvailable >=10 GiB, no NV_ERR_NO_MEMORY)** — dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_100k_memory_gate, dgx_spark_single_node_qwen_3_8_flash_next_v0_30_tutorial_memory_kernel_gate, dgx_spark_sparkdash_monitoring_tutorial_coexistence_decision, ent_unified_memory_128gb [INFERRED 0.85]
- **VoiceStudio Readiness Failure Chain** — voicestudio_risk_audit_shutdown_latch, voicestudio_risk_audit_false_negative_health, voicestudio_risk_audit_no_deliverable_baseline, voicestudio_risk_audit_lifecycle_confusion [INFERRED 0.85]

## Communities (82 total, 14 thin omitted)

### Community 0 - "dgx-spark-twitter-bookmarks-analysis"
Cohesion: 0.06
Nodes (57): 0xSero DeepSeek V4 Flash SparkInfer, DGX Spark Aug 2026 Model Deployment Research, Evidence Labels Standard, Hermes-Ready Tool Contract, NVIDIA Playbook Issue #89 Tool-Call Quant Bisect, Local Acceptance Benchmark Contract, MiaAI Qwen3.6 27B DFlash Profile, NVIDIA Qwen3.6 35B First-Party Control (+49 more)

### Community 1 - "Qwen 3.8 27B Native Spark Setup Tutorial"
Cohesion: 0.12
Nodes (21): DFlash Speculative Decoding, MTP speculative decoding, Unsloth Qwen3.8-27B GGUF, Auxiliary Services Locked Inventory Entries, Qwen 3.8 27B Native Spark Setup Tutorial, Named-Provider Timeout Patch for Hermes, qwen38-admission Service, qwen38-native Service (llama-server worker) (+13 more)

### Community 2 - "Hermes Agent"
Cohesion: 0.14
Nodes (28): Workstation-local desktop-files Profile, Discord Primary Phone Interface, Always-On Hermes on DGX Spark, hermes gateway, hermes serve, Always-On Hermes Rollout Plan, Hermes custom_providers mapping, Controlled LiteLLM and Hermes promotion (Steps 14-24) (+20 more)

### Community 3 - "DGX Spark Qwen NVFP4 Memory And Startup Optimization Research"
Cohesion: 0.16
Nodes (11): Co-residency acceptance test matrix, Qwen vLLM + LM Studio Nemotron co-residency, SparkFast current state 2026-10-12, DGX Spark Qwen NVFP4 Memory And Startup Optimization Research, Five-session co-resident profile 2026-09-26, Historical verified 18 GiB profile, LM Studio JIT, idle TTL and Auto-Evict, Scheduler controls (max_model_len, max_num_seqs, max_num_batched_tokens) (+3 more)

### Community 4 - "LM Studio"
Cohesion: 0.21
Nodes (12): DGX Spark LM Studio And LM Link Tutorial, JIT loading and auto-eviction, lms headless CLI / llmster daemon, lmstudio-link.service user unit, Qwen 3.8 27B LM Studio migration pointer, LM Studio, Three-part comparison prompt and scorecard, RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial (+4 more)

### Community 5 - "finish_native_install.py"
Cohesion: 0.05
Nodes (37): Admission, create_app(), chat(), error(), health(), json_call(), models(), recover_loop() (+29 more)

### Community 6 - "VoiceStudio Risk Audit"
Cohesion: 0.07
Nodes (48): OmniVoice TTS Model, Parakeet TDT 0.6B v3, VoiceStudio, Whisper, Codex Project Completion Audit (22 Aug 2026), VoiceStudio v0.5.0 Portable Install, v0.5.0 Active Beta Contract Churn, API/Network Sharing Auth and TLS (+40 more)

### Community 7 - "app.js"
Cohesion: 0.10
Nodes (44): applyLibrarySnapshot(), closeDrawer(), decodeSafe(), download(), drawTask(), empty(), exportHTML(), exportProgress() (+36 more)

### Community 8 - "Ollama"
Cohesion: 0.09
Nodes (26): gpt-oss 20B, Ollama, Open WebUI, ODS Workstation Ollama Integration Research, Open WebUI to Native Ollama Connector, ODS Dashboard, Workstation ods-litellm (config\litellm\local.yaml), ODS llama-server (+18 more)

### Community 9 - "local-ai-tooling-catalog-and-rollout"
Cohesion: 0.07
Nodes (39): Addy Osmani Agent Skills, Anthropic Claude Skills, AutoGen, Buffer MCP, Caveman, Claude Design, Composio, Compound Engineering plugin (+31 more)

### Community 10 - "RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial"
Cohesion: 0.19
Nodes (18): Qwen3-VL 8B text encoder, Qwen Image 2.1, BF16 quality comparison lane, RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial, INT8 ConvRot baseline lane, Isolated portable ComfyUI install, Official Qwen Image 2.1 image-edit workflow, Official Qwen Image 2.1 T2I workflow (+10 more)

### Community 11 - "LiteLLM"
Cohesion: 0.17
Nodes (11): Stable Capability Model Aliases, DeepSeek LiteLLM Promotion, Proposed LiteLLM/Hermes frontier aliases, Cold-route rejection test, LiteLLM frontier timeouts, LiteLLM, Baidu Unlimited-OCR, spark-litellm Compose service (+3 more)

### Community 12 - "FirstSpark"
Cohesion: 0.12
Nodes (25): NVIDIA Driver CDI Recovery, Dual-Spark Usage Options, DGX Spark Dual-Node Configuration And Operations Reference, NCCL all_gather_perf Result, NCCL Test Procedure, CX-7 Physical Topology, Software Baseline Audit 2026-09-18, Qwen fixed cluster values (+17 more)

### Community 13 - "DGX Spark Frontier Model Hot-Swap And Routing Guide"
Cohesion: 0.11
Nodes (30): aux-services Allow-List Entry Format, Dashboard Command Center Service Mapping, DGX Spark Additional Services Controller, Drain And Restore Workflow, Refresh Bounded Recovery Path, DGX Spark sparkDash Tunnel Scheduled Task, Common Drain And Universal Rollback, Frontier LiteLLM/Hermes Aliases (+22 more)

### Community 14 - "DGX Spark ODS Playbook and Model Roadmap"
Cohesion: 0.11
Nodes (29): Engine Decisions, DGX Spark ODS Playbook and Model Roadmap, Operational context profiles (interactive/batch/long/huge-experimental), Phase 1 - Serving and inference engineering, Phase 2 - Fine-tuning and SLM engineering, Phase 3 - FDE portfolio applications, Phase 4 - Agent security, not agent sprawl, NVIDIA DGX Spark playbook catalog (44 playbooks) (+21 more)

### Community 15 - "frontier_model_probe.py"
Cohesion: 0.25
Nodes (24): atomic_json(), capture_record(), chat_content(), cmd_chat(), cmd_compare(), cmd_concurrency(), cmd_context(), cmd_identity() (+16 more)

### Community 16 - "DGX Spark Additional Models And Convenience Runtimes Research"
Cohesion: 0.15
Nodes (17): Unverified Or Deferred Items, DGX Spark Additional Models And Convenience Runtimes Research, Gemma 4 26B A4B vLLM Spark Recipe, Gemma 4 31B Experimental Profile, LM Studio JIT Loading And Auto-Evict, Machine State Snapshot 2026-08-14, Outdated ODS Ollama Extension, Nemotron Omni vLLM 0.20 Recipe (+9 more)

### Community 17 - "pathlib"
Cohesion: 0.13
Nodes (3): main(), qualification_environment(), request()

### Community 18 - "vLLM"
Cohesion: 0.08
Nodes (40): Known local blockers before dual-node launch, Official vLLM Qwen3.8 Flash Next FP8 recipe, Optional Qwen TP1 lane on SecondSpark, SecondSpark Qwen TensorFold qualification, NemoClaw two-Spark DeepSeek V4 Flash recipe, Second Spark read-only baseline checks, 100K-token context memory gate, LiteLLM alias qwen38-tensorfold-second (+32 more)

### Community 19 - "json"
Cohesion: 0.14
Nodes (12): digest(), main(), child(), send(), guard_socket_connector(), main(), production_python_command(), save_failure() (+4 more)

### Community 20 - "download_native_parallel.py"
Cohesion: 0.16
Nodes (18): atomic_json(), Canceled, digest(), download_file(), transfer(), fetch_range(), main(), probe_ranges() (+10 more)

### Community 21 - "Hermes + Qwen Desktop Lag Consolidated Investigation And Handoff"
Cohesion: 0.14
Nodes (23): annas-archive-epub-downloads skill, Windows Desktop Window Manager, Handy, Vivaldi browser (remote debugger), ylc-searxng, YouTube Learning Center, Background review routed to SecondSpark, Backups and rollback ledger (+15 more)

### Community 22 - "probe_qwen_long.py"
Cohesion: 0.12
Nodes (16): Native Qwen Qualification Results, main(), one(), close_sockets(), main(), cancel(), monitor(), observe_slots() (+8 more)

### Community 23 - "continue_native_reviewed.py"
Cohesion: 0.15
Nodes (17): install_hooks(), qualify_long(), main(), pressure_failures(), pressure_wrapped_run(), monitor(), sample(), reviewed_evidence() (+9 more)

### Community 24 - "MiniMax H3 Windows Video Exploration Tutorial"
Cohesion: 0.13
Nodes (25): MiniMax H3, Akatz MiniMax H3 Character Swap LoRA v1, LoRA-on-Continuation Experiment (fnoji tip), MiniMax H3 Character Swap LoRA Windows Tutorial, MiniMax H3 Community License Agreement, Ref2VA Pinned Baseline, Shaky Cam Author Settings, MiniMax H3 Handheld Shaky Cam LoRA Windows Tutorial (+17 more)

### Community 25 - "DGX Spark Multi-Model Runtime Research"
Cohesion: 0.12
Nodes (10): DGX Spark Multi-Model Runtime Research, One-time LiteLLM HTTP 500 on stopped upstream, Nemotron 3.5 vs Nemotron 3 Nano Omni naming note, Nemotron Omni 12 GiB KV profile, Qwen 27B compose lacks persisted vLLM compile cache, Qwen 27 optimized MTP-3 profile (qwen27-dflash legacy route), Duplicate Lightning instance removal, FlashInfer (+2 more)

### Community 28 - "time"
Cohesion: 0.15
Nodes (8): measure(), check_co_residents(), command(), dflash_model_metadata(), main(), target_model_metadata(), validate_artifacts(), wait_for_memory()

### Community 29 - "DGX Spark Dual-Node Community Frontier Models Runbook"
Cohesion: 0.13
Nodes (27): DGX Spark Dual-Node Community Frontier Models Runbook, Fixed Cluster Values, GLM 5.3 Local Baseline Result, Immediate Stop Conditions, Memory And Coexistence Matrix, Reviewed And Pinned Source Set, Readiness Gate Repairs, Baseline .env Values (+19 more)

### Community 31 - "personal-hermes-obsidian-multinode-design"
Cohesion: 0.12
Nodes (22): Spark Obsidian Headless Sync Replica, Hermes MEMORY.md and USER.md, Obsidian, Obsidian Headless Sync, Qwen3 Embedding 0.6B, TEI (Text Embeddings Inference), Meta Bind Plugin, Obsidian Bases (+14 more)

### Community 32 - "Nemotron 3.5 Lightning 30B-A3B"
Cohesion: 0.16
Nodes (18): MiaAI-Lab Nemotron 3.5 SGLang Recipe, Nemotron 3.5 Lightning Official vLLM Recipe, Permanent Nemotron 1M x 1 profile, Nemotron 3.5 Lightning LM Studio load, DGX Spark Nemotron 3.5 Lightning Tutorial, Hermes test: fact, reasoning, tool call, coding edit, LiteLLM route nemotron35-lightning, MiaAI-Lab SGLang/DSpark recipe (+10 more)

### Community 33 - "RTX PRO 5000 Workstation"
Cohesion: 0.11
Nodes (17): After Power Loss Behavior = Auto Boot, DGX Spark Automatic Power Recovery Research, Safe Power-Loss Test Plan, Context and Concurrency Profiles, dgx-spark-current-models-report, Safe Download Order, Suggested resident allocation across Spark/workstation/laptop, Browser Use (+9 more)

### Community 35 - "Social Capture Local AI Model Exploration Guide"
Cohesion: 0.22
Nodes (12): OpenMontage, Perplexity Portable Computer, PPLX 27B, Cloud step escalation and credits, Original DGX Spark-only launch framing, RTX PRO 5000 Perplexity Portable Computer Tutorial, Settings > Local Inference, Personal Computer vs Portable Computer (+4 more)

### Community 36 - "DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial"
Cohesion: 0.18
Nodes (16): Shared frontier API key, GLM context ladder, DFlash/500K profile (GMU 0.86), DFlash/850K baseline profile, DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial, Step 16e shared evidence suite, GLM containers glm53-exl3-head / glm53-exl3-worker, InstantTensor loader budget fix (+8 more)

### Community 37 - "local-ai-architecture-research"
Cohesion: 0.11
Nodes (22): Caddy, ChatGPT Plus subscription, Claude Code, Claude Pro subscription, Codex, Gemini API / Gemini CLI, Google AI Pro subscription, Herdr (+14 more)

### Community 38 - "RTX PRO 5000 Laya Decision Model Tutorial"
Cohesion: 0.21
Nodes (15): Jev (TypeSafe AI hosted decision API), Laya Local Decision Model, RTX PRO 5000 Jev Agent Decision Evaluation Tutorial, hermes-jev-skills Repository, JEV-as-a-Judge Cascade, Shadow-to-Active Progression, Jev Windows Trial (Playground then API), RTX PRO 5000 Laya Decision Model Tutorial (+7 more)

### Community 39 - "PressureTests"
Cohesion: 0.14
Nodes (3): PressureTests, ReuseTests, sample()

### Community 40 - "RTX PRO 5000 Local Inference Measurement Tutorial"
Cohesion: 0.33
Nodes (9): RTX PRO 5000 Local Inference Measurement Tutorial, llama-server Windows CUDA build, Inference measurement decision record, MTP draft speculative decoding, One-GGUF experiment, Quantized KV cache (-ctk/-ctv), sudoingX llama.cpp flags X post, Time to first token (+1 more)

### Community 41 - "os"
Cohesion: 0.13
Nodes (7): config_paths(), main(), transform(), atomic(), digest(), main(), transform()

### Community 42 - "spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)"
Cohesion: 0.13
Nodes (18): DeepSeek 131K Bring-Up Profile, DGX Spark DeepSeek 131K And SparkFast Comparison Protocol, Eight-Profile Raw Comparison Table, spark-fast Raw Reference Benchmark, Saved DeepSeek Results, GLM local performance results, Stop GLM and restore spark-fast, DGX Spark Frontier Model Qualification Results (+10 more)

### Community 43 - "DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial"
Cohesion: 0.22
Nodes (11): Independent dual-Spark Qwen FP8 recipes, MiaAI-Lab Qwen3.8 Flash Next Dual DGX Sparks recipe, DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial, Qwen 3.8 Flash Next official FP8 lane, Dead huggingface-cli selection issue, Qwen 3.8 Flash Next NVFP4 dual-node baseline, NVFP4 per-node memory accounting, NVFP4 vs FP8 local results (+3 more)

### Community 44 - "configure_hermes.py"
Cohesion: 0.24
Nodes (14): atomic_write(), digest(), explicit_desktop_references(), inside(), main(), endpoint(), lmstudio_references(), main() (+6 more)

### Community 45 - "DGX Spark Operations Setup Guide"
Cohesion: 0.15
Nodes (14): DGX Spark Operations Setup Guide, LiteLLM route spark-fast, ~/ai navigable layout with store symlinks, qwen35 prepare.sh, Promote tested stack to 24x7, Human-readable registries (models.tsv, services.tsv, ports.tsv), One persistent Hermes for every device (Remote Gateway), spark-fast vLLM compose profile (+6 more)

### Community 46 - "Markdown Backed Interactive Dashboard Research"
Cohesion: 0.18
Nodes (14): Claude Messages API, LLMWiki Vault, Obsidian Sync, Personal-Sync Vault, Tailscale Serve, Dashboard MVP Acceptance Tests, Chokidar File Watcher + Server-Sent Events, Markdown Backed Interactive Dashboard Research (+6 more)

### Community 47 - "hashlib"
Cohesion: 0.25
Nodes (7): atomic_write(), Dashboard, library_state(), markdown_path(), note_state(), plain(), sha256()

### Community 48 - "ODS"
Cohesion: 0.15
Nodes (17): ODS Hermes Auth Proxy, 24x7 Hermes Service Shape, FirstSpark ODS retirement 2026-09-22, Phase 0 - Make the Spark a safe appliance, Phase 0 — Safe Remote Appliance, Recommended software versions (2026-08-20), NVIDIA DGX Dashboard, ODS (+9 more)

### Community 49 - "glm-reasoning-shim.py"
Cohesion: 0.14
Nodes (4): BridgeServer, main(), ReasoningBridge, rewrite_reasoning()

### Community 50 - "DGX Spark Additional Model Tutorials Index"
Cohesion: 0.19
Nodes (13): DGX Spark Additional Model Tutorials Index, Qwen 3.8 Release Intake Sequence, Recommended Model Testing Order, Per-Runtime Model Stores, Muse Glimmer vLLM Recipe, Muse Glimmer vLLM compose profile, DGX Spark Muse Glimmer 30B Readiness Tutorial, Inferact/Muse-Glimmer-30B-NVFP4-W4A4 (not to substitute) (+5 more)

### Community 51 - "DGX Spark Nemotron 3 Nano Omni Tutorial"
Cohesion: 0.31
Nodes (8): Nemotron Omni vLLM compose profile, Derived vLLM audio image, DGX Spark Nemotron 3 Nano Omni Tutorial, InvalidDefaultArgInFrom build warning, LiteLLM route nemotron3-omni, ~/ai/media mounted media directory, prepare-nemotron3-omni.sh, Nemotron Omni optimization verification 2026-08-15

### Community 52 - "LongCat Video Avatar 1.5 Workstation Feasibility Tutorial"
Cohesion: 0.20
Nodes (14): FlashAttention, LongCat-Video-Avatar 1.5, PyTorch, Whisper Large V3, WSL2 Ubuntu, LongCat Video Avatar 1.5 Workstation Feasibility Tutorial, One-clip 480p smoke test, LongCat pass criteria (+6 more)

### Community 54 - "DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20"
Cohesion: 0.18
Nodes (16): Safe first LM Studio trial (lms get q4_k_m), Hermes Remote Gateway basic auth, Controlled reboot / power-cycle test (passed), DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20, Health baseline endpoints, Intended boot residency: Qwen spark-fast + one Lightning, lmstudio.service systemd user unit, Recovery pass thresholds (+8 more)

### Community 55 - "Sequence 8J — Social Capture Windows Local-Model Exploration"
Cohesion: 0.52
Nodes (6): Tencent EVIE Visual Retriever, PyTorch + ColPali Route, RTX PRO 5000 EVIE Visual Document Retrieval Tutorial, Multi-Vector Index Cost, EVIE Windows PowerShell Trial, Sequence 8J — Social Capture Windows Local-Model Exploration

### Community 56 - "Realtime Conversation Video Windows Feasibility Tutorial"
Cohesion: 0.29
Nodes (9): AivisSpeech TTS, LTX-2.5, OpenAI-compatible input_audio LLM, diffusers-movie-server gateway, Realtime Conversation Video Windows Feasibility Tutorial, Time to first audio/frame and chunk metrics, Realtime_Conversation_Video client, Realtime_Narration_Video renderer (+1 more)

### Community 57 - "load_qwen.mjs"
Cohesion: 0.17
Nodes (6): args, client, config, options, require, sdkDirectory

### Community 60 - "Social Capture"
Cohesion: 0.42
Nodes (7): Social Capture, Social Capture task provenance table, Social Capture Action Queue.md, Social Capture Pipeline, Queue lifecycle and monthly archive, Social Capture desktop dashboard, WhatsApp backlog importer

### Community 65 - "Qwen 3.8 27B"
Cohesion: 0.19
Nodes (14): Native Qwen 3.8 Inventory Entries, Qwen 3.8 27B, 65K desktop-Qwen control, 262K runtime GPU allocation, Qwen 3.8 27B Ollama Remote Access Research, Live Installation Record 2026-08-20, Remote Access Verification Checklist, RTX PRO 5000 Qwen 3.8 BF16 LM Head Audit Tutorial (+6 more)

### Community 66 - "Frontier Model Vision Test (image)"
Cohesion: 0.33
Nodes (6): Blue Circles (2, top-right), Vision Check: Shape, Color, Count, Position, Frontier Model Vision Test (image), Green Squares (3, bottom-left), Red Triangle (1, top-left), Yellow Star (1, bottom-right)

### Community 68 - "ComfyUI"
Cohesion: 0.26
Nodes (13): BFS Best Face Swap repository, ComfyUI, bfs_body_swap_v1.0_qwen_2.1 LoRA, body_swap prompt, RTX PRO 5000 Qwen Image 2.1 BFS Body Swap Windows Tutorial, LoraLoaderModelOnly node, Reference image preparation, bfs_head_v1.1_alternative_qwen_2.1 LoRA (+5 more)

### Community 69 - "download_native_qwen.sh"
Cohesion: 0.40
Nodes (4): HF_HUB_DISABLE_IMPLICIT_TOKEN, HF_XET_CACHE, HF_XET_NUM_CONCURRENT_RANGE_GETS, download_native_qwen.sh script

### Community 71 - "Fresh Brief Spark Qwen Migration Requirements"
Cohesion: 0.19
Nodes (12): Fresh Brief, FreshRSS, Perplexica, Fresh Brief acceptance gates, Cutover and preservation procedure, Fresh Brief Spark Qwen Migration Requirements, OpenAI-mode JSON adapter specification, Incompatible Client Context Runner Reloads (+4 more)

### Community 72 - "llama.cpp"
Cohesion: 0.22
Nodes (13): llama.cpp, spark-qwen38 (native Qwen27B), build_native_runtime.sh script, SparkFast And Qwen 27B Capacity Comparison, F16 MMA flash-attention temp buffer, Four 100K-input test, Four 240K-input long test, Four isolated Hermes sessions (+5 more)

### Community 73 - "Qwen 3.8 27B DFlash2 Speed Upgrade"
Cohesion: 0.18
Nodes (11): Hermes desktop-ollama Named Provider, Applied, Pending (user, hardware), Qwen 27B Windows lag and Spark download fix — 13 October 2026, Root causes found, HF -> SecondSpark -> ConnectX-7 -> FirstSpark Transfer Route, Workstation Ollama Qwen Speed Comparison, Qwen 3.8 27B DFlash2 Speed Upgrade (+3 more)

### Community 74 - "Local Setup Index"
Cohesion: 0.18
Nodes (9): nvidia/Qwen3.8-Flash-Next-NVFP4 checkpoint, GB10 Superchip, NVFP4, Local Setup Index, Workstation fine-tuning plan, Qwen desktop relief publication, spark-frontier fail-closed hot-swap manager, Qwen3.6-35B-A3B-NVFP4 (+1 more)

### Community 75 - "Hermes LM Link And Workstation Model Routing Research"
Cohesion: 0.21
Nodes (9): LM Link, Hermes provider desktop-ollama, Hermes LM Link And Workstation Model Routing Research, Hermes Desktop, provider_models_cache.json warm restart, Recommended Hermes/LM Link/Ollama topology, Hermes provider spark-lmstudio, LM Link routing verification gates (+1 more)

### Community 76 - "Task Checklist"
Cohesion: 0.15
Nodes (13): Devstral Small 2 24B, olmOCR 2 7B, Task Checklist, Final Completion Definition, Nemotron 3 Nano Omni Serving Tests, FirstSpark Physical Power-Cycle Recovery, Sequence 0 — Reconfirm Baseline and Ownership Map, Sequence 11 — Monthly Maintenance (+5 more)

### Community 77 - "DGX Spark And RTX 5000 Workstation Model Placement Research"
Cohesion: 0.22
Nodes (7): DGX Spark And RTX 5000 Workstation Model Placement Research, Fine-Tuning Scope On 48 GB, Open WebUI Provider Prefixes, Spark/Workstation Ownership Architecture, Model Placement Matrix, Verify Which RTX 5000, Workstation Model Shortlist

### Community 78 - "DGX Spark Ollama And ODS Tutorial"
Cohesion: 0.43
Nodes (6): DGX Spark Ollama And ODS Tutorial, LiteLLM route ollama-gemma4-e4b, ODS public Ollama extension (0.5.7, 8 GB limit), ollama-current container, Open WebUI Ollama connection (http://ollama-current:11434), prepare-ollama-current.sh

### Community 79 - "Qwen 3.8 27B Spark LM Studio Migration Tutorial"
Cohesion: 0.29
Nodes (7): Qwen 3.8 27B Spark LM Studio Migration Tutorial, Exact Ollama Weight Copy to Spark, Hermes Catalog Simplification (Gemmas once, Spark Qwen once), Disable LM Studio JIT Model Loading, Nemotron On-Demand Switching and Rollback, FirstSpark Running Snapshot 2026-10-12, LM Studio Qwen Residency Plan (superseded)

### Community 80 - "Local Setup Field Guide Dashboard Template"
Cohesion: 0.50
Nodes (3): Local Setup Dashboard, Local Setup Field Guide Dashboard Template, Markdown Folder Import And Progress JSON

## Ambiguous Edges - Review These
- `spark-fast alias` → `Background review routed to SecondSpark`  [AMBIGUOUS]
  hermes-qwen-desktop-lag-handoff-2026-09-28.md · relation: conceptually_related_to
- `DFlash2` → `qwen27-dflash alias`  [AMBIGUOUS]
  RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial.md · relation: conceptually_related_to

## Knowledge Gaps
- **126 isolated node(s):** `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_NUM_CONCURRENT_RANGE_GETS`, `HF_XET_CACHE`, `Evidence Labels Standard`, `Operational context profiles (interactive/batch/long/huge-experimental)` (+121 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 313 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Qwen 3.8 27B Native Spark Setup Tutorial` connect `Qwen 3.8 27B Native Spark Setup Tutorial` to `Hermes Agent`, `LM Studio`, `finish_native_install.py`, `Ollama`, `FirstSpark`, `DGX Spark Frontier Model Hot-Swap And Routing Guide`, `DGX Spark Additional Models And Convenience Runtimes Research`, `vLLM`, `json`, `download_native_parallel.py`, `probe_qwen_long.py`, `continue_native_reviewed.py`, `time`, `Nemotron 3.5 Lightning 30B-A3B`, `DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial`, `os`, `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)`, `configure_hermes.py`, `Qwen 3.8 27B`, `Fresh Brief Spark Qwen Migration Requirements`, `llama.cpp`, `Qwen 3.8 27B DFlash2 Speed Upgrade`, `Local Setup Index`, `Task Checklist`?**
  _High betweenness centrality (0.265) - this node is a cross-community bridge._
- **What connects `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_NUM_CONCURRENT_RANGE_GETS`, `HF_XET_CACHE` to the rest of the system?**
  _126 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `dgx-spark-twitter-bookmarks-analysis` be split into smaller, more focused modules?**
  _Cohesion score 0.05754527162977867 - nodes in this community are weakly interconnected._
- **Why does `Local Setup Index` connect `Local Setup Index` to `dgx-spark-twitter-bookmarks-analysis`, `Qwen 3.8 27B Native Spark Setup Tutorial`, `Hermes Agent`, `DGX Spark Qwen NVFP4 Memory And Startup Optimization Research`, `LM Studio`, `VoiceStudio Risk Audit`, `Ollama`, `local-ai-tooling-catalog-and-rollout`, `RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial`, `LiteLLM`, `FirstSpark`, `DGX Spark Frontier Model Hot-Swap And Routing Guide`, `DGX Spark ODS Playbook and Model Roadmap`, `DGX Spark Additional Models And Convenience Runtimes Research`, `vLLM`, `Hermes + Qwen Desktop Lag Consolidated Investigation And Handoff`, `MiniMax H3 Windows Video Exploration Tutorial`, `DGX Spark Multi-Model Runtime Research`, `DGX Spark Dual-Node Community Frontier Models Runbook`, `personal-hermes-obsidian-multinode-design`, `Nemotron 3.5 Lightning 30B-A3B`, `RTX PRO 5000 Workstation`, `Social Capture Local AI Model Exploration Guide`, `DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial`, `local-ai-architecture-research`, `RTX PRO 5000 Laya Decision Model Tutorial`, `RTX PRO 5000 Local Inference Measurement Tutorial`, `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)`, `DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial`, `DGX Spark Operations Setup Guide`, `Markdown Backed Interactive Dashboard Research`, `ODS`, `DGX Spark Additional Model Tutorials Index`, `DGX Spark Nemotron 3 Nano Omni Tutorial`, `LongCat Video Avatar 1.5 Workstation Feasibility Tutorial`, `DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20`, `Sequence 8J — Social Capture Windows Local-Model Exploration`, `Realtime Conversation Video Windows Feasibility Tutorial`, `Qwen 3.8 27B`, `ComfyUI`, `Fresh Brief Spark Qwen Migration Requirements`, `llama.cpp`, `Hermes LM Link And Workstation Model Routing Research`, `Task Checklist`, `DGX Spark And RTX 5000 Workstation Model Placement Research`, `DGX Spark Ollama And ODS Tutorial`, `Qwen 3.8 27B Spark LM Studio Migration Tutorial`?**
  _High betweenness centrality (0.116) - this node is a cross-community bridge._
- **Should `Qwen 3.8 27B Native Spark Setup Tutorial` be split into smaller, more focused modules?**
  _Cohesion score 0.12169312169312169 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `spark-fast alias` and `Background review routed to SecondSpark`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `DFlash2` and `qwen27-dflash alias`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._