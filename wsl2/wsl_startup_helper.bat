setlocal
@REM このバッチファイルをWindows側にコピーして(例$ cp wsl_startup_helper.bat /mnt/c/Users/username/bin/)
@REM wsl_startup_helper.bat \\wsl$\Ubuntu-20.04\home\username\devbase\wsl2\wsl_startup_all.bat
@REM のようにWSL2の起動バッチファイルを指定して、タスクスケジューラーに登録してください。
@REM 管理者権限が必要なので「最上位の特権で実行する」にチェックを入れてください。

@if "%1"=="" (
    echo 実行するバッチを引数に指定してください
    pause
    exit /b 1
)

wsl -e ps
wsl -l --running
@if not %errorlevel%==0 (
    echo WSLの起動が確認できませんでした。時間をおいて実行してみてください。
    exit /b %errorlevel%
)

call "%1"
