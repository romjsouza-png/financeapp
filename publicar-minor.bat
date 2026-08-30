@echo off
REM Versiona (minor) e faz deploy
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\version.ps1" -tipo minor -deploy -mensagem "nova funcionalidade"
pause
