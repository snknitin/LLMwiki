---
type: skill-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Cognitive Support and Explanation Skills#6. Physics Claim Debunker Skill]]"
status: concept
difficulty: hard
priority: p1
category: scientific reasoning
form_factor:
  - research skill
  - Telegram bot
  - interactive notebook
deployment: local-first
source_ideas:
  - debunk conspiracy theories using physics and theory
tags:
  - physics
  - debunking
  - scientific-method
  - estimation
  - evidence
---

# Physics Claim Debunker Skill

> Convert an extraordinary claim into measurable subclaims, test them with conservation laws, dimensions, orders of magnitude, geometry, probability, and primary evidence, then explain exactly what fails—or what remains genuinely uncertain.

## Product Outcome

The skill is a scientific claim examiner, not a generic “false” classifier. It should steelman the claim, state the minimum physical model, calculate observable consequences, compare them with measurement, and distinguish:

- physically impossible under stated assumptions;
- physically possible but unsupported;
- inconsistent with available evidence;
- dependent on an incorrect scale/base rate;
- unfalsifiable as phrased;
- unresolved or outside the available model.

The final explanation has beginner, intermediate, and technical layers, with reproducible calculations and primary references.

## User and Core Workflow

1. User submits a claim, link, video, screenshot, or transcript.
2. Skill extracts atomic propositions and asks which one matters most.
3. It writes the strongest coherent version and lists assumptions.
4. It selects applicable tests: dimensional consistency, energy/momentum/mass balance, inverse-square behavior, signal/noise, thermodynamics, geometry/perspective, material limits, orbital mechanics, statistics, or base rates.
5. It calculates order-of-magnitude predictions in code with units.
6. It gathers primary measurements, papers, official datasets, and instrument specifications.
7. It compares prediction with observation and runs sensitivity analysis.
8. It renders verdict, uncertainty, strongest counterargument, and what future evidence could change the conclusion.

## Personal V0

- Support pasted text and a transcript.
- Implement five deterministic tools: unit-aware calculator, Fermi estimator, geometry calculator, uncertainty propagation, and claim/evidence table.
- Build ten benchmark cases with known physical mechanisms and common misleading arguments.
- Generate a Markdown report plus executable calculation notebook/script.
- Add ELI5/ELI12 rendering through [[News Depth Telegram Skill]].
- Require every quantitative conclusion to point to code/input units.

## Build Boundary

**MVP:** claim decomposition, physical-test selection, reproducible calculations, source retrieval, layered report, and benchmark fixtures.

**Later:** video-frame geometry, audio/image forensics, interactive parameter sliders, collaborative rebuttal trees, and domain packs for space, energy, climate, RF, structures, and optics.

The skill should be willing to conclude “not established” or “my model is insufficient.” Its value comes from showing the reasoning path, not always producing a dramatic debunk.

## Existing Products, Building Blocks, and Shortcuts

- [Pint](https://github.com/hgrecco/pint) provides unit-aware Python calculations; [SymPy](https://www.sympy.org/) covers symbolic derivations and numerical evaluation.
- The [BIPM SI Brochure](https://www.bipm.org/en/publications/si-brochure) anchors unit definitions, while [NIST CODATA](https://physics.nist.gov/cuu/Constants/index.html) supplies versioned physical constants and uncertainties.
- [Jupyter](https://jupyter.org/) or a plain Python report makes calculations reproducible; [uncertainties](https://pythonhosted.org/uncertainties/) propagates measurement error.
- [NASA ADS](https://ui.adsabs.harvard.edu/help/api/), [OpenAlex](https://docs.openalex.org/), arXiv, NIST, NASA/ESA, government metrology/weather/geology sites, and original instrument documentation are primary-source routes by domain.
- [Google Fact Check Tools API](https://developers.google.com/fact-check/tools/api/reference/rest/v1alpha1/claims/search) can reveal existing formulations/reviews of a claim; treat them as research leads while keeping the physics calculation independent.
- InVID-style verification, Wolfram tools, Metabunk, Snopes, and fact-checking organizations are product/process references. This skill specializes in transparent physical models and executable numbers.
- Simplest alternative: a fixed “claim -> assumptions -> prediction -> measurement -> verdict” template plus a Python scratch file.

## Recommended Free-First Stack

- Python skill helpers with Pint, SymPy, NumPy/SciPy, uncertainties, and Matplotlib.
- Jupyter or Quarto for reproducible appendices; Markdown for the main explanation.
- Local model for decomposition/explanation and a research pass for primary evidence.
- yt-dlp/Whisper and OpenCV for user-selected video evidence later.
- SQLite/JSON benchmark set with expected mechanisms, calculations, and failure modes.

## Analysis Contract

Every report includes:

1. Exact claim and charitable interpretation.
2. Assumptions and definitions.
3. Applicable physical laws/model.
4. Back-of-envelope estimate with units.
5. Expected observations if the claim were true.
6. Actual primary measurements and uncertainty.
7. Alternative explanations.
8. Verdict category and confidence.
9. Strongest remaining objection.
10. Evidence that would change the verdict.

## Build Slices

1. Claim schema and five benchmark reports.
2. Unit-aware calculation helpers and test suite.
3. Primary-source retrieval and evidence ledger.
4. Sensitivity/uncertainty analysis.
5. Layered explanation and Telegram command.
6. Video geometry/forensics and interactive sliders.

## Drawbacks, Concerns, and Failure Modes

- A correct formula with wrong boundary conditions produces persuasive nonsense. State the model domain and assumptions.
- Some claims are historical/social rather than physically testable. Isolate only the physical subclaim.
- Data can be cherry-picked. Search for measurements that would contradict the favored conclusion.
- Orders of magnitude can hide thresholds. Run sensitivity analysis near decision boundaries.
- Visual evidence is sensitive to lens, compression, perspective, and missing metadata. Avoid pixel-to-world claims without calibration.
- Mocking believers reduces usefulness. Attack the mechanism and evidence, not the person.

## Clever Hacks and Simpler Alternative

- Begin every case with “what observable would be unavoidable if this were true?”
- Use upper bounds; proving even the best-case claim is far too small/large often avoids complex simulation.
- Plot the claimant’s parameter range and show where the conclusion changes.
- Provide one household-scale analogy after the calculation, not instead of it.
- Keep a library of recurring errors: unit mismatch, inverse-square neglect, base-rate neglect, perspective, selection effects, and energy-budget violations.

## Success Measures

- Quantitative claims reproduce from saved code and inputs.
- Benchmark cases select the correct physical test and verdict category.
- Reports clearly separate assumptions, evidence, inference, and uncertainty.
- Technical reviewers can challenge a specific step rather than the entire narrative.
- Beginner readers can state the core mechanism after the simple layer.

## Product Path

Personal research skill -> open benchmark library -> educational physics explainer -> interactive claim-analysis service. Use [[Scope Expansion Checklist]] before public submissions, moderation, or high-stakes public claims; the private reproducible-analysis stack stays the same.

## Related

- [[News Depth Telegram Skill]]
- [[Understand This Paper]]
- [[Personal Study Curriculum]]
- [[LongVid Learning Studio]]
- [[Project Ideas Index]]
