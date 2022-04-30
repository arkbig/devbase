@REM ========================================
@REM # 必要に応じて設定変更（wsl_env.batをコピーして、.wsl_env.batを作る）
@REM 名前は(あれば)コンテナで使用するenvironmentと合わせてます。

@REM 通常使うDNSサーバーを指定(set as Secondary DNS)
@if "%DNSMASQ_SERVER%"=="" set DNSMASQ_SERVER=1.1.1.1

@REM IP address for WSL2
@if "%DNSMASQ_ADDR%"=="" set DNSMASQ_ADDR=192.168.100.100
@if "%WSL2_ADDR_SUBNET%"=="" set WSL2_ADDR_SUBNET=/24
@if "%WSL2_BROADCAST%"=="" set WSL2_BROADCAST=192.168.100.255

@REM IP address for vEthernet (WSL)
@if "%WSL2_GATEWAY%"=="" set WSL2_GATEWAY=192.168.100.1
@if "%WSL2_GATEWAY_SUBNET%"=="" set WSL2_GATEWAY_SUBNET=255.255.255.0
@REM ========================================
