<p align="center">
  <b><a href="./README.md">English</a> · 中文</b>
</p>

<h1 align="center">Codex Auth Session Refresh</h1>

<p align="center">
  从 ChatGPT 浏览器会话刷新 Codex CLI 的 <code>auth.json</code><br>
  <sub>适用于 OAuth 流程走不通的受限环境</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/-Windows-0078D6?logo=windows" alt="Windows">
  <img src="https://img.shields.io/badge/-Node≥18-CB3837?logo=npm" alt="Node>=18">
  <img src="https://img.shields.io/badge/-Chrome%2FEdge-4285F4?logo=googlechrome" alt="Chrome/Edge">
  <img src="https://img.shields.io/github/license/zcz-user/codex-auth-session-refresh" alt="License">
  <img src="https://img.shields.io/github/last-commit/zcz-user/codex-auth-session-refresh" alt="Last Commit">
</p>

---

## 痛点

Codex CLI 需要 `~/.codex/auth.json` 里有 `access_token`。但 OAuth 登录在很多环境走不通：

| 场景 | 原因 |
|------|------|
| 公司代理 | OAuth 重定向被拦截 |
| WSL / 容器 | 没有浏览器 |
| 远程桌面 | 弹窗异常 |
| 频繁过期 | 几小时就得重来一次 |

## 原理

从你已有的 ChatGPT 浏览器会话提取 token，写入 Codex 的 `auth.json`。不需要逆向、不需要抓包、不需要 API 滥用。

```
浏览器会话 → chatgpt.com/api/auth/session → accessToken → ~/.codex/auth.json
                                                                   │
                              Windows 定时任务（每 N 小时自动刷新） ←──┘
```

## 快速开始

```powershell
cd codex-auth-session-refresh
$env:npm_config_cache = Join-Path (Get-Location) ".npm-cache"
npm install --no-audit --no-fund
.\login-profile.ps1     # 弹窗登录 ChatGPT，回车即可
.\status.ps1            # 验证状态
```

## 命令

| 命令 | 作用 |
|------|------|
| `.\login-profile.ps1` | 首次登录 / Cookie 失效后重登 |
| `.\run-refresh.ps1` | 立即刷新（浏览器自动关） |
| `.\status.ps1` | 查看任务状态 + auth.json 情况 |
| `.\install-scheduled-task.ps1` | 安装定时刷新 |
| `.\create-desktop-toolbox.ps1` | 桌面快捷工具箱 |

### 定时任务

```powershell
.\install-scheduled-task.ps1           # 默认每 4 小时
.\install-scheduled-task.ps1 -EveryHours 2   # 每 2 小时
```

名称 `CodexAuthSessionRefresh`，超时 5 分钟，笔记本友好。

### 卸载

```powershell
Unregister-ScheduledTask -TaskName "CodexAuthSessionRefresh" -Confirm:$false
```

## 环境变量

| 变量 | 默认 | 说明 |
|------|------|------|
| `CODEX_AUTH_PATH` | `~/.codex/auth.json` | 目标 auth.json 路径 |
| `CODEX_AUTH_REFRESH_BROWSER` | 自动检测 | Chrome/Edge 路径 |
| `CODEX_AUTH_REFRESH_PROFILE` | `./browser-profile` | 浏览器配置目录 |
| `CODEX_AUTH_REFRESH_BACKUP` | `./backups` | 备份目录 |
| `CODEX_AUTH_REFRESH_LOG` | `./logs` | 日志目录 |

## 安全

| 禁止提交 | 原因 |
|---------|------|
| `browser-profile/` | ChatGPT 会话状态 |
| `auth.json` | 原始 access token |
| `logs/` | token 已脱敏，但仍敏感 |
| `backups/` | 历史备份 |

日志不记 token 原文：`delete safe.token`。泄露处理：登出所有会话 → 删 profile → 改密码。

## 项目结构

```
codex-auth-session-refresh/
├── scripts/refresh-codex-auth.js   # 核心逻辑
├── .github/workflows/ci.yml        # CI
├── login-profile.ps1               # 首次登录
├── run-refresh.ps1                 # 手动刷新
├── status.ps1                      # 状态检查
├── install-scheduled-task.ps1      # 定时任务
├── create-desktop-toolbox.ps1      # 桌面快捷方式
└── README.md / README_zh.md        # 文档
```
