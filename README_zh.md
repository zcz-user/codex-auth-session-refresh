<p align="center">
  <img src="https://img.shields.io/badge/Codex%20Auth%20Session%20Refresh-%F0%9F%94%91-1a1a2e?style=for-the-badge&logo=openai&labelColor=white" alt="Codex Auth Session Refresh">
</p>

<p align="center">
  <b>从 ChatGPT 浏览器会话中刷新 Codex CLI 的 <code>auth.json</code></b><br>
  <i>适用于 OAuth 登录流程难以完成的受限环境</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Windows-0078D6?logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/npm-%3E%3D18-CB3837?logo=npm" alt="npm >=18">
  <img src="https://img.shields.io/badge/Chrome%2FEdge-4285F4?logo=googlechrome&logoColor=white" alt="Chrome/Edge">
  <img src="https://img.shields.io/github/license/zcz-user/codex-auth-session-refresh" alt="License">
  <img src="https://img.shields.io/github/last-commit/zcz-user/codex-auth-session-refresh" alt="Last Commit">
</p>

---

## 痛点

Codex CLI 需要在 `~/.codex/auth.json` 中存放有效的 `access_token` 才能工作。但标准的 OAuth 浏览器登录流程在以下场景中常常失败：

| 场景 | 原因 |
|------|------|
| 公司代理/防火墙 | OAuth 重定向被拦截 |
| WSL / Docker 容器 | 没有浏览器可用 |
| 远程桌面 / SSH | 认证弹窗异常 |
| Token 过期 | 每几小时就得重新认证一次 |

## 解决方案

从你**已有的 ChatGPT 浏览器会话**中提取新鲜的 `access_token`，直接写入 Codex 的 `auth.json`。

```
ChatGPT 浏览器会话
       │
       ▼
 ┌─────────────────┐      ┌──────────────────┐
 │ Playwright Core │─────▶│ chatgpt.com/api/ │
 │ (浏览器引擎)      │      │ auth/session     │
 └─────────────────┘      └────────┬─────────┘
                                   │ accessToken
                                   ▼
 ┌──────────────────────────────────────────────┐
 │           ~/.codex/auth.json                 │
 │  (每次更新前自动备份)                           │
 └──────────────────────────────────────────────┘
                                   │
                                   ▼
 ┌──────────────────────────────────────────────┐
 │        Windows 定时任务                       │
 │  (每 N 小时自动刷新，无需人工干预)                │
 └──────────────────────────────────────────────┘
```

> 无逆向、无中间人攻击、无 API 滥用。  
> 只是用浏览器读了一下你自己的 session cookie——和每次打开 chatgpt.com 时浏览器做的事情一模一样。

---

## 快速开始

### 1. 安装依赖

```powershell
git clone https://github.com/zcz-user/codex-auth-session-refresh.git
cd codex-auth-session-refresh

$env:npm_config_cache = Join-Path (Get-Location) ".npm-cache"
npm install --no-audit --no-fund
```

### 2. 首次登录

```powershell
.\login-profile.ps1
```

会弹出一个浏览器窗口。登录 ChatGPT，回到 PowerShell 按 **Enter** 即可。

### 3. 验证状态

```powershell
.\status.ps1
```

---

## 命令速查

| 命令 | 说明 |
|------|------|
| `.\login-profile.ps1` | 首次登录 / Cookie 过期后重新登录 |
| `.\run-refresh.ps1` | 立即刷新 token（浏览器自动关闭） |
| `.\install-scheduled-task.ps1` | 安装定时自动刷新 |
| `.\status.ps1` | 查看任务状态 + auth.json 情况 |
| `.\create-desktop-toolbox.ps1` | 在桌面创建快捷工具箱 |

**卸载定时任务：**
```powershell
Unregister-ScheduledTask -TaskName "CodexAuthSessionRefresh" -Confirm:$false
```

---

## 定时刷新

```powershell
# 默认每 4 小时刷新一次
.\install-scheduled-task.ps1

# 自定义间隔（例如每 2 小时）
.\install-scheduled-task.ps1 -EveryHours 2
```

- 任务名称：`CodexAuthSessionRefresh`
- 超时时间：5 分钟
- 支持电池供电模式（笔记本友好）

---

## 桌面工具箱

把常用操作一键放在桌面上：

```powershell
.\create-desktop-toolbox.ps1
```

会在桌面创建 `Codex登录刷新工具` 文件夹，内含：

| 快捷方式 | 功能 |
|---------|------|
| `1_一键刷新.cmd` | 手动刷新 token |
| `2_重新登录.cmd` | 重新登录 ChatGPT |
| `3_查看状态.cmd` | 查看运行状态 |
| `4_打开日志目录.cmd` | 打开工具和日志文件夹 |

---

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `CODEX_AUTH_REFRESH_HOME` | 脚本所在目录 | 项目根目录 |
| `CODEX_AUTH_REFRESH_PROFILE` | `./browser-profile` | 浏览器配置文件目录 |
| `CODEX_AUTH_REFRESH_BACKUP` | `./backups` | auth.json 备份目录 |
| `CODEX_AUTH_REFRESH_LOG` | `./logs` | 日志目录 |
| `CODEX_AUTH_REFRESH_BROWSER` | 自动检测 | Chrome/Edge 可执行文件路径 |
| `CODEX_AUTH_PATH` | `~/.codex/auth.json` | 目标 auth.json 路径 |

---

## 安全

### 以下内容禁止提交到 Git

| 目录/文件 | 包含什么 |
|-----------|---------|
| `browser-profile/` | ChatGPT 登录会话状态 |
| `auth.json` | 原始 access token |
| `logs/` | 运行日志（token 已脱敏，但仍敏感） |
| `backups/` | 历史 auth.json 备份 |

以上全部通过 `.gitignore` 排除 ✓

### 日志策略

日志**不会**记录 token 原文：

```javascript
const safe = { ...row };
delete safe.token;  // token 永不写入磁盘
```

仅记录：时间戳、执行状态（成功/失败）、account_id 是否存在（布尔值）、用户邮箱是否存在（布尔值）、JWT 过期时间。

### 泄露处理

如果 `browser-profile/` 或 `auth.json` 被泄露：
1. 登出所有 ChatGPT 会话（chatgpt.com → 设置 → 安全 → 登出所有设备）
2. 删除 `browser-profile/` 目录
3. 删除 `backups/` 目录
4. 修改 ChatGPT 密码

---

## 项目结构

```
codex-auth-session-refresh/
├── scripts/
│   └── refresh-codex-auth.js    # 核心逻辑
├── .github/workflows/
│   └── ci.yml                   # CI 工作流
├── create-desktop-toolbox.ps1   # 桌面快捷方式生成器
├── install-scheduled-task.ps1   # 定时任务安装器
├── login-profile.ps1            # 首次登录
├── run-refresh.ps1              # 手动刷新
├── status.ps1                   # 健康检查
├── package.json                 # Node 依赖
├── SECURITY.md                  # 安全说明
├── CONTRIBUTING.md              # 贡献指南
├── README.md                    # 英文版本文档
└── README_zh.md                 # 本文（中文版）
```

---

<p align="center">
  <a href="./README.md">English README</a>
</p>
