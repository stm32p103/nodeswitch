@echo off
set Version=%1
set RootDir=%~dp0..
echo Switch to %Version%
powershell -command ". .\common.ps1; Set-NodeVersion -Version %Version% -RootDir %RootDir%"