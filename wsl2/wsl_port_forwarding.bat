@echo off
if "%DNSMASQ_ADDR%"=="" set DNSMASQ_ADDR=192.168.100.100
echo on

REM 古い設定削除
netsh interface portproxy delete v4tov4 listenport=22

netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=%DNSMASQ_ADDR%
if errorlevel 1 pause

@exit /b %errorlevel
REM ファイアウォール解放のサンプル（PC再起動しても消えない）
netsh advfirewall firewall add rule name="WSL port 22" dir=in action=allow protocol=tcp localport=22
