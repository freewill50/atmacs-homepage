# ─────────────────────────────────────────────────────────────
#  ATMACS 홈페이지 — 이후 업데이트 배포 스크립트
#  최초 업로드 후, 사이트 수정 시 이 파일만 실행하면 됩니다.
#  ─────────────────────────────────────────────────────────────

$ErrorActionPreference = "Stop"
$ProjectDir = "C:\Users\한병원\OneDrive - (주)에이티맥스\한병원\2026년_기술연구소\homepage\홈페이지_리뉴얼"

Set-Location $ProjectDir
Write-Host "[작업 위치] $ProjectDir" -ForegroundColor Yellow

if (-not (Test-Path ".git")) {
    Write-Host "[오류] Git 저장소가 초기화되지 않았습니다." -ForegroundColor Red
    Write-Host "       먼저 '1_GitHub_최초업로드.ps1' 을 실행하세요."
    Read-Host "Enter 키를 눌러 종료"
    exit 1
}

# 변경 사항 확인
$changes = git status --short
if ([string]::IsNullOrWhiteSpace($changes)) {
    Write-Host "[알림] 변경된 파일이 없습니다." -ForegroundColor Yellow
    Read-Host "Enter 키를 눌러 종료"
    exit 0
}

Write-Host ""
Write-Host "[변경 파일 목록]" -ForegroundColor Cyan
git status --short
Write-Host ""

$msg = Read-Host "커밋 메시지를 입력하세요 (예: CEO 인사말 수정)"
if ([string]::IsNullOrWhiteSpace($msg)) {
    $msg = "Update: " + (Get-Date -Format "yyyy-MM-dd HH:mm")
}

git add .
git commit -m $msg
git push

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[완료] 1~2분 후 사이트에 반영됩니다." -ForegroundColor Green
} else {
    Write-Host "[오류] Push 실패. 네트워크/인증을 확인하세요." -ForegroundColor Red
}

Read-Host "Enter 키를 눌러 종료"
