@echo off
chcp 65001 >nul
REM BrowserOS 中文版一键安装脚本 (Windows)
REM 用法：在解压后的完整文件夹里，双击 installer\install.cmd 运行。

REM 预检1：脚本必须和两个 js 文件在同一解压包里（防止单独移动脚本导致静默失败）
if not exist "%~dp0..\app-DRpXG1p6.js" (
  echo [X] 找不到 app-DRpXG1p6.js。
  echo 请不要单独移动本脚本：在解压后的完整文件夹里双击 installer\install.cmd 运行。
  pause
  exit /b 1
)
if not exist "%~dp0..\background.js" (
  echo [X] 找不到 background.js。
  echo 请不要单独移动本脚本：在解压后的完整文件夹里双击 installer\install.cmd 运行。
  pause
  exit /b 1
)

REM 预检2：BrowserOS 必须先完全退出，否则替换可能不生效
tasklist /fi "imagename eq BrowserOS.exe" 2>nul | find /i "BrowserOS.exe" >nul
if not errorlevel 1 (
  echo [!] 检测到 BrowserOS 正在运行。
  echo 请先完全退出 BrowserOS，然后重新双击本脚本。
  pause
  exit /b 1
)

set "EXT_BASE=%LOCALAPPDATA%\BrowserOS\User Data\Default\Extensions\bflpfmnmnokmjhmgnolecpppdbdophmk"

if not exist "%EXT_BASE%" (
  echo [X] 找不到 BrowserOS 扩展目录：
  echo     %EXT_BASE%
  echo 请确认已安装 BrowserOS 并运行过一次。
  pause
  exit /b 1
)

REM 找版本号目录（取最新的）
for /f "delims=" %%d in ('dir /b /ad /o-n "%EXT_BASE%" 2^>nul') do (
  set "VER_DIR=%EXT_BASE%\%%d"
  goto :found_ver
)
echo [X] 扩展目录下找不到版本文件夹
pause
exit /b 1

:found_ver
echo [*] 扩展版本目录：%VER_DIR%
set "CHUNKS=%VER_DIR%\chunks"

REM 找主界面文件
for %%f in ("%CHUNKS%\app-*.js") do (
  echo %%f | findstr /i "\.bak" >nul
  if errorlevel 1 (
    set "APP_DST=%%f"
    goto :found_app
  )
)
echo [X] 在 chunks\ 下找不到 app-*.js
pause
exit /b 1

:found_app
echo [*] 备份原文件...
if not exist "%APP_DST%.bak" copy "%APP_DST%" "%APP_DST%.bak" >nul
if not exist "%VER_DIR%\background.js.bak" copy "%VER_DIR%\background.js" "%VER_DIR%\background.js.bak" >nul

echo [*] 安装中文版...
copy /y "%~dp0..\app-DRpXG1p6.js" "%APP_DST%" >nul
if errorlevel 1 (
  echo [X] 复制失败，请确认 BrowserOS 已完全退出后重试。
  pause
  exit /b 1
)
copy /y "%~dp0..\background.js" "%VER_DIR%\background.js" >nul
if errorlevel 1 (
  echo [X] 复制失败，请确认 BrowserOS 已完全退出后重试。
  pause
  exit /b 1
)

echo.
echo [OK] 安装完成！重新打开 BrowserOS，打开扩展设置页检查是否为中文。
pause
