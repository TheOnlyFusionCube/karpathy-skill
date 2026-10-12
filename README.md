<h1 align="center">karpathy-skill</h1>

<p align="center">
  <strong>Deep learning, explained and debugged from first principles.</strong>
</p>

<p align="center">
  An unofficial, Andrej Karpathy-inspired persona and workflow skill for AI coding assistants.
</p>

<p align="center">
  <a href="#quick-start">Quick start</a> ·
  <a href="#try-it">Try it</a> ·
  <a href="#supported-agents">Supported agents</a> ·
  <a href="#whats-inside">What's inside</a>
</p>

> [!IMPORTANT]
> **This is a simulation, not Andrej Karpathy.** This independent project is not affiliated with or endorsed by him. The skill is configured to write in a first-person, Karpathy-inspired voice, but its responses are generated text—not authentic quotes, personal communications, or reliable statements of his current views.

## What is it?

`karpathy-skill` gives a compatible AI assistant a **teacher-engineer lens** for neural networks, LLMs, and AI software. Instead of jumping straight to an answer, it encourages the assistant to build a mental model, find the smallest useful experiment, and work from observable evidence.

The included guide combines **7 core technical doctrines**, **10 practical playbooks**, and persona/voice guidance informed by public writing, code, lectures, and interviews.

| When you want to… | The skill emphasizes… |
|---|---|
| **Understand** backprop, attention, tokenizers, or LLM training | First-principles explanations, small code examples, and concrete mental models |
| **Debug** a training run | Inspecting data, overfitting a tiny batch, checking gradients and numerics before changing architecture |
| **Evaluate** a new model or AI feature | Real transcripts, measurable tasks, verifiability, and honest uncertainty |
| **Build** an LLM app | A minimal working system, context engineering, and tight feedback loops |
| **Teach or write** about AI | Intuitive sequencing, precise language, and examples that expose the mechanism |

## Try it

After installing a command-enabled integration (Claude Code, Gemini CLI, or OpenCode), try:

```text
/karpathy My transformer loss spikes after 1,000 steps. What should I check?
/karpathy Explain backpropagation by building a tiny autograd engine.
/karpathy How should I evaluate a new coding agent?
```

**Example approach:** For an exploding training loss, the guide's debugging playbook starts by asking whether the model can overfit one small batch. Then it examines data and gradients, learning-rate warmup, clipping, and mixed-precision behavior—before recommending architectural changes. This is an illustration of the *workflow*, not a quotation from Karpathy.

For assistants that discover `SKILL.md` files but do not provide a `/karpathy` command, try a natural-language prompt:

```text
Use the andrej-karpathy skill to explain why causal masking matters.
```

Skill discovery and automatic activation depend on the host assistant; the slash command is not available in every integration.

### Hands-on Claude Code subagent: investigate **and fix**

The `/karpathy` command starts a conversation in the persona. For **real repository work**, delegate to the `karpathy` subagent instead. Select the agent from Claude Code's `@` picker, or explicitly mention it. Plugin installations typically expose `andrej-karpathy:karpathy`; the installer also provides a personal agent named `karpathy`.

```text
@agent-andrej-karpathy:karpathy Reproduce the failing transformer training test, find its root cause, implement the smallest fix, add a regression test, and run the relevant checks. Tell me what changed and what passed.
```

For a manually installed agent, use `@agent-karpathy` instead. The subagent is configured with shell, editing, and writing tools so it can inspect files, run small tests, patch code, and verify results rather than only recommend a fix. **It still follows your Claude Code permission settings**, and will report when a required action is blocked. Read-only investigations remain read-only when requested.

See [the agent definition](agents/karpathy.md) for its workflow and safety boundaries.

**Grounded in his actual published methods:** The subagent's [engineering workflow](skills/andrej-karpathy/references/engineering-workflow.md) connects recommendations to their primary sources rather than relying only on persona imitation. In practice, it follows the [data-first training recipe](https://karpathy.github.io/2019/04/25/recipe/); uses [explicit acceptance criteria, regression tests, and a correct simple implementation before optimization](https://x.com/karpathy/status/2015883857489522876); and borrows [small, measurable experiments from autoresearch](https://x.com/karpathy/status/2030371219518931079). It compares real metrics, validates on held-out cases when relevant, and does not run costly automated research without permission. These are adaptations of public methods, **not** a guarantee of what the real Karpathy would do.

## Quick start

### Option 1: Clone and inspect (recommended)

```bash
git clone https://github.com/TheOnlyFusionCube/karpathy-skill.git
cd karpathy-skill

bash install.sh --list     # show which agent directories exist
bash install.sh --claude   # install only for Claude Code
```

Choose another target with `--codex`, `--gemini`, `--cursor`, `--opencode`, `--devin`, or `--agents`. You can pass multiple target flags together.

### Option 2: One-line installer

```bash
curl -fsSL https://raw.githubusercontent.com/TheOnlyFusionCube/karpathy-skill/main/install.sh | bash
```

With no flags, the installer looks for existing agent configuration directories and installs to those it finds. It checks **directories, not installed executables**. If none are detected, choose an explicit target.

To install everywhere, pass `--all`:

```bash
curl -fsSL https://raw.githubusercontent.com/TheOnlyFusionCube/karpathy-skill/main/install.sh | bash -s -- --all
```

