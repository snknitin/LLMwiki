---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Expert Mode and Tiny Model Game Lab#2. Tiny Model Game Lab]]"
status: concept
difficulty: hard
priority: p2
category: small language model reasoning research
form_factor:
  - reproducible research lab
  - model training pipeline
  - local evaluation dashboard
deployment: desktop workstation then DGX Spark
source_ideas:
  - improve a roughly 0.2B parameter model at Wordle until the complete system approaches strong solvers
  - progress to harder games to learn where search verifiers tools data and training create the most capability
tags:
  - tiny-models
  - wordle
  - reinforcement-learning
  - distillation
  - search
  - evaluation
---

# Tiny Model Game Lab

> Turn a roughly 0.2B-parameter language model into the controller of a brutally measured game-solving system, beginning with Wordle and escalating through environments that isolate constraint reasoning, information gain, planning, partial observability, and long-horizon tool use.

## Product Outcome

Build a reproducible laboratory that answers a more valuable question than “can a tiny model play Wordle?”: **where does capability actually come from when parameters are scarce?** The lab compares prompting, constrained decoding, deterministic tools, search, teacher trajectories, supervised fine-tuning, preference or reinforcement learning, and environment curricula under a fixed inference and training budget.

The first target is near-best **system performance** on a pinned Wordle ruleset and lexicon while a 135M–270M model owns the policy interface. The benchmark must separately report:

- **Model-only:** the model sees textual history and emits a guess without solver tools.
- **Constrained model:** invalid words and rule-inconsistent guesses are masked or rejected.
- **Tool-augmented model:** the model calls candidate filtering, scoring, entropy, and verifier functions.
- **Distilled policy:** the model imitates strong solver trajectories but does not call the full solver at inference.
- **Classical ceiling:** deterministic entropy/minimax/search baselines establish what “state of the art” means for the exact word list.

This distinction prevents a misleading result where a perfect classical solver is hidden behind a tiny model and the model gets credit. Both achievements are useful, but they teach different lessons.

## Research Questions

1. How much does exact state representation improve a tiny model before any weight update?
2. Can a model learn to choose among a small ranked candidate set more efficiently than generating arbitrary words?
3. Which teacher signal transfers best: optimal next move, ranked moves, information gain, remaining candidate count, or full trajectory?
4. Does supervised distillation capture the policy well enough to remove expensive tools at inference?
5. When does online RL/GRPO improve generalization rather than memorize a finite lexicon?
6. Which capabilities transfer from Wordle to Mastermind, Twenty Questions, logic grids, adversarial board games, and partially observable games?
7. What is the Pareto frontier among solve rate, worst-case moves, latency, tool calls, model size, training compute, and out-of-distribution performance?

## Personal V0

