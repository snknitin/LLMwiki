# A failed prep must not cancel the night (2026-10-23 ran nothing after prep timed out). Fake `python` (the prep agent)
# exits 1, fake `claude` builds; the lanes must still run and the receipt must say attention, not ready.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-prep-failure.ps1   (needs no other overnight run going)
$ErrorActionPreference = 'Stop'
$tmp = Join-Path ([IO.Path]::GetTempPath()) "test-prep-failure-$PID"
$vault = Join-Path $tmp 'vault'; $projects = Join-Path $tmp 'projects'; $shims = Join-Path $tmp 'shims'
New-Item -ItemType Directory -Force (Join-Path $vault 'Nightly Runs\agent-rules'), (Join-Path $vault 'Morning Runs'), $projects, $shims | Out-Null
try {
    Set-Content (Join-Path $shims 'python.cmd') '@echo prep agent fake failure & exit /b 1' -Encoding Ascii
    Set-Content (Join-Path $shims 'claude.cmd') '@powershell -NoProfile -Command "Set-Content built.txt x; git add built.txt; git commit -qm build; git push -q; ''built''"' -Encoding Ascii
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') 'fixture builder prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') 'fixture prep prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\roles.json') '{"claude":{"builder":"claude:opus","qa":"off","fallbackQa":"off"}}'
    Set-Content (Join-Path $vault 'Nightly Runs\Project Priorities.md') "## Tonight`n`n### Claude`n- alpha qa=off`n`n### Codex`n`n### Hermes`n`n## Backlog"
    $d = Join-Path $projects 'alpha'; New-Item -ItemType Directory -Force (Join-Path $d 'scripts') | Out-Null
    Set-Content (Join-Path $d 'scripts\verify.ps1') 'exit 1'; Set-Content (Join-Path $d 'BUILD_SPEC.md') '# fixture'   # no build tree, so prep has work
    git -C $d init -q -b main 2>$null; git -C $d config user.email t@example.com; git -C $d config user.name T
    git -C $d add -A; git -C $d commit -qm init
    git init -q --bare (Join-Path $tmp 'alpha.git'); git -C $d remote add origin (Join-Path $tmp 'alpha.git'); git -C $d push -q -u origin main 2>$null
    $env:OVERNIGHT_VAULT = $vault; $env:OVERNIGHT_PROJECTS = $projects; $env:PATH = "$shims;$env:PATH"
    $ErrorActionPreference = 'Continue'
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'overnight-run.ps1') -Kind morning -PrepMinutes 1 -HoursPerProject 1 2>&1 | Out-String
    $ErrorActionPreference = 'Stop'
    $receipt = Get-Content (Join-Path $vault 'Nightly Runs\prep-status.json') -Raw | ConvertFrom-Json
    $fails = @()
    if ($out -notmatch 'prep: FAILED') { $fails += 'prep did not fail as staged' }
    if (-not (Test-Path (Join-Path $d 'built.txt'))) { $fails += 'the lane did not run after the failed prep' }
    if ($receipt.state -ne 'attention' -or $receipt.reason -notmatch 'did not finish') { $fails += "receipt is '$($receipt.state)': $($receipt.reason)" }
    $prepReport = Get-Content (Join-Path $vault 'Nightly Runs\Prep Report.md') -Raw -ErrorAction SilentlyContinue
    if ($prepReport -notmatch '## Checked by the runner' -or $prepReport -notmatch '- alpha \([^)]*\): no new commit') { $fails += "Prep Report has no git check for alpha: $prepReport" }
    if ($fails) { Write-Output $out; throw ($fails -join '; ') }
    Write-Output 'PREP FAILURE OK: the lane ran after a failed prep, receipt says attention, Prep Report says what git shows'
} finally { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
