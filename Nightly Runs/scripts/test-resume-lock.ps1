# A -Resume check with no cut-off run must never hold up the scheduled prep it fires with (2026-10-29 18:00): it waited
# for the prep (as a real run would) while the prep waited for it, so the prep gave up with "Another run is going". It
# must also not claim .runner.lock, which turns away a prep or run that starts in the same seconds.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-resume-lock.ps1   (needs no other overnight run going)
$ErrorActionPreference = 'Stop'
$tmp = Join-Path ([IO.Path]::GetTempPath()) "test-runlock-$PID"   # no "-resume" in the path: the runner matches *-Resume* in command lines
$vault = Join-Path $tmp 'vault'
New-Item -ItemType Directory -Force (Join-Path $vault 'Nightly Runs\agent-rules'), (Join-Path $tmp 'fake') | Out-Null
$fake = $null
try {
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') 'fixture builder prompt'
    $env:OVERNIGHT_VAULT = $vault; $env:OVERNIGHT_PROJECTS = Join-Path $tmp 'projects'
    $resume = { & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'overnight-run.ps1') -Resume 2>&1 | Out-String }
    $fails = @()
    $out = & $resume
    if (Test-Path (Join-Path $vault 'Nightly Runs\.runner.lock')) { $fails += 'a -Resume with nothing to continue wrote .runner.lock' }
    # A prep going (any overnight-run.ps1 -PrepOnly counts): the resume check steps aside at once instead of waiting for it.
    Set-Content (Join-Path $tmp 'fake\overnight-run.ps1') 'Start-Sleep -Seconds 120'
    $fake = Start-Process powershell -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$(Join-Path $tmp 'fake\overnight-run.ps1')`"", '-PrepOnly' -WindowStyle Hidden -PassThru
    Start-Sleep -Seconds 2
    $took = Measure-Command { $out += & $resume }
    if ($took.TotalSeconds -gt 45) { $fails += "a -Resume check waited $([int]$took.TotalSeconds) s for a running prep" }
    if ($fails) { Write-Output $out; throw ($fails -join '; ') }
    Write-Output 'RESUME LOCK OK: a resume check with nothing to continue leaves the run lock alone and never waits for a prep'
} finally {
    if ($fake) { Stop-Process -Id $fake.Id -Force -ErrorAction SilentlyContinue }
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
