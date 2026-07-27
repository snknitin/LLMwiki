---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: application security agents
form_factor:
  - local security workbench
  - repository report generator
deployment: isolated local container with optional CI adapter
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#18. Security Review Agency]]"
status: concept
tags:
  - security
  - code-review
  - supply-chain
---

# Security Review Agency

> A read-only repository review crew that combines deterministic scanners with evidence-grounded reasoning to produce a prioritized, reproducible security packet.

## Product Outcome

Turn a repository snapshot, architecture notes, and deployment assumptions into a compact threat model, verified findings, missing-control checklist, and remediation plan. The product should reduce triage time without pretending that an LLM is a penetration test or that scanner output is automatically exploitable.

## User and Core Workflow

1. Select a repository snapshot and declare data sensitivity, internet exposure, and trust boundaries.
2. Inventory languages, manifests, secrets patterns, services, and authentication paths.
3. Run secret, dependency, container, and static-analysis tools in an isolated read-only workspace.
4. Normalize results, link each finding to tool output and exact lines, and merge duplicates.
5. Use an agent to draft abuse cases and missing controls from repository evidence.
6. Human-review severity, reachability, false positives, and proposed fixes.
7. Export Markdown, SARIF, and a remediation backlog.

## Demo/Personal V0

Analyze one local test repository with known seeded issues. Run four scanners, create a simple data-flow diagram from user-supplied architecture notes, and produce a five-finding report with commands that reproduce each result. No exploit execution, network probing, or patching.

## Build Boundary

- In scope: repositories the user owns or is authorized to assess, read-only scanning, threat-model prompts, deduplication, and reporting.
- Out of scope: scanning third-party infrastructure, exploit generation, credential use, production probing, or claiming certification.
- Run untrusted repository code only in a disposable container with network disabled and strict resource limits.
- Redact probable secrets from logs and never send source to a remote model without explicit opt-in.

## Existing Products, Building Blocks, and Shortcuts

- [Gitleaks](https://github.com/gitleaks/gitleaks) supplies proven secret detection and machine-readable findings.
- [OSV-Scanner](https://google.github.io/osv-scanner/usage/) checks supported lockfiles and SBOMs against the Open Source Vulnerabilities database.
- [Semgrep](https://semgrep.dev/docs/getting-started/) provides configurable static-analysis rules and SARIF/JSON-friendly output.
- [Trivy](https://trivy.dev/latest/docs/) covers vulnerabilities, misconfigurations, secrets, and container artifacts, avoiding several custom scanner implementations.
- [GitHub CodeQL](https://docs.github.com/en/code-security/concepts/code-scanning/codeql/codeql-code-scanning) is a future hosted/CI adapter for deeper query-based analysis.

## Recommended Free-First Stack

- Python orchestrator with subprocess argument arrays, Pydantic schemas, and SQLite.
- Rootless Docker or Podman for a read-only, network-off analysis sandbox.
- Gitleaks, OSV-Scanner, Semgrep, and Trivy as authoritative detector stages.
- Tree-sitter for lightweight structural indexing; Mermaid for user-reviewable data-flow diagrams.
- Local LLM through Ollama for classification and threat-model drafting, receiving snippets rather than the whole repository where possible.

Deterministic tools find evidence; the model explains, connects, and prioritizes it. Keeping those roles separate is the main reliability feature.

## Architecture/Data Model

`assessment` references an immutable `repo_snapshot`, `asset`, `trust_boundary`, `scanner_run`, `raw_finding`, `normalized_finding`, `evidence`, `triage_decision`, and `remediation`. Finding fingerprints combine scanner, rule, normalized path, and location. Store tool version, command, exit code, config hash, and timestamps so a reviewer can reproduce results.

## Build Slices

1. Safe snapshot importer, manifest inventory, and reproducible run record.
2. Four scanner adapters plus a common normalized finding schema.
3. Deduplication, source-code evidence viewer, and human triage controls.
4. Lightweight threat model and missing-control analysis constrained to evidence.
5. Markdown/SARIF export, baseline comparison, and optional CI comment adapter.

## Drawbacks, Concerns, and Failure Modes

- Static tools produce false positives and miss runtime, design, and business-logic flaws.
- Running repository hooks or builds can execute malicious code.
- Dependency findings may be irrelevant when vulnerable paths are unreachable.
- LLM severity estimates can sound confident without exploitability evidence.
- Reports can expose secrets or security weaknesses if stored or shared casually.

## Clever Hacks and Simpler Alternative

- Do not run package installation for V0; scan committed manifests and source only.
- Preserve raw scanner output and ask the model to cite finding IDs, never freehand discoveries.
- Baseline known findings so subsequent reviews emphasize changes.
- Seed a tiny vulnerable fixture repository to regression-test the entire report pipeline.
- Simplest alternative: one PowerShell/Python command that runs the four scanners and renders a prioritized Markdown template.

## Success Measures

- Every reported issue links to reproducible tool output or explicit repository evidence.
- The seeded fixture’s known issues are consistently detected.
- Duplicate normalized findings stay below 10% after triage.
- Full V0 completes offline and cannot make outbound network calls.
- Reviewers can accept, reject, or downgrade every finding with a recorded reason.

## Product Path

Start as a local pre-commit security packet for personal projects. Later add policy packs, team baselines, CI annotations, SBOM ingestion, and approved cloud-model escalation. A commercial version must clarify scanner licenses, data handling, retention, and that it assists—not replaces—professional review.

## Related

- [[PR Factory]]
- [[Maintainer Desk]]
- [[On-Call Autopilot]]
