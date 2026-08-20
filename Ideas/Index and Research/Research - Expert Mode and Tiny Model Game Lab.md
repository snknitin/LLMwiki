---
type: research-note
status: active
created: 2026-08-15
scope: expert-conversation-and-tiny-model-games
tags:
  - research
  - local-first
  - skill-design
  - retrieval
  - small-language-models
  - reasoning
  - reinforcement-learning
---

# Research - Expert Mode and Tiny Model Game Lab

This dossier turns two rough ideas into technically honest, testable projects. The first should make an assistant sound and behave like a well-prepared domain operator without pretending that fluency equals expertise. The second should use Wordle as a controlled laboratory for discovering how much performance can be extracted from a roughly 0.2B-parameter model through state representation, deterministic tools, search, verifiers, curriculum, distillation, and reinforcement learning. All factual references below lead to original papers, official documentation, first-party model cards, or source repositories.

## 1. Expert Lens Skill

### Refined concept

Build a local skill that rapidly constructs an **evidence-grounded expert lens** for the domain in the current conversation. It should identify the relevant subdomain, retrieve its authoritative vocabulary and operating model, ask the few questions that would change the diagnosis or decision, and then answer at the register of an experienced practitioner. It must never manufacture insider knowledge merely to sound impressive.

The useful promise is:

> Give me the concepts, distinctions, decision criteria, failure modes, and questions that a serious practitioner would use here, with sources and calibrated uncertainty.

The wrong promise is “be an expert in everything.” An assistant can be rhetorically convincing while being wrong. The product therefore needs two visibly separate qualities:

- **epistemic quality:** factual support, correct distinctions, current sources, explicit unknowns, and appropriate abstention;
- **professional register:** precise terminology, realistic artifacts and workflows, correct units and denominators, awareness of edge cases, and high-value questions.

The skill should be impressive because it finds the hidden decision boundary, not because it sprays jargon. A senior practitioner often reveals expertise by asking “which definition are we using?”, “what is the source of truth?”, “what changes the decision?”, “what happens on the exception path?”, or “what evidence would falsify this?” before offering a polished answer.

### Product modes and output contract

The same engine can expose five modes while keeping one evidence and vocabulary layer:

1. **Orient me:** explain the landscape, canonical concepts, actors, artifacts, metrics, and current disputes.
2. **Help me ask:** generate questions for an expert interview, meeting, vendor call, review, or diagnosis.
3. **Answer as a practitioner:** produce a recommendation using the domain's actual decision model and terminology.
4. **Challenge this:** audit a plan for novice assumptions, missing variables, invalid comparisons, or terminology misuse.
5. **Translate registers:** convert between beginner, practitioner, executive, regulator, researcher, and implementation language without changing the underlying claim.

Each response should have a structured internal record even if the visible answer is concise:

```yaml
domain_path: [domain, field, specialty, task]
user_goal: decision | diagnosis | learning | preparation | critique
known_context: []
material_unknowns: []
questions:
  - text: "..."
    decision_branch: "What changes when this answer changes"
    expected_information_gain: high | medium | low
glossary_terms_used:
  - term: "..."
    meaning_here: "..."
    source_id: "..."
claims:
  - statement: "..."
    status: sourced | inference | hypothesis | user-provided
    source_ids: []
confidence: 0.0
abstain_or_escalate: false
```

The user-facing response should normally ask no more than one to three material questions before giving a provisional answer with named assumptions. Long interrogations feel expert but delay value.

### Architecture: compile a temporary domain lens

Treat every request as a small domain-compilation job rather than a single prompt:

