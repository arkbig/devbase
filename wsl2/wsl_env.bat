@echo off
REM # �K�v�ɉ����Đݒ�ύX�iwsl_env.bat���R�s�[���āA.wsl_env.bat�����j
REM �ϐ�����(�����)�R���e�i�Ŏg�p����environment�ƍ��킹�Ă܂��B
REM �V�F�����ϐ� > .wsl_env.bat > wsl_env.bat �̏��ɗD�悳��܂��B

REM �l�ݒ��D�悷��
if not "%~nx0"==".wsl_env.bat" (
    if exist "%~dp0.wsl_env.bat" (
        call "%~dp0.wsl_env.bat"
    )
)
REM ========================================
REM �l�b�g���[�N�ݒ�
REM ========================================

REM �ʏ�g��DNS�T�[�o�[���w��(set as Secondary DNS)
if "%DNSMASQ_SERVER%"=="" set DNSMASQ_SERVER=1.1.1.1

REM IP address for WSL2
if "%DNSMASQ_ADDR%"=="" set DNSMASQ_ADDR=192.168.100.100
if "%WSL2_ADDR_SUBNET%"=="" set WSL2_ADDR_SUBNET=/24
if "%WSL2_BROADCAST%"=="" set WSL2_BROADCAST=192.168.100.255

REM IP address for vEthernet (WSL)
if "%WSL2_GATEWAY%"=="" set WSL2_GATEWAY=192.168.100.1
if "%WSL2_GATEWAY_SUBNET%"=="" set WSL2_GATEWAY_SUBNET=255.255.255.0

REM ========================================
REM �X�^�[�g�A�b�v�ΏۑI��
REM ========================================

REM ���K�w�̃o�b�`���w�肷��ƁA���̏��ԂŎ��s����܂��B
if "%WSL2_STARTUP_LIST%"=="" (
    set WSL2_STARTUP_LIST=^
        wsl_assign_ip.bat ^
        wsl_dockerd.bat ^
        wsl_sshd.bat ^
        ;
)

REM �|�[�g�t�H���[�f�B���O�Ώہi�|�[�g�ԍ����X�y�[�X��؂�Ŏw��j
REM �ݒ肷��΁Awsl_port_forwarding.bat�����s�����
REM �s�v�ł���΁A0���w��
if "%WSL2_PORT_FORWARDING_LIST%"=="" (
    set WSL2_PORT_FORWARDING_LIST=22
)
