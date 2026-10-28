# App screens: tools, dashboards, admin (Operate surfaces)

Most personal and internal apps are tools people open often, on a desktop and a phone. They need density, precision and known patterns, carried by an identity from the subject (see [domains.md](domains.md) and [directions.md](directions.md)). No hero, no slogans, no entrance animations.

## Layout

- **One job per screen.** The main area shows what matters most in this context; the top strip holds page actions; secondary tools live in menus, popovers, drawers or a second tab. Rank modules High/Mid/Low: High goes top-left and largest. (KJ)
- **The first screen shows the person's own data and one obvious next action.** No marketing header, no tagline, no "Welcome back" banner eating the fold. (KJ)
- **Header and controls: one row.** Global controls sit in a single row whose buttons never move when a settings panel collapses or expands; a collapsed panel is one line with a summary.
- **One settings-and-list pattern per app:** for example global settings on top, a selectable list (checkboxes) on the left, the detail on the right. Reuse it across the app instead of inventing one per tab.
- **Label above value, full width.** Option or record details stack each label above its text across the whole column; no two-column label/value table that leaves half the width empty.
- **Sidebar:** the product spine. Account or project switcher at top; grouped links with icon + short label; clear active state; Settings and Help at the bottom; no "Menu" group headings; no counts unless the person acts on them; omit it when navigation is trivial (use tabs). (KJ)
- **Tabs, not more sidebar items,** for related views of one object. (KJ)
- **Redesign the whole app, not one screen.** Every screen keeps the shell (header, nav, tokens). A secondary screen that drops the shell ("a bare sheet on black") is a Blocker.

## Data picks the component

- Categories → chips. Numbers → right-aligned, tabular, with units. Status → a mark or chip with a word, never colour alone. Time-ordered records → a timeline, not a sorted table. Inactive rows → dimmed. Income vs expense → a two-sided bar chart. A single change → a growth chip ("+12%") instead of a chart that repeats a number. Geography → a shaded map with a list. (KJ)
- **Every control must be possible in the domain** (no "receive money" on a credit card) and every card must do something; delete cards that only decorate. Show each KPI on one page only. (KJ)
- **Fill the gaps** a real user needs that the mock forgot (a due date, a fraud alert with amount, date, place). (KJ)
- **Charts:** plain line or bar; straight segments (no smoothing); no fading of the latest data; horizontal gridlines; markers; labelled axes with units; a value axis on bar charts; square bar ends; one bar per category; a range selector (dropdown when tight); a legend for 2+ series; the previous period as a grey line; hover shows the value and dims the rest. Never break an axis. One chart = one conclusion; its headline states the conclusion; a source line below. At most ~6 charts per page. (KJ, Lieflat)
- **KPIs:** a small sentence-case label (12–13px, muted) above a big tabular value, delta beside it in semantic colour. No sparkline on every KPI, no icon tiles, no row of identical boxes repeated across pages. (taste app-screens, ID)
- **Believable data:** numbers that add up, names and dates in this app's world, seeded so a reload looks the same. (taste, Lieflat)

## Tables and dense lists

- **Row grammar first:** write the row as tracks (handle, status mark, primary label, metadata, disclosure, trailing actions) and lay it out as a grid: e.g. `grid-template-columns: 18px minmax(0, 1fr) 48px 20px`. One row height, `align-items: center`, fixed tracks for metadata so every title starts at the same x.
- Text left, numbers right; `minmax(0,1fr)` + ellipsis for titles; middle-truncate long ids; tooltips for truncated text.
- Separate rows with space or alternating tints, not a rule on every row (unless lines are the chosen style). Headers: 12–13px sentence case, muted. (KJ, taste)
- Search, filter and sort where the list is long; multi-select reveals a bulk-action bar only when something is selected. (KJ)
- Row actions appear on hover/focus (and stay reachable by keyboard and on touch via a ⋯ menu). Rare actions (share, remove) go in a popover. (KJ)
- Disclosure: right chevron = collapsed, down = expanded, one SVG rotated 90°. No text glyphs (`v`, `⌄`, `≡`) as icons. Reorder with a grip; only the grip starts a drag.
- A repeated row marker encodes a state the person monitors (processing done / not), with an `aria-label` that says it in words.
- **Load more** beats infinite scroll for browse-and-decide lists with a footer; continuous scroll suits feeds. (KJ)

