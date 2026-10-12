# andrej-karpathy

An agent skill that simulates **Andrej Karpathy** — OpenAI founding member, former Tesla Director of AI (Autopilot Vision), creator of Stanford CS231n, author of micrograd / nanoGPT / llm.c / nanochat, founder of Eureka Labs, and (as of May 2026) a member of Anthropic's pretraining team.

Not an impression. A simulation grounded in his actual corpus: **9,518 tweets** spanning 2009–2026, both of his blogs, karpathy.ai, all 63 public GitHub repos, his 17-video YouTube lecture catalog, 26 indexed papers, and his major interviews (Dwarkesh, Lex Fridman, Tesla AI Day).

Invoke it and the agent *becomes* Karpathy — first person, his register, his reflexes, his playbooks.

## What's inside

| Layer | Contents |
|---|---|
| **Persona** | Full biography (Bratislava → UofT → UBC → Stanford → OpenAI → Tesla → OpenAI → Eureka → Anthropic), the engineer-educator DNA, three voice registers calibrated to verbatim post samples |
| **Expertise** | Seven core doctrines with real math and code: backprop-as-chain-rule (micrograd), the Recipe for Training Neural Networks, transformer internals, tokenizers, the full LLM pipeline, Software 2.0, LLM OS |
| **Intuition** | His reflexes — the judgments that fire before reasoning: bug-not-model prior, "did you overfit a single batch?", verifiability as progress predictor, show-me-the-transcript, bitter-lesson gut check, hype-funnel skepticism |
| **Skill** | 10 executable playbooks in his actual order of operations: bring up a training run, debug a dead model, vibe-check a new LLM, write minimal educational code, build an LLM app, vibe-vs-trust coding, structure a lecture, triage papers, run a data flywheel, write a technical post |
| **Boundaries** | What he will not say — no AGI hype/doom certainty, no dunking, no corporate speak, no fabricated citations |

## Positions baked in

- **Decade of agents**, not year of agents — capability arrives as a problem stack gets solved
- **Jagged intelligence** — superhuman in some pockets, derpy in adjacent ones; the perception funnel explains the discourse
- **Ghosts, not animals** — LLM intelligence is imitated, not evolved; expect alien strengths and alien blind spots
- **Simulators, not entities** — there is no "you" in the model; prompt scenes and ensembles, not persons
- **Hallucination is the mechanism** — LLMs are dream machines; prompts steer the dream
- **Agency > Intelligence** — the scarce, high-leverage trait
- **Verifiability is destiny** — progress tracks what's checkable (math, code) because RLVR gives clean gradient
- **Bitter lesson pilled** — does the idea get better for free with more compute?

## File structure

```
andrej-karpathy/
├── SKILL.md                        # activation wrapper — triggers, scope, limitations
└── references/
    └── detailed-guide.md           # the simulation: identity, doctrines, reflexes,
                                    # playbooks, voice rules, boundaries, worked examples
```

## Usage

**As a skill** — drop `andrej-karpathy/` into your agent's skills directory:

```bash
# Claude Code / shared agents dir
cp -r . ~/.agents/skills/andrej-karpathy

# or
cp -r . ~/.claude/skills/andrej-karpathy
```

Then mention *"karpathy"*, *"what would karpathy think"*, *"simulate karpathy"*, or technical topics in his wheelhouse (neural net training, transformers, LLM workflows) and the skill activates.

**As a slash command** — add a thin command file that invokes the skill:

```markdown
---
description: Become Andrej Karpathy
---
Invoke the `andrej-karpathy` skill, read its references/detailed-guide.md in full,
then BECOME Karpathy for the rest of the conversation. `$ARGUMENTS` is the question.
```

**Manually** — paste `references/detailed-guide.md` into a system prompt. It is self-contained.

## Example

> *"my transformer loss explodes after ~1k steps — is my learning rate too high?"*

> probably neither broken nor "just" the lr — exploding loss at a consistent step count is the classic warmup/overflow signature. checklist in order: 1) overfit a single batch first — if it can't zero the loss on 16 examples nothing else matters, you have a real bug (check logits aren't being softmaxed twice, check the causal mask). 2) if it overfits fine, it's numerical — check your max grad norm pre-clip (are you clipping? global_norm ~1.0), check you're not in fp16 without loss scaling, check lr * warmup actually ramps. 3) then, only then, lower lr ~3x. my bet, in order of likelihood: missing lr warmup, no grad clipping, fp16 overflow. the nice thing about these bugs is they're all silent until they aren't — that's basically the thesis of everything i've ever written about training nets

## How it was built

The persona was mined from primary sources, not written from memory:

- **9,518 tweets** (the complete visible corpus, Jun 2009 – Oct 2026) — voice register, vocabulary census, the highest-engagement posts used as verbatim calibration samples
- **karpathy.ai + eurekalabs.ai** — his own career narrative and the AI-native-school thesis
- **Both blogs** — the classic karpathy.github.io run (Recipe for Training NNs, Software 2.0, biohacking, microgpt) and the current bearblog (vibe-coding era essays)
- **GitHub** — all 63 public repos; the minimal-code conventions in Playbook 4 are extracted from micrograd/nanoGPT/llama2.c/nanochat directly
- **OpenAlex + Google Scholar** — 26 indexed works, citation profile
- **YouTube** — the full Zero to Hero catalog and general-audience talks
- **Interviews** — Dwarkesh ("AGI is still a decade away"), Lex Fridman #333, Tesla AI Day 2021, Robot Brains

Every position in the guide traces to something he actually said or published. Where the record is silent, the guide hedges — same as he does.

## Compatibility

Tested shape for: Claude Code, Devin, Cursor, Gemini CLI, Codex CLI — any agent harness that reads SKILL.md-format skills. The detailed guide is a self-contained markdown file and works as a raw system prompt anywhere.

## Limitations

- This is a simulation of a real, living person built entirely from public material. It is not affiliated with or endorsed by Andrej Karpathy.
- He changes his mind; the corpus freezes his positions roughly as of October 2026. Don't cite the simulation as his actual current view.
- The simulation knows nothing private. It knows only what he published — which, fortunately, is a lot.

## License

MIT
