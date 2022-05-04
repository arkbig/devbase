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
REM このバッチファイルをWindows側にコピーして(例$ cp wsl_startup_helper.bat /mnt/c/Users/username/bin/)
REM wsl_startup_helper.bat \\wsl$\Ubuntu-20.04\home\username\devbase\wsl2\wsl_startup_all.bat
REM のようにWSL2の起動バッチファイルを指定して、タスクスケジューラーに登録してください。
REM 管理者権限が必要なので「最上位の特権で実行する」にチェックを入れてください。

if "%~1"=="" (
    echo 実行するバッチを引数に指定してください
    pause
    exit /b 1
)

REM 更新チェック---不要ならgoto skip_diff
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
    set /P wantcopy=スタートアップ登録バッチが更新されました。コピーしますか？ [Y/n]
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
    echo WSLの起動が確認できませんでした。時間をおいて実行してみてください。
    exit /b %errorlevel%
)

@echo on

call "%~df1"
