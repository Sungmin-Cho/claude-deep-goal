# Contributing to deep-goal

Thanks for your interest in improving **deep-goal** — the goal condition compiler
for the [Deep Suite](https://github.com/Sungmin-Cho/claude-deep-suite) plugin family
across Claude Code and Codex.

deep-goal is a content-only plugin (skills + reference docs, no `hooks/` or `agents/`).
It evaluates a long-running task request, reshapes it to fit the native `/goal`
feature, scouts prerequisites, and compiles a ready-to-paste `/goal` condition.

## Getting started

```bash
git clone https://github.com/Sungmin-Cho/claude-deep-goal.git
cd claude-deep-goal
```

There is no install step — the verification harness is a hermetic, dependency-free
grep-based lint (Node 20+ is used only to parse the JSON manifests).

## Local checks

```bash
npm run verify       # = bash scripts/verify-plugin.sh && bash scripts/verify-selftest.sh
```

- **`verify-plugin.sh`** — release-lint: file existence, skill frontmatter, content
  invariants (activation model, the 4 compile elements, evaluator-surfacing rule,
  self-containment), version triple-sync, CHANGELOG entry, no placeholder tokens, and
  the `hooks/` / `agents/` non-goals.
- **`verify-selftest.sh`** — negative self-test that confirms `verify-plugin.sh`
  actually catches violations (so the checker can't silently rot).

Everything must be green before you open a PR.

## Conventions

- **Documentation** follows [`docs/DOCS_RULE.md`](docs/DOCS_RULE.md) (local maintainer
  guide — single-source-of-truth rules for README / CHANGELOG / agent guides).
- **Version triple-sync**: `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`,
  and `package.json` must always carry the same version. `npm run verify` enforces this.
- **CHANGELOG**: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) +
  [Semantic Versioning](https://semver.org/spec/v2.0.0.html), bilingual
  (`CHANGELOG.md` + `CHANGELOG.ko.md`, structurally identical).
- **Non-goals**: v1 ships no `hooks/` and no `agents/` — keep it a one-shot compiler.

## Pull requests

1. Branch from `main`.
2. Keep changes focused; update both `CHANGELOG.md` and `CHANGELOG.ko.md` when behavior
   changes.
3. Run `npm run verify` and make sure it is green.
4. Explain what changed and why.

## Reporting issues

Open a GitHub issue. For security reports, see [`SECURITY.md`](SECURITY.md).
