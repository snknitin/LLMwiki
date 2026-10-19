"""Copy the shared agent rules into each harness's global instruction file on this machine.

Usage:  python sync_agent_rules.py          (desktop)
        python3 ~/vaults/LLMWiki/Local_Setup/scripts/sync_agent_rules.py   (Spark)
The rules go between markers, so the rest of each file is left alone and re-runs are safe.
"""
import pathlib
import sys

START, END = "<!-- shared-agent-rules:start -->", "<!-- shared-agent-rules:end -->"
RULES = pathlib.Path(__file__).resolve().parent.parent / "agent-rules" / "AGENTS.md"
HOME = pathlib.Path.home()
TARGETS = [  # (file, only if this directory exists)
    (HOME / ".claude" / "CLAUDE.md", HOME / ".claude"),
    (HOME / ".codex" / "AGENTS.md", HOME / ".codex"),
    (HOME / ".hermes" / "SOUL.md", HOME / ".hermes" / "SOUL.md"),
]


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
        path.write_text(new, encoding="utf-8", newline="\n")
        print(f"update {path}")


if __name__ == "__main__":
    sys.exit(main())
