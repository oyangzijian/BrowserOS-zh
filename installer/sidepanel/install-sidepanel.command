#!/bin/bash
# BrowserOS 侧边栏 Assistant 图片粘贴修复 - 安装 (macOS)
# 用法：完全退出 BrowserOS 后，双击本脚本。
set -e
cd "$(dirname "$0")"
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

if ! command -v node >/dev/null 2>&1; then
  echo "❌ 找不到 node。本补丁需要用 node 修改扩展文件。"
  echo "你电脑上装过 Node（自动建车型工具在用），如仍提示此错误，把本文件夹路径发给 Lulu 处理。"
  read -p "按回车退出"
  exit 1
fi

FIX="fix_sidepanel_paste.js"
if [ ! -f "$FIX" ] && [ -f "../../tools/fix_sidepanel_paste.js" ]; then
  FIX="../../tools/fix_sidepanel_paste.js"
fi
if [ ! -f "$FIX" ]; then
  echo "❌ 找不到 fix_sidepanel_paste.js，请不要单独移动本脚本，要在解压后的完整文件夹里运行。"
  read -p "按回车退出"
  exit 1
fi

if pgrep -x "BrowserOS" >/dev/null 2>&1; then
  echo "⚠️ 检测到 BrowserOS 正在运行。请先完全退出（右键程序坞图标 → 退出），再重新双击本脚本。"
  read -p "按回车退出"
  exit 1
fi

EXT_BASE="$HOME/Library/Application Support/BrowserOS/Default/Extensions/bflpfmnmnokmjhmgnolecpppdbdophmk"
VER_DIR=$(ls -d "$EXT_BASE"/*_0 2>/dev/null | sort -V | tail -1)
if [ -z "$VER_DIR" ]; then
  echo "❌ 找不到 BrowserOS 扩展目录，请确认已安装 BrowserOS 并运行过一次。"
  read -p "按回车退出"
  exit 1
fi
echo "📦 扩展版本目录：$VER_DIR"

TARGET=$(ls "$VER_DIR"/chunks/mermaid-*.js 2>/dev/null | grep -v '.bak' | head -1)
if [ -z "$TARGET" ]; then
  echo "❌ 在 chunks/ 下找不到 mermaid-*.js（侧边栏文件）"
  read -p "按回车退出"
  exit 1
fi
echo "🎯 目标文件：$TARGET"

if [ ! -f "$TARGET.bak-paste" ]; then
  cp "$TARGET" "$TARGET.bak-paste"
  echo "📝 已备份原文件：$TARGET.bak-paste"
fi

node "$FIX" "$TARGET"

echo ""
echo "✅ 完成！重新打开 BrowserOS，在 Assistant 对话框里复制一张图片后按 ⌘+V 测试。"
echo "   测试要用支持图片的模型（如 MiMo）；智谱 GLM-4.7-Flash 是纯文本模型，看不了图。"
read -p "按回车退出"
