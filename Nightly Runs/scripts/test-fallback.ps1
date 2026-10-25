# Self-check for overnight-run.ps1's usage-limit fallback and the limitUntil it saves to .run-state.json.
# Loads only those functions from the runner (nothing runs). Exit 0 = all checks pass.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-fallback.ps1
$ErrorActionPreference = 'Stop'
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'overnight-run.ps1'), [ref]$null, [ref]$null)
$ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -in 'Test-Parked', 'Get-SessionHarness', 'Save-RunState', 'Test-Leftover', 'Get-Backfill', 'Get-AdvanceSpec', 'Test-CachedPass', 'Get-LaneStates' }, $true) |
    ForEach-Object { . ([scriptblock]::Create($_.Extent.Text)) }
$failed = 0
function Check($what, $got, $want) { if ("$got" -ne "$want") { Write-Output "FAIL $what`: got '$got', want '$want'"; $script:failed++ } else { Write-Output "ok   $what" } }

$claude = [pscustomobject]@{ Name = 'alpha'; Harness = 'claude' }
$codex = [pscustomobject]@{ Name = 'gamma'; Harness = 'codex' }
$later = (Get-Date).AddHours(2); $noSpark = @{}

$limitUntil = @{}
Check 'nothing parked: own harness' (Get-SessionHarness $claude) 'claude'
$limitUntil = @{ claude = (Get-Date).AddMinutes(-1) }
Check 'claude limit already reset: claude' (Get-SessionHarness $claude) 'claude'
$limitUntil = @{ claude = $later }
Check 'claude parked: codex' (Get-SessionHarness $claude) 'codex'
$limitUntil = @{ claude = $later; codex = $later }
Check 'claude and codex parked: hermes' (Get-SessionHarness $claude) 'hermes'
Check 'codex project with codex parked: waits' (Get-SessionHarness $codex) ''
$noSpark = @{ alpha = $true }
Check 'not on FirstSpark: waits' (Get-SessionHarness $claude) ''

$stateFile = Join-Path ([IO.Path]::GetTempPath()) "run-state-test-$PID.json"
$Kind = 'nightly'; $started = Get-Date; $deadline = $later; $heads = [ordered]@{ alpha = 'abc' }
Save-RunState
$state = Get-Content $stateFile -Raw | ConvertFrom-Json
Remove-Item $stateFile
Check 'state keeps heads' $state.heads.alpha 'abc'
Check 'state saves limitUntil as a round-trip time' ([datetime]::Parse($state.limitUntil.codex)).ToString('s') $later.ToString('s')

# A session that ended mid-work is restarted, not taken for "target done" (2026-10-24: a Hermes repetition loop and a
# compression timeout each left uncommitted work and the lane was dropped for the night).
Check 'hermes crash with uncommitted work' (Test-Leftover '.' 'hermes' "Repetition Detected`nSPARK_GIT dirty=6 unpushed=0") 'True'
Check 'hermes clean finish' (Test-Leftover '.' 'hermes' 'SPARK_GIT dirty=0 unpushed=0') 'False'
$repo = Join-Path ([IO.Path]::GetTempPath()) "leftover-test-$PID"; git init -q $repo
Check 'desktop clean' (Test-Leftover $repo 'claude' '') 'False'
Set-Content (Join-Path $repo 'a.txt') 'x'
Check 'desktop uncommitted' (Test-Leftover $repo 'claude' '') 'True'
Remove-Item $repo -Recurse -Force

# A built project's lane takes the next overnight-ready project: skips Tonight/Active, missing verify.ps1, dirty checkouts.
$root = Join-Path ([IO.Path]::GetTempPath()) "backfill-test-$PID"; $projects = Join-Path $root 'p'; $prioFile = Join-Path $root 'prio.md'
foreach ($n in 'tonight1', 'active1', 'noverify', 'dirty1', 'good1', 'good2') { $d = Join-Path $projects $n; git init -q $d; if ($n -ne 'noverify') { New-Item -ItemType Directory "$d\scripts" -Force | Out-Null; Set-Content "$d\scripts\verify.ps1" 'x'; git -C $d add -A; git -C $d -c user.email=t@t -c user.name=t commit -qm init } }
Set-Content (Join-Path $projects 'dirty1\new.txt') 'x'
Set-Content $prioFile "## Tonight`n### Codex`n- tonight1`n## Priority order`n1. tonight1`n2. active1`n3. noverify`n4. dirty1`n5. good1`n## Ready next`n- good2`n## Active`n- active1"
$rows = @{ tonight1 = @{} }
Check 'backfill: first ready project' (Get-Backfill 'codex').Name 'good1'
$rows['good1'] = @{}
Check 'backfill: then Ready next' (Get-Backfill 'codex').Name 'good2'
$rows['good2'] = @{}
Check 'backfill: none left' (Get-Backfill 'codex') ''
Remove-Item $root -Recurse -Force

