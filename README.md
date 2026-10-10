# BrowserOS 中文版（Ask BrowserOS 扩展汉化 + 新增服务商）

基于 [oyangzijian/BrowserOS](https://github.com/oyangzijian/BrowserOS) 的 Ask BrowserOS 扩展，做中文界面汉化，并新增 DeepSeek、Xiaomi MiMo 服务商一键配置。

## 改了什么

- **界面汉化**：设置页、侧边栏、新标签页等 260+ 处英文翻译成中文（键盘键名如 Home/Delete/Tab 故意保留英文）。
- **新增服务商卡片**："使用自己的 API 密钥"从 8 个增加到 10 个，新增：
  - **DeepSeek**：预填 `https://api.deepseek.com`，默认模型 `deepseek-chat`
  - **Xiaomi MiMo**：预填 `https://api.xiaomimimo.com/v1`，默认模型 `mimo-v2.6-flash`
- 两者底层走 OpenAI 兼容协议，保存时自动映射为 `openai-compatible` 类型，服务器稳定识别。

![服务商列表](screenshots/providers.jpg)

## 一键安装（推荐）

1. 下载本仓库的 `app-DRpXG1p6.js`、`background.js` 和 `installer/` 文件夹，放在同一目录。
2. 完全退出 BrowserOS。
3. 双击运行：
   - macOS：`installer/install.command`
   - Windows：`installer/install.cmd`
4. 脚本会自动备份原文件并替换。重新打开 BrowserOS 即可。

恢复英文原版：双击 `installer/restore.command`（macOS）或 `installer/restore.cmd`（Windows）。

## 手动安装

1. 完全退出 BrowserOS。
2. 找到扩展目录：
   - macOS：`~/Library/Application Support/BrowserOS/Default/Extensions/bflpfmnmnokmjhmgnolecpppdbdophmk/0.0.161.0_0/chunks/`
   - Windows：`%LOCALAPPDATA%\BrowserOS\User Data\Default\Extensions\bflpfmnmnokmjhmgnolecpppdbdophmk\0.0.161.0_0\chunks\`
3. 备份原文件（重要）。
4. 用本仓库的 `app-DRpXG1p6.js` 替换 `chunks/` 下同名文件，用 `background.js` 替换扩展根目录的同名文件。
5. 重新打开 BrowserOS。

> 注意：扩展带官方自动更新，更新后会被覆盖，需要重新打补丁（用 `tools/` 里的脚本对新版本重跑即可）。

## 文件说明

| 文件 | 说明 |
|---|---|
| `app-DRpXG1p6.js` | 汉化+新增服务商后的主界面文件 |
| `background.js` | 汉化后的后台脚本 |
| `installer/` | 一键安装/恢复脚本（macOS + Windows） |
| `tools/zh_map3.json` | 中英对照表 |
| `tools/apply_zh4.js` | 汉化脚本（AST 精确定位替换） |
| `tools/add_providers.js` | 新增服务商脚本（acorn 模块标准校验） |

## 版本

- 基于扩展 0.0.161.0，2026-10-10 制作。
- MiMo 模型请用 mimo-v2.6-flash，已测试可用。

## 开源协议

本项目按 [GNU AGPL-3.0](LICENSE) 分发。原 BrowserOS 扩展版权归原作者所有。