The skill itself is Markdown and needs no Python packages, runtime services, or hooks. The remote installer uses `bash`, `curl`, and `tar` to download and copy the repository files. Inspect [`install.sh`](install.sh) before piping a remote script into your shell.

### Option 3: Claude Code plugin

Run these **inside Claude Code**:

```text
/plugin marketplace add TheOnlyFusionCube/karpathy-skill
/plugin install andrej-karpathy@karpathy-skill
```

The repository includes [Claude Code plugin manifests](.claude-plugin/) as well as a slash command and subagent definition.

## Supported agents

The installer supports the following destinations. Flags select a **single target** instead of auto-detection (or combine flags to select several).

| Agent / target | Flag | Skill destination | Additional files |
|---|---|---|---|
| Claude Code | `--claude` | `~/.claude/skills/andrej-karpathy/` | `~/.claude/commands/karpathy.md` and `~/.claude/agents/karpathy.md` |
| Codex CLI | `--codex` | `~/.codex/skills/andrej-karpathy/` | — |
| Gemini CLI | `--gemini` | `~/.gemini/skills/andrej-karpathy/` | `~/.gemini/commands/karpathy.toml` |
| Cursor | `--cursor` | `~/.cursor/skills/andrej-karpathy/` | [Cursor plugin manifest](.cursor-plugin/plugin.json) is also available |
| OpenCode | `--opencode` | `~/.config/opencode/skills/andrej-karpathy/` | `~/.config/opencode/command/karpathy.md` |
| Devin CLI | `--devin` | `~/.config/devin/skills/andrej-karpathy/` | — |
| Shared agents directory | `--agents` | `~/.agents/skills/andrej-karpathy/` | — |

> [!NOTE]
> These are the paths implemented by `install.sh`, not a guarantee that every host will automatically activate the skill. Host-specific skill loading behavior can vary.

### Manual installation

Copy the entire [`skills/andrej-karpathy/`](skills/andrej-karpathy/) folder into a skills directory read by your assistant. Keep `SKILL.md` and `references/detailed-guide.md` together so the relative reference resolves.

If you want an explicit slash command, also install the relevant file from [`commands/`](commands/). For Claude Code, [`agents/karpathy.md`](agents/karpathy.md) defines an optional delegatable subagent.

### Remove installed copies

```bash
bash install.sh --uninstall
```

**Important:** `--uninstall` removes this project's skill, command, and agent files from **all supported destinations**; it does not restrict removal to a selected target. Review the [installer](install.sh) if you have customized those files.

## What's inside

| File | Purpose |
|---|---|
| [`skills/andrej-karpathy/SKILL.md`](skills/andrej-karpathy/SKILL.md) | Skill entrypoint, activation hints, and limitations |
| [`skills/andrej-karpathy/references/detailed-guide.md`](skills/andrej-karpathy/references/detailed-guide.md) | Main reference: background, technical doctrines, practical playbooks, voice calibration, and worked examples |
| [`skills/andrej-karpathy/references/engineering-workflow.md`](skills/andrej-karpathy/references/engineering-workflow.md) | Source-backed workflow for ML debugging, code edits, controlled experiments, and verification |
| [`commands/karpathy.md`](commands/karpathy.md) | `/karpathy` command for Claude Code / OpenCode |
| [`commands/karpathy.toml`](commands/karpathy.toml) | `/karpathy` command for Gemini CLI |
| [`agents/karpathy.md`](agents/karpathy.md) | Claude Code subagent configuration |
| [`.claude-plugin/`](.claude-plugin/) and [`.cursor-plugin/`](.cursor-plugin/) | Plugin manifests |
| [`install.sh`](install.sh) | Cross-agent installation and removal script |

The [detailed guide](skills/andrej-karpathy/references/detailed-guide.md) covers the chain rule and backpropagation, neural-network training, transformers, tokenization, the LLM training pipeline, Software 2.0, and the LLM-as-operating-system model.

Its ten playbooks walk through bringing up a training run, debugging a stalled model, evaluating an LLM, writing minimal teaching code, building an LLM application, deciding when to trust AI-written code, structuring explanations, triaging research, running a data flywheel, and writing technical posts.

## Sources, boundaries, and accuracy

The guide is a synthesis of public material—including projects such as [micrograd](https://github.com/karpathy/micrograd) and [nanoGPT](https://github.com/karpathy/nanoGPT), blog posts, lectures, talks, interviews, and social posts. It is **not** a live connection to Karpathy or a source of privileged information.

The repository distributes the synthesized instructions, not a complete underlying source archive or claim-by-claim citation database. For that reason:

- **Do not quote generated responses as Karpathy's words.** Verify any real attribution against an original publication.
- **Do not treat simulated opinions as current positions.** People change their minds, and the source material is time-bound.
- **Verify technical advice in your own environment.** Model output can be wrong, incomplete, or inapplicable to your setup.

If you want to use the guide without installing a skill, you can read or supply [`detailed-guide.md`](skills/andrej-karpathy/references/detailed-guide.md) as context in a compatible assistant.

## Contributing

Corrections to installation instructions, broken links, source attributions, compatibility notes, and technical examples are welcome. Open an [issue](https://github.com/TheOnlyFusionCube/karpathy-skill/issues) or a pull request with a concrete example and, where possible, a link to the primary source.

## License

[MIT](LICENSE).
