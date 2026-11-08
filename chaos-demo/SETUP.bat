@echo off
rem One-shot, idempotent setup. Re-running skips everything already done.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup.ps1" %*
pause
