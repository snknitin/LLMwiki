# Self-check for overnight-run.ps1's usage-limit fallback and the limitUntil it saves to .run-state.json.
# Loads only those functions from the runner (nothing runs). Exit 0 = all checks pass.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-fallback.ps1
$ErrorActionPreference = 'Stop'
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'overnight-run.ps1'), [ref]$null, [ref]$null)
$ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -in 'Test-Parked', 'Get-SessionHarness', 'Save-RunState', 'Test-Leftover', 'Get-Backfill', 'Get-AdvanceSpec', 'Test-CachedPass', 'Get-LaneStates', 'Read-Pipeline', 'Move-ProjectLine', 'Get-LaneFor', 'Sync-Pipeline', 'Test-Built', 'Get-RunSet', 'Test-NetError', 'Test-OpenDirection', 'Set-PreviewPorts', 'Test-SharedQwen', 'Test-LimitHit', 'Get-LimitReset', 'Complete-Run', 'Complete-QaJob', 'Set-Qa', 'Format-Qa', 'Get-QaFromReport', 'Get-Upkeep', 'Get-MissingStructure', 'Move-Stalled', 'Test-Progress', 'Write-Decision' }, $true) |
    ForEach-Object { . ([scriptblock]::Create($_.Extent.Text)) }
$failed = 0
function Check($what, $got, $want) { if ("$got" -ne "$want") { Write-Output "FAIL $what`: got '$got', want '$want'"; $script:failed++ } else { Write-Output "ok   $what" } }

# A network error counts only at the end of a session (2026-10-25: a project's own "fetch failed" text restarted it every few minutes).
$netError = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and "$($n.Left)" -eq '$netError' }, $true).Right.Extent.Text.Trim("'")
Check 'net: a project mentioning fetch failed mid-session is not a dropped connection' (Test-NetError ("the calendar fetch failed path is covered`n" + ('x' * 2000) + "`nSlices done.")) 'False'
Check 'net: a dropped connection at the end is' (Test-NetError (('x' * 2000) + "`nError: fetch failed ECONNRESET")) 'True'

$claude = [pscustomobject]@{ Name = 'alpha'; Harness = 'claude' }
$codex = [pscustomobject]@{ Name = 'gamma'; Harness = 'codex' }
$later = (Get-Date).AddHours(2); $noSpark = @{}

$limitUntil = @{}
Check 'nothing parked: own harness' (Get-SessionHarness $claude) 'claude'
$limitUntil = @{ claude = (Get-Date).AddMinutes(-1) }
Check 'claude limit already reset: claude' (Get-SessionHarness $claude) 'claude'
$limitUntil = @{ claude = $later }
Check 'claude parked: hermes, always the fallback (owner, 2026-10-26)' (Get-SessionHarness $claude) 'hermes'
$limitUntil = @{ claude = $later; codex = $later }
Check 'claude and codex parked: hermes' (Get-SessionHarness $claude) 'hermes'
Check 'codex project with codex parked: hermes' (Get-SessionHarness $codex) 'hermes'
$noSpark = @{ gamma = $true }
Check 'codex project with codex parked, not on FirstSpark: waits' (Get-SessionHarness $codex) ''
$noSpark = @{}
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
foreach ($n in 'tonight1', 'active1', 'noverify', 'nospec', 'dirty1', 'good1', 'good2') { $d = Join-Path $projects $n; git init -q $d; if ($n -ne 'nospec') { Set-Content "$d\BUILD_SPEC.md" 'spec' }; if ($n -notin 'noverify', 'nospec') { New-Item -ItemType Directory "$d\scripts" -Force | Out-Null; Set-Content "$d\scripts\verify.ps1" 'x' }; Set-Content "$d\README.md" 'x'; git -C $d add -A; git -C $d -c user.email=t@t -c user.name=t commit -qm init }
Set-Content (Join-Path $projects 'dirty1\new.txt') 'x'
Set-Content $prioFile "## Tonight`n### Codex`n- tonight1`n## Priority order`n1. tonight1`n2. active1`n3. nospec`n4. noverify`n5. dirty1`n6. good1`n## Ready next`n- good2`n## Active`n- active1"
$rows = @{ tonight1 = @{} }
Check 'backfill: the next rank even before it is overnight-ready' (Get-Backfill 'codex').Name 'noverify'
$rows['noverify'] = @{}
Check 'backfill: then the next rank' (Get-Backfill 'codex').Name 'good1'
$rows['good1'] = @{}
Check 'backfill: never an unranked Ready next project' (Get-Backfill 'codex') ''
$rows['good2'] = @{}
Check 'backfill: none left' (Get-Backfill 'codex') ''
# Mid-run the pipeline sync can put the next rank into a lane line; not running tonight, it still takes the free lane.
$rows = @{ tonight1 = @{} }
Set-Content $prioFile "## Tonight`n### Codex`n- tonight1`n- good1`n## Priority order`n1. tonight1`n2. good1`n## Active"
Check 'backfill: a rank the sync put in a lane, not yet running, takes it' (Get-Backfill 'codex').Name 'good1'
$rows['good1'] = @{}
Check 'backfill: one already running tonight does not' (Get-Backfill 'codex') ''
Remove-Item $root -Recurse -Force

