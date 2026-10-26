"""Score one run.sh result folder: hidden tests, time, tool use, loops, and which model(s) Hermes actually used.

Usage: python3 summarize.py ~/frontier-results/hermes-ab/<label>-<time>   (writes summary.json there and prints a table)
"""
import json
import os
import sqlite3
import subprocess
import sys

out = sys.argv[1]
here = os.path.dirname(os.path.abspath(__file__))
db = sqlite3.connect(f"file:{os.path.expanduser('~/.hermes/state.db')}?mode=ro", uri=True)
rows = []
for name in sorted(d for d in os.listdir(out) if os.path.isdir(os.path.join(out, d))):
    d = os.path.join(out, name)
    events = []
    for line in open(os.path.join(d, "events.jsonl")):
        try:
            events.append(json.loads(line))
        except ValueError:
            pass
    calls = [e for e in events if e.get("type") == "tool_use"]
    results = [e for e in events if e.get("type") == "tool_result"]
    # loop sign: the longest run of back-to-back identical tool calls
    longest = run = 0
    prev = None
    for e in calls:
        key = (e.get("name"), json.dumps(e.get("input"), sort_keys=True))
        run = run + 1 if key == prev else 1
        longest, prev = max(longest, run), key
    final = next((e for e in events if e.get("type") == "result"), {})
    sid = final.get("session_id") or next((e.get("session_id") for e in events if e.get("session_id")), "")
    models = [m for (m,) in db.execute("select model from session_model_usage where session_id = ?", (sid,))]
    secs, rc = open(os.path.join(d, "time-rc.txt")).read().split()
    tail = open(os.path.join(d, "pytest.txt")).read().strip().splitlines()[-1:] or [""]
    # the task-1 prompt forbids touching the existing tests
    edited = subprocess.run(["diff", "-r", os.path.join(here, name, "repo", "tests"), os.path.join(d, "work", "tests")],
                            capture_output=True).returncode != 0 if name.startswith("t1") else None
    rows.append({
        "task": name, "hidden_pass": "passed" in tail[0] and "failed" not in tail[0] and "error" not in tail[0],
        "pytest": tail[0], "seconds": int(secs), "hermes_rc": int(rc), "tool_calls": len(calls),
        "tool_errors": sum(bool(e.get("is_error")) for e in results), "longest_repeat": longest,
        "models": models, "output_tokens": (final.get("tokens") or {}).get("output"), "edited_given_tests": edited,
        "session_id": sid,
    })
json.dump(rows, open(os.path.join(out, "summary.json"), "w"), indent=2)
print(f"{'task':14} {'hidden':6} {'secs':>5} {'calls':>5} {'errs':>4} {'repeat':>6} {'out_tok':>7}  models")
for r in rows:
    print(f"{r['task']:14} {'PASS' if r['hidden_pass'] else 'FAIL':6} {r['seconds']:>5} {r['tool_calls']:>5} "
          f"{r['tool_errors']:>4} {r['longest_repeat']:>6} {r['output_tokens'] or 0:>7}  {','.join(r['models']) or '?'}")
