# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-05-27

### Added

**Core — evaluation, reshape, compile, prerequisite scout**
- Fitness rubric (`references/fitness-rubric.md`): three-verdict judgment system — Fit / Needs reshaping / Reject — with concrete examples for each verdict and reshape strategies (end-state clarification, scope decomposition, proof-command identification).
- Condition compiler (`references/condition-compiler.md`): 4-element compilation rule (measurable end-state, proof method, invariant constraints, upper bound) with evaluator-surfacing rule (Claude Haiku evaluator cannot call tools; every condition must instruct Claude to report step results explicitly in conversation). 4,000-character limit with PLAN.md split strategy at ~2,800 chars or 3+ sequential gates.
- Platform matrix (`references/platform-matrix.md`): Claude vs Codex branch table with platform-specific compilation rules and examples.
- Prerequisite scout (`references/prep-scout.md`): inline codebase scan procedure (Glob/Grep/Read) to discover files to read first, proof commands from `package.json` scripts / Makefile / CI config, and invariant constraints. Includes no-file-tools degraded mode.

**Synergy recipes — 3 multi-plugin compositions**
- `robust-implementation`: deep-work + deep-review recipe. Research→Plan→Implement→Test phases with Plan approval gate and Exit Gates. deep-review-loop(--max=3) after Implement. Termination: all phases complete AND all approval gates reported AND final deep-review-loop APPROVE AND tests pass. Documents that full autonomy is not possible — goal removes turn-by-turn prompts but approval/confirmation points require user input.
- `autonomous-evolution`: deep-evolve recipe. Fitness-metric-driven experiment loop until target metric reached or turn limit hit. Metric value reported in conversation each iteration. Notes interaction between deep-evolve's own measurement loop and native goal turn bound.
- `ship-and-document`: deep-docs + deep-wiki recipe. Implementation assumed complete → (if deep-review present) final review gate first → deep-docs garden → wiki-ingest. Persistent operations (wiki ingest) placed after review approval. Rollback guidance included if order cannot be preserved.
- Recipe index (`references/recipes/README.md`): plugin detection rules mapping detected sibling plugins to recipe suggestions. Multi-recipe selection rule. Single-shot goal fallback when no recipe matches.

**Entry and workflow skills (cross-platform)**
- User-invocable entry skill (`skills/deep-goal/SKILL.md`): self-contained — inlines activation model, 3-verdict fitness summary, 4 compile elements, evaluator-surfacing rule, and platform branch summary. Operates without sibling skill auto-load. Invocation documented for Claude Code (`/deep-goal`), Codex (`$deep-goal:deep-goal`), and SDK (`Skill({...})`).
- Core workflow skill (`skills/deep-goal-workflow/SKILL.md`): 6-step orchestration with references load rules (description-match auto-load → Skill() explicit call → Read fallback → degrade without references). Platform-neutral root resolution (`$CLAUDE_PLUGIN_ROOT` or relative from entry SKILL path or glob search).

**Cross-platform manifests and verification**
- Claude Code manifest (`.claude-plugin/plugin.json`) and Codex manifest (`.codex-plugin/plugin.json`) with `skills` + `interface` fields and `defaultPrompt` using `$deep-goal:deep-goal`.
- `package.json` with `type: module` and `npm run verify` combining positive lint + negative self-test.
- `scripts/verify-plugin.sh`: grep-based release-lint covering file existence, frontmatter, content invariants (activation model, 4 compile elements, evaluator surfacing, self-containment), version triple-sync, CHANGELOG entry, no placeholder tokens, no `hooks/`/`agents/` dirs.
- `scripts/verify-selftest.sh`: negative self-test confirming the checker catches placeholder violations, multi-element self-containment failures, and activation-invariant reversals. Integrated as release gate via `npm run verify`.

**Project guides**
- `CLAUDE.md`: project guide for Claude — overview, directory structure, key concepts (activation model, 4 elements, evaluator surfacing, recipes), slash commands, tests, release workflow with deep-suite marketplace sync, related repositories.
- `AGENTS.md`: Codex project guide — runtime surfaces, verification commands, post-merge deep-suite sync instructions.
- `README.md` / `README.ko.md`: bilingual README with critical constraint, usage (Claude Code / Codex / SDK), 6-step workflow, synergy recipe table, installation (local clone primary, marketplace conditional), deep-suite links.
- `CHANGELOG.md` / `CHANGELOG.ko.md`: bilingual Keep a Changelog format.