1. **Intent and stakes classifier** determines the job, audience, time horizon, reversibility, and whether fresh or primary evidence is required.
2. **Domain router** assigns a path such as `finance / fixed income / portfolio risk / duration exposure`, not merely `finance`. OpenAlex exposes a four-level research hierarchy of domain, field, subfield, and topic through its official [Topics API](https://developers.openalex.org/api-reference/topics/list-topics); it is a useful scholarly seed rather than a universal ontology.
3. **Authority resolver** chooses the right source class: standards body, regulator, official manual, protocol/specification, original paper, source repository, vendor documentation, or user-supplied operating documents. Search results and commentary are discovery aids, not automatic authorities.
4. **Domain-pack loader** retrieves a compact, versioned pack containing a taxonomy, glossary, artifacts, roles, metrics, common confusions, diagnostic questions, failure modes, canonical sources, and freshness policy.
5. **Question planner** chooses the unknown whose answer would most change the conclusion. It generates a question card containing the question, why it matters, likely answer types, and downstream branch.
6. **Evidence retriever** combines exact lexical retrieval for acronyms, clauses, standards, model numbers, and equations with semantic retrieval for conceptual matches. Qdrant's official [hybrid-search documentation](https://qdrant.tech/documentation/search/text-search/hybrid-search/) describes dense-plus-sparse retrieval and fusion; for a small private corpus, SQLite FTS5 may be enough.
7. **Answer planner** creates claims, sources, inferences, caveats, and a terminology budget before generating prose.
8. **Jargon and claim gate** rejects undefined acronyms, unsupported numerical claims, fake terms, anachronistic terminology, and words used outside the scope defined by their source.
9. **Calibrator** converts evidence coverage and test-set performance into a confidence band; it must not accept the model's verbal confidence uncritically.
10. **Learning loop** stores corrected terms, accepted questions, source changes, and expert feedback as versioned domain-pack changes rather than silently rewriting a persona.

This resembles source-grounded research products but has a different interaction goal. Google's first-party description of [NotebookLM](https://blog.google/innovation-and-ai/technology/ai/notebooklm-google-ai/) emphasizes answers grounded in user-selected sources with citations and relevant passages. OpenAI's current [deep research documentation](https://help.openai.com/en/articles/10500283-deep-research) exposes source selection, a reviewable plan, progress, interruption, and a cited report. Borrow their provenance and controllability patterns; add the domain model and question-value layer they do not promise.

### The domain-pack schema

A reusable domain pack should be small enough for a human to inspect and should not be a pasted encyclopedia. Use a lightweight concept scheme inspired by the W3C [SKOS Recommendation](https://www.w3.org/TR/skos-reference/), which defines preferred, alternate, and hidden labels plus broader, narrower, and related concept relationships.

Recommended records:

- `concepts`: preferred term, alternate labels, exact definition, scope note, examples, non-examples, broader/narrower/related concepts, source, valid-from date, and review date;
- `distinctions`: commonly conflated pairs and the consequence of confusing them;
- `artifacts`: the documents, dashboards, models, approvals, logs, tests, or outputs practitioners actually exchange;
- `roles_and_decision_rights`: who proposes, approves, operates, reviews, and owns exceptions;
- `metrics`: numerator, denominator, unit, grain, sampling window, exclusions, leading/lagging status, and failure modes;
- `workflows`: happy path, exception path, escalation triggers, and irreversible steps;
- `question_cards`: trigger, exact question, why it matters, possible answers, branch effect, and supporting source;
- `failure_patterns`: novice tell, expert concern, detection signal, and mitigation;
- `source_registry`: authority class, canonical URL, version, publication date, retrieval date, jurisdiction/product version, and supersession relationship;
- `forbidden_shortcuts`: phrases or recommendations the skill may not use without specific evidence.

OpenAlex can seed research-domain names and current papers; the [Wikidata Query Service](https://www.wikidata.org/wiki/Help%3ASPARQL) can supply broad entity relationships through SPARQL. Neither should define professional truth by itself. For a medical pack, official guidelines and primary evidence should own clinical claims; for a software pack, protocol specifications and the actual version's documentation should own behavior; for law, jurisdiction and controlling authority must be explicit; for finance, definitions, valuation date, currency, accounting basis, and data vendor need to be named.

### Generating questions that feel genuinely expert

Use the **Critical Decision Method** as a better inspiration than generic Socratic prompting. The original case study describes a cognitive-task-analysis method based on multiple-pass retrospection and probe questions that can produce timelines, situation-assessment records, and decision requirements ([Hoffman, Crandall, and Shadbolt, 1998](https://doi.org/10.1518/001872098779480442)). Convert that idea into six deterministic probe families:

1. **Definition probe:** Which operational definition, unit, jurisdiction, accounting treatment, protocol version, or population is in force?
2. **Cue and anomaly probe:** What early signal would an experienced operator notice, and what would make this case atypical?
3. **Decision-point probe:** Where did or will the course of action become hard to reverse? What alternatives were still live then?
4. **Trade-off probe:** Which objective is actually being optimized, what is the constraint, and who bears the externality?
5. **Counterfactual probe:** What single changed fact would reverse the recommendation?
6. **Exception and escalation probe:** What fails outside the happy path, who owns it, and what threshold triggers escalation?

Domain packs then specialize these families. Examples of the *shape* of good questions include:

- software reliability: “Is this availability target measured at the service boundary or per dependency, and how is the error budget consumed during partial degradation?”
- analytics: “What is the row grain, denominator, cohort entry rule, and late-arriving-data policy?”
- finance: “Are we comparing booked ARR, recognized revenue, contracted ACV, cash collection, or economic value, and on what valuation date?”
- medicine: “What is the pre-test probability, what result would change management, and which contraindication or red flag dominates?”
- law: “Which jurisdiction, procedural posture, controlling authority, and standard of review govern this question?”
- machine learning: “Where can train-test contamination enter, what is the unassisted baseline, and which ablation would isolate the claimed gain?”

These are templates, not claims that the assistant knows a case. A term may only appear in a final response when the active pack defines it or a retrieved authority supports it. When a user supplies an unfamiliar term, the skill should ask whether it is organization-specific rather than inventing a definition.

### Retrieval and evidence policy

Start with SQLite tables plus [FTS5](https://www.sqlite.org/fts5.html). Exact term lookup matters disproportionately because expert conversations contain identifiers, clauses, acronyms, units, abbreviations, and near-synonyms that dense-only retrieval can blur. Add a local embedding model and Qdrant hybrid retrieval only when the corpus or measured recall justifies another service. ColBERTv2's original paper is a useful later-stage reference for token-level late-interaction retrieval and reports a 6–10x footprint reduction over earlier late-interaction designs while retaining strong retrieval quality ([Santhanam et al., 2021](https://arxiv.org/abs/2112.01488)).

Every generated claim should be labeled as one of:

- directly supported by a source passage;
- derived from multiple supported facts;
- a recommendation based on declared preferences;
- a hypothesis needing confirmation;
- user-provided context;
- unknown or outside the pack.

Do not cite a whole document when only a heading or search snippet was seen. Save the supporting passage, section, version, and retrieval timestamp. For changing domains, compute freshness per source class: a mathematical definition can be stable; a product limit, law, standard, market figure, or model capability may require a current check.

### Free-first local stack

Use Python 3.12, Typer, Pydantic, SQLite/FTS5, Markdown/YAML domain packs, and a model adapter that accepts any OpenAI-compatible or local endpoint. [llama.cpp](https://github.com/ggml-org/llama.cpp) provides local inference across GGUF models, while [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) can constrain internal records to a JSON schema. Keep retrieval, source-policy enforcement, question ranking, and claim validation outside the model.

A practical folder layout is:

```text
expert-lens/
  packs/
    software-reliability/
      pack.yaml
      glossary.yaml
      questions.yaml
      sources.yaml
      evals/
  src/
    route.py
    retrieve.py
    question_ranker.py
    claim_gate.py
    render.py
  data/expert_lens.sqlite
  tests/
```

The fastest prototype needs no vector database and no agent framework. Build one excellent pack for a domain the owner already understands, use FTS5 plus a capable local model, and collect corrections. A large multi-agent research system before the first pack is evaluated would hide whether the core method works.

### Clever shortcuts

- **Compile before conversation:** generate a one-page “field card” once per domain with terms, artifacts, decisions, exceptions, and sources. Most turns can retrieve this card instead of repeating broad research.
- **Use distinction cards:** experts often differ from novices by preserving distinctions. A table of `X is not Y`, the diagnostic test, and the consequence of confusion gives more value per token than a long glossary.
- **Rank questions by branch impact:** ask whether an answer changes the decision, evidence needed, risk class, or next tool. Discard questions that merely demonstrate vocabulary.
- **Build from official templates:** standards, API schemas, regulatory forms, runbooks, clinical guidelines, and checklists reveal real field artifacts and vocabulary faster than generic articles.
- **Maintain a fake-jargon honeypot:** include plausible but invented acronyms and nonexistent standards in the regression suite. The correct behavior is to challenge or verify them.
- **Separate a public glossary from a private operating layer:** stable concepts can be shared across packs; company-specific thresholds, people, and exceptions remain private overlays.
- **Expose “why this question?”:** one sentence explaining the decision branch teaches the user the expert mental model and makes needless interrogation obvious.
- **Cache evidence, not conclusions:** reuse verified passages and metadata, then regenerate the conclusion for the current facts and date.

### Evaluation and battle testing

Do not evaluate the skill by asking people whether it “sounds expert.” Fluency and jargon can reward confident fabrication. Build an eight-domain benchmark with at least 15 scenarios per domain, using three scenario types: orientation, diagnosis/decision, and critique. Each item should include a source bundle, material unknowns, high-value questions, forbidden claims, expected artifacts, and a scoring rubric.

Evaluate these layers separately:

- **routing:** correct domain and specialty; safe ambiguity handling;
- **retrieval:** source recall, exact-term recall, passage precision, freshness, and authority-class correctness;
- **question value:** proportion of questions that change a decision branch, number of material unknowns found, and expert preference over a generic baseline;
- **terminology:** correct-in-context use, acronym expansion, distinction preservation, and invented-term rejection;
- **factuality:** atomic supported-claim precision and citation entailment;
- **calibration:** Brier score, selective accuracy at different abstention thresholds, and unsupported-confidence rate;
- **utility:** whether the user can make the decision, prepare for the meeting, or locate the next evidence faster;
- **cost:** latency, retrieved tokens, model tokens, and unnecessary questions.

[FActScore](https://arxiv.org/abs/2305.14251) motivates decomposing long answers into atomic claims and measuring what proportion are supported. [RAGAS](https://arxiv.org/abs/2309.15217) separates retrieval relevance, context use, and generation quality, though its automated judgments should be treated as screening rather than proof. Language-model confidence is not automatically calibrated; controlled QA experiments found substantial miscalibration and studied post-hoc and fine-tuning corrections ([Jiang et al., 2021](https://aclanthology.org/2021.tacl-1.57/)). A recent analysis argues that accuracy-only evaluations can incentivize guessing and hallucination when abstention is penalized ([OpenAI et al., 2026](https://doi.org/10.1038/s41586-026-10549-w)); the local benchmark should therefore reward correct abstention and productive clarification.

For the final acceptance test, have a practitioner and a competent generalist blindly compare the skill against an ordinary prompt. Ask the practitioner to mark factual errors, subtle terminology misuse, missing decision variables, unrealistic workflows, and questions they would actually ask. Ask the generalist whether the response teaches the decision model rather than only sounding sophisticated. Store disagreements; they are evidence about the rubric, not noise to delete.

### Failure modes and defenses

- **Expert theater:** high jargon density conceals shallow reasoning. Enforce a glossary source, a defined purpose for each technical term, and a jargon budget.
- **Wrong specialty:** an answer can be excellent for the wrong subfield. Ask the one routing question that separates the plausible domain paths.
- **Acronym collision:** the same acronym means different things across fields. Expand it in context and retain the domain path.
- **Source laundering:** a retrieved blog paraphrases an authority and is cited as proof. Store authority class and follow claims to the owning source.
- **Stale expertise:** standards, laws, products, and accepted practice change. Version packs and mark source-specific review intervals.
- **Invented organizational reality:** public sources cannot reveal a team's actual ownership, data quality, or exception path. Mark those as questions, never assumptions.
- **Interrogation as performance:** too many questions delay help. Ask the top branch-changing question and provide a provisional answer under explicit assumptions.
- **Over-calibrated vagueness:** endless caveats feel safe but are useless. State what is known, the current best action, and exactly which uncertainty could reverse it.
- **One “expert” voice:** disciplines contain legitimate schools, jurisdictions, and trade-offs. Represent disagreements and applicability conditions rather than declaring a synthetic consensus.
- **Prompt injection in retrieved text:** treat source content as data, never instructions; allow tools and write actions only through a separate policy layer.

### Recommended build sequence

1. Build the schema, claim ledger, and question card renderer.
2. Author one domain pack manually from primary sources.
3. Run a baseline ordinary prompt and 30 fixed scenarios.
4. Add domain routing and exact FTS5 retrieval.
5. Add the terminology and unsupported-claim gates.
6. Add question-impact ranking and the visible “why this matters” line.
7. Add a second, very different domain to test whether the architecture generalizes.
8. Only then add automated pack compilation, embeddings, Qdrant, or a hosted research fallback.

The simplest alternative is a reusable `expert-lens.md` worksheet with five blocks: domain path, material definitions, decision variables, five branch-changing questions, and primary sources. If that worksheet does not improve real conversations, an autonomous agent will not rescue the idea.

### Deferred expansion line

This assumes private preparation and user-controlled sources. Before selling domain packs, representing the tool as professional advice, or using private organizational knowledge across users, run [[Scope Expansion Checklist]] for licensing, provenance, privacy, professional-duty, correction, and liability concerns; that later release review should not change the best local-first prototype stack.

## 2. Tiny Model Game Lab

### Refined concept and honest target

Build an experimental lab that starts with a 125M–360M language model playing Wordle and systematically measures how much “alpha” comes from representation, deterministic state, search, verifiers, demonstrations, fine-tuning, distillation, and reinforcement learning. Wordle is valuable because the environment is cheap, every action can be checked exactly, complete games are short, and a mathematical solver gives a hard ceiling.

Do not collapse three different claims into “the 0.2B model reached SOTA”:

1. **Unaided model:** text state in, text guess out, no hidden tools.
2. **Model-guided system:** the model receives structured state, legal actions, search features, or verifier feedback.
3. **Solver-backed system:** deterministic code chooses or can override the action.

The third can achieve an optimal or near-optimal system score while teaching almost nothing about the model. Report all three. The real research question is which capability moves from the scaffold into the trained model, survives ablation, and transfers to new games.

For one formally specified Wordle version with 2,315 equiprobable solutions and a larger allowed-guess set, Bertsimas and Paskov's exact dynamic-programming solution reports `SALET`, a 3.421 expected-guess optimum, and certain victory in at most five guesses ([Operations Research paper](https://doi.org/10.1287/opre.2022.0434)). That is an oracle for that exact word list, distribution, action set, and objective—not a timeless score for every current Wordle variant.

### Candidate models around the requested scale

Use several models rather than betting the experiment on one tokenizer or pretraining recipe:

| Candidate | Why include it | Caveat |
| --- | --- | --- |
| [Gemma 3 270M IT](https://huggingface.co/google/gemma-3-270m-it) | Current 270M instruction-tuned model, 32K context according to Google's model card, widely supported in local runtimes | Terms differ from Apache-style releases; preserve an export/release review for later |
| [SmolLM2 135M Instruct](https://huggingface.co/HuggingFaceTB/SmolLM2-135M-Instruct) | Very small Apache-2.0 instruct baseline; its model card exposes training and zero-shot evaluation details | Weak general reasoning is expected; it may need constrained actions from the first prototype |
| [SmolLM2 360M Instruct](https://huggingface.co/HuggingFaceTB/SmolLM2-360M-Instruct) | Same family at a useful upper point for a clean scale comparison | Roughly 2.7x the nominal 135M size, so report compute as well as score |
| [MobileLLM 125M](https://github.com/facebookresearch/mobilellm) | Meta's released architecture/training code targets sub-billion on-device models and provides 125M/350M comparison points | Better as an architecture/base-model experiment than the default conversational policy |
| [Pythia 160M](https://huggingface.co/EleutherAI/pythia-160m) | Research-friendly base model from a suite designed for analyzing training behavior | Older and not instruction tuned; use it to study learning curves, not as the presumed winner |
| [OpenELM 270M Instruct](https://huggingface.co/apple/OpenELM-270M-Instruct) | Another true 270M-class architecture with released training/inference framework | Custom-code/tokenizer setup is less frictionless than the primary baselines |

Add one 0.5B–1.7B control only to identify a capacity cliff; do not quietly substitute it for the 0.2B experiment. Freeze exact model revisions, tokenizer revisions, precision, decoding settings, and prompt versions in every run.

### Wordle environment and deterministic core

[TextArena](https://github.com/TextArena/TextArena) already includes `Wordle-v0` plus Mastermind, Sudoku, Sokoban, Logic Puzzle, Word Ladder, Hangman, Crosswords, and other text games. Hugging Face's current [OpenEnv Wordle tutorial](https://huggingface.co/docs/openenv/tutorials/wordle-grpo) shows a stateful Wordle environment connected to TRL's GRPO trainer. It is a useful accelerator, but first write a small reference engine so every reward and feedback edge case is understood.

The Wordle core should own:

- the exact solution list, allowed-guess list, and their version hashes;
- duplicate-letter scoring with greens allocated before remaining yellow counts;
- normal versus hard-mode legality;
- state transition and terminal conditions;
- a candidate filter derived from the full feedback history;
- per-letter minimum and maximum counts plus forbidden positions;
- deterministic entropy, expected partition size, worst-case partition, and oracle action values;
- replayable episode logs.

Property tests matter more than sample transcripts. For every answer and guess, feedback must be deterministic; every retained candidate must reproduce the complete feedback history; revealing more valid feedback may not enlarge the candidate set; a solved state must terminate; equivalent state histories must produce the same candidate set; and duplicate-letter permutations must respect the remaining-count rule.

### Four policy interfaces

Train and evaluate the model through progressively less helpful interfaces:

1. **Raw chat policy:** receives the natural-language board and emits a word. This measures instruction following, state tracking, vocabulary, and formatting together.
2. **Structured policy:** receives a compact JSON state containing positions, letter-count bounds, remaining guesses, and optionally candidate count. It emits a five-letter action under a strict schema.
3. **Candidate reranker:** deterministic code supplies `K` legal candidates and features; the model ranks or selects one. This avoids asking a 0.2B model to recall the entire lexicon.
4. **Policy/value head:** encode the state and score enumerated actions directly, optionally estimating probability of winning or remaining moves. The natural-language decoder becomes optional.

The candidate-reranker and policy-head routes are likely to provide the biggest gain. Most five-letter words are not single tokenizer units, so free-form generation makes the model solve an irrelevant segmentation and spelling problem. A constrained action space lets the experiment focus on information gathering and planning. Keep raw-chat results so this gain is visible rather than hidden.

### Baseline ladder and ablations

Run these in order and never delete earlier results:

1. random allowed word;
2. random word consistent with feedback;
3. letter-frequency heuristic;
4. greedy entropy or expected-partition heuristic;
5. exact or bounded dynamic-programming oracle on the fixed reference list;
6. frozen model with zero-shot prompt;
7. frozen model with few-shot examples;
8. frozen model plus structured state;
9. frozen model plus candidate list;
10. frozen model reranking heuristic top-K actions;
11. supervised policy trained on oracle/heuristic trajectories;
12. outcome-filtered reasoning or action distillation;
13. on-policy reinforcement learning in the environment;
14. hybrid trained model plus legality verifier and deterministic fallback.

For every claimed gain, remove one component: candidate filter, features, search depth, verifier, rationale, fine-tune, or fallback. The exact solver score is a ceiling and a label source, not a fair baseline to call an “LLM.”

### Scaffolding and test-time compute

Wordle has a compact, enumerable action space, so ordinary search is stronger and cheaper than asking a tiny model to narrate a long chain of thought. Use the model where learned priors help and code where correctness is mechanical:

- candidate filtering and legality: deterministic;
- feedback simulation: deterministic;
- partition statistics and entropy: deterministic;
- top-K action proposal: heuristic/search;
- final selection among plausible trade-offs: model or learned policy;
- state-value estimate: learned head, checked against rollouts;
- output parsing: constrained schema plus fallback.

For later games where the state tree cannot be cheaply enumerated, adapt the [Tree of Thoughts](https://arxiv.org/abs/2305.10601) pattern of proposing, evaluating, searching, and backtracking over intermediate states. Its original experiments include Game of 24 and Mini Crosswords. For arithmetic games, [Program of Thoughts](https://arxiv.org/abs/2211.12588) provides the stronger principle: let the model express a plan or program while an external interpreter performs exact computation. [Self-consistency](https://arxiv.org/abs/2203.11171) can sample multiple paths and aggregate answers, but its compute multiplier must appear in the results table.

A useful constrained-search controller is:

1. deterministic code generates legal actions and cheap features;
2. tiny model scores or prunes actions;
3. bounded beam search or Monte Carlo rollouts evaluate the survivors;
4. verifier rejects illegal/inconsistent states;
5. the system spends more search only when candidate count or value uncertainty is high.

This makes test-time compute an explicit budget rather than an invisible advantage.

### Curriculum and synthetic data

Generate all training examples from a versioned environment, not from model-written rules. Use a curriculum based on state difficulty:

- **Stage A — mechanics:** one-step legality, feedback interpretation, duplicate-letter cases, and candidate filtering;
- **Stage B — small state:** states with 2–10 candidates where exact best actions are cheap to compute;
- **Stage C — medium state:** 11–100 candidates, including probe guesses that are not possible answers;
- **Stage D — full games:** oracle and diverse near-optimal trajectories from the initial state;
- **Stage E — hard cases:** repeated letters, dense word families such as `_IGHT`, hard mode, nonuniform priors, and adversarial openings;
- **Stage F — distribution shift:** held-out lexemes, altered answer distributions, different word lengths, and synthetic alphabets;
- **Stage G — transfer:** Mastermind, Game of 24, Sudoku, Sokoban, or a second environment with a different state representation.

For each state, store legal actions, oracle or heuristic action value, partition features, chosen action, outcome, and teacher identity. Retain diverse suboptimal trajectories so the model learns recovery rather than only imitating a single opening tree. Oversample states on which the current policy disagrees with the oracle; this is more efficient than regenerating uniform full games after every iteration.

[TinyStories](https://arxiv.org/abs/2305.07759) demonstrates the broader data-centric lesson that very small models can learn surprisingly coherent behavior when the domain and vocabulary are controlled. Wordle is an even more constrained world, but the target is a verified policy rather than story fluency. [STaR](https://arxiv.org/abs/2203.14465) provides an iterative template for keeping rationales that lead to correct outcomes and retrying failures with the answer supplied. For this lab, keep only traces whose actions and intermediate states pass the deterministic verifier; never distill a persuasive but invalid rationale.

### Fine-tuning, distillation, and RL

Use the cheapest learning method that addresses the measured failure:

1. **Supervised fine-tuning:** start with state-to-action examples and short verified state summaries. If the model cannot reliably emit a legal word, RL is premature.
2. **Pairwise preference training:** construct preferred/rejected action pairs using oracle value, with hard negatives that are legal but informationally poor.
3. **Policy/value multitask training:** predict the action plus candidate count, partition statistic, or win probability. Auxiliary targets expose whether the model learned state structure.
4. **Teacher distillation:** ask a stronger model for terse decompositions, but accept only steps grounded in deterministic state fields. Research on distilling reasoning into smaller models supports decomposer/solver separation ([Shridhar, Stolfo, and Sachan, 2022](https://arxiv.org/abs/2212.00193)).
5. **Verifier-filtered self-training:** sample multiple actions/traces, retain those that satisfy state constraints and achieve high rollout value, retrain, and repeat.
6. **On-policy GRPO:** only after stable supervised behavior. TRL supports SFT, DPO, GRPO, process-reward training, and knowledge-distillation trainers in one open library ([official TRL documentation](https://huggingface.co/docs/trl/index)).

Hugging Face's OpenEnv guidance reports that simple final-state rewards worked more cleanly than shaped partial rewards in its Wordle and Sudoku experiments, and warns that even a 1.7B Qwen model without thinking did not consistently solve Wordle in that setup ([OpenEnv integration guide](https://huggingface.co/docs/trl/en/openenv)). This is a useful reality check for a 0.2B target. Begin with binary success plus deterministic curriculum and supervised initialization. If adding a guess-count term or illegal-action penalty, audit whether it changes the intended objective or invites reward hacking.

Process supervision can teach local correctness, but only when intermediate labels are trustworthy. OpenAI's [Let's Verify Step by Step](https://arxiv.org/abs/2305.20050) distinguishes final-outcome from step-level supervision. Wordle supplies cheap machine-verifiable process labels: state consistency, candidate-set correctness, action legality, and partition value. These are preferable to a model grading another model's prose.

For competitive later games, self-play becomes more meaningful. [SPIRAL](https://arxiv.org/abs/2506.24119) reports transferable reasoning gains from multi-turn, multi-agent self-play on zero-sum games and found its strongest results with multi-game training. Do not infer that the same gains will hold at 270M; use its source code and design as a later experiment after single-player verifiable tasks work.

### Evaluation design

Freeze a manifest for every benchmark:

```yaml
environment_version: "..."
answer_list_sha256: "..."
allowed_guess_sha256: "..."
answer_distribution: uniform
mode: normal
max_guesses: 6
model_revision: "..."
tokenizer_revision: "..."
precision: bf16
seed_set: [0, 1, 2, 3, 4]
tool_policy: structured-state-plus-top-k
search_budget_nodes: 0
fallback_enabled: false
```

Primary metrics:

- win rate at six and at five guesses;
- mean, median, p90, and worst-case guesses;
- illegal-action and malformed-output rate;
- constraint-violation rate even when the word is legal;
- entropy or expected-guess regret relative to the oracle;
- candidate-filter accuracy and duplicate-letter accuracy;
- performance by candidate-set size and word-family ambiguity;
- wall time, generated tokens, forward passes, search nodes, and energy/compute proxy;
- seed variance and 95% bootstrap confidence interval;
- transfer score on unseen lexemes, changed distributions, and new games.

Publish four columns for every run: `model-only`, `model + structured state`, `model + tools/search`, and `full system with fallback`. If the full system wins 100% only because the fallback is exact, say so in the headline.

Use three disjoint test families:

1. **Canonical-list test** for comparison with exact and heuristic Wordle policies.
2. **Lexical holdout** where answer words and morphological families are excluded from supervised trajectories.
3. **Synthetic guessing game** with arbitrary symbols or generated strings but identical feedback semantics. This detects whether the model learned constraint reasoning or memorized English openings and leaked answer lists.

Benchmark contamination is especially serious because Wordle lists, strategies, and daily answers are common online. A high canonical score alone cannot demonstrate learned reasoning. The synthetic game and state-level probes are essential.

### Harder-game progression

Choose the next game to isolate a new capability rather than merely increasing board size:

| Stage | Environment | Capability isolated | Deterministic verifier |
| --- | --- | --- | --- |
| 1 | Wordle | lexical constraints and information gain | exact feedback and candidate set |
| 2 | Mastermind | same information structure without language priors | exact color/position counts |
| 3 | Game of 24 | arithmetic composition and bounded search | exact expression evaluator |
| 4 | Sudoku / Logic Puzzle | long-horizon constraint propagation | rule checker and solved grid |
| 5 | Sokoban / Rush Hour | irreversible planning and deadlock avoidance | simulator and goal state |
| 6 | Tic-Tac-Toe / Connect Four | opponent modelling and minimax | complete game engine |
| 7 | Hanabi / poker variants | imperfect information, belief state, cooperation or bluffing | game engine plus payoff |
| 8 | TextWorld / ALFWorld | language-grounded action sequences and partial observability | environment state and task completion |

TextArena supplies many of the early text interfaces. [OpenSpiel](https://github.com/google-deepmind/open_spiel) supplies tested game environments plus search, planning, reinforcement-learning algorithms, and evaluation tools across perfect/imperfect-information and cooperative/competitive games. [MiniGrid](https://github.com/Farama-Foundation/Minigrid) offers lightweight, programmatically adjustable grid worlds and BabyAI language missions, making it suitable for curriculum. [TextWorld](https://github.com/microsoft/TextWorld) generates text-game environments for training and evaluation; Windows users can use its documented Docker path. [ALFWorld](https://github.com/alfworld/alfworld) aligns abstract text environments with embodied tasks for a much later transfer test.

Do not move directly from Wordle to chess. A 270M language model can appear stronger when a chess engine supplies legal moves and evaluation, but the attribution problem becomes worse. Mastermind is the best second task because it preserves the information-gathering structure while removing English vocabulary; Game of 24 is the best third task because every proposed chain can be exactly executed.

### Free-first stack and experiment layout

Use Python 3.12 in WSL2 for the broadest compatibility, PyTorch, Hugging Face Transformers and Datasets, TextArena/OpenEnv, [PEFT](https://github.com/huggingface/peft) for LoRA experiments, TRL for SFT/DPO/GRPO, and TensorBoard or Trackio for local run tracking. At 125M–360M, first try full-parameter BF16 fine-tuning on the available GPU before introducing quantization complexity; record memory and throughput rather than assuming one method is cheaper.

Recommended repository layout:

```text
tiny-model-game-lab/
  manifests/
  environments/wordle_ref/
  solvers/
    random.py
    entropy.py
    exact_oracle.py
  policies/
    raw_chat.py
    structured.py
    reranker.py
    policy_value.py
  data/
    generated/
    splits/
  training/
    sft.py
    preferences.py
    grpo.py
  evaluation/
    run_suite.py
    contamination.py
    transfer.py
  tests/
  reports/
```

Every report should be generated from immutable episode logs. Store model and tokenizer revisions, Git commit, environment manifest, random seed, prompt hash, adapter hash, hardware, precision, and all tool/search budgets.

### Clever experiments likely to produce real alpha

- **Model as value function, code as search:** train the tiny model to rank states or actions while deterministic search performs lookahead. This isolates learned heuristics and can reduce oracle search cost.
- **Residual policy:** let a strong entropy heuristic choose by default; train the model only to predict when and how to deviate. The target is smaller and the ablation is clean.
- **Difficulty-triggered compute:** use candidate-set size, top-two value margin, or model uncertainty to decide when to search deeper.
- **Oracle disagreement mining:** after every checkpoint, generate the states where model and oracle disagree most and add those to the next curriculum batch.
- **Counterfactual feedback pairs:** change one tile or duplicate-letter count while holding the rest fixed; require the action distribution or state summary to change appropriately.
- **Tokenizer-independent action IDs:** emit an index into a supplied legal-action table, then separately test spelling. This distinguishes planning failure from tokenization failure.
- **Opening-tree compression:** distill the oracle's high-traffic decision tree into a compact policy table or classifier; measure storage, latency, and degradation versus the full oracle.
- **Teacher rationale ablation:** train action-only, action-plus-deterministic-features, and action-plus-teacher-rationale students. Do not assume verbose reasoning helps a tiny model.
- **Cross-game adapter bank:** keep the base model frozen and train small adapters for Wordle, Mastermind, and Game of 24, then compare single-game, merged-adapter, and multi-game training.
- **Reasoning without English:** use synthetic symbols or nonce strings. Transfer here is stronger evidence than another canonical Wordle point.

### Failure modes and safeguards

- **Tokenizer tax:** valid words split unpredictably and five-letter output is unreliable. Compare raw strings with action IDs and candidate reranking.
- **Duplicate-letter bugs:** a flawed environment creates fraudulent rewards. Exhaustively test answer/guess feedback pairs and compare independent implementations.
- **Word-list mismatch:** “optimal” scores become incomparable. Hash and publish both action and solution lists plus the answer prior.
- **Training leakage:** the model memorizes the daily answers or oracle tree. Use lexical-family holdouts and synthetic games.
- **Solver laundering:** deterministic code does the reasoning while the model gets credit. Report component-separated scores and disable fallback in model claims.
- **Reward hacking:** the model exploits parsing, termination, repeated guesses, or malformed actions. Make the environment authoritative and regression-test adversarial outputs.
- **Sparse-reward collapse:** a 0.2B policy rarely wins and GRPO has no useful contrast. Start with SFT and small-state curriculum before full-game RL.
- **Opening overfit:** impressive average performance masks brittle mid-game play. Evaluate from sampled reachable states at every depth, not only complete games.
- **Unfaithful rationale:** correct guesses can accompany nonsense explanations. Grade state fields and action value, not prose plausibility.
- **Search-budget concealment:** best-of-N and tree search compare unfairly with greedy baselines. Publish tokens, model calls, search nodes, and latency.
- **Quantization confound:** a small accuracy loss can be large near a policy threshold. Establish BF16/FP16 results before quantized deployment.
- **Catastrophic forgetting:** game fine-tuning may destroy basic instruction following. Retain a small general evaluation slice and compare adapters with full tuning.
- **No transfer:** specialized Wordle performance may be a compressed lookup table. Treat that as a useful systems result, not general reasoning progress.

### Recommended build sequence

1. Implement and exhaustively test the reference Wordle environment.
2. Reproduce random, valid-random, entropy, and exact/near-exact solver baselines.
3. Benchmark frozen Gemma 3 270M IT, SmolLM2 135M, and SmolLM2 360M through raw and structured interfaces.
4. Add the action-ID and top-K reranker interfaces.
5. Generate small-state oracle examples and run SFT; measure state probes before full games.
6. Add oracle-disagreement mining and preference pairs.
7. Try verifier-filtered self-training, then GRPO only if the supervised model wins often enough to create useful groups.
8. Run all ablations and lexical/synthetic holdouts.
9. Transfer the same infrastructure to Mastermind and Game of 24.
10. Only after transfer is demonstrated, add Sudoku, Sokoban, multi-game training, or self-play.

The simplest alternative is already useful: build an exact Wordle engine, a greedy entropy solver, and an evaluation harness around several frozen tiny models. The delta between raw-chat, structured-state, candidate-reranking, and deterministic solving will teach more about small-model systems than prematurely launching a long RL run.

### Deferred expansion line and related projects

This assumes private experiments with locally stored models and game data. Before publishing checkpoints, datasets, leaderboards, or packaged game environments, review model/data licenses, benchmark terms, reproducibility artifacts, and contamination disclosure through [[Scope Expansion Checklist]]; those later release questions should not change the local experimental stack.

Related vault work includes [[Quiz Master]], [[Quiz Poker]], [[Local Video Generation Evaluation Lab]], [[ai-implementation-agency|AI Implementation Agency]], and [[Personal Study Curriculum]].
