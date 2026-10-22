@echo off
chcp 65001 >nul
REM BrowserOS 侧边栏粘贴修复一键恢复 (Windows)
REM 用补丁安装时的备份（.bak-paste）还原侧边栏文件。

tasklist /fi "imagename eq BrowserOS.exe" 2>nul | find /i "BrowserOS.exe" >nul
if not errorlevel 1 (
  echo [!] 检测到 BrowserOS 正在运行。
  echo 请先完全退出 BrowserOS，然后重新双击本脚本。
  pause
  exit /b 1
)

set "EXT_BASE=%LOCALAPPDATA%\BrowserOS\User Data\Default\Extensions\bflpfmnmnokmjhmgnolecpppdbdophmk"
if not exist "%EXT_BASE%" (
  echo [X] 找不到 BrowserOS 扩展目录：%EXT_BASE%
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
for %%f in ("%VER_DIR%\chunks\mermaid-*.js") do (
  echo %%f | findstr /i "\.bak" >nul
  if errorlevel 1 (
    set "TARGET=%%f"
    goto :found_target
  )
)
echo [X] 在 chunks\ 下找不到 mermaid-*.js
pause
exit /b 1

:found_target
if not exist "%TARGET%.bak-paste" (
  echo [X] 找不到备份文件 %TARGET%.bak-paste，可能还没有装过这个补丁。
  pause
  exit /b 1
)
copy /y "%TARGET%.bak-paste" "%TARGET%" >nul
echo [OK] 已恢复到打补丁之前的状态。重新打开 BrowserOS 即可。
pause
