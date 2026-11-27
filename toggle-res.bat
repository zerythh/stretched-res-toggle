@echo off

:: ====================================================================================================================
::  Resolution Toggler - edit the values below to your liking, for stretched res 1280x1024 is the default.
:: ====================================================================================================================

set NATIVE_W=1920
set NATIVE_H=1080

set STRETCHED_W=1280
set STRETCHED_H=1024

set "SCRIPT_URL=https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/toggle-res.ps1"

set "SCRIPT=%~dp0toggle-res.ps1"
if not exist "%SCRIPT%" (
    set "SCRIPT=%TEMP%\toggle-res.ps1"
    powershell -NoProfile -Command "Invoke-WebRequest -UseBasicParsing '%SCRIPT_URL%' -OutFile '%TEMP%\toggle-res.ps1'" || exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%SCRIPT%" ^
    -NativeW %NATIVE_W% -NativeH %NATIVE_H% ^
    -StretchW %STRETCHED_W% -StretchH %STRETCHED_H%

exit /b %errorlevel%
