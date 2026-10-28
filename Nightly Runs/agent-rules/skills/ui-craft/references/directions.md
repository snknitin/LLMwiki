# Directions: where concepts come from

Use in Direction mode. A direction is a **structure from the subject's world** that decides the layout, plus the palette, type and texture that world implies. Pick from different families for different options; check the ledger first.

## The look ledger (check before choosing)

The owner wants no two projects sharing a theme. Before choosing a family:

1. Read the `## Identity` section of sibling projects' DESIGN.md: `E:\GIT_ROOT\Projects\*\DESIGN.md` on the desktop, `~/Workspace/GIT_ROOT/Projects/*/DESIGN.md` on FirstSpark (a quick `grep -A3 "## Identity"` is enough).
2. Tally the families below. As of 2026-10-28 about 22 of 28 projects are **print and paper** (ledger, case file, manila folder, rubber stamp, bound book, iron-gall ink); 23 use a serif. Treat that family as full: use it only when the subject really is a paper artefact, and never twice in one round of options.
3. Never repeat a sibling's palette (same ground + accent pair) or its signature element.
4. After a pick, the project's DESIGN.md Identity line is the ledger entry: start it with the family name, e.g. `Identity: Transit — departure board for due reviews`.

## Families and example structures

Each structure is a layout idea, not a skin. Ask: what does this artefact *organise*, and does my data have that shape?

| Family | Structures (what they organise) | Palette and type cues |
|---|---|---|
| **Instruments and machines** | chart recorder (values over time on a scrolling strip), oscilloscope (live signal + readouts), mixing desk (channels in vertical strips), cockpit (one primary instrument, ring of secondaries), slide rule, chronograph dial, darkroom timer | anodised black or enamel ground, phosphor green/amber or brass accent; condensed grotesk, tabular numerals, engraved small caps |
| **Transit and wayfinding** | departure board (rows of due items with status and time), metro map (stations = steps, lines = tracks), timetable (grid of times x places), airport signage (one bold instruction per zone), air-traffic strip board (one strip per item, moved between bays) | signal yellow, platform grey, line colours; DIN-like or Transport-style grotesk, big numerals |
| **Maps and charts** | topographic contours (density as elevation), nautical chart (soundings, bearings), star chart (constellations of related items), survey plan, territory map with zones | chart blue, sounding black, buoy red/green; small italic labels, hairline graticule |
| **Science and specimens** | specimen drawer (grid of labelled samples), periodic table (items placed by two properties), spectrogram (intensity over time), lab bench readouts, weather station, herbarium sheet | lab white, specimen tags, one indicator dye colour; mono for measurements |
| **Games and scoreboards** | scoreboard (big live numbers), league table (rank, movement arrows, promotion zone), board game (path of squares = progress), trading cards (one card per entity with stats), chess clock (two timers), sports broadcast lower-thirds | team colours, floodlight contrast; heavy grotesk numerals, tabular stats |
| **Broadcast and media** | TV guide grid (channels x time), film slate (scene/take metadata), studio console, radio dial (tuning across a range), vinyl sleeve (A-side/B-side), cue sheet | tube glow, tally red, tape beige; condensed sans, timecode mono |
| **Software-native** | terminal/TUI (dense rows, keyboard-first), spreadsheet (cells, formulas visible), IDE panes, command palette, precise tool UI in the Linear/Vercel tradition (near-monochrome, one accent) | near-black or near-white, one accent; one grotesk, mono only for code and IDs |
| **Architecture and signage** | blueprint (plan + elevation + callouts), building directory (floors = sections), museum label wall, construction drawing with revision table | blueprint blue or drafting white, red-line accent; technical stencil or grotesk caps used once |
| **Craft and movements** | Swiss International Style grid poster, Bauhaus primary shapes, De Stijl blocks, Memphis 1981, Art Deco symmetry, Japanese 24-season calendar (volvelle), ukiyo-e flat colour, stained glass leading, weaving draft (warp x weft grid), glaze test tiles | the movement's own palette, strictly limited; the movement's type (Akzidenz/Helvetica, Futura, Didone, geometric deco) |
| **Nature and seasons** | almanac (day by day with moon/tide columns), tide table, seed catalogue, field guide plates, phenology wheel | botanical greens, earth, sky; old-style serif or humanist sans |
| **Sport and body** | training log, race bib, gym plate weights, heart-rate trace, climbing grade chart | track red, chalk white; condensed numerals |
| **Print and paper** (full: see ledger) | broadsheet columns, ledger, field notebook, riso poster, index card catalogue, type specimen, bound dictionary | paper + ink + one spot colour; Didone or old-style serif |

