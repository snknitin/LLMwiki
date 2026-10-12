# Native Qwen long-input qualification guards

The user-selected candidate uses **four independent 262,144-token slots**, with **1,048,576 total context allocation**, `--no-kv-unified`, and **Q4_0 K and V caches**. The model weights remain **UD-Q5_K_XL**. Lowering KV precision does not change the weight file to Q4, and retaining Q5 weights does not prove KV quantization has no effect on quality.

The earlier four-slot Q8 estimate was about 34 GiB KV + 19.44 GiB Q5 XL weight file + 47.7 GiB existing vLLM allocation = 101.14 GiB, before all other memory and runtime overhead. Four Q4_0 caches should need materially less KV memory, but block metadata, recurrent state, checkpoints, temporary buffers and host use still matter. File size is not a complete resident-memory measurement. The actual allocation and long-prefill peak decide acceptance. Spark-Fast is not changed by this probe.

`probe_qwen_long.py` sends requests only to an already resident native alias. Run it **on FirstSpark** using the actual loopback server port and PID. It checks total context, slot count, separate/unified mode, per-slot context, and K/V cache quantization against launch flags and native slot metadata before inference. It requires four idle server slots even when testing only one or two clients. `/slots` must be available to observe concurrency. Separate mode is the default, with four clients, 1,048,576 total capacity and Q4_0 caches; supplying only 524,288 total capacity in separate mode is rejected.

The guard has two separate policies:

- **20 GiB MemAvailable is the qualification pass target.** Any observed drop below it fails the memory gate, even if all answers are correct. It does not automatically change context, quantization, concurrency or server configuration.
- **8 GiB is an emergency abort threshold.** Crossing it closes all test sockets, including during silent prefill. Sustained swap-out of at least 8 MiB/s for five seconds also aborts. Any positive swap-out delta fails the final conservative memory gate; pre-existing swap usage alone does not fail it.

Sampling increases from 0.5 seconds to 0.1 seconds below the target. Missing initial Linux telemetry prevents requests; three successive telemetry failures during a run cancel them. A total deadline also closes sockets independently of SSE output. This is a bounded watchdog, not a guarantee against sudden GPU/host failure. Verify server slots return idle after cancellation; the helper never stops the model service.

Use an explicit model port and the PID from the approved native service. Begin with short correctness/tool tests and one long request. Then, in a **FirstSpark terminal**, qualify four overlapping 100K inputs:

```bash
python3 probe_qwen_long.py --base http://127.0.0.1:1236/v1 --server-pid PID --kv-mode separate --parallel 4 --context 262144 --kv-capacity-tokens 1048576 --server-slots 4 --cache-k q4_0 --cache-v q4_0 --repetitions 100000 --min-prompt-tokens 100000 --output q4-four-100k.json
```

After that test passes and memory recovers, qualify four overlapping near-full inputs:

```bash
python3 probe_qwen_long.py --base http://127.0.0.1:1236/v1 --server-pid PID --kv-mode separate --parallel 4 --context 262144 --kv-capacity-tokens 1048576 --server-slots 4 --cache-k q4_0 --cache-v q4_0 --repetitions 240000 --min-prompt-tokens 240000 --output q4-four-240k.json
```

Replace `PID` with the actual native worker PID and verify that 1236 is its direct backend port. The first test requires four actual server-reported inputs of at least 100K tokens. The second requires four inputs of at least 240K each, while leaving output room inside each independent 262K window. Repetition counts are not tokenizer evidence. Final receipts require successful marker retrieval, normal stream completion, actual usage, aggregate usage within the allocated capacity, observed simultaneously busy native slots, and the memory gate. The helper never reduces context or clients to obtain a pass.

## Research quality is a separate gate

The checkpoint fixture tests distant literal retrieval. It cannot establish research quality, reasoning quality, or that Q4 KV is equivalent to Q8 KV. After the capacity ladder, run bounded representative Hermes research sessions against the selected Q4 configuration, using a fixed source packet and task with an independently reviewable expected result. Include source claims near the beginning, middle and end; require cited evidence, contradictory-source handling, correct quantities/dates, and an explicit unresolved-questions section. Evaluate unsupported claims, citation correctness, missed counter-evidence, task completion and tool failures. Record actual prompt length, wall time and model/cache identity alongside the reviewer result. Repeat with four concurrent independent tasks, not four cloned transcripts of a single conversation.

An optional **paired Q8 control at one or two concurrent requests** is the useful way to measure a possible cache-quality difference. It must use the identical Q5 weight hash, runtime build, prompts/source packet, effective context, output budget, sampling, speculation mode and scoring rubric; only KV precision should differ. The control's smaller total allocation is a benchmark configuration, not a silent reduction of the selected four-slot Q4 deployment. Do not run both workers concurrently or alter a live worker merely to create this control. Use an explicitly reserved change window and restore the selected configuration afterward. If no matched Q8 control is performed, report absolute Q4 test outcomes and keep the comparative quality claim unverified.

## Retained unified alternative

The previous **524,288-token unified Q8 pool** remains testable with explicit `--kv-mode unified --kv-capacity-tokens 524288 --cache-k q8_0 --cache-v q8_0`. Its worker must expose four slots capped through `--kv-unified-per-slot 262144`. It admits 2×240K or 4×100K inputs; **4×240K is rejected before metadata/inference**. This is an alternative profile, not the currently selected four-independent-slot configuration.

Receipts include explicit KV mode/cache types, total and independent-slot capacity, allowlisted launch flags, separate response/memory/concurrency/capacity gates, memory samples, swap deltas and safe slot metadata. They exclude model input and generated text. Synthetic capacity success does not replace the research-quality gate or prove every future prompt mix and sustained thermal stability.

The original helper is retained as `probe_qwen_long.py.before-20261012-four-slot-guard`. `test_probe_qwen_long.py` uses fake HTTP connections and local socket pairs only; its cancellation tests do not contact a model. No live qualification is claimed by this implementation.
