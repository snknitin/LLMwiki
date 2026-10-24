"""Copy the shared agent rules and shared skills into each harness on this machine.

Usage:  python sync_agent_rules.py          (desktop)
        python3 ~/vaults/LLMWiki/"Nightly Runs"/scripts/sync_agent_rules.py   (Spark)
Rules go between markers, so the rest of each file is left alone and re-runs are safe.
Skills in agent-rules/skills/<name>/ are copied whole into each harness's skills folder.
"""
import os
import pathlib
import shutil
import sys

START, END = "<!-- shared-agent-rules:start -->", "<!-- shared-agent-rules:end -->"
SHARED = pathlib.Path(__file__).resolve().parent.parent / "agent-rules"
RULES = SHARED / "AGENTS.md"
HOME = pathlib.Path.home()
# Hermes lives in ~/.hermes on Linux but in %LOCALAPPDATA%\hermes on Windows (the desktop never got skills before 2026-10-24).
_LOCAL = pathlib.Path(os.environ.get("LOCALAPPDATA", "")) / "hermes"
HERMES = _LOCAL if os.name == "nt" and _LOCAL.exists() else HOME / ".hermes"
TARGETS = [  # (file, only if this path exists)
    (HOME / ".claude" / "CLAUDE.md", HOME / ".claude"),
    (HOME / ".codex" / "AGENTS.md", HOME / ".codex"),
    (HERMES / "SOUL.md", HERMES / "SOUL.md"),
] + [(soul, soul) for soul in sorted((HERMES / "profiles").glob("*/SOUL.md"))]
SKILL_DIRS = [  # (destination, only if this path exists)
    (HOME / ".claude" / "skills", HOME / ".claude"),
    (HOME / ".codex" / "skills", HOME / ".codex"),
    (HERMES / "skills" / "shared", HERMES / "skills"),
] + [(d / "shared", d) for d in sorted((HERMES / "profiles").glob("*/skills"))]  # each profile has its own


def upsert(text: str, rules: str) -> str:
    block = f"{START}\n{rules.strip()}\n{END}"
    if START in text and END in text:
        head, rest = text.split(START, 1)
        return head + block + rest.split(END, 1)[1]
    return (text.rstrip() + "\n\n" if text.strip() else "") + block + "\n"


def self_check() -> None:
    once = upsert("# mine\nkeep me\n", "rule A")
    assert upsert(once, "rule A") == once, "not idempotent"
    assert "keep me" in upsert(once, "rule B") and "rule A" not in upsert(once, "rule B")


def main() -> None:
    self_check()
    rules = RULES.read_text(encoding="utf-8")
    for path, needs in TARGETS:
        if not needs.exists():
            print(f"skip   {path} (not installed here)")
            continue
        old = path.read_text(encoding="utf-8") if path.exists() else ""
        new = upsert(old, rules)
        if new == old:
            print(f"same   {path}")
            continue
        if old and START not in old:  # first sync: keep the original
            path.with_suffix(path.suffix + ".pre-shared-rules.bak").write_text(old, encoding="utf-8")
        try:
            path.write_text(new, encoding="utf-8", newline="\n")
        except OSError as error:  # Hermes audit-* profiles are read-only by design; skip them, keep going
            print(f"skip   {path} (not writable: {error.__class__.__name__})")
            continue
        print(f"update {path}")

    skills = [d for d in sorted((SHARED / "skills").glob("*")) if (d / "SKILL.md").exists()]
    for dest, needs in SKILL_DIRS:
        if not needs.exists():
            print(f"skip   {dest} (not installed here)")
            continue
        try:
            for skill in skills:
                shutil.copytree(skill, dest / skill.name, dirs_exist_ok=True)
        except OSError as error:  # shutil.Error is an OSError too
            print(f"skip   {dest} (not writable: {error.__class__.__name__})")
            continue
        print(f"skills {dest}: {', '.join(s.name for s in skills) or 'none'}")


if __name__ == "__main__":
    sys.exit(main())
