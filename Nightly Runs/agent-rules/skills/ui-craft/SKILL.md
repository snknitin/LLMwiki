---
name: ui-craft
description: Use whenever you design, build, redesign, restyle, review or roast any UI (app screen, dashboard, website, GitHub Pages site, landing page, HTML mockup, design option) in any project, including other people's repos, or when a UI looks generic, amateur or AI-made. With a person in the chat it interviews them with simple multiple-choice questions, shows options and builds their pick. The entry point for all design work; it settles conflicts between the other design skills.
---

# UI craft

Generic UI comes from a generic brief, not from a weak model: five models given the same short prompt built the same page. So every screen starts from what its **domain** rewards, then a written **brief**; its concept is **structure, not costume**, and it is finished only after a **roast** of real screenshots by someone other than the builder. Works the same in Claude Code, Codex and Hermes, in any project.

**Someone in the chat?** Start with the interview in [session.md](references/session.md): look at the project yourself, then ask simple multiple-choice questions (what they want, what bothers them, which directions pull them), show options side by side, and build only what they pick. They never have to score or know design terms. **No one in the chat?** Don't ask; take the recommended defaults and report the choices. **In the owner's own projects** (AGENTS.md mentions DECISIONS.md, REPORT.md or the Agents board), also follow [house-rules.md](references/house-rules.md).

## The rules (every UI, every run)

1. **Brief before code.** Write the brief below for every new screen, page or option. Never go from prompt to page in one step.
2. **Domain first.** Read what this kind of app is for before choosing a look ([domains.md](references/domains.md)): the person's job, their state, the shape of the data, and the two things the domain rewards (money: precision and calm; habits: momentum and low friction; news: recency and hierarchy). Every later choice must serve those two; a choice that serves neither is a default.
3. **Structure, not costume.** The concept is an idea from the subject's world that decides the layout (a 24-hour timeline hung on market closes, a dictionary page filling in, a departure board of due cards). Texture painted onto a generic page is costume.
4. **Name the surface first.** *Operate* (tools, dashboards, admin; most personal apps): dense, precise, known patterns, no hero, no entrance animation. *Persuade* (landing, marketing): one composition per viewport, one signature moment. *Read* (docs, reports, lessons): 60–75ch measure, type does the work.
5. **Let the layout explain.** No eyebrow caption over a heading, no tagline, no sentence explaining a panel, never your instructions on screen. Buttons are 1–3 words and start with a verb ("Generate", "Select all"). Longer help goes behind an ⓘ tooltip. Keep units, amounts and what a save covers.
6. **Readable.** Reading text ≥16px (phone ≥16px, inputs ≥16px), at most 2 families, 2 weights, 3 text tones, contrast ≥4.5:1. Paragraphs at full contrast; secondary text 55–70%.
7. **One primary per section.** One filled button; secondaries ghost or outline; destructive is red even if the brand is not.
8. **Space and edges.** 4/8px scale; gaps inside a group clearly smaller than gaps between groups; every element shares an edge with something; text left, numbers right in tabular figures.
9. **Colour has a job.** Neutral layers + one accent ramp + semantic colours. Accent marks data and the primary action, never decoration. Never the stock blue/indigo/purple gradient.
10. **Every state, real content.** Hover, pressed, focus, disabled, loading; empty, error, one item, 500 items, a 60-character name. Plausible domain data, never lorem or "Item 1".
11. **Motion answers an action.** transform/opacity, ease-out, under 300ms, nothing on keyboard or 100-times-a-day actions, reduced-motion respected. Persuade pages may add one orchestrated moment.
12. **One shell.** Every screen of an app shares header, nav, tokens and finish. A redesign covers the sibling screens, not just the one in the mockup.
13. **Differ from the siblings.** Check the look ledger ([directions.md](references/directions.md)) before choosing a direction; at most one paper or print-document concept per round of options.
14. **Never grade yourself.** Screenshots at 1440 and 390 with real, long content; run [critique.md](references/critique.md); a different model family judges before "done".

