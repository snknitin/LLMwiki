"""Design gate: a UI slice is done only when this prints DESIGN GATE PASS.

1. Token check (no model): no colour literal in UI code outside the token file named in design/gate.json.
2. Judge: a model from a different family than the builder scores each screenshot against the picked
   reference in design/reference/ and DESIGN.md, and writes design/reviews/<time>.md.

    python scripts/design_gate.py --judge claude [--screens a.png b.png]   # Codex built it
    python scripts/design_gate.py --judge codex                            # Claude built it
    python scripts/design_gate.py --tokens-only
    python scripts/design_gate.py --self-test
"""
import argparse
import datetime
import json
import pathlib
import re
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
COLOUR = re.compile(r"#[0-9A-Fa-f]{3,8}\b|\brgba?\(|\bhsla?\(")
UI_EXT = {".ts", ".tsx", ".js", ".jsx", ".svelte", ".vue", ".css", ".html"}
SKIP = re.compile(r"node_modules|__tests__|\.test\.|\.spec\.|/dist/|/build/|/\.svelte-kit/")
AXES = ["direction", "hierarchy", "layout", "typography", "colour", "polish", "restraint"]

RUBRIC = """You are the design judge for this app. A different model built it; be the demanding art director it needs.

Read DESIGN.md (the identity and rules), then look at every image in design/reference/ (the direction the owner picked:
one screen, at desktop and phone width). Then judge each screenshot listed below. Other screens than the reference must
feel like the same product: same palette, type, signature element and level of finish.

Score each screenshot 1-10 on:
- direction: matches the picked identity (palette, type pairing, signature element, layout idea). A generic styled document is 4 or less.
- hierarchy: one clear primary thing; summary before detail; the eye knows where to go.
- layout: composition, alignment, the spacing scale, density that fits the job; no dead space, no cramming.
- typography: the pairing is used deliberately, a clear scale, readable measure, aligned figures.
- colour: tokens only, 60-30-10, accent used with restraint, contrast holds.
- polish: designed hover/focus/empty/error states where visible, no browser-default controls, repeated elements consistent, the phone layout works.
- restraint: no eyebrow captions over headings, no slogans, no sentence explaining a panel, no decoration that means nothing.
Then an overall score (your judgement, not an average): 7 means you would ship it to this owner; 8+ means it is distinctive.

Reply with the JSON only, between <result> and </result>:
<result>{"screens": [{"file": "<path>", "scores": {"direction": 0, "hierarchy": 0, "layout": 0, "typography": 0, "colour": 0, "polish": 0, "restraint": 0}, "overall": 0, "findings": ["<the most important fix first, one sentence each>"]}]}</result>

Screenshots to judge:
"""


def config():
    return json.loads((ROOT / "design" / "gate.json").read_text(encoding="utf-8"))


def token_violations(cfg):
    tokens = {(ROOT / t).resolve() for t in cfg["tokens"]}
    bad = []
    for top in cfg["ui"]:
        for path in sorted((ROOT / top).rglob("*")):
            rel = path.relative_to(ROOT).as_posix()
            if path.suffix not in UI_EXT or not path.is_file() or path.resolve() in tokens or SKIP.search("/" + rel):
                continue
            for n, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
                if COLOUR.search(line) and "design-gate: allow" not in line:
                    bad.append(f"{rel}:{n}: {line.strip()[:120]}")
    return bad


def parse(text):
    found = re.findall(r"<result>(.*?)</result>", text, re.S)
    if not found:
        raise ValueError("judge gave no <result> block")
    return json.loads(found[-1])


def verdict(result, threshold):
    """(passed, failing screen files): every screen needs overall >= threshold and no axis below 5."""
    failing = [s["file"] for s in result["screens"]
               if s["overall"] < threshold or min(s["scores"][a] for a in AXES) < 5]
    return not failing and bool(result["screens"]), failing


