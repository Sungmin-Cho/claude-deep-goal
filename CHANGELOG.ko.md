# 변경 이력

이 프로젝트의 모든 주요 변경 사항은 이 파일에 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)를 따르며,
이 프로젝트는 [Semantic Versioning](https://semver.org/spec/v2.0.0.html)을 준수합니다.

---

## [1.0.1] — 2026-05-27

### 수정됨

- **플러그인 manifest** — `.claude-plugin/plugin.json`의 `repository`가 object(`{ type, url }`) 형태였다. Claude Code 플러그인 스키마는 string URL을 기대하므로 설치 시 `repository: Invalid input: expected string, received object` 에러가 발생했다. string URL로 변경했다. (`.codex-plugin/plugin.json`은 이미 string이었음.)

---

## [1.0.0] — 2026-05-27

최초 릴리스 — Claude Code와 Codex용 goal 조건 컴파일러.

### 추가됨

- **적합성 평가** — 장기 작업 요청이 네이티브 `/goal`에 맞는지 판단하는 3판정 기준(적합 / 재구성 필요 / 반려)과 재구성 전략(종료조건 명확화, 범위 분해, 증명 커맨드 식별).
- **조건 컴파일러** — 4요소(측정 가능한 종료상태·증명 방법·불변 제약·상한)와 평가자 표면화 규칙(Claude Haiku 평가자는 도구를 호출하지 못하므로 모든 조건이 단계 결과를 대화에 보고하도록 지시)을 갖춘 조건을 생성. 4,000자 한도를 적용하고, 조건이 커지거나 순차 게이트가 3개 이상이면 `PLAN.md`로 분리.
- **플랫폼 매트릭스** — Claude vs Codex 분기표 및 각 플랫폼 컴파일 규칙.
- **사전 준비물 탐색** — 인라인 코드베이스 스캔으로 먼저 읽을 파일, 증명 커맨드(`package.json` scripts / Makefile / CI 설정), 불변 제약을 발굴; 파일 도구가 없을 때의 degrade 모드 포함.
- **시너지 레시피 — `robust-implementation`** (deep-work + deep-review): 승인 게이트와 리뷰 루프 APPROVE 판정을 종료조건으로 하는 단계별 Research→Plan→Implement→Test; 승인 지점은 여전히 사용자 입력이 필요함을 명시.
- **시너지 레시피 — `autonomous-evolution`** (deep-evolve): 목표 fitness metric 도달 또는 턴 상한까지 자율 실험 루프.
- **시너지 레시피 — `ship-and-document`** (deep-docs + deep-wiki): 구현 → 선택적 리뷰 게이트 → docs garden → wiki ingest, 영속 작업은 리뷰 승인 이후 배치.
- **레시피 인덱스** — 감지된 형제 플러그인을 레시피 제안에 매핑하고, 매칭이 없으면 단발 goal로 폴백.
- **크로스 플랫폼 진입** — 사용자 호출 `/deep-goal`(Claude Code), `$deep-goal:deep-goal`(Codex), `Skill({...})`(SDK). 진입 스킬은 self-contained로, 형제 스킬 자동 로드 없이 동작.
- **6단계 워크플로우 스킬** — 감지 → 적합성 → 재구성 → 레시피 매칭 → 사전 준비물 탐색 → 컴파일 + 제시.
- **Claude Code 및 Codex 매니페스트**와 `npm run verify`(release lint + negative self-test).
- **이중언어 문서** — README, CHANGELOG, 에이전트 가이드(CLAUDE.md / AGENTS.md).
