---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: developer operations
form_factor:
  - incident investigation console
  - patch verification pipeline
deployment: local-first against replay fixtures
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#13. On-Call Autopilot]]"
status: concept
tags:
  - incident-response
  - observability
  - devops
---

# On-Call Autopilot

> A supervised incident investigator that builds an evidence-backed timeline, tests hypotheses in a disposable environment, and proposes a verified patch without touching production.

## Product Outcome

Shorten diagnosis time while improving incident documentation. The system should answer: what changed, what failed, what user impact is observed, which evidence supports each hypothesis, what reversible mitigation exists, and which verification proves recovery. “Autopilot” ends at an approval gate.

## User and Core Workflow

The operator selects an incident bundle containing deploy metadata, logs, traces, metrics, config, and repo SHA. Collectors normalize timestamps and construct a timeline. The investigator ranks hypotheses with evidence and missing checks. A selected hypothesis produces a patch in an isolated worktree, runs tests and a replay/health probe, and creates a diff plus runbook update for human approval.

## Demo/Personal V0

Use a synthetic service whose deploy breaks because of a config/env mismatch. Replay frozen logs and traces, identify the first bad deploy, patch a fixture, execute tests locally, verify an HTTP request, and generate a mock PR/incident report. No cloud credentials.

## Build Boundary

No production shell, restart, rollback, deploy, secret retrieval, alert acknowledgement, or PR push. Logs and issue text are untrusted. The model never executes arbitrary commands; tools are allowlisted with time/resource limits and scrubbed environment variables.

## Existing Products, Building Blocks, and Shortcuts

- [OpenTelemetry](https://opentelemetry.io/docs/) supplies a common trace/metric/log model and trace IDs for correlation.
- [Grafana Loki/LogQL](https://grafana.com/docs/loki/latest/query/) handles log queries; [`logcli --stdin`](https://grafana.com/docs/loki/latest/query/logcli/getting-started/) can test against local files without deploying Loki.
- [Sentry](https://docs.sentry.io/product/issues/) is a product/API reference for issue grouping, stack traces, releases, and suspect commits.
- Git [worktrees](https://git-scm.com/docs/git-worktree.html) isolate patches, while Docker/Dev Containers isolate tests from the host.

## Recommended Free-First Stack

Use Python/FastAPI, SQLite/DuckDB for events, OpenTelemetry JSON fixtures, `logcli`, Git worktrees, Docker, and a SvelteKit timeline UI. Ollama proposes queries/hypotheses but must attach event IDs. A typed tool runner exposes only read logs, search code, edit worktree, test, and HTTP-probe operations.

## Architecture/Data Model

Entities: `Incident`, `Service`, `Deploy`, `Event`, `Trace`, `LogExcerpt`, `MetricObservation`, `Hypothesis`, `EvidenceLink`, `CommandRun`, `Patch`, `Verification`, `Approval`, and `Postmortem`. Record source clocks and normalization offsets; hypotheses are append-only scores, not overwritten narratives.

## Build Slices

1. Synthetic incident and frozen telemetry bundle.
2. Timeline normalization and deploy correlation.
3. Evidence-linked hypothesis workspace.
4. Sandboxed command/query runner.
5. Patch worktree, tests, and health verification.
6. Mock PR and postmortem generator.

## Drawbacks, Concerns, and Failure Modes

Incomplete telemetry creates confident but wrong stories. Clock skew misorders events. Logs contain secrets and customer data. Running repository tests can execute malicious scripts. A passing local probe may not represent production. Automation can obscure ownership and discourage observability improvements.

## Clever Hacks and Simpler Alternative

Build an “incident packet compiler” first: collect the last deploy, top error changes, relevant traces, and runbook links into Markdown. Require the model to propose the next cheapest discriminating test rather than a root cause. Voice narration is presentation polish, not core value.

## Success Measures

- The fixture root cause and first bad deploy are identified from cited evidence.
- Every executed command is allowlisted, logged, bounded, and sandboxed.
- Patch verification is repeatable from the incident bundle.
- No production-capable credential exists in the runtime.
- Generated postmortem separates facts, hypotheses, and decisions.

## Product Path

Begin as a local replay and postmortem tool. Production assistance later needs read-only observability connectors, strict tenant/secrets isolation, change-management integration, incident-command roles, and gradual action permissions with rollback.

## Related

- [[ai-implementation-agency|AI Implementation Agency]]
- [[pr-factory|PR Factory]]
- [[maintainer-desk|Maintainer Desk]]
