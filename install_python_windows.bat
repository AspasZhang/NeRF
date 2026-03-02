@echo off
setlocal enabledelayedexpansion
chcp 936 >nul
title Python One-Click Installer
color 0A

echo.
echo ========================================
echo    Python One-Click Installer (Windows)
echo ========================================
echo.
echo Detecting system environment...
echo.

:: Check if Python is already installed
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Python detected:
    python --version
    echo.
    choice /C YN /M "Continue to install the latest version"
    if errorlevel 2 goto :end
)

:: Set Python version
set PYTHON_VERSION=3.12.2
set DOWNLOAD_URL=https://npmmirror.com/mirrors/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe

echo [*] Preparing to download Python %PYTHON_VERSION%
echo [*] Using domestic mirror for faster speed
echo.

:: Download installer
set INSTALLER=%TEMP%\python_installer.exe
echo [*] Downloading installer...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALLER%' -UseBasicParsing}"

if not exist "%INSTALLER%" (
    echo [×] Download failed, trying backup source...
    set DOWNLOAD_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALLER%' -UseBasicParsing}"
)

if not exist "%INSTALLER%" (
    echo [×] Download failed, please check network connection
    pause
    goto :end
)

echo [OK] Download completed
echo.
echo [*] Starting Python installation...
echo [*] Installation options: Auto add to PATH + pip + Available for all users
echo.

:: Silent installation, auto add PATH
"%INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

:: Wait for installation to complete
timeout /t 10 /nobreak >nul

:: Clean up installer
del "%INSTALLER%"

echo.
echo [*] Verifying installation...
echo.

:: Refresh environment variables
call refreshenv >nul 2>&1
:: If refreshenv fails, manually set PATH for current session
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] refreshenv not available, trying to set PATH manually...
    setx PATH "%PATH%;C:\Program Files\Python312;C:\Program Files\Python312\Scripts" >nul 2>&1
    set PATH=%PATH%;C:\Program Files\Python312;C:\Program Files\Python312\Scripts
)

:: Verify Python
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Python installed successfully!
    python --version
    echo.
    echo [OK] pip version:
    pip --version
    echo.
    echo [*] Installing common library requests...
    pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple
    echo [OK] requests installed
    echo.
    echo ========================================
    echo    Installation Complete!
    echo ========================================
    echo.
    echo You can now use python and pip commands in the command line
    echo.
) else (
    echo [!] Installation complete, but you need to restart the command line window to use it
    echo [!] Or log out and log back in
)

:end
echo.
pause