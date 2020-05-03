@echo off
set Version=%1
set ScriptDir=%~dp0
set RootDir=%ScriptDir%..
echo Switch to %Version%
powershell -command ". %ScriptDir%\common.ps1; Set-NodeVersion -Version %Version% -RootDir %RootDir%"
