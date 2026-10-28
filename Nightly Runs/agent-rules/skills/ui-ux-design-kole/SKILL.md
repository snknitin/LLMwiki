---
name: ui-ux-design-kole
description: Kole Jain's UI/UX system from all 53 videos of his playlist, with his numbers and his roasts. Use when roasting or reviewing a UI, fixing a dashboard, landing page or mobile screen that looks amateur or vibe-coded, or when you need concrete values for type, colour, spacing, shadows or motion.
version: 2.0.0
author: Nitin Kishore, Hermes Agent, Claude
license: MIT
metadata:
  hermes:
    tags: [ui, ux, design, frontend, critique, dashboards]
    related_skills: [ui-craft]
---

# Kole Jain's UI/UX system

Distilled from the processed captions of all 53 videos in the owner's "Kole Jain — UI/UX" playlist (YouTube Learning Center, 2026-10-27). Kole judges a design by how fast a person finds what they came for, and fixes it by ranking, cutting, re-forming and only then polishing. Where he and the owner's rules disagree, the owner wins (noted inline). For direction, briefs and the overall process, **ui-craft** is the entry point; this skill is the depth behind its roast and craft numbers.

Deeper material:
- [references/roasts.md](references/roasts.md): 200 roasts, each "bad, why, replace with, video".
- [references/rules.md](references/rules.md): ~160 checkable rules, component and motion recipes, and where he goes against common advice.
- [references/videos.md](references/videos.md): takeaways per video, in playlist order.

## The 20 rules that carry most of the quality

1. **Name the screen's one job before styling.** Every element traces to the user's intent; a page with no job is merged into one that has one.
2. **Design the flow, not a screen.** Every screen has an obvious next step and a way back; chain the next decision (after "Create space", ask to add members, with Skip).
3. **Rank every element High / Mid / Low.** High goes top-left and largest; Low goes bottom-right or into a menu. Hierarchy uses size, position and colour together.
4. **Remove redundancy before adding anything.** Duplicate search bars, KPIs repeated across pages, a chart repeating a number, labels the layout implies, arrows on swipeable content, cards that do nothing.
5. **Space groups things, on a 4pt grid.** Subtext 8px under its heading, buttons ~32px below (at least 2x that gap); between groups clearly more than inside. Whitespace before borders. (Owner: no eyebrow label above headings.)
6. **Lock content to edges.** Every element touches at least two edges, like a receipt: text flush left, numbers flush right. When things float, line them into a new edge; don't hide them in a menu.
7. **Fix density by differentiating, not by adding space.** Group by a criterion, add avatars or icons, mute defaults so exceptions pop. Too much whitespace breaks grouping.
8. **Small type system.** One family is enough, two for interest, never four. ≤6 sizes on a site; dashboard text tops out ~24px. Scale 1.27 (16/20/26/33/42/53), 1.17 for dense or mobile. Body line-height 150%, headings 110–130%, display tracking −2% to −3%. Fluid `clamp()` from 320 to 1920px instead of breakpoints. Mobile type is not smaller (iOS base 17px).
9. **Two weights, two text colours.** Primary 100%, secondary 45–70%. Headings win on size and stay regular; subheadings bold; paragraphs at full contrast.
10. **Colour is neutral layers plus an accent ramp, not 60-30-10.** ~4 background layers, 1–2 border colours, ~3 text tones; accent 500/600, hover 700; 1–2 accents. Backgrounds recede: off-white or tinted, never bright. Neighbouring light surfaces differ ~2%. Borders ~85% white, never black.
11. **Semantic beats brand.** Destructive is red whatever the brand; success green, warning amber, link blue. Text passes 4.5:1; if the brand colour fails, darken it or rotate the hue.
12. **Every element has its states and every action a visible response.** Hover lighter, pressed darker, disabled desaturated, focus, loading. Saved = filled icon + a dot on the destination; copy = a "Copied" chip. No change on click reads as an error.
13. **Design every data state with real content.** First-run empty state points at the one primary action; search-miss suggests and gives an exit; skeletons while loading; truncate 60-character names; contrast circles behind icons on bright images. Never lorem ipsum.
14. **One filled primary per section.** Secondaries ghost or outline. Chips are filters and metadata, never the CTA (vertical padding ½–¼ of horizontal). Repeated cards are whole-card links with a hover arrow.
15. **One system for radii and icons.** One radius for small components (~10px); nested inner = outer − gap. One icon library (Lucide, Phosphor, Feather), matched stroke and fill, icon size = text line-height, neutral unless status, never emoji, tooltip on non-obvious icons (after ~1s).
16. **Effects stay subtle or go.** Shadow: light grey, 15–20%, blur 1.3–2x Y, X ≤ Y, popovers more than cards. No clashing gradients, no glow, no gradient avatars. If an effect isn't clearly helping, delete it.
17. **Dark mode is its own palette.** Surfaces get lighter as they rise; neutral steps double (2% → 4–6%); per level +4–6 brightness, −10–20 saturation; light-grey body text, pure white only for key text; accents from 300/400, desaturated; no shadows.
18. **The data chooses the component.** Categories → chips; numbers right-aligned; time-ordered → timeline; income vs expenses → two-sided bars; a growth chip instead of a redundant chart. Charts: straight segments, gridlines, markers, labelled axes and units, a range dropdown, previous period in grey, no fading line.
19. **Container by context; undo over confirm.** Popover for simple non-blocking, modal for complex same-page (then a toast), new page for big or permanent objects (with back). Act first and offer undo; confirm only irreversible high-stakes actions. Settings save instantly. Optimistic UI.
20. **Motion clarifies, feels physical, stays small.** Every button gets a small press response; scroll-jacking almost never; springs not linear (his values: stiffness 636 / damping 24 at ~500ms; 550 / 40 for a spinner); stagger 100–200ms; preloaders short and the content rises with them; slow loops; touch fallback for mouse effects; reduced motion respected; dashboards stay tame.

