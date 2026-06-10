<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/Codex%20Auth%20Refresh-%F0%9F%94%91-1a1a2e?style=for-the-badge&logo=openai&logoColor=white&labelColor=0d1117">
    <img alt="Codex Auth Session Refresh" src="https://img.shields.io/badge/Codex%20Auth%20Refresh-%F0%9F%94%91-1a1a2e?style=for-the-badge&logo=openai&logoColor=white&labelColor=ffffff">
  </picture>
</p>

<p align="center">
  <em>Bypass the OAuth wall. Keep Codex authenticated — automatically.</em>
</p>

<p align="center">
  <a href="#-overview"><img src="https://img.shields.io/badge/Overview-%F0%9F%93%96-blue?style=flat-square" alt="Overview"></a>
  <a href="#-how-it-works"><img src="https://img.shields.io/badge/How%20It%20Works-%E2%9A%99%EF%B8%8F-blue?style=flat-square" alt="How It Works"></a>
  <a href="#-quick-start"><img src="https://img.shields.io/badge/Quick%20Start-%F0%9F%9A%80-green?style=flat-square" alt="Quick Start"></a>
  <a href="#-scheduled-refresh"><img src="https://img.shields.io/badge/Automation-%E2%8F%B0-orange?style=flat-square" alt="Automation"></a>
  <a href="#-security"><img src="https://img.shields.io/badge/Security-%F0%9F%94%92-red?style=flat-square" alt="Security"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Windows-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Node.js-18%2B-339933?style=flat-square&logo=node.js&logoColor=white" alt="Node.js 18+">
  <img src="https://img.shields.io/badge/Chrome%20%7C%20Edge-4285F4?style=flat-square&logo=google-chrome&logoColor=white" alt="Chrome | Edge">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT License">
</p>

---

## 📖 Overview

Codex CLI stores authentication in a local `auth.json` — but the standard OAuth browser flow can be **painful or impossible** in:

- 🔒 **Corporate proxies** blocking OAuth redirects
- 🐳 **Container / WSL environments** without a browser
- 🖥️ **Remote desktop / SSH sessions** with restricted auth flows
- 🔄 **Short-lived session tokens** that expire frequently

This tool bridges the gap: it extracts a fresh `access_token` from your existing ChatGPT web session and writes it directly to Codex's `auth.json`.

> **No reverse engineering. No MITM. No API abuse.**  
> Just a headless(ish) browser reading your own session cookie, the same way your browser does every time you load chatgpt.com.

---

## ⚙️ How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    Your Local Machine                     │
│                                                          │
│  ┌────────────────────┐    ┌─────────────────────────┐   │
│  │  ChatGPT Web       │    │  Playwright Browser     │   │
│  │  Session Profile   │───▶│  (Persistent Context)   │   │
│  └────────────────────┘    └──────────┬──────────────┘   │
│                                        │                  │
│                                        ▼                  │
│                              ┌─────────────────────┐      │
│                              │  chatgpt.com/api/   │      │
│                              │  auth/session       │      │
│                              └──────────┬──────────┘      │
│                                         │                  │
│                                         ▼                  │
│                              ┌─────────────────────┐      │
│                              │    accessToken       │      │
│                              └──────────┬──────────┘      │
│                                         │                  │
│                                         ▼                  │
│                              ┌─────────────────────┐      │
│                              │  ~/.codex/auth.json  │◀────│─── Codex reads this
│                              │  (patched)           │      │
│                              └─────────────────────┘      │
│                                                          │
│  ┌──────────────────────────────────────────────────┐    │
│  │  Scheduled Task (every N hours)                  │    │
│  │  → Automatically refreshes before token expires  │    │
│  └──────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### Token Flow

| Step | What happens |
|------|-------------|
| **1** | Playwright launches Chrome/Edge with a persistent browser profile |
| **2** | Navigates to `https://chatgpt.com/api/auth/session` |
| **3** | Parses the JSON response, extracts `accessToken` |
| **4** | Decodes the JWT payload to verify account_id and expiry |
| **5** | Backs up existing `auth.json` → writes fresh token |
| **6** | Logs anonymized metadata (no token value stored in logs) |

---

## 🚀 Quick Start

### Prerequisites

| Requirement | Version |
|------------|---------|
| **Node.js** | ≥ 18 |
| **Editor** | Chrome or Microsoft Edge (any recent version) |
| **OS** | Windows 10/11 (primary target) |

### 1. Install

```powershell
# Clone or download, then:
cd codex-auth-session-refresh

# Isolated npm cache (avoids global conflicts)
$env:npm_config_cache = Join-Path (Get-Location) ".npm-cache"
npm install --no-audit --no-fund
```

### 2. First Login

```powershell
.\login-profile.ps1
```

A browser window opens with the project's **isolated** browser profile.
- Log in to ChatGPT normally
- Complete any 2FA if enabled
- Return to PowerShell and **press Enter**

The tool extracts your session token and writes it to `~/.codex/auth.json`.

### 3. Verify

```powershell
.\status.ps1
```

Expected output:
```
=== Codex Auth Refresh Status ===

[TASK] State: Ready
[AUTH] access_token length: 1024
[AUTH] account_id present: True
```

Now open Codex — it should authenticate using the patched `auth.json`.

---

## ⏰ Scheduled Refresh

Session tokens expire. Set it and forget it:

