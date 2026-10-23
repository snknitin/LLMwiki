# End-to-end check of overnight-run.ps1's QA pass with fake `claude` and `codex` commands (nothing real is called).
# A throwaway vault and five tiny fixture repos run through a real (not dry) morning run: the fake claude is the builder,
# the fake codex is QA. Checks the QA results in the report and the repos, the QA prompt footer, and that a QA session that
# edits source is marked failed. Takes about a minute. Needs no other overnight run going. Exit 0 = all checks pass.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-qa-run.ps1
$ErrorActionPreference = 'Stop'
$runner = Join-Path $PSScriptRoot 'overnight-run.ps1'
$failed = 0
function Check($what, $got, $want) { if ("$got" -ne "$want") { Write-Output "FAIL $what`: got '$got', want '$want'"; $script:failed++ } else { Write-Output "ok   $what" } }
$tmp = Join-Path ([IO.Path]::GetTempPath()) "test-qa-run-$PID"
$vault = Join-Path $tmp 'vault'; $projects = Join-Path $tmp 'projects'; $shims = Join-Path $tmp 'shims'
New-Item -ItemType Directory -Force (Join-Path $vault 'Nightly Runs\agent-rules'), (Join-Path $vault 'Morning Runs'), $projects, $shims | Out-Null
try {
    # One script plays both tools. A prompt containing "QA reviewer" is a QA session; anything else is a builder.
    Set-Content (Join-Path $shims 'shim.ps1') @'
$tool = $args[0]
$text = [Console]::In.ReadToEnd()
$name = Split-Path -Leaf (Get-Location)
if ($text -match 'QA reviewer') {
    Set-Content (Join-Path $PSScriptRoot "$name.qa-prompt.txt") $text
    if ($name -eq 'epsilon') { Add-Content src.txt 'QA touched source'; git add src.txt; git commit -qm 'QA edits source'; git push -q }
    else {
        Add-Content REPORT.md "`n## QA 2026-01-01`nfinding list"; Add-Content FEEDBACK.md '- fix the thing'
        git add REPORT.md FEEDBACK.md; git commit -qm 'QA: report'; git push -q
    }
    if ($name -eq 'delta') { 'QA RESULT: pass' } else { 'QA RESULT: findings=2' }
} elseif ($name -ne 'beta' -and -not (Test-Path built.txt)) {
    Set-Content src.txt 'built'; Set-Content built.txt 'x'; git add src.txt built.txt; git commit -qm 'build the thing'; git push -q
    'built'
} else { 'nothing to do' }
'@
    foreach ($t in 'claude', 'codex') { Set-Content (Join-Path $shims "$t.cmd") "@powershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0shim.ps1`" $t"-Encoding Ascii }
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') 'fixture builder prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') 'fixture prep prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\roles.json') '{"claude":{"builder":"claude:opus","qa":"codex","fallbackQa":"off"},"codex":{"builder":"codex","qa":"claude:sonnet","fallbackQa":"off"},"hermes":{"builder":"hermes","qa":"claude:sonnet","fallbackQa":"off"}}'
    Copy-Item (Join-Path $PSScriptRoot '..\agent-rules\qa-prompt.md') (Join-Path $vault 'Nightly Runs\agent-rules\qa-prompt.md')
    Set-Content (Join-Path $vault 'Nightly Runs\Project Priorities.md') @'
## Tonight

### Claude
- alpha - findings
- beta - builder makes no commit
- gamma qa=off - QA off
- delta - passes
- epsilon - QA edits source

### Codex

### Hermes

## Backlog
'@
    foreach ($n in 'alpha', 'beta', 'gamma', 'delta', 'epsilon') {
        $d = Join-Path $projects $n; New-Item -ItemType Directory -Force (Join-Path $d 'scripts') | Out-Null
        Set-Content (Join-Path $d 'scripts\verify.ps1') 'exit 0'; Set-Content (Join-Path $d 'BUILD_SPEC.md') '# fixture'
        git -C $d init -q -b main 2>$null; git -C $d config user.email t@example.com; git -C $d config user.name T
        git -C $d add -A; git -C $d commit -qm init
        git init -q --bare (Join-Path $tmp "$n.git"); git -C $d remote add origin (Join-Path $tmp "$n.git"); git -C $d push -q -u origin main 2>$null
    }
    $env:OVERNIGHT_VAULT = $vault; $env:OVERNIGHT_PROJECTS = $projects; $env:PATH = "$shims;$env:PATH"
    $ErrorActionPreference = 'Continue' # fixture omits optional docs; assertions below check the actual run results
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Kind morning -NoPrep -HoursPerProject 1 -QaMinutes 5 2>&1 | Out-String
    $ErrorActionPreference = 'Stop'
    $report = Get-Content (Join-Path $vault 'Morning Runs\Morning Report.md') -Raw
    if ($env:QA_TEST_VERBOSE) { Write-Output $out; Write-Output $report; Get-ChildItem $projects -Recurse -Filter '*.qa.txt' | ForEach-Object { Write-Output "--- $($_.Name)"; Get-Content $_.FullName } }
    Check 'alpha: findings' ($report -match '(?m)^- `alpha`: QA 2 findings\r?$') 'True'
    Check 'delta: pass' ($report -match '(?m)^- `delta`: QA pass\r?$') 'True'
    Check 'beta: no real commit' ($report -match '(?m)^- `beta`: QA skipped: no real commit tonight\r?$') 'True'
    Check 'gamma: qa=off' ($report -match '(?m)^- `gamma`: QA skipped: off \(qa=off\)\r?$') 'True'
    Check 'epsilon: QA touched source' ($report -match '(?m)^- `epsilon`: QA failed: QA changed files it may not: src\.txt') 'True'
    Check 'alpha REPORT.md has the QA section' ((Get-Content (Join-Path $projects 'alpha\REPORT.md') -Raw) -match '## QA 2026-01-01') 'True'
    Check 'alpha FEEDBACK.md has the item' ((Get-Content (Join-Path $projects 'alpha\FEEDBACK.md') -Raw) -match 'fix the thing') 'True'
    $prompt = Get-Content (Join-Path $shims 'alpha.qa-prompt.txt') -Raw
    Check 'QA prompt names the project and the commit range' ($prompt -match 'This QA session: project folder alpha, date for the REPORT\.md section \d{4}-\d{2}-\d{2}, the builder''s commits tonight are [0-9a-f]{40}\.\.[0-9a-f]{40}') 'True'
    Check 'no QA session for beta' (Test-Path (Join-Path $shims 'beta.qa-prompt.txt')) 'False'
    Check 'no QA session for gamma' (Test-Path (Join-Path $shims 'gamma.qa-prompt.txt')) 'False'
    if ($failed) { Write-Output $out }
} finally {
    Remove-Item Env:OVERNIGHT_VAULT, Env:OVERNIGHT_PROJECTS -ErrorAction SilentlyContinue
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
if ($failed) { exit 1 }
