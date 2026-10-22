#!/bin/bash
# BrowserOS 侧边栏 Assistant 图片粘贴修复 - 恢复原文件 (macOS)
set -e
cd "$(dirname "$0")"

if pgrep -x "BrowserOS" >/dev/null 2>&1; then
  echo "⚠️ 检测到 BrowserOS 正在运行。请先完全退出，再重新双击本脚本。"
  read -p "按回车退出"
  exit 1
fi

EXT_BASE="$HOME/Library/Application Support/BrowserOS/Default/Extensions/bflpfmnmnokmjhmgnolecpppdbdophmk"
VER_DIR=$(ls -d "$EXT_BASE"/*_0 2>/dev/null | sort -V | tail -1)
TARGET=$(ls "$VER_DIR"/chunks/mermaid-*.js 2>/dev/null | grep -v '.bak' | head -1)

if [ -n "$TARGET" ] && [ -f "$TARGET.bak-paste" ]; then
  cp "$TARGET.bak-paste" "$TARGET"
  echo "✅ 已恢复侧边栏文件为补丁前版本。"
else
  echo "❌ 找不到备份文件（.bak-paste），无法恢复。"
fi
read -p "按回车退出"