## By area

**Dashboards.** Two-column, two-row grid; a top strip for page actions; the main area for what matters most here. Sidebar = product spine: account switcher top, grouped icon + short label links, active state, Settings and Help at the bottom, no group headings like "Menu", no counts. Four components: lists/tables (search, filter, sort; separate by space or row tint), cards (border in dark mode, fill in light), inputs, tabs for related views. Invisible UI: tooltips, copy chips, hover-revealed row actions, onboarding one tooltip at a time. Fill the gaps a real user needs. Smaller type, tighter spacing and stricter grids than landing pages.

**Mobile.** Bottom bar 3–5 items (ideally 3–4), 44px targets, no raised centre "+", inactive icons visible, accent on active only. One scroll direction per section; one screen, one job; cards as the grouping block but never nested; bottom sheets to keep context; primary and share actions in the thumb zone. Gestures always have a button alternative; slide-to-confirm for high-impact actions. Transitions follow the gesture; the background scales down as a sheet opens.

**Landing pages.** Ladder 2 / 6 / 8 / 10: haphazard → stacked hero over real product screenshots → bento of product crops, punchy copy, social proof → benefit copy, colour threading, one signature effect. Headline says what it is and how it helps; one or two CTAs, same label in nav and hero; a functional CTA (search, prompt box) beats "Get started". Fit the hero to ~1000px tall. No two sections in a row with the same layout. Logo wall (41 of 50 top SaaS sites have one). Real product UI or domain imagery, never unrelated stock. Text over photos on a gradient scrim, never over the focal point. Giant display text once or twice per page.

**Identity (his anti-vibe-code rule).** Define mood, imagery, texture and type pairing before wireframing; serif display + sans body cures the sterile AI look; tinted neutrals; build the palette from the product's own imagery; "Frankenstein" section wireframes from several real sites, then apply your own identity. AI-chosen bright colours get overridden by hand.

**AI products.** Prompt box as control panel (attachments, mode chips, cost hint); streaming text or skeletons; a reasoning trail with sources; confidence chips; memory as a visible, editable list; inline edit of a selected passage.

**Interaction intent ("software must lie").** Guess intent to save time: act on the first click unless a second click would change the meaning; safe triangle for diagonal submenu travel; first tooltip delayed, neighbours instant; press-and-release commits on release, menus open on press; drag near an edge shows the drop position and scrolls faster nearer the edge.

**Prompting an AI for UI (his method).** Goal + format (HTML/CSS) + context (what the product is) + specifics (the elements wanted, an icon library named, no emoji). Use simple real product screenshots as references (Linear, siteinspire), not dense Dribbble shots. Expect a manual pass on alignment, fonts, colour semantics and states.

## His roast method

1. Zoom in and put it at a real viewport (~1920x1000 or a phone with browser bars).
2. Ask what the page is for; restructure pages with no job.
3. Rank High / Mid / Low and relocate.
4. Cut nonsense and duplicates (the domain-impossible button, the second search, the decorative chart).
5. Consolidate (links into a popover, settings + billing + usage together, card buttons into a ⋯ menu).
6. Re-form the data (chips, timelines, two-sided bars, units, time selectors).
7. Fill the gaps (states, the missing real feature, a functional CTA).
8. Polish the craft (spacing, radii, type count, colour semantics, soft shadows, one icon set, contrast).
9. Add identity and life last (real visuals, benefit copy, one signature effect, purposeful motion).
10. Score it on the 2 / 6 / 8 / 10 ladder and name the single change that moves it up a rung.

The full screenshot checklist and finding format are in ui-craft's `references/critique.md`; the swaps he makes are in [references/roasts.md](references/roasts.md).

## Where his advice has a nuance

- **60-30-10:** a starter heuristic only; real products are near-monochrome (Vercel ~90/8/2) built from neutral layers.
- **Pure white/black:** fine for the top card layer and key dark-mode text; never as a page background behind white cards.
- **Gradients:** none as decoration in product UI; one hue if any; allowed as scrims and as identity on marketing pages ("any good website with a gradient can be good without one").
- **Lines and containers:** lose divider lines and nested cards; keep a line or card only when it creates a needed edge. Lines as a deliberate style system are fine.
- **Tooltips:** a backup for icons, never a crutch for a confusing layout.
- **Infinite scroll:** load more for browse-and-decide lists with a footer; continuous scroll for feeds.
- **Fonts:** one is enough; serif display + sans body when the brand needs warmth; three only as display + sans + mono captions.
- **Type scale:** the golden ratio grows too fast from 16px; use 1.27 or 1.17.
- **Confirmation:** undo instead of confirm, except irreversible, high-stakes actions; there the destructive button is the filled red primary.
- **Whitespace:** generous on landing pages, but too much splits related things ("lonely" elements on the Fisker site).
- **Eyebrow labels:** his hero spacing includes a small label 12px above the heading; the owner forbids eyebrows over headings, so keep only the 8/32px gaps.
- **Dribbble:** good for taste, bad as a usability or AI-prompt reference.
