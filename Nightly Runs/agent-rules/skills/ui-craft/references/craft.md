# Craft: the numbers

The values below are the defaults when DESIGN.md says nothing. Sources: Kole Jain (KJ), Emil Kowalski (EK), Jakub Krehel's make-interfaces-feel-better (JK), interface-design (ID), Refactoring UI (RUI), Vercel guidelines (VG), impeccable (IM), OpenAI's frontend guide (OA).

## Type

- **Families:** one is enough; two when one is a display face; three only as display + text + mono for code/IDs. Never four. Display and handwritten faces never set paragraphs. (KJ)
- **Choose, don't default:** Inter, Roboto, Arial or the system stack only as a logged decision. The second-order defaults (Space Grotesk, Fraunces, Clash Display, Geist) count as defaults too. (OA, Anthropic cookbook)
- **Scale:** base 16px. Ratio 1.27 (√φ) for most UI: 16 / 20 / 26 / 33 / 42 / 53. Ratio 1.17 (∛φ) for dense dashboards and phone: 16 / 19 / 22 / 26 / 30. Golden ratio 1.618 only between one body size and one display size. (KJ) Interface-design's equivalent: 1.2 dense, 1.25 product, 1.333 expressive.
- **Sizes per surface:** at most ~6 sizes on a page; dashboard text tops out near 24px (a hero metric may be larger, once); giant display type at most twice per page. (KJ)
- **Fluid sizes, not breakpoints:** one `clamp()` per step from 320px to 1920px: `clamp(MIN, calc(MIN + (MAX - MIN) * ((100vw - 320px) / 1600)), MAX)`. (KJ)
- **Line height:** body 1.5; headings 1.1–1.3; display 1.0–1.15. Serif body gets a little more than sans. (KJ, frontend-design)
- **Tracking:** −2% to −3% on large headings (kern by hand above ~70px); slightly positive on small caps labels; never tighter than −0.04em. (KJ, IM)
- **Weights:** two, at least one step apart (400 + 600). Nothing under 400 for reading text. (KJ, RUI)
- **Hierarchy triad:** size + weight + colour together. Kole's twist: headings big but regular weight, subheadings bold, paragraphs at 100%. Never make the smallest text the faintest. (KJ)
- **Text tones:** primary 100%, secondary 55–70% of the same colour; a third, muted tone only for metadata. In light product UI read as lightness: headings ~11%, body 15–20%, subtext 30–40%. (KJ)
- **Measure:** 60–75 characters for reading; 45–75 acceptable. (IM, RUI)
- **Details:** `font-variant-numeric: tabular-nums` on every number that changes or lines up; `text-wrap: balance` on headings, `pretty` on body; curly quotes and `…`; non-breaking space in "10 MB". (VG, ID)
- **Phone:** type is the same size or larger than desktop, never shrunk (iOS base 17px); inputs ≥16px so iOS doesn't zoom. (KJ, VG)

## Spacing and layout

- **Scale:** 4, 8, 12, 16, 24, 32, 48, 64, 96. Above 48, round to 5s/10s or step ~1.5x; adjacent steps ≥25% apart. (KJ, RUI)
- **Grouping:** label → value 4–8px; heading → its text 8px; text → its buttons 24–32px (at least 2x the heading gap); between groups ≥2x the inside gap. (KJ)
- **Edges:** every element shares at least two edges with its container or a neighbour (a receipt: items flush left, prices flush right). When things float, line them up into a new edge rather than hiding them. (KJ)
- **Density:** decide once (tool panel 12–16px padding, airy page 24px+) and repeat. A crowded list is fixed by grouping, avatars and muting defaults, not by more whitespace; too much whitespace splits related things apart. (KJ, ID)
- **Containers:** space first; then a single divider; then a quiet border; cards only for peer objects. Never a card inside a card. A card earns its chrome only if removing border, background and radius hurts comprehension. (KJ, OA)
- **Width:** cap line and row width on wide screens; a 1440px screen is not a reason for 1440px rows. (KJ)
- **Real viewport:** a desktop shows ~1920x1000 or 1440x~800 at once; a phone loses ~100px to browser bars. Design the first screen to that, not to a tall artboard. (KJ)

## Colour

- **Neutral layers, not 60-30-10.** Product UI needs ~4 background layers, 1–2 border colours and 3 text tones, plus one accent ramp and semantic colours. 60-30-10 is a beginner guard only. (KJ)
- **Light mode:** page background 96–99% lightness, cards white or one step up; neighbouring surfaces differ by ~2% lightness; borders ~85% lightness (or rgba 0.08–0.12), never black. Pure white is fine for the top layer; don't put white cards on a pure-white page. (KJ, ID)
- **Dark mode is its own palette:** steps between neutrals double (4–6%); raised surfaces are lighter, not shadowed (+4–6 brightness, −10–20 saturation per level in HSB); body text light grey; pure white only for key text; accents from the 300/400 shades, desaturated; borders rgba 0.06–0.12. (KJ, ID)
- **Tint the neutrals** with a little of the brand hue: OKLCH lightness −0.03, chroma +0.02 per neutral, hue = brand hue. Tailwind pairs: light `-50` ground + `-500` accent; dark `-950` ground + `-300` accent. (KJ)
- **Accent ramp:** base 500/600, hover 700, link 400/500; 1–2 accents at most; accent ≈10% of the screen. Brand colour on the primary action, not on everything that can take it. (KJ, ID)
- **Semantic beats brand:** red = destructive/danger, amber = warning, green = success, blue = link/info, regardless of brand. Status colours never lie (the "done" colour never paints undone items). (KJ)
- **Charts:** series in OKLCH at equal lightness and chroma, hue stepped 25–30°; or one hue with darkness for importance. (KJ, Lieflat)
- **Shade building (HSB):** each darker step saturation +20, brightness −10, hue nudged ~20° toward blue. (KJ)
- **Contrast:** text ≥4.5:1, large text and non-text ≥3:1; check text over images or shaders at their brightest frame. If the brand colour fails, darken it or rotate the hue. (KJ, WCAG)
- **Decoration:** no decorative gradients. Allowed: a photo scrim, a one-hue chart area fade, a mesh or noise field as identity on a Persuade page. Never two clashing hues, never gradient text. (KJ, IM)

