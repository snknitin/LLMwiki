---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Creator Growth and Local Video Pipelines#5. Auto-GTM Engine]]"
status: concept
difficulty: hard
priority: p0
category: go-to-market automation
form_factor:
  - reusable release workflow
  - local dashboard
  - scheduled automation
deployment: desktop and self-hosted automation
source_ideas:
  - automatically market every tool service plugin skill and site
  - generate feature posts tutorials videos and waitlist content
  - find people and manage waitlists or email lists
tags:
  - gtm
  - launches
  - marketing
  - automation
  - releases
---

# Auto-GTM Engine

> A reusable release-to-market pipeline that turns verified product changes into a launch pack, tutorials, posts, demos, email material, waitlist updates, and a sustained reviewable content queue for every artifact you build.

## Product Outcome

Every project contains a versioned GTM manifest beside its code/spec. When a release/tag or explicit command occurs, the engine gathers product truth, changelog, screenshots, proof clips, audience, objections, and CTA; derives channel-specific assets; checks every claim against proof; presents one approval queue; exports/publishes through optional adapters; and joins outcomes back to the release.

“Automatic” means context collection, derivation, QA, and scheduling are automated. It does not mean inventing positioning from a Git diff or posting daily paraphrases without proof.

## Personal V0

1. Add `go-to-market.yaml` to one shipped tool.
2. Record audiences, jobs, problems, promises with proof IDs, features as user outcomes, objections, CTA, channels, and approved evergreen topics.
3. Trigger on an explicit local version/tag.
4. Generate: release notes, tutorial outline, three posts, one email, one short-video script, FAQ update, and landing-page patch suggestion.
5. Block unsupported capability claims and repeated topics.
6. Review once and export to channel folders.
7. Record published URLs and a small set of outcome events.

## Build Boundary

**MVP:** GTM schema/validator, release collector, source/proof library, derivation graph, claim checker, approval queue, channel exports, and outcome record.

**Later:** GitHub webhooks, direct publishers, listmonk, waitlist/CRM adapters, video renderers, multi-project calendar, and analytics.

The engine does not decide demand, author ad experiments, manage DMs, or implement media models. It calls the corresponding standalone projects.

## Existing Products, Building Blocks, and Shortcuts

- GitHub’s [Releases API](https://docs.github.com/en/rest/releases) provides explicit release triggers, generated notes, and assets.
- [n8n](https://github.com/n8n-io/n8n) supplies visible self-hosted workflows, retries, and approval steps; a Python/TypeScript worker + Task Scheduler is the simpler alternative.
- [listmonk](https://github.com/knadh/listmonk) manages newsletters/lists rather than rebuilding email infrastructure.
- Release Drafter, Changesets, semantic-release, Buffer, Hypefury, Resend, and product-launch tools are references for changelogs, scheduling, and distribution.
- [[Personal Voice Ghostwriter and DM Desk]], [[Meta Ad Creative Studio]], and [[Longform-to-Shorts Studio]] are optional specialist adapters.

## Recommended Free-First Stack

- JSON Schema/Pydantic/Zod GTM manifests in each project.
- Python/TypeScript collector and validator with SQLite event/asset store.
- n8n for multi-step approvals and supported connectors, or a code-only job queue.
- Local model for derivation, backed by proof/source IDs and template versions.
- Markdown/HTML/channel-folder export first.
- GitHub API, listmonk, and official publisher adapters one at a time.

## Content Derivation Graph

One approved release fact + proof can become a changelog entry, documentation update, demo script, product video, X post, LinkedIn explanation, email paragraph, landing-page change, and FAQ answer. Every derived asset keeps `artifact_id`, `release_id`, source fact IDs, proof IDs, audience, channel, status, and published URL.

States: `generated -> claim-checked -> asset-checked -> approved -> scheduled/exported -> published-confirmed -> measured`.

## Build Slices

1. GTM manifest and validator for one project.
2. Release/changelog/screenshot collector.
3. Derivation templates and claim-proof checker.
4. Approval queue and export bundles.
5. Topic cooldown and evergreen inventory.
6. Email/waitlist adapter and published URL verification.
7. Specialist media/voice/ad adapters.
8. Multi-project GTM calendar and outcome learning.

## Drawbacks, Concerns, and Failure Modes

- Daily posting becomes repetitive. Use a proof inventory and topic cooldown.
- Code changes may have no user outcome. Require `user_outcome` before marketing.
- One master paragraph truncated across channels performs poorly. Transform by channel/job.
- Scheduled does not mean published. Verify external URLs/responses.
- Automatic screenshots/demos can expose unfinished states. Asset review is separate from claim review.
- More content cannot fix weak demand. Feed learning back to [[Demand Generation Workbench]].

## Clever Hacks and Simpler Alternative

- Start with one generated Markdown launch pack per release.
- Require developers/agents to add a user-facing change fragment with every meaningful PR.
- Keep ten evergreen proof-backed topics per project and rotate only after actual use evidence.
- Make all renderers/publishers optional; the engine must succeed as files-only.
- Generate “how to use this new feature” from a captured golden-path script, not only the diff.

## Success Measures

- Every public release produces a complete reviewed launch pack.
- Unsupported claims are blocked before export.
- Time from release-ready to channel-ready declines.
- Assets are not repeated inside their cooldown window.
- Published outputs can be traced back to release facts and proof.
- Outcome learning changes future GTM priorities.

## Product Path

Personal release workflow -> shared infrastructure for all vault projects -> open-source GTM manifest standard -> hosted product. Run [[Scope Expansion Checklist]] before customer/workspace use, but preserve the manifest and approval state machine.

## Related

- [[Creator Content Engine]]
- [[Personal Voice Ghostwriter and DM Desk]]
- [[Meta Ad Creative Studio]]
- [[Longform-to-Shorts Studio]]
- [[Conversion List Builder]]
- [[Demand Generation Workbench]]
- [[Project Ideas Index]]

