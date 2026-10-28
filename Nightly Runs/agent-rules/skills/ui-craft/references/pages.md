# Pages: landing, marketing, showcase, single-file HTML (Persuade surfaces)

For these the brief's concept can be bolder and the texture kit in [directions.md](directions.md) comes into play. design-taste-frontend's `draw.mjs` and `inspect.mjs` are worth running here (skip its motion quota).

## The first screen

- It is one composition, like a poster: the product or brand is the loudest thing. Budget: the name, one headline, one sentence, one CTA group, one dominant visual. Nothing else above the fold. (OA)
- The headline says what it is and how it helps, in plain words; never the product name in a corner at 12px; never a lifestyle photo standing in for a SaaS product. (KJ)
- One primary CTA, at most two; the nav CTA and the hero CTA carry the same label when they go to the same place. For an input-driven product, the hero CTA can be the input itself (a search or prompt box). (KJ)
- Fit the hero to the real viewport (1440x~800, 1920x~1000), not a tall artboard. (KJ)
- The first frame must look finished before any interaction or animation: no dark void with a faint centred title. (Mia lab)

## Sections

- No two consecutive sections share a layout. Vary formats: full-bleed image, bento with real content (3–10 cells), clickable multi-section (design every tab), draggable carousel (3–10 cards, position dots, a big next control), stacked sticky cards, a thin cropped photo interlude with a scrim. (KJ)
- A text-only section needs body copy of 3+ lines; a feature section uses much larger visuals and far less text (Kole cut ~90% in one rebuild). Prefer real product UI, cropped to the part that matters, over stock photos or generic icons. (KJ)
- Section titles above a self-explaining bento are redundant: drop them. (KJ)
- Logo wall: a static row is the simple default; a slow marquee with edge fade is the upgrade. Never invent logos, testimonials or stats. (KJ, OA)
- Footer for 3–5 links: one centred row, logo above, socials below; no Apple-style five-column footer for six links. (KJ)
- Break the grid on purpose, once or twice: overlap a section edge, let a card row bleed off-screen, a cut-out product image. Never in dashboards. (KJ)
- Pricing: at most 4 plans, prices ascending, price bigger than plan name, the CTA under the price, "Everything in X, plus…", one crossed-out feature, discounts shown. (KJ)

## Kole's maturity ladder (score with it)

- **2/10:** flat nav, long vague copy repeating the company name, unrelated stock imagery, haphazard colour.
- **6/10:** stacked hero over real product screenshots, outlined CTA hierarchy, a simple load animation.
- **8/10:** bento of zoomed product crops, punchy copy, social proof, a mega menu with images.
- **10/10:** benefit copy, leading lines, colour threading the sections, one signature effect (blur, noise, a mesh sampled from the imagery), smooth menus, hover CTAs. No 3D required.

## Motion on pages

- One orchestrated moment (a page-load sequence or one scroll reveal) beats a fade-up on every section; per-section fade-ups and hover lifts on every card read as AI-made. (frontend-design)
- Motion reveals the product or clarifies; scroll-jacking almost never; loops slow and minimal; mouse effects get a touch fallback; preloaders short, and the content rises with them as they exit. (KJ)
- Recipe, GSAP load choreography: paused timeline played on load; loader slides up while content rises from +100% at the same time (`'<'`); big moves `expo.inOut` 1.0–1.3s; fades 0.3s; stagger 0.2s. Skip it all under reduced motion. (KJ)

## Techniques that make single-file HTML look crafted

From the best of 2,300 AI-generated pages (Mia's AI Lab), all made without images or web fonts:
- Paper grain or fibre: an SVG `feTurbulence` filter as a data-URI background, blended `multiply`.
- Halftone: `radial-gradient` dot patterns, rotated per ink (15°/45°/75°).
- Overprint: stacked layers with `mix-blend-mode: multiply` and a few px of misregistration.
- Fitted mastheads: canvas `measureText` or SVG `textLength` so a title fills the width exactly.
- Line drawing: `pathLength="1"` + `stroke-dashoffset` driven by a custom property.
- Colour themes that animate: registered `@property` colour custom properties.
- Container-query units (`cqw`) so a composition scales as one piece.
- Hard-edged print look: 2–3px borders, `8px 8px 0 #000` shadows that collapse on press.
- Engraving: the same SVG path twice, a pale offset highlight under the ink.

Also from that study: pages under ~8KB were almost always thin. Density of real content and craft, not word count of the prompt, separated the good from the weak.

## Single-file deliverables

One self-contained HTML file: inline CSS and JS, no CDN unless allowed, a viewport meta tag, works offline, readable at 390px, `prefers-reduced-motion` respected, UTF-8 saved so dashes survive.
