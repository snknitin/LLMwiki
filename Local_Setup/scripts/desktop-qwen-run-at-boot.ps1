# One-time, run as administrator: start Desktop Qwen at boot even if nobody logs in (after Windows Update restarts).
# S4U = runs as this user without storing a password; it has no network credentials, which a localhost server doesn't need.
param([string]$User)
$t = 'Desktop Qwen - llama-server'
$principal = New-ScheduledTaskPrincipal -UserId $User -LogonType S4U -RunLevel Limited
Set-ScheduledTask -TaskName $t -Principal $principal -Trigger (New-ScheduledTaskTrigger -AtStartup) | Out-Null
$task = Get-ScheduledTask $t
"$($task.TaskName): logon=$($task.Principal.LogonType) trigger=$($task.Triggers[0].CimClass.CimClassName)" |
    Tee-Object -FilePath 'F:\Vaults\LLMWiki\Local_Setup\work\desktop-qwen-run-at-boot-result.txt'
Start-Sleep 5
