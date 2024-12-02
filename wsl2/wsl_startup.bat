@echo off
setlocal
call "%~dp0wsl_env.bat"

REM WSL2�N���҂�����
wsl -e ps

@echo on

wsl -l --running
if not %errorlevel%==0 exit /b %errorlevel%

@REM �X�^�[�g�A�b�v�Ώۂ�����
@for %%b in (%WSL2_STARTUP_LIST%) do (
    call "%~dp0%%b"
)

@REM �|�[�g�t�H���[�f�B���O�Ώۂ�����
@for %%p in (%WSL2_PORT_FORWARDING_LIST%) do (
    @if not %%p==0 call "%~dp0wsl_port_forwarding.bat" %%p
)
