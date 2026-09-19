@echo off
setlocal

set "SPARKDASH_MODE=%~1"
if not defined SPARKDASH_MODE set "SPARKDASH_MODE=Start"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\DGXSpark\sparkdash-control.ps1" -Mode "%SPARKDASH_MODE%"
exit /b %ERRORLEVEL%
