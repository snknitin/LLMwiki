# Per-slice QA (2026-10-25): when a builder finishes a slice, QA (another model family) reviews that slice on the lane
# before the next slice is planned, so its findings are fixed the same night. A QA that wrote its review into REPORT.md
# but never printed its "QA RESULT:" line still counts. The final verify runs in parallel.
# Fake `claude`: the builder (commits once) and the planner (-n Prep, commits a plan once). Fake `codex`: the QA; its first
# review has no result line on purpose, later ones say pass.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-slice-qa.ps1   (needs no other overnight run going)
$ErrorActionPreference = 'Stop'
$tmp = Join-Path ([IO.Path]::GetTempPath()) "test-slice-qa-$PID"
$vault = Join-Path $tmp 'vault'; $projects = Join-Path $tmp 'projects'; $shims = Join-Path $tmp 'shims'
New-Item -ItemType Directory -Force (Join-Path $vault 'Nightly Runs\agent-rules'), (Join-Path $vault 'Morning Runs'), $projects, $shims | Out-Null
try {
    Set-Content (Join-Path $shims 'plan.ps1') 'if (-not (Test-Path alpha\plan.txt)) { Set-Content alpha\plan.txt "slice 2"; git -C alpha add plan.txt; git -C alpha commit -qm "Advance to slice 2"; git -C alpha push -q }'
    Set-Content (Join-Path $shims 'build.ps1') 'Set-Content built.txt x; git add built.txt; git commit -qm build 2>$null; git push -q 2>$null'
    Set-Content (Join-Path $shims 'qa.ps1') @'
if (-not (Select-String -Path REPORT.md -Pattern '^## QA' -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content REPORT.md "## QA 2026-10-25 22:00`nverify: PASS (exit 0)`nFindings:`n1. the save button is off by one pixel"
    git add REPORT.md; git commit -qm "QA slice"; git push -q
    'review written'
} else { 'QA RESULT: pass' }
'@
    Set-Content (Join-Path $shims 'claude.cmd') ('@echo %* | findstr /C:"-n Prep" >nul && (powershell -NoProfile -File "' + (Join-Path $shims 'plan.ps1') + '" & exit /b 0)' + "`r`n" +
        '@powershell -NoProfile -File "' + (Join-Path $shims 'build.ps1') + '"') -Encoding Ascii
    Set-Content (Join-Path $shims 'codex.cmd') ('@powershell -NoProfile -File "' + (Join-Path $shims 'qa.ps1') + '"') -Encoding Ascii
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') 'fixture builder prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') 'fixture prep prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\qa-prompt.md') 'fixture qa prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\roles.json') '{"claude":{"builder":"claude:opus","qa":"codex","fallbackQa":"off"}}'
    Set-Content (Join-Path $vault 'Nightly Runs\Project Priorities.md') "## Tonight`n`n### Claude`n- alpha`n`n### Codex`n`n### Hermes`n`n## Backlog"
    $d = Join-Path $projects 'alpha'; New-Item -ItemType Directory -Force (Join-Path $d 'scripts'), (Join-Path $d '.claude'), (Join-Path $d '.hermes\live-build-tree') | Out-Null
    Set-Content (Join-Path $d 'scripts\verify.ps1') 'exit 0'; Set-Content (Join-Path $d 'BUILD_SPEC.md') "# fixture`nUI: none"; Set-Content (Join-Path $d 'REPORT.md') '# Report'
    foreach ($f in 'AGENTS.md', 'CLAUDE.md', 'scripts\verify.sh', 'scripts\stop-gate.ps1', 'scripts\preview.ps1', 'scripts\preview.sh', 'PROGRESS.md', 'FEEDBACK.md', 'DECISIONS.md', '.hermes\live-build-tree\model.json') { Set-Content (Join-Path $d $f) 'x' }
    Set-Content (Join-Path $d '.claude\settings.json') '{"hooks":{"Stop":[]}}'
    git -C $d init -q -b main 2>$null; git -C $d config user.email t@example.com; git -C $d config user.name T
    git -C $d add -A; git -C $d commit -qm init
    git init -q --bare (Join-Path $tmp 'alpha.git'); git -C $d remote add origin (Join-Path $tmp 'alpha.git'); git -C $d push -q -u origin main 2>$null
    $env:OVERNIGHT_VAULT = $vault; $env:OVERNIGHT_PROJECTS = $projects; $env:PATH = "$shims;$env:PATH"
    $ErrorActionPreference = 'Continue'
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'overnight-run.ps1') -Kind morning -HoursPerProject 1 2>&1 | Out-String
    $ErrorActionPreference = 'Stop'
    $report = Get-Content (Join-Path $vault 'Morning Runs\Morning Report.md') -Raw -ErrorAction SilentlyContinue
    $log = @(git -C $d log --reverse --format=%s)
    $fails = @()
    $iQa = [array]::IndexOf($log, 'QA slice'); $iPlan = [array]::IndexOf($log, 'Advance to slice 2'); $iBuild = [array]::IndexOf($log, 'build')
    if (-not ($iBuild -ge 0 -and $iQa -gt $iBuild -and $iPlan -gt $iQa)) { $fails += "slice QA did not run between the build and the next plan (commits: $($log -join ' / '))" }
    if ($report -notmatch 'slice QA on codex at \d\d:\d\d') { $fails += 'no slice QA on the lane' }
    if ($report -notmatch 'QA 1 finding \(on codex\)') { $fails += 'the review without a "QA RESULT:" line was not read from REPORT.md' }
    if ($report -notmatch '\| alpha \| claude:opus \| PASS \|') { $fails += 'the parallel final verify did not report PASS' }
    if ($fails) { Write-Output $out; throw ($fails -join '; ') }
    Write-Output 'SLICE QA OK: QA reviewed the finished slice before the next was planned, a review without its result line was read from REPORT.md, the parallel verify passed'
} finally { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
