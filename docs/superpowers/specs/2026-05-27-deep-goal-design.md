# deep-goal — 설계 명세 (Design Spec)

- 작성일: 2026-05-27
- 상태: 승인됨 (brainstorming 합의 완료, 구현 계획 대기)
- 대상 버전: v1.0.0 (첫 릴리스)

---

## 1. 한 줄 정의

> **deep-goal은 사용자의 장기 작업 요청을 받아 (1) goal 기능에 적합한지 평가하고, (2) 맞는 형태로 다듬고, (3) 필요한 사전 준비물을 발굴해, (4) Claude Code / Codex의 네이티브 `/goal`에 그대로 붙여 넣을 수 있는 완성된 조건을 컴파일해 제시하는 cross-platform 플러그인이다.**

deep-suite 시리즈의 일원으로, Claude Code와 Codex 양쪽에서 동일하게 동작한다.

---

## 2. 배경 — goal 기능이란

`/goal`은 Claude Code와 Codex 각각의 **네이티브 빌트인 기능**으로, 하나의 검증 가능한 종료 조건을 향해 턴을 넘어 자율적으로 계속 작업하게 한다.

| 항목 | Claude `/goal` | Codex `/goal` |
|---|---|---|
| 종료 판정 | 별도의 작은 빠른 모델(기본 Haiku)이 매 턴 후 조건 충족을 yes/no + 이유로 평가 | Codex 자신이 종료 조건 도달을 확신하면 멈춤 |
| 구현 기반 | session-scoped prompt-based Stop hook의 wrapper | 별도 feature (`features.goals`) |
| 제어 | set / 상태 / `clear`(+별칭) | set / 상태 / `pause` / `resume` / `clear` |
| 활성화 | v2.1.139+, trust 수락, 훅 시스템 | `config.toml`의 `[features] goals = true` |
| 세션 재개 | `--resume`/`--continue`로 복원 (조건 유지, 카운터 리셋) | 명시 없음 |
| 비대화형 | `claude -p "/goal ..."` | 백그라운드 작업처럼 취급 |

### Claude 평가자의 결정적 제약
Claude 평가자(Haiku)는 **도구를 호출하지 않으며**, Claude가 대화에 **이미 표면화한 출력**만으로 조건을 판정한다. 따라서 조건은 *Claude 자신의 출력으로 증명 가능*하게 작성되어야 한다. 이 비자명한 제약이 deep-goal이 존재하는 핵심 이유 중 하나다.

---

## 3. 핵심 제약 — 자동 호출 불가 (공식 문서 검증 완료)

`/goal`은 **플러그인/스킬이 프로그래밍적으로 자동 호출할 수 없다.** 공식 문서로 검증된 사실:

| 검증 항목 | 결과 | 근거 |
|---|---|---|
| 스킬이 네이티브 `/goal` 프로그래밍 호출 | **불가** | Agent SDK 디스패치 가능 커맨드는 `/compact`·`/clear`·`/context`·`/usage`뿐 |
| 에이전트 출력의 `/goal` 텍스트 실행 | **No** | 커맨드는 "사용자 메시지 시작"에서만 파싱, 에이전트 출력은 plain text |
| Skill 도구의 빌트인 차단 | **Yes (hard limit)** | `/goal`은 빌트인 커맨드, Skill 도구가 reject |
| `-p`로 현재 세션 주입 | **No** | `-p`는 새 세션 전용 |

### 발견했으나 채택하지 않은 우회로
`/goal`은 "prompt-based Stop hook의 wrapper"이므로, 플러그인이 `hooks/hooks.json`에 자체 Stop hook을 등록하면 *기능적으로 동등한* 자체 goal-loop을 사용자 타이핑 없이 구현할 수 있다. **그러나 v1에서는 채택하지 않는다.** 이유:

