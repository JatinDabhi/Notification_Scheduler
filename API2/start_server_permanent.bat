@echo off
title Notification Scheduler Backend Service
echo ========================================================
echo   Notification Scheduler & REST API Service
echo ========================================================
echo.

:: Setup ADB reverse for connected Android phones
adb devices >nul 2>&1
adb reverse tcp:8080 tcp:8080 >nul 2>&1

:: Open firewall port 8080 if not already open
netsh advfirewall firewall show rule name="Node API Port 8080" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="Node API Port 8080" dir=in action=allow protocol=TCP localport=8080 >nul 2>&1
)

echo Starting Node.js Server on port 8080...
echo Server will auto-restart if closed.
echo.

:LOOP
node server.js
echo.
echo [WARNING] Server stopped at %date% %time%. Restarting in 3 seconds...
timeout /t 3 >nul
goto LOOP
