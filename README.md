<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/zcz-user/codex-auth-session-refresh/main/assets/header-dark.svg">
    <img src="https://raw.githubusercontent.com/zcz-user/codex-auth-session-refresh/main/assets/header-light.svg" width="100%" alt="Codex Auth Session Refresh">
  </picture>
</p>

<p align="center">
  <b><a href="./README_zh.md">中文</a></b>
  &nbsp;·&nbsp;
  <a href="https://github.com/zcz-user/codex-auth-session-refresh/issues">Report Bug</a>
  &nbsp;·&nbsp;
  <a href="https://clawhub.com/skill/codex-auth-session">🧩 ClawHub Skill</a>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/zcz-user/codex-auth-session-refresh?style=flat-square&logo=github" alt="Stars">
  <img src="https://img.shields.io/badge/Windows-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Node.js-18%2B-339933?style=flat-square&logo=node.js" alt="Node.js">
  <img src="https://img.shields.io/badge/Playwright-45ba4b?style=flat-square&logo=playwright" alt="Playwright">
  <img src="https://img.shields.io/github/license/zcz-user/codex-auth-session-refresh?style=flat-square" alt="MIT">
  <img src="https://img.shields.io/github/last-commit/zcz-user/codex-auth-session-refresh?style=flat-square&logo=git" alt="Last commit">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square" alt="PRs Welcome">
  <img src="https://img.shields.io/badge/ClawHub-Skill-8A2BE2?style=flat-square" alt="ClawHub Skill">
</p>

---

## 🎯 Who Is This For?

**You, if you're a Codex CLI user** who is stuck with any of these:

| 😤 Problem | 💥 The pain |
|------------|------------|
| **Codex OAuth won't complete** | Corporate proxies, WSL, containers — the browser never opens right |
| **OpenAI 2FA every time** | Re-authenticating every few hours is a nightmare |
| **Forced to use API proxies** | You want official Codex features, but auth keeps failing so you settle for third-party |
| **Token expires mid-session** | Lose your context, have to re-auth, workflow destroyed |

**If any of this sounds like you, this tool is for you.**

You paid for ChatGPT / Codex. You should be able to *use* it. This tool gets your auth working so you can focus on coding, not fighting login screens.

---

## 💡 What This Does

Extracts a fresh `access_token` from your existing ChatGPT browser session and writes it directly to Codex CLI's `~/.codex/auth.json`.

**No reverse engineering. No MITM. No API abuse.** Just your browser giving Codex what it needs.

```
Your ChatGPT session → codex-auth → ~/.codex/auth.json → Codex CLI works
```

---

## ✨ Features

| | |
|---|---|
| 🔌 **One command setup** | `npm install && .\login-profile.ps1` — done |
| 🤖 **Auto-refresh** | Windows Scheduled Task so you never lose auth again |
| 🛡️ **Safe by design** | Token never logged, backup before every write |
| 🪟 **Desktop shortcuts** | `create-desktop-toolbox.ps1` — click to run |
| 🔍 **Health dashboard** | `status.ps1` — task + token state at a glance |
| 🔧 **Fully configurable** | 6 environment variables for custom paths |

---

## 🚀 Quick Start

### One-liner install

```powershell
git clone https://github.com/zcz-user/codex-auth-session-refresh.git
cd codex-auth-session-refresh
npm install
```

### Login once

```powershell
.\login-profile.ps1
# → Browser opens → Login to ChatGPT → Press Enter
```

### Verify

```powershell
.\status.ps1
# → Check Codex auth.json is active
```

### Set it and forget it

```powershell
.\install-scheduled-task.ps1
# → Auto-refresh every 4 hours
```

---

## 📋 Reference

### Commands

| Command | What it does |
|---------|-------------|
| `login-profile.ps1` | First login / re-login (opens browser) |
| `run-refresh.ps1` | Refresh Codex's token now (browser auto-closes) |
| `status.ps1` | Check Codex auth.json state |
| `install-scheduled-task.ps1` | Auto-refresh every N hours |
| `create-desktop-toolbox.ps1` | Create desktop shortcuts |

### Env Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `CODEX_AUTH_PATH` | `~/.codex/auth.json` | Codex auth file target |
| `CODEX_AUTH_REFRESH_BROWSER` | _auto-detect_ | Chrome/Edge path override |
| `CODEX_AUTH_REFRESH_PROFILE` | `./browser-profile` | Browser profile storage |
| `CODEX_AUTH_REFRESH_BACKUP` | `./backups` | Auth file backup dir |
| `CODEX_AUTH_REFRESH_LOG` | `./logs` | Operation log dir |

### Scheduled Task

```powershell
.\install-scheduled-task.ps1               # Every 4h
.\install-scheduled-task.ps1 -EveryHours 2  # Every 2h

# Uninstall
Unregister-ScheduledTask -TaskName "CodexAuthSessionRefresh" -Confirm:$false
```

---

## 🛡️ Security

| Attack Vector | Mitigation |
|---------------|------------|
| `.gitignore` | `browser-profile/`, `logs/`, `backups/`, `auth.json` all excluded |
| Token leak | Logs explicitly `delete safe.token` before writing |
| Corrupted auth | Backup with timestamp **before every write** |

> **Compromised?** Sign out all ChatGPT sessions → delete `browser-profile/` → rotate credentials.

---

## 🏗️ Architecture

```
┌───────────────────────────────────────────────────────────┐
│                   Your Windows Machine                     │
│                                                           │
│  browser → Playwright → chatgpt.com/api/auth/session     │
│                              │                            │
│                              ▼                            │
│                   ┌─────────────────────┐                  │
│                   │  ~/.codex/auth.json │◀── Codex reads  │
│                   └─────────┬───────────┘                  │
│                             │                              │
│                             ▼                              │
│                   ┌────────────────────┐                   │
│                   │ Windows Task       │                   │
│                   │ (auto-refresh)     │                   │
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
  <sub>🧩 Codex Skill — because you paid for Codex, you should be able to use it</sub>
</p>
