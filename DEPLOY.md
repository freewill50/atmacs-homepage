# ATMACS 홈페이지 — GitHub Pages 배포 가이드

도메인: **www.atmacs.co.kr**
호스팅: **GitHub Pages** (무료, 자동 HTTPS)

---

## 사전 준비

- GitHub 계정 (회사 명의 권장: `atmacs-corp` 같은 Organization 또는 개인 계정)
- Git 설치 (Windows: https://git-scm.com/download/win)
- 회사 도메인 DNS 관리자 접근 권한 (가비아/후이즈/카페24 등)

---

## 1단계 — GitHub 저장소 생성

1. GitHub 로그인 → 우측 상단 `+` → **New repository**
2. 저장소 이름: `atmacs-homepage` (또는 `atmacs.github.io` 사용 시 사용자명과 일치 필요)
3. **Public** 선택 (Private은 GitHub Pro 유료 플랜 필요)
4. README, .gitignore, license는 **체크하지 말 것** (이미 로컬에 있음)
5. **Create repository** 클릭

---

## 2단계 — 로컬 프로젝트를 Git에 등록

PowerShell 또는 Git Bash에서 실행:

```powershell
cd "C:\Users\한병원\OneDrive - (주)에이티맥스\한병원\2026년_기술연구소\homepage\홈페이지_리뉴얼"

# Git 초기화
git init
git branch -M main

# 사용자 정보 (최초 1회)
git config user.name "Byungwon Han"
git config user.email "byungwon.han@gmail.com"

# 파일 추가 (.gitignore 가 내부자료 자동 제외)
git add .
git commit -m "Initial commit: ATMACS homepage"

# 원격 저장소 연결 (URL은 본인 저장소로 교체)
git remote add origin https://github.com/<계정명>/atmacs-homepage.git
git push -u origin main
```

> **확인**: `git status` 실행 시 `홈페이지자료/`, `images/originals/`, `ATMACS_*.pdf` 등이
> Untracked 목록에 나타나지 않아야 정상입니다 (`.gitignore` 적용 확인).

---

## 3단계 — GitHub Pages 활성화

1. 저장소 페이지 → **Settings** → 좌측 메뉴 **Pages**
2. **Source**: `Deploy from a branch` 선택
3. **Branch**: `main` / `/ (root)` 선택 → **Save**
4. 1~2분 후 페이지 상단에 `Your site is live at https://<계정명>.github.io/atmacs-homepage/` 표시

이 시점에서 임시 URL로 사이트가 동작합니다.

---

## 4단계 — 회사 도메인 (www.atmacs.co.kr) 연결

### 4-1. DNS 레코드 설정 (도메인 등록업체 관리 페이지)

| 호스트(Name) | 타입 | 값(Value) | TTL |
|---|---|---|---|
| `www` | **CNAME** | `<계정명>.github.io` | 3600 |
| `@` (루트) | **A** | `185.199.108.153` | 3600 |
| `@` (루트) | **A** | `185.199.109.153` | 3600 |
| `@` (루트) | **A** | `185.199.110.153` | 3600 |
| `@` (루트) | **A** | `185.199.111.153` | 3600 |

> **설명**:
> - `www` CNAME: `www.atmacs.co.kr` → GitHub Pages로 연결
> - `@` A 레코드 4개: `atmacs.co.kr`(루트 도메인)로 들어온 요청을 GitHub의 4개 IP로 분산 → 자동으로 `www`로 리다이렉트
> - GitHub Pages 공식 IP (https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)

### 4-2. GitHub Pages 설정에서 도메인 등록

1. 저장소 → **Settings** → **Pages**
2. **Custom domain** 입력란에 `www.atmacs.co.kr` 입력 → **Save**
3. `CNAME` 파일이 저장소에 자동 생성됨 (이미 로컬에 만들어 두었으므로 충돌 없음)
4. DNS 전파 후 (보통 10분 ~ 최대 24시간) **DNS Check Successful** 메시지 표시
5. **Enforce HTTPS** 체크박스가 활성화되면 체크 → Let's Encrypt 인증서 자동 발급

---

## 5단계 — 업데이트 배포

이후 사이트 수정 시:

```powershell
cd "C:\Users\한병원\OneDrive - (주)에이티맥스\한병원\2026년_기술연구소\homepage\홈페이지_리뉴얼"
git add .
git commit -m "수정 내용 요약"
git push
```

→ 1~2분 내 자동 반영 (별도 빌드 불필요)

---

## 체크리스트

- [ ] GitHub 저장소 생성 (Public)
- [ ] 로컬 → 원격 push 완료
- [ ] `git status`에서 내부자료 제외 확인
- [ ] GitHub Pages 활성화 → 임시 URL 접속 OK
- [ ] DNS 레코드 (CNAME + A 4개) 등록
- [ ] Custom domain `www.atmacs.co.kr` 등록
- [ ] HTTPS 활성화 (Enforce HTTPS 체크)
- [ ] 브라우저에서 https://www.atmacs.co.kr 정상 접속 확인

---

## 트러블슈팅

| 증상 | 원인/해결 |
|---|---|
| 페이지가 404로 표시됨 | Pages 설정에서 Branch가 `main`인지, Source가 `root`인지 확인 |
| 이미지가 깨짐 | 파일명 대소문자 확인 (Windows는 무시, Linux는 구분) |
| HTTPS 체크박스 비활성화 | DNS 전파 대기 (최대 24시간). `dig www.atmacs.co.kr`로 확인 |
| `git push` 시 파일 크기 오류 | `.gitignore` 적용 전 commit 된 큰 파일이 있는지 확인 → `git rm --cached <파일>` |
| Custom domain 저장 실패 | DNS 레코드 먼저 등록 후 Pages 설정에 입력 |

---

## 운영 비용

- **호스팅**: 무료 (GitHub Pages, 트래픽 100GB/월 제한 — 회사 홈페이지는 충분)
- **HTTPS 인증서**: 무료 (Let's Encrypt, 자동 갱신)
- **도메인**: 기존 회사 도메인 사용 (별도 비용 없음)
- **합계**: ₩0 / 월

---

## 추후 개선 옵션

1. **GitHub Actions 자동화**: 빌드 단계 추가 시 워크플로 설정
2. **Cloudflare 프록시**: GitHub Pages 앞단에 Cloudflare를 두면 국내 속도 개선 + DDoS 방어
3. **이미지 최적화**: `images/` 폴더의 PNG → WebP 일괄 변환 (이미 일부 적용됨)
