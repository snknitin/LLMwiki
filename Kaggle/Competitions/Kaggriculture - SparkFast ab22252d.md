---
title: "Kaggriculture - SparkFast Lesson"
kind: "competition"
topics: ""
status: "sparkfast-generated"
updated: "2026-10-20"
minutes: 9
generated_from: "https://www.kaggle.com/competitions/kaggriculture"
model: "qwen3.6-35b-a3b"
job_id: "ab22252d7a0f4a45bc164a3b645576b5"
domain: "RL, games & simulation"
---

# Kaggriculture - SparkFast Lesson

<!-- case-study {"domain": "RL, games & simulation", "metric": "Final bank balance", "data": "Multi-agent grid farm, 30 days, 720 turns, crops/animals/market orders", "validation_trap": "Population drift: routes dominating older submissions fail on newer ones due to faster meta shifts", "solutions": [{"source": "S3", "url": "https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots", "rank_claim": null, "core_idea": "Layered state router grafting public mechanisms", "special": "Demand-preserving turn sale timing", "worked": "96.1% vs top public notebooks, ~3ms/turn CPU", "did_not_work": "Not reported", "cost": "Standard library, ~3 ms per turn CPU"}, {"source": "S4", "url": "https://www.kaggle.com/code/kaitofukami/40-40-early-floor-39-46-top-10-v48-fast-routes", "rank_claim": null, "core_idea": "Sparse route hybrid with execution invariant", "special": "One child policy call per turn", "worked": "40/40 early floor, 39/46 Top-10 holdout", "did_not_work": "Simultaneous 4-child evaluation caused PASS collapse", "cost": "Local replay, zero external packages"}, {"source": "S5", "url": "https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory", "rank_claim": null, "core_idea": "Nearest-route policy memory with order-only front-loading", "special": "Reorder SELL blocks, never change inventory", "worked": "177/180 fresh Top-30 validation", "did_not_work": "Unconditional early SELL prediction collapsed performance", "cost": "Chronological split eval, nearest-neighbor lookup"}], "patterns": [{"idea": "Route anchoring beats reactive heuristics", "sources": ["S4", "S5"]}, {"idea": "Order-only market intervention outperforms quantity changes", "sources": ["S5"]}, {"idea": "Execution safety prevents silent failures", "sources": ["S4"]}, {"idea": "Evaluation uses lineage; deployment stays blind", "sources": ["S5"]}], "steal": ["Order-only market reordering to avoid inventory disruption", "Chronological holdout splits to catch population drift", "One-child-per-turn execution invariant to prevent silent crashes", "Nearest-route signature matching for low-cost adaptation"], "talking_points": ["Top solutions anchor to public routes and only intervene at market steps", "Predicting actions fails; reordering existing orders preserves closed-loop value", "Execution invariants matter more than model complexity in turn-based sims", "Evaluation must be lineage-aware while deployment must remain public-state blind"], "slots_found": 0, "leaderboard": true} -->

Which single resource bottleneck (land, labor, or market timing) would you break first if your agent scored 2800?

