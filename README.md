# FinanceApp Pro

Aplicativo de finanças pessoais (estático HTML/CSS/JS) com controle de receitas,
despesas, orçamentos, metas de economia e lançamentos programados.

## Estrutura

```
financeapp/
├── financeapp.html        # App principal (frontend completo)
├── .version               # Versão atual (semver)
├── .gitignore
├── scripts/
│   ├── version.ps1        # Bump de versão + commit + tag (+ opcional deploy)
│   └── init-repo.ps1      # Cria o repo no GitHub e habilita Pages (1x)
└── publicar.bat           # Atalho: versiona patch e faz deploy
```

## Versionamento e Deploy

### Primeira vez (só uma vez)

1. Autentique o GitHub CLI:
   ```
   gh auth login
   ```
2. Execute (cria o repo `financeapp` no GitHub e habilita o Pages):
   ```
   inicializar.bat
   ```
   O site ficará em `https://<seu-usuario>.github.io/financeapp/`

### A cada nova versão

Para release **patch** (correção) com deploy:
```
publicar.bat
```

Ou, para controlar o tipo:
```
powershell -ExecutionPolicy Bypass -File scripts\version.ps1 -tipo minor -deploy
powershell -ExecutionPolicy Bypass -File scripts\version.ps1 -tipo major -deploy
```

O script:
1. Lê a versão atual (`.version`)
2. Incrementa conforme o tipo (patch/minor/major) ou usa `-versao`
3. Insere a meta `<meta name="version">` no HTML
4. Faz `git commit` e cria a tag `vX.Y.Z`
5. Com `-deploy`, faz `git push origin --tags`
6. O GitHub Actions/Pages publica automaticamente o branch `main`

## Processo recomendado

```
                        ┌─ patch  → publicar.bat
release  ── bump de ────┤
                        └─ minor  → publicar-minor.bat
```

Cada release vira uma tag (`v1.0.0`, `v1.1.0`, ...) no histórico, permitindo
reverter ou comparar versões facilmente.
