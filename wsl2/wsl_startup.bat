@echo off
setlocal
call "%~dp0wsl_env.bat"

REM WSL2起動待ち代わり
wsl -e ps

@echo on

wsl -l --running
if not %errorlevel%==0 exit /b %errorlevel%

@REM スタートアップ対象を処理
@for %%b in (%WSL2_STARTUP_LIST%) do (
    call "%~dp0%%b"
)

@REM ポートフォワーディング対象を処理
@for %%p in (%WSL2_PORT_FORWARDING_LIST%) do (
    @if not %%p==0 call "%~dp0wsl_port_forwarding.bat" %%p
)