## Domain map: starting points for this owner's app types

Use these as a first draw, then go past them. Two options from one row should come from different families.

| App type | Structures worth trying |
|---|---|
| Finance, markets, net worth | chart recorder, departure board of positions, overnight timeline hung on exchange closes (picked for finance-signals-dashboard), cockpit, topographic net-worth terrain |
| Learning, language, quizzes | metro map of a curriculum, trading cards, scoreboard/league table, periodic table of words, bound dictionary filling in (picked for language-learning-lab) |
| Habits, journal, health, physio | chart recorder of the day, training log, almanac, chronograph rings, clothbound diary spread (picked for paper-logbook) |
| Agents, ops, run monitors | air-traffic strip board, departure board, mixing desk of lanes, terminal, broadcast cue sheet |
| Video, reading, research libraries | TV guide grid, specimen drawer, star chart of concepts, film slate metadata, museum label wall |
| Social capture, inbox, triage | air-traffic strips moved between bays, sorting office pigeonholes, specimen drawer, kanban as a signal box |
| Recipes, food, lists | glaze test tiles, seed catalogue, kitchen ticket rail, field guide plates |
| City, travel, events | metro map, airport signage, nautical chart, festival line-up poster |
| Games, simulations | board game path, trading cards, arcade cabinet attract screen, scoreboard |

## Vocabulary that moves models

Measured on 2,300 AI-generated pages (Mia's AI Lab, 2026): the strongest briefs named hex colours 99% of the time (the weakest 14%), and words like *grain, hairline, tracked, tabular, multiply, engraved, small caps, fictional* were almost only in strong briefs. The weakest briefs said *stunning, unique, organic, luminous, theme, cards, center, inspired*.

- **Artefact + era:** "a 1926 broadsheet front page", "an 18th-century brass instrument", "a Solari split-flap board", "a riso gig poster", "a museum plate: title block left, object centre, plates right".
- **Movement as rulebook:** International Typographic Style (Müller-Brockmann), Bauhaus, De Stijl, Memphis Milano 1981, Art Nouveau, Art Deco, mid-century travel poster, ukiyo-e, neo-brutalism, Kinfolk/Monocle editorial.
- **Type systems:** Didone display (Didot, Bodoni 72) or heavy grotesk (Helvetica Neue, Arial Black, Archivo Black) set enormous; old-style text (Iowan Old Style, Palatino, Source Serif); tabular numerals; extreme scale contrast (3x+ jumps); one giant numeral cropped by the edge; flush-left ragged-right; drop cap; hanging punctuation.
- **Composition:** strict 12-column grid with hairline rules; baseline alignment; asymmetric; editorial rather than a centred template; poster 3:4 on a desk-grey backdrop; museum plate; broadsheet columns with column rules.
- **Texture kit (CSS only, use one):** feTurbulence grain or paper fibre; halftone via `radial-gradient`; `mix-blend-mode: multiply` overprint with slight misregistration; hard offset shadow `6px 6px 0` with 2–3px borders; double rule via box-shadow; engraved line drawn twice (pale offset, then ink).
- **Constraints as one-liners:** "palette strictly these four and nothing else", "no gradients, no blur shadows, no rounded corners", "deliberately dense, but composed", "must stay legible at 390px".
- **Physical feel instead of adjectives:** "dense like a trading floor", "calm like a reading room", "cold like a terminal", "warm like a kitchen ticket rail".

## Worked examples (the owner's picks, 2026-10-27)

What the three picked options share: one structural idea from the subject's world became the layout itself. The rejects were a plain grid, a gimmick (a crossword, a giant day number) or a dark mood piece. All three picks were calm, light, readable, with one accent.

- **paper-logbook / Today: Clothbound spread.** Morning on the left page, evening on the right, a brass ribbon marking today. Source Serif 4; black linen, paper, blue-black ink, one brass accent.
- **language-learning-lab / Recall: Bound dictionary.** The left page asks; the right page is today's dictionary page filling in alphabetically with guide words and day tabs. Oxblood bookcloth, gilt, bible paper; Literata + Albert Sans.
- **finance-signals-dashboard / Today: The overnight.** A 24-hour timeline from the last 07:00 IST brief to this one, each instrument hung on its exchange's close. Grey-teal frame, white sheet, deep teal data, a dawn-amber brief mark; Public Sans; no red/green, no gauges.

Note that two of the three are paper. The next rounds should prove the other families.
