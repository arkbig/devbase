@echo off
setlocal
call "%~dp0wsl_env.bat"

@echo on
wsl -u root -- service docker start
@if errorlevel 1 wsl -u root -- service docker status
@if errorlevel 1 pause
