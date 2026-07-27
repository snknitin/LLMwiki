---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#13. Paisa Vasool Subscriptions]]"
status: concept
difficulty: easy
priority: urgent
urgency: personal-beta-by-2026-08-27
category: personal finance
form_factor:
  - local dashboard
  - reminder automation
deployment: local-first
source_ideas:
  - identify and cancel unused subscriptions
tags:
  - subscriptions
  - finance
  - automation
---

# Paisa Vasool Subscriptions

> A private subscription value tracker that finds recurring charges, asks whether they were actually useful, and prepares cancellation or renegotiation steps without taking irreversible action.

## Product Outcome

“Paisa vasool” is value received, not merely low cost. The app combines recurring-charge detection with explicit usage and importance feedback to show cost per use, annualized cost, renewal deadlines, and the safest next action.

## Personal V0

- Import bank/card CSVs or enter subscriptions manually.
- Detect probable recurring merchants using amount and timing patterns.
- Confirm each candidate and record plan, billing cycle, renewal date, and cancellation URL.
- Ask for lightweight usage/value feedback monthly.
- Calculate annual cost, cost per use, price changes, and “keep/cancel/downgrade/negotiate” suggestions.
- Send reminders before renewals and trials end.
- Generate a cancellation checklist or draft support message for approval.
- Record savings only after a statement confirms the charge stopped.

## Build Boundary

**MVP:** CSV import, confirmed subscription registry, renewal calendar, value score, and manual cancellation workflow.

**Later:** inbox receipt parsing, browser-guided cancellation, family sharing, and read-only financial connectors. Never click a final cancellation button or alter a service without explicit confirmation.

### Month-One Personal Beta

Reuse the tested transaction importer from [[Net Worth Command Center]]. Begin with normalized merchant and monthly/annual recurrence rules, review every candidate, and maintain a gold fixture of true/false subscriptions. Over the month, verify renewal dates against receipts, export reminders, and confirm savings only from later statements. Email parsing and cancellation assistance are earned by observed gaps.

## Existing Products, Building Blocks, and Shortcuts

- [Actual Budget](https://github.com/actualbudget/actual), [Firefly III](https://github.com/firefly-iii/firefly-iii), and `hledger` already classify recurring transactions; reuse the finance importer/rule vocabulary instead of building a separate banking stack.
- Rocket Money and Bobby are product references for subscription discovery and renewal reminders. The local differentiator is privacy, cost-per-use, verified cancellation, and no credential custody.
- Email receipts can be forwarded or exported and parsed locally with mailparser/Python; an `.ics` renewal calendar is a durable no-notification-service output.
- Simplest alternative: confirmed registry + renewal date + official cancellation deep link. Do not automate the final click until repeated manual cancellation steps justify a guarded browser helper.

## Free-First Stack

- **UI:** local PWA, Streamlit, or a module inside [[Net Worth Command Center]].
- **Data:** SQLite.
- **Detection:** deterministic recurrence rules and merchant aliases; local model only for ambiguous descriptions.
- **Automation:** n8n reminders to Telegram/email.
- **Browser helper later:** extension that opens the verified account/cancellation page and records steps, without storing passwords.

## Clever Shortcut

Skip bank integration at first. Search the last twelve months of exported transactions for repeated normalized descriptions, then ask the user to verify. A second input—calendar reminders or email receipts—can improve renewal dates without a financial-data vendor.

## Build Slices

1. Manual registry and renewal reminders.
2. CSV recurrence detector and confirmation UI.
3. Usage/value check-ins and cost-per-use.
4. Cancellation packet and savings verification.
5. Optional email receipt ingestion.

## Success Measures

- Recurring-charge candidates have high precision.
- Renewal reminders arrive early enough to act.
- Verified annual savings exceed operating cost.
- Important but infrequently used services are not mislabeled as waste.
- No credentials or full bank files enter a cloud model.

## Product Path

The personal tool may simply remain a module of the finance dashboard. A consumer product would face support-heavy merchant variation; a better product wedge may be a privacy-first subscription audit that works from user exports.

## Related

- [[Net Worth Command Center]]
- [[Goal-to-Calendar Planner]]
- [[Project Ideas Index]]
