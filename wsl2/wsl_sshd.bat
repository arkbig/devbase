setlocal
call "%~dp0.wsl_env.bat"
call "%~dp0wsl_env.bat"

wsl -u root -- service ssh status
if errorlevel 1 wsl -u root -- service ssh start
if errorlevel 1 pause
