<p align="center">
  <b>English · <a href="./README_zh.md">中文</a></b>
</p>

<h1 align="center">Codex Auth Session Refresh</h1>

<p align="center">
  Refresh Codex CLI <code>auth.json</code> from ChatGPT web session<br>
  <sub>For environments where OAuth is painful or impossible</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/-Windows-0078D6?logo=windows" alt="Windows">
  <img src="https://img.shields.io/badge/-Node≥18-CB3837?logo=npm" alt="Node>=18">
  <img src="https://img.shields.io/badge/-Chrome%2FEdge-4285F4?logo=googlechrome" alt="Chrome/Edge">
  <img src="https://img.shields.io/github/license/zcz-user/codex-auth-session-refresh" alt="License">
  <img src="https://img.shields.io/github/last-commit/zcz-user/codex-auth-session-refresh" alt="Last Commit">
</p>

---

## Problem

Codex CLI needs a valid `access_token` in `~/.codex/auth.json`. Standard OAuth fails in:

| Scenario | Why |
|----------|-----|
| Corporate proxy | OAuth redirects blocked |
| WSL / container | No browser available |
| Remote desktop | Auth popups break |
| Token expires | Re-auth every few hours |

## How It Works

Extracts a fresh `access_token` from your existing ChatGPT browser session — no reverse engineering, no MITM.

```
ChatGPT session → chatgpt.com/api/auth/session → accessToken → ~/.codex/auth.json
                                                                        │
                  Windows Scheduled Task (auto-refresh every N hours) ←──┘
```

## Quick Start

```powershell
cd codex-auth-session-refresh
$env:npm_config_cache = Join-Path (Get-Location) ".npm-cache"
npm install --no-audit --no-fund
.\login-profile.ps1     # Opens browser → login ChatGPT → press Enter
.\status.ps1            # Verify everything works
```

## Commands

| Command | Description |
|---------|-------------|
| `.\login-profile.ps1` | First login / re-login |
| `.\run-refresh.ps1` | Refresh now (browser auto-closes) |
| `.\status.ps1` | Check task + auth.json state |
| `.\install-scheduled-task.ps1` | Install auto-refresh |
| `.\create-desktop-toolbox.ps1` | Desktop shortcuts |

### Scheduled Task

```powershell
.\install-scheduled-task.ps1              # Every 4 hours (default)
.\install-scheduled-task.ps1 -EveryHours 2       # Every 2 hours
```

Task name: `CodexAuthSessionRefresh`, timeout: 5 min, battery-friendly.

### Uninstall

```powershell
Unregister-ScheduledTask -TaskName "CodexAuthSessionRefresh" -Confirm:$false
```

## Env Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CODEX_AUTH_PATH` | `~/.codex/auth.json` | Target auth.json |
| `CODEX_AUTH_REFRESH_BROWSER` | auto-detect | Chrome/Edge path |
| `CODEX_AUTH_REFRESH_PROFILE` | `./browser-profile` | Browser profile |
| `CODEX_AUTH_REFRESH_BACKUP` | `./backups` | Backup dir |
| `CODEX_AUTH_REFRESH_LOG` | `./logs` | Log dir |

## Security

| Never commit | Why |
|-------------|-----|
| `browser-profile/` | ChatGPT session state |
| `auth.json` | Raw access tokens |
| `logs/` | Metadata (tokens masked but still sensitive) |
| `backups/` | Historical auth state |

Logs strip tokens: `delete safe.token`. Breach? Sign out all sessions → delete profile → rotate credentials.

## Structure

```
codex-auth-session-refresh/
├── scripts/refresh-codex-auth.js   # Core logic
├── .github/workflows/ci.yml        # CI pipeline
├── login-profile.ps1               # First login
├── run-refresh.ps1                 # Manual refresh
├── status.ps1                      # Health check
├── install-scheduled-task.ps1      # Task scheduler
├── create-desktop-toolbox.ps1      # Desktop shortcuts
├── README.md / README_zh.md        # Docs
```
