# A pause from the board stops the scheduled tasks (-Scheduled) and nothing else. Starts no agent: a paused run exits
# at once, and an unpaused one is stopped by -Preflight before any work. Usage: powershell -File test-pause.ps1
$ErrorActionPreference = 'Continue'   # the runner writes progress to stderr; the checks below decide
$runner = Join-Path $PSScriptRoot 'overnight-run.ps1'
$vault = Join-Path ([IO.Path]::GetTempPath()) "test-pause-$PID"
New-Item -ItemType Directory -Force (Join-Path $vault 'Nightly Runs') | Out-Null
$fails = @()
try {
    $env:OVERNIGHT_VAULT = $vault
    $pause = Join-Path $vault 'Nightly Runs\pause.json'
    Set-Content $pause (@{ until = (Get-Date).AddHours(3).ToUniversalTime().ToString('o') } | ConvertTo-Json)
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Kind nightly -Scheduled 2>&1 | Out-String
    if ($out -notmatch 'Scheduled run skipped: paused until') { $fails += "paused run did not skip: $out" }
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -PrepOnly -Scheduled 2>&1 | Out-String
    if ($out -notmatch 'Scheduled prep skipped: paused until') { $fails += "paused prep did not skip: $out" }
    # Without -Scheduled (Prep now, Start a run now) the pause does not apply; -Preflight keeps it from doing work.
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Preflight 2>&1 | Out-String
    if ($out -match 'skipped: paused') { $fails += 'a manual start was paused' }
    Set-Content $pause (@{ until = (Get-Date).AddHours(-1).ToUniversalTime().ToString('o') } | ConvertTo-Json)
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Preflight -Scheduled 2>&1 | Out-String
    if ($out -match 'skipped: paused') { $fails += 'an expired pause still skipped' }
} finally { Remove-Item Env:OVERNIGHT_VAULT -ErrorAction SilentlyContinue; Remove-Item -Recurse -Force $vault -ErrorAction SilentlyContinue }
if ($fails) { throw ($fails -join '; ') }
Write-Output 'PAUSE OK: scheduled prep and run skip while paused; manual starts and an expired pause do not'
