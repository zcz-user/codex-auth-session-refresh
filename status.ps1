$ErrorActionPreference = "SilentlyContinue"

param(
  [string]$TaskName = "CodexAuthSessionRefresh",
  [string]$AuthPath = "$env:USERPROFILE\.codex\auth.json"
)

$root = $PSScriptRoot
$logPath = Join-Path $root "logs\refresh.log.jsonl"

Write-Host ""
Write-Host "=== Codex Auth Refresh Status ==="
Write-Host ""

$task = Get-ScheduledTask -TaskName $TaskName
if ($null -eq $task) {
  Write-Host "[TASK] Missing: $TaskName"
} else {
  $info = Get-ScheduledTaskInfo -TaskName $TaskName
  Write-Host "[TASK] Name: $TaskName"
  Write-Host "[TASK] State: $($task.State)"
  Write-Host "[TASK] LastRunTime: $($info.LastRunTime)"
  Write-Host "[TASK] LastTaskResult: $($info.LastTaskResult) (0 means success)"
  Write-Host "[TASK] NextRunTime: $($info.NextRunTime)"
}

Write-Host ""

if (Test-Path -LiteralPath $AuthPath) {
  try {
    $auth = Get-Content -LiteralPath $AuthPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Write-Host "[AUTH] Path: $AuthPath"
    Write-Host "[AUTH] auth_mode: $($auth.auth_mode)"
    Write-Host "[AUTH] last_refresh: $($auth.last_refresh)"
    Write-Host "[AUTH] access_token length: $($auth.tokens.access_token.Length)"
    Write-Host "[AUTH] refresh_token length: $($auth.tokens.refresh_token.Length)"
    Write-Host "[AUTH] account_id present: $(-not [string]::IsNullOrWhiteSpace($auth.tokens.account_id))"
  } catch {
    Write-Host "[AUTH] Failed to parse auth.json: $($_.Exception.Message)"
  }
} else {
  Write-Host "[AUTH] Missing: $AuthPath"
}

Write-Host ""

if (Test-Path -LiteralPath $logPath) {
  Write-Host "[LOG] Last entries:"
  Get-Content -LiteralPath $logPath -Tail 5 -Encoding UTF8
} else {
  Write-Host "[LOG] Missing: $logPath"
}

Write-Host ""
Write-Host "Tool root: $root"
Write-Host ""
