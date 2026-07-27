---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#2. Marionettist Utopia]]"
status: concept
difficulty: hard
priority: p3
category: social simulation
form_factor:
  - local simulation dashboard
  - optional fictional community
deployment: local-first
source_ideas:
  - fictional-character personalities and hobbies as a bot farm
tags:
  - multi-agent
  - simulation
  - synthetic-media
---

# Marionettist Utopia

> A private synthetic-society sandbox where clearly fictional characters develop interests, relationships, memories, and conversations around the user—without masquerading as real people or operating a deceptive public bot farm.

## Product Outcome

Explore how a cast of persistent characters evolves over time and how different personalities react to the same event. The useful core is a narrative/social simulation engine for games, writing, community testing, or companionship—not fake engagement on real networks.

## Personal V0

- Define 6–12 original characters using goals, traits, boundaries, hobbies, speaking style, and relationship seeds.
- Run a daily simulation tick that selects events and character actions.
- Maintain episodic memory, relationship scores, unresolved threads, and world facts.
- Show a local “social feed” with posts, replies, private messages, and an explanation of why each action occurred.
- Let the user introduce a world event or talk to one character.
- Rewind, fork, and compare simulations from the same checkpoint.

## Build Boundary

**MVP:** local fictional feed, original or public-domain characters, no external account creation, and no autonomous messaging.

**Not allowed as a product default:** impersonation, undisclosed synthetic identities, engagement manipulation, evading platform controls, or using copyrighted character likenesses commercially without rights.

## Existing Products, Building Blocks, and Shortcuts

- [SillyTavern](https://github.com/SillyTavern/SillyTavern) already implements characters, lore, group conversations, TTS, and multiple local model backends; it is the fastest place to test persona differentiation.
- Stanford’s [Generative Agents](https://github.com/joonspk-research/generative_agents) demonstrates memory, reflection, planning, and a Smallville-style environment. Reuse its conceptual split rather than relying on chat history as world state.
- [ActivityPub](https://www.w3.org/TR/activitypub/) provides actors, follows, posts, and inboxes if a transparently synthetic sandbox ever needs a social protocol. It is unnecessary for the local feed.
- Simplest alternative: five editable persona cards, one shared daily world event, deterministic intent/state changes, and one local feed. Generate wording only after the action is selected.

## Free-First Stack

- **UI:** local SvelteKit feed and relationship graph.
- **Engine:** Python event simulator with explicit state transitions.
- **Data:** SQLite for world state and append-only events; graph projection for relationships.
- **Models:** small local model for candidate dialogue; deterministic rules validate continuity, budgets, and safety.
- **Media:** optional local image generation with a consistent-character workflow using original designs.
- **Scheduling:** n8n or a simple cron job for simulation ticks.

## Simulation Design

Separate `intent` from `utterance`. The engine first selects a character goal, target, action type, and world-state effect; the model then renders dialogue. This makes behavior debuggable and prevents prose quality from disguising incoherent state changes.

## Build Slices

1. Character schema and deterministic event loop.
2. Local feed renderer and manual event injection.
3. Memory retrieval and relationship updates.
4. Dialogue generation with continuity tests.
5. Checkpoint, rewind, and branch comparison.
6. Authoring export for stories or game NPCs.

## Success Measures

- Characters remain distinguishable in blind samples.
- World facts and relationships remain consistent across thirty ticks.
- The user can explain an action from visible state, not hidden magic.
- A simulation branch creates reusable story or game material.

## Product Path

The safest products are an NPC engine, writers’ room, synthetic user-research sandbox, or interactive-fiction platform. If any public community mode exists, every synthetic account must be visibly labeled and rate-limited.

## Related

- [[Parallel Presence Companions]]
- [[Motto Agent Council]]
- [[Angel and Demon Companion]]
- [[Project Ideas Index]]
