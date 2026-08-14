---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - New Personal Workflows and Product Ideas#1. Moving Out Marketplace]]"
status: concept
difficulty: hard
priority: p1
category: local marketplace
form_factor:
  - responsive web app
  - map and deadline marketplace
deployment: local prototype then hosted product
source_ideas:
  - deadline-driven moving-out sale marketplace
  - nearby garage-sale discovery
  - optional rental and property handoff leads
tags:
  - marketplace
  - local-commerce
  - moving
  - maps
  - auctions
---

# Moving Out Marketplace

> A deadline-first local marketplace where a move becomes a temporary storefront: buyers discover useful goods nearby, sellers clear a home before handover day, and every listing visibly gets cheaper or more urgent as the deadline approaches.

## Product Outcome

The central object is not an isolated classified ad; it is a **move-out event** with a neighborhood, pickup window, final date, seller preferences, and a collection of items. Buyers can follow a nearby move, assemble a bundle, make an offer or bid, reserve pickup slots, and see what must disappear soon. Sellers get a single command center for inventory, messages, bundles, reservations, payments, and the final donate/recycle queue.

The distinctive value is deadline liquidity. Ordinary marketplaces optimize for the highest acceptable price over an open-ended period. This product helps a seller maximize a blended outcome—cash recovered, items diverted from waste, pickup reliability, and an empty home by a fixed time.

## Personal V0

Run one real or simulated move without payments:

1. Create a move event with approximate area, final date, pickup windows, and a private exact-address reveal rule.
2. Photograph ten to thirty items and create listings with title, category, condition, dimensions, starting price, floor price, and pickup constraints.
3. Publish one shareable storefront URL plus a map card that exposes only an approximate area.
4. Let invited buyers request a reservation, propose a price, or build a bundle.
5. Rank offers by price, bundle size, pickup fit, and buyer reliability rather than price alone.
6. Produce a pickup manifest and a final unresolved-items list for donation, recycling, storage, or disposal.

The V0 succeeds if it coordinates a move better than a spreadsheet plus chat thread. Search, public accounts, bidding, payments, and shipping are later layers.

## Core Experiences

### Seller move command center

- Batch-create listings from phone photos.
- Track `draft -> listed -> negotiating -> reserved -> collected -> fallback`.
- Suggest bundles such as desk + chair + lamp or kitchen starter pack.
- Apply explicit price rules: fixed, best offer, descending price, sealed bid, free after date, or donation fallback.
- Schedule pickups without exposing the exact address until a reservation is confirmed.
- Print or display QR labels so collected items can be checked off quickly.

### Buyer discovery

- Search by distance, pickup window, category, dimensions, price, and move deadline.
- Follow a whole move rather than opening thirty unrelated listings.
- Make a single bundle offer and choose a feasible pickup slot.
- Save searches such as “desk within 5 km before Sunday” or “free kitchen items today.”

### Deadline engine

Each listing has a visible urgency curve. The seller chooses the rule; the system never silently changes a price. A simple version can propose markdowns at `T-14`, `T-7`, `T-3`, and `T-1`, then move unclaimed items into a fallback queue.

## Build Boundary

**MVP:** one seller event, invited buyers, approximate map location, photo listings, fixed-price/offer modes, bundle proposals, pickup slots, status tracking, and exportable manifests.

**Product later:** public discovery, reputation, auctions, escrow/payment provider, delivery partners, multi-city search, promoted events, landlord/property-manager workflows, and rental/property referrals.

Keep property discovery as an adjacent handoff card—not mixed into the furniture transaction model. A move can optionally say “this home may be available” and link to a proper property listing, but household goods and real estate have very different schemas and workflows.

## Existing Products, Building Blocks, and Shortcuts

