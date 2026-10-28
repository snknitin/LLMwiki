# Kole Jain: checkable rules and techniques

Imperative rules tagged with the video they come from, then the component, layout and motion recipes, then where he goes against common advice.

Video ids are YouTube ids (https://www.youtube.com/watch?v=<id>). Distilled from the processed captions of all 53 videos in the owner's "Kole Jain — UI/UX" playlist (YouTube Learning Center, 2026-10-27). Values shown only on screen in a video are missing; numbers are as stated in the narration.

## Videos 1–18

### Rules

**Interaction and feedback**
- R1. Add a double-click or multi-tap delay only when the single-click action would be wrong if a second click follows. Otherwise act on the first click. [S8DcTJm8pYM]
- R2. Nested hover menus use a speed-gated safe triangle toward the submenu. [S8DcTJm8pYM]
- R3. Tooltips: delay on first hover, instant on adjacent elements afterwards. [S8DcTJm8pYM]
- R4. Reversible destructive actions: no confirm modal. Act, then show an Undo toast or move to a Recently Deleted bin (30 days). Use a confirm modal (or slide-to-confirm on mobile) only for irreversible, high-impact actions: bulk sends, money. [S8DcTJm8pYM, 14h1VnkQvIc]
- R5. Settings save instantly, with no Save/Cancel. Editors autosave and offer version history. [S8DcTJm8pYM]
- R6. Buttons commit on release; menu triggers open on press. [S8DcTJm8pYM]
- R7. Drag-reorder near an edge: show a drop-position preview and scale scroll speed by distance to the edge. [S8DcTJm8pYM]
- R8. Every user action gets a visible response. That includes keyboard shortcuts and copy (a "Copied" chip). [EcbgbKtOELY, Vy0KKvZJRH8]
- R9. Use optimistic UI for deletes and saves: remove or confirm instantly, assuming the server succeeds. [B7k5rOgmOGY, Vy0KKvZJRH8]
- R10. Buttons have default, hover, pressed and disabled states (plus loading when async). Inputs have focus, error (red border plus message) and warning states. [EcbgbKtOELY]
- R11. Hover = slightly lighter or brighter; pressed = slightly darker; disabled = desaturated (light gray background, white text). On touch, give a darker press state. [EOcY3hPMQkk]

**Layout and structure**
- R12. In compact components, every element touches at least two edges (container edge or a neighbouring row's edge). [neE6wOuBIP8]
- R13. List and table rows: text hard left, numbers hard right. [neE6wOuBIP8, Ksx9C2-3yMo]
- R14. Don't let rows or lines span the full viewport on wide screens; cap the width. [neE6wOuBIP8]
- R15. Long lists are grouped (date, status, owner) and show avatars wherever a person is referenced. [neE6wOuBIP8]
- R16. No card inside a card; avoid stacked borders with different radii. Use one divider line or whitespace. [neE6wOuBIP8, Gfsd8NNuD9g]
- R17. One radius language: images and buttons don't mix sharp and rounded corners. [eMMiLeo_UGI]
- R18. Hero spacing: eyebrow 12 px above the heading, subtext 8 px below it, CTAs 32 px below the subtext (at least 2× the heading–subtext gap). [9WVt1CelBfg, RCneB_MQ7qs] (For this owner: no eyebrow caption over headings; keep the 8px and 32px gaps.)
- R19. Hero sections space their elements 32 px apart and group related pairs tighter. All spacing is on a 4-pt grid. [EcbgbKtOELY]
- R20. Grid: 12 columns desktop, 8 tablet, 4 mobile for structured or repeating pages. [EcbgbKtOELY]
- R21. Dashboards: one primary job. The main area shows the user's most important data; the top strip holds page actions. [B7k5rOgmOGY]
- R22. Sidebar: icon plus short label per link, grouped, active indicator, Settings and Help at the bottom, account switcher at the top. [B7k5rOgmOGY]
- R23. Popover for simple, non-blocking tasks; modal for complex same-page tasks, followed by a toast; new page for large or permanent objects, always with back or breadcrumb. [B7k5rOgmOGY]
- R24. Tables offer search, filter and sort. Finite-set values render as chips; inactive rows are dimmed; long text is truncated. [B7k5rOgmOGY, Ksx9C2-3yMo]
- R25. Time-series records render as a timeline or chart, not only a table. [Ksx9C2-3yMo]
- R26. Every icon-only control and ambiguous label has a tooltip. [Ksx9C2-3yMo]
- R27. Multi-select reveals a contextual bulk-actions control. [B7k5rOgmOGY]
- R28. Never show the same KPI set on more than one page. Never ship a card with no function. [PDcQJOPby1k]
- R29. Pricing: at most 4 plans, prices ascending, the price larger than the plan name, discounts shown explicitly, and "what the next plan adds". [PDcQJOPby1k]

**Mobile**
- R30. Bottom nav: 3–4 items (5 max), touch targets at least 44 px, main action broken out. [Gfsd8NNuD9g]
- R31. Mobile body text at least 17 px (the iOS base); don't shrink desktop sizes. [Gfsd8NNuD9g]
- R32. Each mobile section scrolls in one direction only. [Gfsd8NNuD9g]
- R33. One screen, one job (home excepted). Use a bottom sheet when the user must keep context. [Gfsd8NNuD9g]
- R34. Every swipe action also has a tap path (button or long-press menu). [14h1VnkQvIc]
- R35. Two empty states: first-run (a single CTA pointing at the main action) and no-results (acknowledge, suggest, exit). [Gfsd8NNuD9g]

**Typography**
- R36. One sans-serif family by default. A serif display face only when the brand needs personality. [EcbgbKtOELY, RCneB_MQ7qs]
- R37. Large headings: letter-spacing −2% to −3%, line-height 110–120%. [EcbgbKtOELY]
- R38. At most 6 font sizes on a landing page. Dashboard text stays at or below 24 px, with tight steps between sizes. [EcbgbKtOELY, B7k5rOgmOGY]
- R39. Secondary text: same size, lower opacity (e.g. 15 px at 55%). [9WVt1CelBfg]
- R40. Hero copy: short, punchy headline and one short subtext (the "7 words / 14 words" figure is not in the transcript; treat it as a rough guide only). Never repeat the company name; say how it helps, not just what it does. [9WVt1CelBfg, eMMiLeo_UGI]
- R41. The nav CTA and the hero CTA going to the same place carry the same label. [eMMiLeo_UGI]
- R42. Icon size = the line-height of the adjacent text (e.g. 24 px). [EcbgbKtOELY]

**Color**
- R43. Light-mode neutrals in a product: 4 background layers, 1–2 strokes, 3 text tones. Landing pages: 3–5 neutrals. [66oOi9OLMCw]
- R44. Text lightness: heading about 11%, body 15–20%, subtext 30–40%. Card borders about 85% lightness, never black. [66oOi9OLMCw]
- R45. The sidebar or frame is only slightly darker than the content (about 2% shift, may carry a little brand hue). [66oOi9OLMCw]
- R46. Accent ramp: base 500/600, hover 700, link 400/500. Dark mode: base 300/400, hover 400/500. [66oOi9OLMCw]
- R47. Dark mode: neutral steps about 2× the light-mode steps (4–6% vs 2%). Elevated surfaces are lighter. Text dimmed, borders brighter, white only for the most important text. Saturated chips and logos desaturated. [66oOi9OLMCw, EOcY3hPMQkk, EcbgbKtOELY]
- R48. Destructive actions are always red, whatever the brand. [66oOi9OLMCw, EOcY3hPMQkk]
- R49. Chart palettes: OKLCH with fixed L and C, hue stepped 25–30° per series. [66oOi9OLMCw]
- R50. Theme a neutral palette: for each neutral, in OKLCH, L −0.03, C +0.02, hue = theme hue. [66oOi9OLMCw]
- R51. Icons are neutral; color only signals status or meaning. Dashboard color comes from data. [EOcY3hPMQkk, Ksx9C2-3yMo]
- R52. No bright or gradient page backgrounds. Use a neutral (optionally brand-tinted) background with a lighter foreground. [EOcY3hPMQkk]
- R53. All text and button color pairs pass WCAG contrast. If the brand color fails, darken it or use its complement. [EOcY3hPMQkk]
- R54. Default values render gray, so non-default values stand out. [neE6wOuBIP8]

**Depth, overlay and motion**
- R55. Shadows are never the first thing noticed: low opacity, high blur. Cards get the least, popovers the most. No shadows in dark mode; use lighter surfaces. [EcbgbKtOELY]
- R56. Text over images: a linear gradient into a readable color (optional progressive blur), never a flat full overlay. [EcbgbKtOELY]
- R57. Never use linear easing for UI motion. [14h1VnkQvIc]
- R58. Page or sheet transitions follow the gesture's direction. When a sheet opens, the background scales down and moves down. Swipe-back moves the previous page from −35% to 0. [14h1VnkQvIc, Gfsd8NNuD9g]
- R59. AI loading indicators are short and looping; long generations stream or show skeleton placeholders that match the final layout. [If7iCPDy2vk]
- R60. Pick one or two signature motion motifs and reuse them site-wide. [RCneB_MQ7qs]
- R61. macOS: keep the top ~50 px free of controls (window drag area). [Vy0KKvZJRH8]
- R62. Product images: real product UI, never stock. Vertical-market sites must show the user's world. [eMMiLeo_UGI, RCneB_MQ7qs]
- R63. Emojis are never used as interface icons; use an icon library (Phosphor or Lucide). [PDcQJOPby1k]


### Techniques

**Components**
- **Undo toast:** delete → item removed instantly → toast with Undo. A Recently Deleted bin as a stronger alternative.
- **Safe-triangle submenu**, speed-gated.
- **Edge-gradient auto-scroll with drop preview** for drag-reorder.
- **Copy chip:** a small "Copied" chip slides up from the button.
- **Hover-revealed row actions:** copy on a table cell, remove-user with a tooltip. A comment triangle marks cells that have comments.
- **Share popover:** search input first, member list, remove on hover.
- **Progressive onboarding:** one pointer tooltip, then the next one, or a corner checklist.
- **Account card in the sidebar header:** avatar plus a chevron pair, opening a popover with Settings, Billing and Usage merged.
- **List row:** favicon, short title, target, date, metric right-aligned, optional one-line description. ⋯ menu for actions; chips reduced to icons.
- **Bulk-select bar:** appears only once items are selected.
- **Chart card:** title, summary value, range selector, grid lines, axis labels, a metric toggle. Hover shows the value plus a % bubble, or dims the siblings.
- **Pricing card:** small plan name, big price, visible discount, "Everything in X, plus…".
- **Settings chips:** an icon chip per value, gray when default.
- **AI prompt box:** attachments, collapsing code paste, mode chips, context add, integrations, advanced toggle, token estimate.
- **AI history** (snippet, delete, search); **memory panel** (usage meter, bulk delete, add fact); **inline-edit popover**; **research trail** (three steps fading in); **confidence pill** (click for %); skeleton shimmer.
- **Dark glass panel:** translucent fill, subtle gradient, backdrop blur, 1 px border, soft inner shadow, shimmer sweep along the border.
- **Ghost buttons** (sidebar links are ghost buttons). Tactile buttons via inner plus outer shadow.
- **macOS quick-capture panel:** shortcut opens it; drop zone, input and shortcut hints; Enter collapses it into a toast; native blur. A floating, collapsible search bar with result count and clear. A floating action bar in the preview.

**Layouts**
- **Hero:** stacked (text over product UI) is the modern default. Text alternatives: left, center, or split body+CTA right. Visual alternatives: bordered, full-bleed, or carousel.
- **Bento** instead of card rows. **Multi-select tabs with a preview** instead of 3-card rows. **Full-length vertical frame lines.** **Mega menu** that slides between items. **Logo strip** with a hover CTA.
- **"Frankenstein" wireframing:** pick each section's structure from a different reference, keep only the wireframe, then apply your own identity.
- **Context-object hero:** centered copy surrounded by domain illustrations that thin out with distance from the center.
- **Dashboard 2×2 grid:** primary list on top, metrics below. Tabs for sub-views instead of new sidebar items.
- **Mobile alternatives:** floating tab bar, or the sidebar as the home page (Notion).

**Motion**
- Eased springs and bounce on carousels. A skewed 3D ring at the edges. A magnetic or fluid page indicator.
- Swipe-up expand transition: card → full screen, tab expands, content fades up, elastic snap.
- Shared-element image zoom into the next page's hero.
- Circle-expand onboarding transition.
- Sheet open: background scale-down and move down. Long-press: blur the background, zoom the element.
- Hero → section handoff: hero elements slide off and the text blurs while the next section overlays it.
- Kinetic words: a word morphs into an object (progress bar, dollar signs, checkbox).
- Object-specific entrances (pop+rotate, fly-in then idle bob), parallax on margin objects.
- Blur crossfade between multi-select panels.
- Auto-rotating feature images on a timer, with a hover zoom.
- AI: looping dots or star, word streaming.

**Color system (product)**
- **Neutral stack (light):** background about 98–100% → cards (white, or sidebar-tone if the cards are darker) → borders about 85% → buttons 90–95% → text 11% / 15–20% / 30–40%.
- **Dark mode:** double the step sizes; primary from the 300–400 range; elevated surfaces lighter; tinted dark neutrals (deep purple, green or red) allowed.
- **Brand hue:** tint a little into the neutrals. Extend a thin brand palette with analogous hues (small rotation) or the complement.
- **Charts:** OKLCH equal-L/C hue walk (+25–30°).
- **One-shot theming:** OKLCH L −0.03, C +0.02, rotate the hue.
- **Visual identity from photography:** pull palette swatches out of the brand's images. Add noise for texture and text contrast; a vignette for focus; graph-paper or cream sections for a "clean software" feel.

**Presentation**
- Background: accent darkened and desaturated, plus a faint shadow.
- Dark shots: blurred accent orbs as glow, or glass with a gradient stroke.
- Skew: 2° vertical / −14° horizontal. Pop-out panel with an offset shadow and gray placeholder.
- "Explode" the UI's lines past the frame edge.
- Offset collage with slight rotation and the hero frame popped out.
- Zoom into one dashboard section rather than showing the whole thing.
- AI-generated green-screen device mockups for clients.
- Prototype the hidden interactions.


### Against common advice

1. **60-30-10 is wrong for product UI** [66oOi9OLMCw]. He uses the rule himself in EOcY3hPMQkk (Lemon Squeezy example), but for product design he replaces it with layers: a neutral foundation, then a functional accent as a ramp, then semantic colors, then theming. Real products are near-monochrome (Vercel about 90/8/2, with the red sometimes absent).
2. **Pure white is fine** [66oOi9OLMCw]. Linear, Notion and Vercel sit at 98–100%. His only caveat: don't use pure white for the page background when the cards are pure white.
3. **Pure black and white aren't "bad"** [EOcY3hPMQkk]. Grays are usually just the better choice for hierarchy, which goes against the common "never use #000/#fff" rule.
4. **Don't put a confirm modal on deletes** [S8DcTJm8pYM]. This reverses the standard "warn before destructive actions". He keeps modals only for irreversible, high-stakes actions.
5. **Whitespace doesn't fix density** [neE6wOuBIP8]. Differentiate the content instead (avatars, grouping, icons).
6. **Don't explain more** [neE6wOuBIP8]. Extra labels and tooltips make screens harder to read; prefer recognizable visuals. (Yet in Ksx9C2-3yMo he insists dashboards need tooltips on icons and ambiguous labels: tooltips as invisible backup, not on-screen explanation.)
7. **Collapsing buttons into a menu isn't a fix** [neE6wOuBIP8], although in PDcQJOPby1k he does collapse card buttons into a ⋯ menu. The resolution: hide only secondary or rare actions (the spectrum of explicitness, Ksx9C2-3yMo), and fix the alignment first.
8. **Grids and the 8-pt rule are guidelines** [EcbgbKtOELY]. Custom landing sections needn't align to columns. The 4-pt multiple matters only because values can be halved, not because it looks better.
9. **One font is enough** [EcbgbKtOELY], against the usual "pair two fonts". The exception: adding a serif for brand personality [RCneB_MQ7qs].
10. **Mobile type gets bigger, not smaller** [Gfsd8NNuD9g]: iOS base 17 px vs macOS 13 px.
11. **Don't learn by redesigning apps; copy them exactly** [9WVt1CelBfg]. And don't build a portfolio early, because your taste will change within one to two months.
12. **Dark mode isn't an inversion** [EOcY3hPMQkk, 66oOi9OLMCw, Vy0KKvZJRH8]. It needs about 2× the neutral step distance; light mode needs steps collapsed closer. Light mode allows several surface models, dark mode only "lighter = higher".
13. **Emphasis is relative**, not a property of the element [neE6wOuBIP8]. To make one item stand out, mute its neighbours (default chips gray) rather than adding color or bold.

## Videos 19–36

### Rules

**Structure and layout**
- R1. Pass the 5-second wireframe test: with the content greyed out, the section order and main idea must still read. [tNMAFjzapOk]
- R2. Never tuck the product name or what it is into a corner at small size (his roast: 12px); the hero headline must say what the product is, next to a product visual. [tNMAFjzapOk]
- R3. Start each screen from the user's intent control (search, primary input) before any decoration. [HE4rLEQpiXY]
- R4. Keep conventions: nav at the top, content flowing top to bottom and left to right, CTAs high-contrast and easy to find. [HE4rLEQpiXY]
- R5. Show one primary CTA (two at most) and one focal element in a hero. [6CC8lLnqa28]
- R6. Fit the hero to a 1920×~1000 viewport (and check at 1440×~800). [BvbFPzLjWcU]
- R7. Never place text over an image's focal point. [V3Omp1hm0Sg]
- R8. No two consecutive sections share the same layout. [V3Omp1hm0Sg]
- R9. Large white space must not separate related items: group by proximity. Type-size jumps between adjacent levels shouldn't be extreme. [V3Omp1hm0Sg]
- R10. A single-product site has no separate "homepage"; the product page is the landing page. [V3Omp1hm0Sg]
- R11. Design every state of every tab or switcher, not just the default. [VPeTgU7la34]
- R12. Use "Load more", not infinite scroll, when a footer exists. [HE4rLEQpiXY]
- R13. Put frequent actions (share, chapter nav, volume) at the bottom of mobile screens; make the primary social action always visible. [goWOAFqJHpA, ixUq4HM4FNg]
- R14. Put mobile action icons on the right edge (thumb zone for 70-80% right-handers). [ixUq4HM4FNg]
- R15. Every choice screen has a search or "other" path and a Skip when "none" is valid. [AH_ugxmLeUM]
- R16. Show value (insights from the user's own data) before asking for goals or commitments in onboarding. [jSxxAFxjxbU]

**Spacing, grid and shape**
- R17. Use a 4px or 8px spacing base for small values; round large values to the nearest 5 or 10 (or step exponentially on 8). [c1TvOcKdBVE]
- R18. Inner radius = outer radius − padding (30/10 → 20). Pills exempt. [c1TvOcKdBVE]
- R19. Give all small components (inputs, chips, buttons) one shared radius; his default is 10px. [AH_ugxmLeUM]
- R20. Elements with the same role (Back, Skip; the two search bars) are identical in size, radius and style. [AH_ugxmLeUM]
- R21. Align to a column grid (3-col and 2-col on mobile screens in his example); allow deliberate small breaks only if balanced. [AH_ugxmLeUM]
- R22. Mobile vertical stacks get more spacing than feels necessary. [AH_ugxmLeUM]
- R23. Separate list items by spacing; if density forces it, use alternating row tints, never a divider on every row (unless lines are the site's chosen style). [c1TvOcKdBVE, EHwZzWd-OnQ]

**Type**
- R24. Tighten letter-spacing on any text ≥70px (negative tracking). [c1TvOcKdBVE]
- R25. Use one brand typeface across logo, product and site where it fits (he uses Apple's New York serif for beauty). [BvbFPzLjWcU]
- R26. Truncate long user content with an ellipsis; test layouts with long strings. [HE4rLEQpiXY]

**Colour and depth**
- R27. No pure #FFFFFF or #000000 page backgrounds; tint them with the accent hue (Tailwind light: `-50` bg + `-500` accent; dark: `-950` bg + `-300` primary). [c1TvOcKdBVE]
- R28. Darker palette steps: saturation +20, brightness −10, hue shifted about 20° toward blue. [c1TvOcKdBVE]
- R29. Dark-mode elevation = lighter surface (brightness +4 to 6, saturation −10 to 20 per level), not shadows. [c1TvOcKdBVE]
- R30. Gradients use one hue (or none). No two-hue clashes like blue to green. [AH_ugxmLeUM]
- R31. Shadows: light-grey colour with a large blur, never Figma-default or transparent black. [AH_ugxmLeUM, NtZeYmTMuo4]
- R32. Status colours are semantic and consistent (the "done" colour never paints undone items); replace vague status text with a number or %. [xHD01_Onac0]
- R33. Hold back the brightest accent for hover or active states when it would overpower at rest. [V3Omp1hm0Sg]
- R34. Overlay icons on photos sit on a contrasting circle; hero photos get a subtle overlay behind text. [HE4rLEQpiXY, BvbFPzLjWcU]
- R35. Avoid the "top-right of the picker" fully saturated default; use desaturated or domain colours. [6CC8lLnqa28]

**Icons, labels and clutter**
- R36. One icon set per area: same stroke width, fill and corner style. Different styles only in separate areas with different jobs. [AH_ugxmLeUM]
- R37. Icon-only buttons are fine for universal icons (home, bookmark, user, search, cart); anything else needs a label or a tooltip. [AH_ugxmLeUM]
- R38. Remove field labels on cards when the content implies them; keep labels where values could be confused (check-in vs check-out). [c1TvOcKdBVE]
- R39. Remove redundant affordances: no carousel arrows on swipe-only mobile, no decorative arrows inside buttons, no card strokes doing nothing. [AH_ugxmLeUM]
- R40. Never let an LLM emit emoji as icons; specify an icon library in the prompt. [xHD01_Onac0]
- R41. Sidebar: user and account switcher at the top, Settings and Help at the bottom, no "Menu" section headings. [xHD01_Onac0]
- R42. Nav dropdowns and menus show image thumbnails when items are products or visual. [VPeTgU7la34, EHwZzWd-OnQ]

**Feedback and motion**
- R43. Every button has hover and pressed states (pressed = slight scale-down, or greyed out while the next step loads). [ld1zhQMXxXU, AH_ugxmLeUM, HE4rLEQpiXY]
- R44. Show a spinner when an action takes noticeably long. [AH_ugxmLeUM]
- R45. Saving an item updates both the icon (filled) and its destination (a dot or badge on the Saved tab). [AH_ugxmLeUM]
- R46. Tooltips on icon-only controls appear after a 1000ms hover and hide on leave. [ld1zhQMXxXU]
- R47. Popover and menu entrance = fade + a few-px upward slide. [NtZeYmTMuo4]
- R48. Springs he uses: tag pop 500ms, stiffness 636, damping 24; spinner steps 300ms delay, stiffness 550, damping 40; success = 300ms delay, ease-out. [ld1zhQMXxXU, NtZeYmTMuo4]
- R49. Every animation must either reveal the product or clarify state; delete animations that do neither. [tNMAFjzapOk, HE4rLEQpiXY]
- R50. Looped animations are slow and minimal (marquee text must stay readable). [ZsP20PN14O0]
- R51. Mouse-follow and hover-only effects have a touch fallback. [ZsP20PN14O0]
- R52. Preloaders stay short and move the content under them as they exit. [ZsP20PN14O0]
- R53. Scrolljacking: avoid. [HE4rLEQpiXY]
- R54. Morphing image or video effects: keep the frame changes small to avoid jank. [EHwZzWd-OnQ]
- R55. Continuous shimmer or loop effects that might bother users get a pause control. [ld1zhQMXxXU]

**Charts**
- R56. Bar charts need a value axis, square (non-rounded) bar ends, and exactly one bar per category. [AH_ugxmLeUM]
- R57. Overspend vs target: draw the target line and colour bars over it distinctly. [jSxxAFxjxbU]


### Techniques

### 4.1 Components
- **Listing card** (c1TvOcKdBVE): row 1, name/location stacked left with price/rating stacked and right-aligned; row 2, spec chips with icons; row 3, labelled check-in/out. No other labels.
- **Name-tag hover pill** over avatars; **delayed tooltip**; **keyboard-shortcut keycaps** that animate per key; **toast** with loading → success (particles) states (ld1zhQMXxXU).
- **Search icon → expanding field** (magnifier dissolves into the field's circle) (ld1zhQMXxXU, HE4rLEQpiXY).
- **Card-stack notification centre** (bottom-right; the drag pulls the others forward) (ld1zhQMXxXU).
- **Upgrade-limit hover** that slides in the Pro value (ld1zhQMXxXU).
- **Sidebar** with icon per item, a hover pill, a dropdown with fade + slide-up, an integration grid with hover labels, a yellow-stroke + 24px-blur-glow selected state, spinner → slide-in check success (NtZeYmTMuo4).
- **Lightbox card** for add-ons: full photo, a gradient under text, an X (V3Omp1hm0Sg).
- **Dealer/location search bar as the final CTA** (V3Omp1hm0Sg).
- **Specs info bar** inside the hero (V3Omp1hm0Sg).
- **Share with scope picker** (slide / chapter / all) and a shared-view owner header (goWOAFqJHpA).
- **Chapter chip** dropdown at the bottom for long story or recap flows, plus a "View summary" dashboard per chapter (goWOAFqJHpA).

### 4.2 Layouts (VPeTgU7la34 unless noted)
- Logo wall (static row, or marquee with edge gradient fade + progressive blur).
- Centered hero (big text, big product image, subtle background gradient) + one differentiator (custom font, inline diagram, interactivity).
- "Clickable multi-section" (tabs or steps swapping a panel; optional auto-advance timer).
- "Simple bento" (plain grid; one tilted card for flair).
- "Straight-line grid" (visible ruled cells, Vercel-style).
- Mega menu with images.
- Competitor comparison section.
- Ultrawide 50/50 split hero for beauty/retail (BvbFPzLjWcU).
- Text-behind-subject hero (trace the subject, subtract it from the headline) (V3Omp1hm0Sg).
- Alternating media-left/right rows, flipped to break monotony (V3Omp1hm0Sg).
- Trim/plan comparison as columns with photo + specs + "See more" hover-reveal (V3Omp1hm0Sg).

### 4.3 Micro-animations with recipes
| Effect | Recipe | Source |
|---|---|---|
| Button label roll | Overflow-hidden mask; two stacked labels translateY(-100%) on hover; scale ~0.95 on :active | ld1zhQMXxXU, ZsP20PN14O0 |
| Fancy button | Label slides up; a circle with a new label slides up beneath; the circle's radius morphs to a rectangle; slight scale | ZsP20PN14O0 |
| Name tag | from translateY(+few px), opacity 0, slight rotate → in; spring 500ms / stiffness 636 / damping 24 | ld1zhQMXxXU |
| Tooltip | show after 1000ms hover; slight overshoot easing | ld1zhQMXxXU |
| Shimmer border | Rotating conic-gradient behind a 1-2px masked ring; pause toggle | ld1zhQMXxXU |
| Text hover pop-out | Inline word hover → image pops near the word | ld1zhQMXxXU |
| Stepper progress | SVG stroke "drawn" via mask or dashoffset between step circles | ld1zhQMXxXU |
| Card stack dismiss | Top card rotate + opacity 0; the rest scale up and translate to fill the gap during drag | ld1zhQMXxXU |
| Highlight-on-scroll text | background-clip:text on a two-stop gradient with stops nearly touching; background-position driven by scroll; optional diagonal and per-line stagger | ZsP20PN14O0 |
| Preloader exit | The loader slides up; the content and background image translate a little with it; short | ZsP20PN14O0 |
| Looped icon | Icon travels a semicircle path drawing its trail; slow | ZsP20PN14O0 |
| Cursor-follow CTA | Container centred on the cursor with lerp easing; disabled on touch | ZsP20PN14O0 |
| Scroll morph to product | Hero media morphs or slides into a dashboard screenshot as the text fades | tNMAFjzapOk |
| Spinner | 180° step rotations, 300ms each, spring stiffness 550 / damping 40 | NtZeYmTMuo4 |
| Success check | Check slides in through a mask (not a fade), 300ms delay, ease-out | NtZeYmTMuo4 |
| Shared-element morph | Same layer name / layout ID across states (a rectangle morphs into a search bar) | NtZeYmTMuo4 |
| CTA card hover | The image zooms *out*; the CTA pops up; the accent colour appears only here | V3Omp1hm0Sg |
| Text swap | Two phrases alternate in one slot on scroll | EHwZzWd-OnQ |
| Hover-diagram | Hovered item rotates forward; the others blur | EHwZzWd-OnQ |

### 4.4 Trends he endorses
Text swapping, hand-drawn annotations over clean bold type, distinctive or animated display type, line dividers as a deliberate style, morphing media, scroll-driven explainer diagrams, images in menus/nav (EHwZzWd-OnQ); simple bento, straight-line grids, images in nav (VPeTgU7la34); 3D hero centrepiece via Spline/Blender (A_Ozpb0XDuw).

### 4.5 Gamification kit (jSxxAFxjxbU)
A central currency (earned, not bought) → leaderboard rank and unlocks. A second currency for consumables. Streaks with reminders. Milestone achievements paying currency. Visible progress (% complete). League leaderboard with promotion, safe and demotion zones and a hidden next tier. Rewards tied to the user's real goal. Normalise competition (local leaderboard for currency and income). Education plus quiz as a currency source. Badges for streak milestones.

### 4.6 Resources from "20 Underrated Web Design Resources" (eeN7yUcIWbw), in his order
1. **UIverse** (uiverse.io): buttons and elements; "copy to Figma".
2. **Logo System** (logosystem.co): logo library.
3. **Phase** (phase.com (?)): Figma-like animation editor, easier than After Effects.
4. **"Fonty"** (caption; most likely **Fontjoy**, fontjoy.com): one-click font pairing from fonts mapped in 3D space.
5. **"Nukes"** (?): bento-grid gallery of trending designs pulled from Twitter/X, "Dribbble on steroids".
6. **Logo Ipsum** (logoipsum.com): placeholder logos (also mentions logo.com).
7. **Burst by Shopify** (Shopify's free stock photos): better organised than Pexels.
8. **"Derves"** (?): slider-driven visual effects, suited to crypto or SaaS landing pages.
9. **Endless Tools** (endlesstools.io (?)): customisable 3D assets.
10. **Design Spells** (designspells.com): curated micro-interactions from big brands.
11. Designer-curated **music playlists** site (name not clear in captions).
12. **Typefaces.today**: display fonts (one of his favourites).
13. **Isocons** (?): customisable isometric icons (rounded or sharp, stroke weight, add-to-folder).
14. **UX of AI** (uxofai.com (?)): AI UX patterns.
15. **Relume Figma kit**: huge community file (about 54 pages of sections and layouts); find it on Figma Community.
16. **Photo Gradient** (photogradient.com (?)): mesh-gradient presets; refresh for new colours.
17. **Unsectioned** (?): websites chopped into searchable sections.
18. **Design Sphere** (?): design podcasts (he listens to Honest UX Talks).
19. **Handy Arrows** (?): hand-drawn arrows.
20. **Wall of Portfolios** (?): portfolios with each designer's experience and location.
Also cited elsewhere in this share: siteinspire.com and 21st.dev (AI reference/components), html.to.design (HTML→Figma), Coolors (base colours), Tailwind palette (bg/accent pairs), Flaticon, Feather and Phosphor icons, Mobbin (UI element library, sponsor), minimal mockups (product mockups), Google Images → Tools → Size: Large, Spline, Blender, Wix Studio.

### 4.7 Process
- **Redesign process** (V3Omp1hm0Sg, BvbFPzLjWcU): list what's wrong section by section → gather 3-5 competitor references and pick a favourite (Rivian, Lucid) → rethink the information architecture (drop pages that only redirect) → source a better hero image → rebuild section by section, changing the layout each time → finish with hover states.
- **Product-designer process** (HE4rLEQpiXY): intent → minimum UI for that intent → add a second intent → decide which content shows → stress-test the content → motion only for clarity → system rules.
- **AI-assisted UI** (xHD01_Onac0): reference screenshot of a real product + 4-part prompt → HTML/CSS → html.to.design → manual pass on fonts, alignment, colour and semantic colour.
- **Feature brainstorming for data products** (goWOAFqJHpA): mine behavioural data (skips, time of day, YoY change, single-track obsession) for personal, shareable stats.
- Mood board before the canvas; quantity breeds quality; step away when stuck (6CC8lLnqa28).


### Against common advice

1. **"Hick's law" for TikTok's swipe target** (ixUq4HM4FNg): he describes target size and distance, which is **Fitts's law**. Hick's law (choice count vs decision time) fits his separate point about removing options. A skill should use the correct names.
2. **Infinite scroll is worse than "Load more"** (HE4rLEQpiXY), against feed-style defaults: load more gives control and footer access.
3. **White space can be overused** (V3Omp1hm0Sg): against "more white space is always better", Fisker's sparse layout with giant text is "disjointed"; tighten proximity.
4. **Lines:** "lose the lines" for list separation (c1TvOcKdBVE), yet line dividers and straight-line grids are a trend he likes (EHwZzWd-OnQ, VPeTgU7la34). Reconciled position: lines are fine as a deliberate **style system**, not as default separators between items.
5. **Mixed icon styles are allowed** in one product if they live in visually separate areas with different jobs (AH_ugxmLeUM), against "one icon set everywhere".
6. **Remove carousel arrows on mobile** and **remove the pause button** (AH_ugxmLeUM, goWOAFqJHpA): he trusts learned gestures (swipe, tap-to-pause) over visible affordances, which goes against discoverability-first advice.
7. **Remove card field labels** (c1TvOcKdBVE): "if your UI isn't clear enough to imply these labels, you're not doing it right". Keep only labels that resolve real ambiguity.
8. **8px grid is not sacred** at large sizes (c1TvOcKdBVE): round to 5 or 10; 120 vs 128 is irrelevant.
9. **Shadow fix = change the colour, not lower the opacity** (AH_ugxmLeUM): light grey plus a big blur, rather than black at low alpha.
10. **Gradients: default to none**; if used, one hue only (AH_ugxmLeUM).
11. **Tooltip delay of 1000ms** (ld1zhQMXxXU): longer than the 300-500ms many systems use; he wants tooltips only for deliberate hovers.
12. **Nested radius formula has limits** (c1TvOcKdBVE): inner = outer − gap breaks when the gap exceeds the outer radius; he eyeballs instead.
13. **Rounded bar tops are bad** (AH_ugxmLeUM), against the popular Dribbble style.
14. **Hide weak images** (V3Omp1hm0Sg): when assets are poor, tuck them behind the next section rather than feature them.
15. **Dribbble is a bad reference** for usability and for AI prompting (BvbFPzLjWcU, xHD01_Onac0): tall artboards hide the real 1000px viewport; dense details confuse LLMs. Yet he consciously keeps purely aesthetic touches (an arrow-only button) when making "Dribbble-worthy" shots.
16. **Scrollytelling and heavy 3D are not "better design"** (6CC8lLnqa28): fit for awareness campaigns, not conversion sites. But a 3D centrepiece lets you design less around it (A_Ozpb0XDuw).
17. **Don't strike through old prices or limits** on upgrade hovers (ld1zhQMXxXU): slide in the replacement instead.

## Videos 37–53

### Rules

**Typography**
- R1. Use at most 2 font families; 3 only as display, sans and mono-for-captions. Never 4. [7sUUzOCv47U]
- R2. Never set paragraph or small text in a display or handwritten font. [7sUUzOCv47U]
- R3. Build the type scale from 16px with ratio 1.27 (√φ): 16 / 20 / 26 / 33 / 42 / 53. Use 1.17 (∛φ: 16 / 19 / 22 / 26 / 30) for dashboards and mobile. Use 1.62 only for a single body-to-heading pair. [7sUUzOCv47U]
- R4. Size fonts fluidly with `clamp(min, calc(min + (max−min) * ((100vw − 320px) / 1600)), max)`, not per-breakpoint overrides. [7sUUzOCv47U]
- R5. Line height: body about 1.5; headings 1.1–1.3; bigger text gets lower values. Never leave auto on very large display text. [7sUUzOCv47U]
- R6. Tracking: tighten large text, loosen small text. [7sUUzOCv47U]
- R7. Use at most 2 weights per page, at least one weight step apart. Avoid ultra-thin and ultra-black for regular text. [Lp6ey4AyDzA, 7sUUzOCv47U]
- R8. Use at most 2 text colours: primary at 100%, secondary at 45–70% opacity of the same colour. [Lp6ey4AyDzA, 7sUUzOCv47U]
- R9. Keep paragraphs at 100% contrast. Make subheadings bold for scanning; headings win on size, not weight. [7sUUzOCv47U]
- R10. Use giant display text at most twice per page. [Lp6ey4AyDzA]

**Colour and surface**
- R11. Use off-white instead of #fff for light-mode backgrounds and bluish-black instead of #000 for dark. Prefer muted accents. [Lp6ey4AyDzA, ulSOdTgoGeY]
- R12. In dark mode, lighten and desaturate the brand primary and accents. Never reuse light-mode saturated values. [ulSOdTgoGeY]
- R13. Dark-mode ambient colour: a background gradient between two brand colours with brightness pulled way down; optional light noise. [pGYLZyBE32o]
- R14. Every tint or colour difference must be visibly distinguishable. If you can't tell the backgrounds apart, remove the difference or increase it. [gKM6b2EnW1k]
- R15. Shadows: offset-x ≤ offset-y; blur = 1.3–2× offset-y; opacity 15–20% (stronger on dark backgrounds). If a gradient or shadow doesn't clearly help, delete it. [Lp6ey4AyDzA]

**Layout and spacing**
- R16. Separate content with space before reaching for cards, borders or dividers. [Lp6ey4AyDzA]
- R17. Don't repeat the same section layout twice on a page. Alternate full-bleed, cards, multi-column, stacked and box-breaking layouts. [ulSOdTgoGeY, pGYLZyBE32o]
- R18. Dashboard placement: rank modules by importance; most important goes top-left; leave no awkward empty cells. [Yr2uIcFZDDQ]
- R19. Remove labels that restate the obvious, duplicate controls, and icons with no meaningful action. [Yr2uIcFZDDQ, pGYLZyBE32o]
- R20. Every control must be logically possible in the domain (no "receive" on a credit card). [Yr2uIcFZDDQ]
- R21. Spacing on a 4px grid. [gKM6b2EnW1k]
- R22. Footer with 3–5 links: centred single row, logo above, socials below, © left, credits right. No multi-column footer unless there are many links. [gKM6b2EnW1k]
- R23. A text-only section needs body copy of 3+ lines; text over a photo needs a gradient scrim. [P2ksReDwWkE]
- R24. Carousels hold 3–10 items, show position dots, have a big next control and are draggable. [P2ksReDwWkE, gKM6b2EnW1k]

**Components**
- R25. Each section or hero has exactly one filled primary button. Secondary buttons are outline or ghost. [Lp6ey4AyDzA]
- R26. Destructive confirm: the destructive action is filled red (primary); Cancel is ghost or outline. [Lp6ey4AyDzA]
- R27. Form labels sit above the inputs and stay visible; placeholders show example values only. Sign-up forms carry a "Create account" title and a link to log in. Input fill is off-white with the stroke at about 40% opacity. [gKM6b2EnW1k]
- R28. Repeated cards are whole-card links with a hover arrow; add a button only for a specific action. [gKM6b2EnW1k]
- R29. Pricing card: the CTA sits right under the price as an outline button; check-mark feature list including one excluded feature; plan name and one-line description; billing fine print; price area separated by a primary-colour tint at low opacity, not a rule. [gKM6b2EnW1k]
- R30. Chips: vertical padding is ½ or ¼ of horizontal padding; never in the primary CTA colour; thinner than buttons. [gKM6b2EnW1k]
- R31. Mobile tab bar: all icons inline and the same size (no raised centre button); inactive icons clearly visible; brand colour on active only; labels readable if present; generous tap spacing. [gKM6b2EnW1k]
- R32. Icons come from one consistent pack; simpler at small sizes. [Lp6ey4AyDzA]
- R33. Hero CTA for an input-driven product can be the input itself (prompt or search field). [pGYLZyBE32o]
- R34. Any optional or nagging behaviour shows how to turn it off where it appears; no shaming copy; no blocking modals for chores. [BUDipdbKK7Y]

**Charts**
- R35. Line charts: no curve smoothing, no fading of the line, horizontal gridlines plus markers, a time-range selector (dropdown if tight), a legend when there are 2+ series, a grey previous-period comparison for business metrics. [gKM6b2EnW1k, Yr2uIcFZDDQ]
- R36. Every number on a chart has a label or unit. Don't show a chart and a stat that say the same thing. Income vs expense is a diverging bar chart. Use a full-screen icon for detail. [Yr2uIcFZDDQ]
- R37. Case-study and report charts have a title, axis titles, a legend and annotations. [t7mpEDXzjCg]

**Motion**
- R38. Large reveals (loader exit, width expansion, wipes) use expo in-out (`expo.inOut`; CSS approx. `cubic-bezier(0.87,0,0.13,1)`), 1.0–1.3s coded (700–800ms in the Figma prototype). Opacity fades use ease-in-out at 200–300ms (0.3s for the nav). Stagger siblings by 0.2s with a 0.6s duration. [d4MF6pdAZNw, nl8OFGdx75w]
- R39. When a loader slides away, the page content rises with it at the same time (pre-offset by 100% of its own height, then animate to 0). [d4MF6pdAZNw]
- R40. Respect usability when adding motion: marquees and decorative effects (kaleidoscope) must not carry essential information. [ulSOdTgoGeY, MZSm6MA8bww]

**Process and verification**
- R41. Review on the real target viewport (desktop and phone, with the browser chrome), not zoomed out. [Lp6ey4AyDzA, 7sUUzOCv47U]
- R42. Never ship lorem ipsum; demo content is realistic. [59XWYgN00nQ]
- R43. Above the fold leads with the key content (portfolio: name plus what you do plus headshot; dashboard: top-priority modules), not decorative headers. [ToJiXPTNnLY, Yr2uIcFZDDQ]


### Techniques

- **Dribbble zoom-in audit** (Yr2uIcFZDDQ). For each element ask three questions: what does it do, is it possible in this domain, is it duplicated? Then merge, delete or convert, rank the rest high, mid and low, and lay them out top-left first. A good template for a "critique a dashboard" mode.
- **Hierarchy triad** (Lp6ey4AyDzA, 7sUUzOCv47U). Size plus 2 weights plus 2 opacities; weight and opacity are interchangeable at small sizes.
- **φ-derived type scales plus a fluid clamp line** (7sUUzOCv47U). Emit CSS custom properties per step, each with a clamp from mobile (320px) to desktop (1920px).
  ```css
  :root{--fs-0:clamp(15px,calc(15px + 1*((100vw - 320px)/1600)),16px);
        --fs-1:clamp(18px,calc(18px + 2.4*((100vw - 320px)/1600)),20.4px); /* ×1.27 */ }
  ```
- **Shadow formula** (Lp6ey4AyDzA): `box-shadow: X Y B rgba(0,0,0,.15–.2)` with X ≤ Y and B = 1.3–2×Y.
- **Offset-duplicate depth** (ulSOdTgoGeY): a solid copy of the button or card behind it, offset, that shifts on hover. A cheap alternative to shadows.
- **Stickers** (gKM6b2EnW1k): a 12-point rounded star, a display font, optional circular text, and a hard offset shadow in a darker tint at 100% opacity. Use it to break boxy layouts.
- **Card gradient-overlay variant** (gKM6b2EnW1k): image at about 75% of the card height, a smooth gradient from its bottom edge upward into the card colour, text over it.
- **Hover-reveal card** (pGYLZyBE32o): on hover, blur and scale the image and fade in extra copy. Use a gradient border to mark the purchase card.
- **Dark ambient gradient** (pGYLZyBE32o): two brand hues darkened as a background gradient, with light noise.
- **Carousel timer dot** (gKM6b2EnW1k): the active indicator stretches into a progress bar for auto-advance.
- **Section library** (P2ksReDwWkE): cards on a dark band; a thin cropped photo interlude with a scrim; a giant headline with the nav under it (290px display); stacked sticky cards for 3–5 steps; a draggable carousel of 3–10 cards; a full-width bento sized to content; cutout text; a whitespace text section.
- **Box-breaking** (ulSOdTgoGeY): overlap section edges, stagger card heights, bleed a card row off-screen, use cut-out product images.
- **Mesh gradient** (MZSm6MA8bww): stacked blurred translucent circles in overlay blend; more layers give more vibrancy. In CSS: several blurred radial-gradient or `filter: blur()` blobs with `mix-blend-mode: overlay`.
- **Metallic and clay surfaces** (MZSm6MA8bww): linear grey-blue gradient with a mid-point colour change, a white radial overlay, two inner shadows and a 20% tint layer for metals. Clay is a muted fill with two opposing inset shadows.
- **GSAP load choreography** (d4MF6pdAZNw), all in paused timelines played on load:
  - a loader that slides up while the content rises together, using the `'<'` position parameter;
  - a pill nav that grows dot, circle, bar, using `getProperty` height then `fromTo` maxWidth from height to final, followed by staggered children;
  - a text wipe with a bar the colour of the text: grow, reveal the text with `set`, re-anchor with `right:0; left:auto`, then shrink.
  
  Add a `prefers-reduced-motion` skip. That is my addition, not Kole's.
- **Figma prototype timing grammar** (nl8OFGdx75w): a hold of 800–1000ms, then the big move (400–800ms, custom expo bezier), then short ease-in-out fades of 200ms. Chain 1ms delays and instant cuts for sequencing. Build expand animations backwards from the end state.
- **Case-study skeleton** (t7mpEDXzjCg): problem plus solution summary up top, then research, persona (goals and frustrations), a small colour-coded flow, lo-fi sketches, large final screens with rationale, reflection. Readable in 10–15 minutes, with chapter-style headings.
- **Conversion lens** (5JxUJ1fuyO8): every page answers "is the info clear?" and "do I know where to click next?"; pick sections (testimonials, impact stats) by the business goal.


### Against common advice

1. **Don't bold the heading by default** (7sUUzOCv47U). Common practice makes headings bold and body grey. Kole: size already gives the heading attention, so leave it regular. Keep the paragraph at 100% opacity (not lightened). Put the bold on the subheading. His reason is that the usual pattern gives the smallest text the least contrast.
2. **The golden ratio is too aggressive for a type scale** (7sUUzOCv47U). He uses √φ (1.27) as the default and ∛φ (1.17) for dense UIs, keeping φ only for a single body-to-heading pair.
3. **No typographic breakpoints** (7sUUzOCv47U). He prefers one linear min/max/calc formula over 320–1920px to stepped media-query sizes.
4. **Smoothed line charts are bad** (gKM6b2EnW1k, Yr2uIcFZDDQ), against the popular Dribbble style. Curving hides the true value at the tip, and fading the recent data looks like hiding bad news.
5. **The destructive action gets the primary filled style** (Lp6ey4AyDzA). Some guidance de-emphasizes destructive buttons. Kole says that if Delete is what the dialog is for, it is the filled red primary and Cancel is ghost or outline.
6. **Remove the centre "+" FAB from tab bars** (gKM6b2EnW1k), against the common raised-centre pattern. It is the least-used tab, so it shouldn't dominate.
7. **Pricing CTA at the top of the card but outline-only** (gKM6b2EnW1k). Most pricing cards put a filled button at the bottom. He moves it up near the price and drops its fill to keep the hierarchy.
8. **Fewer cards and containers despite the bento trend** (Lp6ey4AyDzA). Bento is fine (P2ksReDwWkE), but in grids like e-commerce, whitespace beats cards and dividers. Separately, a bento needs plenty of real content to work.
9. **Don't copy big-company footers** (gKM6b2EnW1k). Apple and Linear patterns don't fit a site with about 6 links.
10. **Gradients and shadows are optional** (Lp6ey4AyDzA): "any good website with a gradient can be a good website without."
11. **Repeated cards need no CTA button** (gKM6b2EnW1k). The whole card is the link, with a hover arrow as the affordance.
12. **UX beats UI for results, and users tolerate ugliness when it works** (5JxUJ1fuyO8). Ad-covered image-compression sites are fine if they're fast. He also cites the aesthetic-usability effect, so his target is both.
13. **Three fonts is acceptable in a specific form** (7sUUzOCv47U), against the strict "max 2" rule: display plus sans plus mono for captions. His own portfolio does it.
14. **Serif is easier to read at small sizes** (7sUUzOCv47U). He states this as why print uses serifs. Screen-UI guidance often disagrees; treat it as his claim, not a UI rule.
15. **Case studies are optional for UI, graphic design and copywriting portfolios** (ToJiXPTNnLY). Only process-heavy work (UX) needs them, and his own portfolio has none.
