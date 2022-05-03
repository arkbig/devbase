setlocal enabledelayedexpansion
call "%~dp0wsl_env.bat"

goto begin
:usage
echo Usage:
echo "%~n0 [opts] <port#>"
echo.
echo "Options:"
echo "-r --rm   Remove port forwarding settings."
exit /b 1

:begin
@REM 引数チェック
rmflag=
portno=
for %%a in (%*) do (
    if "%%a"=="-r" set rmflag=1
    else if "%%a"=="--rm" set rmflag=1
    else if "!portno!"=="" set portno=%%a
    else goto usage
)
if "%portno%"=="" goto usage
set /a portno=%portno% + 1 - 1
if "%portno%"=="0" goto usage

REM 古い設定削除
netsh interface portproxy delete v4tov4 listenport=%portno%
netsh advfirewall firewall delete rune name="WSL port %portno%"

if "%rmflag%"!="" exit /b 0

netsh interface portproxy add v4tov4 listenport=%portno% listenaddress=0.0.0.0 connectport=%portno% connectaddress=%DNSMASQ_ADDR%
@if errorlevel 1 pause

netsh advfirewall firewall add rule name="WSL port %portno%" dir=in action=allow protocol=tcp localport=%portno%
@if errorlevel 1 pause
