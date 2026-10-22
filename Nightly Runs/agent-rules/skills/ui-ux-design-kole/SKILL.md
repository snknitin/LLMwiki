---
name: ui-ux-design-kole
description: Apply Kole Jain's UI/UX principles to frontend code.
version: 0.1.0
author: Nitin Kishore, Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [ui, ux, design, frontend, aesthetics]
---

# UI/UX Design Principles — Kole Jain

## When to Use

Use when generating, reviewing, or refining frontend code — landing pages, dashboards, SaaS UIs, mobile apps, or any AI-coded interface. Apply to catch beginner mistakes, enforce design consistency, and elevate output from "functional" to "polished."

Source: Kole Jain's YouTube tutorials (16 videos, ~100K+ subs).

## Core Philosophy

1. **Design is storytelling, not decoration.** Every element should guide the user toward an action. Flare without function is noise.
2. **The first 70% takes 30 seconds. The last 30% ruins your Saturday.** AI generates functional frontends fast; polish requires deliberate attention to spacing, consistency, and micro-interactions.
3. **Leverage existing layouts before inventing new ones.** 30+ years of web conventions exist for a reason. Respect them, then differentiate.

## Design Thinking Framework

### 1. Start with User Intent
- What action does the user want to take? Design the UI to serve that intent first.
- Multiple intents on one page? Layer them. Search → browse → filter → detail.
- Don't jump to visual design before understanding the user flow.

### 2. Leverage Existing Layouts
- Navigation at top, CTAs eye-catching and findable.
- Information flows top-to-bottom, left-to-right.
- Respect user expectations; differentiate with micro-interactions and unique features.
- Good = follows conventions. Genius = follows conventions but feels unique.

### 3. Content Structure
- Decide WHAT content to display based on user interaction patterns.
- Structure displayed content for scanability: location, rating, price before details.
- Handle edge cases: long names (truncate), bright images (add contrast circles), empty states.

### 4. Functional Animations
- Animations should add clarity or functionality, not decoration.
- Navigation consolidation (hamburger menu) serves a purpose when links overflow.
- Progressive disclosure: show what user needs, reveal more as required.
- Load-more > infinite scroll (gives user control, footer accessibility).
- Small button animations: yes. Scroll-jacking: almost never.

### 5. Design Systems
- A design system is a shared language, not a conformity machine.
- Define rules, spacing, typography scales, interaction patterns.
- Mastery means knowing when to bend the rules — intentionally, not by accident.

## Visual Design Principles

