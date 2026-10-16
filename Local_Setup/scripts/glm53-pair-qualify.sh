#!/usr/bin/env bash
# Standardized qualification of the SecondSpark+ThirdSpark GLM 5.3 Flash TensorFold pair. Run on FirstSpark:
#   glm53-pair-qualify.sh <profile>      e.g. glm53-flash-tf-fp8
#   MODEL=Qwen3.8-Flash-Next CONTAINER=qwen38-fn-tf ENDPOINT=http://192.168.100.11:8889 glm53-pair-qualify.sh qwen38-flash-tf-pair   (the Qwen swap lane)
# Same probe as DGX Spark Frontier Model Qualification Results, plus a code-prompt ladder and a thinking loop check.
set -euo pipefail
profile=${1:?profile}
test "$(hostname)" = spark-07a8 || { echo 'STOP: run on FirstSpark'; exit 1; }
probe="$HOME/ai/tools/frontier-model-probe.py"
model=${MODEL:-GLM-5.3-Flash-EXL3}
container=${CONTAINER:-glm53-flash-tf}
endpoint=${ENDPOINT:-http://192.168.100.11:8888}
floor_kib=$((4 * 1024 * 1024))   # recipe's documented low-water is ~5 GiB under a 1M prompt; stop below 4
code_prompt='Write a complete Python module implementing a thread-safe LRU cache with per-entry TTL expiry, type hints and docstrings, followed by pytest unit tests covering eviction order, expiry and concurrent access. Output only code.'

python3 "$probe" init --profile "$profile" --model "$model" --endpoint "$endpoint" --max-context 1048576
run="$(readlink -f "$HOME/frontier-results/$profile/latest")"
started="$(date -Is)"
for h in head:192.168.100.11 worker:ThirdSpark; do
  ( while true; do ssh -o BatchMode=yes -o ConnectTimeout=5 "${h#*:}" "awk '/^MemAvailable:/ {print \$2}' /proc/meminfo" >> "$run/${h%%:*}-memavailable-kib.txt" || break; sleep 2; done ) &
done
trap 'kill $(jobs -p) 2>/dev/null || true' EXIT

check_safety() {
  for side in head:192.168.100.11 worker:ThirdSpark; do
    f="$run/${side%%:*}-memavailable-kib.txt"
    min="$(awk 'NR==1 || $1 < m {m=$1} END {print m+0}' "$f")"
    printf '%s MIN_MEMAVAILABLE_KIB=%s\n' "${side%%:*}" "$min" | tee -a "$run/qualification-monitor.txt"
    test "$min" -ge "$floor_kib" || { echo "STOP: ${side%%:*} below 4 GiB MemAvailable"; exit 1; }
    ssh -o BatchMode=yes "${side#*:}" "journalctl -k --since '$started' --no-pager" > "$run/${side%%:*}-kernel.txt"
    ! grep -Eiq 'NV_ERR_NO_MEMORY|NVRM.*Xid|Out of memory|oom-killer' "$run/${side%%:*}-kernel.txt" || { echo "STOP: kernel error on ${side%%:*}"; exit 1; }
    ssh -o BatchMode=yes "${side#*:}" "test \"\$(docker inspect -f '{{.State.Running}}' $container)\" = true" || { echo "STOP: rank stopped on ${side%%:*}"; exit 1; }
  done
}

python3 "$probe" identity --profile "$profile"
python3 "$probe" chat --profile "$profile" --max-tokens 1024
python3 "$probe" tool --profile "$profile" --max-tokens 512
python3 "$probe" vision --profile "$profile" --image "$HOME/test-assets/frontier-vision-test.png" --max-tokens 768
check_safety
python3 "$probe" concurrency --profile "$profile" --levels 1,2,4 --max-tokens 512 --minimum-tokens 128
check_safety
python3 "$probe" concurrency --profile "$profile" --levels 1,2,4 --max-tokens 512 --minimum-tokens 128 --label code --prompt "$code_prompt"
check_safety

# Loop check: thinking on at max effort, the server's own sampling; each must stop on its own inside the budget.
python3 - "$endpoint" "$run/loop-check.json" "$model" <<'PY'
import json, sys, time, urllib.request
endpoint, out, model = sys.argv[1:4]
prompts = [
    "How many times does the letter r appear in 'strawberry raspberry cranberry'? Answer with the number.",
    "A bat and a ball cost $1.10 in total. The bat costs $1.00 more than the ball. How much is the ball? Then list three similar trick questions with answers.",
    "Find the bug: def mean(xs): return sum(xs) / len(xs) - 1. Explain it and give the fixed function.",
]
rows = []
for p in prompts:
    body = {"model": model, "messages": [{"role": "user", "content": p}], "max_tokens": 32768, "reasoning_effort": "max"}
    req = urllib.request.Request(f"{endpoint}/v1/chat/completions", json.dumps(body).encode(), {"Content-Type": "application/json"})
    t = time.perf_counter(); r = json.load(urllib.request.urlopen(req, timeout=3600)); e = time.perf_counter() - t
    c = r["choices"][0]; u = r.get("usage", {})
    rows.append({"prompt": p, "finish_reason": c.get("finish_reason"), "completion_tokens": u.get("completion_tokens"),
                 "elapsed_s": round(e, 2), "tok_s": round(u.get("completion_tokens", 0) / e, 2), "usage": u,
                 "reasoning_chars": len(c["message"].get("reasoning_content") or ""), "answer": c["message"].get("content")})
    print(json.dumps({k: rows[-1][k] for k in ("finish_reason", "completion_tokens", "elapsed_s", "tok_s")}))
passed = all(x["finish_reason"] == "stop" and (x["answer"] or "").strip() for x in rows)
json.dump({"passed": passed, "rows": rows}, open(out, "w"), indent=2)
print("LOOP_CHECK_OK" if passed else "LOOP_CHECK_FAILED")
PY
check_safety

for rung in 30000 195000 790000; do
  python3 "$probe" context --profile "$profile" --filler-counts "$rung" --max-tokens 64 --timeout 7200
  check_safety
done
printf 'GLM_PAIR_QUALIFY_PASS=%s\n' "$run"
