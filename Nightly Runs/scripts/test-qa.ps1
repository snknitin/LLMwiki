# Self-check for overnight-run.ps1's role matrix and QA pass planning.
# 1) Loads only Read-Roles / Get-QaPlan / Format-Qa from the runner and checks them. 2) Runs the runner with -DryRun against a
# throwaway vault and one tiny fixture project per lane (env OVERNIGHT_VAULT / OVERNIGHT_PROJECTS), so nothing real is touched.
# Exit 0 = all checks pass. (Needs no other overnight run going: the runner refuses to start beside one.)
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-qa.ps1
$ErrorActionPreference = 'Stop'
$runner = Join-Path $PSScriptRoot 'overnight-run.ps1'
$ast = [System.Management.Automation.Language.Parser]::ParseFile($runner, [ref]$null, [ref]$null)
$ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -in '$specPattern', '$defaultRoles' }, $true) | ForEach-Object { . ([scriptblock]::Create($_.Extent.Text)) }
$ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -in 'Get-ModelFamily', 'Read-Roles', 'Get-QaPlan', 'Format-Qa' }, $true) | ForEach-Object { . ([scriptblock]::Create($_.Extent.Text)) }
$failed = 0
function Check($what, $got, $want) { if ("$got" -ne "$want") { Write-Output "FAIL $what`: got '$got', want '$want'"; $script:failed++ } else { Write-Output "ok   $what" } }

