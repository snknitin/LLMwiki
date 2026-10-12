# Qwen Spark migration staging

Status: installation in progress; model download and real inference qualification remain pending.

Read `../Qwen 3.8 27B Native Spark Setup Tutorial.md` for the final decision and reproducible procedure. The selected setup is native llama.cpp with a fresh Unsloth UD-Q5_K_XL download, four independent 262,144-token slots and Q4 K/V caches. It replaces Nemotron residency, retains spark-fast, and leaves Fresh Brief and Windows Ollama unchanged.

The finite `finish_native_install.py` continuation waits for the verified model, compares baseline against bundled MTP2, tests four simultaneous 100K and 240K inputs, tests four isolated Hermes research/coding sessions, and publishes the backed-up Hermes catalog only after passing. The admission endpoint is loopback port1235; internal llama-server is port1236. No separate output cap is added. Four sessions share GPU throughput; this is not a promise of zero delay or unlimited context.

LM Studio is stopped and disabled; its assets remain for rollback. The pinned native CUDA build is complete. The downloader preserves resumable partials and verifies the final SHA-256. Inspect `/home/snknitin/runs/qwen38-native/installation-status.json` for the current continuation stage; only `qualified_and_published` means the catalog was published. Old LM Studio/copy helpers are historical alternatives, not part of this installation. Do not run competing installers or downloaders.

The earlier incomplete Ollama copy remains separately under the LM Studio model directory. It is not an Unsloth file and should not be resumed as one. Existing Windows model files are untouched.
