# RTX PRO 5000 Laya Decision Model Tutorial

Status: research and user-run evaluation plan, 2026-09-28. No installation or integration has been performed.

## What Laya is

[Laya](https://github.com/NandhaKishorM/laya) is a local, non-generative model for typed `choice`, `score`, and `noul` (yes/no probability) decisions. The captured [X post](https://x.com/NFT_Chen/status/2101675124747338229?s=20) calls it “421M”: that means **421 million parameters**, not a 421 MB model file. The repository lists three checkpoints: English `convaiinnovations/laya` (421M parameters), multilingual `laya-multilingual` (322M), and `laya-typed-decisions` (421M, specialized for a benchmark's typed workflows). It is Apache 2.0. Do not replace a deterministic rule or Hermes routing with it merely because a game loop is fast. [Maintainer README](https://github.com/NandhaKishorM/laya), [English model](https://huggingface.co/convaiinnovations/laya).

## Source and reply audit

The exact X status `2101675124747338229` returned the captured post and replies. The author reports a Snake-game comparison of **86.5 decisions/s and P50 ~9 ms** locally versus **3.2 decisions/s and ~317 ms API round trip** for Jev, plus an M5 Pro median of 15.3 versus 298.1 ms. Those are a poster's specific runs, not evidence of task accuracy or expected RTX speed. [One reply](https://x.com/fibybella/status/2102761345011900765) correctly asks about end-to-end action completion after the decision. Another questions the short input context; the maintainer README documents a 512-token English default (with ~320 tokens left for state) and 1,024-token multilingual default. A later reply points to a community fine-tuned coding-agent guard, which is a separate checkpoint and should be evaluated independently. [Source thread](https://x.com/NFT_Chen/status/2101675124747338229?s=20), [maintainer README](https://github.com/NandhaKishorM/laya).

The maintainer's own [benchmark and limits](https://github.com/NandhaKishorM/laya#honest-limits) matter more than the viral speed clip: base checkpoints score near chance on one typed-decisions zero-shot benchmark (0.362/0.352 versus 0.318 random and 0.461 majority). A checkpoint fine-tuned on that benchmark's training split reports 0.766; that score cannot be attributed to the untuned base. The README reports overconfident probabilities, `noul` label sensitivity, errors on negated cancellation requests, weaker ordinal scoring, and problems with many choices unless token budgets are raised. Treat confidence thresholds as empirical, per-task choices.

## Windows fit and first run

This belongs on the Windows workstation. The 48 GB RTX PRO 5000 has far more memory than one Laya checkpoint needs, but the CPU may be sufficient for low-volume routing; compare both. Use a project-specific virtual environment, not the Python environment that operates Hermes or ODS. The published project requires Python 3.10+; its README gives a Windows PowerShell install path. [Install guide](https://github.com/NandhaKishorM/laya#installation-details).

Run these commands in **Windows PowerShell** from a separate evaluation directory, for example `E:\GIT_ROOT\Projects\laya-eval`. The install and first inference download packages/checkpoints only when you choose to execute them:

```powershell
New-Item -ItemType Directory -Path 'E:\GIT_ROOT\Projects\laya-eval' -Force
Set-Location 'E:\GIT_ROOT\Projects\laya-eval'
py -3.11 -m venv .venv
.\.venv\Scripts\python.exe -m pip install laya
.\.venv\Scripts\python.exe -I -c "import laya; print(laya.__version__)"
.\.venv\Scripts\laya.exe 'My payment failed twice' --preset triage
```

The version line proves that the environment contains Laya without loading weights. The final command is the maintainer's documented CLI smoke test; it loads a checkpoint on first use. The publisher recommends selecting the right [PyTorch CUDA wheel](https://pytorch.org/get-started/locally/) first if GPU inference is wanted. If PyTorch reports no CUDA, record a CPU baseline rather than mistaking it for a GPU result. Record package version, model revision, first-load time, warm decision latency, memory, and actual device. Do not use `Router(preload=True)` for the first probe: it downloads and loads all three checkpoints; the default lazy `Router()` loads only what it needs. [Quickstart](https://github.com/NandhaKishorM/laya#quickstart-route-mode-recommended).

## Evaluation that answers the actual question

Build 50–100 locally labelled routing examples from synthetic or redacted tasks: skill selection, recovery choice, inbox triage, and “no action” cases. Include negation (e.g., “do not cancel”), empty/ambiguous states, long input, and Hindi or another non-English case if that use matters. Separate train, development, and untouched test splits before tuning prompts, thresholds, or a checkpoint. [Hamel Husain's Jev eval FAQ](https://hamel.dev/blog/posts/evals-faq/can-i-use-jev-for-evals.html) treats any AI judge as a classifier that must be validated against trusted labels; the captured [post and replies](https://x.com/HamelHusain/status/2104305090743992821) add useful checks for version drift and false passes after tuning.

Compare four routes on the same cases: deterministic existing rule, Laya base, Laya specialized checkpoint if the workflow matches, and Jev only if you already have API access. Never count the post's Jev latency as your own measurement. For each route, record accuracy and confusion matrix, false actions in high-cost classes, abstention coverage, p50/p95 warm latency, cold load, end-to-end wall time including tool execution, and cost per 1,000 decisions. For Laya, also record the model-selected `routing.model`, max token budget, output probabilities, and low-confidence flags. Re-run the frozen test set on every checkpoint or runtime upgrade.

The built-in [`laya-evals`](https://github.com/NandhaKishorM/laya#evaluation-harness) CLI accepts labelled JSONL and reports choice accuracy, yes/no accuracy, score error, calibration error, confidence, and latency. After you have built a file in the repository's documented schema, the maintainer's form is:

```powershell
.\.venv\Scripts\laya-evals.exe validate .\labelled-test.jsonl
.\.venv\Scripts\laya-evals.exe run .\labelled-test.jsonl --model english --min-accuracy 0.8 --slice language
```

The `0.8` threshold is an **example**, not a recommendation. Set a gate from your task's error cost and measured baseline. In particular, require zero destructive false actions in the held-out set before considering any autonomous use. The model may make advisory suggestions while deterministic code and the user keep final authority.

## Optional tuning after a useful baseline

If untuned Laya loses to the current router, the maintainer provides a [fine-tuning notebook](https://github.com/NandhaKishorM/laya/blob/main/notebooks/laya_finetune_typed_decisions_2xT4_kaggle.ipynb), but its published calibration samples are drawn from training items; evaluate on a separate untouched test split. Its README notes that raw confidence can be miscalibrated and that `laya-multilingual` ships without fitted temperatures. For many choice labels, use a larger head token budget or shortlist; for yes/no, supply explicit criteria and test negated examples. Keep the fine-tuned result under a new name, with source revision and test report, rather than overwriting a base checkpoint. [README limitations and calibration](https://github.com/NandhaKishorM/laya#honest-limits).

## Decision gate

Keep Laya only if it improves an actual local workflow at a chosen accuracy/latency point. A 20x network-round-trip speedup is not useful if incorrect decisions trigger retries or the next tool dominates wall time. Prefer an abstain-and-escalate rule calibrated on trusted labels to an unsupported “confident means correct” assumption. Record the selected model, tested language/input length, accepted coverage, false-action count, and rollback to the existing deterministic route.

## References

- [Captured Laya vs Jev post and replies](https://x.com/NFT_Chen/status/2101675124747338229?s=20)
- [Laya official repository and documentation](https://github.com/NandhaKishorM/laya)
- [Laya checkpoint](https://huggingface.co/convaiinnovations/laya)
- [Hamel Husain on validating Jev as a judge](https://hamel.dev/blog/posts/evals-faq/can-i-use-jev-for-evals.html)
- [Captured Hamel post and replies](https://x.com/HamelHusain/status/2104305090743992821)

Related: [[Local Setup Index]] · [[Task Checklist]]
