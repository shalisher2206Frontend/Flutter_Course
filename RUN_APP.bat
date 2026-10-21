@echo off
cd /d "%~dp0"
title Campus Events
echo Preparing Campus Events...
call flutter pub get
if errorlevel 1 goto failed
echo Opening the app in Chrome...
call flutter run -d chrome
if errorlevel 1 goto failed
exit /b 0

:failed
echo.
echo Flutter could not finish. Check the message above.
echo You can also run the commands in README.md from VS Code.
pause
exit /b 1