# Planning runs on the lane's own model (2026-10-25: GLM Flash planned every lane), falling back like a session does.
$prepModel = 'hermes:glm53-flash'; $noSpark = @{}
$limitUntil = @{}
Check 'advance spec: claude lane model' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'a'; Harness = 'claude'; Model = 'opus-xhigh' })) 'claude:opus-xhigh'
Check 'advance spec: claude default' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'a'; Harness = 'claude'; Model = $null })) 'claude:opus'
Check 'advance spec: codex profile' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'c'; Harness = 'codex'; Model = 'sol-6-high' })) 'codex:sol-6-high'
Check 'advance spec: hermes lane' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'h'; Harness = 'hermes'; Model = $null })) 'hermes:deepseek41-flash-pair'
Check 'advance spec: hermes lane on DeepSeek keeps it' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'h'; Harness = 'hermes'; Model = 'deepseek41-flash-pair' })) 'hermes:deepseek41-flash-pair'
$limitUntil = @{ claude = $later }
Check 'advance spec: claude parked plans on hermes (always the fallback)' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'a'; Harness = 'claude'; Model = 'opus' })) 'hermes:deepseek41-flash-pair'
$limitUntil = @{ claude = $later; codex = $later }
Check 'advance spec: claude and codex parked plan on hermes' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'a'; Harness = 'claude'; Model = 'opus' })) 'hermes:deepseek41-flash-pair'
Check 'advance spec: codex parked plans on hermes, not the prep model' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'c'; Harness = 'codex'; Model = 'sol-6-high' })) 'hermes:deepseek41-flash-pair'
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
$reset = (Get-Date).AddHours(2)
$limitUntil = @{ codex = $reset }; $waitNet = @{ net1 = $true }; $notBefore = @{}; $recheck = @{}; $noSpark = @{ cx1 = $true }
$running = @{ 1 = @{ Q = [pscustomobject]@{ Name = 'plan1'; Harness = 'claude' }; Advance = $true; Action = 'advance'; Spec = 'claude:opus' }; 2 = @{ Q = [pscustomobject]@{ Name = 'build1'; Harness = 'hermes' } } }
$pending = [System.Collections.ArrayList]@([pscustomobject]@{ Name = 'cx1'; Harness = 'codex' }, [pscustomobject]@{ Name = 'net1'; Harness = 'claude' })
$rows = @{ plan1 = @{}; build1 = @{}; cx1 = @{}; net1 = @{}; done1 = @{ Note = 'not advanced: no buildable node left outside owner-only gates (see Prep Report). its claude lane went to fresh-brief at 03:10. ' } }
$lanes = Get-LaneStates
Check 'lane: planning' "$($lanes.plan1.state): $($lanes.plan1.why)" 'planning: planning its next slices on claude:opus'
Check 'lane: building' $lanes.build1.state 'building'
Check 'lane: waiting on a usage limit' "$($lanes.cx1.state): $($lanes.cx1.why)" "waiting: codex usage limit, back at $($reset.ToString('HH:mm'))"
Check 'lane: waiting on the network' $lanes.net1.state 'waiting'
Check 'lane: finished and where its lane went' "$($lanes.done1.state): $($lanes.done1.why)" 'finished: nothing left to build outside owner-only steps; its lane went to fresh-brief'
$limitUntil = @{}; $running = @{}; $pending = $null; $rows = @{}; $noSpark = @{}

