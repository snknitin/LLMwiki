---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#17. Playo Elo Sports Network]]"
status: concept
difficulty: hard
priority: p2
category: local sports
form_factor:
  - mobile app
  - web admin
deployment: hosted when multi-user
source_ideas:
  - Playo-like booking plus Elo ratings and national leaderboards
tags:
  - sports
  - marketplace
  - ratings
---

# Playo Elo Sports Network

> A local sports matchmaker that combines venue/session coordination with transparent, confidence-aware skill ratings for multiple sports.

## Product Outcome

Players should find a nearby session where availability, format, competitiveness, and reliability match. Ratings are per sport and format, update only from verifiable results, show uncertainty, and are used primarily for balanced games—not status anxiety.

## Personal V0

- Pick one sport and one city/community.
- Create a session with venue, time, level range, cost, and open slots.
- Join, waitlist, check in, and record a result confirmed by both sides.
- Maintain a rating and confidence interval per player.
- Suggest balanced teams and rematches.
- Track reliability separately from skill: cancellations, no-shows, and confirmations.
- Provide private peer groups before a public leaderboard.

## Build Boundary

**MVP:** one sport, invite-only group, session coordination, bilateral score confirmation, and a simple Glicko/Elo implementation.

**Later:** venue booking, payments, tournaments, anti-fraud, clubs, national rankings, and identity verification. Avoid a national leaderboard until match integrity and regional comparability are credible.

## Existing Products, Building Blocks, and Shortcuts

- Playo, OpenSports, and TeamReach are product references for discovery, booking, rosters, and group coordination. Start inside one existing group where coordination already hurts.
- [OpenStreetMap](https://www.openstreetmap.org/) and [MapLibre](https://maplibre.org/) cover venue maps without building geospatial infrastructure.
- [Glicko-2](http://www.glicko.net/glicko.html) and Microsoft’s [TrueSkill](https://www.microsoft.com/en-us/research/project/trueskill-ranking-system/) model rating uncertainty better than raw Elo when matches are sparse or team-based.
- Simplest alternative: invite-only “balanced teams night” with bilateral score confirmation and a separate reliability score. Venue marketplace and national ranking come much later.

## Free-First Stack

- **App:** Expo/React Native for universal client.
- **Backend:** Supabase/self-hosted Postgres or FastAPI/Postgres; multi-user realtime needs a server.
- **Auth:** phone/email magic links; minimal profile data.
- **Ratings:** deterministic tested library; Glicko-2 or TrueSkill-style uncertainty may fit sparse play better than raw Elo.
- **Maps:** OpenStreetMap plus a compatible tile provider for discovery.
- **Notifications:** push/email; WhatsApp deep links before paid messaging APIs.
- **Payments later:** local provider only after venue partnerships exist.

## Cold-Start Hack

Do not launch a city marketplace. Launch a “rating and balanced-teams night” for one existing badminton, tennis, pickleball, or football group. Coordination is useful with twenty people; national discovery is not.

## Build Slices

1. Group, player, session, check-in, and result schemas.
2. Invite flow and session roster.
3. Bilateral confirmation and rating calculator.
4. Balanced-team suggestions and confidence display.
5. Reliability signals and dispute handling.
6. Venue/payment integrations only after repeat usage.

## Success Measures

- Sessions fill faster than the group’s existing chat workflow.
- Suggested matches are perceived as balanced.
- Result disputes remain rare and resolvable.
- Rating uncertainty falls with genuine play.
- No-show rate decreases.

## Product Path

Start as software for clubs and recurring groups, not a broad consumer network. Paid club administration, tournament tools, and venue software are more reachable than monetizing casual players.

## Related

- [[Event Networking Copilot]]
- [[Quiz Poker]]
- [[Project Ideas Index]]
