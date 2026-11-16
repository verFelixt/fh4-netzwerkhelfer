@echo off
setlocal
title Forza Horizon 4 Netzwerkhelfer / Network Helper
powershell.exe -NoLogo -NoProfile -NoExit -ExecutionPolicy Bypass -File "%~dp0Forza-Netzwerkhelfer.ps1"
if errorlevel 1 (
  echo.
  echo Der Netzwerkhelfer wurde mit einem Fehler beendet.
  echo The network helper exited with an error.
  pause
)
endlocal
