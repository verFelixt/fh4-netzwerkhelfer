Exit code: 0
Wall time: 0.2 seconds
Output:
@echo off
setlocal
title Forza Horizon 4 Netzwerkhelfer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Forza-Netzwerkhelfer.ps1"
if errorlevel 1 (
  echo.
  echo Der Netzwerkhelfer wurde mit einem Fehler beendet.
  pause
)
endlocal

