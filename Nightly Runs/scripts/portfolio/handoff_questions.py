"""Surface each project's open BUILD_SPEC §6 decisions where the Agents board and the overnight runner look.

Writes a generated block into <project>/REPORT.md under "## Open questions", using the Q-block format from
Nightly Runs/agent-rules/AGENTS.md, so the questions appear in the board's "Needs input" panel, in Preflight and in
morning triage. Vetoable assumptions go in a separate section whose heading neither tool treats as questions.
It also refreshes the one-line pointer under the README title. DECISIONS.md is left to its real job (decisions made,
plus the board's "## Owner answers"), except that a leftover generated handoff from 2026-10-20 is removed there.

Usage:  python handoff_questions.py <projects_root> <project> [<project> ...] [--dry-run]
Re-running is safe: it replaces its own marked block and pointer and never touches answered questions elsewhere.
"""
import re
import sys
from pathlib import Path

START, END = "<!-- prebuild-handoff:start -->", "<!-- prebuild-handoff:end -->"
POINTER_MARK = "**Before you build:**"
OLD_HANDOFF_TITLE = "# Decisions before building "


def section6(spec: str) -> str:
    m = re.search(r"^## 6\..*?$(.*?)(?=^## 7\.)", spec, re.S | re.M)
    return m.group(1) if m else ""


def items(sec: str) -> list[tuple[int, str]]:
    out, cur = [], None
    for line in sec.splitlines():
        m = re.match(r"^(\d+)\.\s+(.*)", line)
        if m:
            if cur:
                out.append(cur)
            cur = [int(m.group(1)), m.group(2)]
        elif cur and line.strip():
            cur[1] += " " + line.strip()
    if cur:
        out.append(cur)
    return [(n, re.sub(r"\s+", " ", t).strip()) for n, t in out]


def classify(text: str) -> str:
    if re.search(r"(?<![Nn]on-)(?<!NON-)BLOCKING", text):
        return "blocking"
    if re.search(r"Proposed change|README proposed change|Requires DCC change", text):
        return "proposal"
    if (re.search(r"\*\*(Open )?[Qq]uestion|Question[^a-z]|\bdecide\b|\bConfirm\b|\?\s|\?$", text)
            or re.search(r"owner (must|picks|to supply|decides|should)|^\**open\b", text, re.I)):
        return "question"
    return "assumption"


def groups_for(spec: str) -> dict[str, list[tuple[int, str]]]:
    g = {"blocking": [], "question": [], "proposal": [], "assumption": []}
    for n, t in items(section6(spec)):
        g[classify(t)].append((n, t))
    return g


def title_of(text: str, limit: int = 150) -> str:
    t = text.replace("**", "").replace("`", "")
    return t if len(t) <= limit else t[: limit - 1].rstrip() + "…"


def block(g) -> str:
    kinds = (("blocking", "blocking", "none for the task it names (blocked until answered); work that §6 says can proceed meanwhile continues"),
             ("question", "question", None),
             ("proposal", "proposed README/contract change", None))
    lines = [START, "## Open questions", "",
             "Pre-build handoff generated from BUILD_SPEC.md §6, most urgent first. Answer in the Agents board's Needs input "
             "panel (answers land in DECISIONS.md) or tick an option here. Each question cites its §6 item, where the full "
             "context lives.", ""]
    q = 0
    for key, label, default in kinds:
        for n, t in g[key]:
            q += 1
            lines += [f"### Q{q} (text): {title_of(t)}",
                      f"BUILD_SPEC §6.{n} · {label} — {t}",
                      f"Default: {default or f'proceed with the default stated in BUILD_SPEC §6.{n}'}", ""]
    if not q:
        lines += ["(none: only vetoable assumptions, listed below)", ""]
    lines += ["## Spec assumptions you can veto", "",
              "The spec proceeds with these unless you object; each links to its §6 item.", ""]
    lines += [f"- §6.{n} — {title_of(t, 190)}" for n, t in g["assumption"]] or ["- (none)"]
    lines += ["", END]
    return "\n".join(lines) + "\n"


def write_report(path: Path, text: str):
    cur = path.read_text(encoding="utf-8") if path.exists() else "# Report\n"
    if START in cur and END in cur:
        new = cur[: cur.index(START)] + text + cur[cur.index(END) + len(END):].lstrip("\n")
    else:
        new = cur.rstrip("\n") + "\n\n" + text
    path.write_text(new, encoding="utf-8", newline="\n")


def pointer(g) -> str:
    nq = len(g["blocking"]) + len(g["question"]) + len(g["proposal"])
    if not nq:
        return f"> {POINTER_MARK} no open questions; review the vetoable assumptions in [REPORT.md](REPORT.md)."
    nb = len(g["blocking"])
    lead = f"{nq} open question{'s' * (nq != 1)}" + (f" ({nb} blocking)" if nb else "")
    return (f"> {POINTER_MARK} {lead} waiting in [REPORT.md](REPORT.md) — they also appear in the Agents board's "
            "**Needs input** panel.")


def set_pointer(readme: str, line: str) -> str:
    text = "\n".join(ln for ln in readme.splitlines() if POINTER_MARK not in ln)
    text = re.sub(r"\n{3,}", "\n\n", text)
    m = re.search(r"^# .*$", text, re.M)
    out = (line + "\n\n" + text.lstrip("\n")) if not m else text[: m.end()] + "\n\n" + line + "\n\n" + text[m.end():].lstrip("\n")
    return out if out.endswith("\n") else out + "\n"


def clean_old_decisions(path: Path) -> str:
    """Remove the 2026-10-20 generated handoff from DECISIONS.md; keep any board answers that landed there."""
    if not path.exists():
        return "absent"
    cur = path.read_text(encoding="utf-8")
    if not cur.startswith(OLD_HANDOFF_TITLE):
        return "kept (not a generated handoff)"
    answers = cur.find("## Owner answers (from the Agents board)")
    if answers == -1:
        path.unlink()
        return "removed"
    path.write_text("# Decisions\n\n" + cur[answers:], encoding="utf-8", newline="\n")
    return "trimmed to owner answers"


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry-run" in sys.argv
    root, projects = Path(args[0]), args[1:]
    for proj in projects:
        d = root / proj
        g = groups_for((d / "BUILD_SPEC.md").read_text(encoding="utf-8"))
        text, ptr = block(g), pointer(g)
        if dry:
            print(f"===== {proj}\n{ptr}\n{text[:1500]}")
            continue
        write_report(d / "REPORT.md", text)
        (d / "README.md").write_text(set_pointer((d / "README.md").read_text(encoding="utf-8"), ptr), encoding="utf-8", newline="")
        print(proj, {k: len(v) for k, v in g.items()}, clean_old_decisions(d / "DECISIONS.md"))


if __name__ == "__main__":
    main()
