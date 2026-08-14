---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: personalized web production
form_factor:
  - local site generator
  - preview deployment pipeline
deployment: local builds with optional Cloudflare Pages previews
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#12. Microsite Factory]]"
status: concept
tags:
  - microsites
  - personalization
  - qa
---

# Microsite Factory

> A schema-driven factory that turns approved account research into consistent, tested static microsites and preview URLs—without fabricated familiarity or twenty divergent codebases.

## Product Outcome

Help an agency or founder create credible account-specific landing pages quickly. Each page explains the target’s observed context, a relevant problem hypothesis, a tailored proof point, and a clear next step. Research claims retain source links; design, accessibility, links, and mobile layout pass automated gates before deployment.

## User and Core Workflow

The operator imports a target list and approved source notes. A researcher produces cited facts; a strategist selects one angle from a bounded taxonomy. The system fills a typed content schema, renders one shared template, runs lint/link/a11y/screenshot checks, and presents diffs. The operator approves preview deployment and later supplies outreach manually.

## Demo/Personal V0

Create three fictional target accounts with different languages and industries. Generate static pages from JSON, run QA, show screenshot diffs, and deploy previews under one Cloudflare Pages project or serve locally. Include one intentionally unsupported claim that the gate blocks.

## Build Boundary

No personal-data enrichment, scraping behind login, impersonation, auto-emailing, fake customer logos, invented metrics, or production domain changes. Pages are private/unlisted previews until approved. One template and component set define the design system.

## Existing Products, Building Blocks, and Shortcuts

- [Astro](https://docs.astro.build/) generates fast static pages from content collections and is simpler than a per-account app.
- [Cloudflare Pages Direct Upload](https://developers.cloudflare.com/pages/get-started/direct-upload/) deploys a prebuilt folder with `npx wrangler pages deploy <dir>` and supports preview branches.
- [Playwright visual comparisons](https://playwright.dev/docs/test-snapshots) catch layout regressions across page variants.
- [axe-core](https://github.com/dequelabs/axe-core) and [Lighthouse](https://github.com/GoogleChrome/lighthouse) provide accessibility/performance gates instead of subjective QA alone.

## Recommended Free-First Stack

Use TypeScript, Astro, Zod-validated JSON/YAML content, Tailwind or plain CSS tokens, Playwright, axe-core, and Lighthouse. A Python research helper with Ollama can draft cited content, but the renderer accepts only validated fields. Use local `npm run build` first; Wrangler previews are optional.

## Architecture/Data Model

Model `Account`, `Source`, `Fact`, `Angle`, `ContentVersion`, `TemplateVersion`, `Asset`, `Build`, `QACheck`, `Approval`, and `Deployment`. Facts carry quote/source/retrieved-at fields. A deployment references immutable content/template/build hashes so rollback is straightforward.

## Build Slices

1. Typed account/content schema and one template.
2. Cited research/fact review.
3. Strategy angle selector and copy draft.
4. Static build for three fixtures.
5. Link, accessibility, Lighthouse, and screenshot gates.
6. Approval-gated preview deployment and rollback.

## Drawbacks, Concerns, and Failure Modes

Personalization often becomes uncanny or wrong. Twenty pages multiply review load even with shared code. Third-party logos/assets create rights issues. Preview URLs can leak sales strategy. Translation may sound unnatural. Visual tests become noisy with fonts and dynamic content.

## Clever Hacks and Simpler Alternative

Generate a single dynamic page with `?account=` selecting validated content, then export static pages only for approved targets. Personalize the first screen and proof block; keep the rest shared. A short annotated audit PDF may outperform a microsite for low-intent accounts.

## Success Measures

- Every non-generic factual sentence links to an approved source.
- All fixture pages pass schema, link, accessibility, and mobile screenshot gates.
- One template change rebuilds every page consistently.
- Unsupported claims block deployment.
- A page can be regenerated and rolled back from versioned inputs.

## Product Path

Start as a personal outbound asset generator. A future agency product adds client workspaces, custom domains, analytics, licensed enrichment, and approval roles; outreach automation remains a separate consent/compliance system.

## Related

- [[Auto-GTM Engine]]
- [[seo-agency-crew|SEO Agency Crew]]
- [[sales-development-agency|Sales Development Agency]]