# Pipeline (owner, 2026-10-25): top-10 overnight-ready projects fill the lanes, overnight-ready Backlog moves to Ready
# next, a built project moves to Active; the priority order itself never changes.
$root = Join-Path ([IO.Path]::GetTempPath()) "pipeline-test-$PID"; $projects = Join-Path $root 'p'; $prioFile = Join-Path $root 'prio.md'
foreach ($n in 'top1', 'top2', 'blready', 'blunranked') { New-Item -ItemType Directory -Force (Join-Path $projects "$n\scripts") | Out-Null; Set-Content (Join-Path $projects "$n\scripts\verify.ps1") 'x'; Set-Content (Join-Path $projects "$n\BUILD_SPEC.md") 'spec' }
New-Item -ItemType Directory -Force (Join-Path $projects 'topnov') | Out-Null
$fixture = @('# P', '## Tonight', '', '### Claude', '- a1 - x', '', '### Codex', '- c1 @codex:sol - y', '- c2', '', '### Hermes', '',
    '## Priority order (top 10 = daily focus)', '### P0', '1. a1', '2. top1', '3. top2', '4. topnov', '5. act1', '6. f6', '7. f7', '8. f8', '9. f9', '10. f10', '11. f11', '12. blready', '',
    '## Ready next (overnight-ready, not queued)', '', '## Active (built; daytime feedback and iteration)', '- act1 - built', '',
    '## Backlog (BUILD_SPEC written, not set up for overnight yet)', '- top2 @codex - tagged', '- blready - has verify now', '- blunranked - ready but not in the priority order', '- blnot - no verify', '') -join "`r`n"
[IO.File]::WriteAllText($prioFile, $fixture)
$pipelineMoves = New-Object System.Collections.ArrayList
$null = Sync-Pipeline
$st = Read-Pipeline; $after = [IO.File]::ReadAllText($prioFile)
Check 'pipeline: untagged project joins the emptiest lane (Hermes had none)' $st.Where.top1 'hermes'
Check 'pipeline: tagged top-10 joins its own lane' $st.Where.top2 'codex'
Check 'pipeline: not overnight-ready stays out' $st.Where.topnov ''
Check 'pipeline: Active stays Active' $st.Where.act1 'active'
Check 'pipeline: overnight-ready Backlog goes to Ready next' $st.Where.blready 'ready'
Check 'pipeline: unranked Backlog stays (the priority order decides)' $st.Where.blunranked 'backlog'
Check 'pipeline: Backlog without verify stays' $st.Where.blnot 'backlog'
Check 'pipeline: line text and tag kept' ([bool]($after -match "### Codex`r`n- c1 @codex:sol - y`r`n- c2`r`n- top2 @codex - tagged`r`n")) 'True'
Check 'pipeline: order untouched, CRLF kept' ([bool]($after -match "1\. a1`r`n2\. top1`r`n3\. top2`r`n4\. topnov`r`n5\. act1`r`n" -and $after -notmatch "[^`r]`n")) 'True'
Check 'pipeline: moves logged' $pipelineMoves.Count 3
$null = Move-ProjectLine 'c2' 'active'
Check 'pipeline: built project to Active' (Read-Pipeline).Where.c2 'active'
$rep = Join-Path $root 'rep'; New-Item -ItemType Directory -Force $rep | Out-Null
Set-Content (Join-Path $rep 'REPORT.md') "# R`n## Status`nProject built: only G3 and G4 (owner steps) are left"
Check 'built: marker' (Test-Built $rep) 'True'
Set-Content (Join-Path $rep 'REPORT.md') "# R`n## Open questions`n### Q5: Move x to Active?`n- [ ] Yes (recommended)`n- [x] Keep building`n"
Check 'built: owner said keep building' (Test-Built $rep) 'False'
Set-Content (Join-Path $rep 'REPORT.md') "# R`n## Open questions`n### Q5: Move x to Active?`n- [ ] Yes (recommended)`n- [ ] Keep building`n"
Check 'built: open move-to-Active question' (Test-Built $rep) 'True'
Set-Content (Join-Path $rep 'REPORT.md') "# R`nverify passed"
Check 'built: no claim' (Test-Built $rep) 'False'
Remove-Item $root -Recurse -Force

