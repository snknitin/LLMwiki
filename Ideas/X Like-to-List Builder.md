---
type: workflow-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - New Personal Workflows and Product Ideas#2. X Like-to-List Builder]]"
status: concept
difficulty: easy
priority: p1
category: social graph organization
form_factor:
  - local CLI
  - review dashboard
deployment: local-first
source_ideas:
  - create X lists from an export of all liked tweets
tags:
  - x
  - lists
  - clustering
  - social-graph
---

# X Like-to-List Builder

> Turn years of liked posts into a small, useful set of X Lists by clustering the people and subjects you repeatedly valued—not merely the accounts you happened to follow.

## Product Outcome

Given an X archive or exported liked-post dataset, produce an editable map of authors, topics, relationships, and proposed Lists. Each placement is supported by representative liked posts and a confidence score. The final output can remain a CSV/change plan or be applied through the official Lists API after review.

The tool should answer: Who repeatedly taught or entertained me? What themes connect them? Which accounts belong in more than one context? Which valuable authors am I not following? Which existing lists should be split, merged, or retired?

## Personal V0

1. Import the likes portion of an X archive or a user-created CSV/JSON export.
2. Normalize post ID/URL, author handle, text, timestamp, media/link hints, and like date when available.
3. Resolve enough author metadata to identify renamed/deleted accounts while retaining the original handle.
4. Embed or classify each liked post, then aggregate topics at author level.
5. Propose five to twelve Lists such as AI research, local AI, builders, finance, writers, friends, opportunities, or entertainment.
6. Show every author with three representative likes, proposed list memberships, and editable reasons.
7. Export `lists.csv`, per-list Markdown, and an optional approved API action plan.

## Build Boundary

**MVP:** local import, author aggregation, clustering, editable list proposals, multi-list membership, and CSV/Markdown export.

**Later:** current profile lookup, existing-list comparison, List creation/member writes, recurring incremental updates, and integration with [[Shortform Signal Digest]].

Do not make X API access a prerequisite. The useful artifact is the reviewed information architecture; applying it manually is acceptable.

## Existing Products, Building Blocks, and Shortcuts

- X documents how to [download your archive](https://help.x.com/en/managing-your-account/how-to-download-your-x-archive); this is the stable personal-data starting point.
- The official [X Lists API](https://docs.x.com/x-api/lists/introduction) supports list and membership operations when an approved authenticated route is available.
- [Sentence Transformers](https://github.com/UKPLab/sentence-transformers), [BERTopic](https://github.com/MaartenGr/BERTopic), and scikit-learn clustering provide transparent local baselines before an agent is needed.
- `jq`, DuckDB, and Polars are enough for archive inspection. Useful smoke test: `jq 'length' likes.json`; use a small adapter to strip JavaScript wrappers if the archive is not plain JSON.
- TweetDeck/X Pro, Twitter List Manager tools, and read-it-later taggers are product references. This workflow differs by inferring organization from what the user actually liked.

## Recommended Free-First Stack

- Python CLI with Pydantic, Polars, sentence-transformers, UMAP/HDBSCAN or agglomerative clustering.
- SQLite for posts, authors, clusters, placements, and user edits.
- Streamlit for the first review UI; SvelteKit only if list editing becomes cumbersome.
- Local model to label clusters and summarize why an author matters; deterministic similarity and user edits decide placement.
- CSV, Markdown, and JSON action-plan exports; optional X OAuth adapter later.

## Data Model and Logic

`LikedPost` references `AuthorIdentity`, content text/hash, timestamps, and extracted topics. `AuthorProfile` aggregates topic weights, representative posts, recency, and like count. `ListProposal` has name, purpose, inclusion rules, and `MembershipProposal` records evidence, confidence, review state, and whether the author may belong to several lists.

Cluster posts first, then aggregate to authors. Clustering authors solely from profile bios misses the exact work that made them useful.

## Build Slices

1. Archive inspection, adapter tests, and normalized post table.
2. Handle/author aggregation with representative likes.
3. Embeddings, clusters, and editable labels.
4. Multi-list proposal and review dashboard.
5. CSV/Markdown export and before/after report.
6. Optional authenticated List writes with dry-run and verification.

## Drawbacks, Concerns, and Failure Modes

- Likes are multi-purpose: bookmark, agreement, support, humor, or accidental tap. Allow per-post intent labels and do not treat every like as endorsement.
- Prolific authors can dominate clusters. Cap representative posts or weight authors rather than raw post count.
- Deleted posts and renamed accounts produce gaps. Preserve IDs and original evidence without blocking the rest of the analysis.
- Topic models create redundant or meaningless labels. Optimize for a small set of Lists the user will actually open.
- Old interests may pollute the current map. Add recency views rather than discarding history.

## Clever Hacks and Simpler Alternative

- Generate an author-frequency report and manually label the top 100; this may provide most of the value.
- Ask the user to name three desired Lists, then classify into those before attempting unsupervised discovery.
- Create a “why I liked them” one-line note for every approved author; it becomes useful even without X Lists.
- Use list overlap intentionally. “AI research” and “people I may contact” are different dimensions.

## Success Measures

- At least 80% of high-frequency useful authors receive a sensible membership after review.
- The final list set is small enough to use weekly.
- Representative likes make placements understandable without rereading the full archive.
- Re-running the importer does not duplicate records or overwrite manual decisions.
- The user discovers valuable accounts/topics that were buried in likes.

## Product Path

One-off local archive workflow -> incremental personal list maintainer -> general social-graph organizer. Apply [[Scope Expansion Checklist]] only before distributing the tool, handling other users’ archives, or operating writes for them.

## Related

- [[Shortform Signal Digest]]
- [[Social Subscription Curator]]
- [[Personal Signal Intelligence OS]]
- [[Project Ideas Index]]

