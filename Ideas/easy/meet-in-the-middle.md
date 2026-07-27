---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: group-coordination
form_factor:
  - shareable web session
  - Telegram group bot
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#11. Meet in the Middle]]"
status: concept
tags: [maps, routing, groups]
---

# Meet in the Middle

> Privately collect approximate origins and choose a venue that minimizes unfair travel time—not a geometric midpoint.

## Product Outcome

A host creates an expiring session, participants submit an approximate neighborhood or station, and the app ranks candidate meeting areas by maximum travel time, total time, venue fit, and opening status. Exact origins need not be shown to the group.

## User and Core Workflow

1. Host creates session, time, travel modes, venue type, and max budget.
2. Participants submit approximate origins through private links.
3. Geocode with confirmation and discard raw typed details when possible.
4. Compute travel-time matrix to candidate areas.
5. Rank with transparent fairness weights.
6. Share top three options and run a group vote.

## Demo/Personal V0

Three participants, transit/driving durations from a public/self-hosted OSRM demo, five manually seeded venues, minimax ranking, and an expiring result page.

## Build Boundary

**MVP:** one city/mode, approximate origins, 3–8 people, matrix ranking, manually supplied venues, delete/expiry.

**Out:** continuous location tracking, exact address sharing, booking/payment, arbitrary WhatsApp group automation, safety guarantees, or global routing.

## Existing Products, Building Blocks, and Shortcuts

- [Telegram Bot API](https://core.telegram.org/bots/api) supports group bots, location messages, buttons, and polls.
- The public [Nominatim policy](https://operations.osmfoundation.org/policies/nominatim/) permits small attributed/cached geocoding but limits load and forbids autocomplete.
- [OSRM Table service](https://project-osrm.org/docs/v5.24.0/api/) returns route-duration matrices, replacing straight-line midpoint math.
- Google [Places Nearby Search](https://developers.google.com/maps/documentation/places/web-service/nearby-search) is a later paid-quality venue adapter.

## Free-First Stack

React/Vite session page, SQLite or expiring in-memory state, Nominatim with caching, OSRM Table, and a small curated venue list. Telegram is the easiest real group-bot iteration.

## Architecture/Data Model

`Session` stores time/preferences/expiry. `ParticipantOrigin` stores approximate coordinate and display alias. `Candidate` stores venue/area. `TravelMatrix` stores source/time/mode. `Ranking` exposes max, median, total travel, and missing routes.

## Build Slices

1. Session/invite and approximate location confirmation.
2. Candidate seed list and distance baseline.
3. OSRM matrix plus minimax ranking.
4. Vote/result/expiry.
5. Optional Telegram group flow.

## Drawbacks/Concerns/Failure Modes

- Exact locations are sensitive; collect neighborhoods/stations and expire them.
- Public geocoders/routers have limits and no SLA.
- A venue can be fair but unsuitable or closed; keep manual verification.
- Transit matrices need transit-specific routing; OSRM mainly covers road profiles.

## Clever Hacks and Simpler Alternative

Ask everyone for nearest station, then rank a curated station/venue list. This avoids geocoding and gives socially understandable results.

## Success Measures

- Result shows why each option ranks.
- No participant sees another’s exact origin.
- Session auto-deletes on expiry.
- Group reaches a choice faster than chat-only coordination.

## Product Path

Private link tool → Telegram bot → venue-data integration → group-planning product. Expansion needs location privacy, map/provider terms, and booking-affiliate disclosure.

## Related Wikilinks

- [[City Roast Map]]
- [[Commute Copilot]]

