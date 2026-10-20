# Portfolio scripts

Tools that keep [[Project Portfolio]] and each project's pre-build questions in step with the repos under `E:\GIT_ROOT\Projects`.

| File | What it is |
|---|---|
| `portfolio.csv` | **Source of truth** for the judgment fields: status, merged/parked into, best use, DCC group, best path, open-source and commercial fit, rationale, notes. Edit this (or ask an agent to). |
| `build_portfolio.py` | Regenerates `Nightly Runs/Project Portfolio.md` and `Project Portfolio.xlsx`. Purpose and stack come from each `BUILD_SPEC.md`; open-question counts come from its §6. |
| `handoff_questions.py` | Writes a project's open BUILD_SPEC §6 decisions into its `REPORT.md` under `## Open questions` (Agents board Q-block format), lists vetoable assumptions separately, and refreshes the "Before you build" line under the README title. |

## Commands

```bash
# Rebuild the portfolio (Markdown + spreadsheet) after changing portfolio.csv or any spec
uv run --no-project --with openpyxl python build_portfolio.py

# Refresh one or more projects' REPORT.md questions after editing their BUILD_SPEC §6, then commit and push them
python handoff_questions.py E:/GIT_ROOT/Projects <project> [<project> ...]
```

## Rules

- **Notes:** typed into the spreadsheet's yellow "Your notes" column, they are copied into `portfolio.csv` on the next build. Edits to any other spreadsheet column are overwritten, so change those in the CSV.
- **New project folder:** the build lists it as "not yet in portfolio.csv". Add a row.
- **Answering questions:** answer from the Agents board's **Needs input** panel. The board writes answers to the project's `DECISIONS.md` and marks the question answered in `REPORT.md`. Then update the cited BUILD_SPEC §6 item so the spec stays the source of truth.
- **Re-running is safe:** `handoff_questions.py` only replaces its own block between `<!-- prebuild-handoff:start -->` and `<!-- prebuild-handoff:end -->`. Questions an overnight agent added elsewhere in `REPORT.md` are left alone.