# 10 at a time (owner, 2026-10-25): the lanes hold the first 10 ranks that are not Active; when two of them are Active,
# ranks 11 and 12 come in. Ready next is exactly the next 5 ranks; Backlog the rest. A ranked project below the 10 leaves
# its lane; one the owner put in a lane without ranking it stays. Running it twice changes nothing.
$root = Join-Path ([IO.Path]::GetTempPath()) "top10-test-$PID"; $projects = Join-Path $root 'p'; $prioFile = Join-Path $root 'prio.md'
$names = 1..19 | ForEach-Object { 'r{0:d2}' -f $_ }
foreach ($n in $names) { $d = Join-Path $projects $n; New-Item -ItemType Directory -Force $d | Out-Null; Set-Content "$d\BUILD_SPEC.md" 'spec' }
$order = @(for ($i = 0; $i -lt $names.Count; $i++) { "$($i + 1). $($names[$i])" })
[IO.File]::WriteAllText($prioFile, (@('## Tonight', '', '### Claude', '- r01', '- mine - placed by the owner, not ranked', '', '### Codex', '- r13 - below the 10', '', '### Hermes', '',
    '## Priority order (top 10 = daily focus)', '### P0 · Daily focus') + $order + @('',
    '## Ready next (overnight-ready, not queued)', '- r19 - too far down', '', '## Active (built; daytime feedback and iteration)', '- r02', '- r05', '',
    '## Backlog (BUILD_SPEC written, not set up for overnight yet)', '') -join "`r`n"))
$pipelineMoves = New-Object System.Collections.ArrayList
Check 'top 10: the 10 that run skip Active' ((Get-RunSet (Read-Pipeline)) -join ',') 'r01,r03,r04,r06,r07,r08,r09,r10,r11,r12'
$null = Sync-Pipeline
$st = Read-Pipeline
$inLanes = @($names | Where-Object { $st.Where[$_] -in 'claude', 'codex', 'hermes' })
Check 'top 10: exactly those 10 are in lanes' ($inLanes -join ',') 'r01,r03,r04,r06,r07,r08,r09,r10,r11,r12'
Check 'top 10: a ranked project below the 10 leaves its lane for Ready next' $st.Where.r13 'ready'
Check 'top 10: Ready next is exactly the next 5 ranks' (@($names | Where-Object { $st.Where[$_] -eq 'ready' }) -join ',') 'r13,r14,r15,r16,r17'
Check 'top 10: anything else in Ready next goes back to Backlog' $st.Where.r19 'backlog'
Check 'top 10: an unranked project the owner put in a lane stays' $st.Where.mine 'claude'
$before = [IO.File]::ReadAllText($prioFile); $null = Sync-Pipeline
Check 'top 10: running it again changes nothing' ([IO.File]::ReadAllText($prioFile) -eq $before) 'True'
$null = Move-ProjectLine 'r03' 'active'; $null = Sync-Pipeline; $st = Read-Pipeline
Check 'top 10: one more Active brings in the next rank' ([bool]($st.Where.r13 -in 'claude', 'codex', 'hermes')) 'True'
# Built projects move to Active without asking; one the owner told to keep building stays.
New-Item -ItemType Directory -Force (Join-Path $projects 'r04') | Out-Null; Set-Content (Join-Path $projects 'r04\REPORT.md') "# R`n## Status`nProject built: only G3 is left (owner)"
Set-Content (Join-Path $projects 'r06\REPORT.md') "# R`n## Open questions`n### Q5: Move r06 to Active?`n- [ ] Yes (recommended)`n- [x] Not now, keep building"
$null = Sync-Pipeline; $st = Read-Pipeline
Check 'built: a built project in a lane moves to Active by itself' $st.Where.r04 'active'
Check 'built: one the owner said keep building stays in its lane' ([bool]($st.Where.r06 -in 'claude', 'codex', 'hermes')) 'True'
Check 'built: its spot goes to the next rank' ([bool]($st.Where.r14 -in 'claude', 'codex', 'hermes')) 'True'
Remove-Item $root -Recurse -Force

