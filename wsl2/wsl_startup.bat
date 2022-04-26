setlocal

@echo off
REM ========================================
REM # 必要に応じて設定変更
REM 名前は(あれば)コンテナで使用するenvironmentと合わせてます。

REM 通常使うDNSサーバーを指定(set as Secondary DNS)
set DNSMASQ_SERVER=1.1.1.1

REM IP address for WSL2
set DNSMASQ_ADDR=192.168.100.100
set WSL2_ADDR_SUBNET=/24
set WSL2_BROADCAST=192.168.100.255

REM IP address for vEthernet (WSL)
set WSL2_GATEWAY_ADDR=192.168.100.1
set WSL2_GATEWAY_SUBNET=255.255.255.0
REM ========================================
echo on

pushd "~dp0"

wsl -e ps
wsl -l --running
if not %errorlevel%==0 exit /b %errorlevel%

call wsl_assign_ip

call wsl_dockerd

call port_forwarding

call wsl_sshd
