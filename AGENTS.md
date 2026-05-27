# deep-goal — Codex Project Guide

Goal condition compiler for long-running autonomous work. Evaluates task requests for native `/goal` fitness, reshapes them, scouts prerequisites, and compiles ready-to-paste `/goal` conditions for Claude Code and Codex.

To check the current version: `jq -r .version .claude-plugin/plugin.json`

> 📄 **Docs maintenance**: this repo's documentation follows `docs/DOCS_RULE.md` (local maintainer guide — single-source-of-truth rules for README / CHANGELOG / this file).

## Runtime Surfaces

- Claude Code manifest: `.claude-plugin/plugin.json`
- Codex manifest: `.codex-plugin/plugin.json`
- User-invocable skill: `skills/deep-goal/SKILL.md` (entry, self-contained)
- Workflow reference skill: `skills/deep-goal-workflow/SKILL.md` (core 6-step, auto-loaded)
- References: `skills/deep-goal-workflow/references/` (fitness-rubric, condition-compiler, platform-matrix, prep-scout, recipes/)
- Scripts: `scripts/verify-plugin.sh`, `scripts/verify-selftest.sh`

No `agents/`, `hooks/`, or persistent state directories. Content-only plugin; no runtime dependencies.

## Verification

```bash
node -e "JSON.parse(require('fs').readFileSync('.codex-plugin/plugin.json','utf8'))"
npm run verify
# = bash scripts/verify-plugin.sh && bash scripts/verify-selftest.sh
```

`verify-plugin.sh` runs grep-based release-lint (positive checks). `verify-selftest.sh` confirms the checker itself catches violations (negative self-test). Both must pass before release.

## Release: Post-merge deep-suite sync (required)

After merging to main and obtaining the 40-character merge commit SHA:

1. Update `/Users/sungmin/Dev/claude-plugins/deep-suite/.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json` — set the `deep-goal` entry `sha` to the merge commit hash.
2. Update the `deep-suite` README plugin tables in both languages.
3. Commit and push to `deep-suite`.

This sync is required before the marketplace install path in the deep-goal README becomes functional.
