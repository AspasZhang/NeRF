@echo off
setlocal enabledelayedexpansion
chcp 936 >nul
title Python 一键安装工具
color 0A

echo.
echo ========================================
echo    Python 一键安装工具 (Windows)
echo ========================================
echo.
echo 正在检测系统环境...
echo.

:: 检查是否已安装Python
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] 检测到已安装Python:
    python --version
    echo.
    choice /C YN /M "是否继续安装最新版本"
    if errorlevel 2 goto :end
)

:: 设置Python版本
set PYTHON_VERSION=3.12.2
set DOWNLOAD_URL=https://npmmirror.com/mirrors/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe

echo [*] 准备下载 Python %PYTHON_VERSION%
echo [*] 使用国内镜像源，速度更快
echo.

:: 下载安装器
set INSTALLER=%TEMP%\python_installer.exe
echo [*] 正在下载安装器...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALLER%' -UseBasicParsing}"

if not exist "%INSTALLER%" (
    echo [×] 下载失败，尝试备用源...
    set DOWNLOAD_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALLER%' -UseBasicParsing}"
)

if not exist "%INSTALLER%" (
    echo [×] 下载失败，请检查网络连接
    pause
    goto :end
)

echo [OK] 下载完成
echo.
echo [*] 开始安装 Python...
echo [*] 安装选项: 自动添加到PATH + pip + 所有用户可用
echo.

:: 静默安装，自动添加PATH
"%INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

:: 等待安装完成
timeout /t 10 /nobreak >nul

:: 清理安装器
del "%INSTALLER%"

echo.
echo [*] 验证安装...
echo.

:: 刷新环境变量
call refreshenv >nul 2>&1
:: 如果 refreshenv 失败，手动设置当前会话的 PATH
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] refreshenv 不可用，尝试手动设置 PATH...
    setx PATH "%PATH%;C:\Program Files\Python312;C:\Program Files\Python312\Scripts" >nul 2>&1
    set PATH=%PATH%;C:\Program Files\Python312;C:\Program Files\Python312\Scripts
)

:: 验证Python
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Python 安装成功！
    python --version
    echo.
    echo [OK] pip 版本:
    pip --version
    echo.
    echo [*] 正在安装常用库 requests...
    pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple
    echo [OK] requests 安装完成
    echo.
    echo ========================================
    echo    安装完成！
    echo ========================================
    echo.
    echo 你现在可以在命令行中使用 python 和 pip 命令了
    echo.
) else (
    echo [!] 安装完成，但需要重启命令行窗口才能使用
    echo [!] 或者注销后重新登录
)

:end
echo.
pause