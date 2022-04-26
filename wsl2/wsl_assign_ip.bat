setlocal
@echo off
if "%DNSMASQ_SERVER%"=="" set DNSMASQ_SERVER=1.1.1.1
if "%DNSMASQ_ADDR%"=="" set DNSMASQ_ADDR=192.168.100.100
if "%WSL2_ADDR_SUBNET%"=="" set WSL2_ADDR_SUBNET=/24
if "%WSL2_BROADCAST%"=="" set WSL2_BROADCAST=192.168.100.255
if "%WSL2_GATEWAY%"=="" set WSL2_GATEWAY=192.168.100.1
if "%WSL2_GATEWAY_SUBNET%"=="" set WSL2_GATEWAY_SUBNET=255.255.255.0
echo on

wsl -u root ip addr add %DNSMASQ_ADDR%%WSL2_ADDR_SUBNET% broadcast %WSL2_BROADCAST% dev eth0 label eth0:100
if errorlevel 1 pause

netsh interface ip add address "vEthernet (WSL)" %WSL2_GATEWAY% %WSL2_GATEWAY_SUBNET%
if errorlevel 1 pause

netsh interface ipv4 set dns "vEthernet (WSL)" static %DNSMASQ_ADDR% none no
if errorlevel 1 pause

netsh interface ipv4 add dns "vEthernet (WSL)" %DNSMASQ_SERVER% 2 no
if errorlevel 1 pause
