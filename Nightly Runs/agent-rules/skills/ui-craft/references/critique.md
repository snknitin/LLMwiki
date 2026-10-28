# Critique: how to roast a UI

Use in Roast mode, and as step 6 of every build. Judge the **pictures**: screenshots at 1440x900 and 390x844 with real, long content, never the code or your memory of it. If you built it, a different model family gives the verdict before "done".

## The roast, in order (Kole Jain's method, extended)

1. **Put it in reality.** Real viewport, real data, browser chrome on the phone. A thumbnail or a tall artboard hides the problems.
2. **Say what it's for.** The screen's one job and the person using it. Elements that serve neither are cut.
3. **Rank and relocate.** High / Mid / Low. High moves top-left and grows; Low moves down or into a menu.
4. **Cut nonsense and duplicates.** Second search bar, repeated KPIs, labels the layout implies, controls impossible in the domain, cards that do nothing.
5. **Consolidate.** Scattered links into a popover; related numbers into one widget; per-card buttons into a whole-card link or a ⋯ menu.
6. **Re-form the data.** Chips, right-aligned numbers, timelines, two-sided bars; labels, units and ranges on every chart.
7. **Fill the gaps.** Missing states, the feature a real user needs, a way back, a next step.
8. **Polish the craft.** Spacing scale, edges, radii, type count, colour jobs, shadows, icons, contrast ([craft.md](craft.md)).
9. **Identity last.** Does it look made for this subject and person, or like a template? One signature, real content.
10. **Score and name the next rung.** 2 / 6 / 8 / 10 ([pages.md](pages.md#koles-maturity-ladder-score-with-it)) and the single change that moves it up.

## Checklist

Mark each Blocker / Major / Minor. A Blocker stops "done".

| # | Check | Typical Blocker |
|---|---|---|
| 1 | One job; primary action is the most prominent thing; squint lands on the High item | Two equal primary buttons; the main data below the fold |
| 2 | A next step and a way back from every screen; no dead ends | A new page without back; a flow ending at "Create" |
| 3 | No duplicated number, label, control or KPI; no label the layout implies | "Financial dashboard" title on a finance dashboard |
| 4 | No text explaining the UI: eyebrows, taglines, panel sentences, instructions, sentence-long buttons | "Tick projects below to generate" as a button |
| 5 | Grouping: inside gaps clearly smaller than between gaps; spacing on the scale | 1/2/3px or 70–80px gaps; groups falling apart |
| 6 | Edges: elements aligned and sharing edges; numbers right-aligned | Floating controls; misaligned first lines across columns |
| 7 | Containers: no cards in cards, no border + shadow, no rule on every row | Card soup |
| 8 | Type: ≤2 families, ≤6 sizes, 2 weights, reading text ≥16px, tight large headings | 11–13px body; four typefaces |
| 9 | Colour: neutral layers, one accent with a job, semantic red, contrast ≥4.5 | Primary button at 3.5:1; brand-coloured Delete |
| 10 | Buttons and chips: one filled primary per section; chips aren't CTAs | Four full-width equal buttons |
| 11 | Consistency: same radius family, one icon set, icon size = line height, no emoji | Emoji icons; mixed icon styles in one toolbar |
| 12 | Effects: shadows soft and secondary; no clashing gradients or glows | Default black drop shadow; purple gradient |
| 13 | States: hover, focus, pressed, disabled, loading, empty, error visible or plausible | Blank empty state; enabled "Start" with 0 items |
| 14 | Data: chart form matches the data; axes, units, ranges; no repeated stats | Smoothed line with no axis |
| 15 | Real content: no lorem, "Item 1", ISO dates, raw ids, JSON, server addresses, broken plurals or mojibake | "Habit 1–4"; "1 approved claims"; "5?8 min" |
| 16 | Phone: nothing clipped, 44px targets, one scroll direction, actions in thumb reach | Nav cut to "Da…"; popover off-screen |
| 17 | Shell: same header, nav, tokens and finish as the app's other screens | A secondary screen that drops the app shell |
| 18 | Identity: passes the swap and name tests, serves the two values its domain rewards ([domains.md](domains.md)), not one of the AI tells below | A look that would fit any app; a finance app styled like a habit diary |
| 19 | Native controls styled; nothing browser-default | Default file input or select |
| 20 | Motion: answers actions, short, ease-out, reduced-motion safe | Fade-up on every section; linear easing |

## Writing findings

- Each finding has three parts: the **rule** it breaks (cite the row or rule), the **evidence** it is on screen (which screenshot, where), and exactly **one fix**. Drop findings you can't prove on the picture.
- Report Blockers, then at most three Majors, as a **Before | After | Why** table. Fix them, re-shoot, re-check.
- For an audit someone else will fix, write the fixes as a self-contained plan (files, values, screenshots to compare).

## AI tells

Defaults that show up whatever the subject. Legitimate only when the brief chose them on purpose.

- **Current clusters** (Anthropic's calibration): warm cream ~#F4F1EA + high-contrast serif + terracotta ~#D97757; near-black + one acid green or vermilion; broadsheet hairlines, zero radius, dense columns; the SaaS card kit (identical rounded cards, same radius everywhere, the same soft grey shadow, gradient washes); template chrome (tracked ALL-CAPS eyebrow over every heading, `A · B · C` meta strings, `WORD — fragment` labels, #0B0B0B/#111 as black, monospace for small data labels, `→` on every link).
- **From 2,300 generated pages** (Mia lab): dark void with a faint centred title and particles; aurora blobs behind frosted glass; "Ship products at light speed" hero + KPI cards + bento + gradient pill CTA; one italic accent word in every headline; a sidebar of sliders shrinking the content; synthwave sun grid.
- **Kole's vibe-code tells:** emoji icons; gradient circle with initials as avatar; the same KPI row on every page; cards that do nothing; five pricing plans; no domain imagery anywhere; counts in sidebar nav; AI-picked bright clashing colours.
- **Community fingerprints:** a 4px left accent bar on every card; a blinking green "live" dot; containers nested three deep; a three-column feature grid as section two; Lucide everywhere by default.
- **This owner's projects:** paper/ledger/stamp/serif identity on almost every app; explanatory sentences and taglines; sentence-long buttons; a redesign that stops at the first screen; self-graded "zero failures".

## Bad → good (the swaps that matter most)

| Bad | Good | From |
|---|---|---|
| Confirm modal before a reversible delete | Delete now + Undo toast, or a 30-day Recently Deleted | KJ |
| Save/Cancel on settings | Save instantly; version history to go back | KJ |
| More labels and tooltips to explain a confusing screen | Fix the visual: icons, grouping, chips, muted defaults | KJ |
| Every chip coloured though all are defaults | Defaults grey; only changed values keep colour | KJ |
| Whitespace added to fix a dense list | Group (by date, owner), add avatars, mute defaults | KJ |
| Cards inside cards, three radii stacked | One divider or whitespace; inner radius = outer − gap | KJ |
| Thin black border on cards | Border ~85% lightness or rgba 0.08 | KJ |
| White cards on a pure-white page | Off-white or tinted page, white cards | KJ |
| Default black drop shadow | Light grey 15–20%, blur 1.3–2x Y, or none | KJ |
| Light palette inverted for dark mode | Separate dark palette; lighter surfaces as they rise | KJ |
| Brand-coloured destructive action | Red, filled, with Cancel as ghost | KJ |
| Two equally styled CTAs | One filled primary; the other ghost or gone | KJ |
| A CTA button on every repeated card | Whole card is the link, arrow fades in on hover | KJ |
| Labels used as placeholders | Labels above; placeholder shows an example | KJ |
| Time-ordered records in a table | Timeline | KJ |
| Plain-text category values | Chips; numbers right-aligned | KJ |
| A chart repeating a number beside it | One growth chip | KJ |
| Smoothed line, no axis, faded recent data | Straight segments, gridlines, markers, full-opacity line | KJ |
| Bar chart with rounded tops, no value axis | Square ends, a value axis, one bar per category | KJ |
| Six-bullet onboarding modal | One tooltip on the key action, then the next | KJ |
| Raised centre "+" in a tab bar | Inline "+" like the other tabs | KJ |
| Desktop UI shrunk onto a phone | Same or larger type; one module per screen | KJ |
| Same layout two sections in a row | Change format (slider, then bento) | KJ |
| Text over the image's focal point | Move the text, or put it behind the subject | KJ |
| Heading bold, body lightened | Heading big and regular, subheading bold, body 100% | KJ |
| Font sizes per breakpoint | One `clamp()` per step | KJ |
| Adjectives in the prompt ("modern, clean") | A brief with hex roles, named stacks, a structure from the domain | Mia, ID |
| The agent browsing a catalogue each screen | ~10 vetted components in the repo, frozen tokens | Signal Desk |
| `--gray-700`, `--surface-2` | `--ink`, `--parchment`, `--brass` | ID |
| `transition: all 300ms ease-in` | `transition: transform 160ms cubic-bezier(0.23,1,0.32,1)` | EK |
| Popover growing from `scale(0)` | From 0.95 + opacity 0, origin at the trigger | EK |
| A command palette that fades in | Opens instantly | EK |
| Spinner that resizes the button | Fixed-size button, spinner overlaid | DSC |
| Error shown only as a red border | Red border + text + icon beside the field | DSC |
| "Tick all without a design" button | "Select all" | owner |
| Two-row header that jumps when settings collapse | One fixed row; collapsed panel is one line | owner |
| Label column with empty space under it | Label above its text, full width | owner |
| 13.5px reading text | 16px, one consistent size; let the page scroll | owner |
| Options derived from the live page | Original concepts from the brief | owner |

## Conflicts settled

| Topic | Rule here | Why |
|---|---|---|
| Colour system | Neutral layers + accent ramp + semantic; 60-30-10 only as a beginner guard | Kole's later video replaces it for product UI |
| Motion amount | Operate: feedback motion only. Persuade: one orchestrated moment. No quota | taste-skill's 8+ moving elements contradicts frontend-design, impeccable and Kole |
| Borders | Operate apps may use quiet 1px borders (1.1–1.3:1 contrast); never border + shadow together | taste pages vs taste app-screens and Kole |
| Shadows | Floating layers only, soft recipe; none in dark mode; hard offset only as a chosen direction | Kole, impeccable |
| Eyebrows | Never above a heading. A 12–13px sentence-case label above a *value* is fine | owner rule beats Kole's hero-spacing example |
| Monospace | Code, ids, keys, timecodes only | frontend-design and taste: mono as costume is a tell |
| Fonts | Chosen for the subject; ≤2 families; Inter/system only as a logged choice | all sources |
| Where the look comes from | The subject and the brief; never ui-ux-pro-max's catalogue style, never a cloned brand file | owner rule: no two projects share a theme |
| Gradients | None as decoration; scrims, one-hue chart fades and identity fields on Persuade pages allowed | Kole, taste, owner |
| Cards and bento | Cards only for peer objects; bento only on Persuade pages with real content for every cell | Kole, OpenAI, taste |
| Confirmation | Undo first; confirm only irreversible high-stakes actions | Kole, Vercel |
| Tooltips | For icons and truncated text, as backup; never to explain a confusing layout | Kole |
| DESIGN.md | Identity (the brief) + Kit (tokens, components); optional Google-spec YAML token front matter so `npx @google/design.md lint` can check it | one format instead of three |
| Asking the owner | Decide and log in DECISIONS.md; questions only via REPORT.md | owner's never-stall rule |
