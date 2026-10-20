"""Surface each project's open BUILD_SPEC §6 decisions where the Agents board and the overnight runner look.

Writes a generated block into <project>/REPORT.md under "## Open questions", using the Q-block format from
Nightly Runs/agent-rules/AGENTS.md, so the questions appear in the board's "Needs input" panel, in Preflight and in
morning triage. Vetoable assumptions go in a separate section whose heading neither tool treats as questions.
It also refreshes the one-line pointer under the README title. DECISIONS.md is left to its real job (decisions made,
plus the board's "## Owner answers"), except that a leftover generated handoff from 2026-10-20 is removed there.

Only §6 items labelled **Question…:** become owner questions (BLOCKING in the label puts them first). Write them as
    3. **Question (blocks T4):** One plain question ending in "?" Then a sentence on why it matters.
       - [ ] The choice the spec proceeds with (recommended)
       - [ ] The alternative
or, for a free-text answer (a path, URL, account), no options and a closing "Default: <value>" sentence.
Every other item (Assumption, README proposed change, …) is listed as vetoable.

Usage:  python handoff_questions.py <projects_root> <project> [<project> ...] [--dry-run]
Re-running is safe: it replaces its own marked block and pointer, and an already answered question keeps its ticks.
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


def items(sec: str) -> list[tuple[int, str, list[str]]]:
    """§6 items as (number, text, options). Indented `- [ ] …` lines under an item are its answer options."""
    out, cur = [], None
    for line in sec.splitlines():
        m = re.match(r"^(\d+)\.\s+(.*)", line)
        opt = re.match(r"^\s+- \[[ xX]\]\s+(.*)", line)
        if m:
            if cur:
                out.append(cur)
            cur = [int(m.group(1)), m.group(2), []]
        elif cur and opt:
            cur[2].append(opt.group(1).strip())
        elif cur and line.strip():
            cur[1] += " " + line.strip()
    if cur:
        out.append(cur)
    return [(n, re.sub(r"\s+", " ", t).strip(), o) for n, t, o in out]


QUESTION_LABEL = re.compile(r"^\*\*(?:Open )?Question\b([^*]*)\*\*\s*", re.I)


def classify(text: str) -> str:
    """Only items labelled **Question…:** reach the owner; everything else is a vetoable assumption or README note."""
    m = QUESTION_LABEL.match(text)
    if m:
        return "blocking" if re.search(r"(?<![Nn]on-)(?<!NON-)BLOCKING", m.group(1)) else "question"
    return "assumption"


def groups_for(spec: str) -> dict[str, list[tuple[int, str, list[str]]]]:
    g = {"blocking": [], "question": [], "assumption": []}
    for n, t, o in items(section6(spec)):
        g[classify(t)].append((n, t, o))
    return g


def title_of(text: str, limit: int = 150) -> str:
    t = text.replace("**", "").replace("`", "")
    return t if len(t) <= limit else t[: limit - 1].rstrip() + "…"


def split_question(text: str) -> tuple[str, str, str | None]:
    """'**Question (…):** Ask? Context. Default: x' -> ('Ask?', 'Context.', 'x')."""
    body = QUESTION_LABEL.sub("", text)
    default = None
    d = re.search(r"\s*Default:\s*(.+)$", body)
    if d:
        default, body = d.group(1).strip(), body[: d.start()]
    q = re.match(r"(.{10,300}?\?)(?:\s+|$)(.*)", body)
    ask, context = (q.group(1), q.group(2)) if q else (title_of(body), "")
    return title_of(ask, 300), context.strip(), default


def answered_chunks(report: str) -> list[str]:
    """Question blocks in the current generated block that already carry an answer (a ticked line)."""
    if START not in report or END not in report:
        return []
    old = report[report.index(START): report.index(END)].split("\n## Spec assumptions")[0]
    return [c for c in re.split(r"(?m)^(?=### Q\d+)", old) if c.startswith("### Q") and re.search(r"(?m)^- \[[xX]\]", c)]


def block(g, answered: list[str] = ()) -> str:
    lines = [START, "## Open questions", "",
             "Pre-build handoff generated from BUILD_SPEC.md §6, most urgent first. Answer in the Agents board's Needs input "
             "panel (answers land in DECISIONS.md) or tick an option here. Each question cites its §6 item, where the full "
             "context lives.", ""]
    q = 0
    for key in ("blocking", "question"):
        for n, t, opts in g[key]:
            q += 1
            ask, context, default = split_question(t)
            keep = next((c for c in answered if t in c or re.match(rf"### Q\d+(?: \(\w+\))?: {re.escape(ask)}\n", c)), None)
            if keep:  # an answered question keeps its ticks; only its number changes
                lines += [re.sub(r"^### Q\d+", f"### Q{q}", keep.rstrip("\n")), ""]
                continue
            lines += [f"### Q{q}{'' if opts else ' (text)'}: {ask}",
                      f"BUILD_SPEC §6.{n} · {'blocking' if key == 'blocking' else 'question'}" + (f" — {context}" if context else "")]
            if opts:
                lines += [f"- [ ] {o}" for o in opts]
            else:
                fallback = "none, blocked until answered" if key == "blocking" else f"proceed with the assumption in BUILD_SPEC §6.{n}"
                lines += [f"Default: {default or fallback}"]
            lines += [""]
    if not q:
        lines += ["(none: only vetoable assumptions, listed below)", ""]
    lines += ["## Spec assumptions you can veto", "",
              "The spec proceeds with these, including any README updates it proposes, unless you object; each links to its §6 item.", ""]
    lines += [f"- §6.{n} — {title_of(t, 190)}" for n, t, _ in g["assumption"]] or ["- (none)"]
    lines += ["", END]
    return "\n".join(lines) + "\n"


def write_report(path: Path, text: str):
    cur = path.read_text(encoding="utf-8") if path.exists() else "# Report\n"
    if START in cur and END in cur:
        new = cur[: cur.index(START)] + text + cur[cur.index(END) + len(END):].lstrip("\n")
    else:
        new = cur.rstrip("\n") + "\n\n" + text
    path.write_text(new, encoding="utf-8", newline="\n")


def pointer(block_text: str) -> str:
    """Counts only unanswered questions (no ticked line) in the generated block."""
    qs = [c for c in re.split(r"(?m)^(?=### Q\d+)", block_text.split("\n## Spec assumptions")[0]) if c.startswith("### Q")]
    open_qs = [c for c in qs if not re.search(r"(?m)^- \[[xX]\]", c)]
    nq, nb = len(open_qs), sum("· blocking" in c for c in open_qs)
    if not nq:
        answered = f" ({len(qs)} answered)" if qs else ""
        return f"> {POINTER_MARK} no open questions{answered}; review the vetoable assumptions in [REPORT.md](REPORT.md)."
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
        report = d / "REPORT.md"
        text = block(g, answered_chunks(report.read_text(encoding="utf-8") if report.exists() else ""))
        ptr = pointer(text)
        if dry:
            print(f"===== {proj}\n{ptr}\n{text[:1500]}")
            continue
        write_report(d / "REPORT.md", text)
        (d / "README.md").write_text(set_pointer((d / "README.md").read_text(encoding="utf-8"), ptr), encoding="utf-8", newline="")
        print(proj, {k: len(v) for k, v in g.items()}, clean_old_decisions(d / "DECISIONS.md"))


if __name__ == "__main__":
    main()