# Planning runs on the lane's own model (2026-10-25: GLM Flash planned every lane), falling back like a session does.
$prepModel = 'hermes:glm53-flash'; $noSpark = @{}
$limitUntil = @{}
Check 'advance spec: claude lane model' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'a'; Harness = 'claude'; Model = 'opus-xhigh' })) 'claude:opus-xhigh'
Check 'advance spec: claude default' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'a'; Harness = 'claude'; Model = $null })) 'claude:opus'
Check 'advance spec: codex profile' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'c'; Harness = 'codex'; Model = 'sol-6-high' })) 'codex:sol-6-high'
Check 'advance spec: hermes lane' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'h'; Harness = 'hermes'; Model = $null })) 'hermes:glm53-flash'
$limitUntil = @{ claude = $later }
Check 'advance spec: claude parked plans on codex' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'a'; Harness = 'claude'; Model = 'opus' })) 'codex'
$limitUntil = @{ claude = $later; codex = $later }
Check 'advance spec: claude and codex parked plan on hermes' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'a'; Harness = 'claude'; Model = 'opus' })) 'hermes:glm53-flash'
Check 'advance spec: codex parked uses the prep model' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'c'; Harness = 'codex'; Model = 'sol-6-high' })) 'hermes:glm53-flash'
$limitUntil = @{}

# A target that passed at this exact commit (clean tree) starts with its advance; anything else builds first.
$repo = Join-Path ([IO.Path]::GetTempPath()) "cache-test-$PID"; git init -q $repo
Set-Content (Join-Path $repo 'a.txt') 'x'; git -C $repo add -A; git -C $repo -c user.email=t@t -c user.name=t commit -qm init
$head = "$(git -C $repo rev-parse HEAD)"
$verifyCache = @{ p = [pscustomobject]@{ head = $head; verify = 'PASS'; at = 'x' } }
Check 'cache: pass at this commit' (Test-CachedPass 'p' $repo) 'True'
Check 'cache: no entry' (Test-CachedPass 'other' $repo) 'False'
$verifyCache = @{ p = [pscustomobject]@{ head = $head; verify = 'SUSPECT (PASS)'; at = 'x' } }
Check 'cache: suspect is not a pass' (Test-CachedPass 'p' $repo) 'False'
$verifyCache = @{ p = [pscustomobject]@{ head = 'abc'; verify = 'PASS'; at = 'x' } }
Check 'cache: another commit' (Test-CachedPass 'p' $repo) 'False'
$verifyCache = @{ p = [pscustomobject]@{ head = $head; verify = 'PASS'; at = 'x' } }
Set-Content (Join-Path $repo 'b.txt') 'y'
Check 'cache: uncommitted changes' (Test-CachedPass 'p' $repo) 'False'
Remove-Item $repo -Recurse -Force

# The board shows each lane's state in the runner's words (2026-10-25: Codex lanes parked on a usage limit read
# "waiting for network" or "done" because the board guessed from log text).
$reset = (Get-Date).Date.AddHours(11).AddMinutes(33)
$limitUntil = @{ codex = $reset }; $waitNet = @{ net1 = $true }; $notBefore = @{}; $recheck = @{}
$running = @{ 1 = @{ Q = [pscustomobject]@{ Name = 'plan1'; Harness = 'claude' }; Advance = $true; Action = 'advance'; Spec = 'claude:opus' }; 2 = @{ Q = [pscustomobject]@{ Name = 'build1'; Harness = 'hermes' } } }
$pending = [System.Collections.ArrayList]@([pscustomobject]@{ Name = 'cx1'; Harness = 'codex' }, [pscustomobject]@{ Name = 'net1'; Harness = 'claude' })
$rows = @{ plan1 = @{}; build1 = @{}; cx1 = @{}; net1 = @{}; done1 = @{ Note = 'not advanced: no buildable node left outside owner-only gates (see Prep Report). its claude lane went to fresh-brief at 03:10. ' } }
$lanes = Get-LaneStates
Check 'lane: planning' "$($lanes.plan1.state): $($lanes.plan1.why)" 'planning: planning its next slices on claude:opus'
Check 'lane: building' $lanes.build1.state 'building'
Check 'lane: waiting on a usage limit' "$($lanes.cx1.state): $($lanes.cx1.why)" 'waiting: codex usage limit, back at 11:33'
Check 'lane: waiting on the network' $lanes.net1.state 'waiting'
Check 'lane: finished and where its lane went' "$($lanes.done1.state): $($lanes.done1.why)" 'finished: nothing left to build outside owner-only steps; its lane went to fresh-brief'
$limitUntil = @{}; $running = @{}; $pending = $null; $rows = @{}

if ($failed) { exit 1 }
