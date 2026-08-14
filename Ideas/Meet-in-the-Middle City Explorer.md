---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - New Personal Workflows and Product Ideas#6. Meet-in-the-Middle City Explorer]]"
status: concept
difficulty: medium
priority: p2
category: group planning and local discovery
form_factor:
  - responsive web app
  - Telegram group bot
deployment: local-first then hosted session links
source_ideas:
  - meet-in-the-middle travel-time optimizer
  - city roast map as a playful decision layer
tags:
  - maps
  - routing
  - venues
  - humor
  - groups
---

# Meet-in-the-Middle City Explorer

> Find a genuinely fair place to meet, then make choosing it fun with a compact local brief, practical venue shortlist, and a playful roast/compliment of each candidate area.

## Why These Two Ideas Merge Cleanly

[[meet-in-the-middle]] computes candidate areas from participant origins, time, mode, and fairness. [[city-roast-map]] turns neighborhood data and local lore into memorable cards. The calculation and comedy share the same city/venue data but remain separate layers: routing decides what is fair; the roast never changes the score.

The combined product is more useful than either alone. A midpoint calculator gets the group to three rational options; the city layer gives the group something enjoyable and distinctive to vote on.

## Product Outcome

A host creates an expiring planning session, participants submit an approximate starting point and constraints, and the system ranks areas/venues by maximum travel time, total/median time, transfer burden, price, opening hours, and desired vibe. Each result includes:

- travel-time comparison and why the option is fair;
- two to five venues with verification links;
- practical notes such as last train, parking, weather exposure, and reservation need;
- a playful data-backed roast and compliment;
- group vote and final meetup card.

## Personal V0

- Support one familiar city, three to eight participants, one travel mode, and a curated list of twenty candidate venues.
- Collect nearest station or approximate neighborhood through private session links.
- Compute an OSRM road-time matrix or use manually entered transit times.
- Rank candidates with minimax travel time and a transparent weighted score.
- Add hand-reviewed roast/compliment cards based on benign venue/transit/amenity observations.
- Run a group vote and export the winner as a shareable card/ICS event.

## Build Boundary

**MVP:** expiring session, approximate origins, candidate list, travel matrix, transparent ranking, local character cards, vote, and final plan.

**Later:** multimodal/transit routing, live opening hours, budgets, accessibility needs, weather, reservations, conversational group bot, and city packs.

Exact tracking, booking/payment, and a global venue database are not needed for the first useful city.

## Existing Products, Building Blocks, and Shortcuts

- [OSRM Table API](https://project-osrm.org/docs/v5.24.0/api/#table-service) computes road travel-time matrices; [OpenTripPlanner](https://www.opentripplanner.org/) is the heavier open-source transit path.
- [Nominatim](https://operations.osmfoundation.org/policies/nominatim/) can geocode small, cached personal workloads, while nearest stations or manually confirmed map pins avoid autocomplete entirely.
- [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API), [Wikidata Query Service](https://query.wikidata.org/), and [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/) cover nearby feature data and interactive maps.
- Google Places or Foursquare can be later venue-quality adapters; a curated CSV is more reliable for the first city.
- Telegram polls and the [Telegram Bot API](https://core.telegram.org/bots/api) provide the fastest group interface after a shareable web session.
- TravelTime/Meetways-style midpoint tools and city meme pages are product references. The unique layer is fair route scoring plus an evidence-aware social decision card.

## Recommended Free-First Stack

- SvelteKit/Vite TypeScript web app with MapLibre.
- SQLite for personal sessions; Postgres/PostGIS only for hosted multi-city search.
- Python/GeoPandas data-prep scripts; OSRM/OpenTripPlanner adapter boundary.
- Curated venue CSV/GeoJSON plus cached Overpass/Wikidata observations.
- Local model for roast/compliment drafts; human-approved template library for the initial city.
- ICS export and Telegram share link before calendar/booking APIs.

## Architecture and Data Model

`PlanningSession` stores date/time, travel modes, venue intent, budget, ranking weights, and expiry. `ParticipantOrigin` stores approximate point or station. `CandidateArea` owns venues and observation summaries. `TravelMatrixCell` records route duration, transfers/distance, provider, and capture time. `CandidateScore` exposes max, median, total, spread, and penalties. `LocalCharacterCard` stores evidence IDs, roast, compliment, and review state. `Vote` and `FinalPlan` close the loop.

## Build Slices

1. Session links and approximate origin input.
2. Curated candidates plus straight-line baseline.
3. Route matrix and minimax/weighted ranking.
4. Practical venue cards and evidence drawer.
5. Roast/compliment templates and group vote.
6. Final plan card, ICS, and Telegram flow.
7. Second city or transit routing only after the first is reliable.

## Drawbacks, Concerns, and Failure Modes

- Geographic midpoint is often unfair; always rank travel time.
- Public router/geocoder data can be stale or mode-limited. Show provider and verification links.
- A fair area may have unsuitable venues. Keep the curated shortlist and manual override.
- Humor can overpower usefulness. Put route facts first and keep roast/compliment optional.
- Transit conditions vary by day and hour. Cache with timestamps and allow participant-entered corrections.
- Too many scoring sliders make group choice harder. Offer simple presets such as fairest, fastest overall, cheapest, or most fun.

## Clever Hacks and Simpler Alternative

- Ask only for nearest station and rank a curated station list.
- Use a lexicographic score: first minimize worst journey, then total time, then venue fit.
- Generate a “loser’s consolation” card explaining why the runner-up lost.
- Include both roast and compliment on a flip card so the joke does not become the data.
- Let participants veto one area before voting.

## Success Measures

- Groups choose a venue faster than chat-only planning.
- Every recommendation exposes individual travel estimates and ranking logic.
- Participants perceive the result as fair even when their preferred area does not win.
- Venue/route checks are current enough for the meeting.
- Roast/compliment cards improve participation without changing the deterministic score.

## Product Path

One-city private session tool -> Telegram group planner -> curated city packs -> venue/reservation partnerships. Run [[Scope Expansion Checklist]] before public location storage, commercial venue placement, or booking integrations; the local routing and data model remain valid.

## Related

- [[meet-in-the-middle]]
- [[city-roast-map]]
- [[commute-copilot]]
- [[Event Networking Copilot]]
- [[Project Ideas Index]]

