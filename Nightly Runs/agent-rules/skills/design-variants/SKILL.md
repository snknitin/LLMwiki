---
name: design-variants
description: Use when the owner is unsure what a screen or flow should look like and wants several options to pick from, or when a "Design" note from the Agents board asks for options, a combined final option, or a pick to be merged. Builds 2-3 variants on separate branches with screenshots and a manifest the board's Design tab shows. Works the same in Claude Code, Codex and Hermes.
---

# Build design variants to pick from

1. Read `DESIGN.md`, `FEEDBACK.md`, any open `Design` entry under `## Owner direction (from the Agents board)` in `DECISIONS.md`, and the screen's current code. Read the `ui-craft` skill (SKILL.md and its `references/directions.md`). Write a `ui-craft` brief for each of 2–3 genuinely different directions from different families, differing in layout and visual idea, not just colour (e.g. "A: open two-page spread, B: tear-off calendar sheet, C: week grid"). Each may propose its own identity (palette, type pairing, signature element) as long as it fits the subject and the person using it.
2. For each direction, from the current base branch: `git worktree add ../<repo>-variant-<x> -b variant-<x>`, implement that screen plus the app shell it sits in, with realistic demo content and designed hover, focus and empty states. Serve it on a temporary port (never the project's registered preview port), take full-page screenshots at 1440px and 390px with real content, look at them and iterate until you would show them to a demanding art director. Run the tests that cover the screen, commit and push the branch.
3. On the base branch, commit the board's view of the round (never merge a variant):
   - `design/variants/before-1440.png` (the screen today) and `design/variants/<x>-1440.png`, `<x>-390.png` per option.
   - `design/variants.json`:
     ```json
     {"screen": "Today", "round": "2026-10-27", "before": "design/variants/before-1440.png", "designerPick": "b",
      "options": [{"letter": "a", "name": "Clothbound spread", "idea": "One sentence on the direction.",
                   "palette": "...", "type": "...", "signature": "...", "tradeoffs": ["...", "..."], "effort": "S",
                   "branch": "variant-a", "desktop": "design/variants/a-1440.png", "phone": "design/variants/a-390.png"}]}
     ```
     `designerPick` is your recommendation; leave `pick` out until the owner picks. The owner picks, combines or asks again from the board's Design tab.
4. **A combine note** ("combine the options … into one final option D: take the layout of B, the palette of A …"): build that one option the same way on `variant-<next letter>` from the base branch, add it to `design/variants.json`, and wait for the pick.
5. **A pick note**: merge that branch into the base branch, keep the other variant branches (they are reference), remove the worktrees, copy the picked screenshots to `design/reference/`, set `"pick"` and `"status": "done"` in `design/screens/<screen>.json` (or `design/variants.json` in an older project), rewrite `DESIGN.md`'s Identity to the picked direction with a Kit section (the token file and the components every screen must use), and make `python scripts/design_gate.py --judge <the other model family> --screens <the picked screen's shots>` print `DESIGN GATE PASS`. If the project has no `scripts/design_gate.py` yet, copy `design_gate.py` from this skill's folder into `scripts/` and write `design/gate.json` (token file, UI folders, `screenshots/latest`, threshold 7).
6. Mark the Design note `applied <date>: <what changed>` and push.

## Job mode (started from the Agents board's Design tab)
The owner starts design jobs from the board whenever they want; the nightly runner never does. Claude, Codex and Hermes may each be designing options for the same screen (one tab or page of the project) at the same time, so a job prompt gives you the screen, your letters (Claude A–C, Codex D–F, Hermes G–I; taken letters are skipped) and a job folder. It also hands you the owner's earlier notes on that screen and any reference images: read them all first. It deliberately leaves out the live screen: options are original concepts, never a restyle of today's UI.
- **Options and combines are static HTML mockups, not builds.** One self-contained `<letter>.html` per option (inline CSS, Google Fonts links fine, no frameworks, no build step), using the screen's real content. Don't touch the repo: no branches, worktrees, installs, servers or tests. Aim to finish in about 10 minutes; the board stops a mockup job after 30.
- Screenshot each mockup: `npx -y playwright@1.64.1 screenshot --full-page --viewport-size "1440, 900" file://<job folder>/<letter>.html <job folder>/<letter>-1440.png` and `"390, 844"` for `<letter>-390.png` (works on the desktop and on FirstSpark, whose cached Chromium 1248 needs no download). Look once (Hermes: with the vision tool), fix the worst problem, re-shoot, stop.
- Write `options.json` **last** in the job folder. The board copies the HTML and screenshots into `design/variants/<screen>/<round>/` and `design/screens/<screen>.json` and commits; you don't.
- Don't load the whole design-skill library for a mockup: the job prompt carries `ui-craft`'s `brief.md`. Hermes especially: big skills bloat its context and slow every call.
- **A pick job is the only one that builds into the app:** follow `ui-craft` (Build, then Roast) and implement the picked `<letter>.html` on main with the app's components and tokens, across the screen's sibling screens' shell, run verify, copy the screenshots to `design/reference/`, set `"pick"` and `"status": "done"` in `design/screens/<screen>.json`, update DESIGN.md, pass the design gate, push, then write `done.json` in the job folder.