```powershell
# Default: every 4 hours
.\install-scheduled-task.ps1

# Custom interval
.\install-scheduled-task.ps1 -EveryHours 2
```

Creates a Windows Scheduled Task named `CodexAuthSessionRefresh` that:
- Runs every N hours (configurable, default 4)
- Starts 5 minutes after installation (no immediate interference)
- Has a 5-minute execution timeout
- Works on battery (laptop-friendly)

### Manual Control

| Command | Purpose |
|---------|---------|
| `.\run-refresh.ps1` | Refresh now (headed browser, auto-closes) |
| `.\login-profile.ps1` | Re-login when ChatGPT session expires |
| `.\status.ps1` | Check task status + auth.json state |
| `Unregister-ScheduledTask -TaskName "CodexAuthSessionRefresh" -Confirm:$false` | Remove scheduled task |

---

## 🧰 Desktop Toolbox

For users who prefer clicking:

```powershell
.\create-desktop-toolbox.ps1
```

Creates a folder on your desktop named `Codex登录刷新工具` with:

| Entry | Action |
|-------|--------|
| `1_一键刷新.cmd` | Manual refresh |
| `2_重新登录.cmd` | Re-login (browser opens) |
| `3_查看状态.cmd` | Status check |
| `4_打开日志目录.cmd` | Opens tool/logs/backups folders |

---

## 🔒 Security

### Project Philosophy

This tool handles **your own authentication state** — treat it with the same care as your password manager.

### What's Protected

| Asset | Protected? | Why |
|-------|-----------|-----|
| `browser-profile/` | ✅ `.gitignore` | Contains ChatGPT login session |
| `auth.json` | ✅ `.gitignore` | Contains raw access tokens |
| `logs/` | ✅ `.gitignore` | Metadata only — tokens are **never** written to logs |
| `backups/` | ✅ `.gitignore` | Historical auth state (includes old tokens) |

### Risk Model

```
Compromise Vector          Impact
────────────────────────────────────────────────────────
browser-profile leaked  → Full ChatGPT account access
auth.json leaked        → API access until token expires
Scheduled task hijacked → Token refresh mechanism abused
```

If you suspect any of these are compromised: **sign out of all ChatGPT sessions**, rotate credentials, and delete the project's `browser-profile/` directory.

### Design Decisions

- **Playwright `persistentContext`** — keeps cookies across runs without storing passwords
- **Logs strip tokens** — `refresh-codex-auth.js` explicitly deletes the token field before logging
- **Backup before write** — `auth.json` is backed up with a timestamp before every update
- **Isolated profile** — the browser profile lives in `browser-profile/`, separate from your daily browser

---

## 🛠️ Configuration

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `CODEX_AUTH_REFRESH_HOME` | script root | Project home |
| `CODEX_AUTH_REFRESH_PROFILE` | `./browser-profile` | Browser profile directory |
| `CODEX_AUTH_REFRESH_BACKUP` | `./backups` | Auth backup directory |
| `CODEX_AUTH_REFRESH_LOG` | `./logs` | Log directory |
| `CODEX_AUTH_REFRESH_BROWSER` | auto-detect | Full path to Chrome/Edge executable |
| `CODEX_AUTH_PATH` | `~/.codex/auth.json` | Target auth.json path |

### Script Arguments

#### `install-scheduled-task.ps1`
| Param | Default | Description |
|-------|---------|-------------|
| `-TaskName` | `CodexAuthSessionRefresh` | Scheduled task name |
| `-EveryHours` | `4` | Refresh interval |

#### `status.ps1`
| Param | Default | Description |
|-------|---------|-------------|
| `-TaskName` | `CodexAuthSessionRefresh` | Task to inspect |
| `-AuthPath` | `~/.codex/auth.json` | Auth file to check |

---

## 🧪 How It Works: Technical Detail

### Session Endpoint Response

The ChatGPT session endpoint returns a JSON object containing:

```json
{
  "accessToken": "eyJhbGciOiJSUzI1Ni...",
  "expires": "2026-06-11T00:00:00.000Z",
  "user": { "email": "user@example.com" }
}
```

### JWT Payload Extraction

The tool decodes the JWT **without verification** (it doesn't need to — this is your own token) to extract:
- `chatgpt_account_id` — for multi-account scenarios
- `exp` — token expiry timestamp (logged for monitoring)

### Why Headed Mode?

ChatGPT's session endpoint sometimes returns `{}` in true headless mode — possibly a bot-detection measure. The tool runs **headed but auto-closing**, so you see a brief flash and it's done.

---

## 📁 Project Structure

```
codex-auth-session-refresh/
├── scripts/
│   └── refresh-codex-auth.js   # Core: browser + token extraction logic
├── create-desktop-toolbox.ps1  # Desktop shortcut generator
├── install-scheduled-task.ps1  # Windows Task Scheduler installer
├── login-profile.ps1           # First-time ChatGPT login
├── run-refresh.ps1             # Manual token refresh
├── status.ps1                  # Health check + diagnostics
├── package.json                # Node.js project config
├── SECURITY.md                 # Security notes
└── README.md                   # This file
```

---

## 📄 License

MIT. Do what you want — just don't blame us if a token expires mid-session.

---

<p align="center">
  <sub>Built for developers who just want Codex to <em>work</em>.</sub>
</p>
