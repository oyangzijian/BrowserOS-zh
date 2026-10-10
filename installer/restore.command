#!/bin/bash
# BrowserOS 中文版一键恢复脚本 (macOS)
# 双击运行。从备份恢复英文原版。
set -e

# 预检：BrowserOS 必须先完全退出
if pgrep -x "BrowserOS" >/dev/null 2>&1; then
  echo "⚠️  检测到 BrowserOS 正在运行。"
  echo "请先完全退出 BrowserOS（右键程序坞图标 → 退出），然后重新双击本脚本。"
  read -p "按回车退出"
  exit 1
fi

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
if [ -n "$APP_DST" ] && [ -f "$APP_DST.bak" ]; then
  cp "$APP_DST.bak" "$APP_DST"
  echo "✅ 已恢复主界面文件"
  RESTORED=1
else
  echo "⚠️  找不到主界面文件的备份"
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
  echo "请重新打开 BrowserOS，扩展已恢复为英文原版。"
fi
read -p "按回车退出"
