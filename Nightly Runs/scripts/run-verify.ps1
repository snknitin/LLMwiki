# Runs one project's verify, puts its output in a file and returns its exit code (1 if it hit the limit).
# A cmd redirect, not a PowerShell pipe: a verify can leave a server behind that still holds its stdout, and a pipe would
# then never close, so the runner would wait forever (2026-10-31: 65 minutes on a stray `next start`). That server keeps
# the redirected file open too, so each run writes its own file: a retry could not reopen the same one.
param([string]$Verify, [string]$Out, [double]$Minutes = 30)
$work = "$Out.$([guid]::NewGuid().ToString('N')).tmp"
$arguments = '/d', '/c', "powershell -NoProfile -ExecutionPolicy Bypass -File `"$Verify`" > `"$work`" 2>&1"
$p = Start-Process cmd.exe -ArgumentList $arguments -WorkingDirectory (Get-Location).Path -PassThru -WindowStyle Hidden
$null = $p.Handle   # without this, ExitCode is empty once the process has ended
$finished = $p.WaitForExit([int]($Minutes * 60000))
if (-not $finished) { & taskkill.exe /PID $p.Id /T /F *> $null }
Copy-Item -LiteralPath $work -Destination $Out -Force
Remove-Item -LiteralPath $work -ErrorAction SilentlyContinue
if ($finished) { return $p.ExitCode }
return 1
