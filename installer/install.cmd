@echo off
chcp 65001 >nul
REM BrowserOS 中文版一键安装脚本 (Windows)
REM 双击运行。会备份原文件，然后替换为中文版。

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
copy /y "%~dp0..\background.js" "%VER_DIR%\background.js" >nul

echo.
echo [OK] 安装完成！请完全退出 BrowserOS 再重新打开。
pause