$tmp = Join-Path ([IO.Path]::GetTempPath()) "test-qa-$PID"
New-Item -ItemType Directory -Force $tmp | Out-Null
try {
    # ---- roles.json ----
    Check 'missing file: default claude QA' (Read-Roles (Join-Path $tmp 'none.json')).claude.qa 'codex'
    $f = Join-Path $tmp 'roles.json'
    Set-Content $f '{"claude":{"builder":"claude:sonnet","qa":"hermes"},"codex":{"builder":"codex","qa":"off"},"hermes":{"builder":"hermes","qa":"claude:sonnet"}}'
    $r = Read-Roles $f
    Check 'file read: claude QA' $r.claude.qa 'hermes'
    Check 'file read: codex QA off' $r.codex.qa 'off'
    Set-Content $f '{"claude":{"builder":"claude:opus","qa":"claude:sonnet"},"codex":{"builder":"codex","qa":"claude"},"hermes":{"builder":"hermes","qa":"codex"}}'
    Check 'same-family QA in the file: defaults' (Read-Roles $f).claude.qa 'codex'
    Set-Content $f '{ not json'
    Check 'broken file: defaults' (Read-Roles $f).codex.qa 'claude:sonnet'

    # ---- per-project plan ----
    $roles = $defaultRoles
    $plan = Get-QaPlan ([pscustomobject]@{ Harness = 'claude'; Qa = $null }) $roles
    Check 'claude lane default: codex' "$($plan.Family)|$($plan.Model)|$($plan.Skip)" 'codex||'
    $plan = Get-QaPlan ([pscustomobject]@{ Harness = 'codex'; Qa = $null }) $roles
    Check 'codex lane default: claude sonnet' "$($plan.Family)|$($plan.Model)" 'claude|sonnet'
    $plan = Get-QaPlan ([pscustomobject]@{ Harness = 'claude'; Qa = 'off' }) $roles
    Check 'qa=off skips' "$($plan.Family)|$($plan.Skip)" '|off (qa=off)'
    $plan = Get-QaPlan ([pscustomobject]@{ Harness = 'claude'; Qa = 'hermes' }) $roles
    Check 'qa=hermes override' $plan.Family 'hermes'
    $plan = Get-QaPlan ([pscustomobject]@{ Harness = 'claude'; Qa = 'claude:opus' }) $roles
    Check 'override in the builder family is refused' ([bool]$plan.Skip) 'True'
    $plan = Get-QaPlan ([pscustomobject]@{ Harness = 'claude'; Qa = 'gpt' }) $roles
    Check 'unknown QA harness is refused' ([bool]$plan.Skip) 'True'
    $plan = Get-QaPlan ([pscustomobject]@{ Harness = 'hermes'; Model = 'glm53-flash'; Qa = 'hermes:qwen3.6-35b-a3b' }) $roles
    Check 'Hermes GLM reviewed by Hermes Qwen' "$($plan.Family)|$($plan.Model)|$($plan.Skip)" 'hermes|qwen3.6-35b-a3b|'
    $plan = Get-QaPlan ([pscustomobject]@{ Harness = 'hermes'; Model = 'qwen3.8-27b-desktop'; Qa = 'hermes:spark-fast' }) $roles
    Check 'actual Qwen builder override cannot be reviewed by Qwen alias' ([bool]$plan.Skip) 'True'
    $plan = Get-QaPlan ([pscustomobject]@{ Harness = 'hermes'; Model = 'glm53-flash'; Qa = $null }) $roles -Fallback
    Check 'fallback is local Qwen, independent of primary subscription' "$($plan.Spec)|$($plan.FallbackUsed)|$($plan.Skip)" 'hermes:qwen3.6-35b-a3b|True|'
    Check 'format: pass' (Format-Qa @{ state = 'pass' }) 'pass'
    Check 'format: findings' (Format-Qa @{ state = 'findings'; findings = 3 }) '3 findings'
    Check 'format: one finding' (Format-Qa @{ state = 'findings'; findings = 1 }) '1 finding'
    Check 'format: skipped' (Format-Qa @{ state = 'skipped'; reason = "codex`nparked" }) 'skipped: codex parked'

    # ---- dry run against a fixture vault ----
    $vault = Join-Path $tmp 'vault'; $projects = Join-Path $tmp 'projects'
    New-Item -ItemType Directory -Force (Join-Path $vault 'Nightly Runs\agent-rules'), $projects | Out-Null
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') 'fixture prompt'
    Set-Content (Join-Path $vault 'Nightly Runs\roles.json') '{"claude":{"builder":"claude:opus","qa":"hermes"},"codex":{"builder":"codex","qa":"claude:sonnet"},"hermes":{"builder":"hermes","qa":"claude:sonnet"}}'
    Set-Content (Join-Path $vault 'Nightly Runs\Project Priorities.md') @'
## Tonight

### Claude
- alpha - lane default
- gamma @claude:sonnet qa=claude:opus - same family override

### Codex
- beta qa=off - switched off

### Hermes

## Backlog
'@
    foreach ($n in 'alpha', 'beta', 'gamma') {
        $d = Join-Path $projects $n; New-Item -ItemType Directory -Force (Join-Path $d 'scripts') | Out-Null
        Set-Content (Join-Path $d 'scripts\verify.ps1') 'exit 1'; Set-Content (Join-Path $d 'BUILD_SPEC.md') '# fixture'
        git -C $d init -q -b main 2>$null; git -C $d config user.email t@example.com; git -C $d config user.name T
        git -C $d add -A; git -C $d commit -qm init
        git init -q --bare (Join-Path $tmp "$n.git"); git -C $d remote add origin (Join-Path $tmp "$n.git"); git -C $d push -q -u origin main 2>$null
    }
    $env:OVERNIGHT_VAULT = $vault; $env:OVERNIGHT_PROJECTS = $projects
    $ErrorActionPreference = 'Continue' # fixture intentionally omits optional project docs; inspect the actual report below
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -DryRun -Kind nightly -NoPrep 2>&1 | Out-String
    $ErrorActionPreference = 'Stop'
    Remove-Item Env:OVERNIGHT_VAULT, Env:OVERNIGHT_PROJECTS
    $report = Get-Content (Join-Path $vault 'Nightly Runs\Overnight Report.md') -Raw
    Check 'dry run wrote a report' ($report -match 'dry run') 'True'
    Check 'dry run: alpha QA on the roles.json harness' ($report -match 'alpha[^\r\n]*QA would run on hermes') 'True'
    Check 'dry run: beta qa=off' ($report -match 'beta[^\r\n]*QA skipped \(off \(qa=off\)\)') 'True'
    Check 'dry run: gamma same-family override' ($report -match "gamma[^\r\n]*QA skipped \(qa=claude:opus is the builder's own model family") 'True'
    if ($failed) { Write-Output $out }
} finally {
    Remove-Item Env:OVERNIGHT_VAULT, Env:OVERNIGHT_PROJECTS -ErrorAction SilentlyContinue
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
if ($failed) { exit 1 }