- 사용자가 "임의로 수정할 수 없는 고유 기능을 쓴다"는 전제와 어긋남 (재구현이 됨)
- 네이티브 UI(`◎ /goal active`)·auto-clear·세션 resume·빌트인 평가자 토큰 추적 **상실**
- Codex hook 시스템은 Claude와 다르고 문서화가 빈약 → "양쪽 동일 동작" 보장이 깨질 위험
- 네이티브 `/goal`과 자체 루프 공존 시 혼란

→ **결론: deep-goal의 역할은 "완성된 `/goal` 조건을 제시"하는 데서 끝나고, 활성화 트리거는 사용자가 누른다.** 활성화 마찰은 "한 줄 복사-붙여넣기"로 최소화한다.

---

## 4. 확정된 설계 결정

| # | 결정 | 선택 | 근거 |
|---|---|---|---|
| 1 | 활성화 모델 | 네이티브 `/goal` 조건 **제시 → 사용자 트리거** | 자동 호출 불가(§3). 고유 기능 사용 전제 충실, 양 플랫폼 동일 |
| 2 | 작업 범위 | 코어(평가+컴파일+제시) **+ 사전 준비물 능동 식별** | Codex의 contract 철학 반영, 조건 품질↑ |
| 3 | 게이트 성격 | **균형** — 재구성 우선, 구조적 부적합 시 반려 | goal 문서가 "무관한 잡다 목록 금지" 경고 |
| 4 | 플러그인 형태 | **가벼운 별도 플러그인** | 시리즈 완결성·독립 배포·cross-platform 유지하되 무거운 ceremony 미복제 |
| 5 | 시너지 범위 (v1) | **레시피 라이브러리 + 단발 goal** | 코어는 가볍게, 레시피는 references 지식으로 확장 |

### deep-goal이 형제들과 "종류가 다르다"는 점 (의식적 수용)
형제 7개는 모두 Harness 매트릭스의 한 칸을 *직접 차지*하고 아티팩트로 데이터 흐름에 연결된다. deep-goal은 네이티브 goal(그 자체가 Inferential Sensor)의 **사용 어댑터/온램프**로 한 단계 메타에 있다. 이 차이 때문에 무거운 ceremony(아티팩트 스키마·캐시·서브에이전트)를 복제하지 않고 **가볍게** 간다.

---

## 5. 정체성 & 매트릭스 위치

> **"deep-suite 오케스트레이션 레시피를 goal 자율 실행으로 컴파일하는 메타-Guide"**

- **Core question**: *"이 목표를, 어떤 플러그인을 어떤 검증 게이트와 엮어, goal로 자율 달성할까?"*
- **매트릭스 위치**: Guides × Inferential의 **상위** — 다른 Guide/Sensor를 조합하는 오케스트레이션 Guide
- **데이터 흐름**: 다른 deep-* 플러그인의 진입점을 **consume**(시퀀스에 배치) → `PLAN.md` + `/goal` 조건을 **emit**

시너지 레시피가 deep-goal을 "외톨이 온램프"에서 **시리즈를 조합하는 접착제**로 격상시킨다.

---

## 6. 디렉토리 구조

```
deep-goal/
├── .claude-plugin/plugin.json          # Claude Code 매니페스트
├── .codex-plugin/plugin.json           # Codex 매니페스트 (skills + interface)
├── CLAUDE.md                           # Claude용 프로젝트 가이드
├── AGENTS.md                           # Codex용 프로젝트 가이드
├── skills/
│   ├── deep-goal/
│   │   └── SKILL.md                    # 얇은 사용자 진입 (user-invocable: true), self-contained
│   └── deep-goal-workflow/
│       ├── SKILL.md                    # 코어 워크플로우 (자동 로드, user-invocable: false)
│       └── references/
│           ├── fitness-rubric.md       # goal 적합성 판정 기준
│           ├── condition-compiler.md   # 조건 4요소 + 평가자 표면화 규칙
│           ├── platform-matrix.md      # Claude vs Codex 차이·분기표
│           ├── prep-scout.md           # 사전 준비물 탐색 절차
│           └── recipes/                # 시너지 레시피 라이브러리
│               ├── README.md           # 레시피 인덱스 + 플러그인 감지 규칙
│               ├── robust-implementation.md
│               ├── autonomous-evolution.md
│               └── ship-and-document.md
├── README.md  /  README.ko.md
├── CHANGELOG.md  /  CHANGELOG.ko.md
└── package.json
```

