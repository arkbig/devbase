setlocal
call "%~dp0.wsl_env.bat"
call "%~dp0wsl_env.bat"

wsl -e ps
wsl -l --running
@if not %errorlevel%==0 exit /b %errorlevel%

call "%~dp0wsl_assign_ip.bat"

call "%~dp0wsl_dockerd.bat"

call "%~dp0port_forwarding.bat"

call "%~dp0wsl_sshd.bat"
