@echo off
setlocal
call "%~dp0wsl_env.bat"

@echo on

wsl -u root -- service ssh start
@if errorlevel 1 wsl -u root -- service ssh status
@if errorlevel 1 pause