- Facebook Marketplace, Craigslist, OLX, OfferUp, Nextdoor, Freecycle, and Buy Nothing are useful product references for local classifieds and giveaways. The opportunity is the event storefront, hard deadline, bundle optimizer, and pickup manifest rather than another infinite listing feed.
- [Sharetribe](https://www.sharetribe.com/docs/) is a marketplace accelerator for hosted listings, transactions, and custom integrations. Study its transaction process before inventing a marketplace state machine.
- [Medusa](https://github.com/medusajs/medusa) and [Vendure](https://github.com/vendure-ecommerce/vendure) provide open-source commerce primitives if checkout becomes necessary; neither should be required for the first coordination-only build.
- [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/) plus a geocoder can render approximate event locations. A geohash or rounded coordinate is enough for discovery before an address is revealed.
- [Stripe Connect](https://docs.stripe.com/connect) is the later marketplace-payment reference. For V0, record an agreed amount and let buyer and seller settle outside the app.
- For an India-first pilot, [Razorpay Payment Links](https://razorpay.com/docs/payments/payment-links/apis/) can create expiring fixed-amount collection links without building checkout; [Razorpay Route](https://razorpay.com/docs/payments/route/) is a later multi-seller split-payout option.
- A WhatsApp/Telegram share link and a static event page are the simplest demand test. If nobody follows the whole event or builds bundles, auctions and payment integration will not fix the concept.

## Recommended Free-First Stack

- **Web:** SvelteKit or Next.js with a mobile-first camera/upload flow.
- **Data:** PostgreSQL/PostGIS when public geo-search is required; SQLite is sufficient for the first private event.
- **Media:** object folder or S3-compatible MinIO, with libvips/Sharp for thumbnails.
- **Map:** MapLibre with approximate coordinates and manually verified pickup notes.
- **Rules:** ordinary TypeScript functions for markdown schedules, reservation expiry, and offer ranking.
- **Optional AI:** a local vision/text model may draft titles, categories, condition questions, and bundle suggestions; the seller confirms all facts and prices.
- **Notifications:** email or Telegram for the personal pilot; add web push/SMS only after reminders prove useful.
- **Image preprocessing:** ImageMagick/libvips for auto-orient, resize, and WebP conversion before any vision-model call.

## Architecture and Data Model

`MoveEvent` owns location precision, deadline, pickup windows, fallback policy, and `Listing` records. A `Listing` owns photos, dimensions, condition, pricing mode, floor/ask values, and state. `Offer` can cover one or many listings. `Reservation` locks a bundle for a time window. `PickupAppointment` records arrival window and collection confirmation. `FallbackAction` records donate/recycle/store/dispose. `EventActivity` is an append-only audit log.

Offer ranking should be transparent: `cash value + bundle-clearance bonus + pickup-fit bonus - failure risk`. The seller chooses the winner. Avoid letting a model decide allocation or price.

## Build Slices

1. Event page, item schema, photo upload, and shareable storefront.
2. Seller inventory board and buyer reservation request.
3. Offers, bundles, reservation expiry, and pickup calendar.
4. Deadline rules, price suggestions, and fallback manifest.
5. Nearby search and saved alerts using approximate locations.
6. Only after real usage: public identity, reputation, payments, delivery, and monetization experiments.

## Drawbacks, Concerns, and Failure Modes

- The marketplace has a cold-start problem at neighborhood scale. Start with one move whose link is distributed through existing groups; do not begin with an empty city map.
- Sellers may overprice until the final day. Show clearance probability and unsold inventory, but keep price changes explicit.
- Buyers may reserve and disappear. Use short reservation expiry, pickup confirmation, and a waitlist.
- Bundles can create allocation conflicts. Lock inventory transactionally and keep one authoritative event log.
- Shipping defeats the local-clearance advantage for bulky goods. Default to pickup; treat delivery as a separately priced option.
- Auctions add excitement but also delay certainty. Fixed/offer/descending-price modes are more aligned with a hard move deadline.

## Clever Hacks and Simpler Alternative

- Generate one mobile-friendly static catalog with numbered items and a Google Form/Telegram bot for claims. This can validate the event-storefront behavior in a day.
- Put QR stickers on objects; scanning opens the listing and toggles collected status.
- Offer “take the room” bundles and a discount for clearing five or more items.
- Let the seller set a fallback ladder once: sell until Friday, free to friends Saturday, donate Sunday.
- Optimize for **pickup certainty**, not only price. A lower offer that clears eight items in one trip may be the best outcome.

## Success Measures

- Percentage of listed volume collected or routed to a fallback before the move deadline.
- Median time required to photograph and publish one item.
- Reservation no-show rate and average messages per completed pickup.
- Share of sales made as bundles.
- Seller-rated reduction in move-out effort compared with ordinary classifieds.
- For a product pilot: contribution margin per completed event, not gross listing volume.

## Product Path

Private event catalog -> neighborhood moving-sale directory -> managed local marketplace -> partnerships with movers, buildings, donation services, and property managers. Possible revenue models are a one-time event fee, optional promoted visibility, transaction fee after payments exist, or paid concierge services. Test event fees before building financial infrastructure.

Before opening the marketplace to other sellers or payments, run [[Scope Expansion Checklist]] for identity, fraud, taxes, refunds, prohibited goods, location exposure, payment-provider rules, and marketplace operations. These later requirements do not change the local V0 stack.

## Related

- [[Meet-in-the-Middle City Explorer]]
- [[GiftShelf]]
- [[Paisa Vasool Subscriptions]]
- [[Side-Hustle Radar]]
- [[Project Ideas Index]]
