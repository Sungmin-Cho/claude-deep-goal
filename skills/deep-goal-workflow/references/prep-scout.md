# prep-scout — 사전 준비물 탐색 절차

deep-goal의 5단계(사전 준비물 탐색)에서 사용한다. 메인 세션이 인라인으로 수행하며 서브에이전트 없음.

---

## 탐색 목표

goal 진행 전에 다음 세 가지를 발굴한다:

1. **먼저 읽을 파일** — goal 시작 전 Claude가 반드시 파악해야 할 컨텍스트
2. **진행 증명 커맨드** — 완료/진전을 확인할 테스트/빌드/lint 커맨드
3. **불변 제약** — goal 진행 중 바뀌면 안 되는 것

---

## 탐색 절차

### Step 1: git 여부 확인

```bash
git rev-parse --is-inside-work-tree 2>/dev/null && echo "git" || echo "non-git"
```

- **git 환경**: 브랜치·HEAD 정보를 함께 파악. 불변 제약에 "main 직접 push 금지" 등 추가 고려.
- **non-git 환경**: 파일 시스템 기반 탐색만 수행. 버전 제약은 스킵.

### Step 2: 진행 증명 커맨드 식별

다음 순서로 검증 커맨드를 탐색한다:

**2a. `package.json` scripts 확인**

```bash
# package.json의 scripts 섹션 읽기
# 우선순위: test > build > lint > typecheck
```

`scripts`에서 `test`, `build`, `lint`, `type-check`, `typecheck`, `check` 키를 찾아 해당 커맨드 추출.

**2b. `Makefile` 확인**

```bash
# Makefile의 타겟 목록 확인
make -qp 2>/dev/null | grep '^[a-zA-Z][a-zA-Z0-9_-]*:' | head -20
```

`test`, `build`, `check`, `verify` 타겟 우선 추출.

**2c. CI 설정 확인**

다음 경로 중 존재하는 것을 읽는다:
- `.github/workflows/` — GitHub Actions 워크플로우 (test/build 스텝)
- `.gitlab-ci.yml` — GitLab CI
- `Makefile` — 위에서 확인

**2d. 언어별 기본 커맨드 추정**

탐색 결과가 없으면 파일 확장자로 추정:
- TypeScript/JavaScript: `npm test`, `tsc --noEmit`
- Python: `pytest`, `python -m pytest`
- Go: `go test ./...`, `go build ./...`
- Rust: `cargo test`, `cargo build`

### Step 3: 먼저 읽을 파일 식별

goal 진행 전 반드시 파악할 컨텍스트 파일을 찾는다:

**3a. 설계/아키텍처 문서**

```bash
# 다음 패턴으로 Glob 탐색
CLAUDE.md, AGENTS.md, README.md, ARCHITECTURE.md,
docs/architecture.md, docs/design.md, docs/DESIGN.md
```

**3b. 목표 관련 소스 파일**

요청의 핵심 대상 파일/디렉토리를 파악:
- 요청에서 언급된 파일명/모듈명 추출
- `src/`, `lib/`, `app/` 등 주요 소스 디렉토리의 인덱스 파일

**3c. 의존성/환경 설정**

- `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml` — 의존성 파악
- `.env.example` — 환경변수 파악

### Step 4: 불변 제약 발굴

goal 진행 중 바뀌면 안 되는 것을 명시한다:

**4a. 코드베이스에서 힌트 탐색**

```bash
# CONTRIBUTING.md, docs/contributing.md 등에서 규칙 확인
grep -r "DO NOT\|must not\|never\|금지\|불변" CLAUDE.md AGENTS.md CONTRIBUTING.md 2>/dev/null | head -20
```

**4b. 공통 불변 제약 템플릿**

명시적 힌트가 없으면 다음 템플릿에서 적용 가능한 것을 선택 제안:
- "기존 public API 시그니처 변경 금지"
- "main 브랜치에 직접 push 금지"
- "기존 테스트 케이스 삭제 금지"
- "환경변수/시크릿 하드코딩 금지"

---

## 탐색 결과 정리

탐색 완료 후 다음 형태로 요약한다:

```
[먼저 읽을 파일]
- CLAUDE.md (프로젝트 가이드)
- src/core/index.ts (목표 관련 핵심 파일)

[진행 증명 커맨드]
- npm test (테스트 전체)
- tsc --noEmit (타입 체크)

[불변 제약]
- public API 시그니처 변경 금지
- main 브랜치 직접 push 금지
```

이 정보를 6단계 컴파일에 입력한다.

---

## no-file-tools degraded mode

Glob / Grep / Read 도구 또는 그 권한이 없는 런타임에서는 다음 방식으로 동작한다:

### (a) 사용자에게 컨텍스트 요청

다음 항목을 사용자에게 직접 질문한다:

> "사전 준비물 탐색을 위해 다음 정보가 필요합니다:
> 1. 테스트/빌드 확인 커맨드는 무엇인가요? (예: `npm test`, `make build`)
> 2. goal 진행 중 변경하면 안 되는 제약이 있나요?
> 3. 먼저 읽어야 할 핵심 파일이나 문서가 있나요?"

### (b) 출력을 "미검증(unverified)"으로 표시

사용자 응답 없이 진행할 경우, 탐색 결과 섹션에 다음 표시:

> ⚠️ **미검증(unverified)**: 파일 탐색 도구 없이 추정한 내용입니다. goal 실행 전 직접 확인하세요.

### (c) 최소 goal 컴파일

저장소 prerequisite를 점검한 척하지 않는다. 다음 형태로 최소 조건을 컴파일한다:

```
[조건] <사용자가 명시한 목표>
[증명] <사용자가 제공한 커맨드 또는 "수동 확인">
[불변 제약] <사용자가 명시한 제약 또는 "명시 없음 — 실행 전 확인 필요">
[상한] or stop after N turns.
⚠️ prep-scout를 실행하지 못했습니다 — 파일 탐색 권한 없음. ready-to-run 상태가 아닐 수 있습니다.
```

ready-to-run 약속을 거짓으로 하지 않는 것이 원칙이다.
