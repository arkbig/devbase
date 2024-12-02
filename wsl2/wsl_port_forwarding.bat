@echo off
setlocal enabledelayedexpansion
call "%~dp0wsl_env.bat"

goto begin
:usage
echo "Usage:"
echo "%~n0 [opts] <port#>"
echo ""
echo "Options:"
echo "-r --rm   Remove port forwarding settings only (not set new)."
exit /b 1

:begin
REM �����`�F�b�N
set rmflag=
set portno=
for %%a in (%*) do (
    if "%%a"=="-r" (
        set rmflag=1
    ) else if "%%a"=="--rm" (
        set rmflag=1
    ) else if "!portno!"=="" (
        set portno=%%a
    ) else (
        goto usage
    )
)
if "%portno%"=="" goto usage
REM �����H
cd >nul
set /a portno=%portno%
if not %errorlevel% == 0 goto usage
if %portno% leq 0 goto usage

@echo on

REM �Â��ݒ�폜
netsh interface portproxy delete v4tov4 listenport=%portno%
netsh advfirewall firewall delete rule name="WSL port %portno%"

if not "%rmflag%"=="" exit /b 0

REM �V�����ݒ�
netsh interface portproxy add v4tov4 listenport=%portno% listenaddress=0.0.0.0 connectport=%portno% connectaddress=%DNSMASQ_ADDR%
@if errorlevel 1 pause
netsh advfirewall firewall add rule name="WSL port %portno%" dir=in action=allow protocol=tcp localport=%portno%
@if errorlevel 1 pause
