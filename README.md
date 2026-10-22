# BrowserOS 中文版（Ask BrowserOS 扩展汉化 + 新增服务商）

基于 [oyangzijian/BrowserOS](https://github.com/oyangzijian/BrowserOS) 的 Ask BrowserOS 扩展，做中文界面汉化，并新增 DeepSeek、Xiaomi MiMo、智谱 GLM 服务商一键配置。

## 改了什么

- **界面汉化**：设置页、侧边栏、新标签页等 260+ 处英文翻译成中文（键盘键名如 Home/Delete/Tab 故意保留英文）。
- **新增服务商卡片**："使用自己的 API 密钥"从 8 个增加到 11 个，新增：
  - **DeepSeek**：预填 `https://api.deepseek.com`，默认模型 `deepseek-chat`
  - **Xiaomi MiMo**：预填 `https://api.xiaomimimo.com/v1`，默认模型 `mimo-v2.6-flash`
  - **智谱 GLM**（v1.1.0 新增）：预填 `https://open.bigmodel.cn/api/paas/v4`，默认模型 `glm-4.7-flash`（免费、200K 上下文、纯文本输入，API Key 在智谱开放平台申请）
- 三者底层走 OpenAI 兼容协议，保存时自动映射为 `openai-compatible` 类型，服务器稳定识别。
- **图片粘贴修复**（v1.1.0）：对话框粘贴图片时增加 `clipboardData.files` 兜底（部分 macOS 应用复制的图片只在 files 里）；新标签页首页输入框放开附件限制，普通服务商（内嵌聊天模式）也能粘贴/添加图片，不再误报“该智能体暂不支持附件”。注意：智谱 GLM-4.7-Flash 本身是纯文本模型，看图请切到支持图片的模型（如 MiMo）。
- **Assistant 侧边栏粘贴图片**（v1.1.2）：官方 0.0.161.0 的侧边栏对话框原本没有任何粘贴图片处理（输入框只有 onChange/onKeyDown）。本版给侧边栏补上粘贴支持：复制图片后在侧边栏按 ⌘+V / Ctrl+V，输入框上方出现橙色提示条（独占一行，不遮挡输入），输入一句话发送即把图片一起发出。实现脚本在 `tools/fix_sidepanel_paste.js`，一键安装脚本在 `installer/sidepanel/`。

![服务商列表](providers.jpg)

![MiMo 服务商中文配置与实测](mimo-demo.jpg)

## 文件说明

| 文件 | 说明 |
|---|---|
| `app-DRpXG1p6.js` | 汉化+新增服务商后的主界面文件（对应扩展 `0.0.161.0` 版本 `chunks/` 目录） |
| `background.js` | 汉化后的后台脚本 |
| `tools/zh_map3.json` | 中英对照表 |
| `tools/apply_zh4.js` | 汉化脚本（AST 精确定位替换，`node apply_zh4.js`） |
| `tools/add_providers.js` | 新增 DeepSeek/MiMo 脚本（`node add_providers.js`，用 acorn 按模块标准校验） |
| `tools/add_glm.js` | 在 v1.0.1 成品基础上新增智谱 GLM 脚本（`node add_glm.js`） |
| `tools/fix_paste.js` | 图片粘贴修复脚本（`node fix_paste.js`） |
| `tools/fix_sidepanel_paste.js` | 侧边栏粘贴图片补丁脚本（`node fix_sidepanel_paste.js`，作用于 `chunks/mermaid-*.js`） |
| `installer/sidepanel/` | 侧边栏粘贴补丁的一键安装/恢复脚本（macOS + Windows） |

## 安装方法（推荐：一键脚本）

1. 从 [Releases](https://github.com/oyangzijian/BrowserOS-zh/releases) 下载最新版完整包 `BrowserOS-zh-full-v1.1.2.zip` 并解压（不要只解压出单个脚本，整个文件夹都要保留）。
2. 完全退出 BrowserOS（macOS：右键程序坞图标 → 退出；Windows：右键任务栏图标 → 退出）。
3. **第 1 步（主包）**：双击运行安装脚本：
   - macOS：`installer/install.command`
   - Windows：`installer/install.cmd`

   脚本会自动找到扩展目录、备份原文件（`.bak`），然后替换为中文版。装完即有汉化、11 个服务商和设置页图片粘贴。

   > macOS 如果提示"无法验证开发者"：右键点击 `install.command` → 打开 → 仍要打开，即可运行。这是未签名脚本的正常提示，只需操作一次。

4. **第 2 步（侧边栏粘贴补丁，可选但推荐）**：需要电脑装有 [Node.js](https://nodejs.org)（LTS 版）。双击运行：
   - macOS：`sidepanel/install-sidepanel.command`
   - Windows：`sidepanel/install-sidepanel.cmd`

   脚本会备份侧边栏文件（`.bak-paste`）再打补丁；扩展版本不是 0.0.161.0 时会拒绝执行，不会改坏文件。

5. 重新打开 BrowserOS，打开扩展设置页，界面应为中文；各服务商的 API Key 需要在每台电脑上各填一次。

恢复原版：主包双击 `installer/restore.command`（macOS）或 `installer/restore.cmd`（Windows）；侧边栏补丁双击 `sidepanel/restore-sidepanel.command` / `restore-sidepanel.cmd`。

### 手动安装（备用）

如果一键脚本在你的机器上找不到扩展目录，再按以下步骤手动操作：

1. 完全退出 BrowserOS。
2. 找到扩展目录，例如 macOS：
   ```
   ~/Library/Application Support/BrowserOS/Default/Extensions/bflpfmnmnokmjhmgnolecpppdbdophmk/0.0.161.0_0/
   ```
   （`0.0.161.0_0` 是版本号，你的机器上可能不同，取最新的那个）
3. 先备份原文件（重要）：把 `chunks/` 目录下 `app-` 开头的 `.js` 文件复制一份改名为 `.bak` 后缀；把扩展根目录的 `background.js` 复制一份改名为 `background.js.bak`。
4. 用本仓库的 `app-DRpXG1p6.js` 替换 `chunks/` 下的 `app-*.js`，用 `background.js` 替换扩展根目录的同名文件。
5. 重新打开 BrowserOS。

> 注意：扩展带官方自动更新，更新后会被覆盖，需要重新打补丁（用 `tools/` 里的脚本对新版本重跑即可）。

## 版本

- 基于扩展 `0.0.161.0`，2026-10-10 制作。
- MiMo 模型请用 `mimo-v2.6-flash`（已测试可用）。
- v1.1.0（2026-10-22）：新增智谱 GLM-4.7-Flash 服务商；修复对话框图片粘贴（files 兜底 + 首页输入框放开附件）。
- v1.1.2（2026-10-22）：新增 Assistant 侧边栏粘贴图片（完整版整合包 `BrowserOS-zh-full-v1.1.2.zip`，含主包 + 侧边栏补丁 + Mac/Win 双平台脚本）。（v1.1.1 的悬浮提示条会遮挡输入框，已被 v1.1.2 的独立行提示条取代，请勿使用 v1.1.1。）

## 声明

本仓库文件由 BrowserOS 官方扩展二次修改而来，仅做界面汉化与服务商配置增强，原版权归原作者所有。
