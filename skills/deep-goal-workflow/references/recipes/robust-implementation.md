# 레시피: robust-implementation

deep-work의 구조적 4단계 진행과 deep-review-loop의 자동 수렴 게이트를 엮어, 검증된 구현을 goal로 자율 달성한다. **핵심 제약: deep-work의 Plan 승인은 필수 사용자 인터랙션이며, 승인 없이 자율 완주는 불가능하다.** 이 제약은 주의 문구가 아니라 컴파일된 조건 자체에 반영된다.

---

## 트리거 (감지 조건)

다음 두 플러그인이 모두 감지될 때 이 레시피를 제안한다:

- `deep-work` — Research / Plan / Implement / Test 4단계 워크플로우
- `deep-review` 또는 `deep-review-loop` — 코드 리뷰 자동 수렴 루프

`deep-work`만 감지되고 `deep-review`가 없는 경우: review 게이트를 생략한 축소판을 사용자에게 확인 후 제안한다.

---

## 전제 (필요 플러그인)

| 플러그인 | 역할 |
|---|---|
| `deep-work` | Research→Plan→Implement→Test 4단계 실행 |
| `deep-review` / `deep-review-loop` | Implement 완료 직후 리뷰 수렴 게이트 |

두 플러그인이 없으면 단발 goal 폴백을 사용한다.

---

## 시퀀스

```
[1] deep-work Research 단계
[2] deep-work Plan 단계 → ★ Plan 승인 (사용자 필수 인터랙션) ★
[3] deep-work Implement 단계
    → deep-review-loop(--max=3): verdict APPROVE까지 반복
    → Implement Exit Gate 확인 (진행 / 재실행 / 일시정지)
[4] deep-work Test 단계
    → 테스트 전체 통과 확인
```

**게이트 정확도 기술 (spec §11 대조):**

- **Plan 승인**: deep-work의 "Plan 승인이 유일한 필수 인터랙션"(deep-work-workflow/SKILL.md 명세). 이 지점에서 반드시 사용자 입력이 필요하다. goal은 턴 간 프롬프트를 없애줄 뿐 이 승인 지점은 사용자 입력을 요구한다.
- **Exit Gate**: Implement 완료 직후 "진행 / 재실행 / 일시정지" 확인. Phase 5(Test)는 Exit Gate 적용 대상 아님.
- **deep-review-loop**: `--max=N` 자동 수렴 루프라 게이트로 적합. 사람이 중간에 개입 없이 APPROVE까지 반복.

---

## 종료조건

다음이 **모두** 충족되어야 완료:

1. deep-work 모든 phase(Research / Plan / Implement / Test) 완료
2. **모든 승인 게이트(Plan 승인·Implement Exit Gate) 통과가 대화에 보고됨** — 이 게이트는 종료조건의 일부이며, 보고 없이는 평가자가 종료를 판정할 수 없다
3. 최종 deep-review-loop verdict가 APPROVE
4. 테스트 전체 통과

---

## 컴파일된 `/goal` 예시

### Claude (gate-aware, 평가자 표면화 포함)

```
deep-work 세션으로 <기능>을 Research→Plan→Implement→Test 순으로 진행한다.
deep-work의 Plan 승인과 Implement 완료 직후 Exit Gate에서는 사용자에게 승인을 요청하고, 승인이 대화에 보고된 뒤에만 다음 단계로 진행한다(승인 전 자율 진행 금지 — 이 게이트는 종료조건의 일부다).
Implement 완료 직후 deep-review-loop(--max=3)를 돌려 verdict가 APPROVE가 될 때까지 대응한다.
종료조건: 모든 phase 완료 AND 모든 승인 게이트(Plan 승인·Exit Gate) 통과가 보고됨 AND 최종 deep-review-loop APPROVE AND 테스트 전체 통과.
각 단계 결과(phase 전환·승인 게이트·review verdict·테스트 출력)를 대화에 명시적으로 보고할 것.
or stop after 40 turns.
```

### Codex (contract 형태)

```
/goal 목표: deep-work로 <기능>을 Research→Plan→Implement→Test 순으로 구현한다.

달성 조건:
- deep-work 모든 phase 완료
- Plan 승인 게이트 통과 보고됨 (사용자 승인 필수)
- Implement Exit Gate 통과 보고됨 (사용자 확인 필수)
- deep-review-loop(--max=3) verdict APPROVE
- 테스트 전체 통과

변경 금지: <불변 제약>
검증: <테스트 커맨드> 전체 통과

각 phase 전환·게이트 결과를 진행 로그에 명시 기록.
pause 지점: Plan 승인 요청, Exit Gate 확인.
```

---

## 주의 (현실적 제약)

### 완전 무인 자율 불가

deep-work의 **Plan 승인은 필수 사용자 인터랙션**이다(`deep-work-workflow/SKILL.md` 명세: "Plan 승인이 유일한 필수 인터랙션"). goal은 *턴 간 프롬프트*를 없애줄 뿐, Plan 승인 지점은 반드시 사용자 입력을 기다린다. 이 점을 사용자에게 사전 고지한다.

### Exit Gate 정확한 위치

- Implement 완료 직후 → Exit Gate (진행 / 재실행 / 일시정지)
- Phase 5 Test는 Exit Gate 적용 대상이 아님 (deep-work-workflow 실제 명세)

### deep-review-loop 상한

`--max=3`은 예시값이다. 리뷰 난이도에 따라 조정한다. 상한에 도달하면 자동 종료되므로 goal 상한 턴 수와 충돌하지 않도록 여유를 둔다.

### 평가자 표면화 없으면 종료 판정 불가

Claude 평가자(Haiku)는 도구를 호출하지 않고 대화에 표면화된 출력만으로 판정한다. "각 단계 결과를 대화에 명시 보고"가 없으면 내부적으로 완료해도 평가자가 종료를 판정하지 못한다. 이 지침이 조건에 반드시 포함된 이유다.
