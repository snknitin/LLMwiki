---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: quantified identity
form_factor:
  - local web app
  - share-card generator
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#5. Flex Card Forge]]"
status: concept
---
# Flex Card Forge

> Turn opt-in GitHub, fitness, and game statistics into a beautiful collectible card whose claims and rarity can be inspected.

## Product Outcome

Create a high-quality SVG/PNG card with verified metrics, source dates, and an honest cohort-based rarity calculation. Users should want to share it because it looks good and because the underlying accomplishments are real.

## User and Core Workflow

The owner connects or imports one profile, selects approved metrics, chooses a theme, and reviews normalized facts. A rarity engine compares each metric with a defined snapshot cohort, explains sample size and percentile, then renders a card and a verification page.

## Demo/Personal V0

Support one GitHub username plus pasted Strava and Chess.com exports. Render three card themes, a backside with evidence links, and an “insufficient data” state. Use a fixed 100-profile GitHub cohort rather than claiming global rank.

## Build Boundary

Include opt-in adapters, normalized metrics, cohort snapshots, theme templates, export, and provenance. Exclude scraping private profiles, universal identity scoring, NFT/minting, automated social posting, and fabricated percentiles.

## Existing Products, Building Blocks, and Shortcuts

- [GitHub REST API](https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api) supplies repository and activity data.
- [Strava API](https://developers.strava.com/docs/reference/) provides permissioned athlete/activity data.
- [Chess.com Published Data API](https://www.chess.com/news/view/published-data-api) exposes public player statistics.
- [Satori](https://github.com/vercel/satori) renders deterministic HTML/CSS-like layouts to SVG.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite/Drizzle, scheduled adapter jobs, D3 quantiles, Satori, and Sharp. TypeScript shares schemas between ingestion and rendering; SQLite retains cohort snapshots; SVG-first output stays crisp and templateable.

## Architecture/Data Model

Store `profiles`, `connections`, `metric_definitions`, `observations`, `cohorts`, `cohort_members`, `percentiles`, `card_templates`, and `renders`. Each printed stat carries provider, source URL, retrieval timestamp, unit, and cohort version.

## Build Slices

1. Manual metric editor and deterministic card renderer.
2. GitHub adapter, cache, and provenance page.
3. Cohort snapshots and transparent percentile calculations.
4. Strava/Chess.com adapters and theme gallery.

## Drawbacks/Concerns/Failure Modes

API limits, incomparable definitions, small cohorts, deleted profiles, and selection bias can make rarity misleading. Cache responsibly, version metric formulas, show denominators, never substitute missing values, and allow the owner to hide any statistic.

## Clever Hacks and Simpler Alternative

Start with a signed `stats.json` file and a card template CLI. The user can supply trusted data manually; the hard design question—whether the object feels collectible—can be tested before any OAuth work.

## Success Measures

Track render completion, share/export rate, evidence-page opens, user corrections, percentage of stats with current provenance, and zero unsupported rarity claims.

## Product Path

Personal flex card → open-source profile-card generator → creator/team collectible platform. Before public cohorts, account connections, or monetized templates, run [[Scope Expansion Checklist]] for provider terms, rights, consent, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#5. Flex Card Forge]]
- [[Scope Expansion Checklist]]
- [[Meta Ad Creative Studio]]