### 가벼움 보장 (의식적 비목표)
- `agents/` **없음** — 사전 준비물 탐색은 메인 세션이 인라인 수행 (cross-platform fallback 부담 회피)
- `hooks/` **없음** — 자체 goal-loop을 구현하지 않음 (§3)
- 지속 상태 파일 / 아티팩트 스키마 / 캐시 **없음** — 일회성 변환 후 종료

---

## 7. 진입 인터페이스

진입 경로를 맥락별로 구분 (리뷰 codex high2 대응 — `Skill({})`은 SDK 호출이지 Codex 사용자 진입이 아니다):
- **Claude Code 사용자**: `/deep-goal <장기 작업>` (슬래시) / `/deep-goal` (무인수 → "무엇을 끝까지 진행하고 싶나요?" 대화 진입)
- **Codex 사용자**: `$deep-goal:deep-goal <장기 작업>` (`.codex-plugin` defaultPrompt와 일치하는 정식 사용자 진입)
- **프로그래밍 / SDK invoke (Claude·Codex 공통, 사용자 진입 아님)**: `Skill({ skill: "deep-goal:deep-goal", args })`
- **서브커맨드 최소화** — goal 상태 확인·중단은 네이티브 `/goal`·`/goal clear`가 담당하므로 중복 기능을 만들지 않는다.

---

## 8. 워크플로우 (6단계)

### 1) 감지
- 요청 파싱
- 플랫폼 감지 (Claude / Codex)
- git 여부
- **설치된 deep-\* 플러그인 감지** (레시피 매칭용)

### 2) 적합성 평가
`fitness-rubric` 적용 → `적합` / `재구성 필요` / `부적합` 분류.

### 3) 재구성 대화 (필요시 — 균형 게이트)
- 종료조건 모호 → 측정 가능하게 보강 제안
- 너무 큼 → 분해 제안
- 증명 방법 없음 → 검증 커맨드 식별
- **구조적 부적합**(검증 불가 주관 목표 / 단발성 / 무관한 잡다 목록) → 명확히 반려 + 대안(`/loop`, 일반 작업) 제시

### 4) 레시피 매칭
요청 + 감지된 플러그인 → 적용 가능한 시너지 레시피 제안. 해당 플러그인이 없으면 **순수 단발 goal**로 진행.

### 5) 사전 준비물 탐색
코드베이스를 인라인 스캔하여 발굴:
- **먼저 읽을 파일** (goal 진행 전 컨텍스트)
- **진행 증명 커맨드** (테스트/빌드/lint 등)
- **불변 제약** (바꾸면 안 되는 것)

### 6) 컴파일 + 제시
- 플랫폼 맞춤 `/goal <조건>` 생성
- 조건이 복잡하면 시퀀스를 `PLAN.md`로 분리하고 조건은 "PLAN.md 단계대로 완수, 각 게이트 통과까지"로 압축
- 근거 요약 + **복사용 코드블록**으로 제시 + 활성화 안내

---

## 9. 적합성 판정 기준 (fitness-rubric)

| 판정 | 신호 | 처리 |
|---|---|---|
| ✅ 적합 | 단일 목표 · 검증 가능한 종료조건 · "한 프롬프트보다 크고 백로그보다 작음" · 진행 증명 루프 존재 | 4~6단계 |
| 🔧 재구성 | 종료조건 모호 / 범위 과대 / 증명 방법 부재 | 측정 가능화·분해·커맨드 식별 제안 |
| ⛔ 반려 | 검증 불가 주관 목표("더 멋지게") · 단발성(한 턴이면 끝) · 무관한 잡다 목록 | 이유 + 대안 제시 |

---

## 10. 조건 컴파일 — 핵심 가치

