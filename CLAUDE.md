# deep-goal — Project Guide for Claude

Goal condition compiler that evaluates long-running task requests, reshapes them to fit, scouts prerequisites, and compiles ready-to-paste native `/goal` conditions for Claude Code and Codex.

For detailed version history see [`CHANGELOG.md`](CHANGELOG.md) / [`CHANGELOG.ko.md`](CHANGELOG.ko.md). This file is intentionally short — it holds the overview, structure, and drift-resistant conventions only.

To check the current version: `jq -r .version .claude-plugin/plugin.json`

---

## Project Overview

**deep-goal** is a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) / Codex plugin that acts as a **meta-Guide**: it evaluates whether a long-running task request is a good fit for the native `/goal` feature, reshapes requests that need adjustment, scouts prerequisites in the codebase, and compiles a platform-tailored `/goal` condition the user copies and pastes to activate.

**Identity**: deep-goal is the "orchestration on-ramp" of the deep-suite — it consumes the entry points of sibling plugins (deep-work, deep-review, deep-evolve, deep-docs, deep-wiki) and emits `PLAN.md` + `/goal` conditions. Three synergy recipes encode the most common multi-plugin compositions.

**Key constraint (non-negotiable)**: Native `/goal` cannot be invoked programmatically by a plugin. deep-goal's role ends at presenting the compiled condition; the user triggers activation.

**No runtime artifacts**: No `agents/`, `hooks/`, persistent state files, or caches. One-shot compilation; all work is content + skills.