## Core idea
You control a multi-agent grid farm over 30 days (720 turns) against hidden opponents. You buy seeds and livestock, water and feed daily, harvest, and sell at a shared market. The metric is final bank balance [S1](https://www.kaggle.com/competitions/kaggriculture). The primary validation trap is population drift: routes that dominate older submissions collapse against newer ones because top teams shift production and sale timing faster than the public queue updates [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).

## Game mechanics and constraints
The environment is a 5x5 grid where each turn represents 15 minutes. Players move farmers, plant crops, water them daily, and manage livestock. Crops like wheat and carrots yield once, while tomatoes and strawberries yield repeatedly for a fixed number of days before decaying into weeds [S1](https://www.kaggle.com/competitions/kaggriculture). Animals such as geese, cows, and sheep produce indefinitely but require daily feeding with wheat. If plants or animals are neglected for two consecutive days, they are lost permanently. Market actions allow players to buy seeds, sell produce, and hire farm hands. The market processes orders simultaneously, meaning timing and order of submission directly impact execution priority [S1](https://www.kaggle.com/competitions/kaggriculture). Labor is the primary constraint: each farmer can only perform one action per turn, forcing players to optimize movement and task assignment across the grid. Land expansion costs increase exponentially, limiting early-game growth.

## Evaluation methodology
Top solutions rely heavily on replaying public trajectories rather than training reactive policies from scratch. Because the environment is deterministic given the same seed and opponent actions, replaying provides a coherent baseline schedule that avoids isolated edits breaking downstream labor [S1](https://www.kaggle.com/competitions/kaggriculture). However, public submissions evolve. A route that wins against older submissions often fails against newer ones because top teams shift production and sale timing. To measure true generalization, authors use chronological splits. Older episodes form the fit-only route pool, while the newest trajectories are reserved for outer validation [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory). This prevents look-ahead bias and ensures the agent adapts to population drift rather than memorizing stale strategies [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory). Lineage is treated as evaluation metadata only; deployment conditions on shops, public farms, prices, inventories, money, step, and internal controller memory [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).

## Market dynamics and timing
[S3](https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots) introduces demand-preserving turn sale timing. The agent routes actions based on public farm signatures and adjusts market submissions to avoid collisions. By preserving the order of sales and only shifting timing, the agent maintains inventory discipline while maximizing execution priority [S3](https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots). This approach contrasts with predicting future SELL quantities, which collapses performance when market conditions shift [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).

## Method comparison
| Source | Representation | Validation | Key Idea | Tradeoff |
|---|---|---|---|---|
| [S3](https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots) | Layered state router + reflexes | Head-to-head vs 10 public notebooks | Demand-preserving turn sale timing | Brittle when meta shifts mid-season |
| [S4](https://www.kaggle.com/code/kaitofukami/40-40-early-floor-39-46-top-10-v48-fast-routes) | Sparse route hybrid | Chronological holdout panels | One child policy call per turn execution | Narrow branching limits novel adaptation |
| [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory) | Nearest-route policy memory | 177/180 fresh Top-30 replay | Order-only front-loading (reorder SELL blocks) | Higher lookup cost; degrades on signature drift |

## Case studies

### [S3](https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots): The 2945 Farm (Thomas Tschinkel) — Rank: Not reported
**What was special**: Grafted public mechanisms into a single-file layered chassis that routes actions based on public farm signatures. The agent uses a state router to decide whether to follow a default production route or intervene at market steps.
**What worked**: 96.1% win rate against top public notebooks over 270 fresh seeds; ~3 ms per turn CPU runtime. The layered architecture allows modular updates without breaking the core loop.
**What did not work**: Not reported.
**Cost to reproduce**: Standard Python library, ~3 ms per turn on CPU.

### [S4](https://www.kaggle.com/code/kaitofukami/40-40-early-floor-39-46-top-10-v48-fast-routes): v48 Fast Routes (Kaito Fukami) — Rank: Not reported
**What was special**: Enforced execution invariant: exactly one selected child policy per turn. The previous version evaluated four complete stateful children simultaneously, which caused silent PASS collapse under timing pressure.
**What worked**: 40/40 win rate on early floor; 39/46 on Top-10 holdout in local replay. The invariant prevents comprehension-level crashes and ensures every turn produces a non-PASS action.
**What did not work**: Simultaneous evaluation of multiple children, which consumed too much compute and introduced race conditions.
**Cost to reproduce**: Local replay against frozen action streams; zero external packages.

### [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory): v21.1 Conditional Memory (Kaito Fukami) — Rank: Not reported
**What was special**: Nearest-route memory that predicts market collisions and adjusts SELL order only, never inventory. The agent calculates a distance metric between the current public state and 30 fit-only route prototypes, then reorders market blocks to avoid collisions.
**What worked**: 177/180 validation on fresh Top-30 trajectories in local replay; recovered from route drift by swapping to current medoids. The order-only constraint preserves inventory discipline while improving market execution.
**What did not work**: Unconditional early SELL prediction, which caused ~28 preemptions per game and collapsed performance. Predicting an action does not establish closed-loop value.
**Cost to reproduce**: Chronological split evaluation; nearest-neighbor signature matching over public farm states.

## Patterns across the winners
1. Route-based planning beats reactive heuristics. Winners anchor to a complete public trajectory and only intervene at market steps [S4](https://www.kaggle.com/code/kaitofukami/40-40-early-floor-39-46-top-10-v48-fast-routes).
2. Order-only market intervention outperforms quantity/inventory changes. Predicting actions does not establish closed-loop value; reordering existing blocks does [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).
3. Execution safety prevents silent failures. Restricting to one child call per turn eliminates comprehension-level crashes [S4](https://www.kaggle.com/code/kaitofukami/40-40-early-floor-39-46-top-10-v48-fast-routes).
4. Evaluation must be lineage-aware but deployment must be blind. Team/seed folds leak; route extraction uses lineage only for evaluation metadata [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).

## Interview questions
1. **Design choice**: Why do top solutions use route replay instead of training a reactive policy from scratch?
<details><summary>Show answer</summary>

Routes provide a coherent full schedule that avoids isolated edits breaking downstream labor [S1](https://www.kaggle.com/competitions/kaggriculture). Reactive policies optimize locally and often water/feed inefficiently, while routes guarantee structural feasibility and free compute for market timing [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).

</details>

2. **Validation**: How do you handle population drift when your validation set becomes stale?
<details><summary>Show answer</summary>

Split submissions chronologically. Use older episodes for route selection and reserve the newest trajectories for outer validation. Refresh medoids when win rates drop below 70% on holdout panels [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).

</details>

3. **Failure analysis**: Why did early SELL prediction collapse performance?
<details><summary>Show answer</summary>

Predicting an action does not establish closed-loop value. Premature SELLs displaced higher-value orders and caused collision losses. Restricting to order-only front-loading preserved inventory discipline [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).

</details>

4. **Tradeoff**: When would you choose nearest-route memory over a full replay engine?
<details><summary>Show answer</summary>

When compute is constrained. Nearest-route memory uses lightweight signature matching (labor/unlocks/production counts) instead of full state simulation, cutting latency while preserving route compatibility [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).

</details>

5. **Budget**: How would you compete if you only had 10% of the top teams' evaluation budget?
<details><summary>Show answer</summary>

Freeze a single high-performing route, run 50 head-to-head replays instead of 180, and focus ablation on market timing thresholds. Skip identity-based features; they leak and add no runtime value [S3](https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots)[S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory).

</details>

## 20-minute controlled experiment
1. **Baseline**: Run a standard route replay agent on 10 frozen games. Record final margin and number of child policy calls per turn.
2. **Change**: Replace the multi-child evaluation loop with a single deterministic child selector that picks the first compatible child per turn.
3. **Expected artifact**: `main.py` with a `select_child(state)` function that returns exactly one policy path.
4. **Checks**: Verify that `len(policy_calls) == len(child_calls) == 719` for every turn. Ensure no SELL quantities changed across the season. If margin improves by >2%, lock the reorder logic; if not, revert and note the collision point.
5. **Validation**: Run the modified agent against a fresh Top-10 holdout. Record win rate and margin distribution. Compare against baseline to confirm execution invariant holds.

## Agent assignment
- **Inputs**: 30-day public action stream, current market price table, inventory shed state.
- **Constrained task**: Implement the order-only front-loading rule. Change only SELL block order; zero inventory or quantity modifications.
- **Expected artifact**: `main.py` with a single `reorder_sells(route_sells, prices)` function and 719 policy calls.
- **Human verification**: Check that `len(policy_calls) == len(child_calls) == 719` and that no SELL quantity changed across the season.
- **Audit trail**: Log every market order submission with a timestamp and priority score. Verify that high-value items are submitted first when collision risk is detected.

## Transfer question
How would you adapt the nearest-route memory approach to a stock trading environment where order book depth changes rapidly?
<details><summary>Show hint</summary>

Map public farm signatures to historical order book snapshots. Use chronological splits to prevent look-ahead bias in liquidity metrics.

</details>

## Recall question
What single constraint did the top solutions enforce to prevent silent PASS collapse?
<details><summary>Show answer</summary>

Exactly one child policy call per turn.

</details>

## 10-rank source-coverage table
| Rank | Team | Score | Source Coverage | Validation Method |
|---|---|---|---|---|
| 1 | M & M & P & Q | 5890.3 | Not reported | Unstated |
| 2 | Victor @ Tufa Labs | 5823.4 | Not reported | Unstated |
| 3 | DSM | 5580.3 | Not reported | Unstated |
| 4 | Farmcore | 5487.4 | Not reported | Unstated |
| 5 | 有辣条有权 | 5473.7 | Not reported | Unstated |
| 6 | CDE | 5465.0 | Not reported | Unstated |
| 7 | DECEM | 5459.9 | Not reported | Unstated |
| 8 | itwastony | 5395.7 | Not reported | Unstated |
| 9 | tetsuya & yuanzhe & guoqin | 5338.7 | Not reported | Unstated |
| 10 | KawattaTaido | 5334.0 | Not reported | Unstated |

Self-reported rank claims vs independently checked final standings:
[S3](https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots), [S4](https://www.kaggle.com/code/kaitofukami/40-40-early-floor-39-46-top-10-v48-fast-routes), and [S5](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory) authors report local replay win rates and ladder scores. These are not independently checked final standings. The final leaderboard scores are sourced from the official Kaggle API [S6](https://www.kaggle.com/competitions/kaggriculture/leaderboard).

## Ten-rank source coverage

Teams and ranks come from Kaggle's leaderboard API (the private leaderboard when available). A writeup is linked to a team only when exactly one top-10 team name appears in its text; otherwise the rank its URL claims is shown as a clue. Check before quoting. A missing slot means no matching readable source was collected, not that no solution exists.

| Rank | Team (Kaggle leaderboard) | Collected source | How it was linked |
|---|---|---|---|
| 1 | M & M & P & Q | Not found in this run | — |
| 2 | Victor @ Tufa Labs | Not found in this run | — |
| 3 | DSM | Not found in this run | — |
| 4 | Farmcore | Not found in this run | — |
| 5 | 有辣条有权 | Not found in this run | — |
| 6 | CDE | Not found in this run | — |
| 7 | DECEM | Not found in this run | — |
| 8 | itwastony | Not found in this run | — |
| 9 | tetsuya & yuanzhe & guoqin | Not found in this run | — |
| 10 | KawattaTaido | Not found in this run | — |


## Top-voted solution notebooks

Found through Kaggle's API, sorted by votes. Votes measure popularity, not correctness: check the validation before reusing any code.

| Notebook | Author | Votes | Last run | Used in this lesson |
|---|---|---|---|---|
| [The 2945 Farm: 96% vs the Top-10 Public Bots](https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots) | Thomas Tschinkel | 162 | 2026-09-19 | Yes [S3] |
| [40/40 Early Floor / 39/46 Top-10 / v48 Fast Routes](https://www.kaggle.com/code/kaitofukami/40-40-early-floor-39-46-top-10-v48-fast-routes) | Kaito Fukami | 139 | 2026-08-24 | Yes [S4] |
| [177/180 Fresh Top-30 / v21.1 Conditional Memory](https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory) | Kaito Fukami | 107 | 2026-08-06 | Yes [S5] |


## Source reading receipt

Generated on 2026-10-20T02:32:21.948945+00:00 with Hermes **qwen3.6-35b-a3b**, followed by a second SparkFast review. This is AI-generated teaching, not independently verified research or executed experiment results.

- [S1] Read: first 9000 characters only: https://www.kaggle.com/competitions/kaggriculture
- [S2] Unavailable — not used: https://www.kaggle.com/competitions/kaggriculture/writeups
- [S3] Read: first 9000 characters only: https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots
- [S4] Read: first 9000 characters only: https://www.kaggle.com/code/kaitofukami/40-40-early-floor-39-46-top-10-v48-fast-routes
- [S5] Read: first 9000 characters only: https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory
- [S6] Read captured text: https://www.kaggle.com/competitions/kaggriculture/leaderboard

[S1]: https://www.kaggle.com/competitions/kaggriculture
[S3]: https://www.kaggle.com/code/thomastschinkel/the-2945-farm-96-vs-the-top-10-public-bots
[S4]: https://www.kaggle.com/code/kaitofukami/40-40-early-floor-39-46-top-10-v48-fast-routes
[S5]: https://www.kaggle.com/code/kaitofukami/177-180-fresh-top-30-v21-1-conditional-memory
[S6]: https://www.kaggle.com/competitions/kaggriculture/leaderboard
