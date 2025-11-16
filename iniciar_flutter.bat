@echo off
REM Script para ejecutar Flutter app en emulador/dispositivo

echo ========================================
echo PENGUIN TERNOS - Flutter App
echo ========================================
echo.

cd /d "%~dp0flutter_app"

echo Verificando dependencias...
call flutter pub get
echo.

echo Dispositivos disponibles:
call flutter devices
echo.

echo Ejecutando aplicacion...
echo.

call flutter run
