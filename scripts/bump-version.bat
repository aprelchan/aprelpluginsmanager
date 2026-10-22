@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%.."

if "%~1"=="" (
    echo Usage: bump-version.bat ^<version^> [codename]
    echo Example: bump-version.bat 1.6.1
    echo Example: bump-version.bat 1.6.1 "Aprel Chan"
    exit /b 1
)

set "VERSION=%~1"
set "CODENAME=%~2"
set "METAINFO=apmplugin\metainfo.json"

if not exist "%METAINFO%" (
    echo Error: %METAINFO% not found
    exit /b 1
)

if "%CODENAME%"=="" (
    python scripts\bump_version.py "%METAINFO%" "%VERSION%"
) else (
    python scripts\bump_version.py "%METAINFO%" "%VERSION%" "%CODENAME%"
)
if errorlevel 1 exit /b %errorlevel%

echo.
echo Building plugin package...
where uv >nul 2>nul
if %errorlevel% equ 0 (
    uv run --with elyxbuilder-cli elyb build
) else (
    where elyb >nul 2>nul
    if %errorlevel% equ 0 (
        elyb build
    ) else (
        pip install elyxbuilder-cli -U && elyb build
    )
)
