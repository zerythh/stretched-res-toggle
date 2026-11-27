@echo off
:: ==========================================================
::  Stretched Res Toggle - just edit the 4 values below, then run.
:: ==========================================================
set NATIVE_W=1920
set NATIVE_H=1080

set STRETCHED_W=1280
set STRETCHED_H=1024
:: ==========================================================

set "SCRIPT_URL=https://raw.githubusercontent.com/zerythh/stretched-res-toggle/refs/heads/main/toggle-res.ps1"
set "SCRIPT=%TEMP%\toggle-res.ps1"

:: Grab the latest script from GitHub (falls back to the last downloaded copy if offline)
powershell -NoProfile -Command "try { Invoke-WebRequest -UseBasicParsing '%SCRIPT_URL%' -OutFile '%SCRIPT%' } catch { exit 1 }"
if errorlevel 1 if not exist "%SCRIPT%" (
    echo Could not download the script from GitHub and no cached copy exists.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%SCRIPT%" ^
    -NativeW %NATIVE_W% -NativeH %NATIVE_H% ^
    -StretchW %STRETCHED_W% -StretchH %STRETCHED_H%

exit /b %errorlevel%
