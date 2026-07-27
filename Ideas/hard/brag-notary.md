---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: evidence and provenance
form_factor:
  - local verification desk
  - shareable evidence receipt
deployment: local-first with optional public verifier
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#4. Brag Notary]]"
status: concept
tags:
  - provenance
  - verification
  - cryptography
---

# Brag Notary

> A claim-evidence workbench that timestamps what was submitted, verifies narrowly defined checks, and never confuses tamper evidence with truth.

## Product Outcome

Let a founder turn “we hit 10k users” into an inspectable claim receipt: the exact claim, evidence files/links, source captures, checks performed, caveats, reviewer identity, timestamp, and content hash. The output says `supported`, `partially supported`, or `insufficient evidence` at the atomic-check level.

## User and Core Workflow

The user writes a claim and decomposes it into measurable fields such as metric, threshold, population, date, and system of record. They attach exports or public sources. The verifier hashes/captures evidence, runs type-specific checks, flags contradictions, and asks for missing scope. The user reviews redactions; the system signs a manifest and produces a badge that opens the evidence receipt.

## Demo/Personal V0

Use three synthetic claims: fully supported, misleading denominator, and unverifiable. Generate local signed JSON manifests and an HTML verifier. Demonstrate that editing either the claim or evidence breaks verification. Do not publish real customer data.

## Build Boundary

This is not a legal notary, audit, assurance engagement, identity proof, or guarantee that an upstream screenshot/export is genuine. Never expose private analytics, customer records, or secrets. Avoid binary “fraud” stamps; show evidence limits.

## Existing Products, Building Blocks, and Shortcuts

- [OpenTimestamps](https://opentimestamps.org/) can anchor a document hash to Bitcoin without uploading the document.
- [Sigstore Rekor](https://docs.sigstore.dev/logging/overview/) is an append-only transparency log for signed metadata; use a private/local log for confidential evidence.
- [C2PA Content Credentials](https://spec.c2pa.org/specifications/) standardize signed provenance for media, while the [C2PA explainer](https://spec.c2pa.org/specifications/specifications/2.2/explainer/Explainer.html) clearly states provenance does not establish truth.
- `cosign sign-blob` from [Sigstore Cosign](https://docs.sigstore.dev/cosign/signing/signing_with_blobs/) can sign a manifest without building custom cryptography.

## Recommended Free-First Stack

Use Python/FastAPI, Pydantic claim schemas, SQLite, filesystem evidence blobs, SHA-256 hashes, and Sigstore/Cosign or a local Ed25519 key. Render with SvelteKit. Add OCR/LLM extraction only to suggest fields; verification rules remain deterministic and reviewer-visible.

## Architecture/Data Model

Entities are `Claim`, `AtomicAssertion`, `EvidenceItem`, `Capture`, `Check`, `Finding`, `Redaction`, `Reviewer`, `Manifest`, and `Signature`. The manifest contains canonicalized hashes, not private evidence. Verification rehashes all inputs and displays signature trust separately from evidence sufficiency.

## Build Slices

1. Claim schema and evidence uploader.
2. Canonical manifest and content hashing.
3. Three deterministic check types.
4. Reviewer/caveat workflow.
5. Signature, timestamp, and public verifier.
6. Badge with revocation/supersession state.

## Drawbacks, Concerns, and Failure Modes

Screenshots and CSVs can be fabricated before hashing. Public logs leak metadata. Key loss or compromise harms trust. A badge invites over-reading and selective evidence. External links rot. “Notary” language may imply regulated legal authority.

## Clever Hacks and Simpler Alternative

Start with a Git-signed Markdown evidence packet and QR code. Use “timestamped evidence receipt” in the interface. Require one counterevidence field and an expiry/recheck date so a formerly true growth claim is not treated as current forever.

## Success Measures

- Any one-byte change invalidates the receipt.
- Every status is explained by atomic checks and caveats.
- Private evidence is absent from the public manifest.
- A superseded or revoked receipt is obvious.
- A third party can verify the bundle without trusting the app server.

## Product Path

Personal portfolio receipts can evolve into launch-metric provenance or grant/milestone evidence. Regulated attestations, KYC, and public accusations require professional partners and a separate legal product.

## Related

- [[Data Room Concierge]]
- [[Startup Graveyard]]
- [[Source Idea Coverage Map]]