### 공통 4요소
1. **측정 가능한 종료상태** (테스트 결과, 빌드 exit code, 파일 개수, 빈 큐 등)
2. **증명 방법** (커맨드/아티팩트 — 어떻게 증명할지)
3. **불변 제약** (가는 길에 바뀌면 안 되는 것)
4. **상한** (턴/시간 — `or stop after N turns`)

### 플랫폼 분기

| 플랫폼 | 규칙 |
|---|---|
| **Claude** | 평가자(Haiku)가 도구 못 쓰고 *대화 표면화된 것만* 판단 → "Claude 출력으로 증명 가능"하게 문구화, **게이트/단계 결과를 대화에 명시 보고하라는 지침 필수**, 4,000자 한도 준수, `or stop after N turns` 상한 권장 |
| **Codex** | *contract* 형태(달성/변경금지/검증/종료) + 체크포인트·진행 로그 지침, `pause`/`resume` 활용 안내, `PLAN.md` 적극 활용 |

### 예시 (Claude, robust-implementation 레시피)
```
deep-work 세션으로 <기능>을 Research→Plan→Implement→Test 순으로 진행한다.
deep-work의 Plan 승인과 각 phase Exit Gate에서는 사용자에게 승인을 요청하고, 승인이 대화에 보고된 뒤에만 다음 단계로 진행한다(승인 전 자율 진행 금지 — 이 게이트는 종료조건의 일부다).
Implement 완료 직후 deep-review-loop(--max=3)를 돌려 verdict가 APPROVE가 될 때까지 대응한다.
종료조건: 모든 phase 완료 AND 모든 승인 게이트(Plan 승인·Exit Gate) 통과가 보고됨 AND 최종 deep-review-loop APPROVE AND 테스트 전체 통과.
각 단계 결과(phase 전환·승인 게이트·review verdict·테스트 출력)를 대화에 명시적으로 보고할 것.
or stop after 40 turns.
```
마지막 문장(대화 명시 보고)이 없으면 Claude 평가자가 종료를 판정하지 못한다 — deep-goal이 책임지는 비자명한 컴파일 규칙.

---

## 11. 시너지 레시피 라이브러리 (v1: 3개)

각 레시피는 `references/recipes/`의 *지식 문서*이며, 본체를 무겁게 하지 않는다. 감지된 플러그인에 따라 적용 가능한 것만 제안한다.

| 레시피 | 트리거 (감지) | 요지 |
|---|---|---|
| **robust-implementation** | deep-work + deep-review | phase 진행 + Implement 완료 직후 deep-review-loop(APPROVE까지) 게이트 + test 통과까지 |
| **autonomous-evolution** | deep-evolve | fitness metric 목표치 도달까지 자율 실험 |
| **ship-and-document** | deep-docs + deep-wiki | 구현 완료 → docs garden + wiki ingest + 최종 review |

### 현실적 제약 (레시피 문서에 명시)
- **deep-work**의 필수 사용자 인터랙션 핵심은 **Plan 승인**이며(`deep-work-workflow`의 "Plan 승인이 유일한 필수 인터랙션"), phase 사이 Exit Gate는 "진행 / 재실행 / 일시정지" 확인이다(Phase 5 Test 제외). 따라서 **완전 무인 자율은 불가** — goal은 *턴 간 프롬프트*를 없애줄 뿐 승인·확인 지점은 사용자 입력을 요구한다. 레시피는 게이트를 실제보다 많게 묘사하지 않고 정직하게 안내한다. (리뷰 W3 교정)
- **deep-review-loop**는 `--max=N` 자동 수렴이라 게이트로 적합.

---

## 12. cross-platform 보장