# Steer on the board: an open owner direction brings a finished project back; an applied one, or an open-looking line
# in another section, does not.
$sd = Join-Path ([IO.Path]::GetTempPath()) "steer-test-$PID"; New-Item -ItemType Directory -Force $sd | Out-Null
$open = "# Decisions`r`n`r`n## Owner direction (from the Agents board)`r`n### 2026-10-25 21:40 $([char]0xB7) Change course $([char]0xB7) open`r`n> Use SQLite`r`n`r`n## Owner answers (from the Agents board)`r`n"
[IO.File]::WriteAllText("$sd\DECISIONS.md", $open)
Check 'steer: an open note counts' (Test-OpenDirection $sd) 'True'
[IO.File]::WriteAllText("$sd\DECISIONS.md", $open.Replace('open', 'applied 2026-10-26: store switched'))
Check 'steer: an applied note does not' (Test-OpenDirection $sd) 'False'
[IO.File]::WriteAllText("$sd\DECISIONS.md", "# Decisions`n## Owner direction (from the Agents board)`n`n## Other`n### 2026 x $([char]0xB7) open`n")
Check 'steer: only inside its own section' (Test-OpenDirection $sd) 'False'
Remove-Item $sd -Recurse -Force

# Preview ports: the runner hands them out; agents never ask. Skips taken (any table) and listening ports, UI: none
# projects and ones that have a row; a preview script anywhere outside Archived also gets one.
$root = Join-Path ([IO.Path]::GetTempPath()) "ports-test-$PID"; $projects = Join-Path $root 'projects'
$prioFile = Join-Path $root 'prio.md'; $portRegistry = Join-Path $root 'registry.md'
foreach ($n in 'a1', 'a2', 'a3', 'b9', 'z0') { New-Item -ItemType Directory -Force (Join-Path $projects "$n\scripts") | Out-Null; Set-Content (Join-Path $projects "$n\BUILD_SPEC.md") 'spec' }
Set-Content (Join-Path $projects 'a3\BUILD_SPEC.md') "spec`nUI: none"
Set-Content (Join-Path $projects 'b9\scripts\preview.ps1') 'x'; Set-Content (Join-Path $projects 'z0\scripts\preview.ps1') 'x'
[IO.File]::WriteAllText($prioFile, "## Tonight`r`n### Claude`r`n- a1`r`n### Codex`r`n- a2`r`n- a3`r`n### Hermes`r`n`r`n## Priority order`r`n1. a1`r`n2. a2`r`n3. a3`r`n`r`n## Ready next`r`n`r`n## Active`r`n`r`n## Backlog`r`n- b9`r`n`r`n## Archived`r`n- z0`r`n")
[IO.File]::WriteAllText($portRegistry, "# R`r`n## Services`r`n| Port | What |`r`n|---|---|`r`n| 8775 | ntfy |`r`n`r`n## Project previews (x)`r`n| Port | Project |`r`n|---|---|`r`n| 8773 | a1 |`r`n`r`n## Free`r`n")
$pipelineMoves = New-Object System.Collections.ArrayList
Set-PreviewPorts @{ 8774 = $true }
$reg = [IO.File]::ReadAllText($portRegistry)
Check 'ports: next free skips taken and listening ones' ([bool]($reg -match '\| 8776 \| a2 \|')) 'True'
Check 'ports: a preview script outside the lanes gets one too' ([bool]($reg -match '\| 8777 \| b9 \|')) 'True'
Check 'ports: UI: none, archived and existing rows get none' ([regex]::Matches($reg, '\| a1 \||\| a3 \||\| z0 \|').Count) '1'
Check 'ports: rows stay inside the previews table' ([bool]($reg -match '\| 8773 \| a1 \|\r\n\| 8776 \| a2 \|\r\n\| 8777 \| b9 \|\r\n\r\n## Free')) 'True'
Set-PreviewPorts @{}
Check 'ports: running again changes nothing' ([IO.File]::ReadAllText($portRegistry) -eq $reg) 'True'
Remove-Item $root -Recurse -Force

# QA on GLM (the plain "hermes" spec) runs during the lanes and in parallel; only the shared FirstSpark Qwen waits.
Check 'qa: GLM is not the shared Qwen' (Test-SharedQwen @{ Spec = 'hermes'; Family = 'hermes' }) 'False'
Check 'qa: the FirstSpark Qwen is' (Test-SharedQwen @{ Spec = 'hermes:qwen3.6-35b-a3b'; Family = 'hermes' }) 'True'
Check 'qa: Codex is not' (Test-SharedQwen @{ Spec = 'codex:sol-5-6'; Family = 'codex' }) 'False'

