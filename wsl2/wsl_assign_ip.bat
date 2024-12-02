@echo off
setlocal
call "%~dp0wsl_env.bat"

@echo on
wsl -u root ip addr change %DNSMASQ_ADDR%%WSL2_ADDR_SUBNET% broadcast %WSL2_BROADCAST% dev eth0 label eth0:100
@if errorlevel 1 pause

set WSL_ETHERNET_NAME="vEthernet (WSL (Hyper-V firewall))"
netsh interface ip add address %WSL_ETHERNET_NAME% %WSL2_GATEWAY% %WSL2_GATEWAY_SUBNET%
@if errorlevel 1 netsh interface ip show address %WSL_ETHERNET_NAME% | find "%WSL2_GATEWAY%"
@if errorlevel 1 pause

netsh interface ipv4 set dns %WSL_ETHERNET_NAME% static %DNSMASQ_ADDR% none no
@if errorlevel 1 pause
netsh interface ipv4 add dns %WSL_ETHERNET_NAME% %DNSMASQ_SERVER% 2 no
@if errorlevel 1 pause
