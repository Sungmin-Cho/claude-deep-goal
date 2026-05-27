# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.1] — 2026-05-27

### Fixed

- **Plugin manifest** — `repository` in `.claude-plugin/plugin.json` was an object (`{ type, url }`); the Claude Code plugin schema expects a string URL, causing installation to fail with `repository: Invalid input: expected string, received object`. Changed to a plain string URL. (`.codex-plugin/plugin.json` was already a string.)

---

## [1.0.0] — 2026-05-27

Initial release — goal condition compiler for Claude Code and Codex.

### Added

- **Fitness evaluation** — three-verdict rubric (Fit / Needs reshaping / Reject) that judges whether a long-running request suits the native `/goal` feature, with reshape strategies (end-state clarification, scope decomposition, proof-command identification).
- **Condition compiler** — produces conditions with 4 elements (measurable end-state, proof method, invariant constraints, upper bound) plus the evaluator-surfacing rule (the Claude Haiku evaluator can't call tools, so every condition instructs Claude to report step results in the conversation). Enforces the 4,000-character limit, splitting into a `PLAN.md` when conditions grow large or chain 3+ sequential gates.
- **Platform matrix** — Claude vs Codex branch table with platform-specific compilation rules.
- **Prerequisite scout** — inline codebase scan to surface files to read first, proof commands (from `package.json` scripts / Makefile / CI config), and invariant constraints; includes a degraded mode when file tools are unavailable.
- **Synergy recipe — `robust-implementation`** (deep-work + deep-review): phased Research→Plan→Implement→Test with approval gates and a review-loop APPROVE verdict as termination; discloses that approval points still require user input.
- **Synergy recipe — `autonomous-evolution`** (deep-evolve): fitness-metric-driven experiment loop until the target metric is reached or the turn limit is hit.
- **Synergy recipe — `ship-and-document`** (deep-docs + deep-wiki): implementation → optional review gate → docs garden → wiki ingest, with persistent operations placed after review approval.
- **Recipe index** — maps detected sibling plugins to recipe suggestions, with a single-shot goal fallback when nothing matches.
- **Cross-platform entry** — user-invocable `/deep-goal` (Claude Code), `$deep-goal:deep-goal` (Codex), and `Skill({...})` (SDK). The entry skill is self-contained and operates without sibling-skill auto-load.
- **6-step workflow skill** — detect → fitness → reshape → recipe match → prep scout → compile + present.
- **Claude Code and Codex manifests** plus `npm run verify` (release lint + negative self-test).
- **Bilingual documentation** — README, CHANGELOG, and agent guides (CLAUDE.md / AGENTS.md).