def judge(name, screens):
    prompt = RUBRIC + "\n".join(f"- {s}" for s in screens) + "\n"
    if name == "claude":
        cmd = [shutil.which("claude") or "claude", "-p", "--model", "opus", "--allowedTools", "Read"]
    elif name == "codex":
        cmd = [shutil.which("codex") or "codex", "exec", "--skip-git-repo-check", "--sandbox", "read-only"]
        for image in screens + [p.relative_to(ROOT).as_posix() for p in sorted((ROOT / "design" / "reference").glob("*.png"))]:
            cmd += ["-i", image]
        cmd.append("-")
    else:
        sys.exit(f"unknown judge {name}")
    run = subprocess.run(cmd, input=prompt, capture_output=True, text=True, encoding="utf-8", cwd=ROOT, timeout=1800)
    if run.returncode:
        sys.exit(f"DESIGN GATE ERROR: the {name} judge failed: {run.stderr.strip()[-400:]}")
    return parse(run.stdout)


def report(result, name, passed, failing, threshold):
    stamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    rows = ["| Screen | " + " | ".join(AXES) + " | overall |", "|---" * (len(AXES) + 2) + "|"]
    for s in result["screens"]:
        rows.append(f"| `{s['file']}` | " + " | ".join(str(s["scores"][a]) for a in AXES) + f" | **{s['overall']}** |")
    findings = [f"- `{s['file']}`: {f}" for s in result["screens"] for f in s.get("findings", [])]
    text = (f"# Design review {stamp}\n\nJudge: {name}. Pass bar: overall {threshold}+ and no axis below 5. "
            f"Result: **{'PASS' if passed else 'FAIL'}**{'' if passed else ' (' + ', '.join(failing) + ')'}.\n\n"
            + "\n".join(rows) + "\n\n## Findings\n\n" + ("\n".join(findings) or "- none") + "\n")
    out = ROOT / "design" / "reviews" / f"{stamp.replace(' ', '-').replace(':', '')}.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8")
    return out


def self_test():
    good = {"screens": [{"file": "a.png", "scores": dict.fromkeys(AXES, 8), "overall": 8, "findings": []}]}
    weak = {"screens": [{"file": "b.png", "scores": {**dict.fromkeys(AXES, 8), "restraint": 4}, "overall": 8, "findings": ["x"]}]}
    assert verdict(good, 7) == (True, [])
    assert verdict(weak, 7) == (False, ["b.png"])
    assert verdict({"screens": []}, 7)[0] is False
    assert parse("noise <result>" + json.dumps(good) + "</result> tail") == good
    assert COLOUR.search("color: '#2E2C29'") and COLOUR.search("rgb(0 0 0 / .16)") and not COLOUR.search("var(--ink)")
    print("self-test ok")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--judge", choices=["claude", "codex"])
    ap.add_argument("--screens", nargs="*")
    ap.add_argument("--tokens-only", action="store_true")
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        return self_test()
    cfg = config()
    bad = token_violations(cfg)
    if bad:
        print("Colour literals outside the token file (move them into tokens):\n  " + "\n  ".join(bad))
        sys.exit("DESIGN GATE FAIL: tokens")
    print(f"tokens ok ({', '.join(cfg['tokens'])})")
    if a.tokens_only:
        return
    if not a.judge:
        sys.exit("pass --judge claude (Codex built it) or --judge codex (Claude built it)")
    screens = a.screens or sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / cfg["screens"]).glob("*.png"))[:12]
    if not screens:
        sys.exit(f"DESIGN GATE FAIL: no screenshots in {cfg['screens']}; run verify first")
    result = judge(a.judge, screens)
    threshold = cfg.get("threshold", 7)
    passed, failing = verdict(result, threshold)
    print(f"review: {report(result, a.judge, passed, failing, threshold).relative_to(ROOT).as_posix()}")
    print("DESIGN GATE PASS" if passed else f"DESIGN GATE FAIL: {', '.join(failing)}")
    sys.exit(0 if passed else 1)


if __name__ == "__main__":
    main()
