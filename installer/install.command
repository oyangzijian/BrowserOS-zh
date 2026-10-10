#!/bin/bash
# BrowserOS 中文版一键安装脚本 (macOS)
# 用法：在解压后的完整文件夹里，双击 installer/install.command 运行。
set -e
cd "$(dirname "$0")/.."

APP_SRC="app-DRpXG1p6.js"
BG_SRC="background.js"

# 预检1：脚本必须和两个 js 文件在同一解压包里（防止单独移动脚本导致静默失败）
if [ ! -f "$APP_SRC" ] || [ ! -f "$BG_SRC" ]; then
  echo "❌ 找不到 $APP_SRC 或 $BG_SRC。"
  echo "请不要单独移动本脚本：在解压后的完整文件夹里双击 installer/install.command 运行。"
  read -p "按回车退出"
  exit 1
fi

# 预检2：BrowserOS 必须先完全退出，否则替换可能不生效
if pgrep -x "BrowserOS" >/dev/null 2>&1; then
  echo "⚠️  检测到 BrowserOS 正在运行。"
  echo "请先完全退出 BrowserOS（右键程序坞图标 → 退出），然后重新双击本脚本。"
  read -p "按回车退出"
  exit 1
fi

EXT_BASE="$HOME/Library/Application Support/BrowserOS/Default/Extensions/bflpfmnmnokmjhmgnolecpppdbdophmk"

if [ ! -d "$EXT_BASE" ]; then
  echo "❌ 找不到 BrowserOS 扩展目录："
  echo "   $EXT_BASE"
  echo "请确认已安装 BrowserOS 并运行过一次。"
  read -p "按回车退出"
  exit 1
fi

# 自动找版本号目录（如 0.0.161.0_0），取最新的
VER_DIR=$(ls -d "$EXT_BASE"/*_0 2>/dev/null | sort -V | tail -1)
if [ -z "$VER_DIR" ]; then
  echo "❌ 扩展目录下找不到版本文件夹"
  read -p "按回车退出"
  exit 1
fi
echo "📦 扩展版本目录：$VER_DIR"

CHUNKS="$VER_DIR/chunks"

# 找主界面文件（文件名中的 hash 可能随版本变化）
APP_DST=$(ls "$CHUNKS"/app-*.js 2>/dev/null | grep -v '.bak' | head -1)
if [ -z "$APP_DST" ]; then
  echo "❌ 在 chunks/ 下找不到 app-*.js"
  read -p "按回车退出"
  exit 1
fi

echo "📝 备份原文件..."
[ -f "$APP_DST.bak" ] || cp "$APP_DST" "$APP_DST.bak"
[ -f "$VER_DIR/background.js.bak" ] || cp "$VER_DIR/background.js" "$VER_DIR/background.js.bak"

echo "📥 安装中文版..."
cp "$APP_SRC" "$APP_DST" || { echo "❌ 复制失败，请确认 BrowserOS 已完全退出后重试。"; read -p "按回车退出"; exit 1; }
cp "$BG_SRC" "$VER_DIR/background.js" || { echo "❌ 复制失败，请确认 BrowserOS 已完全退出后重试。"; read -p "按回车退出"; exit 1; }

echo ""
echo "✅ 安装完成！重新打开 BrowserOS，打开扩展设置页检查是否为中文。"
read -p "按回车退出"
