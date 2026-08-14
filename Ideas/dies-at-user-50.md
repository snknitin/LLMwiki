---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: developer tooling
form_factor:
  - local dashboard
  - command-line harness
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#3. Dies at User 50]]"
status: concept
---
# Dies at User 50

> An authorized synthetic-user gauntlet that finds the concurrency or journey where a web product first violates explicit reliability thresholds.

## Product Outcome

Replace vague “can it handle traffic?” claims with a reproducible run, failure curve, browser evidence, and playful death certificate. The valuable artifact is the bottleneck diagnosis and next experiment, not a leaderboard.

## User and Core Workflow

The builder proves ownership of localhost or an allowlisted host, selects browser journeys, defines latency/error thresholds and a maximum virtual-user count, then starts a gradual ramp. The system streams metrics, stops on safety limits, captures logs/screenshots, and creates a report showing the first failing stage.

## Demo/Personal V0

Test one local sample app at 1, 5, 10, 25, and 50 virtual users. Combine an HTTP checkout scenario with one Playwright login journey. Render a badge only when the run contains sufficient samples and a verified threshold breach.

## Build Boundary

Include local/verified targets, scripted journeys, bounded ramping, thresholds, kill switch, evidence, and report export. Exclude internet-wide testing, CAPTCHA bypass, credential attacks, stealth traffic, and unbounded swarms.

## Existing Products, Building Blocks, and Shortcuts

- [k6](https://grafana.com/docs/k6/latest/) replaces a custom load engine with virtual users, scenarios, and metrics.
- [k6 thresholds](https://grafana.com/docs/k6/latest/using-k6/thresholds/) supply machine-readable pass/fail criteria.
- [Playwright](https://playwright.dev/docs/intro) executes real browser journeys and captures traces.
- [Locust](https://docs.locust.io/en/stable/) is a Python-native alternative for user behavior and distributed load.

## Recommended Free-First Stack with Rationale

Use a TypeScript CLI and local Next.js dashboard orchestrating k6 and Playwright, with SQLite for runs and filesystem storage for artifacts. The tools already solve traffic and browser execution; the product layer should focus on safe orchestration, comparison, and explanation.

## Architecture/Data Model

Store `targets`, `ownership_checks`, `journeys`, `load_profiles`, `thresholds`, `runs`, `samples`, `failures`, and `artifacts`. A controller validates the target, launches a capped subprocess, ingests JSON metrics, observes a kill channel, and derives the first threshold-crossing point.

## Build Slices

1. Localhost-only k6 wrapper and threshold report.
2. Playwright journey recorder, trace attachment, and comparison chart.
3. Verified allowlist, guardrails, badge/death-certificate renderer.
4. Regression mode for two builds.

## Drawbacks/Concerns/Failure Modes

Client-machine limits can be mistaken for server limits; cold starts skew results; browser tests are expensive; and public targets create abuse risk. Record generator CPU/network, run warmups, separate HTTP from browser load, and fail closed on target verification.

## Clever Hacks and Simpler Alternative

Start as `npx user50 test http://localhost:3000 --max-vus 50` with one YAML journey and a static HTML report. A single “baseline versus current” regression gate is more useful than AI-generated personas.

## Success Measures

Track reproducibility across three runs, accurate first-failure detection, time to useful diagnosis, zero traffic beyond configured limits, and whether a reported bottleneck is confirmed by the next fix.

## Product Path

Personal load harness → open-source CI tool → hosted reliability lab. Before public targets, team accounts, or paid benchmarks, run [[Scope Expansion Checklist]] for authorization, abuse controls, data handling, and release terms; keep the recommended local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#3. Dies at User 50]]
- [[Scope Expansion Checklist]]
- [[landing-page-conversion-agency|Landing Page Conversion Agency]]

