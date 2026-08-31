# version.ps1 - Script de versionamento do FinanceApp
# Uso: powershell -ExecutionPolicy Bypass -File scripts\version.ps1 -tipo minor
#   -tipo: major | minor | patch (padrao: patch)
# Tambem aceita: -versao "1.2.3" para definir uma versao explicita.
# Com -deploy, faz push e atualiza o GitHub Pages apos o commit.
# Com -mensagem "texto", acrescenta uma mensagem ao commit.

param(
  [ValidateSet("major","minor","patch")]
  [string]$tipo = "patch",
  [string]$versao = "",
  [switch]$deploy,
  [string]$mensagem = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$versionFile = Join-Path $root ".version"

if (Test-Path $versionFile) {
  $current = (Get-Content $versionFile -Raw).Trim()
} else {
  $current = "0.0.0"
}

if ($versao -ne "" ) {
  $new = $versao
} else {
  $parts = $current -split "\."
  $major = [int]$parts[0]; $minor = [int]$parts[1]; $patch = [int]$parts[2]
  switch ($tipo) {
    "major" { $major++; $minor = 0; $patch = 0 }
    "minor" { $minor++; $patch = 0 }
    default { $patch++ }
  }
  $new = "$major.$minor.$patch"
}

# Atualiza o .version
Set-Content -Path $versionFile -Value $new -NoNewline

# Atualiza a meta de versao no HTML (coloca logo apos a tag <title>)
$html = Join-Path $root "financeapp.html"
if (Test-Path $html) {
  $content = Get-Content $html -Raw -Encoding UTF8
  $pattern = '(?s)(<title>.*?</title>)'
  if ($content -match $pattern) {
    $replacement = '${1}' + "`r`n" + '  <meta name="version" content="' + $new + '">'
    $content = [regex]::Replace($content, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    Set-Content -Path $html -Value $content -Encoding UTF8 -NoNewline
  }
}

Write-Host ""
Write-Host "FinanceApp Pro - Novo versionamento" -ForegroundColor Cyan
Write-Host "  De: $current" -ForegroundColor Gray
Write-Host "  Para: v$new  ($tipo)" -ForegroundColor Green
Write-Host ""

# Commit
Set-Location $root
git add -A
$commitMsg = "release: v$new"
if ($mensagem -ne "") { $commitMsg += " - " + $mensagem }
git commit -m $commitMsg
if ($LASTEXITCODE -ne 0) { Write-Host "Nada para commitar alem do version bump." -ForegroundColor Yellow }

# Tag
git tag "v$new"

Write-Host ""
Write-Host "Commit e tag v$new criados." -ForegroundColor Green

if ($deploy) {
  Write-Host ""
  Write-Host "Publicando no GitHub..." -ForegroundColor Cyan
  git push origin --tags
  if ($LASTEXITCODE -ne 0) { Write-Host "Falha no push. Confira o remote (git remote -v)." -ForegroundColor Red; exit 1 }
  Write-Host "Deploy enviado. Acompanhe o GitHub Actions / Pages." -ForegroundColor Green
}