When this skill and another design skill disagree, this one wins (the reasons are in [critique.md](references/critique.md#conflicts-settled)).

## Pick the mode first

| Ask | Mode | Read |
|---|---|---|
| New app, new screen, "give me options", a Design-tab job | **Direction** | [domains.md](references/domains.md), the brief below, [directions.md](references/directions.md) |
| Implement a screen or a picked mockup | **Build** | [craft.md](references/craft.md), then [app-screens.md](references/app-screens.md) or [pages.md](references/pages.md) |
| Existing UI, "review", "roast", "looks generic", or no change named | **Roast** (never Build) | [critique.md](references/critique.md) |
| "Redesign this", "make it look better", "give me options", with a person in the chat | **Redesign** | [session.md](references/session.md) |
| Add a tab or view to an existing app | **Fit** | [app-screens.md § Adding a view](references/app-screens.md#adding-a-view-to-an-existing-app) |
| Charts, tables, KPIs | **Data** | [app-screens.md § Data](references/app-screens.md#data-picks-the-component) |

## Redesign with a person

The full flow, questions included, is in [session.md](references/session.md): look first, ask what they want, show the biggest problems in plain words, confirm the domain, offer directions, build 3 options, let them pick or mix, then build on a branch and show before and after. Never build before they pick.

## The brief

Write it in the reply, in `DESIGN.md`'s Identity, or as the option's `options.json` fields. Every line is concrete: hex values, named stacks, numbers. Adjectives like "clean", "modern", "stunning", "premium" carry no information; replace each with a physical comparison ("dense like a trading floor", "quiet like a reading room").

```
Person & moment: <who>, <when>, must <one verb> in <how long>
Domain: <the job> · <the person's state> · rewards <two values>
Surface: Operate | Persuade | Read
Concept: <subject> as <a structure from its world> (<era or movement, if any>)
  The idea that decides the layout: <one sentence>
Rejected defaults: <3 obvious choices you are not making>
Palette (strict): <Name #hex role> x4-6; accent only for <what>
Type: display <stack>; text <stack>; numbers tabular; scale <ratio> from <base>px
Composition: <grid and skeleton in one line>; what the first screen shows
Depth: one of tonal steps | quiet 1px borders | soft shadows | hard offset; texture: <none or one>
Signature: <one element only this app has> + <one interaction that enacts the concept>
Content: <real names, numbers, dates this app would show>
```

Before building, run four tests on the brief and revise what fails:
- **Swap:** replace your type, palette or layout with the obvious default. If nothing important changes, it was a default.
- **Name:** cover the product name. Can you still tell what the app is for?
- **Domain:** does each line serve the two values the domain rewards? Would this look fit an app from a different domain just as well? Then it's not specific enough.
- **Signature:** point to five places the signature shows up.
- **Ledger:** a sibling project or another option in this round already uses this family or palette? Choose again.

## Process

Each step ends on a check; don't start the next until it holds.

1. **Ground.** Read the request and the project's own docs (README, BUILD_SPEC.md, FEEDBACK.md, DESIGN.md when present). Answer the five domain questions in [domains.md](references/domains.md), write the screen's one job in a sentence and rank its elements High / Mid / Low. *Done when* the brief's Domain line is written and every element on the screen traces to that job.
2. **Direct.** Write the brief (above) or, for options, one brief per option from different families in [directions.md](references/directions.md). On a new project the brief becomes DESIGN.md's Identity before the first screen is built. *Done when* all fields are concrete and the four tests pass.
3. **Tokens.** Put palette, type scale, spacing, radii and depth into CSS custom properties named from the domain (`--ink`, `--brass`, not `--gray-700`); on an existing app, read its tokens, grid and one sibling view first. *Done when* no colour literal sits outside the token file.
4. **Build.** Follow [craft.md](references/craft.md) and the surface's reference. Real content, every state, the shared shell. *Done when* every visible control does something and every state in rule 10 renders.
5. **Look.** Screenshot at 1440×900 and 390×844 with real, long content (`npx -y playwright@1.64.1 screenshot --full-page --viewport-size "1440, 900" <url> out-1440.png`). *Done when* you have looked at both images, not just produced them.
6. **Roast.** Run the checklist in [critique.md](references/critique.md) against the screenshots; fix every Blocker and the top three Majors; re-shoot. On a project with `scripts/design_gate.py`, it must print `DESIGN GATE PASS` with the other model family as judge. *Done when* no Blocker remains.
7. **Record.** Update DESIGN.md (Identity = the brief; Kit = tokens and the components every screen uses) and promote any complaint you fixed into a DESIGN.md rule. In someone else's repo, keep these notes where the person wants them ([session.md](references/session.md#someone-elses-repo-open-source)). *Done when* the next agent could build a sibling screen from DESIGN.md alone.

## The other design skills: when to open them

Load at most two extra skills per task; this one already carries their must-follow rules.
- **ui-ux-design-kole**: Kole Jain's full system (numbers, 170 roasts, critique method). Open for Roast mode and dashboards.
- **impeccable**: `critique`, `audit`, `polish`, `typeset`, `layout` commands. Its scripts are not installed here: take its "launcher unavailable" path, and skip its closing question to the user in unattended runs.
- **design-taste-frontend**: Persuade pages only, for `draw.mjs` directions and the `inspect.mjs` browser check. Ignore its motion quota (8+ moving elements, entrances on every section).
- **ui-ux-pro-max**: lookups only (UX guidelines, stack gotchas, chart types): `python <its folder>/scripts/search.py "<2-5 words>" --domain ux` (its documented `${CLAUDE_PLUGIN_ROOT}` path is wrong outside a plugin). Never adopt its `--design-system` look.
- **frontend-design**: the calibration list of current AI looks (already folded into [critique.md](references/critique.md#ai-tells)).
- **design-variants** (owner's setup): options on branches or for the Agents board's Design tab; it uses [brief.md](brief.md) for mockup jobs.
- **dataviz** (Claude host skill), when present: chart colour and form.

Component libraries, checklists and reference sites, and when each earns a visit: [resources.md](references/resources.md).

Unattended runs never stop to ask: decide, record the choice where the work is reported, and carry on. Interactive sessions ask as [session.md](references/session.md) describes.
