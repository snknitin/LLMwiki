---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#14. Yu-Gi-Oh RL Lab]]"
status: concept
difficulty: hard
priority: p3
category: reinforcement learning
form_factor:
  - research environment
  - local dashboard
deployment: DGX Spark
source_ideas:
  - Yu-Gi-Oh reinforcement-learning environment using a GBA ROM
tags:
  - reinforcement-learning
  - card-games
  - simulation
---

# Yu-Gi-Oh RL Lab

> A reproducible card-battler reinforcement-learning laboratory that starts with a small explicit rules engine, then optionally adapts to a user-supplied duel environment after the learning setup is correct.

## Product Outcome

Train and compare random, scripted, search, imitation, and RL agents in a partially observable card game. The key artifacts are a deterministic environment, legal-action masks, replayable trajectories, evaluation leagues, and interpretable strategy diagnostics.

## Personal V0

- Implement an original small card game with deck, hand, board, graveyard, turns, effects, hidden information, and deterministic seed.
- Expose Gymnasium reset/step, observation/action spaces, legal-action mask, and `check_env`.
- Build random and heuristic opponents before neural agents.
- Record full transition/event logs and replay any episode exactly.
- Train a baseline PPO/DQN or policy-gradient agent only after rule tests pass.
- Evaluate against frozen opponents and unseen decks.
- Visualize action distribution, win conditions, and common failure loops.

## Build Boundary

**MVP:** original rules engine, 40–100 local cards, scripted baselines, deterministic replay, and one RL baseline.

**Later:** hierarchical actions, self-play leagues, deck building, imperfect-information search, and an adapter to a local user-provided duel engine/emulator. Do not make ROM control or pixel learning the first dependency; it is slow, opaque, and hard to debug.

## Existing Products, Building Blocks, and Shortcuts

- [Gymnasium](https://gymnasium.farama.org/main/introduction/create_custom_env/) defines the environment API and `check_env`; [Stable-Baselines3](https://github.com/DLR-RM/stable-baselines3) supplies trusted baseline algorithms.
- [RLCard](https://github.com/datamllab/rlcard) is prior art for card-game environments and evaluation, while [EDOPro](https://github.com/edo9300/edopro) is an open duel-simulator implementation that may serve as a later local adapter.
- PyTorch plus vectorized environments is enough until correctness and scripted baselines are strong; DGX Spark becomes useful for parallel self-play.
- Simplest alternative: original 40–100 card rules engine with legal-action masks and deterministic replay. It teaches environment design far faster than pixel control of a GBA emulator.

## Free-First Stack

- **Environment:** Python, Gymnasium, Pydantic/dataclasses, and property-based tests.
- **Training:** PyTorch, Stable-Baselines3 or RLlib.
- **Scale:** vectorized environments locally; DGX Spark only after environment correctness and strong baselines.
- **Tracking:** TensorBoard/Trackio-like local metrics and reproducible config files.
- **Replay UI:** small Gradio/Streamlit viewer or web board.
- **Storage:** Parquet episode summaries plus compressed event logs.

## Clever Hacks and Simpler Alternative

- Begin with tactical subproblems or deck-building objectives before full duels.
- Use hierarchical actions—card, effect, target—and explicit masks.
- Freeze opponent pools to detect overfitting and cycling.
- Report exploitability proxies and performance across seeds, not one training curve.
- Reward only verified outcomes; dense shaping easily teaches stalling or simulator exploits.

## Build Slices

1. Rules/state/event schema and exhaustive unit tests.
2. Gymnasium adapter and random/heuristic baselines.
3. Replay viewer and evaluation harness.
4. Neural baseline and ablations.
5. Self-play league and deck diversity.
6. Optional local external-environment adapter.

## Battle-Testing Gates

- Every episode is deterministic from seed and action log.
- Illegal actions are impossible, not merely penalized.
- Random and heuristic baselines establish sanity bounds.
- Training is evaluated on frozen opponents and held-out seeds/decks.
- Reward hacking cases become regression tests.

## Product Path

The immediate value is learning RL environment design on the DGX Spark. Any public game-specific release requires a separate asset/engine review; the local lab can use user-supplied components without making them part of the project.

## Related

- [[Quiz Poker]]
- [[Live Chess Tutor]]
- [[Neural Fractal Visualizer]]
- [[Project Ideas Index]]
