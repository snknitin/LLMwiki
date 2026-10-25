# Single-session mode (2026-10-25): a run starts its lanes at once, with no verify sweep and no serial prep. A project whose
# target passed at the commit it is still on (the runner's verify cache) starts with planning on the lane's own model, not
# with a builder session; the builder session after that is told how the previous one ended.
# Fake `claude`: as the planner (-n Prep) it commits a next-slice plan; as the builder it logs its prompt and commits.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-single-session.ps1   (needs no other overnight run going)
$ErrorActionPreference = 'Stop'
$tmp = Join-Path ([IO.Path]::GetTempPath()) "test-single-session-$PID"
$vault = Join-Path $tmp 'vault'; $projects = Join-Path $tmp 'projects'; $shims = Join-Path $tmp 'shims'
New-Item -ItemType Directory -Force (Join-Path $vault 'Nightly Runs\agent-rules'), (Join-Path $vault 'Morning Runs'), $projects, $shims | Out-Null
try {
    # The planner appends a slice to the plan (a real commit); the builder records the prompt it got, then commits.
    Set-Content (Join-Path $shims 'plan.ps1') 'Add-Content alpha\plan.txt "slice"; git -C alpha add plan.txt; git -C alpha commit -qm "Advance to slice 2"; git -C alpha push -q'
    Set-Content (Join-Path $shims 'build.ps1') '$input | Out-File -Append -Encoding utf8 prompts.txt; Set-Content built.txt x; git add built.txt; git commit -qm build; git push -q'
    Set-Content (Join-Path $shims 'claude.cmd') ('@echo %* | findstr /C:"-n Prep" >nul && (powershell -NoProfile -File "' + (Join-Path $shims 'plan.ps1') + '" & exit /b 0)' + "`r`n" +
        '@powershell -NoProfile -File "' + (Join-Path $shims 'build.ps1') + '"') -Encoding Ascii
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') 'fixture builder prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') 'fixture prep prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\roles.json') '{"claude":{"builder":"claude:opus","qa":"off","fallbackQa":"off"}}'
    Set-Content (Join-Path $vault 'Nightly Runs\Project Priorities.md') "## Tonight`n`n### Claude`n- alpha qa=off`n`n### Codex`n`n### Hermes`n`n## Backlog"
    # A structurally complete project (no prep item), UI: none, verify passing.
    $d = Join-Path $projects 'alpha'; New-Item -ItemType Directory -Force (Join-Path $d 'scripts'), (Join-Path $d '.claude'), (Join-Path $d '.hermes\live-build-tree') | Out-Null
    Set-Content (Join-Path $d 'scripts\verify.ps1') 'exit 0'; Set-Content (Join-Path $d 'BUILD_SPEC.md') "# fixture`nUI: none"
    foreach ($f in 'AGENTS.md', 'CLAUDE.md', 'scripts\verify.sh', 'scripts\stop-gate.ps1', 'scripts\preview.ps1', 'scripts\preview.sh', 'PROGRESS.md', 'FEEDBACK.md', 'DECISIONS.md', '.hermes\live-build-tree\model.json') { Set-Content (Join-Path $d $f) 'x' }
    Set-Content (Join-Path $d '.claude\settings.json') '{"hooks":{"Stop":[]}}'
    Set-Content (Join-Path $d '.gitignore') 'prompts.txt'
    git -C $d init -q -b main 2>$null; git -C $d config user.email t@example.com; git -C $d config user.name T
    git -C $d add -A; git -C $d commit -qm init
    git init -q --bare (Join-Path $tmp 'alpha.git'); git -C $d remote add origin (Join-Path $tmp 'alpha.git'); git -C $d push -q -u origin main 2>$null
    # The last run's own verify passed at this commit.
    @{ alpha = @{ head = "$(git -C $d rev-parse HEAD)"; verify = 'PASS'; at = '2026-10-25 06:40' } } | ConvertTo-Json | Set-Content (Join-Path $vault 'Nightly Runs\.verify-cache.json')
    $env:OVERNIGHT_VAULT = $vault; $env:OVERNIGHT_PROJECTS = $projects; $env:PATH = "$shims;$env:PATH"
    $ErrorActionPreference = 'Continue'
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'overnight-run.ps1') -Kind morning -HoursPerProject 1 2>&1 | Out-String
    $ErrorActionPreference = 'Stop'
    $report = Get-Content (Join-Path $vault 'Morning Runs\Morning Report.md') -Raw -ErrorAction SilentlyContinue
    $log = @(git -C $d log --reverse --format=%s)
    $prompts = Get-Content (Join-Path $d 'prompts.txt') -Raw -ErrorAction SilentlyContinue
    $cache = Get-Content (Join-Path $vault 'Nightly Runs\.verify-cache.json') -Raw | ConvertFrom-Json
    $fails = @()
    if ($out -match 'prep: (FAILED|finished)') { $fails += 'the run waited on a serial prep before its lanes' }
    if ($log[1] -ne 'Advance to slice 2') { $fails += "the first step was not the advance (commits: $($log -join ' / '))" }
    if ($report -notmatch 'advanced to its next slices at \d\d:\d\d on claude:opus') { $fails += "the advance did not run on the lane's model: $report" }
    if ($log -notcontains 'build') { $fails += 'no builder session after the advance' }
    if ($prompts -notmatch 'THE PREVIOUS SESSION on this project ended at') { $fails += 'a later builder session was not told how the previous one ended' }
    if ($cache.alpha.head -ne "$(git -C $d rev-parse HEAD)" -or $cache.alpha.verify -ne 'PASS') { $fails += "the verify cache was not updated to the final commit: $($cache.alpha | ConvertTo-Json -Compress)" }
    if ($fails) { Write-Output $out; throw ($fails -join '; ') }
    Write-Output 'SINGLE SESSION OK: no prep wait, cached pass went straight to planning on the lane model, restarts see the last output, cache updated'
} finally { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