### Spacing & Hierarchy
- Intentional spacing creates grouping: 8px subtext gap, 12px eyebrow gap, 32px button gap.
- Proximity, contrast, consistency, and hierarchy are the four pillars.
- Whitespace creates hierarchy; color creates hierarchy too (font size alone isn't enough).
- Use opacity (55% vs 100%) to create visual hierarchy without adding sizes.

### Typography
- Headers: ~7 words. Body: ~14 words. Communicate quickly.
- Dashboard: smaller font sizes, less spacing than landing pages (more content per screen).
- Use color and size to create hierarchy, not just weight.

### Color Theory
- **60-30-10 rule:** 60% dominant neutral, 30% secondary, 10% accent.
- **Less is more:** Don't give every element a different color. Pick 1-2 accents max.
- **Neutral balance:** Backgrounds stay in the background. Use neutral grays for backgrounds, slightly lighter for foreground. Add subtle brand tint only.
- **Brand colors:** Adapt them if they fail WCAG. Darken, or use complementary/analogous colors. Don't be afraid to deviate from brand guidelines for usability.
- **Pure white/black:** Use grays for secondary text, borders, and less important elements. Reserve pure white/black for most important actions.
- **Dark mode:** Not a color inverse. Brighten borders, use light grays for most text, pure white only for key elements, desaturate logos.
- **Semantic colors:** Red for destructive actions, even if not on brand. Red/green for status.
- **Element states:** Hover = lighter/brighter. Active = darker. Disabled = desaturated.

### Layout Patterns
- **Hero sections:** Text-left/image-right (most common), image-fullscreen-under-text, text-top/image-bottom.
- **Feature sections:** Center text for profound statements. Bento grid for feature lists (nothing lost on scroll).
- **Visual treatment:** Bordered images, full-width bleed, image carousel with rotation.
- **Dashboard layout:** 2-column, 2-row grid. Top = important page actions. Main = data. Bottom = charts/metrics.

### Shadows & Depth
- Shadows create layer hierarchy. Subtle shadows for cards, stronger for modals.
- On dark mode: shadows are less visible; use border + background color instead.

### Icons & Buttons
- Icons need no color unless communicating status (active tab, selected state).
- Buttons should have small animations (hover/press states).
- Icon + short title in navigation. Helpful for collapsible sidebars.

## Component Patterns

### Four Dashboard Components
1. **Lists and tables:** Most common. Separation via space, lines/dividers, or color. Tables need search, filter, sort.
2. **Cards:** Charts, toasts, metric displays. Margins well-spaced. Border on dark mode, background color on light mode.
3. **User input:** Forms, modals, settings. Tables-within-cards (like Vercel) for advanced patterns.
4. **Tabs:** Add new pages without cluttering sidebar. Notion settings pattern.

### Navigation Patterns
- **Sidebar:** Logo/profile at top, grouped links, settings/help at bottom, optional notifications.
- **Top bar:** Search, profile management, secondary navigation.
- **Mega menu:** For depth and exploration signals (Level 3+ landing pages).
- **Breadcrumb:** Required when navigating to new pages.

### Modal vs Popover vs New Page
- **Popover:** Simple context, non-blocking (user can click away). Display settings, quick actions.
- **Modal:** Complex context, blocking (must click create/cancel). Directly related to current page. Always show toast confirmation.
- **New page:** Permanent or large context. Requires back button/breadcrumb.

### Micro-Interactions
- Chart hover: show number + bubble with percent. Other bars dim.
- Selection reveals contextual buttons (bulk actions).
- Optimistic UI: delete email instantly, assume success. No awkward loading pauses.
- Chart animations: smooth transitions, not flashy.

## Common Beginner Mistakes

1. **Bad user flow:** Designing screens before understanding the journey. Every screen should have a clear purpose in the flow.
2. **Overusing effects:** 3D graphics, buttery scrolling, massive animations — these don't serve the user. Navigation is not a reason for animation.
3. **Spacing issues:** Inconsistent gutters, cramped cards, no breathing room. Use a spacing scale (4px, 8px, 12px, 16px, 24px, 32px).
4. **Inconsistent components:** Different border radii, font sizes, and colors across similar elements. Build a component library.
5. **Bad icon usage:** Colored icons for everything. Icons should be recognizable symbols; color only for status.
6. **Redundant elements:** Repeating information that's already in the URL, title, or nearby. Trust the user's mental model.
7. **Missing interactive feedback:** No hover states, no disabled states, no loading states, no error states. Every interactive element needs visual feedback.
8. **Bad charts:** Weird chart types nobody understands. Use standard line/bar charts with grid lines, axis labels, and summaries.

## Mobile-Specific Principles

1. **Navigation:** Bottom bar for primary navigation, hamburger for secondary. Thumb-reach zone matters.
2. **Scale:** Touch targets minimum 44x44pt. Font sizes readable at arm's length.
3. **Content:** Prioritize above the fold. Progressive disclosure for secondary content.
4. **One screen, one job:** Don't overload mobile screens. Split complex flows across screens.
5. **Gestures:** Swipe, pinch, long-press. Don't override native gestures.
6. **Dynamism:** Micro-animations on mobile should be subtle (haptic feedback > visual effects).
7. **Empty states:** Always design for empty. Guided empty states > blank screens.

## Landing Page Levels

### Level 1 (≈$500) — Functional but Template-like
- Standard text-left/image-right alternating layout
- Stock images unrelated to product
- Inconsistent corners (sharp images vs rounded buttons)
- Flat navigation, no hierarchy
- Haphazard color application
- No animations beyond basic hover

### Level 2 (≈$2,000) — Knows What It's Doing
- Stacked hero layout (modern)
- Actual product screenshots instead of stock images
- Improved typography hierarchy
- Menu hierarchy with outline CTAs
- Simple load animations
- Logical page flow (not just sections stacked)

### Level 3 (≈$6-10K) — Good Instincts + Real Craft
- Zoomed-in product visuals (curated, not full screenshots)
- Bento grids for features
- Multi-select interactions
- Shorter, punchier copy
- Brand elements (badges, logos, social proof)
- Mega menu for navigation
- Smooth hover effects and fluid transitions
- Good page flow with natural section transitions

### Level 4 (≈$10K+) — Attention to Detail
- Content crafted for the space, not generic templates
- Leading lines through typography and spacing
- Copy focuses on HOW it helps, not WHAT it does
- Color threaded expertly throughout
- Blur effects, smooth mega menus, contextual CTAs on hover
- Immaculate page flow — content encourages scrolling
- No custom illustrations or 3D — just well-crafted UI

## Agent Prompting Patterns

When instructing AI coding agents to build frontends, use these patterns:

### 1. Provide Reference Links
```
"Build a dashboard UI inspired by these references:
- https://dub.co (link tracking SaaS)
- https://linear.app (project management)
- https://vercel.com (analytics dashboard)

Follow their patterns: sidebar navigation, card-based layout, optimistic UI, toast notifications."
```

### 2. Specify Design Constraints
```
"Apply the 60-30-10 color rule. 60% neutral background, 30% secondary, 10% accent.
Use 8px spacing scale. Max 2 font sizes per section.
All interactive elements must have hover, active, and disabled states."
```

### 3. Progressive Refinement
```
"First pass: functional layout with proper spacing and hierarchy.
Second pass: add micro-interactions (chart hover, optimistic updates).
Third pass: refine color palette and ensure WCAG contrast."
```

### 4. Component Library Approach
```
"Build a component library first: buttons, cards, tables, inputs, modals, toasts.
Then compose pages from these components. Ensure consistency across all instances."
```

## Sources

- [The stupid simple way to learn UI/UX design in exactly 10 minutes](https://www.youtube.com/watch?v=9WVt1CelBfg) — Training eye, building skill, 28-day roadmap
- [Every UI/UX Concept Explained in Under 10 Minutes](https://www.youtube.com/watch?v=EcbgbKtOELY) — Affordances, hierarchy, grids, typography, color, dark mode, shadows, icons, feedback, micro-interactions
- [How to think like a GENIUS UI/UX designer](https://www.youtube.com/watch?v=HE4rLEQpiXY) — User intent, existing layouts, content structure, functional animations, design systems
- [7 UI/UX mistakes that SCREAM you're a beginner](https://www.youtube.com/watch?v=AH_ugxmLeUM) — User flow, effects, spacing, components, icons, redundancy, feedback, charts
- [Everything you need to know about Mobile App UI's in 8 minutes](https://www.youtube.com/watch?v=Gfsd8NNuD9g) — Navigation, scale, content, one-screen-one-job, gestures, dynamism, empty states
- [EVERYTHING you need to know to build a Dashboard UI in 8 minutes](https://www.youtube.com/watch?v=B7k5rOgmOGY) — Sidebars, layout, modals/popovers, 4 components, micro-interactions, optimistic UI
- [The 4 Levels of Landing Page UI/UX Design](https://www.youtube.com/watch?v=eMMiLeo_UGI) — Level 1-4 progression with specific visual and interaction markers
- [The 7 Color Mistakes that RUIN your UI Designs](https://www.youtube.com/watch?v=EOcY3hPMQkk) — 60-30-10 rule, neutral balance, brand color adaptation, dark mode, semantic colors, element states
- [The 3 dashboard UI flaws that give away you've NEVER built one](https://www.youtube.com/watch?v=Ksx9C2-3yMo) — Data-driven UI, progressive disclosure, invisible UI details
- [5 SaaS UI/UX mistakes that SCREAM you Vibe Code](https://www.youtube.com/watch?v=PDcQJOPby1k) — AI-generated SaaS design pitfalls