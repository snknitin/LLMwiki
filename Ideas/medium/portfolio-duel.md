---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: developer career tooling
form_factor:
  - local comparison dashboard
  - shareable challenge card
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#21. Portfolio Duel]]"
status: concept
---
# Portfolio Duel

> Compare two opt-in portfolios through explicit evidence and rubric weights, then give each person a useful next challenge.

## Product Outcome

Make portfolio review engaging without reducing people to follower counts. The result shows category-by-category evidence, missing data, adjustable weights, a defensible winner or tie, and tailored improvement tasks.

## User and Core Workflow

Enter two GitHub usernames and/or portfolio URLs with permission, choose a role target, and verify identity mapping. The system collects public evidence, runs page checks, normalizes metrics, and scores a visible rubric. Users inspect citations, correct mismatches, adjust weights, and export a duel card plus challenge plan.

## Demo/Personal V0

Compare two of the user’s own or consenting test profiles. Score clarity, shipped work, documentation, accessibility, freshness, and project evidence. Support ties and “not enough data”; avoid popularity metrics.

## Build Boundary

Include opt-in sources, normalization, rubric, evidence, corrections, comparison, and challenge generation. Exclude hiring rankings, private repository access, identity inference, popularity contests, public leaderboards, and unverified scraping.

## Existing Products, Building Blocks, and Shortcuts

- [GitHub REST API](https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api) supplies repository and profile evidence.
- [GitHub rate-limit documentation](https://docs.github.com/en/rest/rate-limit/rate-limit) guides caching and request budgets.
- [Lighthouse](https://developer.chrome.com/docs/lighthouse/overview) measures portfolio page quality.
- [Playwright](https://playwright.dev/docs/intro) captures the rendered evidence and responsive states.

## Recommended Free-First Stack with Rationale

Use TypeScript, Next.js, SQLite/Drizzle, Octokit, Playwright, Lighthouse, and Satori for result cards. Deterministic collectors and scorers own the comparison; Ollama only explains evidence and drafts challenges.

## Architecture/Data Model

Model `participants`, `source_profiles`, `snapshots`, `projects`, `audit_results`, `rubric_versions`, `category_scores`, `evidence_items`, `corrections`, `duels`, and `challenges`. Snapshot IDs make every duel reproducible.

## Build Slices

1. Manual evidence cards and rubric comparison.
2. GitHub collector, cache, and identity confirmation.
3. Portfolio page audit, evidence review, ties/missing states.
4. Challenge generator and shareable result card.

## Drawbacks/Concerns/Failure Modes

Quantity can masquerade as quality; inactive public repos may hide excellent private work; different career goals are not comparable; and scores invite harassment. Use role-specific rubrics, prioritize project evidence, support opt-out/deletion, and keep default sharing private.

## Clever Hacks and Simpler Alternative

Run a self-duel: current portfolio versus a saved snapshot from 90 days ago. This removes interpersonal ranking and tests whether the feedback actually drives improvement.

## Success Measures

Track evidence correctness, correction rate, tie/unknown handling, challenge completion, repeat self-duels, score movement after changes, and participant fairness ratings.

## Product Path

Personal improvement game → opt-in peer tool → portfolio coaching product. Before public profiles, shared accounts, hiring use, or payments, run [[Scope Expansion Checklist]] for consent, fairness, provider terms, moderation, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#21. Portfolio Duel]]
- [[Scope Expansion Checklist]]
- [[Flex Card Forge]]

