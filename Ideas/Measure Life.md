---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#7. Measure Life]]"
status: concept
difficulty: medium
priority: p1
category: quantified self
form_factor:
  - mobile app
  - local dashboard
deployment: local-first
source_ideas:
  - measure aspects of life and discover triggers for mood, body, and goals
tags:
  - quantified-self
  - experiments
  - wellbeing
---

# Measure Life

> A private self-observation and N-of-1 experiment tool that helps discover useful patterns between food, sleep, activities, environment, symptoms, mood, and goals without pretending correlation is diagnosis or causation.

## Product Outcome

Capture a tiny amount of context at useful moments, then review time-lagged patterns and run explicit experiments. The app should help answer practical questions such as “does late caffeine consistently delay sleep?” or “which study setup predicts a good focus block?” while showing uncertainty and missing data.

## Personal V0

- Define a small set of outcomes and exposures with units and meaning.
- Create morning, event-triggered, and evening check-ins.
- Import selected device/health exports only when they reduce manual work.
- Visualize timelines, distributions, streak-free completion, and lagged associations.
- Mark confounders, unusual days, medications, travel, or illness.
- Create an experiment with hypothesis, baseline, intervention, duration, stop rule, and result.
- Produce a weekly review that separates observation, hypothesis, and next test.

## Build Boundary

**MVP:** five manual variables, two daily check-ins, local data, timeline, simple correlation/lag explorer, and experiment notes.

**Later:** wearable integrations, reminders, randomization, richer statistics, and clinician exports. Do not diagnose conditions, recommend medication changes, or present a small observational association as causal.

## Existing Products, Building Blocks, and Shortcuts

- Android [Health Connect](https://developer.android.com/health-and-fitness/guides/health-connect) and Apple [HealthKit](https://developer.apple.com/documentation/healthkit) can import selected sleep/activity observations later; manual event buttons remain the clean baseline.
- [Open mHealth schemas](https://www.openmhealth.org/documentation/#/overview/get-started) demonstrate normalized health-data records, while DuckDB/Polars can analyze exports locally without a health-data cloud.
- Existing quantified-self products such as Exist and Gyroscope show correlation dashboards, but the local differentiator is explicit hypotheses, lags, confounders, and “insufficient evidence.”
- Simpler alternative: two weeks of a fixed Markdown/form check-in, then analyze CSV with DuckDB or a notebook. Only fields that survive this trial should enter the app schema.

## Free-First Stack

- **App:** Expo/React Native.
- **Data:** encrypted local SQLite with explicit units, timezone, source, and missingness.
- **Analysis:** Python/Polars or TypeScript statistics for rolling summaries and lagged comparisons.
- **Charts:** Observable Plot/ECharts.
- **Models:** no model for statistics; local LLM may turn the user’s question into a reviewed experiment template.
- **Export:** CSV/JSON/Markdown plus a human-readable data dictionary.

## Clever Hacks and Simpler Alternative

- Start with a daily Markdown or form template for two weeks before coding; only stable fields deserve schema.
- Use event buttons such as “coffee,” “exercise,” or “headache began” so timestamps are more accurate than evening recall.
- Show raw dots and sample size beside every trend line.
- Compare within similar weekdays/time windows to reduce obvious confounding.
- Change one variable at a time when practical, and predeclare what result would change behavior.

## Build Slices

1. Variable/data dictionary and check-in forms.
2. Timeline and edit/audit history.
3. Lag explorer with sample-size warnings.
4. Experiment protocol and outcome notes.
5. Selected import adapters and clinician-friendly export.

## Battle-Testing Gates

- Three weeks of real check-ins with acceptable burden.
- Timezone changes, missed days, duplicates, and corrected entries behave predictably.
- Statistical fixtures match an external calculation.
- Every chart exposes sample size and missing values.
- The app has a clear “insufficient evidence” state.

## Product Path

It can remain a private life lab or become an open-source N-of-1 framework. A health-facing commercial version adds medical, privacy, study-design, and regulatory responsibilities that should not be inferred from a wellness tracker.

## Related

- [[Paper Logbook]]
- [[Physio Atlas]]
- [[Feedback Mirror]]
- [[Personal Finance Cockpit]]
- [[Project Ideas Index]]
