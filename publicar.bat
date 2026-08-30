@echo off
REM Release patch e deploy rapido
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\version.ps1" -tipo patch -deploy
pause
