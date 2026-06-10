<p align="center">
  <img src="https://img.shields.io/badge/Codex%20Auth%20Session%20Refresh-%F0%9F%94%91-1a1a2e?style=for-the-badge&logo=openai&labelColor=white" alt="Codex Auth Session Refresh">
</p>

<p align="center">
  <b>Refresh Codex CLI <code>auth.json</code> from ChatGPT web session</b><br>
  <i>For environments where OAuth is painful or impossible</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Windows-0078D6?logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/npm-%3E%3D18-CB3837?logo=npm" alt="npm >=18">
  <img src="https://img.shields.io/badge/Chrome%2FEdge-4285F4?logo=googlechrome&logoColor=white" alt="Chrome/Edge">
  <img src="https://img.shields.io/github/license/zcz-user/codex-auth-session-refresh" alt="License">
  <img src="https://img.shields.io/github/last-commit/zcz-user/codex-auth-session-refresh" alt="Last Commit">
</p>

---

## Problem

Codex CLI needs `~/.codex/auth.json` with a valid `access_token`. The standard OAuth flow fails in:

| Scenario | Why |
|----------|-----|
| Corporate proxy | OAuth redirects blocked |
| WSL / container | No browser to complete flow |
| Remote desktop | Auth popups break |
| Token expires | Need to re-authenticate every few hours |

## Solution

Extract a fresh `access_token` from your **existing ChatGPT browser session** and write it to Codex `auth.json` — no reverse engineering, no MITM.

```
ChatGPT Web Session
       │
       ▼
 ┌─────────────────┐      ┌──────────────────┐
 │ Playwright Core │─────▶│ chatgpt.com/api/ │
 │ (browser)       │      │ auth/session     │
 └─────────────────┘      └────────┬─────────┘
                                   │ accessToken
                                   ▼
 ┌──────────────────────────────────────────────┐
 │           ~/.codex/auth.json                 │
 │  (backup created before every update)         │
 └──────────────────────────────────────────────┘
                                   │
                                   ▼
 ┌──────────────────────────────────────────────┐
 │        Windows Scheduled Task                │
 │  (every N hours, auto-refresh)               │
 └──────────────────────────────────────────────┘
```

---

## Quick Start

### 1. Install

```powershell
git clone https://github.com/zcz-user/codex-auth-session-refresh.git
cd codex-auth-session-refresh

$env:npm_config_cache = Join-Path (Get-Location) ".npm-cache"
npm install --no-audit --no-fund
```

### 2. First Login

```powershell
.\login-profile.ps1
```

A browser opens. Log in to ChatGPT, return to PowerShell, press **Enter**.

### 3. Verify

```powershell
.\status.ps1
```

---

## Commands

| Command | What it does |
|---------|-------------|
| `.\login-profile.ps1` | First login / re-login (opens browser) |
| `.\run-refresh.ps1` | Refresh token now (browser auto-closes) |
| `.\install-scheduled-task.ps1` | Install auto-refresh every N hours |
| `.\status.ps1` | Check task status + auth.json state |
| `.\create-desktop-toolbox.ps1` | Create desktop shortcuts |

**Uninstall task:**
```powershell
Unregister-ScheduledTask -TaskName "CodexAuthSessionRefresh" -Confirm:$false
```

---

## Scheduled Task

```powershell
# Default: every 4 hours
.\install-scheduled-task.ps1

# Custom interval
.\install-scheduled-task.ps1 -EveryHours 2
```

- Name: `CodexAuthSessionRefresh`
- Timeout: 5 minutes
- Runs on battery (laptop-friendly)

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CODEX_AUTH_REFRESH_HOME` | script root | Project home directory |
| `CODEX_AUTH_REFRESH_PROFILE` | `./browser-profile` | Browser profile directory |
| `CODEX_AUTH_REFRESH_BACKUP` | `./backups` | Auth backup directory |
| `CODEX_AUTH_REFRESH_LOG` | `./logs` | Log directory |
| `CODEX_AUTH_REFRESH_BROWSER` | auto-detect | Chrome/Edge executable path |
| `CODEX_AUTH_PATH` | `~/.codex/auth.json` | Target auth.json path |

---

## Security

| Never commit | Why |
|-------------|-----|
| `browser-profile/` | ChatGPT session state |
| `auth.json` | Raw access tokens |
| `logs/` | Metadata (tokens masked, still sensitive) |
| `backups/` | Historical auth state |

All excluded via `.gitignore` ✓

**Logging policy:** Logs strip token values before writing:

```javascript
const safe = { ...row };
delete safe.token;  // token never touches disk
```

**Breach response:** Sign out all ChatGPT sessions → delete `browser-profile/` → rotate credentials.

---

## Project Structure

```
codex-auth-session-refresh/
├── scripts/
│   └── refresh-codex-auth.js    # Core logic
├── create-desktop-toolbox.ps1   # Desktop shortcuts
├── install-scheduled-task.ps1   # Task scheduler
├── login-profile.ps1            # First login
├── run-refresh.ps1              # Manual refresh
├── status.ps1                   # Health check
├── package.json                 # Node dependencies
├── SECURITY.md                  # Security notes
├── CONTRIBUTING.md              # Contribution guide
└── README.md                    # This file
```

---

<p align="center">
  <a href="./README_zh.md">中文版 README</a>
</p>