- Pin one target-word list, one allowed-guess list, exact duplicate-letter rules, normal/hard modes, and a versioned evaluation seed set.
- Implement a pure deterministic environment with exhaustive unit and property tests.
- Build random, frequency, positional-frequency, entropy, expected-remaining-candidates, minimax, and cached decision-tree baselines before involving a model.
- Benchmark an unmodified [SmolLM2-135M](https://huggingface.co/HuggingFaceTB/SmolLM2-135M) and [Gemma 3 270M](https://huggingface.co/google/gemma-3-270m-it) candidate under identical prompts and decoding limits; use 360M or 0.6B only as scaling controls.
- Add structured output and legal-action validation, then expose one tool at a time: `filter_candidates`, `score_feedback`, `rank_guesses`, and `verify_guess`.
- Generate teacher trajectories from the strongest deterministic solver and fine-tune the tiny model first with supervised learning or LoRA.
- Run RL only after the environment, baselines, splits, and reward-hacking tests are stable.
- Publish a local scorecard that makes every advantage and external computation visible.

## Build Boundary

**MVP:** Wordle-compatible original environment; pinned public/user-supplied word lists; deterministic baselines; two tiny-model baselines; constrained/tool-augmented variants; trajectory dataset; one supervised adapter; and a reproducible evaluation report.

**Later:** GRPO or another online method, curriculum transfer, multi-game environment interface, policy distillation, interpretability probes, automated ablations, and DGX Spark sweeps.

Do not begin by pretraining a 0.2B model from scratch. Start with an existing 135M–270M checkpoint and learn whether the bottleneck is representation, action validity, data, search, or optimization. Pretraining becomes justified only if tokenizer, vocabulary, or architecture ablations are themselves the research question.

## Existing Products, Building Blocks, and Shortcuts

- [SmolLM2-135M](https://huggingface.co/HuggingFaceTB/SmolLM2-135M) is an Apache-2.0, 135M-class baseline with official Transformers support; its published general reasoning scores make clear that raw zero-shot capability is limited, which is useful for measuring genuine gains.
- [Gemma 3 270M](https://huggingface.co/google/gemma-3-270m-it) is a close size-class alternative with a 32K context window and official evaluation table; its terms differ from Apache-licensed SmolLM, but that should not change the personal experiment's technical design.
- [MobileLLM](https://github.com/facebookresearch/mobilellm) provides Meta's released sub-billion architecture/training code with a 125M comparison point, while [Pythia-160M](https://huggingface.co/EleutherAI/pythia-160m) is a useful research-oriented base-model control. Neither should displace the easier instruction-tuned V0 candidates unless the experiment specifically studies architecture or learning curves.
- Hugging Face [TRL's environment-based GRPO interface](https://huggingface.co/docs/trl/main/grpo_trainer) supports stateful environments and environment-owned rewards. Its official Wordle/OpenEnv example is prior art, but it notes improvement at the 1B scale rather than proving the same recipe works at 0.2B.
- [PEFT/LoRA](https://huggingface.co/docs/peft/main/conceptual_guides/lora) trains small adapters while freezing base weights; full fine-tuning is also feasible at this model size and should remain an explicit comparison.
- [TextArena](https://github.com/TextArena/TextArena) and [Microsoft TextWorld](https://github.com/microsoft/TextWorld) provide patterns and environments for text-game evaluation and escalation beyond Wordle.
- The official code for [Implicit Language Q-Learning](https://github.com/Sea-Snell/Implicit-Language-Q-Learning) contains a gym-like Wordle environment, policies, word lists, and offline datasets; treat its older word list and state assumptions as prior art, not an unquestioned benchmark.
- [deedy/wordle-solver](https://github.com/deedy/wordle-solver) demonstrates exhaustive deterministic evaluation and a cached solution tree. Its reported results are tied to a specific pre-NYT lexicon, so reproduce rather than compare headline numbers across mismatched dictionaries.
- Bertsimas and Paskov's [exact dynamic-programming analysis](https://doi.org/10.1287/opre.2022.0434) reports a `SALET` opening, 3.421 expected guesses, and a five-guess worst case for one precisely defined 2,315-solution benchmark. Treat it as a ceiling for that manifest—not a universal current-Wordle record.
- [lm-evaluation-harness](https://github.com/EleutherAI/lm-evaluation-harness) and Hugging Face [Lighteval](https://github.com/huggingface/lighteval) can track whether game specialization damages ordinary language capabilities. Lighteval's own repository says Windows is untested, so run it in WSL2 or on the Linux DGX Spark rather than making native Windows support a V0 dependency.

## Recommended Free-First Stack

- **Environment:** Python 3.12, dataclasses/Pydantic, NumPy, Gymnasium-style `reset/step`, pytest, and Hypothesis for duplicate-letter and state-transition properties.
- **Solvers:** pure Python/NumPy for exhaustive baselines; optional Rust only after profiling proves the Python implementation blocks experiments.
- **Models:** Transformers, PyTorch, Accelerate, SmolLM2-135M, Gemma 3 270M, and SmolLM2-360M/Qwen3-0.6B as bracket controls.
- **Training:** TRL `SFTTrainer` first; PEFT adapters and full fine-tuning as measured alternatives; environment-based GRPO only after supervised and tool-use baselines.
- **Constrained actions:** explicit candidate IDs or a `choose_guess(index)` tool are more reliable than unconstrained generation; Outlines/JSON Schema can enforce the protocol but cannot enforce strategy.
- **Data:** versioned JSONL trajectories, Parquet episode summaries, immutable run manifests, and content hashes for word lists, prompts, code, model, adapter, and solver.
- **Tracking:** local MLflow, Trackio, TensorBoard, or plain Parquet plus a generated Markdown report; do not make a hosted tracker mandatory.
- **Interface:** CLI batch runner first, then a small Gradio/Streamlit replay and comparison dashboard.
- **Compute:** CPU for exhaustive environment tests and classical baselines; desktop GPU for tiny-model SFT/LoRA; DGX Spark for controlled sweeps or multi-game training, not for the first proof.

## Architecture and Data Model

`GameDefinition` pins rules, observation schema, action schema, lexicon/version, maximum turns, and reward semantics. `EpisodeState` stores target ID, history, candidate set hash, legal actions, seed, and terminal status. `PolicyVariant` declares model checkpoint, prompt, tools, decoding, adapter, and whether deterministic solver output is visible. `TrajectoryStep` records observation, legal actions, selected action, feedback, teacher scores, model log-probability, tool calls, latency, and violations. `RunManifest` records code commit, environment hash, data splits, hardware, package lock, model and adapter hashes, random seeds, and evaluation budget. `Scorecard` stores solve rate, average/worst moves, invalid actions, constraint violations, regret against the classical baseline, latency, tokens, tool calls, and energy/compute proxy.

The environment—not the model—owns rule truth, legality, termination, and reward. Every policy receives the same serialized state and budget. Evaluation targets must never appear in fine-tuning trajectories under another identifier.

## Baseline and Ablation Ladder

1. Random valid guess.
2. Letter and positional-frequency heuristic.
3. Entropy or expected partition-size policy.
4. Minimax/worst-partition policy.
5. Cached exact or rollout-enhanced policy where tractable.
6. Tiny model, raw textual history, unconstrained generation.
7. Tiny model with structured state and valid-word rejection.
8. Tiny model selecting from a deterministic top-k proposal set.
9. Tiny model calling candidate/entropy tools.
10. SFT/LoRA on teacher actions and ranked alternatives.
11. Full fine-tune at the same data/compute budget.
12. Online RL/GRPO with held-out lexicons and reward-hacking probes.

Each rung changes one important variable. If tool augmentation closes the gap, that is the result; do not automatically spend days on RL to produce a less interpretable system.

## Game Curriculum Beyond Wordle

| Stage | Environment | Capability isolated | Why it is harder |
|---|---|---|---|
| 1 | Mastermind / Bulls and Cows | constraint propagation and information gain | symbols are abstract and variants can scale code length/alphabet |
| 2 | Game of 24 | arithmetic composition and bounded search | actions form expression trees, but every proposal remains exactly executable |
| 3 | Sudoku, KenKen, logic grids | multi-step constraint satisfaction | state is larger and invalid early commitments propagate |
| 4 | Twenty Questions | adaptive question selection | the action space is generated language, not a fixed list |
| 5 | Connect Four and small chess endgames | adversarial search and opponent modelling | a good move depends on future counterplay |
| 6 | Kuhn/Leduc poker or Hanabi-like microgames | belief state and partial observability | optimal play requires uncertainty and information management |
| 7 | TextWorld/Sokoban-style tasks | long-horizon planning and memory | sparse reward, irreversible actions, and compositional instructions |
| 8 | Negotiation or social-deduction microgames | language strategy and other-agent models | rewards can be non-stationary and evaluation is less deterministic |

Do not move to the next stage until the previous environment has an exact or strong non-neural baseline, leakage-resistant splits, and a replayable failure taxonomy. Transfer evaluation should keep the same model interface while replacing the game-specific tools, exposing whether the policy learned a reusable method or memorized tool names.

## Build Slices

1. Wordle rules, duplicate-letter oracle, word-list versioning, and exhaustive environment tests.
2. Classical baselines, decision-tree cache, replay format, and evaluation splits.
3. Model-only and constrained-action 135M/270M baselines with fixed inference budgets.
4. Tool protocol and one-tool-at-a-time ablations.
5. Teacher trajectory generator, SFT/LoRA, and held-out-word evaluation.
6. Full fine-tune and scaling controls; ordinary-language regression suite.
7. GRPO experiment with verified rewards and adversarial exploit tests.
8. Mastermind transfer environment, then Game of 24, one adversarial game, and one partially observable game.
9. Local dashboard showing score, regret, compute, trajectory, and failure clusters.

## Drawbacks, Concerns, and Failure Modes

- **Fake SOTA:** word lists, hard-mode rules, answer priors, and allowed guesses change results dramatically. Define the benchmark before making comparisons.
- **Solver smuggling:** if a tool returns the best move, the model is a router. Report this honestly and add weaker-tool ablations.
- **Finite-game memorization:** Wordle's target space is small. Hold out targets, use alternate lexicons and lengths, and test transfer to procedural variants.
- **Reward hacking:** the policy may exploit parser bugs, invalid outputs, retries, information leakage, or episode termination. Convert every exploit into a regression test.
- **Duplicate-letter bugs:** naive yellow/green scoring is often wrong. Exhaustively compare the optimized implementation with a slow reference oracle.
- **Teacher ceiling:** imitation cannot reliably outperform a flawed teacher. Store multiple teacher scores and measure regret.
- **RL instability:** sparse rewards, tiny policies, and small finite environments can produce collapse or memorization. Start with SFT and dense verified auxiliary signals, but keep final success reward dominant.
- **Tokenizer mismatch:** five-letter words may fragment unpredictably. Compare text generation with candidate-index selection and byte/character representations.
- **Capability regression:** aggressive specialization can damage ordinary instruction following. Run a small frozen language-evaluation suite after every adapter or checkpoint.
- **Compute theatre:** a tiny model can still waste large training budgets. Track wall time, samples, tokens, and energy proxy alongside score.

## Clever Hacks and Simpler Alternative

- Make the model select a candidate index from a ranked list; this isolates strategic choice from spelling and tokenizer failure.
- Distill **rankings and regret**, not only the teacher's single action, so the model learns which alternatives are nearly equivalent.
- Randomize word IDs and tool names during training to detect interface memorization.
- Train on procedural Wordle variants—word length, alphabet, answer-set size—then evaluate on the canonical game.
- Use exact solver values as a critic or auxiliary target while preserving final win/move reward.
- Cache deterministic tool results by state hash; most Wordle computation repeats across runs.
- Maintain a “capability accounting” table that credits the base model, prompt, constraints, tools, search, training, and test-time compute separately.
- Simplest alternative: skip fine-tuning and wrap the 135M model around a deterministic entropy solver as an explainer. This will likely reach strong game performance fastest and provides the baseline that any learned policy must justify beating.

## Success Measures

- 100% rule-oracle agreement on exhaustive and adversarial duplicate-letter fixtures.
- Reproducible results across machines from a pinned manifest and seed set.
- Solve rate, average guesses, worst-case guesses, and regret reported against strong classical baselines on the identical lexicon.
- Zero invalid actions and zero hidden state leakage in the constrained system.
- A clear ablation showing the marginal contribution of state representation, constraints, each tool, SFT, and RL.
- The 135M–270M policy closes a defined fraction of the gap between its raw baseline and the classical ceiling without exceeding the fixed inference budget.
- Performance holds on unseen targets, procedural variants, and at least one new game family.
- Specialized checkpoints retain acceptable instruction/language performance on a frozen regression suite.
- Experiment cost remains low enough to repeat failures instead of showcasing one lucky run.

## Product Path

Personal Wordle lab -> open reproducible tiny-model benchmark -> multi-game curriculum and leaderboard -> educational model-training workbench -> specialized on-device agent research toolkit. Keep the same local training stack for the personal build; apply [[Scope Expansion Checklist]] before redistributing third-party word lists, game assets, checkpoints with special terms, hosted evaluation submissions, or public claims of state-of-the-art performance.

## Related

- [[Yu-Gi-Oh RL Lab]]
- [[Live Chess Tutor]]
- [[Quiz Poker]]
- [[LeetCode Pattern Curriculum]]
- [[Neural Fractal Visualizer]]
- [[Project Ideas Index]]
