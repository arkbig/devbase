setlocal
call "%~dp0.wsl_env.bat"
call "%~dp0wsl_env.bat"

netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=%DNSMASQ_ADDR%
if errorlevel 1 pause

@exit /b %errorlevel
REM ファイアウォール解放のサンプル（PC再起動しても消えない）
netsh advfirewall firewall add rule name="WSL port 22" dir=in action=allow protocol=tcp localport=22
