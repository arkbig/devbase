netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=192.168.100.100
if errorlevel 1 pause

@exit /b %errorlevel
REM ファイアウォール解放のサンプル（PC再起動しても消えない）
netsh advfirewall firewall add rule name="WSL port 22" dir=in action=allow protocol=tcp localport=22
