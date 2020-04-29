@echo off
set Version=%1
set RootDir=%~dp0..
echo Install Node.js %Version%
powershell -command ". .\common.ps1; Install-Node -Version %Version% -RootDir %RootDir%"