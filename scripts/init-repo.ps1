# init-repo.ps1 - Cria/vincula o repositorio no GitHub e habilita o GitHub Pages
# Uso: powershell -ExecutionPolicy Bypass -File scripts\init-repo.ps1
# Requer o GitHub CLI autenticado (gh auth login).

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if (Test-Path (Join-Path $root ".git")) {
  Write-Host "Repositorio git local ja existe." -ForegroundColor Yellow
} else {
  Set-Location $root; git init
}

# Verifica se gh esta disponivel
$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
  Write-Host "GitHub CLI (gh) nao encontrado. Instale ou adicione ao PATH." -ForegroundColor Red
  exit 1
}

$login = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host "Voce precisa autenticar o gh:  gh auth login" -ForegroundColor Yellow
  exit 1
}

# Cria o repo no GitHub (nao duplica se ja existir)
$repoCheck = gh repo view financeapp 2>&1
if ($LASTEXITCODE -ne 0) {
  Set-Location $root
  gh repo create financeapp --public --source=. --push
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Falha ao criar o repositorio. Confira o nome/disponibilidade." -ForegroundColor Red
    exit 1
  }
  Write-Host "Repositorio financeapp criado e primeiro push feito." -ForegroundColor Green
} else {
  Write-Host "Repositorio financeapp ja existe." -ForegroundColor Yellow
}

# Habilita GitHub Pages (branch main, raiz)
gh api -X POST repos/{owner}/financeapp/pages `
  -f "source[branch]=main" -f "source[path]=/" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
  Write-Host "GitHub Pages habilitado (branch main)." -ForegroundColor Green
} else {
  gh api -X PUT repos/{owner}/financeapp/pages `
    -f "source[branch]=main" -f "source[path]=/" 2>&1 | Out-Null
  Write-Host "GitHub Pages ja configurado." -ForegroundColor Green
}

Write-Host ""
Write-Host "Pronto! Site em: https://<usuario>.github.io/financeapp/" -ForegroundColor Cyan