# Codex's weekly limit, as its log shows it: a garbled apostrophe and a dated reset on the next line.
$limitHit = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and "$($n.Left)" -eq '$limitHit' }, $true).Right.Extent.Text.Trim('"')
$codexLimit = "ERROR: You$([char]0xFFFD)$([char]0xFFFD)$([char]0xFFFD)ve hit your usage limit. Visit https://chatgpt.com/settings/usage to purchase more credits or try again `r`nat Nov 1st, 2026 11:40 AM."
Check 'limit: Codex weekly limit with a garbled apostrophe' (Test-LimitHit $codexLimit) 'True'
Check 'limit: its dated reset' (Get-LimitReset $codexLimit).ToString('yyyy-MM-dd HH:mm') '2026-11-01 11:42'
Check 'limit: Claude session limit still' (Test-LimitHit "You've hit your session limit · resets 2:40am") 'True'
Check 'limit: ordinary text is not one' (Test-LimitHit 'All 58 tests passed.') 'False'

# A session log as the runner writes it: UTF-8 "=== session" headers, each right after the tool's UTF-16 "\r\0\n\0"
# (2026-10-28: the split missed them, so session 11's "resets 5am" was read as session 5's "resets 12am").
$logDir = Join-Path ([IO.Path]::GetTempPath()) "complete-run-test-$PID"; New-Item -ItemType Directory -Force $logDir | Out-Null
$u8 = [Text.Encoding]::UTF8; $u16 = [Text.Encoding]::Unicode
[IO.File]::WriteAllBytes((Join-Path $logDir 'beta.log'), [byte[]]($u8.GetBytes("=== session 5 23:40 ===`r`n") + $u16.GetBytes("You've hit your session limit - resets 12am (Asia/Kolkata)`r`n") + $u8.GetBytes("=== session 11 04:04 ===`r`n") + $u16.GetBytes("work`r`nYou've hit your session limit - resets 5am (Asia/Kolkata)`r`n")))
$limitUntil = @{}; $projects = $logDir; $stateFile = Join-Path $logDir 'state.json'; $runPhase = 'wrapup'; $qaResults = @{}
$sessionText = Complete-Run ([pscustomobject]@{ Name = 'beta'; Harness = 'claude' }) @{ Note = '' }
Remove-Item -Recurse -Force $logDir
Check 'session log: only the last session is read' ($sessionText -match '12am') 'False'
Check 'session log: its own reset time parks claude' $limitUntil.claude (Get-LimitReset 'resets 5am')

# A QA that hit Hermes's --run-budget counts as timed out, and the next QA starts after its range (owner, 2026-10-28).
$projects = Join-Path ([IO.Path]::GetTempPath()) "qa-range-test-$PID"; $d = Join-Path $projects 'gamma'; New-Item -ItemType Directory -Force $d | Out-Null
$ErrorActionPreference = 'Continue'
git -C $d init -q; git -C $d -c user.email=t@t -c user.name=t commit -q --allow-empty -m c0; $c0 = "$(git -C $d rev-parse HEAD)"
git -C $d -c user.email=t@t -c user.name=t commit -q --allow-empty -m c1; $c1 = "$(git -C $d rev-parse HEAD)"
Set-Content (Join-Path $projects 'gamma.qa-fallback.txt') "=== QA 06:38 of $c0..$c1 on hermes:qwen3.6-35b-a3b ===`nLOCAL AGENT FAILED: Command '['hermes', '--run-budget',`n'1800']' timed out after 1859.99 seconds`nSPARK_GIT dirty=2 unpushed=0"
$rows = @{ gamma = @{ Note = '' } }; $qaFrom = @{}; $qaAllowed = @('REPORT.md'); $QaMinutes = 30; $DryRun = $true
$r = @{ Q = @{ Name = 'gamma' }; Plan = @{ Family = 'hermes'; Spec = 'hermes:qwen3.6-35b-a3b'; FallbackUsed = $true }; Log = (Join-Path $projects 'gamma.qa-fallback.txt'); Head = $c1; From = $c0; Dirty = @() }
$null = Complete-QaJob $r $false
$ErrorActionPreference = 'Stop'
Remove-Item -Recurse -Force $projects
Check 'qa: Hermes run-budget stop is a timeout' $qaResults.gamma.reason 'timed out after 30 min'
Check 'qa: the next QA starts after the timed-out range' $qaFrom.gamma $c1

