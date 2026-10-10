#!/bin/bash
# BrowserOS 中文版一键恢复脚本 (macOS)
# 双击运行。从备份恢复英文原版。
set -e

EXT_BASE="$HOME/Library/Application Support/BrowserOS/Default/Extensions/bflpfmnmnokmjhmgnolecpppdbdophmk"

if [ ! -d "$EXT_BASE" ]; then
  echo "❌ 找不到 BrowserOS 扩展目录"
  read -p "按回车退出"
  exit 1
fi

VER_DIR=$(ls -d "$EXT_BASE"/*_0 2>/dev/null | sort -V | tail -1)
CHUNKS="$VER_DIR/chunks"
APP_DST=$(ls "$CHUNKS"/app-*.js 2>/dev/null | grep -v '.bak' | head -1)

RESTORED=0
if [ -f "$APP_DST.bak" ]; then
  cp "$APP_DST.bak" "$APP_DST"
  echo "✅ 已恢复主界面文件"
  RESTORED=1
else
  echo "⚠️  找不到主界面文件的备份（$APP_DST.bak）"
fi

if [ -f "$VER_DIR/background.js.bak" ]; then
  cp "$VER_DIR/background.js.bak" "$VER_DIR/background.js"
  echo "✅ 已恢复 background.js"
  RESTORED=1
else
  echo "⚠️  找不到 background.js 的备份"
fi

if [ "$RESTORED" = "1" ]; then
  echo ""
  echo "请完全退出 BrowserOS 再重新打开。"
fi
read -p "按回车退出"
