#!/usr/bin/env bash
# deep-goal verify negative self-test — proves verify-plugin.sh actually catches violations.
# Three self-tests; any failure → non-zero exit. Output: "self-test: ALL-PASS" or "self-test: HAS-FAIL".
set -u
fail=0

# Single trap to clean up all fixtures on exit (including Ctrl-C / abnormal termination).
trap 'rm -f skills/.selftest-placeholder.md skills/deep-goal/.selftest-autoclaim.md /tmp/deep-goal-stub.md skills/deep-goal/.SKILL.md.selftest-bak' EXIT

# (1) placeholder gate catches forbidden tokens in skills/ (an() C1 regression guard)
# mkdir -p ensures skills/ exists even before Task 3 creates content there (harmless).
mkdir -p skills
printf 'TODO fill in\n' > skills/.selftest-placeholder.md
if bash scripts/verify-plugin.sh 2>&1 | grep -q "forbidden found"; then
  echo "PASS: placeholder gate catches"
else
  echo "FAIL: placeholder gate blind"
  fail=$((fail+1))
fi
rm -f skills/.selftest-placeholder.md

# (2) self-containment multi-element check — verify-plugin.sh catches keyword-only stubs (W1 regression guard)
# Place a keyword-only stub at skills/deep-goal/ temporarily (real SKILL.md backed up),
# run verify-plugin.sh, and confirm it reports FAIL for the self-containment checks.
stub_dir="skills/deep-goal"
real_skill="${stub_dir}/SKILL.md"
backup_skill="${stub_dir}/.SKILL.md.selftest-bak"
mkdir -p "$stub_dir"
# Backup real SKILL.md if present; write keyword-only stub (missing 증명/불변/표면화 elements).
[ -f "$real_skill" ] && mv "$real_skill" "$backup_skill"
printf '종료조건 Codex Skill(\nentry: proof-method\n' > "$real_skill"
# Run verify-plugin.sh; it should FAIL (non-zero or report "Failed: N" > 0).
vout=$(bash scripts/verify-plugin.sh 2>&1)
vstatus=$?
# Restore real SKILL.md before evaluating (so trap cleanup is idempotent).
rm -f "$real_skill"
[ -f "$backup_skill" ] && mv "$backup_skill" "$real_skill"
# Expect either non-zero exit OR output containing "Failed: [^0]" — stub must be caught.
if echo "$vout" | grep -qE 'Failed: [1-9]|✗'; then
  echo "PASS: stub fails multi-element check (verify-plugin.sh caught it)"
else
  echo "FAIL: stub passed verify-plugin.sh — self-containment check not enforced"
  fail=$((fail+1))
fi

# (3) reversed activation invariant rejected (codex round3 medium regression guard):
# "자동 호출 가능" claim must be caught by the an() forbidden-pattern check.
mkdir -p skills/deep-goal
printf '네이티브 /goal은 자동 호출 가능하다\n' > skills/deep-goal/.selftest-autoclaim.md
if bash scripts/verify-plugin.sh 2>&1 | grep -qE "forbidden found in:.*selftest-autoclaim"; then
  echo "PASS: reversed activation invariant rejected"
else
  echo "FAIL: reversed invariant passes"
  fail=$((fail+1))
fi
rm -f skills/deep-goal/.selftest-autoclaim.md

# Trap will clean residual fixtures; report result.
if [ "$fail" -eq 0 ]; then
  echo "self-test: ALL-PASS"
  exit 0
else
  echo "self-test: HAS-FAIL ($fail failure(s))"
  exit 1
fi
