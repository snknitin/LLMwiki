# Graph Report - Local_Setup  (2026-10-13)

## Corpus Check
- 136 files · ~298,026 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 16 file(s) not represented in the graph (top: .log 6, .service 4, (none) 1)

## Summary
- 1733 nodes · 5290 edges · 71 communities (55 shown, 16 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 204 edges (avg confidence: 0.84)
- Token cost: 1,601,293 input · 0 output

## Community Hubs (Navigation)
- Model Deployment & Install Matrix
- Qwen 3.8 27B Migration & Fresh Brief
- Always-On Hermes & Roadmap Phases
- One-Large-Model Rule & Recovery
- Additional Models & Convenience Runtimes
- Admission Proxy Code
- VoiceStudio & Model Store Ownership
- Setup Dashboard Frontend (app.js)
- Ollama, ODS & Open WebUI on Spark
- Agent Tooling & Skills Catalog
- Qwen Image 2.1 ComfyUI Workflows
- Frontier Hot-Swap Runbook & Aliases
- Dual-Spark CX-7 Networking & NCCL
- Aux Services Controller & sparkDash
- Multi-Model Engine Decisions
- Frontier Model Probe Script
- Gemma 4 & Spark/Workstation Placement
- Frontier Qualification Results
- Native Download & Hermes Probes
- Parallel Pinned Downloads
- Desktop Hermes Lag Handoff
- Native Qwen Qualification Probes
- Reviewed Native Continuation
- MiniMax H3 Video LoRAs
- Native Install Finisher
- Native Qwen Runner & Memory Diagnose
- Dual-Node Frontier Recipes
- Long-Context Probe Tests
- Hermes Obsidian Sync Design
- Hermes Serve/Gateway & Acceptance Gates
- DGX Spark Hardware & Power Recovery
- Bandwidth vs Capacity Placement
- GLM 5.3 Flash EXL3 Dual-Node
- Credentials & Cloud Subscriptions
- Jev & Laya Decision Models
- Pressure & Reuse Guard Tests
- RTX 5000 llama.cpp Measurement
- Desktop Qwen Publish & GLM Shim
- DeepSeek V4.1 131K Comparison
- Qwen 3.8 Flash Next Dual-Node
- Hermes Provider Migration Scripts
- Spark Operations Setup Guide
- Markdown-Backed Dashboard Design
- Dashboard Preview Server
- Qwen Flash Next v0.30 Single-Node
- GLM Reasoning Bridge
- Muse Glimmer 30B Readiness
- Nemotron Omni & Switch Procedure
- LongCat Video Avatar Feasibility
- DFlash Draft Config Tests
- Interactive Speed & Restart Probes
- EVIE Retrieval & Social Model Exploration
- Realtime Conversation Video
- LM Studio SDK Loader
- Memory Readiness Tests
- Hermes Timeout Tests
- Social Capture Pipeline
- Systemd Reset Tests
- Named Timeout Integration Tests
- Production Wire Tests
- Native Catalog Tests
- Logical Routes & Capability Aliases
- Vision Test Image
- Three-Device Topology
- Native Qwen Download Script
- Desktop Qwen Transform Tests

## God Nodes (most connected - your core abstractions)
1. `Hermes Agent` - 138 edges
2. `Local Setup Index` - 114 edges
3. `LiteLLM` - 102 edges
4. `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)` - 91 edges
5. `vLLM` - 87 edges
6. `LM Studio` - 87 edges
7. `Ollama` - 86 edges
8. `RTX PRO 5000 Workstation` - 84 edges
9. `ODS` - 80 edges
10. `DGX Spark ODS Playbook and Model Roadmap` - 73 edges

## Surprising Connections (you probably didn't know these)
- `Unified 524K Q8 KV Alternative` --semantically_similar_to--> `Two-Slot 262K Context and Memory Plan`  [INFERRED] [semantically similar]
  Qwen Spark Migration/LONG-PROBE-GUARDS.md → Qwen 3.8 27B Spark Serving Options.md
- `Frontier Model Vision Test (image)` --conceptually_related_to--> `DGX Spark`  [INFERRED]
  Frontier Model Vision Test.png → Always-On Hermes on DGX Spark.md
- `Four-Slot Q8 Memory Estimate` --references--> `spark-fast (Qwen 3.6 35B-A3B NVFP4 lane)`  [EXTRACTED]
  Qwen Spark Migration/LONG-PROBE-GUARDS.md → DGX Spark Additional Model Tutorials Index.md
- `DGX Spark Frontier Model Qualification Results` --references--> `Frontier Model Vision Test (image)`  [INFERRED]
  DGX Spark Frontier Model Qualification Results.md → Frontier Model Vision Test.png
- `Qwen Spark Migration Publication Status` --references--> `Hermes spark-qwen38 Provider (qwen38-27b-spark)`  [INFERRED]
  Qwen Spark Migration/DECISION-README.md → Qwen 3.8 27B Native Spark Setup Tutorial.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Frontier Lane Hot-Swap Lifecycle** — ent_aux_services, ent_spark_frontier, ent_spark_model, ent_spark_fast, dgx_spark_dual_node_community_frontier_models_runbook_common_drain_rollback, dgx_spark_dual_node_community_frontier_models_runbook_litellm_hermes_aliases [INFERRED 0.85]
- **MiaAI Dual-Spark Frontier Recipes** — ent_qwen_3_8_flash_next, ent_glm_5_3_flash, ent_deepseek_v4_1_flash, ent_dual_spark_cluster, ent_miaai_lab [EXTRACTED 1.00]
- **Spark Hermes Control Plane** — ent_hermes, always_on_hermes_on_dgx_spark_hermes_serve, always_on_hermes_on_dgx_spark_hermes_gateway, ent_litellm, ent_tailscale, ent_hermes_desktop [EXTRACTED 1.00]
- **Frontier hot-swap control plane** — ent_spark_frontier, ent_litellm, ent_hermes, ent_glm_reasoning_shim, ent_spark_fast, ent_dual_spark_cluster [EXTRACTED 1.00]
- **Mutually exclusive dual-node frontier lanes on port 8100** — dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_baseline, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_fp8_comparison, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_mtp_850k_accepted, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_deepseek_recipe, dgx_spark_dual_node_frontier_model_recipes_research_2026_09_18_port_8100 [INFERRED 0.85]
- **Frontier qualification evidence pipeline** — dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_probe_suite, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_evidence_suite, dgx_spark_frontier_model_qualification_results_headline_table, dgx_spark_dual_node_glm_5_3_flash_exl3_tutorial_perf_results, dgx_spark_dual_node_qwen_3_8_flash_next_tutorial_nvfp4_vs_fp8_results, ent_spark_frontier_check [INFERRED 0.85]
- **Performance-first Hermes serving stack** — ent_hermes, ent_litellm, ent_spark_fast, ent_vllm, ent_qwen_3_6_35b_a3b [EXTRACTED 1.00]
- **Boot recovery ordering chain** — ent_docker, ent_spark_fast, dgx_spark_pre_shutdown_and_automatic_recovery_snapshot_2026_08_20_wait_for_spark_fast, dgx_spark_pre_shutdown_and_automatic_recovery_snapshot_2026_08_20_lmstudio_service, ent_nemotron_3_5_lightning [EXTRACTED 1.00]
- **Dual Spark cluster bring-up** — ent_firstspark, ent_secondspark, dgx_spark_second_node_and_dual_spark_readiness_research_2026_08_20_qsfp112_dac_cable, dgx_spark_second_node_and_dual_spark_readiness_research_2026_08_20_cluster_assistant, ent_nccl, ent_dual_spark_cluster [EXTRACTED 1.00]
- **SecondSpark single-node Qwen raw-qualify then LiteLLM/Hermes promotion** — ent_tensorfold, ent_secondspark, ent_litellm, ent_hermes, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_alias_qwen38_tensorfold_second, dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_full_raw_qualification [EXTRACTED 1.00]
- **Hermes cross-machine provider routing via LM Link and Tailscale** — ent_hermes, ent_lm_link, ent_lm_studio, ent_ollama, ent_tailscale, hermes_lm_link_and_workstation_model_routing_research_spark_lmstudio_provider, hermes_lm_link_and_workstation_model_routing_research_desktop_ollama_provider [EXTRACTED 1.00]
- **Unified-memory safety qualification gates (MemAvailable >=10 GiB, no NV_ERR_NO_MEMORY)** — dgx_spark_single_node_qwen_3_8_flash_next_tensorfold_replacement_tutorial_100k_memory_gate, dgx_spark_single_node_qwen_3_8_flash_next_v0_30_tutorial_memory_kernel_gate, dgx_spark_sparkdash_monitoring_tutorial_coexistence_decision, ent_unified_memory_128gb [INFERRED 0.85]
- **Native Qwen 3.8 27B serving stack on FirstSpark** — qwen_3_8_27b_native_spark_setup_tutorial_qwen38_native_service, qwen_3_8_27b_native_spark_setup_tutorial_qwen38_admission_service, qwen_3_8_27b_native_spark_setup_tutorial_spark_qwen38_provider, ent_llama_cpp, ent_unsloth_qwen3_8_27b_gguf, ent_firstspark, ent_hermes [EXTRACTED 1.00]
- **Workstation Ollama reached from Spark Hermes via Tailscale Serve** — ent_ollama, ent_tailscale_serve, ent_desktop_ollama_provider, ent_hermes, ent_qwen_3_8_27b, ent_rtx_pro_5000_workstation [EXTRACTED 1.00]
- **MiniMax H3 local ComfyUI bench with community LoRAs** — minimax_h3_windows_video_exploration_tutorial_isolated_comfyui_bench, ent_minimax_h3, ent_comfyui, minimax_h3_character_swap_lora_windows_tutorial_character_swap_lora, minimax_h3_handheld_shaky_cam_lora_windows_tutorial_handheld_shaky_cam_lora, ent_rtx_pro_5000_workstation [EXTRACTED 1.00]
- **Qwen Image 2.1 ComfyUI pipeline (denoiser + encoder + VAE + LoRA)** — ent_qwen_image_2_1, ent_qwen3_vl_8b_encoder, rtx_pro_5000_qwen_image_2_1_base_windows_tutorial_qwen_image_vae, rtx_pro_5000_qwen_image_2_1_base_windows_tutorial_text_encode_qwen_image21_node, rtx_pro_5000_qwen_image_2_1_bfs_body_swap_windows_tutorial_lora_loader_model_only, ent_comfyui [EXTRACTED 1.00]
- **Realtime conversation video service chain** — realtime_conversation_video_windows_feasibility_tutorial_realtime_conversation_client, realtime_conversation_video_windows_feasibility_tutorial_audio_input_llm, realtime_conversation_video_windows_feasibility_tutorial_realtime_narration_video, ent_aivisspeech, realtime_conversation_video_windows_feasibility_tutorial_diffusers_movie_server, ent_ltx_2_5 [EXTRACTED 1.00]
- **Spark alias-based model routing plane** — ent_hermes, ent_litellm, ent_spark_fast, ent_spark_small, ent_vllm, ent_llama_cpp, ent_dgx_spark [EXTRACTED 1.00]
- **Dual-Spark Frontier Hot-Swap Lane** — ent_dual_spark_cluster, ent_qwen_3_8_flash_next, ent_glm_5_3_flash, ent_deepseek_v4_1_flash, ent_spark_frontier, ent_spark_fast [EXTRACTED 1.00]
- **VoiceStudio Readiness Failure Chain** — voicestudio_risk_audit_shutdown_latch, voicestudio_risk_audit_false_negative_health, voicestudio_risk_audit_no_deliverable_baseline, voicestudio_risk_audit_lifecycle_confusion [INFERRED 0.85]
- **Spark Inference Engine Learning Ladder** — ent_llama_cpp, ent_vllm, ent_sglang, ent_tensorrt_llm, ent_nim [EXTRACTED 1.00]
- **Gateway-routed logical aliases with controlled model swap** — dgx_spark_twitter_bookmarks_analysis_safe_swap_controller, local_ai_architecture_research_hotswap_as_routing, personal_hermes_obsidian_multinode_design_gateway_hot_swap_policy, ent_litellm, personal_hermes_obsidian_multinode_design_logical_routes [INFERRED 0.85]
- **Spark-authoritative Hermes with remote Desktop clients over Tailscale** — ent_hermes, ent_hermes_desktop, ent_dgx_spark, ent_tailscale, local_ai_architecture_research_hermes_serve, local_ai_architecture_research_hermes_gateway [EXTRACTED 1.00]
- **Desktop lag causal chain on shared display GPU** — ent_qwen_3_8_27b, ent_ollama, ent_rtx_pro_5000_workstation, ent_desktop_window_manager, ent_handy, hermes_qwen_desktop_lag_handoff_2026_09_28_gpu_display_contention [EXTRACTED 1.00]

## Communities (71 total, 16 thin omitted)

### Community 0 - "Model Deployment & Install Matrix"
Cohesion: 0.06
Nodes (64): 0xSero DeepSeek V4 Flash SparkInfer, DGX Spark Aug 2026 Model Deployment Research, Evidence Labels Standard, NVIDIA Playbook Issue #89 Tool-Call Quant Bisect, MiaAI Qwen3.6 27B DFlash Profile, NVIDIA Qwen3.6 35B First-Party Control, Install and Experiment Matrix, DGX Spark Model Installation And Switching Guide (+56 more)

### Community 1 - "Qwen 3.8 27B Migration & Fresh Brief"
Cohesion: 0.05
Nodes (48): Qwen 3.8 Release Intake Sequence, Qwen 3.8 27B LM Studio migration pointer, Hermes desktop-ollama Named Provider, Fresh Brief, FreshRSS, Perplexica, Qwen 3.8 27B, Tailscale Serve (+40 more)

### Community 2 - "Always-On Hermes & Roadmap Phases"
Cohesion: 0.06
Nodes (57): Workstation-local desktop-files Profile, Discord Primary Phone Interface, Always-On Hermes on DGX Spark, ODS Hermes Auth Proxy, Always-On Hermes Rollout Plan, 24x7 Hermes Service Shape, Phase 0 - Make the Spark a safe appliance, Roadmap Completion Criteria (+49 more)

### Community 3 - "One-Large-Model Rule & Recovery"
Cohesion: 0.05
Nodes (40): Hermes Remote Gateway basic auth, One persistent Hermes for every device (Remote Gateway), Controlled reboot / power-cycle test (passed), DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20, Duplicate Lightning instance removal, Health baseline endpoints, lmstudio.service systemd user unit, Recovery pass thresholds (+32 more)

### Community 4 - "Additional Models & Convenience Runtimes"
Cohesion: 0.07
Nodes (40): DGX Spark Additional Model Tutorials Index, Recommended Model Testing Order, Per-Runtime Model Stores, Unverified Or Deferred Items, DGX Spark Additional Models And Convenience Runtimes Research, LM Studio JIT Loading And Auto-Evict, Machine State Snapshot 2026-08-14, MiaAI-Lab Nemotron 3.5 SGLang Recipe (+32 more)

### Community 5 - "Admission Proxy Code"
Cohesion: 0.06
Nodes (15): Admission, create_app(), chat(), health(), json_call(), models(), recover_loop(), startup() (+7 more)

### Community 6 - "VoiceStudio & Model Store Ownership"
Cohesion: 0.06
Nodes (50): Safe Download Order, Downloaded vs running distinction, Model store ownership rules, Hugging Face Hub cache, OmniVoice TTS Model, Parakeet TDT 0.6B v3, VoiceStudio, Whisper (+42 more)

### Community 7 - "Setup Dashboard Frontend (app.js)"
Cohesion: 0.10
Nodes (44): applyLibrarySnapshot(), closeDrawer(), decodeSafe(), download(), drawTask(), empty(), exportHTML(), exportProgress() (+36 more)

### Community 8 - "Ollama, ODS & Open WebUI on Spark"
Cohesion: 0.08
Nodes (33): Fixed Cluster Values, Frontier API port 8100, DGX Spark Ollama And ODS Tutorial, LiteLLM route ollama-gemma4-e4b, ODS public Ollama extension (0.5.7, 8 GB limit), ollama-current container, Open WebUI Ollama connection (http://ollama-current:11434), prepare-ollama-current.sh (+25 more)

### Community 9 - "Agent Tooling & Skills Catalog"
Cohesion: 0.07
Nodes (41): Addy Osmani Agent Skills, Anthropic Claude Skills, AutoGen, Buffer MCP, Caveman, Claude Design, Composio, Compound Engineering plugin (+33 more)

### Community 10 - "Qwen Image 2.1 ComfyUI Workflows"
Cohesion: 0.12
Nodes (31): BFS Best Face Swap repository, ComfyUI, Qwen3-VL 8B text encoder, Qwen Image 2.1, BF16 quality comparison lane, RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial, INT8 ConvRot baseline lane, Isolated portable ComfyUI install (+23 more)

### Community 11 - "Frontier Hot-Swap Runbook & Aliases"
Cohesion: 0.08
Nodes (35): Stable Capability Model Aliases, Spark/Workstation Ownership Architecture, Common Drain And Universal Rollback, DGX Spark Dual-Node Community Frontier Models Runbook, GLM 5.3 Local Baseline Result, Immediate Stop Conditions, Frontier LiteLLM/Hermes Aliases, Memory And Coexistence Matrix (+27 more)

### Community 12 - "Dual-Spark CX-7 Networking & NCCL"
Cohesion: 0.12
Nodes (28): NVIDIA Driver CDI Recovery, Dual-Spark Usage Options, DGX Spark Dual-Node Configuration And Operations Reference, NCCL all_gather_perf Result, NCCL Test Procedure, CX-7 Physical Topology, Software Baseline Audit 2026-09-18, NVIDIA Sync Cluster Assistant (+20 more)

### Community 13 - "Aux Services Controller & sparkDash"
Cohesion: 0.11
Nodes (24): aux-services Allow-List Entry Format, Dashboard Command Center Service Mapping, DGX Spark Additional Services Controller, Drain And Restore Workflow, Native Qwen 3.8 Inventory Entries, Refresh Bounded Recovery Path, DGX Spark sparkDash Tunnel Scheduled Task, sparkDash known issues (+16 more)

### Community 14 - "Multi-Model Engine Decisions"
Cohesion: 0.15
Nodes (25): Engine Decisions, DGX Spark Multi-Model Runtime Research, One-time LiteLLM HTTP 500 on stopped upstream, Qwen 27B compose lacks persisted vLLM compile cache, Qwen 27 optimized MTP-3 profile (qwen27-dflash legacy route), Nemotron runtime path comparison (vLLM / SGLang / LM Studio), NVIDIA Qwen3.6 35B NVFP4 Spark vLLM recipe, Phase 1 - Serving and inference engineering (+17 more)

### Community 15 - "Frontier Model Probe Script"
Cohesion: 0.25
Nodes (24): atomic_json(), capture_record(), chat_content(), cmd_chat(), cmd_compare(), cmd_concurrency(), cmd_context(), cmd_identity() (+16 more)

### Community 16 - "Gemma 4 & Spark/Workstation Placement"
Cohesion: 0.09
Nodes (25): Gemma 4 26B A4B vLLM Spark Recipe, Gemma 4 31B Experimental Profile, Nemotron Omni vLLM 0.20 Recipe, DGX Spark And RTX 5000 Workstation Model Placement Research, Open WebUI Provider Prefixes, Workstation Model Shortlist, Gemma vLLM compose configuration, DGX Spark Gemma 4 Models Tutorial (+17 more)

### Community 18 - "Frontier Qualification Results"
Cohesion: 0.10
Nodes (24): GLM local performance results, Optional Qwen TP1 lane on SecondSpark, DGX Spark Frontier Model Qualification Results, GLM v2 concurrency regression flag, Standardized frontier headline results, SparkFast orphan-request guard, SecondSpark Qwen TensorFold qualification, SecondSpark Qwen v0.30 Attempt 1 (failed safety) (+16 more)

### Community 19 - "Native Download & Hermes Probes"
Cohesion: 0.13
Nodes (12): digest(), main(), child(), send(), guard_socket_connector(), main(), production_python_command(), save_failure() (+4 more)

### Community 20 - "Parallel Pinned Downloads"
Cohesion: 0.15
Nodes (18): atomic_json(), Canceled, digest(), download_file(), transfer(), fetch_range(), main(), probe_ranges() (+10 more)

### Community 21 - "Desktop Hermes Lag Handoff"
Cohesion: 0.14
Nodes (24): annas-archive-epub-downloads skill, Codex, Windows Desktop Window Manager, Handy, Vivaldi browser (remote debugger), ylc-searxng, YouTube Learning Center, Background review routed to SecondSpark (+16 more)

### Community 22 - "Native Qwen Qualification Probes"
Cohesion: 0.13
Nodes (17): Native Qwen Qualification Results, error(), main(), main(), one(), qualification_environment(), close_sockets(), main() (+9 more)

### Community 23 - "Reviewed Native Continuation"
Cohesion: 0.15
Nodes (17): install_hooks(), qualify_long(), main(), pressure_failures(), pressure_wrapped_run(), monitor(), sample(), reviewed_evidence() (+9 more)

### Community 24 - "MiniMax H3 Video LoRAs"
Cohesion: 0.15
Nodes (23): MiniMax H3, Akatz MiniMax H3 Character Swap LoRA v1, LoRA-on-Continuation Experiment (fnoji tip), MiniMax H3 Character Swap LoRA Windows Tutorial, MiniMax H3 Community License Agreement, Ref2VA Pinned Baseline, Shaky Cam Author Settings, MiniMax H3 Handheld Shaky Cam LoRA Windows Tutorial (+15 more)

### Community 25 - "Native Install Finisher"
Cohesion: 0.20
Nodes (21): check_abort(), entrypoint(), get(), handle_shutdown(), kill_group(), main(), mem_available_gib(), memory_guard() (+13 more)

### Community 28 - "Native Qwen Runner & Memory Diagnose"
Cohesion: 0.16
Nodes (11): atomic(), digest(), main(), transform(), check_co_residents(), command(), dflash_model_metadata(), main() (+3 more)

### Community 29 - "Dual-Node Frontier Recipes"
Cohesion: 0.19
Nodes (19): DeepSeek V4.1 Flash EXL3 2x Spark Recipe, Raw endpoint acceptance gate, MiaAI-Lab DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks recipe, DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18, GLM recipe open failure issues, MiaAI-Lab GLM-5.3-Flash-EXL3-2x-DGX-Sparks recipe, Known local blockers before dual-node launch, MiaAI-Lab Qwen3.8 Flash Next Dual DGX Sparks recipe (+11 more)

### Community 31 - "Hermes Obsidian Sync Design"
Cohesion: 0.13
Nodes (17): Spark Obsidian Headless Sync Replica, Hermes MEMORY.md and USER.md, Obsidian, Obsidian Headless Sync, Meta Bind Plugin, Obsidian Bases, Agent Inbox safe-writing pattern, Concurrency and failure rules (+9 more)

### Community 32 - "Hermes Serve/Gateway & Acceptance Gates"
Cohesion: 0.13
Nodes (18): hermes gateway, hermes serve, Hermes-Ready Tool Contract, Local Acceptance Benchmark Contract, 24x7 Promotion Gates, Frontier Model Acceptance Gate, LM Studio API as named Hermes provider, LM Studio API port 1234 (loopback) (+10 more)

### Community 33 - "DGX Spark Hardware & Power Recovery"
Cohesion: 0.14
Nodes (12): After Power Loss Behavior = Auto Boot, DGX Spark Automatic Power Recovery Research, Safe Power-Loss Test Plan, Context and Concurrency Profiles, dgx-spark-current-models-report, DGX Spark, GB10 Superchip, Local Setup Index (+4 more)

### Community 35 - "Bandwidth vs Capacity Placement"
Cohesion: 0.14
Nodes (16): Fine-Tuning Scope On 48 GB, Model Placement Matrix, Verify Which RTX 5000, Suggested resident allocation across Spark/workstation/laptop, Browser Use, Perplexity Portable Computer, PPLX 27B, RAGFlow (+8 more)

### Community 36 - "GLM 5.3 Flash EXL3 Dual-Node"
Cohesion: 0.18
Nodes (17): Shared frontier API key, GLM context ladder, DFlash/500K profile (GMU 0.86), DFlash/850K baseline profile, DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial, Step 16e shared evidence suite, GLM containers glm53-exl3-head / glm53-exl3-worker, InstantTensor loader budget fix (+9 more)

### Community 37 - "Credentials & Cloud Subscriptions"
Cohesion: 0.14
Nodes (15): Caddy, ChatGPT Plus subscription, Claude Code, Claude Pro subscription, Gemini API / Gemini CLI, Google AI Pro subscription, Herdr, ai-fleet declarative config repository (+7 more)

### Community 38 - "Jev & Laya Decision Models"
Cohesion: 0.21
Nodes (15): Jev (TypeSafe AI hosted decision API), Laya Local Decision Model, RTX PRO 5000 Jev Agent Decision Evaluation Tutorial, hermes-jev-skills Repository, JEV-as-a-Judge Cascade, Shadow-to-Active Progression, Jev Windows Trial (Playground then API), RTX PRO 5000 Laya Decision Model Tutorial (+7 more)

### Community 39 - "Pressure & Reuse Guard Tests"
Cohesion: 0.14
Nodes (3): PressureTests, ReuseTests, sample()

### Community 40 - "RTX 5000 llama.cpp Measurement"
Cohesion: 0.18
Nodes (16): RTX PRO 5000 Local Inference Measurement Tutorial, llama-server Windows CUDA build, Inference measurement decision record, MTP draft speculative decoding, One-GGUF experiment, Quantized KV cache (-ctk/-ctv), sudoingX llama.cpp flags X post, Time to first token (+8 more)

### Community 41 - "Desktop Qwen Publish & GLM Shim"
Cohesion: 0.15
Nodes (5): config_paths(), main(), transform(), BridgeServer, main()

### Community 42 - "DeepSeek V4.1 131K Comparison"
Cohesion: 0.16
Nodes (13): DeepSeek 131K Bring-Up Profile, DGX Spark DeepSeek 131K And SparkFast Comparison Protocol, Eight-Profile Raw Comparison Table, spark-fast Raw Reference Benchmark, Baseline .env Values, DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial, Host-Side Source Tests, DeepSeek LiteLLM Promotion (+5 more)

### Community 43 - "Qwen 3.8 Flash Next Dual-Node"
Cohesion: 0.18
Nodes (13): Independent dual-Spark Qwen FP8 recipes, Official vLLM Qwen3.8 Flash Next FP8 recipe, Qwen fixed cluster values, DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial, Qwen 3.8 Flash Next official FP8 lane, Dead huggingface-cli selection issue, Qwen 3.8 Flash Next NVFP4 dual-node baseline, NVFP4 per-node memory accounting (+5 more)

### Community 44 - "Hermes Provider Migration Scripts"
Cohesion: 0.24
Nodes (14): atomic_write(), digest(), explicit_desktop_references(), inside(), main(), endpoint(), lmstudio_references(), main() (+6 more)

### Community 45 - "Spark Operations Setup Guide"
Cohesion: 0.18
Nodes (11): DGX Spark Operations Setup Guide, LiteLLM route spark-fast, ~/ai navigable layout with store symlinks, qwen35 prepare.sh, Promote tested stack to 24x7, Human-readable registries (models.tsv, services.tsv, ports.tsv), spark-fast vLLM compose profile, capture-dgx-state.sh audit (+3 more)

### Community 46 - "Markdown-Backed Dashboard Design"
Cohesion: 0.19
Nodes (13): Claude Messages API, LLMWiki Vault, Obsidian Sync, Personal-Sync Vault, Dashboard MVP Acceptance Tests, Chokidar File Watcher + Server-Sent Events, Markdown Backed Interactive Dashboard Research, Spark Agent Report Feedback Dashboard (+5 more)

### Community 47 - "Dashboard Preview Server"
Cohesion: 0.26
Nodes (7): atomic_write(), Dashboard, library_state(), markdown_path(), note_state(), plain(), sha256()

### Community 48 - "Qwen Flash Next v0.30 Single-Node"
Cohesion: 0.17
Nodes (14): 100K-token context memory gate, 100-turn long-agent tool gate, Controlled LiteLLM and Hermes promotion (Steps 14-24), DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial, v0.30 fixed launch values, Upstream issue #48 long-agent premature stop, Memory, kernel, and preemption gate, memwatch memory watchdog (+6 more)

### Community 50 - "Muse Glimmer 30B Readiness"
Cohesion: 0.23
Nodes (11): Muse Glimmer vLLM Recipe, Spark-Fast + Nemotron five-session co-residency retest, Muse Glimmer vLLM compose profile, DGX Spark Muse Glimmer 30B Readiness Tutorial, Inferact/Muse-Glimmer-30B-NVFP4-W4A4 (not to substitute), LiteLLM route muse-glimmer, Muse-Glimmer-30B-assistant DFlash draft, prepare-muse-glimmer.sh (+3 more)

### Community 51 - "Nemotron Omni & Switch Procedure"
Cohesion: 0.18
Nodes (8): Nemotron Omni vLLM compose profile, Derived vLLM audio image, DGX Spark Nemotron 3 Nano Omni Tutorial, InvalidDefaultArgInFrom build warning, LiteLLM route nemotron3-omni, ~/ai/media mounted media directory, prepare-nemotron3-omni.sh, Nemotron Omni optimization verification 2026-08-15

### Community 52 - "LongCat Video Avatar Feasibility"
Cohesion: 0.20
Nodes (14): FlashAttention, LongCat-Video-Avatar 1.5, PyTorch, Whisper Large V3, WSL2 Ubuntu, LongCat Video Avatar 1.5 Workstation Feasibility Tutorial, One-clip 480p smoke test, LongCat pass criteria (+6 more)

### Community 54 - "Interactive Speed & Restart Probes"
Cohesion: 0.19
Nodes (4): measure(), main(), one(), post()

### Community 55 - "EVIE Retrieval & Social Model Exploration"
Cohesion: 0.23
Nodes (12): Tencent EVIE Visual Retriever, OpenMontage, PyTorch + ColPali Route, RTX PRO 5000 EVIE Visual Document Retrieval Tutorial, Multi-Vector Index Cost, EVIE Windows PowerShell Trial, Social Capture Local AI Model Exploration Guide, Per-experiment record template (+4 more)

### Community 56 - "Realtime Conversation Video"
Cohesion: 0.29
Nodes (9): AivisSpeech TTS, LTX-2.5, OpenAI-compatible input_audio LLM, diffusers-movie-server gateway, Realtime Conversation Video Windows Feasibility Tutorial, Time to first audio/frame and chunk metrics, Realtime_Conversation_Video client, Realtime_Narration_Video renderer (+1 more)

### Community 57 - "LM Studio SDK Loader"
Cohesion: 0.17
Nodes (6): args, client, config, options, require, sdkDirectory

### Community 60 - "Social Capture Pipeline"
Cohesion: 0.42
Nodes (7): Social Capture, Social Capture task provenance table, Social Capture Action Queue.md, Social Capture Pipeline, Queue lifecycle and monthly archive, Social Capture desktop dashboard, WhatsApp backlog importer

### Community 65 - "Logical Routes & Capability Aliases"
Cohesion: 0.40
Nodes (4): Baidu Unlimited-OCR, Logical route catalog (local/fast, local/code, local/deep, local/vision, cloud/*), Capability aliases (code-fast, reasoning-large, ocr-doc, embedding), Logical routes (fast, code, deep, vision, private-local, hosted-best)

### Community 66 - "Vision Test Image"
Cohesion: 0.33
Nodes (6): Blue Circles (2, top-right), Vision Check: Shape, Color, Count, Position, Frontier Model Vision Test (image), Green Squares (3, bottom-left), Red Triangle (1, top-left), Yellow Star (1, bottom-right)

### Community 69 - "Native Qwen Download Script"
Cohesion: 0.40
Nodes (4): HF_HUB_DISABLE_IMPLICIT_TOKEN, HF_XET_CACHE, HF_XET_NUM_CONCURRENT_RANGE_GETS, download_native_qwen.sh script

## Ambiguous Edges - Review These
- `DFlash2` → `qwen27-dflash alias`  [AMBIGUOUS]
  RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial.md · relation: conceptually_related_to
- `spark-fast alias` → `Background review routed to SecondSpark`  [AMBIGUOUS]
  hermes-qwen-desktop-lag-handoff-2026-09-28.md · relation: conceptually_related_to

## Knowledge Gaps
- **126 isolated node(s):** `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_NUM_CONCURRENT_RANGE_GETS`, `HF_XET_CACHE`, `Markdown Folder Import And Progress JSON`, `Discord Primary Phone Interface` (+121 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 308 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Qwen 3.8 27B Native Spark Setup Tutorial` connect `Qwen 3.8 27B Migration & Fresh Brief` to `Always-On Hermes & Roadmap Phases`, `Additional Models & Convenience Runtimes`, `Admission Proxy Code`, `Ollama, ODS & Open WebUI on Spark`, `Aux Services Controller & sparkDash`, `Multi-Model Engine Decisions`, `Gemma 4 & Spark/Workstation Placement`, `Native Download & Hermes Probes`, `Parallel Pinned Downloads`, `Native Qwen Qualification Probes`, `Reviewed Native Continuation`, `Native Install Finisher`, `Native Qwen Runner & Memory Diagnose`, `Hermes Serve/Gateway & Acceptance Gates`, `DGX Spark Hardware & Power Recovery`, `GLM 5.3 Flash EXL3 Dual-Node`, `Hermes Provider Migration Scripts`, `Muse Glimmer 30B Readiness`, `Interactive Speed & Restart Probes`?**
  _High betweenness centrality (0.266) - this node is a cross-community bridge._
- **What connects `HF_HUB_DISABLE_IMPLICIT_TOKEN`, `HF_XET_NUM_CONCURRENT_RANGE_GETS`, `HF_XET_CACHE` to the rest of the system?**
  _126 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Model Deployment & Install Matrix` be split into smaller, more focused modules?**
  _Cohesion score 0.06027306027306027 - nodes in this community are weakly interconnected._
- **Why does `Local Setup Index` connect `DGX Spark Hardware & Power Recovery` to `Model Deployment & Install Matrix`, `Qwen 3.8 27B Migration & Fresh Brief`, `Always-On Hermes & Roadmap Phases`, `One-Large-Model Rule & Recovery`, `Additional Models & Convenience Runtimes`, `VoiceStudio & Model Store Ownership`, `Ollama, ODS & Open WebUI on Spark`, `Agent Tooling & Skills Catalog`, `Qwen Image 2.1 ComfyUI Workflows`, `Frontier Hot-Swap Runbook & Aliases`, `Dual-Spark CX-7 Networking & NCCL`, `Aux Services Controller & sparkDash`, `Multi-Model Engine Decisions`, `Gemma 4 & Spark/Workstation Placement`, `Frontier Qualification Results`, `MiniMax H3 Video LoRAs`, `Dual-Node Frontier Recipes`, `Hermes Obsidian Sync Design`, `Hermes Serve/Gateway & Acceptance Gates`, `Bandwidth vs Capacity Placement`, `GLM 5.3 Flash EXL3 Dual-Node`, `Credentials & Cloud Subscriptions`, `Jev & Laya Decision Models`, `RTX 5000 llama.cpp Measurement`, `DeepSeek V4.1 131K Comparison`, `Qwen 3.8 Flash Next Dual-Node`, `Spark Operations Setup Guide`, `Markdown-Backed Dashboard Design`, `Qwen Flash Next v0.30 Single-Node`, `Muse Glimmer 30B Readiness`, `Nemotron Omni & Switch Procedure`, `LongCat Video Avatar Feasibility`, `EVIE Retrieval & Social Model Exploration`, `Realtime Conversation Video`?**
  _High betweenness centrality (0.132) - this node is a cross-community bridge._
- **Should `Qwen 3.8 27B Migration & Fresh Brief` be split into smaller, more focused modules?**
  _Cohesion score 0.05034965034965035 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `DFlash2` and `qwen27-dflash alias`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `spark-fast alias` and `Background review routed to SecondSpark`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._