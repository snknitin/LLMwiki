---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: transit-and-alerts
form_factor:
  - local dashboard
  - messaging bot
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#26. Commute Copilot]]"
status: concept
tags:
  - transit
  - alerts
  - routing
---

# Commute Copilot

> A route-specific departure check that says whether to leave now, wait, or use a known fallback—with freshness made explicit.

## Product Outcome

The user saves one commute, preferred departure windows, and acceptable alternatives. Before leaving, the tool checks scheduled and realtime feeds, summarizes disruption impact, proposes a route, and produces a compact share card. Trust comes from precise timestamps and graceful “data unavailable” states.

## User and Core Workflow

1. User defines origin/destination as approximate stops, weekdays, time window, and walking tolerance.
2. Import the city’s GTFS schedule and discover relevant trips.
3. Poll GTFS Realtime feeds near the commute window.
4. Compare expected arrival/departure with baseline and apply route-specific alert rules.
5. Notify only when action changes: leave earlier, take fallback, or no reliable data.
6. Open a map/card with source agency and last-updated time.

## Demo/Personal V0

Choose one city with working GTFS and GTFS Realtime feeds. Support one saved route and one fallback. Run the checker manually, render current departure rows and a shareable HTML/PNG alert. A prerecorded feed fixture makes the demo reproducible.

## Build Boundary

**MVP:** one agency, one commute, static GTFS import, realtime trip updates/alerts, freshness checks, simple fallback, local notifications/card.

**Out:** global city support, fare payment, ride-hailing, predictive crowding, background precise GPS, turn-by-turn navigation, guaranteed arrival claims, and public incident reporting.

## Existing Products, Building Blocks, and Shortcuts

- [GTFS Realtime Trip Updates](https://gtfs.org/documentation/realtime/feed-entities/trip-updates/) provide standardized delays, cancellations, and stop-time changes instead of agency-specific scraping.
- GTFS [Realtime Best Practices](https://gtfs.org/documentation/realtime/realtime-best-practices/) supply freshness and data-quality expectations for trustworthy alerts.
- [OpenTripPlanner](https://github.com/opentripplanner/OpenTripPlanner) replaces building a multimodal router from scratch and combines GTFS, OpenStreetMap, and realtime updates.
- [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/) provides an open interactive route display.

## Free-First Stack

- **Backend:** Python + FastAPI; `gtfs-realtime-bindings`, Polars, and SQLite.
- **Routing:** simple preselected-trip logic first; OpenTripPlanner Docker only when alternate routing is needed.
- **Scheduler:** APScheduler around the user’s commute windows.
- **UI/cards:** minimal PWA or Telegram bot plus MapLibre card page.
- **Notifications:** local desktop/Telegram; no mobile push infrastructure initially.

## Architecture/Data Model

`AgencyFeed` stores URLs, timezone, expected refresh, and health. `SavedCommute` references origin/destination stops, days, window, and fallback rules. `TripObservation` stores scheduled/realtime times and feed timestamp. `AlertDecision` stores rule inputs, chosen action, confidence, and expiry. `NotificationReceipt` prevents duplicates.

## Build Slices

1. GTFS importer and stop/trip browser.
2. One saved route and scheduled departure view.
3. Realtime ingest, freshness, delay/cancel handling.
4. Action rules and deduplicated notifications.
5. Fallback routing and share card.

## Drawbacks/Concerns/Failure Modes

- Many cities lack complete or reliable realtime feeds; feed availability is the first go/no-go check.
- Stale data is worse than no data. Display source timestamp, health, and fall back to schedule explicitly.
- Trip IDs and stop sequences can change on feed updates; version imports and reconcile carefully.
- Routing engines are operationally heavy for one commute. Preselect routes before deploying OpenTripPlanner.
- Alert fatigue destroys trust. Notify only on material action changes and include quiet hours.

## Clever Hacks and Simpler Alternative

- Build a “one button before I leave” checker before background alerts.
- Cache a known-good commute and two fallbacks; you do not need general-purpose routing.
- Test with recorded protobuf fixtures for on-time, delay, cancellation, and stale-feed cases.
- Generate office-share cards without revealing exact home location—use route/stop aliases.

## Success Measures

- Feed freshness is visible on every decision.
- Duplicate alerts remain below one per incident.
- The tool correctly handles fixture delays/cancellations/stale data.
- Morning check takes under five seconds after cache warmup.
- User reports at least one avoided bad commute per month.

## Product Path

Personal route checker → city-specific bot → employer commute assistant → multi-agency product. Expansion depends on feed licenses/quality, privacy controls, alert delivery costs, and reliability commitments.

## Related Wikilinks

- [[Meet in the Middle]]
- [[Personal Morning Briefing]]
- [[Local Discovery Dashboard]]

