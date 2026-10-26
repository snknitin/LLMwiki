#!/usr/bin/env bash
# Hermes coding A/B for the pair lanes: the same 3 tasks, each in a fresh copy, judged by hidden tests the model never
# sees. Run on FirstSpark from a copy of this folder (deployed as ~/ai/tools/pair-hermes-ab):
#   run.sh <label> <model> [task...]   e.g. run.sh glm glm53-flash ; run.sh deepseek deepseek41-flash-pair
# Results: ~/frontier-results/hermes-ab/<label>-<time>/<task>/{events.jsonl,pytest.txt} and summary.json
set -euo pipefail
label=${1:?label}; model=${2:?model}; shift 2
here=$(cd "$(dirname "$0")" && pwd)
out=$HOME/frontier-results/hermes-ab/$label-$(date +%Y%m%d-%H%M%S)
export PATH=$HOME/ai/tools/pair-ab-venv/bin:$HOME/.local/bin:$PATH   # pytest for the model and the judge
tasks=("$@"); [[ ${#tasks[@]} -gt 0 ]] || tasks=(t1-intervals t2-csvsum t3-orders)
for name in "${tasks[@]}"; do
  t=$here/$name; w=$out/$name/work; mkdir -p "$w"; cp -r "$t/repo/." "$w"
  start=$(date +%s)
  rc=0; timeout 2400 hermes chat -Q --format stream-json --provider custom:local-models -m "$model" --yolo \
    --max-turns 60 --in "$w" --query-file "$t/task.md" > "$out/$name/events.jsonl" 2> "$out/$name/stderr.txt" || rc=$?
  echo "$(( $(date +%s) - start )) $rc" > "$out/$name/time-rc.txt"
  cp "$t/hidden_test.py" "$w/test_hidden_zz.py"
  (cd "$w" && python3 -m pytest -q -p no:cacheprovider .) > "$out/$name/pytest.txt" 2>&1 || true
  echo "$name: $(tail -1 "$out/$name/pytest.txt"), $(cat "$out/$name/time-rc.txt") (s, hermes rc)"
done
python3 "$here/summarize.py" "$out" 2>/dev/null || echo "raw results: $out"
