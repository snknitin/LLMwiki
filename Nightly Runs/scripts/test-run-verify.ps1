# A verify that leaves a process holding its stdout must not hang the runner, and one that never ends must hit the limit.
$ErrorActionPreference = 'Stop'
$run = Join-Path $PSScriptRoot 'run-verify.ps1'
$dir = Join-Path $env:TEMP "test-run-verify-$PID"
New-Item -ItemType Directory -Force $dir | Out-Null
try {
    $leaves = Join-Path $dir 'leaves-a-process.ps1'
    Set-Content $leaves "Write-Output 'VERIFY RAN'`n`$null = Start-Process ping.exe -ArgumentList '-n','40','127.0.0.1' -PassThru -NoNewWindow`nexit 7"
    $out = Join-Path $dir 'out.txt'
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $code = & $run $leaves $out
    if ($clock.Elapsed.TotalSeconds -gt 20) { throw "waited $($clock.Elapsed.TotalSeconds) s on the leftover process" }
    if ($code -ne 7) { throw "expected exit code 7, got '$code'" }
    if (-not (Select-String -LiteralPath $out -SimpleMatch 'VERIFY RAN' -Quiet)) { throw 'the output file has no verify output' }
    # The retry, while that leftover process is still running: same output file, and the real exit code.
    Remove-Item -LiteralPath $out
    $code = & $run $leaves $out
    if ($code -ne 7) { throw "expected 7 from the retry, got '$code'" }
    if (-not (Select-String -LiteralPath $out -SimpleMatch 'VERIFY RAN' -Quiet)) { throw 'the retry wrote no verify output' }

    $never = Join-Path $dir 'never-ends.ps1'
    Set-Content $never 'Start-Sleep -Seconds 120'
    $clock.Restart()
    $code = & $run $never $out 0.05
    if ($clock.Elapsed.TotalSeconds -gt 20) { throw 'the limit did not stop the verify' }
    if ($code -ne 1) { throw "expected 1 at the limit, got '$code'" }
    Write-Output 'PASS test-run-verify'
} finally {
    Get-Process ping -ErrorAction SilentlyContinue | Where-Object { $_.StartTime -gt (Get-Date).AddMinutes(-2) } | Stop-Process -Force -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue
}