## Surfaces, depth, shape

- **One depth strategy per app:** tonal steps, quiet 1px borders, soft shadows, or hard offset. Never border + shadow on the same resting card. (ID)
- **Soft shadow recipe:** light grey colour (not black), opacity 15–20%, blur 1.3–2x the Y offset, X ≤ Y; cards least, popovers and menus most; never the first thing you notice. No shadows in dark mode. (KJ)
- **Hard offset (neo-brutalist) recipe:** 2–3px border, `6px 6px 0 <ink>`, collapses on press. Only when it is the chosen direction. (Mia lab)
- **Radius:** one radius family; one value for small components (~8–10px) and identical sizes for identical components. Nested: inner = outer − gap (30/10 → 20; ignore when padding > 24px). Never mix sharp images with round buttons. (KJ, JK)
- **Images:** 1px inset outline at black 10% (light) or white 10% (dark), never a tinted colour. Text over photos sits on a gradient scrim from the bottom (image ~3/4 of the card), never a flat full overlay, never over the focal point. (JK, KJ)
- **Browser surfaces:** theme `::selection`, caret colour, focus ring (`:focus-visible`, 2px, offset 2px, accent), scrollbars, `color-scheme`, `theme-color`. (IM, VG)

## Icons, buttons, inputs

- **Icons:** one library per app (Lucide, Phosphor, Feather), same stroke and fill; icon size = the line-height of its text; stroke 1.5px beside 400-weight text, 2px beside 600; `currentColor`; outline by default, filled for active. Neutral unless they show status. Never emoji. (KJ, JK)
- **Icon-only controls:** only for universal icons (home, search, close, settings, bookmark); everything else gets a label or a tooltip (first tooltip after a delay, neighbours instantly); always an `aria-label`. (KJ, EK)
- **Buttons:** states default, hover (slightly lighter), pressed (slightly darker, scale 0.96–0.97), focus, disabled (desaturated, never scaled), loading (spinner overlaid, size unchanged). Commit on release; menu triggers open on press. Labels 1–3 words, verb first, naming the object ("Save draft", "Pay $24"); the success toast reuses the verb ("Saved"). (KJ, EK, JK, VG)
- **Chips vs buttons:** chips are for filters, selection and metadata, thinner than buttons (vertical padding ½–¼ of horizontal), never in the primary colour. (KJ)
- **Hit areas:** ≥44x44 on touch, ≥24x24 (WCAG 2.2) and ideally 40 on dense desktop; extend with a pseudo-element, never overlapping. (VG, JK)
- **Inputs:** label above the field, always visible; placeholder shows an example ("e.g. 2,400"); off-white fill with a ~40% stroke or slightly darker than the surface; error = red border + message + icon beside the field; Enter submits; never block paste; don't pre-disable submit. (KJ, VG)

## Motion

- **Decide by frequency:** 100+ times a day (keyboard, command palette, list navigation) → no animation; tens a day → minimal; occasional (modals, toasts, drawers) → standard; rare (first run, a milestone) → may delight. (EK)
- **Durations:** press 100–160ms; tooltip 125–200; dropdown 150–250; modal/drawer 200–300 (500 max); exits faster and smaller than entrances. Stagger 30–80ms, only on rare entrances. (EK)
- **Curves:** enter and exit `cubic-bezier(0.23, 1, 0.32, 1)` (ease-out); on-screen movement `cubic-bezier(0.77, 0, 0.175, 1)`; drawers `cubic-bezier(0.32, 0.72, 0, 1)`. Never `ease-in`, never linear for UI. Springs with zero bounce for UI; Kole's pop: stiffness 636 / damping 24 (~500ms). (EK, KJ)
- **Never** animate from `scale(0)` (start at 0.95 + opacity 0); popovers grow from their trigger, modals stay centred; `transition: all` is banned; only `transform` and `opacity` unless measured smooth. (EK)
- **Hover effects** behind `@media (hover: hover) and (pointer: fine)`; mouse-follow effects need a touch fallback. (EK, KJ)
- **Reduced motion:** under `prefers-reduced-motion: reduce`, cross-fade instead of moving; motion is never the only feedback (a colour, icon or label also changes). (JK, EK)
- **Persuade pages:** one orchestrated page-load or reveal beats fade-ups on every section. Big reveals use expo in-out (~`cubic-bezier(0.87, 0, 0.13, 1)`) at 1.0–1.3s; fades 0.2–0.3s; preloaders under ~800ms and the content rises with them. (KJ, frontend-design)

## Copy

- Headings name the area or the action ("Plan status", "Last sync"); the page must be understandable from headings, labels and numbers alone. If cutting 30% of the copy improves it, keep cutting. (OA)
- Empty state: what's empty, why, and the one next action (a button). Error: what happened and how to fix it; never apologise, never blame. Success: what happened and what's next. (frontend-design, hueyexe)
- No developer text on screen: no ISO timestamps, raw ids, server addresses, JSON, stack traces. Dates read like a person wrote them ("Tue 28 Oct, 07:00").
- Pluralise correctly ("1 note", "2 notes"). Use the real dash characters (– —), saved as UTF-8.
