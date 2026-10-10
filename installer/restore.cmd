@echo off
chcp 65001 >nul
REM BrowserOS 中文版一键恢复脚本 (Windows)
REM 双击运行。从备份恢复英文原版。

set "EXT_BASE=%LOCALAPPDATA%\BrowserOS\User Data\Default\Extensions\bflpfmnmnokmjhmgnolecpppdbdophmk"

if not exist "%EXT_BASE%" (
  echo [X] 找不到 BrowserOS 扩展目录
  pause
  exit /b 1
)

for /f "delims=" %%d in ('dir /b /ad /o-n "%EXT_BASE%" 2^>nul') do (
  set "VER_DIR=%EXT_BASE%\%%d"
  goto :found_ver
)
echo [X] 扩展目录下找不到版本文件夹
pause
exit /b 1

:found_ver
set "CHUNKS=%VER_DIR%\chunks"
for %%f in ("%CHUNKS%\app-*.js") do (
  echo %%f | findstr /i "\.bak" >nul
  if errorlevel 1 (
    set "APP_DST=%%f"
    goto :found_app
  )
)

:found_app
set RESTORED=0
if exist "%APP_DST%.bak" (
  copy /y "%APP_DST%.bak" "%APP_DST%" >nul
  echo [OK] 已恢复主界面文件
  set RESTORED=1
) else (
  echo [!] 找不到主界面文件的备份
)

if exist "%VER_DIR%\background.js.bak" (
  copy /y "%VER_DIR%\background.js.bak" "%VER_DIR%\background.js" >nul
  echo [OK] 已恢复 background.js
  set RESTORED=1
) else (
  echo [!] 找不到 background.js 的备份
)

if "%RESTORED%"=="1" (
  echo.
  echo 请完全退出 BrowserOS 再重新打开。
)
pause
