@echo off
setlocal
title Lexora Legal
cd /d "%~dp0"

REM Se prefiere un entorno virtual funcional; si no existe, se usa el Python instalado en Windows.
set "PYTHON_EXE="
set "PYTHON_ARGS="
if exist "venv\Scripts\python.exe" (
    "venv\Scripts\python.exe" -c "import flask, flask_mysqldb" >nul 2>&1
    if not errorlevel 1 set "PYTHON_EXE=%CD%\venv\Scripts\python.exe"
)

if not defined PYTHON_EXE (
    where py >nul 2>&1
    if not errorlevel 1 (
        for /f "delims=" %%P in ('where py') do if not defined PYTHON_EXE set "PYTHON_EXE=%%P"
        set "PYTHON_ARGS=-3"
    )
)

if not defined PYTHON_EXE (
    echo.
    echo No se encontro Python. Instala Python 3 y vuelve a ejecutar este archivo.
    pause
    exit /b 1
)

REM Comprueba Flask y el conector MySQL antes de iniciar el servidor.
"%PYTHON_EXE%" %PYTHON_ARGS% -c "import flask, flask_mysqldb" >nul 2>&1
if errorlevel 1 (
    echo.
    echo Faltan dependencias. Se instalaran desde requirements.txt...
    "%PYTHON_EXE%" %PYTHON_ARGS% -m pip install -r requirements.txt
    if errorlevel 1 (
        echo.
        echo No fue posible instalar las dependencias. Revisa tu conexion a Internet y Python.
        pause
        exit /b 1
    )
)

echo Iniciando Lexora Legal...
start "Lexora Legal - Servidor" /min "%PYTHON_EXE%" %PYTHON_ARGS% -m flask --app app run --no-debugger --no-reload

REM Espera brevemente a que Flask quede disponible y abre la pagina en el navegador predeterminado.
timeout /t 2 /nobreak >nul
start "" "http://127.0.0.1:5000"

echo La aplicacion se abrio en http://127.0.0.1:5000
echo Para detenerla, cierra la ventana "Lexora Legal - Servidor".
endlocal
