
param(
  [string]$ToolboxName = "Codex登录刷新工具"
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$desktop = [Environment]::GetFolderPath("Desktop")
$toolbox = Join-Path $desktop $ToolboxName
New-Item -ItemType Directory -Force -Path $toolbox | Out-Null

function Write-Cmd($name, $body) {
  $path = Join-Path $toolbox $name
  [System.IO.File]::WriteAllText($path, $body, (New-Object System.Text.UTF8Encoding $false))
}

Write-Cmd "1_一键刷新Codex登录.cmd" @"
@echo off
title Codex Auth Refresh
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\run-refresh.ps1"
echo.
echo Done. You can close this window.
pause
"@

Write-Cmd "2_登录失效时重新登录.cmd" @"
@echo off
title Codex Auth Re-Login
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\login-profile.ps1"
echo.
echo Done. You can close this window.
pause
"@

Write-Cmd "3_查看刷新状态.cmd" @"
@echo off
title Codex Auth Status
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\status.ps1"
echo.
pause
"@

Write-Cmd "4_打开日志和工具目录.cmd" @"
@echo off
title Codex Auth Folders
start "" "$root"
start "" "$root\logs"
start "" "$root\backups"
exit /b 0
"@

Write-Cmd "README.txt" @"
Codex login refresh toolbox

Real tool location:
$root

Use these desktop entries:

1_一键刷新Codex登录.cmd
Run a manual refresh now.

2_登录失效时重新登录.cmd
Use this when ChatGPT login state expires. A browser window opens. Log in, return to the terminal, and press Enter.

3_查看刷新状态.cmd
Show scheduled task status, last run result, auth.json status, and recent logs.

4_打开日志和工具目录.cmd
Open the tool, logs, and backups folders.

Notes:
- Tokens are not stored on the desktop.
- Logs mask token values.
- The scheduled task name is CodexAuthSessionRefresh.
- The workaround updates the Codex auth.json file because Codex reads it by default.
"@

Write-Host "[OK] Desktop toolbox created: $toolbox"
