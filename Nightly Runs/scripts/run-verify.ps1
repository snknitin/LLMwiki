# Runs one project's verify with its output in a file and returns its exit code (1 if it hit the limit).
# A cmd redirect, not a PowerShell pipe: a verify can leave a server behind that still holds its stdout, and a pipe would
# then never close, so the runner would wait forever (2026-10-31: 65 minutes on a stray `next start`).
param([string]$Verify, [string]$Out, [double]$Minutes = 30)
$arguments = '/d', '/c', "powershell -NoProfile -ExecutionPolicy Bypass -File `"$Verify`" > `"$Out`" 2>&1"
$p = Start-Process cmd.exe -ArgumentList $arguments -WorkingDirectory (Get-Location).Path -PassThru -WindowStyle Hidden
$null = $p.Handle   # without this, ExitCode is empty once the process has ended
if ($p.WaitForExit([int]($Minutes * 60000))) { return $p.ExitCode }
& taskkill.exe /PID $p.Id /T /F *> $null
return 1