# Prep covers Ready next like the top 10, so a project that fills a lane mid-run has its tree and gates before the run.
$projects = Join-Path ([IO.Path]::GetTempPath()) "upkeep-test-$PID"; $prioFile = Join-Path $projects 'prio.md'
$ranks = @(1..10 | ForEach-Object { "p$_" }) + 'r1', 'r2'
New-Item -ItemType Directory -Force (Join-Path $projects 'r1\scripts') | Out-Null
Set-Content (Join-Path $projects 'r1\BUILD_SPEC.md') "# r1`nUI: none"; Set-Content (Join-Path $projects 'r1\scripts\verify.ps1') 'exit 0'
Set-Content $prioFile ("## Priority order`n" + (($ranks | ForEach-Object { "$($ranks.IndexOf($_) + 1). $_" }) -join "`n") + "`n## Ready next`n- r1`n- r2`n## Backlog`n")
$ErrorActionPreference = 'Continue'; $upkeep = @(Get-Upkeep @()); $ErrorActionPreference = 'Stop'
Remove-Item -Recurse -Force $projects
Check 'prep: a Ready next project without a tree gets one' (@($upkeep | Where-Object { $_.Project -eq 'r1' }).Action -match 'build-tree') 'True'
Check 'prep: a Ready next project without a spec is left alone' @($upkeep | Where-Object { $_.Project -eq 'r2' }).Count 0

# A lane project with no real commit all night goes to Active and the next rank takes its lane (owner, 2026-10-28).
$projects = Join-Path ([IO.Path]::GetTempPath()) "stalled-test-$PID"; $prioFile = Join-Path $projects 'prio.md'; $logDir = $projects
$ErrorActionPreference = 'Continue'; $heads = @{}
foreach ($n in 'idle', 'busy', 'next1') {
    $d = Join-Path $projects $n; New-Item -ItemType Directory -Force $d | Out-Null; Set-Content (Join-Path $d 'BUILD_SPEC.md') '# spec'
    git -C $d init -q; git -C $d add -A; git -C $d -c user.email=t@t -c user.name=t commit -qm init; $heads[$n] = "$(git -C $d rev-parse HEAD)"
}
Set-Content (Join-Path $projects 'idle\REPORT.md') 'diagnosis only'; git -C (Join-Path $projects 'idle') add -A; git -C (Join-Path $projects 'idle') -c user.email=t@t -c user.name=t commit -qm report
Set-Content (Join-Path $projects 'busy\app.py') 'x = 1'; git -C (Join-Path $projects 'busy') add -A; git -C (Join-Path $projects 'busy') -c user.email=t@t -c user.name=t commit -qm feature
Set-Content $prioFile "## Priority order`n1. idle`n2. busy`n3. next1`n`n## Tonight`n`n### Claude`n`n### Codex`n- idle`n- busy`n`n### Hermes`n`n## Ready next`n- next1`n`n## Active`n`n## Backlog`n"
$rows = @{ idle = @{ Note = '' }; busy = @{ Note = '' } }; $pipelineMoves = New-Object System.Collections.ArrayList
Move-Stalled 'idle' $rows.idle; Move-Stalled 'busy' $rows.busy
$st = Read-Pipeline; $fill = Get-Backfill 'codex'
$ErrorActionPreference = 'Stop'
Remove-Item -Recurse -Force $projects
Check 'stalled: a lane project with only bookkeeping commits goes to Active' $st.Where.idle 'active'
Check 'stalled: one with real work keeps its lane' $st.Where.busy 'codex'
Check 'stalled: the next rank takes the freed lane' $fill.Name 'next1'

# A Hermes model can carry the board's effort ("<model>-<effort>"); the planner keeps it (owner, 2026-10-28).
$limitUntil = @{}; $noSpark = @{}
Check 'effort: a Hermes lane model keeps its effort for planning' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'h'; Harness = 'hermes'; Model = 'deepseek41-flash-pair-xhigh' })) 'hermes:deepseek41-flash-pair-xhigh'
Check 'effort: no effort, the config default' (Get-AdvanceSpec ([pscustomobject]@{ Name = 'h'; Harness = 'hermes'; Model = $null })) 'hermes:deepseek41-flash-pair'

if ($failed) { exit 1 }
