@echo off
for /F "usebackq" %%i in (`@cd`) do set PWD=%%~dfi
powershell -File %~dp0\switch.ps1 node.exe %~fd0 %PWD% %*