- 진입 `SKILL.md`는 deep-docs 패턴대로 **self-contained** — workflow의 핵심 규칙(rubric 요약, 4요소, 플랫폼 분기)을 인라인 보존(의도적 duplication). 타 플랫폼에서 sibling skill 자동 로드가 약해도 동작.
- 플랫폼 감지 → 컴파일 분기.
- 탐색이 메인 인라인이라 Agent 도구 부재 플랫폼(Codex/Copilot/Gemini)에서도 추가 fallback 불필요.
- **references 로드 실패 시 degrade 보증 (리뷰 codex high1 대응)**: references root 해석은 플랫폼 중립이다 — `${CLAUDE_PLUGIN_ROOT}` 설정 시 그 경로, unset 시 진입 SKILL 자신의 절대 경로 기준 상대 해석 또는 작업트리 glob 탐색. 셋 다 실패해도 진입 SKILL이 self-contained 이므로 평가·4요소 컴파일·플랫폼 분기 등 **코어 기능은 동작**한다(references는 레시피/상세에만 필요). 즉 cross-platform 코어 약속은 fallback 전면 실패에도 깨지지 않는다.
- **prep-scout no-file-tools degrade (리뷰 codex round4 medium)**: Glob/Grep/Read 또는 그 권한이 없는 런타임에서는 prep-scout이 (a) 사용자에게 컨텍스트를 요청하거나 (b) 출력을 "미검증"으로 표시하고 (c) 저장소 prerequisite를 점검한 척하지 않는 최소 goal을 컴파일한다 — ready-to-run 약속을 거짓으로 하지 않는다.
- 매니페스트 2벌(`.claude-plugin` / `.codex-plugin`) + `CLAUDE.md` / `AGENTS.md`.
- 릴리스 시 **deep-suite 마켓플레이스 등록**(형제 동일 관례 — `marketplace.json` 2곳 + README 표).

---

## 13. 비목표 (Non-goals) — YAGNI 명시

- ❌ 네이티브 `/goal` 자동 호출 (불가 — §3)
- ❌ 자체 Stop hook goal-loop 구현 (v1 채택 안 함 — §3)
- ❌ 사후 달성 검증 단계 (범위 결정에서 제외)
- ❌ 동적 임의 플러그인 합성 (v1은 고정 레시피 3개)
- ❌ 지속 상태/아티팩트/캐시/서브에이전트 (가벼움 유지)
- ❌ goal 상태 확인·중단 기능 (네이티브 `/goal`이 담당)

---

## 14. 구현 시 결정할 열린 질문

- ~~플랫폼 감지 구체 방법~~ → **plan Task 3 §감지방법으로 위임 해소(Info-3)**: 런타임 자기 인식(Claude/Codex) + 필요 시 양쪽 제시.
- ~~설치된 deep-* 플러그인 감지 구체 방법~~ → **plan Task 3 §감지방법으로 위임 해소(Info-3)**: 사용 가능한 스킬/슬래시 목록 확인 + 불확실 시 1회 사용자 확인.
- ~~`PLAN.md` 분리 임계치~~ → **해소(W4/I5)**: ~2,800자(4,000의 70%) 또는 순차 게이트 3개 이상이면 분리 (condition-compiler / plan Task 4).
- **4,000자·`stop after N turns` 상한 수치의 출처(W4)** — Claude `/goal` 공식 문서 기준이나 버전 변동 가능. condition-compiler에 근거 주석 + 컴파일 출력에 "현재 버전 기준" 단서 포함.
- v1 레시피 3개 각각의 상세 시퀀스 문구 (특히 deep-work 승인 게이트와의 상호작용 문구 — W3 실제 명세 대조)
- README/CHANGELOG/매니페스트 메타데이터 초기값

---

## 부록 A — 형제 플러그인 공통 골격 (참고)

각 deep-* 플러그인은 다음을 공유한다:
- 매니페스트 2벌: `.claude-plugin/plugin.json` + `.codex-plugin/plugin.json`(`skills`·`interface` 필드 추가)
- 지침 2벌: `CLAUDE.md` + `AGENTS.md`
- 스킬 2단: `skills/<name>/SKILL.md`(얇은 진입) + `skills/<name>-workflow/`(코어)
- 이중언어 README/CHANGELOG, `package.json`, deep-suite 마켓플레이스 동기화
