---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: software engineering agents
form_factor:
  - local agent workbench
  - GitHub PR pipeline
deployment: isolated local runners with optional GitHub App
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#15. PR Factory]]"
status: concept
tags:
  - coding-agents
  - git
  - pull-requests
---

# PR Factory

> A test-gated coding tournament that explores multiple isolated fixes, selects by evidence, and presents one human-reviewed patch with the full decision trail.

## Product Outcome

Given a well-scoped issue and repository snapshot, produce a correct, minimal, reviewable patch faster than one serial agent. The factory makes planning, candidate attempts, commands, diffs, test results, security scans, and judge rationale inspectable. It optimizes accepted fixes, not generated lines.

## User and Core Workflow

The user imports an issue and pins a base SHA. A planner creates acceptance tests and constraints for approval. Two or three agents receive isolated worktrees and the same fixture/tool budget. QA runs original plus new tests and static checks; a judge compares only evidence and diffs. The user reviews the winning patch and may create a branch/PR through an explicit GitHub action.

## Demo/Personal V0

Use a tiny fixture repo with one failing issue and hidden regression test. Run two worktrees with different strategies, show one rejected candidate, and output the winning local diff, commands, tests, and rationale. Stop before push.

## Build Boundary

No arbitrary repository execution on the host, force pushes, merges, branch deletion, workflow-file edits, or PR creation without approval. Workers have no ambient GitHub/cloud credentials and limited network/CPU/time. The issue and repository are untrusted inputs.

## Existing Products, Building Blocks, and Shortcuts

- Git’s [worktree documentation](https://git-scm.com/docs/git-worktree.html) gives native isolated checkouts; `git worktree add -d <path> <sha>` creates a throwaway candidate.
- GitHub’s [App permission reference](https://docs.github.com/en/rest/authentication/permissions-required-for-github-apps) supports least-privilege PR/check integration.
- The [Checks API](https://docs.github.com/en/rest/checks) can attach detailed annotations after the local process is trusted.
- [Dev Containers](https://containers.dev/) and Docker provide disposable execution; combine them with lockfile-aware install policies and no secrets.

## Recommended Free-First Stack

Use Python orchestration, Git CLI/worktrees, Docker, SQLite for run metadata, and a SvelteKit diff/decision UI. Use local coding models through a provider adapter; the selection contract is deterministic tests, lint/typecheck/security scan, diff size, and rubric evidence. Do not require a vector database.

## Architecture/Data Model

Entities: `RepositorySnapshot`, `IssueSnapshot`, `Plan`, `AcceptanceCriterion`, `Candidate`, `Worktree`, `ToolCall`, `Patch`, `TestRun`, `Finding`, `JudgeDecision`, `Approval`, and `PullRequestResult`. All runs bind to base SHA, container image digest, tool/model version, and budget.

## Build Slices

1. Fixture repo, issue parser, and base-SHA lock.
2. Planner plus human-approved acceptance criteria.
3. Two isolated worktree/container runners.
4. Deterministic QA and normalized result schema.
5. Judge comparison and diff review.
6. Approval-gated branch/PR creation.

## Drawbacks, Concerns, and Failure Modes

Parallel agents multiply tokens, compute, and vulnerable dependency installs. Tests can be incomplete or gamed. Candidates may make broad rewrites that pass. Repository licences and contributor policies matter later. Worktrees share Git object storage, so path/sandbox design must still be careful.

## Clever Hacks and Simpler Alternative

Run one agent plus one critic before true parallelism. Use `git diff --stat`, changed-file allowlists, mutation tests, and a “simplest patch wins ties” rule. Keep a golden issue suite so orchestration changes can be evaluated rather than demoed once.

## Success Measures

- Winning patch passes original, new, and hidden tests.
- Every command/diff is attributable to one candidate and base SHA.
- Sandbox has no credential or host-write escape.
- Judge selection is reproducible from stored evidence.
- Human review accepts the patch with minimal edits.

## Product Path

Begin as a local coding-agent benchmark and patch assistant. Hosted PR automation needs hardened ephemeral sandboxes, repository policies, spend limits, GitHub App isolation, maintainer approval, and transparent bot attribution.

## Related

- [[Maintainer Desk]]
- [[On-Call Autopilot]]
- [[Security Review Agency]]
