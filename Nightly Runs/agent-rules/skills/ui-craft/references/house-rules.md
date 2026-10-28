# House rules: the owner's own projects

Apply these on top of the skill when working in the owner's projects (`E:\GIT_ROOT\Projects` on the desktop, `~/Workspace/GIT_ROOT/Projects` on FirstSpark), whose AGENTS.md mentions DECISIONS.md, REPORT.md or the Agents board. Everywhere else they don't apply.

## Running and asking

- Overnight and unattended runs never stop to ask: decide, log it in DECISIONS.md, and put real questions in REPORT.md's multiple-choice format.
- In a daytime chat with the owner, interview as [session.md](session.md) describes.
- Links handed to the owner are their Tailscale links, never localhost.
- The Agents board's Design tab runs option jobs for Claude, Codex and Hermes using [../brief.md](../brief.md); picks are built with the `design-variants` skill and must pass `scripts/design_gate.py` with the other model family as judge.

## The look ledger

Before choosing a direction, read the `## Identity` section of the sibling projects' DESIGN.md (`grep -A3 "## Identity" */DESIGN.md` in the projects folder). As of 2026-10-28 about 22 of 28 projects use a paper, ledger, case-file, stamp or bound-book identity and 23 use a serif. Treat print and paper as full: use it only when the subject really is a paper artefact, never twice in one round. Start each new Identity line with its family name (`Identity: Transit — departure board for due reviews`).

## What the owner likes

- A distinct concept per project and per model, so there is real choice among options.
- Reading text at 16px, one consistent size; scrolling is fine, cramming isn't.
- One-word buttons ("Generate", "Select all") in a single header row whose controls never move; collapsible settings that collapse to one line.
- The Agents-tab pattern reused: global settings on top, a selectable list on the left, detail on the right.
- Labels stacked above their text at full width, never a half-empty label column.
- Status as small marks: a green tick for live, a count in a button label ("Generate (3)"), "running · 5m".
- Note boxes that show 6–7 lines; reference images accepted wherever a design is described.
- Options that are original concepts, never a restyle of the current live page.

## What keeps going wrong in these projects

Explanatory sentences, taglines and eyebrows; sentence-long buttons; paper/ledger/stamp/serif identities everywhere; a redesign that stops at the first screen (picked screens score 7–8, siblings 2–5); browser-default controls; dead space and misalignment; placeholder data ("Habit 1–4"), ISO dates, raw ids, broken plurals and mojibake dashes; navigation clipped at phone width; fixed panels sized with `vh` hiding Next/Submit on a real phone; builders grading their own work.

## Worked examples (the owner's picks, 2026-10-27)

What they share: one structural idea from the subject's world became the layout itself; all three are calm, light and readable with one accent. The rejects were a plain grid, a gimmick (a crossword, a giant day number) or a dark mood piece.

- **paper-logbook / Today: Clothbound spread.** Morning on the left page, evening on the right, a brass ribbon marking today. Source Serif 4; black linen, paper, blue-black ink, one brass accent.
- **language-learning-lab / Recall: Bound dictionary.** The left page asks; the right page is today's dictionary page filling in alphabetically with guide words and day tabs. Oxblood bookcloth, gilt, bible paper; Literata + Albert Sans.
- **finance-signals-dashboard / Today: The overnight.** A 24-hour timeline from the last 07:00 IST brief to this one, each instrument hung on its exchange's close. Grey-teal frame, white sheet, deep teal data, a dawn-amber brief mark; Public Sans; no red/green, no gauges.

Two of the three are paper; the next rounds should prove the other families.
