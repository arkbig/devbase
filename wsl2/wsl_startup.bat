setlocal
call "%~dp0wsl_env.bat"

@REM WSL2起動待ち
wsl -e ps
wsl -l --running
@if not %errorlevel%==0 exit /b %errorlevel%

@REM スタートアップ対象を処理
for %%b in (%WSL2_STARTUP_LIST%) do (
    call "%~dp0%%b"
)

@REM ポートフォワーディング対象を処理
for %%p in (%WSL2_PORT_FORWARDING_LIST%) do (
    call "~dp0wsl_port_forwarding.bat" %%p
)
