@echo off
REM Script de inicio rápido para PENGUIN TERNOS
REM Ejecuta el backend en Node.js

echo ========================================
echo PENGUIN TERNOS - Backend Server
echo ========================================
echo.

cd /d "%~dp0backend"

if not exist "node_modules\" (
    echo Instalando dependencias...
    call npm install
    echo.
)

if not exist ".env" (
    echo.
    echo ERROR: Archivo .env no encontrado
    echo Por favor crea el archivo .env basandote en .env.example
    echo Necesitas configurar SUPABASE_URL y SUPABASE_KEY
    echo.
    pause
    exit /b 1
)

echo Iniciando servidor...
echo El servidor estara disponible en http://localhost:3000
echo Presiona Ctrl+C para detener
echo.

call npm run dev
