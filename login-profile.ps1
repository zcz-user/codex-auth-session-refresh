$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$env:CODEX_AUTH_REFRESH_HOME = $root
$env:CODEX_AUTH_REFRESH_PROFILE = Join-Path $root "browser-profile"
$env:CODEX_AUTH_REFRESH_BACKUP = Join-Path $root "backups"
$env:CODEX_AUTH_REFRESH_LOG = Join-Path $root "logs"

Set-Location $root
node ".\scripts\refresh-codex-auth.js" --login
