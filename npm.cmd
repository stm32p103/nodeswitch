@echo off
for /F "usebackq" %%i in (`@cd`) do set PWD=%%~dfi
powershell -File %~dp0\switch.ps1 npm.cmd %~fd0 %PWD% %*