---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: open-source operations
form_factor:
  - maintainer dashboard
  - GitHub App assistant
deployment: local-first with optional GitHub App
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#11. Maintainer Desk]]"
status: concept
tags:
  - github
  - triage
  - open-source
---

# Maintainer Desk

> A supervised operations desk for one repository that turns issue noise into reproducible evidence, review drafts, and safe patches without impersonating maintainers.

## Product Outcome

Help a maintainer spend time on judgment rather than sorting. New issues receive duplicate candidates, missing-information checks, reproduction status, component labels, and a draft response. Pull requests get a first-pass risk/test/docs review. Nothing posts or changes labels before the maintainer approves.

## User and Core Workflow

The user selects a repo and contribution policy. The desk ingests issues/PRs read-only, retrieves code and docs, and builds proposal cards. Reproduction jobs run in disposable containers. The maintainer approves a label/reply or asks for a patch; changes land in a branch/worktree, tests run, and the result is presented as a diff with provenance.

## Demo/Personal V0

Use a small fixture repository with five issues, one duplicate, one incomplete bug, one reproducible regression, and two PRs. Produce triage cards, reproduce the bug in a sandbox, draft one docs patch, and stop before any GitHub write.

## Build Boundary

No auto-commenting, closing, merging, release publishing, secret access, or untrusted code execution on the host. Community replies identify themselves as drafts/automation when eventually posted. Maintainer policies override general model preferences.

## Existing Products, Building Blocks, and Shortcuts

- GitHub documents [App endpoint permissions](https://docs.github.com/en/rest/authentication/permissions-required-for-github-apps); request read-only issues/contents first and add write scopes only for explicit features.
- [CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners) provides an existing ownership/routing map.
- [`gh issue` and `gh pr`](https://cli.github.com/manual/) offer scriptable read/write commands and make an excellent local prototype before building a GitHub App.
- [Dev Containers](https://containers.dev/) or Docker isolates reproduction tooling; still disable ambient credentials and constrain network/resources.

## Recommended Free-First Stack

Use Python/FastAPI, `gh` CLI, SQLite, Git worktrees, Docker, and a SvelteKit dashboard. Ollama summarizes and drafts; deterministic checks parse templates, labels, changed files, tests, and CODEOWNERS. Store raw GitHub event IDs and commit SHAs for reproducibility.

## Architecture/Data Model

Entities: `Repository`, `PolicyVersion`, `IssueSnapshot`, `PullRequestSnapshot`, `DuplicateCandidate`, `TriageProposal`, `ReproductionRun`, `Patch`, `CheckRun`, `DraftReply`, `Approval`, and `GitHubMutation`. All analysis keys to immutable issue/PR revision and repository SHA.

## Build Slices

1. Read-only `gh` ingestion and fixture snapshots.
2. Template completeness and duplicate suggestions.
3. Label/owner routing with policy explanations.
4. Sandboxed reproduction run and evidence capture.
5. PR review/doc patch proposals.
6. Approval-gated GitHub App writes.

## Drawbacks, Concerns, and Failure Modes

Issue descriptions can prompt-inject agents. Reproduction installs may execute malware. Duplicate detection can silence valid reports. Generated comments create community spam and flatten maintainer voice. Repo state moves while analysis runs, making stale recommendations dangerous.

## Clever Hacks and Simpler Alternative

Generate one private daily triage Markdown note from `gh issue list`; let the maintainer copy decisions manually. Focus first on missing-information and duplicate candidates, which provide value without executing code. Require an exact base SHA before proposing a patch.

## Success Measures

- High acceptance rate for suggested labels/duplicates on the fixture.
- Reproduction reports include command, environment, logs, and commit SHA.
- Zero GitHub mutations without an approval record.
- Maintainer edits to replies decline without increasing negative feedback.
- Stale analyses are invalidated when the issue/PR or base SHA changes.

## Product Path

Start as a personal maintainer cockpit, then an installable GitHub App for small projects. Hosted multi-repo operations require hardened sandboxes, tenant isolation, abuse prevention, transparent bot identity, and billing based on useful accepted work—not comment volume.

## Related

- [[pr-factory|PR Factory]]
- [[ai-implementation-agency|AI Implementation Agency]]
- [[on-call-autopilot|On-Call Autopilot]]
