"""Run: python test_handoff_questions.py (asserts only, no dependencies)."""
from handoff_questions import START, END, answered_chunks, block, groups_for, pointer

SPEC = """## 6. Assumptions & Open Questions
1. **Assumption:** Git exists.
2. **Question (BLOCKING T6):** Which STT surface should T6 use? Handy may not expose batch mode.
   - [ ] Parakeet via Handy (recommended)
   - [ ] Parakeet run directly
3. **Question:** Where are the sample PDFs? Needed for fixtures. Default: none, blocked until answered
4. **README proposed change:** update the Git-state row.
## 7. Build
"""

g = groups_for(SPEC)
assert [n for n, *_ in g["blocking"]] == [2] and [n for n, *_ in g["question"]] == [3]
assert [n for n, *_ in g["assumption"]] == [1, 4]
out = block(g)
assert "### Q1: Which STT surface should T6 use?\nBUILD_SPEC §6.2 · blocking — Handy may not expose batch mode.\n- [ ] Parakeet via Handy (recommended)\n- [ ] Parakeet run directly\n" in out
assert "### Q2 (text): Where are the sample PDFs?\nBUILD_SPEC §6.3 · question — Needed for fixtures.\nDefault: none, blocked until answered\n" in out
assert "- §6.4 — README proposed change: update the Git-state row." in out

# An answered question keeps its ticks and is renumbered; the vetoable section is not swallowed into it.
old = (f"{START}\n## Open questions\n\n### Q7: Which STT surface should T6 use?\nctx\n- [x] Parakeet via Handy (recommended)\n\n"
       f"## Spec assumptions you can veto\n\n- §6.1 — x\n{END}")
chunks = answered_chunks(old)
assert len(chunks) == 1 and "Spec assumptions" not in chunks[0]
out = block(g, chunks)
assert "### Q1: Which STT surface should T6 use?\nctx\n- [x] Parakeet via Handy (recommended)\n" in out
assert "1 open question waiting" in pointer(out)  # the answered blocking one is not counted
assert "2 open questions (1 blocking)" in pointer(block(g))
print("ok")
