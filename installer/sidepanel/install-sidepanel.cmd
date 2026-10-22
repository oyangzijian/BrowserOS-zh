@echo off
chcp 65001 >nul
REM BrowserOS 侧边栏粘贴修复一键安装 (Windows)
REM 用法：在完整包的 sidepanel 文件夹里，双击 install-sidepanel.cmd 运行。
REM 需要已安装 Node.js（没有请先到 https://nodejs.org 装 LTS 版）。

if not exist "%~dp0fix_sidepanel_paste.js" (
  echo [X] 找不到 fix_sidepanel_paste.js。
  echo 请不要单独移动本脚本：在完整包的 sidepanel 文件夹里双击运行。
  pause
  exit /b 1
)

where node >nul 2>nul
if errorlevel 1 (
  echo [X] 找不到 Node.js。本补丁需要 Node.js 才能打。
  echo 请先到 https://nodejs.org 安装 LTS 版，然后重新双击本脚本。
  pause
  exit /b 1
)

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

for /f "delims=" %%d in ('dir /b /ad /o-n "%EXT_BASE%" 2^>nul') do (
  set "VER_DIR=%EXT_BASE%\%%d"
  goto :found_ver
)
echo [X] 扩展目录下找不到版本文件夹
pause
exit /b 1

:found_ver
echo [*] 扩展版本目录：%VER_DIR%

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
echo [*] 目标文件：%TARGET%
if not exist "%TARGET%.bak-paste" copy "%TARGET%" "%TARGET%.bak-paste" >nul
node "%~dp0fix_sidepanel_paste.js" "%TARGET%"
if errorlevel 1 (
  echo.
  echo [X] 补丁未应用（原文件没有被修改）。常见原因：扩展版本与 0.0.161.0 不一致。
  echo 把上面的输出发给维护者处理即可，你的 BrowserOS 不受影响。
  pause
  exit /b 1
)
echo.
echo [OK] 完成！重新打开 BrowserOS，在 Assistant 对话框里复制一张图片后按 Ctrl+V 测试。
echo 测试要用支持图片的模型（如 MiMo）；智谱 GLM-4.7-Flash 是纯文本模型，看不了图。
pause
