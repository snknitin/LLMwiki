"""Soak a pair lane with mixed load and record what breaks. Run on FirstSpark (deployed as ~/ai/tools/pair-soak):

    python3 soak.py --minutes 120 --model deepseek41-flash-pair --label deepseek-eaq

Each cycle: 4 concurrent Hermes coding sessions that read a long source file (long contexts, many tool calls), plus,
every other cycle, one ~330K-token needle prompt sent straight to the lane at the same time (bench.py on the head);
then health and kernel checks, a 4-minute idle gap, and a timed probe after the idle (issue #51's hang after idle).
Watches the DeepSeek recipe's open issues: #65 (a long prompt leaves CUDA graphs broken), #51 (hang after idle),
#47 (worker lockup, mlx5 AER). Memory is sampled on the head by mem-sample.sh (started separately).
Results: ~/frontier-results/soak/<label>-<time>/events.jsonl, one JSON object per check.
"""
import argparse
import concurrent.futures as cf
import json
import os
import shutil
import subprocess
import tempfile
import time
import urllib.request

ap = argparse.ArgumentParser()
ap.add_argument("--minutes", type=float, default=120)
ap.add_argument("--model", default="deepseek41-flash-pair")
ap.add_argument("--label", default="soak")
ap.add_argument("--endpoint", default="http://192.168.100.11:8890")
ap.add_argument("--served", default="DeepSeek-V4.1-Flash-1017")
ap.add_argument("--container", default="dsv41-1017-exl3-tf")
ap.add_argument("--long-tokens", type=int, default=330000)
ap.add_argument("--idle-s", type=int, default=240)
args = ap.parse_args()

out = os.path.expanduser(f"~/frontier-results/soak/{args.label}-{time.strftime('%Y%m%d-%H%M%S')}")
os.makedirs(out)
log = open(os.path.join(out, "events.jsonl"), "a", buffering=1)
start = time.time()
env = dict(os.environ, PATH=os.path.expanduser("~/ai/tools/pair-ab-venv/bin:~/.local/bin:") + os.environ["PATH"])
NODES = {"head": "192.168.100.11", "worker": "ThirdSpark"}
SOURCES = ["argparse.py", "subprocess.py", "inspect.py", "typing.py"]  # 2,000-3,700 lines each, from /usr/lib/python3.12
TASK = ("Read {f} in this directory completely (it is long; read all of it, in parts if needed). Then write REPORT.md "
        "listing every public class and top-level function with a one-line description each, and write test_{m}.py "
        "with five pytest tests that exercise behaviour you found in the file (import it from the standard library, "
        "not from this copy). Run `python3 -m pytest -q test_{m}.py` and fix the tests until they pass. "
        "Reply with the number of passing tests.")


def event(kind, **kw):
    kw.update(kind=kind, t=round(time.time() - start, 1), at=time.strftime("%H:%M:%S"))
    log.write(json.dumps(kw) + "\n")
    print(json.dumps(kw), flush=True)


def ssh(host, cmd, timeout=60):
    r = subprocess.run(["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=10", host, cmd],
                       capture_output=True, text=True, timeout=timeout)
    return r.returncode, r.stdout.strip()


def probe(timeout=180):
    body = {"model": args.served, "messages": [{"role": "user", "content": "Reply with exactly: SOAK_OK"}],
            "max_tokens": 20, "chat_template_kwargs": {"thinking": False}}
    req = urllib.request.Request(f"{args.endpoint}/v1/chat/completions", json.dumps(body).encode(),
                                 {"Content-Type": "application/json"})
    t = time.time()
    try:
        r = json.load(urllib.request.urlopen(req, timeout=timeout))
        return {"ok": "SOAK_OK" in (r["choices"][0]["message"].get("content") or ""), "s": round(time.time() - t, 2)}
    except Exception as e:  # a hang or a dead server is exactly what the soak looks for
        return {"ok": False, "s": round(time.time() - t, 2), "error": repr(e)[:300]}


