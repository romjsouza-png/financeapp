@echo off
REM Cria o repositorio no GitHub e habilita o GitHub Pages (rodar 1x)
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\init-repo.ps1"
pause
