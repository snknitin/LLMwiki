---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#14. GiftShelf]]"
status: concept
difficulty: medium
priority: p1
category: gifting and commerce
form_factor:
  - web app
deployment: hosted
source_ideas:
  - buy-me-a-coffee alternative based on wish-list items, pooled gifts, recurring buys, and book recommendations
tags:
  - wishlist
  - gifting
  - payments
---

# GiftShelf

> A public recommendation shelf and gift registry where supporters can fund a specific book, tool, recurring need, or pooled item instead of sending an abstract tip.

## Product Outcome

Creators and ordinary users build a transparent list of things they genuinely want or recommend. A supporter selects an item, pays all or part, adds a message, and receives a clear fulfillment status. “Buy me a book” can simultaneously express support and share taste.

## Personal V0

- Create a public shelf with title, why it matters, price range, priority, URL, and whether multiples are useful.
- Group items into books, tools, subscriptions, experiences, and pooled goals.
- Let a supporter reserve or mark an item purchased externally.
- Prevent duplicate gifts through a temporary reservation.
- Show funded, partially funded, received, and reviewed states.
- Publish a post-use note or review with optional supporter thanks.
- Suggest a gift from budget, interests, and shipping region using explicit item data.

## Build Boundary

**MVP:** wish list, shareable pages, external purchase/reservation links, and no money custody.

**Later:** pooled payments, recurring sponsorship, creator integrations, fulfillment, and tax receipts where applicable. “Gift” treatment varies by jurisdiction and circumstances; the app must not promise that payments are universally non-taxable.

## Existing Products, Building Blocks, and Shortcuts

- Amazon Wish Lists and registries prove reservation/fulfillment behavior; Throne focuses on creator gifting, while Buy Me a Coffee/Ko-fi prove simple supporter pages. Compare their duplicate prevention and privacy before adding payments.
- [Open Library APIs](https://openlibrary.org/developers/api) can enrich book entries, and ordinary merchant deep links remove checkout, custody, refunds, and fulfillment from the first version.
- [Stripe Connect](https://docs.stripe.com/connect) or a local marketplace-capable provider is a later pooled-payment primitive, but it should not influence the link-and-reservation MVP.
- Simplest alternative: static shelf + “I bought this” reservation + owner confirmation. This proves recommendation, sharing, and duplicate prevention before money flows through the app.

## Free-First Stack

- **Web:** Next.js/SvelteKit.
- **Data/auth:** Postgres with magic links; a free-tier managed backend is acceptable for v0.
- **Images/metadata:** user-entered first; retailer metadata only through permitted APIs.
- **Payments later:** a marketplace-capable payment provider with webhooks, refunds, and identity/compliance support.
- **Recommendations:** deterministic filters and embeddings over the user’s own notes; no model needed for checkout.
- **Notifications:** email via a transactional provider or simple share links initially.

## Clever Shortcut

Do not collect money. Generate a beautiful shelf that deep-links to the merchant, plus a “I bought this” reservation. This proves sharing, gift selection, and duplicate prevention before taking on payment custody, chargebacks, refunds, taxes, or split payouts.

## Build Slices

1. Shelf editor and public page.
2. Reservation/duplicate-prevention flow.
3. Fulfillment and thank-you status.
4. Recommendation quiz.
5. Creator embeds and analytics.
6. Pooled funds only after legal/payment review.

## Success Measures

- Supporters understand exactly what their action buys.
- Duplicate gifts are rare.
- Shelf owners keep items and status current.
- Gift conversion is better than a generic support link for the same audience.

## Product Path

The strongest wedge is book-focused creator shelves with reviews and affiliate-compatible outbound links. Payment pooling is a separate, regulated complexity tier and should not block the useful registry.

## Related

- [[Personal Library Website]]
- [[Creator Content Engine]]
- [[Project Ideas Index]]