**Marketplace presence**: Part of the [claude-deep-suite](https://github.com/Sungmin-Cho/claude-deep-suite) marketplace.

---

## 🚨 CRITICAL — Plugin Update Workflow

**Every deep-goal release must be accompanied by the following work. No exceptions.**

### 1. Sync the deep-suite marketplace (required)

Update the following in `/Users/sungmin/Dev/claude-plugins/deep-suite/`:

- **`.claude-plugin/marketplace.json`** and **`.agents/plugins/marketplace.json`** — under the `deep-goal` entry: `sha` = full 40-character merge commit hash on the new `main`; description = one-line headline summary.
- **`README.md`** / **`README.ko.md`** — the `deep-goal` row in the Plugins table and any narrative sections that reference the version.

After editing:
```bash
cd /Users/sungmin/Dev/claude-plugins/deep-suite
git add .claude-plugin/marketplace.json .agents/plugins/marketplace.json README.md README.ko.md
git commit -m "chore: bump deep-goal to vX.Y.Z — <one-line summary>"
git push
```

### 2. Version triple-sync (required)

Bump the version in all three manifests together — they must always match:
- `.claude-plugin/plugin.json`
- `.codex-plugin/plugin.json`
- `package.json`

`npm run verify` enforces this with a grep check; a mismatch causes `exit=1`.

### 3. Update CHANGELOG (both languages, required)

- Add a new version entry to both `CHANGELOG.md` and `CHANGELOG.ko.md` using [Keep a Changelog](https://keepachangelog.com/) format.
- **Do NOT inline release notes in this CLAUDE.md** — CHANGELOG is the single source of truth.

---

## Directory Structure

```
deep-goal/
├── .claude-plugin/plugin.json          # Claude Code manifest
├── .codex-plugin/plugin.json           # Codex manifest (skills + interface)
├── package.json                         # type: module, npm verify script
├── scripts/
│   ├── verify-plugin.sh                # grep-based release-lint (positive checks)
│   └── verify-selftest.sh              # negative self-test (meta-verification)
├── skills/
│   ├── deep-goal/
│   │   └── SKILL.md                    # thin user entry (user-invocable: true), self-contained
│   └── deep-goal-workflow/
│       ├── SKILL.md                    # core 6-step workflow (auto-loaded, user-invocable: false)
│       └── references/
│           ├── fitness-rubric.md       # goal fitness judgment criteria
│           ├── condition-compiler.md   # 4 elements + evaluator-surfacing rule
│           ├── platform-matrix.md      # Claude vs Codex branch table
│           ├── prep-scout.md           # prerequisite scouting procedure
│           └── recipes/
│               ├── README.md           # recipe index + plugin detection rules
│               ├── robust-implementation.md
│               ├── autonomous-evolution.md
│               └── ship-and-document.md
├── CLAUDE.md / AGENTS.md
├── README.md / README.ko.md
└── CHANGELOG.md / CHANGELOG.ko.md
```

---

## Key Concepts

### Activation model (non-negotiable)

Native `/goal` **cannot be auto-invoked** by a plugin or skill. The Claude Code Agent SDK dispatch list covers `/compact`, `/clear`, `/context`, `/usage` — `/goal` is excluded. Agent output containing `/goal` text is treated as plain text, not a command.

deep-goal's role: evaluate → reshape → compile → **present**. The user copies the condition and triggers `/goal <condition>` manually. Activation friction is minimized to a one-line copy-paste.

### The 4 compile elements

Every compiled `/goal` condition must contain:
1. **Measurable end-state** — test result, build exit code, file count, empty queue, etc.
2. **Proof method** — the command or artifact that demonstrates completion
3. **Invariant constraints** — what must not change along the way
4. **Upper bound** — turn or time limit (`or stop after N turns`)

### Evaluator surfacing rule (Claude-specific)

The Claude `/goal` evaluator (Haiku by default) **cannot call tools** — it judges only from output Claude has already surfaced to the conversation. Therefore every compiled condition must instruct Claude to "report each step result explicitly in the conversation." Without this instruction, the evaluator cannot determine completion.

### Synergy recipes

Three knowledge documents in `references/recipes/` encode multi-plugin compositions:
- **robust-implementation** — deep-work + deep-review: phased implementation with approval gates and review-loop APPROVE verdict
- **autonomous-evolution** — deep-evolve: fitness-metric-driven experiment loop until target reached
- **ship-and-document** — deep-docs + deep-wiki: post-implementation docs gardening + wiki ingest (with optional review gate before persistent operations)

Recipes are applied only when the relevant sibling plugins are detected. Unmatched requests fall back to single-shot goal.

---

## Slash commands

| Command | Description |
|---|---|
| `/deep-goal <task>` | Evaluate and compile a long-running task into a `/goal` condition |
| `/deep-goal` (no args) | Interactive entry — asks "What do you want to run to completion?" |

Codex user entry: `$deep-goal:deep-goal <task>`

---

## Tests

```bash
npm run verify
# = bash scripts/verify-plugin.sh && bash scripts/verify-selftest.sh
```

- **`verify-plugin.sh`**: grep-based release-lint (positive checks — file existence, frontmatter, content invariants, version sync, CHANGELOG entry, no placeholder tokens).
- **`verify-selftest.sh`**: negative self-test — confirms that `verify-plugin.sh` actually catches violations (placeholder gate, multi-element self-containment check, activation invariant reversal). Prevents silent checker rot.

Latest release (v1.0.0) shipped at `Passed: N, Failed: 0` with `verify-selftest.sh: ALL-PASS`.

---

## Related repositories

- **deep-suite (marketplace)**: https://github.com/Sungmin-Cho/claude-deep-suite — `/Users/sungmin/Dev/claude-plugins/deep-suite`
- **deep-work**: https://github.com/Sungmin-Cho/claude-deep-work
- **deep-review**: https://github.com/Sungmin-Cho/claude-deep-review
- **deep-evolve**: https://github.com/Sungmin-Cho/claude-deep-evolve
- **deep-docs**: https://github.com/Sungmin-Cho/claude-deep-docs
- **deep-wiki**: https://github.com/Sungmin-Cho/claude-deep-wiki
- **deep-dashboard**: https://github.com/Sungmin-Cho/claude-deep-dashboard

---

**Reminder**: This CLAUDE.md is intentionally kept short. For every new release:

1. **Write the details in CHANGELOG** (not here — prevents drift)
2. **Only update Key Concepts** if a core rule (activation model, 4 elements, evaluator constraint) actually changes
3. **Sync the deep-suite marketplace** (see the "CRITICAL" section above)
