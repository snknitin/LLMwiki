# Resources: what to reach for, and when

Taste lives in this skill and the project's DESIGN.md, not in runtime browsing: visiting catalogues every screen wastes context and pulls toward their look. Open a resource for a specific gap, adapt what you take to the project's tokens, and check the licence before vendoring code.

## Components and primitives
- **Native HTML first**, then a headless primitive (Radix, React Aria, Base UI, Vaul for drawers, cmdk for palettes), then hand-rolled with full keyboard, focus and ARIA. Never `<div onClick>` as a button.
- **shadcn/ui**: the default React primitive set and registry format. Replace its theme with the project's tokens first; shadcn defaults are a look of their own.
- **coss.com/ui** (Base UI + Tailwind, from Cal.com), **reui.io/components** (app shells, settings, data grids): vetted variants when starting a React app's primitive layer.
- **beautifului.dev**: agent-UI pieces (thinking trace, approval card, tool chips, task rows, diff table) for the Agents board and similar run monitors.
- **Amicro** (amicro.dev, `npx @subhanhq/amicro add`): one loader, mono chart or micro-interaction at a time.
- **21st.dev, uiverse.io, beUI, Rare UI, EasyUI**: a specific widget or interaction; restyle to the project's tokens.
- **NumberFlow, dither-kit, evilcharts**: animated numbers and charts for shadcn apps.
- **ThreeUI** (MIT community tier): only for a Persuade hero that earns 3D, with a static fallback.

## Checklists and guidelines
- **Vercel Web Interface Guidelines**: interaction, forms, focus, loading and content rules; the best checklist for behaviour.
- **designsystemchecklist.com**: per-component state and accessibility checks when setting up tokens or reviewing a component.
- **make-interfaces-feel-better** (Jakub Krehel): final polish constants.
- **Emil Kowalski** (emilkowal.ski, "You don't need animations"; his skills repo): whether and how to animate.
- **Google DESIGN.md** (`npx @google/design.md lint | diff | export --format css-tailwind`): lint a DESIGN.md's tokens and contrast, export them to CSS.

## References for patterns (look, don't copy)
- **Mobbin MCP** (paid, owner credentials): real shipped flows (onboarding, paywalls, settings).
- **collectui.com, recent.design, siteinspire.com, Design Spells, 60fps.design** (iOS motion): free pattern and interaction inspiration.
- **VoltAgent awesome-design-md / getdesign.md**: real brands' tokens. Use for craft-level calibration (how Linear spaces a list), never as a project's identity.
- Reference real products, not Dribbble shots: tall artboards hide the real viewport and dense details confuse models (Kole).

## Fonts, colour, assets
- **Google Fonts** pairings chosen for the subject; **typefaces.today** for display faces; **Fontjoy** for quick pairing ideas.
- **Coolors** for a base, then build ramps by the rules in [craft.md](craft.md); **OKLCH** for themes and chart hues.
- **Lucide, Phosphor, Feather**: one per app.
- **Burst by Shopify**: free photos when a page needs real imagery; otherwise real product UI crops.

## Charts and reports
- **dataviz** (Claude host skill) when present; **Lieflat Charts** (noncommercial licence) for its card anatomy (conclusion headline, legend · range subtitle, source line) and honesty rules; **agent-html** for single-file offline reports with a validator.

## Tools for looking
- **Playwright** screenshots (`npx -y playwright@1.64.1 screenshot ...`), the built-in browser pane, or `agent-browser`. On FirstSpark use the cached Playwright Chromium; there is no system Chrome.
