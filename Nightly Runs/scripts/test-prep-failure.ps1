# A failed prep step must not stop a lane (2026-10-23 ran nothing after prep timed out). A run no longer preps serially
# before the lanes: a tonight project's prep item is its lane's first step, on the lane's model. Fake `claude` fails when
# called as the planner (-n Prep) and builds when called as the builder; the lane must still build, at once.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-prep-failure.ps1   (needs no other overnight run going)
$ErrorActionPreference = 'Stop'
$tmp = Join-Path ([IO.Path]::GetTempPath()) "test-prep-failure-$PID"
$vault = Join-Path $tmp 'vault'; $projects = Join-Path $tmp 'projects'; $shims = Join-Path $tmp 'shims'
New-Item -ItemType Directory -Force (Join-Path $vault 'Nightly Runs\agent-rules'), (Join-Path $vault 'Morning Runs'), $projects, $shims | Out-Null
try {
    Set-Content (Join-Path $shims 'claude.cmd') ('@echo %* | findstr /C:"-n Prep" >nul && (echo prep agent fake failure & exit /b 1)' + "`r`n" +
        '@powershell -NoProfile -Command "Set-Content built.txt x; git add built.txt; git commit -qm build; git push -q; ''built''"') -Encoding Ascii
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
    $report = Get-Content (Join-Path $vault 'Morning Runs\Morning Report.md') -Raw -ErrorAction SilentlyContinue
    $fails = @()
    if ($out -match 'prep: (FAILED|finished)') { $fails += 'the run waited on a serial prep before its lanes' }
    if ($report -notmatch 'build-tree[^|]*made no commit on claude:opus; building on the current target') { $fails += "the lane's first step was not the build-tree item on the lane's model: $report" }
    if (-not (Test-Path (Join-Path $d 'built.txt'))) { $fails += 'the lane did not build after the failed prep step' }
    if ($fails) { Write-Output $out; throw ($fails -join '; ') }
    Write-Output 'PREP FAILURE OK: the prep step ran first on the lane model, failed, and the lane built anyway'
} finally { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
