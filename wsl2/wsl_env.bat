@echo off
REM # 必要に応じて設定変更（wsl_env.batをコピーして、.wsl_env.batを作る）
REM 変数名は(あれば)コンテナで使用するenvironmentと合わせてます。
REM シェル環境変数 > .wsl_env.bat > wsl_env.bat の順に優先されます。

REM 個人設定を優先する
if not "%~nx0"==".wsl_env.bat" (
    if exist "%~dp0.wsl_env.bat" (
        call "%~dp0.wsl_env.bat"
    )
)
REM ========================================
REM ネットワーク設定
REM ========================================

REM 通常使うDNSサーバーを指定(set as Secondary DNS)
if "%DNSMASQ_SERVER%"=="" set DNSMASQ_SERVER=1.1.1.1

REM IP address for WSL2
if "%DNSMASQ_ADDR%"=="" set DNSMASQ_ADDR=192.168.100.100
if "%WSL2_ADDR_SUBNET%"=="" set WSL2_ADDR_SUBNET=/24
if "%WSL2_BROADCAST%"=="" set WSL2_BROADCAST=192.168.100.255

REM IP address for vEthernet (WSL)
if "%WSL2_GATEWAY%"=="" set WSL2_GATEWAY=192.168.100.1
if "%WSL2_GATEWAY_SUBNET%"=="" set WSL2_GATEWAY_SUBNET=255.255.255.0

REM ========================================
REM スタートアップ対象選択
REM ========================================

REM 同階層のバッチを指定すると、この順番で実行されます。
if "%WSL2_STARTUP_LIST%"=="" (
    set WSL2_STARTUP_LIST=^
        wsl_assign_ip.bat ^
        wsl_dockerd.bat ^
        wsl_sshd.bat ^
        ;
)

REM ポートフォワーディング対象（ポート番号をスペース区切りで指定）
REM 設定すれば、wsl_port_forwarding.batが実行される
REM 不要であれば、0を指定
if "%WSL2_PORT_FORWARDING_LIST%"=="" (
    set WSL2_PORT_FORWARDING_LIST=22
)
