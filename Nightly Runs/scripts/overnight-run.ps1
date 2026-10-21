# Overnight runner: works the "## Tonight" list in Nightly Runs/Project Priorities.md, up to -PerHarness projects per harness at once
# (default 3 Claude + 3 Codex + 3 Hermes = 9 in parallel).
# @claude and @codex run here on the desktop; @hermes runs on FirstSpark over SSH. After each agent finishes,
# the runner re-runs that project's scripts/verify.ps1 itself and writes a report plus a dated copy per real run (never overwritten):
#   nightly: Nightly Runs/Overnight Report.md, Nightly Runs/Logs/<yyyy-MM-dd_HHmm>.md, agent logs in E:/GIT_ROOT/Projects/.overnight-logs
#   morning: Morning Runs/Morning Report.md,   Morning Runs/Logs/<yyyy-MM-dd_HHmm>.md, agent logs in E:/GIT_ROOT/Projects/.morning-logs
# Every run starts with a preflight: projects with blockers are skipped, and Nightly Runs/Preflight.md lists what needs you.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File overnight-run.ps1 [-Kind nightly|morning] [-Preflight | -DryRun] [-PerHarness 3] [-Until 06:30] [-HoursPerProject 3]
#   -Kind       where results go (above); the scheduled task passes nightly. Default: morning if started 05:00-16:59, else nightly
#   -Until      a nightly run keeps its lanes working until this time (default 06:30): an agent that stops early with real
#               progress is started again on its project. A morning run, or any run given -HoursPerProject, works that many hours.
#   -Preflight  only check (run it in the evening, fix what it lists, then let 23:00 run); exit code = number of blocked projects
#   -NoPrep     skip the top-10 upkeep prep agent (see Get-Upkeep); -PrepMinutes caps it (default 90)
#   -PrepOnly   run only the prep agent (make-overnight-ready, build-tree, structure, queue, advance), then refresh Preflight.md
#               and exit. The Agents board runs it when a project enters the top 10 or a Tonight lane, so it's ready before 23:00.
#   -Resume     continue a run that was cut off (power cut, crash, reboot) until its original end time; exits at once when
#               there is none. The "Agents Run resume" task runs it at logon and every 15 minutes.
# Survives the night: the PC is kept awake while a run is going, and a session that ended on a network error waits for the
# network (or FirstSpark) to come back, then starts again. A tool at its usage limit waits for the reset time it prints.
# A project that finishes tonight's target mid-run is advanced to its next slices (advance-slice) and keeps going.
param([ValidateSet('nightly', 'morning')][string]$Kind, [switch]$Preflight, [switch]$DryRun, [int]$PerHarness = 3, [double]$HoursPerProject = 3, [string]$Until = '06:30', [switch]$NoPrep, [int]$PrepMinutes = 90, [switch]$PrepOnly, [switch]$Resume)
$ErrorActionPreference = 'Continue'
$hoursGiven = $PSBoundParameters.ContainsKey('HoursPerProject')   # explicit hours win over a nightly run's -Until
# One run at a time, however it was started (board button, scheduled "Agents Run HHMM" task, by hand): a second one exits.
# A real run that finds only a -PrepOnly going waits for it (prep is short), so a late prep never costs the night.
function Get-OtherRuns { @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe' OR Name='pwsh.exe'" | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -like '*-File*overnight-run.ps1*' -and $_.CommandLine -notlike '*-Preflight*' }) }
$others = Get-OtherRuns
# A -Resume check with nothing to continue exits within seconds: wait that out, so a 23:00 start never loses to it.
if (-not $Preflight -and $others -and -not @($others | Where-Object { $_.CommandLine -notlike '*-Resume*' })) {
    $until = (Get-Date).AddSeconds(60)
    while (@(Get-OtherRuns | Where-Object { $_.CommandLine -like '*-Resume*' }) -and (Get-Date) -lt $until) { Start-Sleep -Seconds 5 }
    $others = Get-OtherRuns
}
if (-not $Preflight -and -not $PrepOnly -and $others -and -not @($others | Where-Object { $_.CommandLine -notlike '*-PrepOnly*' })) {
    $until = (Get-Date).AddMinutes($PrepMinutes + 5)
    while ((Get-OtherRuns) -and (Get-Date) -lt $until) { Start-Sleep -Seconds 30 }
    $others = Get-OtherRuns
}
if (-not $Preflight -and $others) { Write-Output "Another run is going (pid $($others.ProcessId -join ', ')); not starting a second one."; exit 0 }
$vault         = 'F:\Vaults\LLMWiki'
$projects      = 'E:\GIT_ROOT\Projects'
$sparkProjects = '/home/snknitin/Workspace/GIT_ROOT/Projects'
$ssh           = "$env:WINDIR\System32\OpenSSH\ssh.exe"
$prioFile      = Join-Path $vault 'Nightly Runs\Project Priorities.md'
$preflightMd   = Join-Path $vault 'Nightly Runs\Preflight.md'
$prompt        = Get-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') -Raw -Encoding UTF8
# Written when the lanes start, deleted when the run finishes: if it is still here and no run is going, the run was cut off.
$stateFile     = Join-Path $vault 'Nightly Runs\.run-state.json'
$resumeEnd     = $null
if ($Resume) {
    $state = $null
    try { $state = Get-Content $stateFile -Raw -ErrorAction Stop | ConvertFrom-Json } catch { exit 0 }   # nothing was cut off
    $resumeEnd = [datetime]::Parse($state.until)
    if ((Get-Date).AddMinutes(30) -ge $resumeEnd) { Remove-Item $stateFile -ErrorAction SilentlyContinue; Write-Output "resume: the cut-off run's end time ($($resumeEnd.ToString('HH:mm'))) has passed"; exit 0 }
    $Kind = $state.kind
    Write-Output "resume: continuing the $Kind run cut off after $($state.started), until $($resumeEnd.ToString('HH:mm'))"
}
if (-not $Preflight) {
    # Keep the PC awake (not the screen) while this process lives; Windows drops the request when it exits.
    try { Add-Type -Namespace Win32 -Name Power -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint esFlags);'; [void][Win32.Power]::SetThreadExecutionState(0x80000001) } catch {}
}
$started       = Get-Date
if (-not $Kind) { $Kind = $(if ($started.Hour -ge 5 -and $started.Hour -lt 17) { 'morning' } else { 'nightly' }) }
$runsDir       = Join-Path $vault $(if ($Kind -eq 'morning') { 'Morning Runs' } else { 'Nightly Runs' })
$reportMd      = Join-Path $runsDir $(if ($Kind -eq 'morning') { 'Morning Report.md' } else { 'Overnight Report.md' })
$runLogDir     = Join-Path $runsDir 'Logs'   # dated copy of each real run's report, kept for history
$stamp         = $started.ToString('yyyy-MM-dd_HHmm')   # names this run's dated report and agent-log folder
$logDir        = Join-Path $projects ($(if ($Kind -eq 'morning') { '.morning-logs\' } else { '.overnight-logs\' }) + $stamp)
New-Item -ItemType Directory -Force $logDir | Out-Null

# Parse "- <folder> [@<harness>[:<model>]] - note" lines under "## Tonight". The "### Claude/Codex/Hermes" lane a line
# sits in picks its harness; an explicit @tag overrides the lane. First occurrence of a folder wins.
function Read-Queue {
    $q = @(); $seen = @{}; $inTonight = $false; $lane = 'claude'
    foreach ($line in Get-Content $prioFile -Encoding UTF8) {
        if ($line -match '^##\s') { $inTonight = $line -match '^##\s+Tonight'; $lane = 'claude'; continue }
        if ($inTonight -and $line -match '^###\s+(\w+)') { $lane = $Matches[1].ToLower(); continue }
        if ($inTonight -and $line -match '^\s*-\s+([A-Za-z0-9._-]+)(?:\s+@(\w+)(?::([\w./-]+))?)?' -and -not $seen[$Matches[1]]) {
            $seen[$Matches[1]] = $true
            $q += [pscustomobject]@{ Name = $Matches[1]; Harness = $(if ($Matches[2]) { $Matches[2].ToLower() } else { $lane }); Model = $Matches[3] }
        }
    }
    return $q
}
$queue = Read-Queue

# ---- Top-10 upkeep: the projects agents work on follow the priority order ----
# The top 10 of "## Priority order" (skipping Active and Archived) must each be overnight-ready, have a live build tree and
# sit in a Tonight lane (or Ready next when its lane is full). When a project moves to Active or Archived, the next one in
# the order takes its place. A tonight project whose verify already passes must advance a slice first, or its run would
# stop at once. Preflight lists this work; a real run hands it to one Claude prep agent (agent-rules/prep-prompt.md)
# before the lanes start, then re-reads the lanes.
# The standard overnight repo structure (the make-overnight-ready skill's checklist). A project that already has verify.ps1
# but lacks any of this gets a "structure" item, so the prep agent fills in only what is missing.
function Get-MissingStructure($dir) {
    $m = @()
    foreach ($f in 'AGENTS.md', 'CLAUDE.md', 'scripts\verify.sh', 'scripts\stop-gate.ps1', 'PROGRESS.md', 'FEEDBACK.md', 'DECISIONS.md') {
        if (-not (Test-Path (Join-Path $dir $f))) { $m += ($f -replace '\\', '/') }
    }
    $settings = Join-Path $dir '.claude\settings.json'
    if (-not ((Test-Path $settings) -and (Select-String -Path $settings -Pattern '"Stop"' -Quiet))) { $m += 'Stop hook in .claude/settings.json' }
    # A project with a UI already in the repo also needs DESIGN.md and screenshots in verify. Projects whose UI isn't
    # built yet get these from the skill once their first page exists, so this check stays quiet until then.
    $tracked = @(git -C $dir ls-files 2>$null)
    $hasUi = [bool]($tracked | Where-Object { $_ -match '\.(html|jinja2?|svelte|vue|[jt]sx)$' -and $_ -notmatch '(^|/)(\.hermes|docs|node_modules)/' } | Select-Object -First 1)
    if ($hasUi) {
        if (-not (Test-Path (Join-Path $dir 'DESIGN.md'))) { $m += 'DESIGN.md' }
        if (-not (Select-String -Path (Join-Path $dir 'scripts\verify.ps1') -Pattern 'screenshot|playwright' -Quiet)) { $m += 'screenshots in verify' }
    }
    return $m
}
function Get-Upkeep($queue, [switch]$CheckVerify) {
    $order = @(); $section = ''; $parked = @{}
    foreach ($line in Get-Content $prioFile -Encoding UTF8) {
        if ($line -match '^##\s+(.*)$') { $section = $Matches[1]; continue }
        if ($section -match '^Priority order' -and $line -match '^\s*\d+\.\s+([A-Za-z0-9._-]+)') { $order += $Matches[1] }
        if ($section -match '^(Active|Archived)' -and $line -match '^\s*-\s+([A-Za-z0-9._-]+)') { $parked[$Matches[1]] = $true }
    }
    $queued = @{}; foreach ($q in $queue) { $queued[$q.Name] = $q.Harness }
    $top = @($order | Where-Object { -not $parked[$_] } | Select-Object -Unique -First 10)
    $inTop = @{}; foreach ($t in $top) { $inTop[$t] = $true }
    $items = @(); $waiting = 0
    foreach ($name in $top) {
        $dir = Join-Path $projects $name
        if (-not (Test-Path "$dir\BUILD_SPEC.md")) { $items += [pscustomobject]@{ Project = $name; Action = 'owner'; Why = 'no BUILD_SPEC.md yet, so it cannot be made overnight-ready' }; continue }
        $todo = @(); $why = @()
        if (-not (Test-Path "$dir\scripts\verify.ps1")) { $todo += 'make-overnight-ready'; $why += 'no scripts/verify.ps1' }
        else {
            if (-not (Test-Path "$dir\.hermes\live-build-tree\model.json")) { $todo += 'build-tree'; $why += 'no live build tree' }
            $missing = @(Get-MissingStructure $dir)
            if ($missing) { $todo += 'structure'; $why += 'missing: ' + ($missing -join ', ') }
        }
        if (-not $queued[$name]) { $todo += 'queue'; $why += 'in the top 10 but not in a Tonight lane'; $waiting++ }
        if ($todo) { $items += [pscustomobject]@{ Project = $name; Action = $todo -join ' + '; Why = $why -join '; ' } }
    }
    if ($waiting) {
        $drop = @($queue | Where-Object { -not $inTop[$_.Name] } | ForEach-Object { [pscustomobject]@{ Project = $_.Name; Action = 'dequeue'; Why = "in the $($_.Harness) lane but no longer in the top 10" } })
        if ($drop -or $queue.Count -lt 3 * $PerHarness) { $items += $drop }
        else {   # every lane is full of top-10 work: a waiting project stays in Ready next, nothing to prep for it
            $items = @($items | ForEach-Object { $_.Action = ($_.Action -split ' \+ ' | Where-Object { $_ -ne 'queue' }) -join ' + '; $_.Why = ($_.Why -split '; ' | Where-Object { $_ -notmatch 'not in a Tonight lane' }) -join '; '; $_ } | Where-Object { $_.Action })
        }
    }
    if ($CheckVerify) {
        foreach ($q in $queue) {
            $v = Join-Path $projects "$($q.Name)\scripts\verify.ps1"
            if (-not (Test-Path $v)) { continue }
            & powershell -NoProfile -ExecutionPolicy Bypass -File $v *> $null
            if ($LASTEXITCODE -eq 0) { $items += [pscustomobject]@{ Project = $q.Name; Action = 'advance'; Why = 'verify already passes, so tonight needs its next slices' } }
        }
    }
    return $items
}
$upkeep = @(Get-Upkeep $queue -CheckVerify:(-not $Preflight))
$prepWork = @($upkeep | Where-Object { $_.Action -ne 'owner' })
if ($prepWork -and -not $Preflight -and -not $DryRun -and -not $NoPrep) {
    $prepLog = Join-Path $logDir '_prep.log'
    $prepPrompt = (Get-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') -Raw -Encoding UTF8) + "`n" +
        (($prepWork | ForEach-Object { "- $($_.Project): $($_.Action) ($($_.Why))" }) -join "`n") + "`n"
    $prepJob = Start-Job -ScriptBlock {
        param($dir, $text, $log)
        $OutputEncoding = New-Object System.Text.UTF8Encoding $false
        Set-Location $dir   # the Projects root, so no project's .claude deny rules apply to the prep agent
        $text | & claude -p --model opus --permission-mode bypassPermissions *> $log
    } -ArgumentList $projects, $prepPrompt, $prepLog
    if (-not (Wait-Job $prepJob -Timeout ($PrepMinutes * 60))) { Stop-Job $prepJob; Write-Output "prep: stopped after $PrepMinutes min (log: $prepLog)" }
    Remove-Job $prepJob -Force
    Write-Output "prep: done for $($prepWork.Count) item(s), log: $prepLog"
    $queue = Read-Queue   # the prep agent may have moved projects into lanes
    $upkeep = @(Get-Upkeep $queue)   # so Preflight.md shows what is still left after prep
}

# ---- Preflight: find everything that needs the owner before an unattended night ----
# Blockers keep a project from running tonight; "needs input" items let it run on its recommended defaults.
function Get-OpenItems($file) {
    # Unanswered questions under any heading that mentions open questions/decisions (same rules as the Agents board):
    #   "### Q1: ..." blocks with "- [ ]" options (answered once any option is "- [x]"), or plain bullets
    #   (answered once they contain "- answered" or an em-dash "answered"), skipping "none" placeholders.
    #   "(multi)" and "(text)" after Q<n> only change how the board asks; any "- [x]" line means answered.
    if (-not (Test-Path $file)) { return @() }
    $answeredMark = '(?i)(' + [char]0x2014 + '|-{1,2})\s*answered\b'   # built from a char code: this file must stay ASCII for PowerShell 5.1
    $items = @(); $openLevel = 0; $q = $null; $qAnswered = $false
    foreach ($l in Get-Content $file -Encoding UTF8) {
        if ($l -match '^(#{1,6})\s+(.*)$') {
            $level = $Matches[1].Length; $title = $Matches[2].Trim()
            if ($q -and -not $qAnswered) { $items += $q }; $q = $null
            if ($openLevel -and $level -gt $openLevel) { $q = $title; $qAnswered = $false; continue }   # a Q block inside the section
            $openLevel = $(if ($title -match '(?i)open (questions?|decisions?)') { $level } else { 0 })
            continue
        }
        if (-not $openLevel) { continue }
        if ($l -match '^\s*[-*]\s+\[([ xX])\]') { if ($q -and $Matches[1] -ne ' ') { $qAnswered = $true }; continue }   # an option line
        if (-not $q -and $l -match '^\s*[-*]\s+(\S.*)$' -and $Matches[1] -notmatch '^(?i)\(?none' -and $Matches[1] -notmatch $answeredMark) {
            $items += $Matches[1].Trim()
        }
    }
    if ($q -and -not $qAnswered) { $items += $q }
    return $items
}
$sparkState = @{}
$hermesNames = @($queue | Where-Object { $_.Harness -eq 'hermes' } | ForEach-Object { $_.Name })
if ($hermesNames) {
    $check = ($hermesNames | ForEach-Object { "p=$sparkProjects/$_; if [ -d `$p/.git ]; then echo $_ ok `$(git -C `$p status --porcelain | wc -l); else echo $_ missing; fi" }) -join '; '
    $out = @(& $ssh -o BatchMode=yes -o ConnectTimeout=10 FirstSpark $check 2>$null)
    if (-not $out) { $hermesNames | ForEach-Object { $sparkState[$_] = 'unreachable' } }
    foreach ($l in $out) { $f = -split $l; $sparkState[$f[0]] = $(if ($f[1] -eq 'ok') { "dirty=$($f[2])" } else { 'missing' }) }
}
$cliOk = @{ claude = [bool](Get-Command claude -ErrorAction SilentlyContinue); codex = [bool](Get-Command codex -ErrorAction SilentlyContinue); hermes = $true }
$checks = @{}
foreach ($q in $queue) {
    $dir = Join-Path $projects $q.Name; $b = @(); $w = @()
    if (-not (Test-Path $dir)) { $b += "folder $dir not found" }
    else {
        if (-not (Test-Path "$dir\scripts\verify.ps1")) { $b += 'no scripts/verify.ps1 (ask: "Make it overnight-ready")' }
        if ($q.Harness -notin 'claude', 'codex', 'hermes') { $b += "unknown tool @$($q.Harness)" }
        elseif (-not $cliOk[$q.Harness]) { $b += "$($q.Harness) CLI not found on this PC" }
        git -C $dir rev-parse '@{u}' *> $null
        if ($LASTEXITCODE -ne 0) { $b += 'no upstream branch, so commits cannot be pushed (add a GitHub remote)' }
        if (git -C $dir status --porcelain 2>$null) { $b += 'uncommitted changes on the desktop: commit or stash them first' }
        if ($q.Harness -eq 'hermes') {
            $st = "$($sparkState[$q.Name])"
            if ($st -eq 'unreachable') { $b += 'FirstSpark unreachable over SSH' }
            elseif ($st -eq 'missing') { $b += "not cloned on FirstSpark ($sparkProjects/$($q.Name))" }
            elseif ($st -match '^dirty=([1-9]\d*)$') { $b += "$($Matches[1]) uncommitted change(s) on FirstSpark" }
        }
        if (-not (Test-Path "$dir\BUILD_SPEC.md")) { $w += 'no BUILD_SPEC.md' }
        if ($q.Harness -ne 'claude' -and -not (Test-Path "$dir\AGENTS.md")) { $w += "no AGENTS.md for @$($q.Harness) (it will fall back to CLAUDE.md if it reads it)" }
        if (Test-Path "$dir\.claude\stop-retries") { $w += 'last run hit the stop-gate retry cap' }
        foreach ($f in 'REPORT.md', 'PROGRESS.md') {
            $open = @(Get-OpenItems "$dir\$f")
            if ($open) { $w += "$($open.Count) open question(s) in $($f): " + (($open | Select-Object -First 3) -join ' / ') }
        }
    }
    $checks[$q.Name] = @{ Blockers = $b; Warnings = $w }
}
$pf = @("# Preflight", "",
        "Checked $((Get-Date).ToString('yyyy-MM-dd HH:mm')) for tonight's lanes. **BLOCKED** projects are skipped tonight. **NEEDS INPUT** projects still run, on their recommended defaults, unless you answer first (in the project's REPORT.md or PROGRESS.md).", "",
        "| Project | Lane | Status | What's needed |", "|---|---|---|---|")
foreach ($q in $queue) {
    $c = $checks[$q.Name]
    $status = $(if ($c.Blockers) { 'BLOCKED' } elseif ($c.Warnings) { 'NEEDS INPUT' } else { 'READY' })
    $pf += "| $($q.Name) | $($q.Harness) | $status | $((@($c.Blockers) + @($c.Warnings)) -join '<br>') |"
}
if (-not $queue) { $pf += '| (Tonight list is empty) | | | |' }
if ($upkeep) {
    $pf += '', '## Top 10 upkeep', '', "Before the lanes start, the prep agent does the PREP items (make-overnight-ready, build-tree, structure, queue, advance): at the next real run, or right away when the Agents board runs -PrepOnly. OWNER items need you. Advance is checked at run time.", '',
        '| Project | Action | Who | Why |', '|---|---|---|---|'
    $pf += $upkeep | ForEach-Object { "| $($_.Project) | $($_.Action) | $(if ($_.Action -eq 'owner') { 'OWNER' } else { 'PREP' }) | $($_.Why) |" }
}
Set-Content -Path $preflightMd -Value $pf -Encoding UTF8
if ($Preflight -or $PrepOnly) { Write-Output ($pf -join "`n"); exit @($checks.Values | Where-Object { $_.Blockers }).Count }

# Every repo in tonight's queue gets a Hermes project (if it has none yet) so its sessions group under it.
# A failure here (FirstSpark down) never stops the run.
try { & (Join-Path $PSScriptRoot 'ensure-projects.ps1') -Projects @($queue | ForEach-Object { $_.Name }) -DryRun:$DryRun | ForEach-Object { Write-Output "projects: $_" } }
catch { Write-Output "projects: skipped ($($_.Exception.Message))" }

# ---- Tamper check: the files that judge the work must not change overnight, and the test suite must not shrink ----
# Claude is blocked from editing these by deny rules, but Codex (no sandbox) and Hermes (--yolo) are not, so the runner checks
# every project the same way: a baseline right before the lanes start (after prep, which may legitimately advance a slice)
# and a comparison after the run. Any difference turns the result into SUSPECT.
$guarded = 'scripts/verify.ps1', 'scripts/verify.sh', 'scripts/stop-gate.ps1', '.claude/settings.json'
function Get-Integrity($dir) {
    $h = @{}
    foreach ($g in $guarded) { $p = Join-Path $dir $g; if (Test-Path $p) { $h[$g] = (Get-FileHash $p -Algorithm SHA256).Hash } }
    $tests = 0; $skips = 0
    # shortcut: counts tests by regex (pytest "def test_", JS "it(" / "test("), not by running a collector; upgrade to
    # "pytest --collect-only -q" / "vitest list" if a project's count turns out noisy.
    $files = @(git -C $dir ls-files --cached --others --exclude-standard 2>$null | Where-Object { $_ -match '(^|/)(test_[^/]*\.py|[^/]*_test\.py|[^/]*\.(test|spec)\.[jt]sx?)$' })
    foreach ($f in $files) {
        $p = Join-Path $dir $f
        if (-not (Test-Path $p)) { continue }
        $t = Get-Content $p -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $t) { continue }
        $tests += ([regex]::Matches($t, '(?m)^\s*(async\s+)?def\s+test_|\b(it|test)\s*\(')).Count
        $skips += ([regex]::Matches($t, 'pytest\.mark\.(skip|xfail)|unittest\.skip|\b(it|test|describe)\.skip\s*\(|\bx(it|describe)\s*\(')).Count
    }
    return @{ Hashes = $h; Tests = $tests; Skips = $skips }
}
function Compare-Integrity($before, $after) {
    $issues = @()
    foreach ($g in $guarded) {
        $b = $before.Hashes[$g]; $a = $after.Hashes[$g]
        if ($b -and -not $a) { $issues += "$g deleted" } elseif ($b -and $a -ne $b) { $issues += "$g changed" }
    }
    if ($after.Tests -lt $before.Tests) { $issues += "tests $($before.Tests) -> $($after.Tests)" }
    if ($after.Skips -gt $before.Skips) { $issues += "skipped tests $($before.Skips) -> $($after.Skips)" }
    return $issues
}

# One agent run, inside a background job. Output goes to $log.
$worker = {
    param($dir, $harness, $model, $prompt, $log, $budget, $ssh, $sparkDir, $sessionName)
    Set-Content -Path "$log.pid" -Value $PID   # so the runner can end this job's whole process tree at the end time
    $OutputEncoding = New-Object System.Text.UTF8Encoding $false
    Set-Location $dir
    $env:OVERNIGHT_RUN = '1'   # turns on the project's Stop-hook verify gate (Claude)
    switch ($harness) {
        'codex' {
            # @codex:<name> is a profile when ~/.codex/<name>.config.toml exists (model + reasoning effort), else a model id.
            $a = @('exec', '--dangerously-bypass-approvals-and-sandbox')
            if ($model -and (Test-Path (Join-Path $HOME ".codex\$model.config.toml"))) { $a += @('-p', $model) } elseif ($model) { $a += @('-m', $model) }
            $prompt | & codex @a - *>> $log
        }
        'hermes' {
            if (-not $model) { $model = 'glm53-flash' }   # best local coding model (SecondSpark + ThirdSpark)
            $m = "-m $model"
            # .git/overnight-hermes.pid: a session cut off from this side (dropped SSH) can still be running on FirstSpark;
            # never start a second one in the same repo (SPARK_BUSY makes the runner wait and try again).
            $remote = 'test -d {0} || {{ echo SPARK_MISSING; exit 3; }}; cd {0} || exit 3; p=.git/overnight-hermes.pid; if [ -f $p ] && kill -0 $(cat $p) 2>/dev/null; then echo SPARK_BUSY; exit 4; fi; echo $$ > $p; git pull --rebase -q; ~/.local/bin/hermes chat --query-file - -Q --yolo --in {0} --run-budget {1} {2}; rm -f $p; echo SPARK_GIT dirty=$(git status --porcelain | wc -l) unpushed=$(git rev-list --count @{{u}}..HEAD)' -f $sparkDir, $budget, $m
            $prompt | & $ssh -o BatchMode=yes FirstSpark $remote *>> $log
        }
        default {
            if (-not $model) { $model = 'opus' }   # coordinator; the builder subagent runs on sonnet
            # @claude:<model>[-<effort>], e.g. opus-xhigh or fable-high; effort defaults to high for unattended runs.
            $effort = 'high'
            if ($model -match '^(.+)-(low|medium|high|xhigh|max)$') { $model = $Matches[1]; $effort = $Matches[2] }
            # -n names the session in Claude Code's session list; Codex and Hermes have no such flag (the board labels theirs).
            $prompt | & claude -p -n $sessionName --model $model --effort $effort --permission-mode bypassPermissions *>> $log
        }
    }
}

$rows = @{}; $pending = New-Object System.Collections.ArrayList
foreach ($q in $queue) {
    $dir = Join-Path $projects $q.Name
    $rows[$q.Name] = [ordered]@{ Project = $q.Name; Harness = "$($q.Harness)$(if ($q.Model) { ':' + $q.Model })"; Verify = '-'; Git = '-'; Commits = 0; Note = '';
        Minutes = 0; TestsBefore = ''; TestsAfter = ''; TimedOut = $false; UsageLimit = $false }
    if ($checks[$q.Name].Blockers) { $rows[$q.Name].Note = 'skipped by preflight: ' + ($checks[$q.Name].Blockers -join '; ') }
    elseif ($DryRun) { $rows[$q.Name].Note = 'dry run: would run now' }
    else { [void]$pending.Add($q) }
}
$integrity = @{}   # tamper baseline, taken just before the lanes start
foreach ($q in $pending) { $integrity[$q.Name] = Get-Integrity (Join-Path $projects $q.Name); $rows[$q.Name].TestsBefore = $integrity[$q.Name].Tests }

function Complete-Run($q, $row) {
    $dir = Join-Path $projects $q.Name
    $log = Join-Path $logDir "$($q.Name).log"
    $text = $(if (Test-Path $log) { Get-Content $log -Raw -Encoding UTF8 } else { '' })
    $text = ($text -split '(?m)^=== session \d+ ')[-1]   # only this session's output; earlier sessions were already read
    $text = $text -replace "`0", ''   # *>> appends UTF-16 to a UTF-8 file: drop the NULs so the checks below can match
    if ($q.Harness -ne 'hermes' -and $text -match $limitHit) {
        $script:limitUntil[$q.Harness] = Get-LimitReset $text
        $row.Note += "$($q.Harness) usage limit at $((Get-Date).ToString('HH:mm')), resumed after $($script:limitUntil[$q.Harness].ToString('HH:mm')). "; $row.UsageLimit = $true
    }
    if ($q.Harness -eq 'hermes') {
        if ($text -match 'SPARK_MISSING') { $row.Note += "not cloned on FirstSpark at $sparkProjects. " }
        if ($text -match 'SPARK_GIT dirty=(\d+) unpushed=(\d+)') { $row.Note += "FirstSpark: $($Matches[1]) uncommitted, $($Matches[2]) unpushed. " }
        git -C $dir pull --rebase --autostash -q 2>$null   # bring Hermes's pushed commits here for the gate
    }
    if ($row.Note -notlike "*log: $log*") { $row.Note += "log: $log" }
    return $text
}

# A session that ended because the connection dropped (API host, or FirstSpark over SSH), or found the last Hermes
# session for this project still running on FirstSpark, is started again once the other end answers.
$netError = '(?i)ENOTFOUND|EAI_AGAIN|ECONNRESET|ECONNREFUSED|ETIMEDOUT|fetch failed|Connection error|network error|getaddrinfo|Could not resolve host|Connection timed out|Connection reset|Connection closed by|Broken pipe|client_loop|ssh: connect to host|SPARK_BUSY'
function Test-Online($harness) {
    if ($harness -eq 'hermes') { & $ssh -o BatchMode=yes -o ConnectTimeout=8 FirstSpark true *> $null; return $LASTEXITCODE -eq 0 }
    $hostName = $(if ($harness -eq 'codex') { 'api.openai.com' } else { 'api.anthropic.com' })
    $client = New-Object System.Net.Sockets.TcpClient
    try { return $client.ConnectAsync($hostName, 443).Wait(8000) } catch { return $false } finally { $client.Dispose() }
}

# A tool at its usage limit ("You've hit your session limit, resets 2:30am", "try again in 2 hours") waits for the reset,
# then its projects start again; nothing is dropped for the night.
$limitHit = '(?i)usage limit|limit reached|rate.limit|hit your (session |usage |weekly )?limit|session limit'
function Get-LimitReset($text) {
    $now = Get-Date
    if ($text -match '(?i)(?:resets?|try again)\s+(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)') {
        $h = [int]$Matches[1] % 12; if ($Matches[3] -ieq 'pm') { $h += 12 }
        $t = $now.Date.AddHours($h).AddMinutes([int]$Matches[2] + 2); if ($t -le $now) { $t = $t.AddDays(1) }
        return $t
    }
    if ($text -match '(?i)try again in (\d+)\s*(hour|minute)') { return $now.AddMinutes([int]$Matches[1] * $(if ($Matches[2] -ieq 'hour') { 60 } else { 1 }) + 2) }
    return $now.AddMinutes(60)   # shortcut: no reset time found, so retry in an hour; parse the tool's wording if logs show a different message
}

# Tonight's target finished mid-run: the prep agent advances the project to its next slices (advance-slice skill) from the
# Projects root, where the projects' deny rules on verify.ps1 don't apply, then the project gets a new session.
$advanceWorker = {
    param($root, $text, $log, $tool)
    $OutputEncoding = New-Object System.Text.UTF8Encoding $false
    Set-Content -Path "$log.pid" -Value $PID
    Set-Location $root
    if ($tool -eq 'codex') { $text | & codex exec --dangerously-bypass-approvals-and-sandbox - *>> $log }
    else { $text | & claude -p --model opus --permission-mode bypassPermissions *>> $log }
}
function Start-Advance($q) {
    $name = $q.Name; $dir = Join-Path $projects $name
    $issues = @(Compare-Integrity $integrity[$name] (Get-Integrity $dir))   # checked before the advance re-baselines it
    if ($issues) { $rows[$name].Note += "not advanced: SUSPECT ($($issues -join '; ')). "; return }
    $now = Get-Date
    $tool = $(if (-not $limitUntil['claude'] -or $now -ge $limitUntil['claude']) { 'claude' } elseif (-not $limitUntil['codex'] -or $now -ge $limitUntil['codex']) { 'codex' } else { '' })
    if (-not $tool) { $rows[$name].Note += 'not advanced: claude and codex are both at their usage limit. '; return }
    $advances[$name] = 1 + [int]$advances[$name]
    $text = (Get-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') -Raw -Encoding UTF8) +
        "`n- ${name}: advance (tonight's target passed during the run and the lanes are already going: do only this item, quickly)`n"
    $log = Join-Path $logDir "$name.advance.txt"; Remove-Item "$log.pid" -ErrorAction SilentlyContinue
    $job = Start-Job -ScriptBlock $advanceWorker -ArgumentList $projects, $text, $log, $tool
    $running[$job.Id] = @{ Job = $job; Q = $q; Start = $now; Head = (git -C $dir rev-parse HEAD 2>$null); Advance = $true; PidFile = "$log.pid" }
}

# Real progress since $from: a commit that changes more than the bookkeeping files every session rewrites.
function Test-Progress($dir, $from) {
    $head = git -C $dir rev-parse HEAD 2>$null
    if (-not $from -or -not $head -or $head -eq $from) { return $false }
    return [bool](@(git -C $dir diff --name-only $from $head 2>$null) | Where-Object { $_ -notmatch '(^|/)(REPORT|PROGRESS|DECISIONS)\.md$' })
}

# The lanes' end time. Nightly: -Until (next occurrence), so the lanes work all night. Otherwise -HoursPerProject from now.
function Get-Deadline($now) {
    if ($resumeEnd) { return $resumeEnd }   # a resumed run keeps the cut-off run's end time
    if ($Kind -eq 'nightly' -and -not $hoursGiven) {
        $d = $now.Date.Add([timespan]::Parse($Until)); if ($d -le $now) { $d = $d.AddDays(1) }; return $d
    }
    return $now.AddHours($HoursPerProject)
}
$deadline = Get-Deadline (Get-Date)
$minSession = 1800   # never start a session with less than 30 minutes left
$maxSessions = 8     # shortcut: a fixed cap per project per run in case an agent keeps committing in circles; raise it if logs show real work cut off

if ($pending.Count) { @{ kind = $Kind; started = $started.ToString('o'); until = $deadline.ToString('o') } | ConvertTo-Json | Set-Content -Path $stateFile -Encoding UTF8 }
$running = @{}; $limitUntil = @{}; $advances = @{}; $sessions = @{}; $waitNet = @{}; $netRetries = @{}; $nextNetCheck = @{}
while ($pending.Count -or $running.Count) {
    # Start every pending project whose harness has a free slot, in list order (first sessions before relaunches).
    foreach ($q in @($pending)) {
        $left = [int]($deadline - (Get-Date)).TotalSeconds
        if ($left -lt $minSession) { if (-not $sessions[$q.Name]) { $rows[$q.Name].Note = "not run: less than 30 min left before $($deadline.ToString('HH:mm'))" }; $pending.Remove($q); continue }
        if ($limitUntil[$q.Harness] -and (Get-Date) -lt $limitUntil[$q.Harness]) { continue }   # waits for the tool's usage limit to reset
        if ($waitNet[$q.Name]) {   # checked at most once a minute per tool
            if ($nextNetCheck[$q.Harness] -and (Get-Date) -lt $nextNetCheck[$q.Harness]) { continue }
            if (-not (Test-Online $q.Harness)) { $nextNetCheck[$q.Harness] = (Get-Date).AddMinutes(1); continue }
            $waitNet.Remove($q.Name)
        }
        if (@($running.Values | Where-Object { $_.Q.Harness -eq $q.Harness }).Count -ge $PerHarness) { continue }
        $pending.Remove($q)
        $dir = Join-Path $projects $q.Name; $log = Join-Path $logDir "$($q.Name).log"
        $sessions[$q.Name] = 1 + [int]$sessions[$q.Name]
        Add-Content -Path $log -Value "=== session $($sessions[$q.Name]) $((Get-Date).ToString('HH:mm')), until $($deadline.ToString('HH:mm')) ===" -Encoding UTF8
        Remove-Item "$log.pid" -ErrorAction SilentlyContinue   # the job writes a fresh one
        $dot = [char]0x00B7   # this file must stay ASCII for PowerShell 5.1
        $sessionName = "$($q.Name) $dot $(if ($Kind -eq 'morning') { 'morning' } else { 'night' }) of $($started.ToString('MMM d', [Globalization.CultureInfo]::InvariantCulture)) $dot session $($sessions[$q.Name])"
        $job = Start-Job -ScriptBlock $worker -ArgumentList $dir, $q.Harness, $q.Model, $prompt, $log, $left, $ssh, "$sparkProjects/$($q.Name)", $sessionName
        $running[$job.Id] = @{ Job = $job; Q = $q; Start = Get-Date; Head = (git -C $dir rev-parse HEAD 2>$null); PidFile = "$log.pid" }
    }
    if (-not $running.Count) { if ($pending.Count) { Start-Sleep -Seconds 30; continue }; break }   # only projects waiting for the network or a usage-limit reset
    Wait-Job -Job @($running.Values | ForEach-Object { $_.Job }) -Any -Timeout 60 | Out-Null
    foreach ($id in @($running.Keys)) {
        $r = $running[$id]; $row = $rows[$r.Q.Name]
        if ($r.Job.State -eq 'Running' -and (Get-Date) -ge $deadline.AddSeconds(300)) {
            # Stop-Job alone ends only the job host; taskkill /T also ends the claude/codex/ssh process under it and their children.
            # (A Hermes session on FirstSpark stops itself: it was given the same end time as --run-budget.)
            $jobPid = Get-Content $r.PidFile -ErrorAction SilentlyContinue | Select-Object -First 1   # this job's own file, never an earlier one
            if ($jobPid) { & taskkill.exe /PID $jobPid /T /F *> $null }
            Stop-Job $r.Job; $row.Note += "stopped at the $($deadline.ToString('HH:mm')) end time, agent processes ended. "; $row.TimedOut = $true
        }
        if ($r.Job.State -ne 'Running') {
            Remove-Job $r.Job -Force; $running.Remove($id)
            $name = $r.Q.Name; $dir = Join-Path $projects $name
            if ($r.Advance) {
                $integrity[$name] = Get-Integrity $dir   # the advance legitimately extends verify.ps1: that is the new baseline
                if (-not $row.TimedOut -and (Test-Progress $dir $r.Head)) { $row.Note += "advanced to its next slices at $((Get-Date).ToString('HH:mm')). "; [void]$pending.Add($r.Q) }
                elseif (-not $row.TimedOut) { $row.Note += "not advanced: the next work waits on an owner gate, or the project is built (see Prep Report). " }
                continue
            }
            $row.Minutes += [int]((Get-Date) - $r.Start).TotalMinutes
            $text = Complete-Run $r.Q $row
            if ($row.TimedOut) { continue }
            # Stopped early with real progress and time left: start it again; it resumes from PROGRESS.md's next open item.
            if ($sessions[$name] -lt $maxSessions -and (Test-Progress $dir $r.Head)) { [void]$pending.Add($r.Q) }
            elseif ($r.Q.Harness -ne 'hermes' -and "$text" -match $limitHit) { [void]$pending.Add($r.Q) }   # starts again after the reset
            elseif ("$text" -match $netError -and [int]$netRetries[$name] -lt 6) {
                $netRetries[$name] = 1 + [int]$netRetries[$name]; $waitNet[$name] = $true
                $row.Note += "connection lost at $((Get-Date).ToString('HH:mm')), retried when back. "; [void]$pending.Add($r.Q)
            }
            # No new work: tonight's target is probably done. Advance it (at most twice a run) while an hour is left.
            elseif ([int]$advances[$name] -lt 2 -and ($deadline - (Get-Date)).TotalMinutes -gt 60) { Start-Advance $r.Q }
        }
    }
}
foreach ($name in @($sessions.Keys)) { if ($sessions[$name] -gt 1) { $rows[$name].Note = "$($sessions[$name]) sessions. " + $rows[$name].Note } }

# Independent gate: the runner's own verify and git check, not the agent's claim.
foreach ($q in $queue) {
    $dir = Join-Path $projects $q.Name; $row = $rows[$q.Name]
    if (-not (Test-Path "$dir\scripts\verify.ps1")) { continue }
    & powershell -NoProfile -ExecutionPolicy Bypass -File "$dir\scripts\verify.ps1" *> (Join-Path $logDir "$($q.Name).verify.txt")
    $row.Verify = $(if ($LASTEXITCODE -eq 0) { 'PASS' } else { 'FAIL' })
    if ($integrity[$q.Name]) {
        $after = Get-Integrity $dir; $row.TestsAfter = $after.Tests
        $issues = @(Compare-Integrity $integrity[$q.Name] $after)
        if ($issues) { $row.Verify = "SUSPECT ($($row.Verify))"; $row.Note = "SUSPECT: $($issues -join '; '). Check the diff before trusting this result. " + $row.Note }
    }
    $dirty = git -C $dir status --porcelain 2>$null
    $ahead = git -C $dir rev-list --count '@{u}..HEAD' 2>$null
    $row.Git = $(if ($dirty) { 'uncommitted changes' } elseif ([int]$ahead -gt 0) { "$ahead unpushed" } else { 'clean, pushed' })
    $row.Commits = @(git -C $dir log --since=$($started.ToString('s')) --oneline 2>$null).Count
}

$md = @("# $(if ($Kind -eq 'morning') { 'Morning' } else { 'Overnight' }) Report", "",
        "Run started $($started.ToString('yyyy-MM-dd HH:mm')), finished $((Get-Date).ToString('HH:mm'))$(if ($DryRun) { ' (dry run)' }), $Kind run, up to $PerHarness per harness at once. Logs: ``$logDir``", "",
        ($(if ($prepWork -and -not $DryRun -and -not $NoPrep) { "Prep before the lanes: $($prepWork.Count) top-10 upkeep item(s); see ``Nightly Runs/Prep Report.md`` and ``$logDir\_prep.log``. " } else { '' }) +
        "Verify is re-run by the runner on the desktop after each agent finishes (for @hermes, after pulling its pushed commits). Each project's ``REPORT.md`` has details and open questions."), "",
        "| Project | Harness | Verify | Git (desktop) | Commits tonight | Note |", "|---|---|---|---|---|---|")
$md += $queue | ForEach-Object { $r = $rows[$_.Name]; "| $($r.Project) | $($r.Harness) | $($r.Verify) | $($r.Git) | $($r.Commits) | $($r.Note) |" }
if (-not $queue) { $md += '| (Tonight list is empty) | | | | | |' }
New-Item -ItemType Directory -Force $runLogDir | Out-Null   # Morning Runs/Logs on the first morning run
Set-Content -Path $reportMd -Value $md -Encoding UTF8
if (-not $DryRun) { Set-Content -Path (Join-Path $runLogDir "$stamp.md") -Value $md -Encoding UTF8 }
if (-not $DryRun) { Remove-Item $stateFile -ErrorAction SilentlyContinue }   # finished: nothing for -Resume to continue

# ---- Scorecard: one row per project per real run, plus a summary by tool, so harnesses and models can be compared ----
$scoreCsv = Join-Path $vault 'Nightly Runs\Scorecard.csv'
$scoreMd  = Join-Path $vault 'Nightly Runs\Scorecard.md'
if (-not $DryRun -and $queue) {
    $queue | ForEach-Object {
        $r = $rows[$_.Name]
        $result = $(if ($r.Verify -like 'SUSPECT*') { 'SUSPECT' } elseif ($r.Note -like 'skipped by preflight*') { 'SKIPPED' }
                    elseif ($r.Note -like 'not run*') { 'NOT RUN' } elseif ($r.Verify -in 'PASS', 'FAIL') { $r.Verify } else { 'UNKNOWN' })
        [pscustomobject]@{
            Run = $stamp; Kind = $Kind; Project = $_.Name; Harness = $_.Harness; Model = $(if ($_.Model) { $_.Model } else { 'default' })
            Result = $result; Minutes = $r.Minutes; Commits = $r.Commits; TestsBefore = $r.TestsBefore; TestsAfter = $r.TestsAfter
            OpenQuestions = @(Get-OpenItems (Join-Path $projects "$($_.Name)\REPORT.md")).Count; TimedOut = $r.TimedOut; UsageLimit = $r.UsageLimit
        }
    } | Export-Csv -Path $scoreCsv -Append -NoTypeInformation -Encoding UTF8
}
if (Test-Path $scoreCsv) {
    $all = @(Import-Csv $scoreCsv)
    $cut = (Get-Date).AddDays(-7).ToString('yyyy-MM-dd')
    function Get-ScoreRows($set) {
        $set | Group-Object Harness | Sort-Object Name | ForEach-Object {
            $ran = @($_.Group | Where-Object { $_.Result -in 'PASS', 'FAIL', 'SUSPECT' })
            $pass = @($ran | Where-Object Result -eq 'PASS').Count
            $rate = $(if ($ran.Count) { [int](100 * $pass / $ran.Count) } else { 0 })
            $mins = $(if ($ran.Count) { [int](($ran | Measure-Object Minutes -Average).Average) } else { 0 })
            "| $($_.Name) | $($ran.Count) | $pass | $(@($ran | Where-Object Result -eq 'FAIL').Count) | $(@($ran | Where-Object Result -eq 'SUSPECT').Count) | $rate% | $mins | $(($_.Group | Measure-Object Commits -Sum).Sum) | $(@($_.Group | Where-Object { $_.Result -in 'SKIPPED', 'NOT RUN' }).Count) |"
        }
    }
    $head = '| Tool | Runs | PASS | FAIL | SUSPECT | Pass rate | Avg minutes | Commits | Skipped / not run |', '|---|---|---|---|---|---|---|---|---|'
    $sm = @('# Scorecard', '', "Rebuilt $((Get-Date).ToString('yyyy-MM-dd HH:mm')) from ``Scorecard.csv`` (one row per project per real run). SUSPECT = verify passed or failed, but a guarded file changed or tests shrank overnight, so check the diff.", '',
            '## Last 7 days', '') + $head + @(Get-ScoreRows @($all | Where-Object { $_.Run -ge $cut })) + @('', '## All time', '') + $head + @(Get-ScoreRows $all) +
          @('', '## Last 5 results per project (newest first)', '', '| Project | Tool | Results |', '|---|---|---|')
    $sm += $all | Group-Object Project | Sort-Object Name | ForEach-Object {
        $last = @($_.Group | Sort-Object Run -Descending | Select-Object -First 5)
        "| $($_.Name) | $($last[0].Harness) | $(($last | ForEach-Object { "$($_.Result) ($($_.Run.Substring(0, 10)))" }) -join ', ') |"
    }
    Set-Content -Path $scoreMd -Value $sm -Encoding UTF8
}
Write-Output ($md -join "`n")
