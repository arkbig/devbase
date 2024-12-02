@echo off
setlocal
goto skip_copy_self
:copy_self
REM Process at the beginning so that the running file seek does not change.
@echo on
copy /Y "%~dp1%~nx0" "%~df0"
call "%~df0" "%~df1"
exit /b %errorlevel%

:skip_copy_self
REM ���̃o�b�`�t�@�C����Windows���ɃR�s�[����(��$ cp wsl_startup_helper.bat /mnt/c/Users/username/bin/)
REM wsl_startup_helper.bat \\wsl$\Ubuntu-20.04\home\username\devbase\wsl2\wsl_startup_all.bat
REM �̂悤��WSL2�̋N���o�b�`�t�@�C�����w�肵�āA�^�X�N�X�P�W���[���[�ɓo�^���Ă��������B
REM �Ǘ��Ҍ������K�v�Ȃ̂Łu�ŏ�ʂ̓����Ŏ��s����v�Ƀ`�F�b�N�����Ă��������B

if "%~1"=="" (
    echo ���s����o�b�`�������Ɏw�肵�Ă�������
    pause
    exit /b 1
)

REM �X�V�`�F�b�N---�s�v�Ȃ�goto skip_diff
REM goto skip_diff
set existdiff=
for /F "usebackq delims=" %%p in (`wsl -e wslpath "%~df0"`) do (
    set mntpath=%%p
)
set realpath=
if exist "%~dp1%~nx0" (
    for /F "usebackq delims=" %%p in (`wsl -e wslpath "%~df1"`) do (
        set realpath=%%~pp%~nx0
    )
)
if not "%realpath%"=="" (
    for /F "usebackq delims=" %%l in (`wsl -e diff "%mntpath%" "%realpath:\=/%"`) do (
        set existdiff=1
        echo %%l
    )
)
set wantcopy=n
if not "%existdiff%"=="" (
    set wantcopy=Y
    set /P wantcopy=�X�^�[�g�A�b�v�o�^�o�b�`���X�V����܂����B�R�s�[���܂����H [Y/n]
)
if "%wantcopy%"=="Y" (
    goto copy_self
) else if "%wantcopy%"=="y" (
    goto copy_self
)
:skip_diff

wsl -e ps
wsl -l --running
if not %errorlevel%==0 (
    echo WSL�̋N�����m�F�ł��܂���ł����B���Ԃ������Ď��s���Ă݂Ă��������B
    exit /b %errorlevel%
)

@echo on

call "%~df1"
