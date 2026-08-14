---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: email operations
form_factor:
  - local review queue
  - mailbox automation
deployment: local-first with scoped Gmail OAuth
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#10. Inbox Zero Mercenary]]"
status: concept
tags:
  - gmail
  - triage
  - approval-workflow
---

# Inbox Zero Mercenary

> A reversible email triage desk that proposes labels, archives, unsubscribes, and replies while keeping every external or destructive action under explicit user control.

## Product Outcome

Reduce a drowning inbox into bounded buckets: urgent reply, waiting, reference, newsletter, automated receipt, stale, and uncertain. The app should expose why an item landed in a bucket, what action is proposed, and how to undo it. “Zero” is not the goal if it hides missed obligations.

## User and Core Workflow

The user starts with an export or read-only Gmail scope. Rules classify obvious senders/headers; the model handles ambiguous content using goals and VIPs. The user reviews grouped proposals, approves reversible labels/archive batches, and edits individual reply drafts. Unsubscribe requests are a separate approval queue. Feedback updates rules and a weekly sender digest.

## Demo/Personal V0

Process 200 synthetic or exported messages with no writes. Show sender clusters, proposed labels/actions, five cited reply drafts, and a dry-run audit. In a sandbox mailbox, apply only `AI-Proposed-*` labels, then demonstrate rollback.

## Build Boundary

No auto-send, permanent delete, spam reporting, forwarding, broad delegated access, or unsubscribe without approval. Never obey instructions embedded in email bodies. Sensitive content and attachments remain local unless a provider is explicitly chosen.

## Existing Products, Building Blocks, and Shortcuts

- The [Gmail API overview](https://developers.google.com/workspace/gmail/api/guides) covers messages, drafts, labels, filters, and push notifications; use official OAuth instead of browser scraping.
- [`users.messages.batchModify`](https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.messages/batchModify) can change labels for up to 1,000 message IDs; wrap it in preview, idempotency, and rollback.
- [RFC 8058](https://datatracker.ietf.org/doc/html/rfc8058) defines safe one-click unsubscribe headers; prefer it over visiting arbitrary links.
- [Thunderbird](https://github.com/mozilla/releases-comm-central) is a product/reference for local mail storage and filter UX; IMAP is the provider-neutral fallback.

## Recommended Free-First Stack

Use Python, FastAPI, SQLite FTS, Gmail API with the narrowest scope, and a SvelteKit review UI. Run Ollama for classification/drafting and Presidio or regex rules for sensitive-data hints. Keep an encrypted local message cache with short retention; attachments are opt-in.

## Architecture/Data Model

Model `Mailbox`, `MessageHeader`, `MessageSnapshot`, `Thread`, `SenderRule`, `Classification`, `ProposedAction`, `ApprovalBatch`, `Execution`, `Rollback`, `DraftReply`, and `Feedback`. Each mutation records before/after labels, Gmail history ID, actor, and idempotency key.

## Build Slices

1. Export/fixture parser and sender statistics.
2. Deterministic rules and local classification.
3. Grouped review queue with explanations.
4. Draft replies with source-thread citations.
5. Sandbox label mutation and rollback.
6. RFC 8058 unsubscribe review and weekly learning report.

## Drawbacks, Concerns, and Failure Modes

Urgency is personal and contextual. Thread snippets omit attachments/history. Batch actions amplify misclassification. OAuth scopes, cached mail, and reply drafts are high-value data. Unsubscribe endpoints can be malicious or reveal an active address. Archive is reversible but still hides messages from attention.

## Clever Hacks and Simpler Alternative

Start from Gmail search queries and rules: identify top 20 bulk senders, create filters, and produce a daily “needs reply” note. Use a quarantine label for seven days before archiving. A sender-level decision is often safer and more scalable than classifying every message independently.

## Success Measures

- Zero messages sent or permanently deleted automatically.
- Every mailbox mutation can be reversed from the ledger.
- VIP/urgent fixture recall meets a chosen high threshold.
- User review time and inbox count fall without increasing missed-thread reports.
- Feedback changes sender/rule behavior predictably.

## Product Path

Build for one personal Gmail account, then package a privacy-focused local mail triager. Team/shared-mailbox workflows require delegation, retention, audit, and administrator controls; automatic sending remains opt-in and separately gated.

## Related

- [[Personal Signal Intelligence OS]]
- [[support-faq-builder|Support FAQ Builder]]
- [[27-clicks-to-cancel|27 Clicks to Cancel]]