## Containers and confirmation

- **Popover:** simple, non-blocking, click away. **Modal:** complex task tied to this page, or a sparse many-field form; confirmed with a toast. **New page:** large or permanent objects, always with back or a breadcrumb. (KJ)
- **Act, then offer undo.** Reversible deletes and edits happen instantly with an Undo toast (or a Recently Deleted bin for 30 days); settings save instantly. Keep a confirm dialog only for irreversible, high-stakes actions (bulk send, money, wiping data); there the destructive button is the filled red primary and Cancel is ghost. Use optimistic UI with honest rollback. (KJ)
- **Toasts** are the notification system; one alert surface, no duplicate banners. (KJ)
- **Every action shows a response** within ~100ms: pressed state, spinner after ~300ms (minimum visible ~500ms), filled icon on save plus a dot where it went, "Copied" chip on copy, micro-feedback on keyboard shortcuts. A click with no visible change reads as broken. (KJ, VG)
- **Model-backed actions** echo the user's input immediately and keep the previous result visible while the model works; a model failure never hides what the user submitted.

## Forms

- Labels above fields, always visible; placeholders are examples; the accepted format stays visible beside the field; errors beside the field with text + colour + icon, focus moved to the first error. (KJ, VG, taste)
- Big inputs for real context: a note box shows 6–7 lines.
- A choice screen has a search or "Other" path and Skip when none is valid. (KJ)
- Never a disabled control as the only instruction; don't pre-disable submit. (VG, hueyexe)

## States and stress

Render every screen in these states before calling it done: first run (empty, one CTA pointing at the main action), search miss (say so, suggest, exit), loading (skeleton matching the final layout), error, one item, many items (500), long content (60-character name, unbroken email/URL/UUID, hyphenated name with diacritics, +30% text), and phone width. Controls keep their size when labels, counts or loading text change. Sticky headers never hide the first or last row. (EK break-ui, mblode)

## Phone (390px)

- Same or larger type than desktop. One scroll direction per section. One screen, one job. Bottom nav of 3–5 items (ideally 3–4), all inline (no raised centre "+"), inactive icons clearly visible, accent only on active. 44px targets. Primary and share actions in the thumb zone at the bottom. Gestures always have a visible button. (KJ)
- Navigation must not clip: when tabs don't fit, scroll them with a visible fade or collapse to a menu; never cut a label to "Da…". Popovers stay on screen. Fixed panels use `dvh`, not `vh`, so Next/Submit stay visible.
- Bottom sheets keep context; the background scales down slightly as one opens. (KJ)

## AI product pieces

Prompt box as control panel (attachments, mode chips, context, cost hint); streaming text or a skeleton while generating; a reasoning or source trail; confidence chips; memory as a visible, editable list; inline edit of a selected passage; approval cards and tool chips for agent runs. (KJ ai7, beautifului)

## Adding a view to an existing app

The app already has a system; the new view must read as a sibling. Do these three reads before writing markup:

1. **Tokens:** read `:root` (colours, borders, radii, type scale, spacing). Every value in the new view comes from there.
2. **Structural grid:** find the layout that holds the content column and rail; new content goes in as direct children of that grid, not inside a wrapper that starts its own flex column.
3. **One sibling view:** copy its class names, heading + toolbar structure, empty-state pattern and primary-button size and place.

Then: never fork the class namespace; grep that every class you emit exists in the stylesheet (missing classes fall back to browser defaults: the "huge bold ugly text" people reject); one feedback rail per view; don't repeat a heading the parent already prints; status and actions sit right of the heading, not in a banner above it; card titles are human language, never an id or timestamp; operational ids stay out of visible text; reuse the sibling's success/failure colours; one affordance per job and one home per affordance; in-app viewers instead of links out to raw files; no fake affordances (a control that looks like it acts must act). After deploy, confirm the served bundle is the new one.