since = time.strftime("%Y-%m-%d %H:%M:%S")
started_at = {}


def checks(phase):
    p = probe()
    nodes = {}
    for name, host in NODES.items():
        rc, st = ssh(host, f"docker inspect -f '{{{{.State.Running}}}} {{{{.State.StartedAt}}}} {{{{.RestartCount}}}}' {args.container}")
        rc2, kern = ssh(host, f"journalctl -k --since '{since}' --no-pager | grep -Ei 'xid|NV_ERR_NO_MEMORY|AER|mlx5.*(err|fatal)|oom|hung_task|soft lockup' | tail -5")
        rc3, mem = ssh(host, "awk '/^MemAvailable:/ {print $2}' /proc/meminfo")
        started_at.setdefault(name, st.split()[1] if st else "")
        nodes[name] = {"container": st, "restarted": bool(st) and st.split()[1] != started_at[name],
                       "kernel": kern, "mem_gib": round(int(mem or 0) / 1048576, 2)}
    event("check", phase=phase, probe=p, nodes=nodes)
    return p["ok"] and all(n["container"].startswith("true") and not n["restarted"] for n in nodes.values())


def hermes(i, cycle):
    src = SOURCES[i % len(SOURCES)]
    w = tempfile.mkdtemp(prefix=f"soak-c{cycle}-s{i}-", dir=out)
    shutil.copy(f"/usr/lib/python3.12/{src}", w)
    t = time.time()
    try:
        r = subprocess.run(["hermes", "chat", "-Q", "--format", "stream-json", "--provider", "custom:local-models",
                            "-m", args.model, "--yolo", "--max-turns", "40", "--in", w,
                            "-q", TASK.format(f=src, m=src[:-3])],
                           capture_output=True, text=True, timeout=2400, env=env)
        rc = r.returncode
        events = [json.loads(l) for l in r.stdout.splitlines() if l.startswith("{")]
    except subprocess.TimeoutExpired:
        rc, events = "timeout", []
    final = next((e for e in events if e.get("type") == "result"), {})
    calls = sum(e.get("type") == "tool_use" for e in events)
    tests = subprocess.run(["python3", "-m", "pytest", "-q", "-p", "no:cacheprovider", w], capture_output=True,
                           text=True, env=env, cwd=w).stdout.strip().splitlines()[-1:]
    return {"session": i, "file": src, "rc": rc, "s": round(time.time() - t, 1), "tool_calls": calls,
            "tokens": final.get("tokens"), "pytest": tests[0] if tests else "", "session_id": final.get("session_id")}


def long_prompt(cycle):
    t = time.time()
    rc, outp = ssh(NODES["head"], "cd ~/src/frontier/deepseek41-1017-tf && python3 -I tools/bench.py --url http://127.0.0.1:8890 "
                   f"--model {args.served} --suite needle --needle-sizes {args.long_tokens} --depths 0.5 --timeout 3600 "
                   f"--label soak-c{cycle} --out ~/src/frontier/dsv41-runs/soak-needle-c{cycle}.json 2>&1 | grep -E 'needle  prompt|errors'",
                   timeout=3900)
    return {"rc": rc, "s": round(time.time() - t, 1), "result": outp[-400:]}


cycle = 0
healthy = checks("start")
while healthy and time.time() - start < args.minutes * 60:
    cycle += 1
    with cf.ThreadPoolExecutor(5) as ex:
        sessions = [ex.submit(hermes, i, cycle) for i in range(4)]
        longf = ex.submit(long_prompt, cycle) if cycle % 2 == 1 else None
        for f in sessions:
            event("hermes", cycle=cycle, **f.result())
        if longf:
            event("long_prompt", cycle=cycle, tokens=args.long_tokens, **longf.result())
    healthy = checks(f"cycle {cycle} after load")
    if not healthy:
        break
    time.sleep(args.idle_s)
    healthy = checks(f"cycle {cycle} after {args.idle_s} s idle")
event("end", cycles=cycle, healthy=healthy, minutes=round((time.time() - start) / 60, 1))
