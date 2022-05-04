@echo off
setlocal
call "%~dp0wsl_env.bat"

@echo on
wsl -u root ip addr change %DNSMASQ_ADDR%%WSL2_ADDR_SUBNET% broadcast %WSL2_BROADCAST% dev eth0 label eth0:100
@if errorlevel 1 pause

netsh interface ip add address "vEthernet (WSL)" %WSL2_GATEWAY% %WSL2_GATEWAY_SUBNET%
@if errorlevel 1 netsh interface ip show address "vEthernet (WSL)" | find "%WSL2_GATEWAY%"
@if errorlevel 1 pause

netsh interface ipv4 set dns "vEthernet (WSL)" static %DNSMASQ_ADDR% none no
@if errorlevel 1 pause

netsh interface ipv4 add dns "vEthernet (WSL)" %DNSMASQ_SERVER% 2 no
@if errorlevel 1 pause
