param(
  [string] $TaskName   = "CodexAuthSessionRefresh",
  [int]    $EveryHours = 4
)

$ErrorActionPreference = "Stop"
$scriptPath = Join-Path $PSScriptRoot "run-refresh.ps1"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(5) -RepetitionInterval (New-TimeSpan -Hours $EveryHours) -RepetitionDuration (New-TimeSpan -Days 3650)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "Refresh Codex auth.json from ChatGPT" -Force | Out-Null
Write-Host "[OK] Scheduled task installed: $TaskName"
Write-Host "[OK] Runs every $EveryHours hours via $scriptPath"