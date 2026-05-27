# 변경 이력

이 프로젝트의 모든 주요 변경 사항은 이 파일에 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)를 따르며,
이 프로젝트는 [Semantic Versioning](https://semver.org/spec/v2.0.0.html)을 준수합니다.

---

## [1.0.0] - 2026-05-27

### 추가됨

**코어 — 평가·재구성·컴파일·사전 준비물 탐색**
- 적합성 평가 기준(`references/fitness-rubric.md`): 3판정 시스템 — 적합 / 재구성 필요 / 반려 — 각 판정별 구체 예시와 재구성 전략(종료조건 명확화, 범위 분해, 증명 커맨드 식별) 포함.
- 조건 컴파일러(`references/condition-compiler.md`): 4요소 컴파일 규칙(측정 가능한 종료상태·증명 방법·불변 제약·상한)과 평가자 표면화 규칙(Claude Haiku 평가자는 도구를 호출하지 못하므로 모든 조건에 단계 결과를 대화에 명시 보고하는 지침이 필수). 4,000자 한도 및 ~2,800자 또는 순차 게이트 3개 이상 시 PLAN.md 분리 전략 포함.
- 플랫폼 매트릭스(`references/platform-matrix.md`): Claude vs Codex 분기표 — 각 플랫폼 컴파일 규칙과 예시.
- 사전 준비물 탐색기(`references/prep-scout.md`): 인라인 코드베이스 스캔 절차(Glob/Grep/Read)로 먼저 읽을 파일·`package.json` scripts/Makefile/CI 설정에서 증명 커맨드·불변 제약 발굴. 파일 도구 없는 환경에서의 degrade 모드 포함.

**시너지 레시피 — 멀티 플러그인 조합 3종**
- `robust-implementation`: deep-work + deep-review 레시피. Research→Plan→Implement→Test 단계 진행, Plan 승인 게이트 및 Exit Gate 포함. Plan 승인 직후·Implement 완료 직후 각각 deep-review-loop(--max=3) 적용. 종료조건: 모든 phase 완료 AND 모든 승인 게이트 통과 보고 AND 최종 deep-review-loop APPROVE AND 테스트 통과. 완전 무인 자율 불가(goal은 턴 간 프롬프트를 없애줄 뿐, 승인·확인 지점은 사용자 입력 필요)를 명시.
- `autonomous-evolution`: deep-evolve 레시피. 목표 fitness metric 도달 또는 상한까지 자율 실험 루프. 매 반복마다 metric 값을 대화에 보고. deep-evolve 자체 측정 루프와 네이티브 goal 턴 상한의 관계 안내.
- `ship-and-document`: deep-docs + deep-wiki 레시피. 구현 완료 가정 → (deep-review 있으면) 최종 리뷰 게이트 먼저 통과 → deep-docs garden → wiki-ingest. wiki ingest 등 영속 작업은 리뷰 승인 이후 배치. 순서 변경 불가 시 rollback 안내 포함.
- 레시피 인덱스(`references/recipes/README.md`): 감지된 형제 플러그인과 레시피 제안 매핑 규칙. 복수 레시피 선택 규칙. 매칭 없을 시 단발 goal 폴백.

**진입·워크플로우 스킬 (cross-platform)**
- 사용자 진입 스킬(`skills/deep-goal/SKILL.md`): self-contained — 활성화 모델·3판정 요약·4요소·평가자 표면화 규칙·플랫폼 분기 요약을 인라인 보존. 형제 스킬 자동 로드 없이도 동작. Claude Code(`/deep-goal`)·Codex(`$deep-goal:deep-goal`)·SDK(`Skill({...})`) 진입 경로 문서화.
- 코어 워크플로우 스킬(`skills/deep-goal-workflow/SKILL.md`): 6단계 오케스트레이션, references 로드 규칙(description 매칭 자동 로드 → Skill() 명시 호출 → Read fallback → references 없이 degrade). `$CLAUDE_PLUGIN_ROOT` 설정 시 절대 경로, unset 시 진입 SKILL 기준 상대 경로 또는 glob 탐색으로 플랫폼 중립 root 해석.

**Cross-platform 매니페스트 및 검증**
- Claude Code 매니페스트(`.claude-plugin/plugin.json`) 및 Codex 매니페스트(`.codex-plugin/plugin.json`) — `skills`·`interface` 필드, `defaultPrompt`는 `$deep-goal:deep-goal` 사용.
- `package.json`: `type: module`, `npm run verify`(positive lint + negative self-test 통합).
- `scripts/verify-plugin.sh`: grep 기반 release-lint — 파일 존재·frontmatter·콘텐츠 불변량(활성화 모델·4요소·평가자 표면화·self-containment)·버전 3중 sync·CHANGELOG 엔트리·placeholder 토큰 없음·`hooks/`/`agents/` 디렉토리 없음 검사.
- `scripts/verify-selftest.sh`: negative self-test — 검증기가 실제로 placeholder 위반·다중요소 self-containment 실패·활성화 invariant 역전을 잡는지 메타검증. `npm run verify`의 release gate에 통합.

**프로젝트 가이드**
- `CLAUDE.md`: Claude용 프로젝트 가이드 — 개요·디렉토리 구조·핵심 개념(활성화 모델·4요소·평가자 표면화·레시피)·슬래시 커맨드·테스트·릴리스 워크플로우(deep-suite 마켓플레이스 동기화 포함)·관련 저장소.
- `AGENTS.md`: Codex 프로젝트 가이드 — 런타임 표면·검증 커맨드·merge 후 deep-suite 동기화 안내.
- `README.md` / `README.ko.md`: 이중언어 README — 핵심 제약·사용법(Claude Code/Codex/SDK)·6단계 흐름·시너지 레시피 표·설치(로컬 clone 1차·마켓플레이스 조건부 2차)·deep-suite 링크.
- `CHANGELOG.md` / `CHANGELOG.ko.md`: 이중언어 Keep a Changelog 형식.
