<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/zcz-user/codex-auth-session-refresh/main/assets/header-dark.svg">
    <img src="https://raw.githubusercontent.com/zcz-user/codex-auth-session-refresh/main/assets/header-light.svg" width="100%" alt="Codex Auth Session Refresh">
  </picture>
</p>

<p align="center">
  <b>中文</b>
  &nbsp;·&nbsp;
  <a href="./README.md">English</a>
  &nbsp;·&nbsp;
  <a href="https://github.com/zcz-user/codex-auth-session-refresh/issues">报告问题</a>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/zcz-user/codex-auth-session-refresh?style=flat-square&logo=github" alt="Stars">
  <img src="https://img.shields.io/badge/Windows-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Node.js-18+-339933?style=flat-square&logo=node.js" alt="Node.js">
  <img src="https://img.shields.io/badge/Playwright-45ba4b?style=flat-square&logo=playwright" alt="Playwright">
  <img src="https://img.shields.io/github/license/zcz-user/codex-auth-session-refresh?style=flat-square" alt="MIT">
  <img src="https://img.shields.io/github/last-commit/zcz-user/codex-auth-session-refresh?style=flat-square&logo=git" alt="最近更新">
</p>

---

## 🎯 这个工具给谁的？

**给所有用 Codex CLI 但被验证码折磨的人。** 看看是不是你：

| 😤 痛点 | 💥 有多烦 |
|---------|----------|
| **Codex OAuth 死活登不上** | 公司代理、WSL、容器——浏览器根本弹不出来 |
| **OpenAI 二次验证每次都要搞** | 几小时过期一次，重登到崩溃 |
| **被迫用中转站/代理 API** | 想用官方功能，但验证码过不去，只能用第三方 |
| **token 写到一半过期** | 上下文全丢，重新来，工作效率归零 |

**中一条就是你。** 你花了钱订 ChatGPT / Codex，你**应该能用它**。这个工具就是让你跳过验证码的折磨，直接写代码。

---

## 💡 原理

从你已有的 ChatGPT 浏览器会话里提取 `access_token`，直接写进 Codex CLI 的 `~/.codex/auth.json`。

**不需要逆向。不需要抓包。不需要滥用 API。** 就是让你的浏览器帮 Codex 拿个通行证。

```
你的 ChatGPT 会话 → codex-auth → ~/.codex/auth.json → Codex CLI 直接干活
```

---

## ✨ 功能

| | |
|---|---|
| 🔌 **一行搞定** | `npm install && .\login-profile.ps1` — 完事 |
| 🤖 **自动续命** | Windows 定时任务刷新，再也不怕过期 |
| 🛡️ **安全设计** | Token 永不记日志，每次更新自动备份 |
| 🪟 **桌面快捷** | `create-desktop-toolbox.ps1` — 点一下就刷 |
| 🔍 **状态面板** | `status.ps1` — 一眼看出 token 有没有问题 |
| 🔧 **灵活配置** | 6 个环境变量，路径随便改 |

---

## 🚀 快速开始

```powershell
git clone https://github.com/zcz-user/codex-auth-session-refresh.git
cd codex-auth-session-refresh
npm install
.\login-profile.ps1     # → 弹窗 → 登录 ChatGPT → 回车
.\status.ps1            # 看看 Codex 认不认这个 token
.\install-scheduled-task.ps1  # 再也不用手动刷了
```

---

## 📋 命令速查

| 命令 | 干什么 |
|------|--------|
| `login-profile.ps1` | 首次登录 / 重登（弹浏览器） |
| `run-refresh.ps1` | 立刻刷 Codex token（浏览器自动关） |
| `status.ps1` | 查看 Codex auth 状态 |
| `install-scheduled-task.ps1` | 装定时任务，自动续命 |
| `create-desktop-toolbox.ps1` | 桌面快捷工具箱 |

### 定时任务

```powershell
.\install-scheduled-task.ps1                # 每 4 小时
.\install-scheduled-task.ps1 -EveryHours 2  # 每 2 小时

# 卸载
Unregister-ScheduledTask -TaskName "CodexAuthSessionRefresh" -Confirm:$false
```

---

## 🛡️ 安全

| 风险 | 怎么防 |
|------|--------|
| 误提交到 Git | `browser-profile/`、`logs/`、`auth.json` 全在 `.gitignore` 里 |
| Token 泄漏 | 日志明确 `delete safe.token` 再写入 |
| auth.json 写坏 | 每次更新前**带时间戳备份** |

> **泄露了？** 登出所有 ChatGPT 会话 → 删 `browser-profile/` → 改密码。

---

## 🏗️ 架构

```
┌───────────────────────────────────────────────────────────┐
│                        你的 Windows                         │
│                                                           │
│  浏览器 → Playwright → chatgpt.com/api/auth/session       │
│                              │                            │
│                              ▼                            │
│                   ┌─────────────────────┐                  │
│                   │  ~/.codex/auth.json │◀── Codex 会读    │
│                   └─────────┬───────────┘                  │
│                             │                              │
│                             ▼                              │
│                   ┌────────────────────┐                   │
│                   │ Windows 定时任务    │                   │
│                   │ (自动刷新)          │                   │
│                   └────────────────────┘                   │
└───────────────────────────────────────────────────────────┘
```

---

<p align="center">
  <a href="https://github.com/zcz-user/codex-auth-session-refresh/stargazers">
    <img src="https://img.shields.io/github/stars/zcz-user/codex-auth-session-refresh?style=social" alt="Stars">
  </a>
  <a href="https://github.com/zcz-user/codex-auth-session-refresh/network/members">
    <img src="https://img.shields.io/github/forks/zcz-user/codex-auth-session-refresh?style=social" alt="Forks">
  </a>
  <br>
  <sub>🧩 Codex Skill — 你付了钱，你就该用上</sub>
</p>
