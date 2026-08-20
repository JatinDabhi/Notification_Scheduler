@echo off
:: Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrator privileges confirmed.
) else (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

echo Opening port 8080 for Node.js API...
netsh advfirewall firewall add rule name="Node API Port 8080" dir=in action=allow protocol=TCP localport=8080
echo.
echo Port 8080 is now open! Your mobile app can connect directly to this PC.
pause
