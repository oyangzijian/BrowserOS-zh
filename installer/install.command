#!/bin/bash
# BrowserOS 中文版一键安装脚本 (macOS)
# 双击运行。会备份原文件，然后替换为中文版。
set -e
cd "$(dirname "$0")/.."

EXT_BASE="$HOME/Library/Application Support/BrowserOS/Default/Extensions/bflpfmnmnokmjhmgnolecpppdbdophmk"

if [ ! -d "$EXT_BASE" ]; then
  echo "❌ 找不到 BrowserOS 扩展目录："
  echo "   $EXT_BASE"
  echo "请确认已安装 BrowserOS 并运行过一次。"
  read -p "按回车退出"
  exit 1
fi

# 自动找版本号目录（如 0.0.161.0_0）
VER_DIR=$(ls -d "$EXT_BASE"/*_0 2>/dev/null | sort -V | tail -1)
if [ -z "$VER_DIR" ]; then
  echo "❌ 扩展目录下找不到版本文件夹"
  read -p "按回车退出"
  exit 1
fi
echo "📦 扩展版本目录：$VER_DIR"

CHUNKS="$VER_DIR/chunks"
APP_SRC="app-DRpXG1p6.js"
BG_SRC="background.js"

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
cp "$APP_SRC" "$APP_DST"
cp "$BG_SRC" "$VER_DIR/background.js"

echo ""
echo "✅ 安装完成！请完全退出 BrowserOS 再重新打开。"
read -p "按回车退出"
