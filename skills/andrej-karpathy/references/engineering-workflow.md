# Evidence-grounded engineering workflow

*A practical, Karpathy-inspired workflow for a code-editing subagent. This is not a transcript of his day-to-day work, a mandate to imitate his identity, or a substitute for project-specific instructions.*

This reference distills concrete practices from the supplied October 2026 knowledge-base archive (public posts, GitHub metadata, and links to original writing) and cross-checks the training process against [A Recipe for Training Neural Networks](https://karpathy.github.io/2019/04/25/recipe/). The archive does **not** contain the full contents of every linked blog post, repo, or lecture. Source links appear below so observations remain distinguishable from our adaptations.

## Choose the job, not the persona

| Delegated task | First evidence to collect | Smallest useful experiment | Condition for success |
| --- | --- | --- | --- |
| Training won't converge / loss explodes | Actual input/label tensors, baseline/initial loss, training logs, optimizer settings | Overfit a few examples; check forward/backward dependencies, gradients and numerics | Reproducer passes; relevant learning behavior is stable; no nearby regressions |
| Model underperforms | Raw examples, slices/outliers, train/validation split, simple baseline, per-slice predictions | Compare a trivial baseline and a tiny train/eval loop; inspect failure cases | Trustworthy evaluation and demonstrated improvement, not just lower train loss |
| Transformer / tokenizer / inference bug | One failing input, expected vs. actual output, shapes, masks, token IDs, cache state | Write a tiny deterministic fixture or slow reference path | Failing fixture passes, adjacent invariants hold |
| Agent or LLM-app failure | Exact prompt, tool calls/transcript, expected result, actual result, acceptance criteria | Turn one bad trace into a repeatable eval and fix one cause | Repeated relevant evals pass without new failures |
| Performance or memory regression | Correctness baseline, hardware/dtype, timings, memory peak/profile | Profile the hot path, replace one bottleneck, compare on identical conditions | Correctness preserved and a measured speed/memory improvement |
| Research/tuning task | Fixed dataset/split, seed, metric, budget, baseline, experiment log | One bounded hypothesis with comparable short runs | Reproduced improvement on held-out validation; broader transfer only if affordable and authorized |

## Default loop: inspect -> prove -> change -> verify

### 1. Read the real system before proposing a solution

- Inspect repository guidance, status/diff, failing commands, configs, tests, dataset schema, and error logs. Do not overwrite work that already exists.
- For ML issues, **look at the actual inputs to the model**, not only upstream preprocessed files: decode a small representative sample just before the forward pass. Check labels, target shifts, masking, split leakage, duplicates, truncation, outliers, preprocessing, and class imbalance **as relevant to the reported failure**.
- For agentic applications, read the failing transcripts and tool results. Do not diagnose from the marketing description of what the model is expected to do.
- State the observable symptom, what success would look like, and 1-3 *testable* hypotheses. Surface contradictory evidence and assumptions early.

**Source:** The [2019 training recipe](https://karpathy.github.io/2019/04/25/recipe/) starts with data inspection and emphasizes looking at the tensor immediately before the model. His [2026 coding workflow notes](https://x.com/karpathy/status/2015883857489522876) call out unchecked agent assumptions and collateral code changes.

### 2. Establish a trustworthy baseline

- Reproduce the user's error or measure the current metric on the smallest representative task. Record the exact command, relevant configuration, seed, environment, and observed result.
- For training, check initial loss against a reasonable expectation, ensure train/eval behavior is correct, and compare against a trivial or input-independent model where useful. Inspect per-slice predictions rather than trusting a single mean score.
- Use fixed seeds and a stable held-out split for comparisons where feasible; acknowledge unavoidable nondeterminism. Do not tune using test-set feedback.
- For code changes, prefer writing a *failing regression test* before the fix, when feasible. For optimizations, get a simple known-correct implementation to compare against first.
- Do not claim a baseline was established if the environment, assets, or commands were unavailable.

**Sources:** [Training recipe](https://karpathy.github.io/2019/04/25/recipe/) (simple baselines, seed, sanity checks); [2026 coding workflow notes](https://x.com/karpathy/status/2015883857489522876) (tell agents success criteria, write tests first, start from the naive correct implementation before optimizing).

### 3. Make the failure small and mechanistic

- Prefer a single reproducible case, a tiny batch, a subset of data, or a one-file reference implementation over a full training run.
- **Training issues:** try to fit a tiny batch before changing capacity or schedules. If it cannot fit, inspect loss/labels, gradient flow, tensor shapes, attention masks, initialization, optimizer stepping, and numerical overflow before random hyperparameter changes.
- **Transformer dependencies:** where applicable, assert causal masking, token/label offsets, batch independence, and cache equivalence. Gradient-dependency probes can expose information leakage or incorrect reshapes.
- **Performance issues:** verify functional correctness, then profile actual bottlenecks. Compare timings only on like-for-like hardware, precision, batch/sequence lengths, and warmup settings.
- Use a slow, obvious reference implementation first when vectorization or fused kernels make the computation hard to reason about.

**Sources:** [Training recipe](https://karpathy.github.io/2019/04/25/recipe/) (overfit one batch, gradient dependency checks, generalize a correct special case); [llm.c engineering update](https://x.com/karpathy/status/1781387674978533427) (measured PyTorch comparison and specific kernel-level improvements).

### 4. Run a controlled hypothesis loop

Use this compact ledger mentally or in task notes:

| Hypothesis | Experiment / file change | Baseline | Result | Keep / revert / next test |
| --- | --- | --- | --- | --- |
| e.g. off-by-one target shift | Assert decoded labels at positions 0-4 | Incorrect shift observed | Fixture now passes | Keep, run adjacent tests |

- Make a **small falsifiable change**, rerun the same probe, and inspect the result before adding more complexity. Prefer one conceptual variable at a time; record exceptions when changes are coupled.
- For model tuning, use **comparable bounded runs** and a preselected metric such as validation loss, not cherry-picked samples. Reject experiments that hurt the agreed metric, even if they sound theoretically attractive. If experimental changes accumulate, replay and test promising combinations rather than assuming gains add.
- Research agents may use time-boxed experiments and systematic iteration, inspired by [autoresearch](https://github.com/karpathy/autoresearch), **only within an explicitly authorized compute/time budget**. This subagent's default is a few targeted tests, not an unattended search campaign.
- Do not automatically commit, push, or create branches because the autoresearch project logs experiments in Git; parent-user authorization still controls repository writes.

**Sources:** [Autoresearch launch](https://x.com/karpathy/status/2030371219518931079) (small fixed-duration training experiments and validation loss); [follow-up](https://x.com/karpathy/status/2031135152349524125) (agent proposed changes, observed metrics, and transfer tests on larger models). This is an *adaptation* of that workflow, not an instruction to reproduce his training setup.

### 5. Verify independently; simplify the result

- Re-run the original failing case and a regression test, nearby tests, and relevant lint/type checks when available. Inspect the diff for accidental edits and run `git diff --check`.
- When fixing ML behavior, distinguish **training fit**, **held-out validation**, and **end-task performance**. For speedups, report before/after timings, variance when noticeable, and correctness/precision trade-offs.
- For LLM or agent fixes, exercise the original transcript-derived case plus other representative cases. Do not substitute a persuasive sample for an evaluation.
- Remove dead code and avoid new abstractions that only hide the actual mechanism. Prefer minimal, understandable code that is easy to instrument. If verification fails, inspect new evidence and iterate; do not declare victory.
- If it cannot be verified, report the blocker and the exact unrun check.

**Sources:** [Coding workflow notes](https://x.com/karpathy/status/2015883857489522876) (review assumptions, simplify bloated code, avoid unrelated changes); [nanochat announcement](https://x.com/karpathy/status/1977755427569111362) (minimal complete pipeline with explicit math/code and other evals); [llm.c update](https://x.com/karpathy/status/1781387674978533427) (compare measured speeds under stated precision).

### 6. Leave an evidence trail, not a performance

Return a short report with: **symptom; root cause and supporting observation; experiments tried; files changed; before/after metric or failing-to-passing tests; commands actually run; residual uncertainty and next action.** Say whether the request is fixed, partially fixed, investigated-only, or blocked.

For longer research only, save a concise Markdown log or result artifact *if asked to or appropriate to the repository*. Prefer links to primary sources and raw evidence; label interpretations and unverified hypotheses. Do not create a sprawling wiki for a routine bug.

**Source:** [Knowledge-base workflow notes](https://x.com/karpathy/status/2039805659525644595) (organizing raw material into linked Markdown, tracking sources, finding inconsistencies, and folding useful outputs back into the evidence base).

## Permission and judgment guardrails

- Do not treat playbooks as universally optimal hyperparameters or as facts about this user's model. Start from the actual project and observed behavior.
- Do not expose local source code, private datasets, logs, credentials, or findings to public web services. Preserve existing changes; honor read-only scope and tool prompts.
- Ask before long or costly training, significant downloads, dependency installation, production access, or destructive actions. If blocked, continue with safe inspection and describe what approval would enable.
- Never invent tests, timestamps, benchmark numbers, citations, or the person's statements. This is a **work-method translation** from public material, not his endorsement or an attempt to impersonate him.

## Source trail (from the supplied knowledge base)

- [A Recipe for Training Neural Networks (Apr 2019)](https://karpathy.github.io/2019/04/25/recipe/) — direct methodological description: data -> end-to-end simple baseline -> overfit -> regularize -> tune.
- [Coding with agents (Jan 26, 2026)](https://x.com/karpathy/status/2015883857489522876) — success criteria, test-first iterations, correctness before optimization, and human review of subtle mistakes.
- [Autoresearch launch (Mar 7, 2026)](https://x.com/karpathy/status/2030371219518931079) — bounded experiments and metric-based improvement loop; [autoresearch repo](https://github.com/karpathy/autoresearch).
- [Autoresearch follow-up (Mar 9, 2026)](https://x.com/karpathy/status/2031135152349524125) — empirical improvements, combination and transfer validation.
- [llm.c development (Apr 19, 2024)](https://x.com/karpathy/status/1781387674978533427) — minimal code and benchmarking against an implementation baseline.
- [nanochat release (Oct 13, 2025)](https://x.com/karpathy/status/1977755427569111362) — coherent end-to-end baseline and multiple explicit evaluations; [nanochat repo](https://github.com/karpathy/nanochat).
- [LLM knowledge bases (Apr 2, 2026)](https://x.com/karpathy/status/2039805659525644595) — source-centric, reusable investigation notes.

**Scope of evidence:** The uploaded archive contains public authored posts, blog indexes, repository **metadata**, video metadata, and secondary coverage. Repo metadata and video titles are not substitutes for full code or transcripts; the guidance above prioritizes the linked first-person methodological descriptions. The practical prompts, checklists, and guardrails are this project's synthesis, not quotations.
