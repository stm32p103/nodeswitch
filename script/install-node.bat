@echo off
set Version=%1
set ScriptDir=%~dp0
set RootDir=%ScriptDir%..
echo Install Node.js %Version%
powershell -command ". %ScriptDir%\common.ps1; Install-Node -Version %Version% -RootDir %RootDir%"