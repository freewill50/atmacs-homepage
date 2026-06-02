# ─────────────────────────────────────────────────────────────
#  ATMACS 홈페이지 — GitHub 최초 업로드 스크립트
#  사용법:
#    1) GitHub에서 빈 저장소 먼저 생성 (https://github.com/new)
#       - 이름: atmacs-homepage  (Public 선택, README/license 체크 X)
#    2) 이 파일을 우클릭 → "PowerShell로 실행"
#    3) 화면 안내에 따라 GitHub 사용자명 입력
#  ─────────────────────────────────────────────────────────────

$ErrorActionPreference = "Stop"
$ProjectDir = "C:\Users\한병원\OneDrive - (주)에이티맥스\한병원\2026년_기술연구소\homepage\홈페이지_리뉴얼"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " ATMACS 홈페이지 — GitHub 최초 업로드" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ── 0. git 설치 확인 ────────────────────────────────────────
try {
    $gitVersion = git --version
    Write-Host "[OK] Git 감지됨: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "[오류] Git이 설치되어 있지 않습니다." -ForegroundColor Red
    Write-Host "       https://git-scm.com/download/win 에서 설치 후 다시 실행하세요."
    Read-Host "Enter 키를 눌러 종료"
    exit 1
}

# ── 1. 프로젝트 폴더 이동 ───────────────────────────────────
Set-Location $ProjectDir
Write-Host "[작업 위치] $ProjectDir" -ForegroundColor Yellow
Write-Host ""

# ── 2. 사용자 입력 받기 ─────────────────────────────────────
$githubUser = Read-Host "GitHub 사용자명을 입력하세요 (예: atmacs-corp)"
if ([string]::IsNullOrWhiteSpace($githubUser)) {
    Write-Host "[오류] 사용자명이 비어 있습니다." -ForegroundColor Red
    exit 1
}
$repoName = Read-Host "저장소 이름을 입력하세요 [기본값: atmacs-homepage]"
if ([string]::IsNullOrWhiteSpace($repoName)) { $repoName = "atmacs-homepage" }

$remoteUrl = "https://github.com/$githubUser/$repoName.git"
Write-Host ""
Write-Host "[원격 저장소] $remoteUrl" -ForegroundColor Yellow
Write-Host ""

# ── 3. 기존 .git 폴더 정리 ──────────────────────────────────
if (Test-Path ".git") {
    Write-Host "[정리] 기존 .git 폴더 삭제 중..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force ".git"
}

# ── 4. Git 초기화 ──────────────────────────────────────────
Write-Host "[1/6] Git 저장소 초기화..." -ForegroundColor Cyan
git init -q
git branch -M main

git config user.name "Byungwon Han"
git config user.email "byungwon.han@gmail.com"
git config core.autocrlf true
git config core.quotepath false

# ── 5. 큰 파일 사전 차단 ───────────────────────────────────
Write-Host "[2/6] 100MB 초과 파일 검사..." -ForegroundColor Cyan
$bigFiles = Get-ChildItem -Recurse -File | Where-Object {
    $_.Length -gt 95MB -and
    $_.FullName -notmatch "\\\.git\\" -and
    $_.FullName -notmatch "\\홈페이지자료\\" -and
    $_.FullName -notmatch "\\_review_" -and
    $_.FullName -notmatch "\\images\\originals\\"
}
if ($bigFiles) {
    Write-Host "[경고] 다음 파일은 GitHub 100MB 제한 초과:" -ForegroundColor Red
    $bigFiles | ForEach-Object { Write-Host "       $($_.FullName) ($([math]::Round($_.Length/1MB,1))MB)" }
    Read-Host "계속하려면 Enter (Ctrl+C로 중단)"
}

# ── 6. 파일 추가 + 커밋 ────────────────────────────────────
Write-Host "[3/6] 파일 스테이징 (.gitignore 적용)..." -ForegroundColor Cyan
git add .

$staged = git diff --cached --numstat | Measure-Object -Line
Write-Host "       → $($staged.Lines) 파일 스테이징됨"

Write-Host "[4/6] 최초 커밋 생성..." -ForegroundColor Cyan
git commit -q -m "Initial commit: ATMACS homepage launch"

# ── 7. 원격 저장소 연결 ────────────────────────────────────
Write-Host "[5/6] 원격 저장소 연결..." -ForegroundColor Cyan
git remote add origin $remoteUrl

# ── 8. Push ────────────────────────────────────────────────
Write-Host "[6/6] GitHub로 업로드 (인증 창이 뜨면 로그인하세요)..." -ForegroundColor Cyan
Write-Host ""
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host " 업로드 성공!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host " 다음 단계:" -ForegroundColor Yellow
    Write-Host " 1) https://github.com/$githubUser/$repoName/settings/pages 접속"
    Write-Host " 2) Source → Deploy from a branch → main → / (root) → Save"
    Write-Host " 3) 1~2분 후 임시 URL로 접속 확인"
    Write-Host "    https://$githubUser.github.io/$repoName/"
    Write-Host " 4) DEPLOY.md의 4단계(도메인 연결) 진행"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "[오류] Push 실패. 다음을 확인하세요:" -ForegroundColor Red
    Write-Host "  - GitHub에서 저장소를 먼저 생성했는지"
    Write-Host "  - 사용자명/저장소명이 정확한지"
    Write-Host "  - GitHub 로그인 인증을 완료했는지"
}

Read-Host "Enter 키를 눌러 종료"
