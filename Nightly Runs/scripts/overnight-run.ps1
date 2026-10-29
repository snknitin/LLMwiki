# Overnight runner: works the "## Tonight" list in Nightly Runs/Project Priorities.md, every project at once (or up to -PerHarness per harness)
# (default 3 Claude + 3 Codex + 3 Hermes = 9 in parallel).
# @claude and @codex run here on the desktop; @hermes runs on FirstSpark over SSH. After each agent finishes,
# the runner re-runs that project's scripts/verify.ps1 itself and writes a report plus a dated copy per real run (never overwritten):
#   nightly: Nightly Runs/Overnight Report.md, Nightly Runs/Logs/<yyyy-MM-dd_HHmm>.md, agent logs in E:/GIT_ROOT/Projects/.overnight-logs
#   morning: Morning Runs/Morning Report.md,   Morning Runs/Logs/<yyyy-MM-dd_HHmm>.md, agent logs in E:/GIT_ROOT/Projects/.morning-logs
# Every run starts with a preflight: projects with blockers are skipped, and Nightly Runs/Preflight.md lists what needs you.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File overnight-run.ps1 [-Kind nightly|morning] [-Preflight | -DryRun] [-PerHarness N (default 0 = no limit)] [-Until 06:00] [-HoursPerProject 3]
#   -Kind       where results go (above); the scheduled task passes nightly. Default: morning if started 05:00-16:59, else nightly
#   -Until      a nightly run keeps its lanes working until this time (default 06:00): an agent that stops early with real
#               progress is started again on its project. A morning run, or any run given -HoursPerProject, works that many hours.
#   -Preflight  only check (run it in the evening, fix what it lists, then let 23:00 run); exit code = number of blocked projects
#   -NoPrep     skip the top-10 upkeep prep agent (see Get-Upkeep); -PrepMinutes caps it (default 90)
#   -PrepOnly   run only the prep agent (make-overnight-ready, build-tree, structure, mvp, advance; never moves lanes), then refresh Preflight.md
#   -QaOnly -Project <folder> -QaFrom <commit>: review an earlier range, without prep or builder sessions
#               and exit. The Agents board runs it when a project enters the top 10 or a Tonight lane, so it's ready before 23:00.
#   -Resume     continue a run that was cut off (power cut, crash, reboot) until its original end time; exits at once when
#               there is none. The "Agents Run resume" task runs it at logon and every 15 minutes.
# Survives the night: the PC is kept awake while a run is going, and a session that ended on a network error waits for the
# network (or FirstSpark) to come back, then starts again. A tool at its usage limit waits for the reset time it prints;
# meanwhile a Claude project's sessions run on Codex, or on Hermes if Codex is parked too (noted in the report row).
# A project that finishes tonight's target mid-run is advanced to its next slices (advance-slice) and keeps going.
param([ValidateSet('nightly', 'morning')][string]$Kind, [switch]$Preflight, [switch]$DryRun, [int]$PerHarness = 0, [double]$HoursPerProject = 3, [string]$Until = '06:00', [switch]$NoPrep, [int]$PrepMinutes = 90, [switch]$PrepOnly, [switch]$Resume, [switch]$Scheduled, [int]$QaMinutes = 30,
      [switch]$QaOnly, [ValidatePattern('^[A-Za-z0-9._-]+$')][string]$Project, [string]$QaFrom, [switch]$FixOnly)
if ($QaOnly -and (-not $Project -or -not $QaFrom -or $Resume -or $PrepOnly -or $DryRun)) { throw '-QaOnly requires -Project and -QaFrom, without Resume, PrepOnly or DryRun' }
if ($QaOnly) { $NoPrep = $true }
if ($FixOnly -and (-not $Project -or $QaOnly -or $PrepOnly -or $DryRun -or $Resume)) { throw '-FixOnly requires -Project, without QaOnly, PrepOnly, DryRun or Resume' }
$ErrorActionPreference = 'Continue'
$hoursGiven = $PSBoundParameters.ContainsKey('HoursPerProject')   # explicit hours win over a nightly run's -Until
# Paused on the board (Nightly Runs/pause.json): the scheduled tasks (-Scheduled) skip until then. Prep now and
# Start a run now still work, and so does -Resume of a run that was cut off.
if ($Scheduled) {
    $pauseFile = Join-Path $(if ($env:OVERNIGHT_VAULT) { $env:OVERNIGHT_VAULT } else { 'F:\Vaults\LLMWiki' }) 'Nightly Runs\pause.json'
    try { $pausedUntil = [datetime]((Get-Content $pauseFile -Raw -ErrorAction Stop | ConvertFrom-Json).until) } catch { $pausedUntil = $null }
    if ($pausedUntil -and $pausedUntil -gt (Get-Date)) { Write-Output "Scheduled $(if ($PrepOnly) { 'prep' } else { 'run' }) skipped: paused until $($pausedUntil.ToString('yyyy-MM-dd HH:mm'))"; exit 0 }
}
# One run at a time, however it was started (board button, scheduled "Agents Run HHMM" task, by hand): a second one exits.
# A real run that finds only a -PrepOnly going waits for it (prep is short), so a late prep never costs the night.
# Not a -Resume check: the prep waits out a -Resume check, so the two would deadlock and the prep give up (2026-10-29 18:00).
function Get-OtherRuns { @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe' OR Name='pwsh.exe'" | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -like '*-File*overnight-run.ps1*' -and $_.CommandLine -notlike '*-Preflight*' }) }
$others = Get-OtherRuns
# A -Resume check with nothing to continue exits within seconds: wait that out, so a 23:00 start never loses to it.
if (-not $Preflight -and $others -and -not @($others | Where-Object { $_.CommandLine -notlike '*-Resume*' })) {
    $waitUntil = (Get-Date).AddSeconds(60)   # not $until: PowerShell names ignore case, so that would overwrite -Until
    while (@(Get-OtherRuns | Where-Object { $_.CommandLine -like '*-Resume*' }) -and (Get-Date) -lt $waitUntil) { Start-Sleep -Seconds 5 }
    $others = Get-OtherRuns
}
if (-not $Preflight -and -not $PrepOnly -and -not $Resume -and $others -and -not @($others | Where-Object { $_.CommandLine -notlike '*-PrepOnly*' -and $_.CommandLine -notlike '*-FixOnly*' })) {
    $waitUntil = (Get-Date).AddMinutes($PrepMinutes + 5)
    while ((Get-OtherRuns) -and (Get-Date) -lt $waitUntil) { Start-Sleep -Seconds 30 }
    $others = Get-OtherRuns
}
# A fix session ignores -Resume checks that have no cut-off run to continue: they only wait (for preps and fixes too),
# so counting them would deadlock the two.
if ($FixOnly -and -not (Test-Path (Join-Path $(if ($env:OVERNIGHT_VAULT) { $env:OVERNIGHT_VAULT } else { 'F:\Vaults\LLMWiki' }) 'Nightly Runs\.run-state.json'))) {
    $others = @($others | Where-Object { $_.CommandLine -notlike '*-Resume*' })
}
# A scheduled run never loses its night to a run still going (a Start now in the evening): it waits for that one to end.
if (-not $Preflight -and $others -and $Scheduled -and -not $PrepOnly -and -not $Resume) {
    Write-Output "Another run is going (pid $($others.ProcessId -join ', ')); this scheduled run starts when it ends."
    $launched = Get-Date; $waitUntil = $launched.AddHours(10)
    while ((Get-OtherRuns) -and (Get-Date) -lt $waitUntil) { Start-Sleep -Seconds 60 }
    $others = Get-OtherRuns
    # Its night ended while it waited: starting now would set the end time to the next -Until and run all day
    # (2026-10-25: a 21:00 run waiting behind a 19:23 Start now that the owner kept until 06:00).
    if (-not $others -and $Kind -eq 'nightly' -and -not $hoursGiven) {
        $end = $launched.Date.Add([timespan]::Parse($Until)); if ($end -le $launched) { $end = $end.AddDays(1) }
        if ((Get-Date) -ge $end.AddMinutes(-30)) { Write-Output "The run it waited for went on until $((Get-Date).ToString('HH:mm')); tonight's window ($Until) is over, so this scheduled run does not start."; exit 0 }
    }
}
# A second check that needs no WMI: the running run's lock (pid + process start time). On 2026-10-28 the process query
# came back without the 23:32 runner under load, and a -Resume runner worked the same projects alongside it all night.
$runLock = Join-Path $(if ($env:OVERNIGHT_VAULT) { $env:OVERNIGHT_VAULT } else { 'F:\Vaults\LLMWiki' }) 'Nightly Runs\.runner.lock'
function Get-LockHolder {
    try { $l = Get-Content $runLock -Raw -ErrorAction Stop | ConvertFrom-Json } catch { return $null }
    $p = Get-Process -Id ([int]$l.pid) -ErrorAction SilentlyContinue
    if ($p -and $p.Id -ne $PID -and $p.StartTime.ToString('o') -eq $l.started) { return [int]$l.pid } else { return $null }
}
$holder = $(if (-not $Preflight) { Get-LockHolder })
if (-not $Preflight -and ($others -or $holder)) { Write-Output "Another run is going (pid $(@(@($others.ProcessId) + $holder | Where-Object { $_ } | Select-Object -Unique) -join ', ')); not starting a second one."; exit 0 }
$vault         = $(if ($env:OVERNIGHT_VAULT) { $env:OVERNIGHT_VAULT } else { 'F:\Vaults\LLMWiki' })   # the env overrides are for test-qa.ps1's fixture
$projects      = $(if ($env:OVERNIGHT_PROJECTS) { $env:OVERNIGHT_PROJECTS } else { 'E:\GIT_ROOT\Projects' })
$sparkProjects = $(if ($env:OVERNIGHT_SPARK_PROJECTS) { $env:OVERNIGHT_SPARK_PROJECTS } else { '/home/snknitin/Workspace/GIT_ROOT/Projects' })
if ($sparkProjects -notmatch '^/[A-Za-z0-9/._-]+$') { throw 'Invalid Spark project root' }
$ssh           = "$env:WINDIR\System32\OpenSSH\ssh.exe"
# No Claude self-update mid-run: one at 21:36 on 2026-10-28 left claude.exe missing and every later Claude call failed.
$env:DISABLE_AUTOUPDATER = '1'
$prioFile      = Join-Path $vault 'Nightly Runs\Project Priorities.md'
$preflightMd   = Join-Path $vault 'Nightly Runs\Preflight.md'
$prompt        = Get-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') -Raw -Encoding UTF8
# Owner answers that asked for work become PROGRESS.md items (the board writes them); builders clear them first.
$ownerQueue    = "OWNER QUEUE: before tonight's target, do every open '- [ ]' item under '## Queued by the owner (Agents board)' in PROGRESS.md. " +
    "The owner asked for each on the Agents board, with their answer in the item. Build or fix it, run verify, tick the item with the commit hash, " +
    "and resolve the matching entry in any 'Open decisions' or open-question list (mark it resolved with the date and commit) so the board stops asking.`n"
$prompt       += "`n$ownerQueue"
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
# Claimed only now: a -Resume check with nothing to continue exits above without it, so it never turns away the scheduled prep or run that fires with it.
if (-not $Preflight -and -not $PrepOnly -and -not $DryRun) { @{ pid = $PID; started = (Get-Process -Id $PID).StartTime.ToString('o') } | ConvertTo-Json -Compress | Set-Content -Path $runLock -Encoding UTF8 }
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
        if ($inTonight -and $line -match '^\s*-\s+([A-Za-z0-9._-]+)(?:\s+@(\w+)(?::([\w./-]+))?)?(?:\s+qa=([\w:./-]+))?' -and -not $seen[$Matches[1]]) {
            $seen[$Matches[1]] = $true
            $q += [pscustomobject]@{ Name = $Matches[1]; Harness = $(if ($Matches[2]) { $Matches[2].ToLower() } else { $lane }); Model = $Matches[3]; Qa = $Matches[4] }
        }
    }
    return $q
}

# Role matrix (Nightly Runs/roles.json, edited on the Agents board): per lane the builder and the QA harness[:model].
# QA is always another model family than the builder. A missing or invalid file means these defaults.
$rolesFile = Join-Path $vault 'Nightly Runs\roles.json'
$defaultRoles = @{ claude = @{ builder = 'claude:opus'; qa = 'codex'; fallbackQa = 'hermes:qwen3.6-35b-a3b' }; codex = @{ builder = 'codex'; qa = 'claude:sonnet'; fallbackQa = 'hermes:qwen3.6-35b-a3b' }; hermes = @{ builder = 'hermes'; qa = 'claude:sonnet'; fallbackQa = 'hermes:qwen3.6-35b-a3b' } }
$specPattern = '^(claude|codex|hermes)(?::([\w./-]+))?$'
function Get-ModelFamily($spec) {
    if ($spec -notmatch $specPattern) { return $spec }
    $harness = $Matches[1]; $model = $Matches[2]
    if ($harness -ne 'hermes') { return $harness }
    if (-not $model) { $model = 'deepseek41-flash-pair' }   # Hermes' default model
    $model = ($model -split '/')[-1].ToLower()
    if ($model -match 'qwen|spark-fast') { return 'qwen' }
    if ($model -match 'glm') { return 'glm' }
    if ($model -match 'deepseek') { return 'deepseek' }
    if ($model -match 'claude') { return 'claude' }
    if ($model -match 'gpt|codex') { return 'codex' }
    return $model
}
function Read-Roles($file) {
    try {
        $j = Get-Content $file -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json
        $r = @{}
        foreach ($lane in 'claude', 'codex', 'hermes') {
            $b = "$($j.$lane.builder)"; $a = "$($j.$lane.qa)"
            if ($b -notmatch $specPattern -or $Matches[1] -ne $lane) { return $defaultRoles }
            if ($a -ne 'off' -and ($a -notmatch $specPattern -or (Get-ModelFamily $a) -eq (Get-ModelFamily $b))) { return $defaultRoles }
            $f = "$($j.$lane.fallbackQa)"
            if (-not $f) { $f = $(if ((Get-ModelFamily $a) -eq 'qwen') { 'off' } else { 'hermes:qwen3.6-35b-a3b' }) }
            if ($f -ne 'off' -and ($f -notmatch $specPattern -or (Get-ModelFamily $f) -eq (Get-ModelFamily $b) -or $f -eq $a)) { return $defaultRoles }
            $r[$lane] = @{ builder = $b; qa = $a; fallbackQa = $f }
        }
        return $r
    } catch { return $defaultRoles }
}
# What QA to run for a queue entry: the line's qa= override, else its harness's roles.json default. Family = the QA harness
# (its model after the colon). Skip = why there is none ('off' included). (test-qa.ps1 checks this.)
function Get-QaPlan($q, $roles, [switch]$Fallback) {
    $own = $q.Harness
    $spec = $(if ($Fallback) { $roles[$own].fallbackQa } elseif ($q.Qa) { $q.Qa } elseif ($roles[$own]) { $roles[$own].qa } else { '' })
    if ($spec -eq 'off') { return @{ Spec = $spec; Skip = $(if ($q.Qa) { 'off (qa=off)' } else { "off in roles.json for the $own lane" }) } }
    if ($spec -notmatch $specPattern) { return @{ Spec = $spec; Skip = "no valid QA harness ('$spec')" } }
    $family = $Matches[1]; $model = $Matches[2]
    $builder = "$own$(if ($q.Model) { ':' + $q.Model })"
    if ((Get-ModelFamily $spec) -eq (Get-ModelFamily $builder)) { return @{ Spec = $spec; Skip = "qa=$spec is the builder's own model family, and QA must differ" } }
    return @{ Spec = $spec; Family = $family; Model = $model; Skip = $null; FallbackUsed = [bool]$Fallback }
}
$roles = Read-Roles $rolesFile
# roles.json's builder model applies to a lane project with no @tag model of its own (claude:opus is the old default).
# The owner's picks take effect at the next step (owner, 2026-10-29): before every builder session, planning step and QA
# review the runner reads roles.json and the project's @tag model again, so a model or effort changed on the board mid-run
# is used at once, and the report's model column says what ran. The harness itself never changes mid-run.
function Update-Choices($q) {
    $script:roles = Read-Roles $rolesFile
    $now = @(Read-Queue | Where-Object { $_.Name -eq $q.Name })[0]
    $model = $(if ($now -and $now.Harness -eq $q.Harness -and $now.Model) { $now.Model } else { $null })
    if (-not $model -and $roles[$q.Harness] -and $roles[$q.Harness].builder -match $specPattern -and $Matches[1] -eq $q.Harness) { $model = $Matches[2] }
    $q.Model = $model
    if ($now) { $q.Qa = $now.Qa }
    if ($rows -and $rows[$q.Name]) { $rows[$q.Name].Harness = "$($q.Harness)$(if ($model) { ':' + $model })" }
}
function Set-BuilderModels($queue) {
    foreach ($q in $queue) { if (-not $q.Model -and $roles[$q.Harness] -and $roles[$q.Harness].builder -match $specPattern -and $Matches[1] -eq $q.Harness -and $Matches[2]) { $q.Model = $Matches[2] } }
    return $queue
}
# ---- Pipeline: the lanes, Ready next and Active follow the priority order (owner, 2026-10-25) ----
# Project Priorities.md keeps one "- name ..." line per project under "### Claude/Codex/Hermes" (in "## Tonight"),
# "## Ready next", "## Active" or "## Backlog"; the "## Priority order" list only ranks and never changes here.
# Every top-10 project that is overnight-ready (scripts/verify.ps1) goes into a Tonight lane, a Backlog project that has
# become overnight-ready goes to Ready next, and a built one goes to Active (see Test-Built), so the owner never has to.
$pipelineMoves = New-Object System.Collections.ArrayList
# The file's projects: Order (ranked), Where (name -> claude/codex/hermes/ready/active/backlog/archived), Tag (its @harness).
function Read-Pipeline {
    $st = @{ Order = @(); Where = @{}; Tag = @{}; Tier = @{} }; $sec = ''; $tier = ''
    foreach ($l in [IO.File]::ReadAllText($prioFile) -split '\r?\n') {
        if ($l -match '^##\s+(.+)') { $t = $Matches[1]; $sec = $(if ($t -match '^Tonight') { 'claude' } elseif ($t -match '^Priority order') { 'order' } elseif ($t -match '^Ready next') { 'ready' } elseif ($t -match '^Active') { 'active' } elseif ($t -match '^Backlog') { 'backlog' } elseif ($t -match '^Archive') { 'archived' } else { '' }); continue }
        if ($l -match '^###\s+(Claude|Codex|Hermes)\b' -and $sec -in 'claude', 'codex', 'hermes') { $sec = $Matches[1].ToLower(); continue }
        if ($sec -eq 'order') {
            if ($l -match '^###\s+(P\d+)\b') { $tier = $Matches[1] }
            elseif ($l -match '^\s*\d+\.\s+([A-Za-z0-9._-]+)') { $st.Order += $Matches[1]; if ($tier) { $st.Tier[$Matches[1]] = $tier } }
            continue
        }
        if ($sec -and $l -match '^\s*-\s+([A-Za-z0-9._-]+)(?:\s+@(claude|codex|hermes)\b)?') { if (-not $st.Where[$Matches[1]]) { $st.Where[$Matches[1]] = $sec }; if ($Matches[2]) { $st.Tag[$Matches[1]] = $Matches[2] } }
    }
    return $st
}
# Moves a project's line to the end of another section's list (a new "- name" line when it has none), in place, keeping
# the file's line endings; an atomic write, like the Agents board's own moves.
function Move-ProjectLine($folder, $to) {
    $pipeHeads = @{ claude = '### Claude'; codex = '### Codex'; hermes = '### Hermes'; ready = '## Ready next'; active = '## Active'; backlog = '## Backlog' }
    $raw = [IO.File]::ReadAllText($prioFile); $eol = $(if ($raw -match "`r`n") { "`r`n" } else { "`n" })
    $lines = New-Object System.Collections.ArrayList; foreach ($l in $raw -split '\r?\n') { [void]$lines.Add($l) }
    $sec = ''; $text = "- $folder"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^##\s+(.+)') { $sec = $Matches[1]; continue }
        if ($sec -match '^(Tonight|Ready next|Active|Backlog)' -and $lines[$i] -match "^\s*-\s+$([regex]::Escape($folder))(\s|$)") { $text = $lines[$i]; $lines.RemoveAt($i); break }
    }
    $h = -1; for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i].StartsWith($pipeHeads[$to])) { $h = $i; break } }
    if ($h -lt 0) { return $false }
    $k = $h + 1; while ($k -lt $lines.Count -and $lines[$k] -match '^\s*-\s') { $k++ }
    $lines.Insert($k, $text)
    $tmp = "$prioFile.$PID.tmp"
    [IO.File]::WriteAllText($tmp, ($lines -join $eol), (New-Object Text.UTF8Encoding $false))
    Move-Item -LiteralPath $tmp -Destination $prioFile -Force
    return $true
}
# The lane a project joins: its own @harness tag, else the emptier of Claude and Codex (Hermes needs a FirstSpark clone,
# so an untagged project only goes there when the owner tags it).
# The projects that run (owner, 2026-10-25): 10 at a time, the first 10 of the priority order that are not Active or
# Archived. When one moves to Active, the 11th becomes part of the 10.
function Get-RunSet($st) {
    return @($st.Order | Where-Object { $st.Where[$_] -notin 'active', 'archived' } | Select-Object -Unique -First 10)
}
# A project's lane: its own @harness tag, else the lane with the fewest projects (ties: Codex, then Claude, then Hermes;
# the runner clones a missing FirstSpark copy for Hermes).
# The lane each project last ran in (Nightly Runs/home-lanes.json, kept by Sync-Pipeline): a project that leaves the lanes
# and comes back returns to its own harness (2026-10-29: leetcode-pattern-curriculum left Hermes and came back on Codex).
function Read-HomeLanes {
    $h = @{}
    try { (Get-Content (Join-Path (Split-Path $prioFile) 'home-lanes.json') -Raw -ErrorAction Stop | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $h[$_.Name] = "$($_.Value)" } } catch { }
    return $h
}
function Get-LaneFor($name, $st) {
    if ($st.Tag[$name]) { return $st.Tag[$name] }
    $homeLane = (Read-HomeLanes)[$name]
    if ($homeLane -in 'claude', 'codex', 'hermes') { return $homeLane }
    $count = [ordered]@{ codex = 0; claude = 0; hermes = 0 }; foreach ($w in $st.Where.Values) { if ($w -in 'claude', 'codex', 'hermes') { $count[$w]++ } }
    $best = 'codex'; foreach ($k in @($count.Keys)) { if ($count[$k] -lt $count[$best]) { $best = $k } }   # first wins a tie
    return $best
}
# Fills the lanes from the top 10 and moves overnight-ready Backlog projects to Ready next. Returns what it moved.
# The sections follow the ranks: the lanes hold exactly the 10 that run, Ready next the next 5 ranks, Backlog the rest.
# A ranked project below the 10 leaves its lane; a project the owner put in a lane without ranking it stays.
function Sync-Pipeline {
    $st = Read-Pipeline; $moved = @()
    $lanes = 'claude', 'codex', 'hermes'
    # Built projects go to Active without asking (owner, 2026-10-25): a "Project built:" line, or a Move-to-Active question
    # answered Yes or not answered at all. Their spots go to the next ranks below.
    foreach ($n in @($st.Where.Keys | Where-Object { $st.Where[$_] -in $lanes + 'ready' })) {
        if ((Test-Built (Join-Path $projects $n)) -and (Move-ProjectLine $n 'active')) { $st.Where[$n] = 'active'; $moved += "$n to Active (built: only owner steps left)" }
    }
    $runSet = @(Get-RunSet $st)
    $next5 = @($st.Order | Where-Object { $st.Where[$_] -notin 'active', 'archived' -and $_ -notin $runSet } | Select-Object -Unique -First 5)
    foreach ($n in @($st.Where.Keys | Where-Object { $st.Where[$_] -in $lanes -and $_ -notin $runSet -and $st.Order -contains $_ })) {
        $to = $(if ($next5 -contains $n) { 'ready' } else { 'backlog' })
        if (Move-ProjectLine $n $to) { $st.Where[$n] = $to; $moved += "$n out of its lane to $(if ($to -eq 'ready') { 'Ready next' } else { 'Backlog' }) (below the 10 that run)" }
    }
    foreach ($n in $runSet) {   # one not overnight-ready yet goes in too: its lane makes it ready first
        if ($st.Where[$n] -in $lanes -or -not (Test-Path (Join-Path $projects "$n\BUILD_SPEC.md"))) { continue }
        $lane = Get-LaneFor $n $st
        if (Move-ProjectLine $n $lane) { $st.Where[$n] = $lane; $moved += "$n to the $lane lane (one of the 10 that run)" }
    }
    foreach ($n in $next5) {
        if ($st.Where[$n] -in $lanes + 'ready') { continue }
        if (Move-ProjectLine $n 'ready') { $st.Where[$n] = 'ready'; $moved += "$n to Ready next (next in the priority order)" }
    }
    foreach ($n in @($st.Where.Keys | Where-Object { $st.Where[$_] -eq 'ready' -and $_ -notin $next5 })) {
        if (Move-ProjectLine $n 'backlog') { $st.Where[$n] = 'backlog'; $moved += "$n back to Backlog (not among the next 5 ranks)" }
    }
    foreach ($m in $moved) { [void]$pipelineMoves.Add("$((Get-Date).ToString('HH:mm')) $m"); Write-Output "pipeline: moved $m" }
    # Remember each lane project's lane, so it comes back to it after a spell in Ready next or Active.
    $homes = Read-HomeLanes; $before = ($homes | ConvertTo-Json -Compress)
    foreach ($n in @($st.Where.Keys | Where-Object { $st.Where[$_] -in $lanes })) { $homes[$n] = $st.Where[$n] }
    if (($homes | ConvertTo-Json -Compress) -ne $before -and -not $DryRun) { $homes | ConvertTo-Json | Set-Content -Path (Join-Path (Split-Path $prioFile) 'home-lanes.json') -Encoding UTF8 }
}
# Built: the planner found nothing buildable outside owner-only steps and wrote "Project built: ..." in REPORT.md (or the
# older "Move <project> to Active?" question, unless the owner answered it with keep building).
function Test-Built($dir) {
    $t = Get-Content (Join-Path $dir 'REPORT.md') -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $t) { return $false }
    $said = $(if ($t -match '(?m)^\W*Project built:') { $true }
        elseif ($t -match '(?ms)^###\s+Q\d+[^\r\n]*Move \S+ to Active\?(.*?)(?=^#|\z)') { $Matches[1] -notmatch '(?i)- \[x\][^\r\n]*(keep|not now|not yet|\bno\b)' }
        else { $false })
    if (-not $said) { return $false }
    # A usable app first (owner, 2026-10-28: "built" projects had a blank page or no working preview): the MVP gate in
    # verify and a preview script, unless BUILD_SPEC says "UI: none".
    $spec = Join-Path $dir 'BUILD_SPEC.md'; $verify = Join-Path $dir 'scripts\verify.ps1'
    $headless = (Test-Path $spec) -and [bool](Select-String -Path $spec -Pattern '^\s*\**UI\**\s*:\s*\**none\b' -Quiet)
    $usable = (Test-Path $verify) -and [bool](Select-String -Path $verify -Pattern 'MVP FLOW OK' -SimpleMatch -Quiet) -and (Test-Path (Join-Path $dir 'scripts\preview.ps1'))
    if (-not $headless -and -not $usable) { return $false }
    $tree = Test-TreeBuilt $dir
    return ($null -eq $tree) -or $tree   # the tree overrules the report line; no tree, the line decides
}
# Built per the build tree: at least 80% of its work nodes (gates aside) done and none an agent could build now (ready or
# active), so what is left waits on the owner's gates or testing (owner, 2026-10-28: projects with nodes left went to
# Active). $null when the project has no tree.
# Statuses as the Agents board shows them (src/tree.ts treeFromHermesModel), not model.json's snapshot: builders log
# nodes in PROGRESS.md, which marks them done or active, and blocked work whose dependencies are all done turns ready
# (2026-10-29: personal-library-website read 1/48 done here while the board showed it built).
function Test-TreeBuilt($dir) {
    $f = Join-Path $dir '.hermes\live-build-tree\model.json'
    if (-not (Test-Path $f)) { return $null }
    try { $model = Get-Content $f -Raw -Encoding UTF8 | ConvertFrom-Json } catch { return $false }
    $nodes = @($model.nodes); $status = @{}; foreach ($n in $nodes) { $status[$n.id] = "$($n.status)" }
    $progress = Get-Content (Join-Path $dir 'PROGRESS.md') -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    foreach ($e in "$progress" -split '\r?\n(?=##\s)') {
        if ($e -notmatch '^##\s+\d{4}-\d{2}-\d{2}(?:[ T]\d{1,2}:\d{2})?\s*[—–-]\s*([A-Za-z][\w-]*?)(?=\s*[—–:]|[ \t]*(?:\r?\n|$))') { continue }
        $id = $Matches[1]; $rest = $e.Substring($Matches[0].Length)
        if (-not $status.ContainsKey($id) -or $status[$id] -eq 'done') { continue }
        $done = ($rest -match '^[\s—–:-]*(done|complete[d]?|verify pass(ed)?|accepted)\b') -or (($e -match '\b(done|complete[d]?|passe?[sd]?|accepted)\b') -and ($e -notmatch '\b(fail(ed|s)?|not done|incomplete)\b'))
        $status[$id] = $(if ($done) { 'done' } else { 'active' })
    }
    $deps = @{}; foreach ($x in @($model.edges)) { if ($x -and $status.ContainsKey($x.from) -and $status.ContainsKey($x.to)) { $deps[$x.to] += @($x.from) } }
    foreach ($n in $nodes) {
        $d = @($deps[$n.id] | Where-Object { $_ })
        if ($status[$n.id] -eq 'blocked' -and $d.Count -and -not @($d | Where-Object { $status[$_] -ne 'done' }).Count) { $status[$n.id] = $(if ($n.kind -eq 'gate') { 'approval' } else { 'ready' }) }
    }
    $work = @($nodes | Where-Object { $_.kind -ne 'gate' })
    if (-not $work.Count) { return $false }
    $done = @($work | Where-Object { $status[$_.id] -eq 'done' }).Count
    return ($done / $work.Count -ge 0.8) -and -not @($work | Where-Object { $status[$_.id] -in 'ready', 'active' }).Count
}
# Preview ports are handed out here, never asked about (2026-10-25: agents asked the owner which port to use, and one
# preview took ntfy's 8783). Every project in the lanes, Ready next or with a preview script gets a "Project previews" row
# before any agent runs: the next port from 8773 that no registry table names and nothing listens on, on the desktop or
# FirstSpark. Agents read their row (shared rule "The preview").
$portRegistry = Join-Path $vault 'Local_Setup\FirstSpark Port Registry.md'
function Get-ListeningPorts {
    $l = @{}
    try { Get-NetTCPConnection -State Listen -ErrorAction Stop | ForEach-Object { $l[[int]$_.LocalPort] = $true } } catch { }
    $out = & $ssh -o BatchMode=yes -o ConnectTimeout=8 FirstSpark 'ss -Htln' 2>$null
    foreach ($line in @($out)) { if ("$line" -match ':(\d+)\s+\S+:\S+\s*$') { $l[[int]$Matches[1]] = $true } }
    return $l
}
function Set-PreviewPorts($listening) {
    if (-not (Test-Path $portRegistry)) { return }
    $raw = [IO.File]::ReadAllText($portRegistry); $eol = $(if ($raw -match "`r`n") { "`r`n" } else { "`n" })
    $lines = New-Object System.Collections.ArrayList; foreach ($l in $raw -split '\r?\n') { [void]$lines.Add($l) }
    $head = -1; for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^##\s+Project previews') { $head = $i; break } }
    if ($head -lt 0) { return }
    $taken = @{}; $has = @{}; $last = -1; $sec = ''
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^##\s') { $sec = $(if ($i -eq $head) { 'previews' } else { '' }) }
        if ($lines[$i] -match '^\|\s*(\d{2,5})\s*\|\s*([^|]*?)\s*\|') { $taken[[int]$Matches[1]] = $true; if ($sec -eq 'previews') { $has[$Matches[2]] = $true; $last = $i } }
    }
    if ($last -lt 0) { return }
    $st = Read-Pipeline
    $want = @(@(Get-RunSet $st) + @($st.Where.Keys | Where-Object { $st.Where[$_] -in 'claude', 'codex', 'hermes', 'ready' -or ($st.Where[$_] -ne 'archived' -and (Test-Path (Join-Path $projects "$_\scripts\preview.ps1"))) }) | Select-Object -Unique)
    $added = @()
    foreach ($n in $want) {
        $spec = Join-Path $projects "$n\BUILD_SPEC.md"
        if ($has[$n] -or -not (Test-Path $spec) -or (Select-String -Path $spec -Pattern '^UI:\s*none' -Quiet)) { continue }
        $p = 8773; while ($taken[$p] -or $listening[$p]) { $p++ }
        $taken[$p] = $true; $has[$n] = $true; $last++; $lines.Insert($last, "| $p | $n |"); $added += "$n=$p"
        [void]$pipelineMoves.Add("$((Get-Date).ToString('HH:mm')) $n gets preview port $p (Port Registry)")
    }
    if (-not $added) { return }
    $tmp = "$portRegistry.$PID.tmp"; [IO.File]::WriteAllText($tmp, ($lines -join $eol), (New-Object Text.UTF8Encoding($false)))
    Move-Item -Force $tmp $portRegistry
    Write-Host "Preview ports assigned: $($added -join ', ')"
}
if (-not $Preflight -and -not $DryRun -and -not $QaOnly -and -not $Resume -and -not $FixOnly -and -not $Project) { Sync-Pipeline; Set-PreviewPorts (Get-ListeningPorts) }
$queue = Set-BuilderModels (Read-Queue)
if ($Project) { $queue = @($queue | Where-Object { $_.Name -eq $Project }); if (-not $queue) { throw "Project $Project is not in Tonight" } }
if ($QaOnly) {
    $qaBase = git -C (Join-Path $projects $Project) rev-parse --verify "$QaFrom^{commit}" 2>$null
    if ($LASTEXITCODE) { throw 'QaFrom must resolve to a local commit' }
    git -C (Join-Path $projects $Project) merge-base --is-ancestor $qaBase HEAD
    if ($LASTEXITCODE) { throw 'QaFrom must be an ancestor of HEAD' }
}

# ---- Top-10 upkeep: the projects agents work on follow the priority order ----
# The top 10 of "## Priority order" (skipping Active and Archived) and every project the owner put in a Tonight lane must
# each be overnight-ready and have a live build tree. Only the owner moves projects between lanes and sections: prep never
# queues or dequeues anything. A tonight project whose verify already passes must advance a slice first, or its run would
# stop at once. Preflight lists this work; a real run hands it to the prep model, prep.json (agent-rules/prep-prompt.md)
# before the lanes start, then re-reads the lanes.
# The standard overnight repo structure (the make-overnight-ready skill's checklist). A project that already has verify.ps1
# but lacks any of this gets a "structure" item, so the prep agent fills in only what is missing.
function Get-MissingStructure($dir) {
    $m = @()
    # Not preview.ps1/.sh: the shared rule has the builder add them once the MVP gate passes, never before (2026-10-25: the
    # prep was sent to add a preview to projects with no working app yet).
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
        elseif (-not (Select-String -Path (Join-Path $dir 'DESIGN.md') -Pattern '^#+\s*Identity' -Quiet)) { $m += 'DESIGN.md Identity section' }   # shared rule "Designed, not default"
        if (-not (Select-String -Path (Join-Path $dir 'scripts\verify.ps1') -Pattern 'screenshot|playwright' -Quiet)) { $m += 'screenshots in verify' }
    }
    return $m
}
function Get-Upkeep($queue) {
    $order = @(); $section = ''; $parked = @{}
    foreach ($line in Get-Content $prioFile -Encoding UTF8) {
        if ($line -match '^##\s+(.*)$') { $section = $Matches[1]; continue }
        if ($section -match '^Priority order' -and $line -match '^\s*\d+\.\s+([A-Za-z0-9._-]+)') { $order += $Matches[1] }
        if ($section -match '^(Active|Archived)' -and $line -match '^\s*-\s+([A-Za-z0-9._-]+)') { $parked[$Matches[1]] = $true }
    }
    $top = @(@(Get-RunSet (Read-Pipeline)) + @($queue | ForEach-Object { $_.Name }) | Select-Object -Unique)
    # Ready next (the next 5 ranks, skipping Active and Archived) gets the same prep, after the top: a lane that frees up
    # mid-run takes one, and its tree, gates and questions must exist before the run so the owner answers them then
    # (2026-10-28: bionic-reading-trainer had verify.ps1 but no tree, joined at 01:34 and raised its approvals mid-run).
    $readyNext = @($order | Where-Object { -not $parked[$_] -and $_ -notin $top } | Select-Object -Unique -First 5)
    $items = @()
    foreach ($name in @($top) + $readyNext) {
        $dir = Join-Path $projects $name
        if (-not (Test-Path "$dir\BUILD_SPEC.md") -and $name -in $readyNext) { continue }   # never a lane pick (Get-Backfill needs a spec)
        if (-not (Test-Path "$dir\BUILD_SPEC.md")) { $items +=[pscustomobject]@{ Project = $name; Action = 'owner'; Why = 'no BUILD_SPEC.md yet, so it cannot be made overnight-ready' }; continue }
        $todo = @(); $why = @()
        if (-not (Test-Path "$dir\scripts\verify.ps1")) { $todo += 'make-overnight-ready'; $why += 'no scripts/verify.ps1' }
        else {
            if (-not (Test-Path "$dir\.hermes\live-build-tree\model.json")) { $todo += 'build-tree'; $why += 'no live build tree' }
            $missing = @(Get-MissingStructure $dir)
            if ($missing) { $todo += 'structure'; $why += 'missing: ' + ($missing -join ', ') }
            # Shared rule "MVP first": until verify carries the MVP gate, the next slice must be a usable MVP (a BUILD_SPEC line "UI: none" opts out).
            $headless = [bool](Select-String -Path "$dir\BUILD_SPEC.md" -Pattern '^\s*\**UI\**\s*:\s*\**none\b' -Quiet)   # an explicit 'UI: none' line; a mention of headless tools doesn't count
            if (-not $headless -and -not (Select-String -Path "$dir\scripts\verify.ps1" -Pattern 'MVP FLOW OK' -SimpleMatch -Quiet)) { $todo += 'mvp'; $why += 'no MVP gate yet: re-plan so the next slice is a usable MVP' }
        }
        if ($todo) { $items += [pscustomobject]@{ Project = $name; Action = $todo -join ' + '; Why = $why -join '; ' } }
    }
    return $items
}
# Who preps (Nightly Runs/prep.json, picked on the board): Desktop Qwen through local-agent.py, or Claude / Codex.
$prepModel = 'hermes:qwen3.8-27b-desktop'
try { $m = (Get-Content (Join-Path $vault 'Nightly Runs\prep.json') -Raw -ErrorAction Stop | ConvertFrom-Json).model } catch { $m = $null }
if ($m -match '^(hermes:qwen3\.8-27b-desktop|hermes:(glm53-flash|deepseek41-flash-pair|qwen38-flash-pair|qwen3\.6-35b-a3b)(-(low|medium|high|xhigh|max))?|claude:[a-z0-9][\w.-]{0,40}|codex(:[a-z0-9][\w.-]{0,60})?)$') { $prepModel = $m }
# Runs inside the prep and slice-advance jobs (jobs see no functions), from the Projects root so no project's deny rules apply.
$prepAgent = @'
param($spec, $dir, $text, $log, $helper, $budget)
$OutputEncoding = New-Object System.Text.UTF8Encoding $false
Set-Location $dir
$model = ($spec -split ':', 2)[1]
$effort = $(if ($spec -like 'hermes:*' -and $model -match '^(.+)-(low|medium|high|xhigh|max)$') { $model = $Matches[1]; $Matches[2] })   # the board's effort menu
if ($spec -like 'hermes:*' -and $model -in 'glm53-flash', 'deepseek41-flash-pair', 'qwen38-flash-pair', 'qwen3.6-35b-a3b') {
    # The Spark pair's models (GLM 5.3 Flash, DeepSeek V4.1 Flash, Qwen 3.8 Flash; whichever is loaded) and Qwen 3.6 35B are reachable only from FirstSpark (key-protected loopback LiteLLM), so prep runs there through Hermes'
    # agents-board-prep profile on FirstSpark's clones: pull them, prep and push there, then the desktop pulls.
    $items = @([regex]::Matches($text, '(?m)^- ([A-Za-z0-9._-]+): ') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique | Where-Object { Test-Path (Join-Path $dir "$_\.git") })
    $spark = '/home/snknitin/Workspace/GIT_ROOT/Projects'
    $sparkText = [regex]::Replace($text, '(?i)(F:\\Vaults\\LLMWiki|E:\\GIT_ROOT\\Projects)((?:\\[^\\\s`"'',;:)]+(?: [A-Z][^\\\s`"'',;:)]*)?)*)', {
        param($m) $(if ($m.Groups[1].Value -like 'F:*') { '/home/snknitin/vaults/LLMWiki' } else { $spark }) + ($m.Groups[2].Value -replace '\\', '/') })
    $sparkText += "`nYOU ARE ON FIRSTSPARK (Linux), in $spark. Each project's gate is ``bash scripts/verify.sh`` (keep verify.ps1 in step with it; you cannot run it here). " +
        "The vault is /home/snknitin/vaults/LLMWiki (it syncs to the desktop). The shared skills are in ~/.hermes/profiles/agents-board-prep/skills/shared/<skill>/SKILL.md; read the one the task names. " +
        "You may edit a project's CLAUDE.md or AGENTS.md, but only the target, scope, order-of-work and stop-condition lines; never its rules, permissions, owner gates or security text. " +
        "Work one project at a time, yourself. Commit only your paths and git push after each project. Report only what happened: name a commit hash only after git log -1 shows it. The runner checks every claim against git.`n"
    $pulls = ($items | ForEach-Object { "if [ -d $_/.git ]; then git -C $_ pull --rebase -q || echo 'PREP PULL FAILED: $_ (FirstSpark clone)'; else git clone -q $(git -C (Join-Path $dir $_) remote get-url origin) $_ || echo 'PREP CLONE FAILED: $_'; fi" }) -join '; '
    $remote = "cd $spark && $pulls; timeout $([int]$budget + 120) ~/.local/bin/hermes -p agents-board-prep chat -m $model$(if ($effort) { " --reasoning $effort" }) --query-file - -Q --yolo --in $spark --max-turns 400 --run-budget $budget"
    $sparkText | & "$env:WINDIR\System32\OpenSSH\ssh.exe" -o BatchMode=yes FirstSpark $remote *>> $log
    $code = $LASTEXITCODE
    foreach ($p in $items) { git -C (Join-Path $dir $p) pull --rebase -q *>> $log }   # bring FirstSpark's prep commits to the desktop
    $global:LASTEXITCODE = $code
} elseif ($spec -like 'hermes:*') {
    $text | & python $helper --base-url http://127.0.0.1:11435/v1 --model qwen3.8-27b-desktop --workdir $dir --budget $budget *>> $log
} elseif ($spec -like 'codex*') {
    $a = @('exec', '--dangerously-bypass-approvals-and-sandbox')
    # codex:<profile>-<level> (codex:default-<level>: the config's own model) sets the reasoning level, unless a profile has that full name.
    if ($model -match '^(.+)-(low|medium|high|xhigh|max)$' -and -not (Test-Path (Join-Path $HOME ".codex\$model.config.toml"))) { $model = $Matches[1]; $a += @('-c', "model_reasoning_effort=$($Matches[2])") }
    if ($model -eq 'default') { $model = $null }
    if ($model -and (Test-Path (Join-Path $HOME ".codex\$model.config.toml"))) { $a += @('-p', $model) } elseif ($model) { $a += @('-m', $model) }
    $text | & codex @a - *>> $log
} else {
    $effort = 'high'
    if ($model -match '^(.+)-(low|medium|high|xhigh|max)$') { $model = $Matches[1]; $effort = $Matches[2] }
    $level = $(if ($model -like 'haiku*') { @() } else { @('--effort', $effort) })   # Haiku has no reasoning level
    $text | & claude -p -n 'Prep' --model $model @level --permission-mode bypassPermissions *>> $log
}
if ($LASTEXITCODE) { throw "Prep agent $spec failed (exit $LASTEXITCODE); see $log" }
'@
# -FixOnly -Project <name>: the board starts this right after the owner answers a question with "fix it": the prep model
# works only that project's owner queue, then the runner reports what git shows. No upkeep scan, no lanes.
if ($FixOnly) {
    $dir = Join-Path $projects $Project
    if (-not (Test-Path "$dir\.git")) { throw "No project $Project" }
    New-Item -ItemType Directory -Force $logDir | Out-Null
    $fixLog = Join-Path $logDir "_fix-$Project.log"
    $before = "$(git -C $dir rev-parse HEAD 2>$null)"
    $fixText = "You are fixing what the owner asked for in one project, now, in its own session (not tonight's target).`n$ownerQueue" +
        "Work only in $dir. Read its CLAUDE.md (or AGENTS.md), PROGRESS.md and DECISIONS.md first. Keep every existing check and the MVP gate green; " +
        "commit only your paths and git pull --rebase then git push. Report only what happened.`n- ${Project}: owner-queue (the open items under '## Queued by the owner (Agents board)' in PROGRESS.md)`n"
    $fixJob = Start-Job -ScriptBlock {
        param($agent, $spec, $dir, $text, $log, $helper, $budget)
        Set-Content "$log.pid" $PID
        & ([scriptblock]::Create($agent)) $spec $dir $text $log $helper $budget
    } -ArgumentList $prepAgent, $prepModel, $projects, $fixText, $fixLog, (Join-Path $PSScriptRoot 'local-agent.py'), ($PrepMinutes * 60)
    if (-not (Wait-Job $fixJob -Timeout ($PrepMinutes * 60 + 300))) {
        $jobPid = Get-Content "$fixLog.pid" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($jobPid) { & taskkill.exe /PID $jobPid /T /F *> $null }
        Stop-Job $fixJob
    }
    Receive-Job $fixJob -ErrorAction Continue; Remove-Job $fixJob -Force
    $new = @(if ($before) { git -C $dir log --format='%h %s' "$before..HEAD" 2>$null })
    $ahead = "$(git -C $dir rev-list --count '@{u}..HEAD' 2>$null)"
    $open = @(Select-String -Path "$dir\PROGRESS.md" -Pattern '^\s*- \[ \] Owner answer' -ErrorAction SilentlyContinue).Count
    Write-Output "fix $Project with ${prepModel}: $(if ($new) { "$($new.Count) new commit(s): $($new -join '; ')" } else { 'no new commit' }); $(if ($ahead -and $ahead -ne '0') { "$ahead NOT pushed" } else { 'pushed' }); $open owner item(s) still open; log: $fixLog"
    exit $(if ($new) { 0 } else { 1 })
}
$upkeep = @(Get-Upkeep $queue)
# ---- Handoff: leftover edits never block a run ----
# Uncommitted work in a tonight project (desktop or FirstSpark clone) is committed on its own pushed wip/handoff-* branch,
# the checkout goes back to clean, and PROGRESS.md gets a HANDOFF entry so tonight's agent reviews and continues it.
# Left alone (and still blocking, with the reason): files edited in the last 10 minutes, a Hermes session still going,
# and anything that looks like a secret.
$handoff = @{}; $leftAlone = @{}; $recheck = @{}; $notBefore = @{}
$waitPattern = 'last 10 minutes|still running'   # left-alone reasons that pass on their own
$secretPattern = '(^|/)(\.env[^/]*|[^/]*\.(pem|key|pfx|p12)|id_rsa[^/]*|[^/]*credential[^/]*|[^/]*secret[^/]*)$'
$handoffBranch = "wip/handoff-$($started.ToString('yyyyMMdd-HHmm'))"
function Add-HandoffNote($dir, $where, $branch, $hash, $pushed) {
    git -C $dir pull --rebase -q 2>$null
    $at = (Get-Date).ToString('yyyy-MM-dd HH:mm')
    $saved = $(if ($pushed) { "pushed branch ``$branch`` (commit $hash)" } else { "branch ``$branch`` (commit $hash), not pushed: it exists only on $where" })
    Add-Content -Path (Join-Path $dir 'PROGRESS.md') -Encoding UTF8 -Value "`n## $at - HANDOFF - open: uncommitted changes on $where before this run were saved on $saved. Start here: review that diff, merge what belongs to the current work and finish it (or say in REPORT.md why not), then add a later entry ``HANDOFF - picked up``."
    git -C $dir add -- PROGRESS.md; git -C $dir commit -q -m "Handoff note: uncommitted work saved on $branch" -- PROGRESS.md 2>$null; git -C $dir push -q 2>$null
}
function Save-DesktopHandoff($name, $dir) {
    $lines = @(git -C $dir status --porcelain 2>$null)
    if (-not $lines) { return }
    $paths = @($lines | ForEach-Object { ($_.Substring(3) -replace '^.* -> ', '').Trim('"') })
    if ($paths | Where-Object { $_ -match $secretPattern }) { $leftAlone[$name] = 'uncommitted changes on the desktop include a file that looks like a secret; commit or remove it yourself'; return }
    # Screenshots a verify run just regenerated are not someone working: hand them off like any older edit.
    if ($paths | Where-Object { $_ -notmatch '(^|/)screenshots/.*\.png$' } | Where-Object { $f = Join-Path $dir $_; (Test-Path $f) -and (Get-Item $f).LastWriteTime -gt (Get-Date).AddMinutes(-10) }) { $leftAlone[$name] = 'uncommitted changes on the desktop edited in the last 10 minutes (someone may be working); left alone'; return }
    $base = git -C $dir branch --show-current
    git -C $dir switch -q -c $handoffBranch 2>$null
    if ($LASTEXITCODE -ne 0) { $leftAlone[$name] = "uncommitted changes on the desktop; could not create $handoffBranch"; return }
    git -C $dir add -A; git -C $dir commit -q -m "WIP handoff: uncommitted changes left on the desktop before the $Kind run" 2>$null
    $hash = git -C $dir rev-parse --short HEAD
    git -C $dir push -q -u origin $handoffBranch 2>$null; $pushed = $LASTEXITCODE -eq 0
    git -C $dir switch -q $base
    Add-HandoffNote $dir 'the desktop' $handoffBranch $hash $pushed
    $handoff[$name] += "desktop edits handed off on $handoffBranch ($hash). "
}
if (-not $Preflight -and -not $DryRun -and -not $QaOnly) {
    # Desktop checkouts only before a real run (a daytime prep must not sweep up the owner's work in progress).
    if (-not $PrepOnly) { foreach ($q in $queue) { $d = Join-Path $projects $q.Name; if (Test-Path "$d\.git") { Save-DesktopHandoff $q.Name $d } } }
    # FirstSpark clones of every tonight project and prep item: a GLM prep, advance or fallback session pulls them, and a dirty
    # clone made that pull fail (2026-10-25). Only a Hermes-lane project is held back by its clone's state.
    $sparkNames = @(@($queue | ForEach-Object { $_.Name }) + @($upkeep | Where-Object { $_.Action -ne 'owner' } | ForEach-Object { $_.Project }) | Select-Object -Unique)
    if ($sparkNames) {
        $sb = "$handoffBranch-spark"
        $script = @(foreach ($n in $sparkNames) {
            "( cd $sparkProjects/$n 2>/dev/null || exit 0; [ -z `"`$(git status --porcelain)`" ] && exit 0"
            "  p=.git/overnight-hermes.pid; if [ -f `$p ] && kill -0 `$(cat `$p) 2>/dev/null; then echo `"$n busy`"; exit 0; fi"
            "  files=`$(git status --porcelain | cut -c4- | sed 's/.* -> //; s/^`"//; s/`"`$//')"
            "  if echo `"`$files`" | grep -Eq '$secretPattern'; then echo `"$n secret`"; exit 0; fi"
            "  for f in `$files; do [ -e `"`$f`" ] && [ -n `"`$(find `"`$f`" -maxdepth 0 -mmin -10)`" ] && { echo `"$n recent`"; exit 0; }; done"
            "  base=`$(git branch --show-current); git switch -q -c $sb || { echo `"$n nobranch`"; exit 0; }"
            "  git add -A && git commit -qm 'WIP handoff: uncommitted changes left on FirstSpark before the $Kind run'; h=`$(git rev-parse --short HEAD)"
            "  if git push -q -u origin $sb 2>/dev/null; then ok=1; else ok=0; fi; git switch -q `$base; echo `"$n saved `$h `$ok`" )"
        }) + '#'
        foreach ($l in @(($script -join "`n") | & $ssh -o BatchMode=yes -o ConnectTimeout=10 FirstSpark 'bash -s' 2>$null)) {
            $f = -split $l; $n = $f[0]; $d = Join-Path $projects $n
            if ($f[1] -eq 'saved') { git -C $d fetch -q 2>$null; Add-HandoffNote $d 'FirstSpark' $sb $f[2] ($f[3] -eq '1'); $handoff[$n] += "FirstSpark edits handed off on $sb ($($f[2])). "; continue }
            $why = switch ($f[1]) {
                'busy' { 'a Hermes session is still running on FirstSpark; its uncommitted changes were left alone' }
                'secret' { 'uncommitted changes on FirstSpark include a file that looks like a secret; commit or remove it yourself' }
                'recent' { 'uncommitted changes on FirstSpark edited in the last 10 minutes; left alone' }
                default { "uncommitted changes on FirstSpark; could not create $sb" }
            }
            if (@($queue | Where-Object { $_.Name -eq $n -and $_.Harness -eq 'hermes' })) { $leftAlone[$n] = $why }
        }
    }
}
$sparkState = @{}
$hermesNames = @($queue | Where-Object { $_.Harness -eq 'hermes' } | ForEach-Object { $_.Name })
if ($hermesNames) {
    $check = ($hermesNames | ForEach-Object { "p=$sparkProjects/$_; if [ -d `$p/.git ]; then echo $_ ok `$(git -C `$p status --porcelain | wc -l); else echo $_ missing; fi" }) -join '; '
    $out = @(& $ssh -o BatchMode=yes -o ConnectTimeout=10 FirstSpark $check 2>$null)
    if (-not $out) { $hermesNames | ForEach-Object { $sparkState[$_] = 'unreachable' } }
    foreach ($l in $out) { $f = -split $l; $sparkState[$f[0]] = $(if ($f[1] -eq 'ok') { "dirty=$($f[2])" } else { 'missing' }) }
    if (-not $Preflight -and -not $DryRun) {   # clone a missing one rather than skip the project for the night
        foreach ($n in @($sparkState.Keys | Where-Object { $sparkState[$_] -eq 'missing' })) {
            $url = git -C (Join-Path $projects $n) remote get-url origin 2>$null
            if ($url) { & $ssh -o BatchMode=yes -o ConnectTimeout=10 FirstSpark "git clone -q $url $sparkProjects/$n" *> $null; if ($LASTEXITCODE -eq 0) { $sparkState[$n] = 'dirty=0'; $handoff[$n] += "cloned on FirstSpark. " } }
        }
    }
}
$prepStatusFile = Join-Path $vault 'Nightly Runs\prep-status.json'
$recordPrep = -not $Preflight -and -not $DryRun -and -not $QaOnly -and -not $NoPrep
$prepReceipt = $null
function Save-PrepReceipt($state, $remaining = @(), $blockers = @(), $reason = '') {
    if (-not $script:prepReceipt) { return }
    $script:prepReceipt.state = $state
    $script:prepReceipt.remaining = @($remaining)
    $script:prepReceipt.blockers = @($blockers)
    $script:prepReceipt.reason = $reason
    if ($state -ne 'running') { $script:prepReceipt.ended = (Get-Date).ToString('o') }
    $tmp = "$prepStatusFile.$PID.tmp"
    [IO.File]::WriteAllText($tmp, ($script:prepReceipt | ConvertTo-Json -Depth 7), (New-Object Text.UTF8Encoding $false))
    Move-Item -LiteralPath $tmp -Destination $prepStatusFile -Force
}
# Already prepped: today's ready receipt is for this exact queue and no project has moved since. Skip the scan (every
# project's verify, ~20 min) instead of repeating it at the scheduled prep and again when the run starts.
$cycleStart = (Get-Date).Date.AddHours(6.5); if ((Get-Date) -lt $cycleStart) { $cycleStart = $cycleStart.AddDays(-1) }
$prepDone = $false
if ($recordPrep -and -not $FixOnly) {
    try { $oldReceipt = Get-Content $prepStatusFile -Raw -ErrorAction Stop | ConvertFrom-Json } catch { $oldReceipt = $null }
    if ($oldReceipt -and $oldReceipt.state -eq 'ready' -and $oldReceipt.heads -and $oldReceipt.ended -and [datetime]$oldReceipt.ended -ge $cycleStart -and
        $oldReceipt.prioritiesHash -eq (Get-FileHash $prioFile -Algorithm SHA256).Hash.ToLowerInvariant()) {
        $prepDone = -not @($queue | Where-Object { "$(git -C (Join-Path $projects $_.Name) rev-parse HEAD 2>$null)" -ne "$($oldReceipt.heads.($_.Name))" })
    }
}
if ($prepDone) {
    Write-Output "prep: already done at $(([datetime]$oldReceipt.ended).ToString('HH:mm')) for this queue and no project changed since; skipping"
    if ($PrepOnly) { exit 0 }
    $recordPrep = $false   # today's ready receipt stays as it is
}
if ($recordPrep) {
    $prepReceipt = @{ state = 'running'; started = (Get-Date).ToString('o'); prioritiesHash = (Get-FileHash $prioFile -Algorithm SHA256).Hash.ToLowerInvariant(); projects = @($queue | ForEach-Object Name); remaining = @(); blockers = @(); reason = '' }
    Save-PrepReceipt 'running' @() @() 'Checking current targets before local preparation'
}
$prepWork = @($upkeep | Where-Object { $_.Action -ne 'owner' })
# The runner's own final verify per project, by commit (Nightly Runs/.verify-cache.json): a project whose target passed at
# the commit it is still on starts with its advance, instead of a builder session that would only find nothing to do.
$verifyCacheFile = Join-Path $vault 'Nightly Runs\.verify-cache.json'
$verifyCache = @{}
try { (Get-Content $verifyCacheFile -Raw -ErrorAction Stop | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $verifyCache[$_.Name] = $_.Value } } catch { }
function Test-CachedPass($name, $dir) {
    $c = $verifyCache[$name]
    return [bool]($c -and $c.verify -eq 'PASS' -and $c.head -and "$(git -C $dir rev-parse HEAD 2>$null)" -eq $c.head -and -not (git -C $dir status --porcelain 2>$null))
}
# Planning moves to prep (owner, 2026-10-28): each lane project whose target already passed at its commit gets its
# advance now, so the gates and questions of its next slices reach the owner before the run, not after 21:00. The run
# then finds a new commit and starts with a builder session; one prep did not reach still plans as its first step.
if ($PrepOnly) {
    foreach ($q in $queue) {
        if (@($prepWork | Where-Object { $_.Project -eq $q.Name }) -or -not (Test-CachedPass $q.Name (Join-Path $projects $q.Name))) { continue }
        $prepWork += [pscustomobject]@{ Project = $q.Name; Action = 'advance'; Why = "its target passed verify at this commit ($($verifyCache[$q.Name].at)); plan the next slices now and ask their owner questions" }
    }
}
# A real run never waits on a serial prep: each tonight project's item becomes its lane's first step, on the lane's own model,
# all lanes at once (2026-10-25: a serial prep kept every lane idle for over two hours). The scheduled prep and Prep now
# (-PrepOnly) still prep everything, tonight projects included, so a prepped project starts building at once.
$laneWork = @{}
if (-not $PrepOnly) {
    foreach ($i in @($prepWork | Where-Object { $q0 = $_.Project; @($queue | Where-Object { $_.Name -eq $q0 }) })) { $laneWork[$i.Project] = $i }
    $prepWork = @($prepWork | Where-Object { -not $laneWork[$_.Project] })
}
$prepHeads = @{}
foreach ($item in $prepWork) { $prepHeads[$item.Project] = "$(git -C (Join-Path $projects $item.Project) rev-parse HEAD 2>$null)" }
if ($recordPrep) { $prepReceipt.projects = @(@($queue | ForEach-Object Name) + @($upkeep | ForEach-Object Project) | Select-Object -Unique); Save-PrepReceipt 'running' $upkeep @() "Preparing the current queue with $prepModel" }
if ($prepWork -and $PrepOnly -and -not $NoPrep) {
    $prepLog = Join-Path $logDir '_prep.log'
    $prepPrompt = (Get-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') -Raw -Encoding UTF8) + "`n" +
        (($prepWork | ForEach-Object { "- $($_.Project): $($_.Action) ($($_.Why))" }) -join "`n") + "`n"
    $prepJob = Start-Job -ScriptBlock {
        param($agent, $spec, $dir, $text, $log, $helper, $budget)
        Set-Content "$log.pid" $PID
        & ([scriptblock]::Create($agent)) $spec $dir $text $log $helper $budget
    } -ArgumentList $prepAgent, $prepModel, $projects, $prepPrompt, $prepLog, (Join-Path $PSScriptRoot 'local-agent.py'), ($PrepMinutes * 60)
    $prepFailed = $false
    if (-not (Wait-Job $prepJob -Timeout ($PrepMinutes * 60 + 90))) {
        $jobPid = Get-Content "$prepLog.pid" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($jobPid) { & taskkill.exe /PID $jobPid /T /F *> $null }
        Stop-Job $prepJob; $prepFailed = $true
    } elseif ($prepJob.State -eq 'Failed') { $prepFailed = $true }
    Receive-Job $prepJob -ErrorAction Continue
    Remove-Job $prepJob -Force
    # The prep agent writes the Prep Report itself, and on 2026-10-23 it named commits that were never made.
    # Append what git actually shows per project, so an invented claim cannot pass for done.
    $facts = foreach ($item in $prepWork) {
        $dir = Join-Path $projects $item.Project; $head = $prepHeads[$item.Project]
        $new = @(if ($head) { git -C $dir log --format='%h %s' "$head..HEAD" 2>$null })
        $ahead = "$(git -C $dir rev-list --count '@{u}..HEAD' 2>$null)"
        $dirty = @(git -C $dir status --porcelain 2>$null).Count
        "- $($item.Project) ($($item.Action)): " + $(if ($new) { "$($new.Count) new commit(s): $($new -join '; ')" } else { 'no new commit' }) +
            $(if ($ahead -and $ahead -ne '0') { "; $ahead commit(s) NOT pushed" } elseif ($new) { '; pushed' } else { '' }) +
            $(if ($dirty) { "; $dirty uncommitted file(s)" } else { '' })
    }
    Add-Content -Path (Join-Path $vault 'Nightly Runs\Prep Report.md') -Encoding UTF8 -Value (@('', "## Checked by the runner ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))", '',
        'What git shows in each project after prep, whatever the report above says.', '') + @($facts))
    $facts | ForEach-Object { Write-Output "prep check: $_" }
    Write-Output "prep: $(if ($prepFailed) { 'FAILED' } else { 'finished' }) for $($prepWork.Count) item(s), $prepModel, log: $prepLog"
    if ($prepFailed) { Save-PrepReceipt 'failed' $prepWork @() "Prep ($prepModel) did not finish; inspect $prepLog" }
    # A failed prep never cancels the night: lanes still run on each project's current target (2026-10-23 ran nothing).
    if ($prepFailed -and $PrepOnly) { exit 1 }
    Sync-Pipeline   # projects the prep just made overnight-ready move to Ready next, or into a lane when top 10
    Set-PreviewPorts (Get-ListeningPorts)
    $queue = Set-BuilderModels (Read-Queue)   # the prep agent may have moved projects into lanes
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
$cliOk = @{ claude = [bool](Get-Command claude -ErrorAction SilentlyContinue); codex = [bool](Get-Command codex -ErrorAction SilentlyContinue); hermes = $true }
$checks = @{}
foreach ($q in $queue) {
    $dir = Join-Path $projects $q.Name; $b = @(); $w = @()
    if (-not (Test-Path $dir)) { $b += "folder $dir not found" }
    else {
        if (-not (Test-Path "$dir\scripts\verify.ps1")) { $w += 'not overnight-ready yet: its lane makes it ready first (make-overnight-ready)' }
        if ($q.Harness -notin 'claude', 'codex', 'hermes') { $b += "unknown tool @$($q.Harness)" }
        elseif (-not $cliOk[$q.Harness]) { $b += "$($q.Harness) CLI not found on this PC" }
        git -C $dir rev-parse '@{u}' *> $null
        if ($LASTEXITCODE -ne 0) { $b += 'no upstream branch, so commits cannot be pushed (add a GitHub remote)' }
        # Someone editing or a Hermes session still going is temporary: the lane re-checks every 5 minutes and starts then.
        if ($leftAlone[$q.Name] -match $waitPattern) { $w += "$($leftAlone[$q.Name]); re-checked every 5 minutes, starts on its own once the edits stop"; $recheck[$q.Name] = $true }
        elseif ($leftAlone[$q.Name]) { $b += $leftAlone[$q.Name] }   # the handoff above saved everything else
        elseif (git -C $dir status --porcelain 2>$null) { $w += 'uncommitted changes on the desktop: saved on a wip/handoff branch and handed to tonight''s agent when the run starts' }
        if ($q.Harness -eq 'hermes') {
            $st = "$($sparkState[$q.Name])"
            if ($st -eq 'unreachable') { $w += 'FirstSpark unreachable over SSH at prep; its sessions retry when it answers' }
            elseif ($st -eq 'missing') { $b += "not cloned on FirstSpark ($sparkProjects/$($q.Name))" }
            elseif ($st -match '^dirty=([1-9]\d*)$' -and -not $leftAlone[$q.Name]) { $w += "$($Matches[1]) uncommitted change(s) on FirstSpark: saved on a wip/handoff branch and handed to tonight's agent when the run starts" }
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
    $pf += '', '## Top 10 upkeep', '', "The scheduled prep and Prep now do the PREP items (make-overnight-ready, build-tree, structure, mvp; never moves lanes). In a run, a Tonight project's PREP item is its lane's first step, on the lane's own model, all lanes at once. OWNER items need you. Advancing to the next slices happens in the run, as soon as a target passes.", '',
        '| Project | Action | Who | Why |', '|---|---|---|---|'
    $pf += $upkeep | ForEach-Object { "| $($_.Project) | $($_.Action) | $(if ($_.Action -eq 'owner') { 'OWNER' } else { 'PREP' }) | $($_.Why) |" }
}
Set-Content -Path $preflightMd -Value $pf -Encoding UTF8
if ($recordPrep) {
    $remaining = @($upkeep | Where-Object { -not $laneWork[$_.Project] })   # tonight's items run as their lanes' first steps
    $blocked = @($queue | ForEach-Object { $n = $_.Name; foreach ($why in @($checks[$n].Blockers)) { if ($why) { @{ project = $n; reason = $why } } } })
    $prepReceipt.warnings = @($queue | ForEach-Object { $n = $_.Name; foreach ($why in @($checks[$n].Warnings)) { if ($why) { "$n`: $why" } } })
    $prepReceipt.heads = @{}; foreach ($q in $queue) { $prepReceipt.heads[$q.Name] = "$(git -C (Join-Path $projects $q.Name) rev-parse HEAD 2>$null)" }   # lets a later prep see nothing moved
    Save-PrepReceipt $(if ($prepFailed -or $remaining.Count -or $blocked.Count) { 'attention' } else { 'ready' }) $remaining $blocked $(if ($prepFailed) { "Prep ($prepModel) did not finish (see $prepLog); lanes run on current targets" } elseif ($remaining.Count -or $blocked.Count) { 'Preparation finished with items still requiring attention' } else { 'Current queue checked and prepared for the scheduled run' })
}
if ($Preflight -or $PrepOnly) { Write-Output ($pf -join "`n"); exit @($checks.Values | Where-Object { $_.Blockers }).Count }

# Every repo in tonight's queue gets a Hermes project (if it has none yet) so its sessions group under it.
# A failure here (FirstSpark down) never stops the run.
try { if (-not $QaOnly) { & (Join-Path $PSScriptRoot 'ensure-projects.ps1') -Projects @($queue | ForEach-Object { $_.Name }) -DryRun:$DryRun | ForEach-Object { Write-Output "projects: $_" } } }
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
    return @{ Hashes = $h; Tests = $tests; Skips = $skips; Head = "$(git -C $dir rev-parse HEAD 2>$null)" }
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
    param($dir, $harness, $model, $prompt, $log, $budget, $ssh, $sparkDir, $sessionName, $isQa, $reviewHead)
    Set-Content -Path "$log.pid" -Value $PID   # so the runner can end this job's whole process tree at the end time
    $OutputEncoding = New-Object System.Text.UTF8Encoding $false
    Set-Location $dir
    # Its own temp folder: pytest keeps one "pytest-of-<user>\pytest-current" link per temp folder, and side-by-side runs
    # on the desktop fail with WinError 5 on it (2026-10-26: three projects' final verify, and builders chasing it as a bug).
    # A short name: deep pytest paths under a long one pass Windows' 260-character limit (WinError 3).
    $env:TEMP = $env:TMP = (New-Item -ItemType Directory -Force (Join-Path ([IO.Path]::GetTempPath()) "ov$PID")).FullName
    if (-not $isQa) { $env:OVERNIGHT_RUN = '1' }   # turns on the project's Stop-hook verify gate (Claude); QA must be free to end on a failing verify
    switch ($harness) {
        'codex' {
            # @codex:<name> is a profile when ~/.codex/<name>.config.toml exists (model + reasoning effort), else a model id.
            # <profile>-<effort> (the board's effort menus; default-<effort>: config.toml's own model) sets the effort on
            # top of that profile, unless a profile has that full name.
            $a = @('exec', '--dangerously-bypass-approvals-and-sandbox')
            if ($model -match '^(.+)-(low|medium|high|xhigh|max)$' -and -not (Test-Path (Join-Path $HOME ".codex\$model.config.toml"))) { $model = $Matches[1]; $a += @('-c', "model_reasoning_effort=$($Matches[2])") }
            if ($model -eq 'default') { $model = $null }
            if ($model -and (Test-Path (Join-Path $HOME ".codex\$model.config.toml"))) { $a += @('-p', $model) } elseif ($model) { $a += @('-m', $model) }
            $prompt | & codex @a - *>> $log
        }
        'hermes' {
            if (-not $model) { $model = 'deepseek41-flash-pair' }   # the Spark pair's default lane (SecondSpark + ThirdSpark)
            # "<model>-<effort>" (the board's effort menus) sets Hermes' --reasoning; no suffix keeps ~/.hermes/config.yaml's.
            $effort = $(if ($model -match '^(.+)-(low|medium|high|xhigh|max)$') { $model = $Matches[1]; $Matches[2] })
            $m = "--provider custom:local-models --base-url http://127.0.0.1:4000/v1 -m $model$(if ($effort) { " --reasoning $effort" })"
            # .git/overnight-hermes.pid: a session cut off from this side (dropped SSH) can still be running on FirstSpark;
            # never start a second one in the same repo (SPARK_BUSY makes the runner wait and try again).
            if ($isQa -and $model -in 'qwen3.6-35b-a3b', 'spark-fast') {
                # Dedicated local profile: no subscription plugins, inherited keys, or cloud fallback.
                $m = 'python3 ~/.agents-board/local-agent.py --base-url http://127.0.0.1:8000/v1 --model spark-fast --workdir {0} --budget {1}' -f $sparkDir, $budget
                if ($isQa) { $m += ' --qa-result' }
            } else { $m = '~/.local/bin/hermes chat --query-file - -Q --yolo --in {0} --run-budget {1} {2}' -f $sparkDir, $budget, $m }
            # Leftovers in the FirstSpark clone made 'git pull --rebase' fail, so the session never started (2026-10-25: QA of
            # paper-logbook and mock-interview). QA reviews the exact commit, so its leftovers go to a pushed wip branch; a builder
            # continues from them, so they become a WIP commit. A file that looks like a secret is never committed.
            $tidy = 'if git status --porcelain | grep -q .; then if git status --porcelain | grep -Eiq ''(\.env|\.pem|\.key|id_rsa|credential|secret)''; then echo SPARK_DIRTY_SECRET; exit 7; fi; '
            $tidy += $(if ($isQa) { 'b=wip/qa-handoff-$(date +%Y%m%d-%H%M%S); git switch -q -c $b && git add -A && git commit -qm ''WIP left in the FirstSpark clone before QA, saved by the runner'' && git push -q -u origin $b 2>/dev/null; git switch -q -; echo SPARK_HANDOFF $b; fi; ' }
                else { 'git add -A && git commit -qm ''WIP: unfinished work left by the previous session, saved by the runner; continue from it''; echo SPARK_WIP_COMMITTED; fi; ' })
            $headCheck = $(if ($isQa) { '[ $(git rev-parse HEAD) = {0} ] || {{ echo SPARK_HEAD_MISMATCH; exit 6; }}; ' -f $reviewHead } else { '' })
            $remote = 'test -d {0} || {{ echo SPARK_MISSING; exit 3; }}; cd {0} || exit 3; p=.git/overnight-hermes.pid; if [ -f $p ] && kill -0 $(cat $p) 2>/dev/null; then echo SPARK_BUSY; exit 4; fi; echo $$ > $p; trap ''rm -f $p'' EXIT; {3}git pull --rebase -q || exit 5; {2}{1}; rc=$?; echo SPARK_GIT dirty=$(git status --porcelain | wc -l) unpushed=$(git rev-list --count @{{u}}..HEAD); exit $rc' -f $sparkDir, $m, $headCheck, $tidy
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
    $rows[$q.Name] = [ordered]@{ Project = $q.Name; Harness = "$($q.Harness)$(if ($q.Model) { ':' + $q.Model })"; Verify = '-'; Git = '-'; Commits = 0; Note = "$($handoff[$q.Name])";
        Minutes = 0; TestsBefore = ''; TestsAfter = ''; TimedOut = $false; UsageLimit = $false }
    if ($checks[$q.Name].Blockers) { $rows[$q.Name].Note += 'skipped by preflight: ' + ($checks[$q.Name].Blockers -join '; ') }
    elseif ($DryRun) { $rows[$q.Name].Note = 'dry run: would run now' }
    else { [void]$pending.Add($q) }
}
$integrity = @{}   # tamper baseline, taken just before the lanes start
foreach ($q in $pending) { $integrity[$q.Name] = Get-Integrity (Join-Path $projects $q.Name); $rows[$q.Name].TestsBefore = $integrity[$q.Name].Tests }

function Complete-Run($q, $row) {
    $dir = Join-Path $projects $q.Name
    $log = Join-Path $logDir "$($q.Name).log"
    $text = $(if (Test-Path $log) { Get-Content $log -Raw -Encoding UTF8 } else { '' })
    # *>> appends UTF-16 to a UTF-8 file: drop the NULs first, or "\n\0=== session" never splits and an earlier session's
    # "resets 12am" parked Claude until the next midnight (2026-10-28, 04:55)
    $text = $text -replace "`0", ''
    $text = ($text -split '(?m)^=== session \d+ ')[-1]   # only this session's output; earlier sessions were already read
    if ($q.Harness -ne 'hermes' -and (Test-LimitHit $text)) {
        $script:limitUntil[$q.Harness] = Get-LimitReset $text
        $row.Note += "$($q.Harness) usage limit at $((Get-Date).ToString('HH:mm')), resumed after $($script:limitUntil[$q.Harness].ToString('HH:mm')). "; $row.UsageLimit = $true
        Save-RunState
    }
    if ($q.Harness -eq 'hermes') {
        if ($text -match 'SPARK_MISSING') { $row.Note += "not cloned on FirstSpark at $sparkProjects. " }
        if ($text -match 'SPARK_GIT dirty=(\d+) unpushed=(\d+)') { $row.Note += "FirstSpark: $($Matches[1]) uncommitted, $($Matches[2]) unpushed. " }
        git -C $dir pull --rebase --autostash -q 2>$null   # bring Hermes's pushed commits here for the gate
    }
    if ($row.Note -notlike "*log: $log*") { $row.Note += "log: $log. " }
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
# Only the tools' own limit messages, and only at the end of the output, where a tool prints them before it exits: Claude
# "You've hit your session limit - resets 2:30am", Codex "You've hit your usage limit ... try again in ...". Matching the
# whole log parked Codex for an hour at a time on project text like "rate-limited" (2026-10-24/25; no log ever ended in
# a real Codex limit).
# The apostrophe often arrives garbled ("You\ufffd\ufffd\ufffdve"), so anything that is not a letter may stand in for it
# (2026-10-26: Codex's weekly limit went unnoticed and its lanes were closed as "no work left").
$limitHit = "(?i)you\W{0,6}ve hit your (?:session |usage |weekly |daily )?limit|chatgpt\.com/settings/usage|claude ai usage limit reached|usage limit reached|rate_limit_exceeded|insufficient_quota"
function Test-LimitHit($text) { $t = "$text"; return $t.Substring([Math]::Max(0, $t.Length - 1500)) -match $limitHit }
# The tool itself would not start (a broken install or PATH): the work never ran, so it is never "nothing to do".
function Test-ToolMissing($text) { $t = "$text"; return $t.Substring([Math]::Max(0, $t.Length - 1500)) -match '(?i)is not recognized as the name of a cmdlet|CommandNotFoundException|: command not found' }
# The same for a dropped connection: only at the end of the output, where the tool reports it as it stops (2026-10-25:
# paper-logbook's own text "calendar/plan fetch failed" restarted it every few minutes).
function Test-NetError($text) { $t = "$text"; return $t.Substring([Math]::Max(0, $t.Length - 1500)) -match $netError }
# Every lane decision, one line each, in <run log folder>\_decisions.log: what ended, what the runner did next, and why.
function Write-Decision($name, $what) { Add-Content -Path (Join-Path $logDir '_decisions.log') -Value "$((Get-Date).ToString('HH:mm:ss')) $name`: $what" -Encoding UTF8 }
function Get-LimitReset($text) {
    $now = Get-Date
    # Codex's weekly limit names a date: "try again at Nov 1st, 2026 11:40 AM" (the line may wrap after "again").
    if ($text -match '(?i)try again\s+at\s+([a-z]{3})[a-z]*\.?\s+(\d{1,2})(?:st|nd|rd|th)?,?\s+(\d{4})\s+(\d{1,2}):(\d{2})\s*(am|pm)') {
        $at = [datetime]::ParseExact("$($Matches[1]) $($Matches[2]) $($Matches[3]) $($Matches[4]):$($Matches[5]) $($Matches[6].ToUpper())", 'MMM d yyyy h:mm tt', [Globalization.CultureInfo]::InvariantCulture)
        return $at.AddMinutes(2)
    }
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
    param($agent, $spec, $root, $text, $log, $helper)
    Set-Content -Path "$log.pid" -Value $PID
    & ([scriptblock]::Create($agent)) $spec $root $text $log $helper 1800
}
# The model that plans a lane's next slices (or does its prep item): the lane's own builder model, which knows the project
# best, falling back like a session does when its harness is parked; the prep model only when nothing else is free.
function Get-AdvanceSpec($q) {
    $use = Get-SessionHarness $q
    if (-not $use) { return $prepModel }
    $model = $(if ($use -eq $q.Harness) { $q.Model })
    switch ($use) {
        'claude' { return "claude:$(if ($model) { $model } else { 'opus' })" }
        'codex' { return $(if ($model) { "codex:$model" } else { 'codex' }) }
        default { return "hermes:$(if (($model -replace '-(low|medium|high|xhigh|max)$', '') -in 'glm53-flash', 'deepseek41-flash-pair', 'qwen38-flash-pair', 'qwen3.6-35b-a3b') { $model } else { 'deepseek41-flash-pair' })" }
    }
}
function Start-Advance($q, $action = 'advance', $why = "tonight's target passed during the run") {
    Update-Choices $q
    $name = $q.Name; $dir = Join-Path $projects $name
    $issues = @(Compare-Integrity $integrity[$name] (Get-Integrity $dir))   # checked before the advance re-baselines it
    if ($issues) {
        # A builder changed a file that judges its work (verify, stop gate, settings): put the last good version back and keep
        # going, instead of dropping the project for the night. The morning report still says SUSPECT and the diff stays in git.
        $now = Get-Integrity $dir
        $changed = @($guarded | Where-Object { $integrity[$name].Hashes[$_] -and $now.Hashes[$_] -ne $integrity[$name].Hashes[$_] })
        $restores[$name] = 1 + [int]$restores[$name]
        if ($changed -and $restores[$name] -le 2 -and $integrity[$name].Head) {
            git -C $dir checkout $integrity[$name].Head -- @($changed) 2>$null
            git -C $dir commit -q -m "Restore $($changed -join ', '): changed by a builder session (the runner keeps the judge fixed overnight)" -- @($changed) 2>$null
            git -C $dir push -q 2>$null
            $rows[$name].Note += "SUSPECT: a session changed $($changed -join ', '); restored at $((Get-Date).ToString('HH:mm')) and kept building. "
            Write-Decision $name "restored $($changed -join ', '): builder session"
            [void]$pending.Add($q); return   # its target must now pass the real verify: a builder session, not the planner
        } elseif ($changed) { $rows[$name].Note += "not advanced: SUSPECT ($($issues -join '; ')) again after two restores. "; Start-Backfill $rows[$name] $q.Harness $name; return }
        else { $rows[$name].Note += "SUSPECT: $($issues -join '; ') (flagged for the morning; kept building). " }
    }
    $now = Get-Date
    if ($action -eq 'advance') { $advances[$name] = 1 + [int]$advances[$name] }
    $spec = Get-AdvanceSpec $q
    $text = (Get-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') -Raw -Encoding UTF8) +
        "`n- ${name}: $action ($why. The lanes are already going: do only this item, quickly. Read the project's PROGRESS.md '## Now' handoff and REPORT.md first: they hold what its builder learned. Add your line to the Prep Report without removing other projects' lines.)`n"
    $log = Join-Path $logDir "$name.advance.txt"; Remove-Item "$log.pid" -ErrorAction SilentlyContinue
    Add-Content -Path $log -Value "=== $action $((Get-Date).ToString('HH:mm')) on $spec ===" -Encoding UTF8
    $job = Start-Job -ScriptBlock $advanceWorker -ArgumentList $prepAgent, $spec, $projects, $text, $log, (Join-Path $PSScriptRoot 'local-agent.py')
    $running[$job.Id] = @{ Job = $job; Q = $q; Start = $now; Head = (git -C $dir rev-parse HEAD 2>$null); Advance = $true; Action = $action; Why = $why; Spec = $spec; PidFile = "$log.pid" }
}

# A lane's first step: its prep item (make-overnight-ready, mvp, build-tree, structure), or its advance when its target
# already passed at this commit; none means a builder session.
function Set-FirstStep($q) {
    $dir = Join-Path $projects $q.Name
    $item = $laneWork[$q.Name]
    if (-not $item) { $item = @(Get-Upkeep @($q) | Where-Object { $_.Project -eq $q.Name -and $_.Action -ne 'owner' })[0] }
    if ($item) { $firstStep[$q.Name] = @{ Action = $item.Action; Why = $item.Why } }
    elseif (Test-CachedPass $q.Name $dir) { $firstStep[$q.Name] = @{ Action = 'advance'; Why = "verify passed at this commit in the runner's last check ($($verifyCache[$q.Name].at))" } }
}

# Real progress since $from: a commit that changes more than the bookkeeping files every session rewrites.
function Test-Progress($dir, $from) {
    $head = git -C $dir rev-parse HEAD 2>$null
    if (-not $from -or -not $head -or $head -eq $from) { return $false }
    return [bool](@(git -C $dir diff --name-only $from $head 2>$null) | Where-Object { $_ -notmatch '(^|/)(REPORT|PROGRESS|DECISIONS)\.md$' })
}

# A session that ended mid-work (a crash, a model repetition loop, a context-compression timeout) leaves uncommitted
# changes: on FirstSpark the session's SPARK_GIT line says so, on the desktop git status does. That is not "target done".
function Test-Leftover($dir, $harness, $text) {
    if ($harness -eq 'hermes') { return "$text" -match 'SPARK_GIT dirty=[1-9]' }
    return [bool](git -C $dir status --porcelain 2>$null)
}

# A lane whose project has nothing buildable left takes the next overnight-ready project (scripts/verify.ps1, clean
# checkout, cloned on FirstSpark for Hermes) from the priority order, then Ready next, for the rest of the night on the
# same harness, so no lane idles. Nothing moves in Project Priorities.md; the report says which project filled in.
# The owner steered it on the board (an open "## Owner direction" entry in DECISIONS.md) after its lane finished tonight.
function Test-OpenDirection($dir) {
    $t = Get-Content (Join-Path $dir 'DECISIONS.md') -Raw -ErrorAction SilentlyContinue
    if (-not $t -or $t -notmatch '(?ms)^## Owner direction \(from the Agents board\)[ \t]*\r?$(.*?)(?=^## |\z)') { return $false }
    return $Matches[1] -match '(?m)^### .+ \S+ open[ \t]*\r?$'
}

function Get-Backfill($harness) {
    $st = Read-Pipeline
    foreach ($n in @(Get-RunSet $st)) {   # strictly the 10 that run, in priority order (owner, 2026-10-25), never one further down
        if ($st.Where[$n] -in 'active', 'archived' -or $rows[$n]) { continue }   # already running tonight, built, or out
        $d = Join-Path $projects $n
        if (-not (Test-Path "$d\.git") -or -not (Test-Path "$d\BUILD_SPEC.md") -or (git -C $d status --porcelain 2>$null)) { continue }   # no spec yet, or someone is working in it
        if ($harness -eq 'hermes') {   # its FirstSpark clone: made now if missing
            $url = git -C $d remote get-url origin 2>$null
            & $ssh -o BatchMode=yes -o ConnectTimeout=8 FirstSpark "test -d $sparkProjects/$n/.git || git clone -q $url $sparkProjects/$n" *> $null
            if ($LASTEXITCODE -ne 0) { continue }
        }
        return [pscustomobject]@{ Name = $n; Harness = $harness; Model = $null; Qa = $null }
    }
}

# A lane project its planner left with nothing to build, that made no real commit all night (only REPORT, PROGRESS or
# DECISIONS), goes to Active, so the next rank takes its lane tonight and the prep readies it for the next run (owner,
# 2026-10-28: paper-logbook held a lane for two bookkeeping commits). The owner moves it back to a lane on the board.
function Move-Stalled($name, $row) {
    if (-not [int]$sessions[$name]) { return }   # never a project that only just joined a lane: it has not built anything yet
    if (-not (Test-TreeBuilt (Join-Path $projects $name))) { return }   # nodes left to build: it keeps its lane for the next run
    if (Test-Progress (Join-Path $projects $name) $heads[$name]) { return }
    if (-not (Move-ProjectLine $name 'active')) { return }
    $row.Note += "stalled: no real work tonight; moved to Active. "
    [void]$pipelineMoves.Add("$((Get-Date).ToString('HH:mm')) $name to Active (stalled: no real work tonight)")
    Write-Decision $name 'stalled: no real work tonight, moved to Active'
}

# Hand a lane to the next overnight-ready project for the rest of the run (its row, HEAD and tamper baseline as at start).
function Start-Backfill($row, $harness, $from) {
    if (($deadline - (Get-Date)).TotalSeconds -lt $minSession) { return }
    # A lane whose harness is parked on a usage limit hands the next project to a harness that is working now.
    if (Test-Parked $harness -and -not (Test-Parked 'hermes')) { $harness = 'hermes' }   # the fallback is always Hermes (owner, 2026-10-26)
    # A project the owner steered after it finished tonight comes back first, on this lane, with fresh counters.
    $busy = @($running.Values | ForEach-Object { if ($_.Q) { $_.Q.Name } }) + @($pending | ForEach-Object { $_.Name })
    foreach ($q0 in @($script:queue)) {
        $n0 = $q0.Name; $d0 = Join-Path $projects $n0
        if ($n0 -in $busy -or $steered[$n0] -ge 2 -or -not (Test-OpenDirection $d0) -or (git -C $d0 status --porcelain 2>$null)) { continue }
        $steered[$n0] = 1 + [int]$steered[$n0]; $advances[$n0] = 0; $idle[$n0] = 0; $hangs[$n0] = 0; $leftovers[$n0] = 0
        $q1 = [pscustomobject]@{ Name = $n0; Harness = $harness; Model = $null; Qa = $q0.Qa }
        $row.Note += "its $harness lane went back to $n0 (owner note on the board) at $((Get-Date).ToString('HH:mm')). "
        $rows[$n0].Note += "back at $((Get-Date).ToString('HH:mm')) for the owner's note. "
        Write-Decision $n0 "owner note on the board: back on $harness"
        [void]$pending.Add($q1); Save-RunState; return
    }
    # Mid-run too: a project that finished and wrote "Project built:" goes to Active, so the next rank joins the 10 and takes
    # this lane (2026-10-25: personalized-adhd was built at 22:20 and its spot stayed empty all night).
    $null = Sync-Pipeline
    $b = Get-Backfill $harness
    if (-not $b) { $row.Note += "no project left in the priority order for its $harness lane. "; return }
    $row.Note += "its $harness lane went to $($b.Name) at $((Get-Date).ToString('HH:mm')). "
    if (Move-ProjectLine $b.Name $harness) { [void]$pipelineMoves.Add("$((Get-Date).ToString('HH:mm')) $($b.Name) to Tonight $harness (filled $from's lane)") }
    $script:queue += $b; $bd = Join-Path $projects $b.Name
    $rows[$b.Name] = [ordered]@{ Project = $b.Name; Harness = $b.Harness; Verify = '-'; Git = '-'; Commits = 0; Note = "filled $from's lane at $((Get-Date).ToString('HH:mm')) (not in tonight's lanes). ";
        Minutes = 0; TestsBefore = ''; TestsAfter = ''; TimedOut = $false; UsageLimit = $false }
    $integrity[$b.Name] = Get-Integrity $bd; $rows[$b.Name].TestsBefore = $integrity[$b.Name].Tests
    $heads[$b.Name] = "$(git -C $bd rev-parse HEAD 2>$null)"; Set-FirstStep $b; [void]$pending.Add($b); Save-RunState
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

# Each project's HEAD as the lanes start: the run's commits are exactly <before>..<after>, so the Agents board's Review tab
# never has to guess from times (Hermes's commits reach the desktop when its session ends, after the gate's pull).
$heads = [ordered]@{}
foreach ($q in $pending) { $h = git -C (Join-Path $projects $q.Name) rev-parse HEAD 2>$null; if ($h) { $heads[$q.Name] = "$h" } }
if ($QaOnly) { $heads[$Project] = "$qaBase"; $pending.Clear() }
$qaResults = [ordered]@{}   # QA per project: @{ state = running|pass|findings|skipped|failed; findings; reason }, read by the Agents board
$runPhase = 'lanes'   # read by the Agents board: lanes = agents working, wrapup = QA and the runner's verify
$running = @{}; $limitUntil = @{}; $advances = @{}; $sessions = @{}; $restores = @{}; $hangs = @{}; $idle = @{}; $steered = @{}; $planLimits = @{}; $waitNet = @{}; $nextNetCheck = @{}; $noSpark = @{}; $leftovers = @{}
foreach ($n in @($recheck.Keys)) { $notBefore[$n] = (Get-Date).AddMinutes(5) }
foreach ($n in @($sparkState.Keys)) { if ($sparkState[$n] -eq 'unreachable') { $waitNet[$n] = $true } }   # starts when FirstSpark answers
# A resumed run keeps the usage limits the cut-off run had hit.
$resumedQa = @{}
if ($Resume -and $state.qa) { foreach ($p in $state.qa.PSObject.Properties) { if ("$($p.Value.state)" -ne 'running') { $resumedQa[$p.Name] = $true }; $qaResults[$p.Name] = @{ state = "$($p.Value.state)"; findings = [int]$p.Value.findings; reason = "$($p.Value.reason)" } } }
if ($Resume -and $state.limitUntil) { foreach ($p in $state.limitUntil.PSObject.Properties) { $limitUntil[$p.Name] = [datetime]::Parse($p.Value) } }
# limitUntil (harnesses parked on a usage limit, as ISO strings) is also read by the Agents board's Usage limits panel.
# Each lane's state in the runner's own words, for the Agents board (it cannot see the runner's queue): building, planning,
# waiting (and for what), queued, or finished (and why).
function Get-LaneStates {
    $lanes = @{}
    foreach ($r in @($running.Values)) { if ($r.Q) { $lanes[$r.Q.Name] = $(if ($r.Qa) { @{ state = 'reviewing'; why = "QA of its finished slice on $($r.Plan.Spec)" } } elseif ($r.Advance) { @{ state = 'planning'; why = $(if ($r.Action -eq 'advance') { "planning its next slices on $($r.Spec)" } else { "$($r.Action) on $($r.Spec)" }) } } else { @{ state = 'building'; why = "on $($r.Q.Harness)" } }) } }
    foreach ($q in @($pending)) {
        if (-not $q -or $lanes[$q.Name]) { continue }
        $use = Get-SessionHarness $q
        $lanes[$q.Name] = $(if ($notBefore[$q.Name] -and (Get-Date) -lt $notBefore[$q.Name]) { @{ state = 'waiting'; why = $(if ($recheck[$q.Name]) { 'someone is editing it; starts once the edits stop' } else { 'its last Hermes session is still finishing' }) } }
            elseif (-not $use) { @{ state = 'waiting'; why = "$($q.Harness) usage limit, back at $($limitUntil[$q.Harness].ToString('HH:mm'))" } }
            elseif ($waitNet[$q.Name]) { @{ state = 'waiting'; why = "network ($use)" } }
            else { @{ state = 'queued'; why = 'starts in a moment' } })
    }
    foreach ($name in @($rows.Keys)) {
        if ($lanes[$name]) { continue }
        $note = "$($rows[$name].Note)"
        $went = $(if ($note -match 'lane went to ([A-Za-z0-9._-]+)') { "; its lane went to $($Matches[1])" } else { '' })
        $lanes[$name] = @{ state = 'finished'; why = $(if ($note -match 'stalled: no real work') { "stalled: no real work tonight, moved to Active$went" }
            elseif ($note -match 'moved to Active') { "built (only owner steps left), moved to Active$went" }
            elseif ($note -match 'planner made no new slice') { "its planner made no new slice$went" }
            elseif ($note -match 'could not make it overnight-ready') { "could not be made overnight-ready$went" }
            elseif ($note -match 'no buildable node left') { "nothing left to build outside owner-only steps$went" }
            elseif ($note -match 'SUSPECT') { 'SUSPECT: its verify or tests changed; check the diff' }
            elseif ($note -match 'skipped[^.]*') { $Matches[0] } elseif ($note -match 'not run[^.]*') { $Matches[0] } else { 'done for this run' }) }
    }
    return $lanes
}
function Save-RunState {
    $parked = @{}; foreach ($k in @($limitUntil.Keys)) { $parked[$k] = $limitUntil[$k].ToString('o') }
    @{ kind = $Kind; phase = $runPhase; started = $started.ToString('o'); until = $deadline.ToString('o'); heads = $heads; limitUntil = $parked; qa = $qaResults; lanes = $(if ($runPhase -eq 'lanes') { Get-LaneStates } else { @{} }) } | ConvertTo-Json -Depth 5 | Set-Content -Path $stateFile -Encoding UTF8
}
function Test-Parked($tool) { return [bool]($limitUntil[$tool] -and (Get-Date) -lt $limitUntil[$tool]) }
# The harness a project's next session runs on. A Claude project whose harness is parked on its usage limit runs on Codex,
# or on Hermes (local, no quota) when Codex is parked too, instead of idling until the reset; its next session goes back
# to Claude once that has reset. A Codex project runs on Hermes while Codex is parked. Never another account of the same tool.
# $null = wait. (test-fallback.ps1 checks this.)
function Get-SessionHarness($q) {
    if (-not (Test-Parked $q.Harness)) { return $q.Harness }
    $next = $(if ($q.Harness -ne 'hermes') { @('hermes') } else { @() })   # the fallback is always Hermes (owner, 2026-10-26)
    return @($next) | Where-Object { -not (Test-Parked $_) -and -not ($_ -eq 'hermes' -and $noSpark[$q.Name]) } | Select-Object -First 1
}
$qaPromptFile = Join-Path $vault 'Nightly Runs\agent-rules\qa-prompt.md'
$qaAllowed = 'REPORT.md', 'FEEDBACK.md', 'BUILD_SPEC.md', 'PROGRESS.md', 'DECISIONS.md'   # BUILD_SPEC/PROGRESS only to revert a "done" mark that has no evidence; DECISIONS.md is bookkeeping (2026-10-25: two QA results were thrown away for logging there)
function Format-Qa($r) {
    if ($r.state -eq 'pass') { return 'pass' }
    if ($r.state -eq 'findings') { return $(if ([int]$r.findings -eq 1) { '1 finding' } else { "$($r.findings) findings" }) }
    return "$($r.state): $("$($r.reason)" -replace '\s+', ' ')"
}
function Set-Qa($name, $state, $reason = '', $findings = 0, $by = '') {
    $script:qaResults[$name] = @{ state = $state; findings = $findings; reason = $reason }
    if ($state -ne 'running') { $script:rows[$name].Note = "$($script:rows[$name].Note.TrimEnd()) QA $(Format-Qa $script:qaResults[$name])$(if ($by) { " (on $by)" }). " }   # the gate's note may end in 'log: <path>' without a space
    if (-not $DryRun) { Save-RunState }
}
$qaPromptText = $(if (Test-Path $qaPromptFile) { Get-Content $qaPromptFile -Raw -Encoding UTF8 } else { '' })
$qaFrom = @{}   # per project: the commit QA last reviewed up to (a slice at a time during the lanes, the rest at the end)
# QA of one range of a project's commits, on a QA plan (another model family than the builder). The log keeps every
# attempt, each after its own "=== QA" line, and only the last attempt is read.
function Start-QaJob($q, $plan, $from) {
    $name = $q.Name; $dir = Join-Path $projects $name; $fam = $plan.Family
    $suffix = $(if ($plan.FallbackUsed) { 'qa-fallback' } else { 'qa' })
    $log = Join-Path $logDir "$name.$suffix.txt"
    Remove-Item "$log.pid" -ErrorAction SilentlyContinue
    # FirstSpark reviews origin's HEAD: bring the desktop level with origin first (2026-10-28: origin had a FirstSpark commit
    # the desktop lacked, so jobs-search-and-apply-tool's final QA stopped at SPARK_HEAD_MISMATCH).
    if ($fam -eq 'hermes') { git -C $dir pull --rebase --autostash -q 2>$null; git -C $dir push -q 2>$null }
    $head = "$(git -C $dir rev-parse HEAD 2>$null)"
    Add-Content -Path $log -Value "=== QA $((Get-Date).ToString('HH:mm')) of $from..$head on $($plan.Spec) ===" -Encoding UTF8
    $shots = $(if ($fam -eq 'hermes') { "/home/snknitin/.agents-board/qa/$stamp/$name" } else { Join-Path $logDir "_qa\$name" })
    $platform = $(if ($fam -eq 'hermes') { 'You are on Linux: use scripts/verify.sh and scripts/preview.sh when present. If absent, reproduce verify.ps1 steps with the available Linux commands; do not invoke a Windows path or claim unavailable checks passed.' } else { '' })
    $text = $qaPromptText + "`n---`nThis QA session: project folder $name, date for the REPORT.md section $((Get-Date).ToString('yyyy-MM-dd HH:mm')), the builder's commits to review are $from..$head (git log -p that range), put screenshots in $shots (outside the repo, never commit them). $platform`n"
    $sessionName = "$name $([char]0x00B7) QA of $($started.ToString('MMM d', [Globalization.CultureInfo]::InvariantCulture))"
    $job = Start-Job -ScriptBlock $worker -ArgumentList $dir, $fam, $plan.Model, $text, $log, ($QaMinutes * 60), $ssh, "$sparkProjects/$name", $sessionName, $true, $head
    Set-Qa $name 'running'
    return @{ Job = $job; Q = $q; Plan = $plan; Start = Get-Date; Head = $head; Dirty = @(git -C $dir status --porcelain 2>$null); Log = $log; From = $from; Qa = $true; PidFile = "$log.pid" }
}
# A QA that wrote its review into REPORT.md but never printed its "QA RESULT:" line still counts: its last "## QA" section,
# when it got as far as verify and a findings list, gives the result (2026-10-24: whole reviews were thrown away for it).
function Get-QaFromReport($dir, $from) {
    if (@(git -C $dir diff --name-only $from HEAD 2>$null) -notcontains 'REPORT.md') { return $null }
    $t = "$(Get-Content (Join-Path $dir 'REPORT.md') -Raw -Encoding UTF8 -ErrorAction SilentlyContinue)"
    $m = [regex]::Matches($t, '(?ms)^## QA [^\r\n]*\r?\n(.*?)(?=^## |\z)')
    if (-not $m.Count) { return $null }
    $sec = $m[$m.Count - 1].Groups[1].Value
    $parts = $sec -split '(?im)^[^\r\n]*\bfindings?\b[^\r\n]*$', 2
    if ($sec -notmatch '(?i)verify' -or $parts.Count -lt 2) { return $null }
    $n = [regex]::Matches($parts[1], '(?m)^\s*\d+[.)]\s+\S').Count
    return @{ State = $(if ($n -gt 0) { 'findings' } else { 'pass' }); Findings = $n }
}
# Reads a finished QA's result; true when it failed for a reason a fallback reviewer could fix (not findings, not a
# forbidden edit, which a second judge's opinion never replaces).
function Complete-QaJob($r, $timedOut) {
    $name = $r.Q.Name; $dir = Join-Path $projects $name; $fam = $r.Plan.Family
    $text = (("$(Get-Content $r.Log -Raw -Encoding UTF8 -ErrorAction SilentlyContinue)" -replace "`0", '') -split '(?m)^=== QA ')[-1]
    $timedOut = $timedOut -or $text -match '(?s)LOCAL AGENT FAILED:.*timed out after [\d.]+ seconds'   # Hermes stops itself at --run-budget
    if ($fam -eq 'hermes') { git -C $dir pull --rebase --autostash -q 2>$null }   # its commits reach the desktop only now
    # Put back what QA's verify run re-took (tracked screenshots), then look at what QA itself committed.
    $byVerify = @(git -C $dir status --porcelain 2>$null | Where-Object { $_ -notin $r.Dirty -and $_ -match '^ M ' } | ForEach-Object { $_.Substring(3) } | Where-Object { $_ -notin $qaAllowed })
    if ($byVerify) { git -C $dir checkout -- $byVerify 2>$null }
    $foreign = @(git -C $dir diff --name-only $r.Head HEAD 2>$null | Where-Object { $_ -notin $qaAllowed })
    $hit = [regex]::Matches($text, '(?m)^\s*QA RESULT:\s*(pass|findings\s*=\s*(\d+))\s*$')
    $by = $r.Plan.Spec
    $rows[$name].Note = "$($rows[$name].Note.TrimEnd()) QA log: $($r.Log)."
    $salvage = Get-QaFromReport $dir $r.Head
    if ($timedOut -and -not $salvage) { Set-Qa $name 'failed' "timed out after $QaMinutes min" 0 $by }
    elseif ($foreign) { Set-Qa $name 'failed' "QA changed files it may not: $($foreign -join ', '); see git log $($r.Head)..HEAD" 0 $by }
    elseif ($hit.Count) {
        $n = $(if ($hit[$hit.Count - 1].Groups[2].Success) { [int]$hit[$hit.Count - 1].Groups[2].Value } else { 0 })
        if ($n -gt 0) { Set-Qa $name 'findings' '' $n $by } else { Set-Qa $name 'pass' '' 0 $by }
    }
    elseif ($salvage) { Set-Qa $name $salvage.State 'read from its REPORT.md QA section (no "QA RESULT:" line)' $salvage.Findings $by }
    elseif ($fam -ne 'hermes' -and (Test-LimitHit $text)) { $limitUntil[$fam] = Get-LimitReset $text; Set-Qa $name 'skipped' "$fam hit its usage limit during QA; resets $($limitUntil[$fam].ToString('HH:mm'))" 0 $by }
    elseif ($text -match 'SPARK_MISSING') { Set-Qa $name 'skipped' "not cloned on FirstSpark at $sparkProjects" 0 $by }
    elseif ($text -match 'SPARK_BUSY') { Set-Qa $name 'skipped' 'a Hermes session is still running in that repo on FirstSpark' 0 $by }
    elseif ($text -match 'SPARK_HEAD_MISMATCH') { Set-Qa $name 'failed' 'FirstSpark HEAD differs from the desktop commit being reviewed' 0 $by }
    else { Set-Qa $name 'failed' 'the QA session ended without a "QA RESULT:" line' 0 $by }
    if ($qaResults[$name].state -in 'pass', 'findings') { $script:qaFrom[$name] = "$(git -C $dir rev-parse HEAD 2>$null)" }
    # A timed-out range is left unreviewed, so the next QA covers only the newest slice instead of the whole night again
    # (owner, 2026-10-28: each retry grew and timed out again, 3 times each on jobs-search and bionic-reading-trainer).
    elseif ($timedOut -and $r.Head) {
        $script:qaFrom[$name] = $r.Head
        $rows[$name].Note += " Not reviewed (QA timed out): $("$($r.From)" -replace '^(.{7}).*', '$1')..$($r.Head -replace '^(.{7}).*', '$1')."
    }
    return (-not $r.Plan.FallbackUsed -and -not $foreign -and $qaResults[$name].state -in 'failed', 'skipped')
}
# QA of a slice the moment its builder finishes it, on the lane, before the next slice is planned: its findings go into
# FEEDBACK.md, which the planner puts first, so they are fixed the same night, and the end of the run has little left to
# review. FirstSpark Qwen reviews one project at a time, so a slice whose only reviewer is Qwen waits for the end.
# FirstSpark's Qwen is shared with the owner's apps: one review on it at a time, and none while the lanes run. GLM (the
# plain "hermes" QA spec, on SecondSpark + ThirdSpark) is not that model (2026-10-26: treating it the same left the whole
# Codex lane without slice QA all night, then reviewed it one project at a time for 3.5 hours after the lanes stopped).
function Test-SharedQwen($plan) { return "$($plan.Spec)" -like 'hermes:qwen*' }

function Start-SliceQa($q) {
    Update-Choices $q
    $name = $q.Name; $dir = Join-Path $projects $name
    $from = $(if ($qaFrom[$name]) { $qaFrom[$name] } else { $heads[$name] })
    if ($DryRun -or -not $qaPromptText -or -not (Test-Progress $dir $from)) { return $false }
    $plan = Get-QaPlan $q $roles
    if ($plan.Skip) { return $false }
    if (-not $cliOk[$plan.Family] -or (Test-Parked $plan.Family)) { $plan = Get-QaPlan $q $roles -Fallback; if ($plan.Skip -or -not $cliOk[$plan.Family] -or (Test-Parked $plan.Family)) { return $false } }
    if (Test-SharedQwen $plan) { return $false }   # waits for the end of the run
    $rec = Start-QaJob $q $plan $from
    $running[$rec.Job.Id] = $rec
    $rows[$name].Note += "slice QA on $($plan.Spec) at $((Get-Date).ToString('HH:mm')). "
    return $true
}
$firstStep = @{}; $tails = @{}
foreach ($q in @($pending)) { Set-FirstStep $q }
foreach ($q in @($queue | Where-Object { $checks[$_.Name].Blockers })) { if (-not $DryRun -and -not $QaOnly) { Start-Backfill $rows[$q.Name] $q.Harness $q.Name } }
if ($pending.Count) { Save-RunState }
while ($pending.Count -or $running.Count) {
    # Start every pending project whose harness has a free slot, in list order (first sessions before relaunches).
    foreach ($q in @($pending)) {
        $left = [int]($deadline - (Get-Date)).TotalSeconds
        if ($left -lt $minSession) { if (-not $sessions[$q.Name]) { $rows[$q.Name].Note = "not run: less than 30 min left before $($deadline.ToString('HH:mm'))" }; $pending.Remove($q); continue }
        if ($notBefore[$q.Name] -and (Get-Date) -lt $notBefore[$q.Name]) { continue }
        if ($recheck[$q.Name]) {   # left alone at prep: someone was editing, or a Hermes session was still going
            $leftAlone.Remove($q.Name); $d = Join-Path $projects $q.Name
            if ($q.Harness -ne 'hermes') { Save-DesktopHandoff $q.Name $d }   # FirstSpark: the session's own SPARK_BUSY check waits
            if ($leftAlone[$q.Name] -match $waitPattern) { $notBefore[$q.Name] = (Get-Date).AddMinutes(5); continue }
            if ($leftAlone[$q.Name]) { $rows[$q.Name].Note += "skipped: $($leftAlone[$q.Name]). "; $pending.Remove($q); continue }
            $recheck.Remove($q.Name); $rows[$q.Name].Note += "started at $((Get-Date).ToString('HH:mm')) once the edits stopped. $($handoff[$q.Name])"
        }
        $use = Get-SessionHarness $q
        if (-not $use) { continue }   # waits for a usage-limit reset
        if ($waitNet[$q.Name]) {   # checked at most once a minute per tool
            if ($nextNetCheck[$use] -and (Get-Date) -lt $nextNetCheck[$use]) { continue }
            if (-not (Test-Online $use)) { $nextNetCheck[$use] = (Get-Date).AddMinutes(1); continue }
            $waitNet.Remove($q.Name)
        }
        if ($PerHarness -gt 0 -and @($running.Values | Where-Object { $_.Q.Harness -eq $use }).Count -ge $PerHarness) { continue }   # 0 = no limit: every project in the lane at once
        if ($firstStep[$q.Name]) { $f = $firstStep[$q.Name]; $firstStep.Remove($q.Name); $pending.Remove($q); Start-Advance $q $f.Action $f.Why; continue }
        $pending.Remove($q)
        Update-Choices $q
        $run = $q
        if ($use -ne $q.Harness) {   # Home: the queue entry the project goes back to when this session ends
            $run = [pscustomobject]@{ Name = $q.Name; Harness = $use; Model = $null; Home = $q }
            $rows[$q.Name].Note += "fallback: session $(1 + [int]$sessions[$q.Name]) on $use at $((Get-Date).ToString('HH:mm')) ($($q.Harness) parked until $($limitUntil[$q.Harness].ToString('HH:mm'))). "
        }
        $dir = Join-Path $projects $q.Name; $log = Join-Path $logDir "$($q.Name).log"
        $sessions[$q.Name] = 1 + [int]$sessions[$q.Name]
        Add-Content -Path $log -Value "=== session $($sessions[$q.Name]) $((Get-Date).ToString('HH:mm')), until $($deadline.ToString('HH:mm')) ===" -Encoding UTF8
        Remove-Item "$log.pid" -ErrorAction SilentlyContinue   # the job writes a fresh one
        $dot = [char]0x00B7   # this file must stay ASCII for PowerShell 5.1
        $sessionName = "$($q.Name) $dot $(if ($Kind -eq 'morning') { 'morning' } else { 'night' }) of $($started.ToString('MMM d', [Globalization.CultureInfo]::InvariantCulture)) $dot session $($sessions[$q.Name])"
        # A fresh session after a cut-off one also sees how the last one ended (PROGRESS.md '## Now' is the handoff itself).
        $sessionPrompt = $prompt + $(if ($tails[$q.Name]) { "`nTHE PREVIOUS SESSION on this project ended at $($tails[$q.Name].At). Start from PROGRESS.md '## Now'; this is the end of its output:`n" + $tails[$q.Name].Text + "`n" } else { '' })
        $job = Start-Job -ScriptBlock $worker -ArgumentList $dir, $run.Harness, $run.Model, $sessionPrompt, $log, $left, $ssh, "$sparkProjects/$($q.Name)", $sessionName, $false
        $running[$job.Id] = @{ Job = $job; Q = $run; Start = Get-Date; Head = (git -C $dir rev-parse HEAD 2>$null); PidFile = "$log.pid" }
    }
    Save-RunState   # each lane's state for the Agents board
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
        if ($r.Qa -and $r.Job.State -eq 'Running' -and (Get-Date) -ge $r.Start.AddMinutes($QaMinutes + 5)) {
            $jobPid = Get-Content $r.PidFile -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($jobPid) { & taskkill.exe /PID $jobPid /T /F *> $null }
            Stop-Job $r.Job; $r.QaTimedOut = $true
        }
        if ($r.Job.State -eq 'Running' -and -not $r.Advance -and -not $r.Qa -and $r.Q.Harness -in 'claude', 'codex') {
            $d = Join-Path $projects $r.Q.Name
            $sig = "$(git -C $d rev-parse HEAD 2>$null) $((git -C $d status --porcelain 2>$null) -join '|')"
            if ($sig -ne $r.Sig) { $r.Sig = $sig; $r.Changed = Get-Date }
            elseif ((Get-Date) -ge ([datetime]$(if ($r.Changed) { $r.Changed } else { $r.Start })).AddMinutes(90)) {
                $jobPid = Get-Content $r.PidFile -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($jobPid) { & taskkill.exe /PID $jobPid /T /F *> $null }
                Stop-Job $r.Job; $r.Hung = $true; $row.Note += "no commit or file change for 90 min at $((Get-Date).ToString('HH:mm')): session restarted. "
            }
        }
        if ($r.Job.State -ne 'Running') {
            Remove-Job $r.Job -Force; $running.Remove($id)
            $name = $r.Q.Name; $dir = Join-Path $projects $name
            $own = $(if ($r.Q.Home) { $r.Q.Home } else { $r.Q })   # a fallback session's project goes back to its own lane
            if ($r.Qa) {
                if ($row.TimedOut) { continue }   # cut off at the end time: the end-of-run QA reviews this range again
                if (Complete-QaJob $r $r.QaTimedOut) {
                    $fb = Get-QaPlan $r.Q $roles -Fallback
                    if (-not $fb.Skip -and -not (Test-SharedQwen $fb) -and $fb.Spec -ne $r.Plan.Spec -and $cliOk[$fb.Family] -and -not (Test-Parked $fb.Family)) {
                        $rec = Start-QaJob $r.Q $fb $r.From; $running[$rec.Job.Id] = $rec; $row.Note += "Retrying QA on fallback $($fb.Spec). "; continue
                    }
                }
                Start-Advance $r.Q   # plan the next slice; the planner puts QA's findings (FEEDBACK.md) first
                continue
            }
            if ($r.Advance) {
                $integrity[$name] = Get-Integrity $dir   # the advance legitimately extends verify.ps1: that is the new baseline
                if ($row.TimedOut) { continue }
                $atext = (((Get-Content (Join-Path $logDir "$name.advance.txt") -Raw -Encoding UTF8 -ErrorAction SilentlyContinue) -replace "`0", '') -split '(?m)^=== ')[-1]
                $fam = ($r.Spec -split ':')[0]
                if (Test-Progress $dir $r.Head) { $row.Note += "$(if ($r.Action -eq 'advance') { 'advanced to its next slices' } else { "$($r.Action) done" }) at $((Get-Date).ToString('HH:mm')) on $($r.Spec). "; [void]$pending.Add($r.Q) }
                # A usage limit means the planner never ran, even when another session parked that model first (2026-10-26:
                # creator-content-engine and event-market-research-terminal lost the night to "no new slice" this way).
                # A tool that would not start is parked for 30 min the same way (2026-10-28: a broken claude.exe at 21:36
                # sent five Ready next projects to Active in 30 seconds).
                elseif ($fam -ne 'hermes' -and ((Test-LimitHit $atext) -or (Test-ToolMissing $atext)) -and [int]$planLimits[$name] -lt 4) {
                    $planLimits[$name] = 1 + [int]$planLimits[$name]
                    $why = $(if (Test-ToolMissing $atext) { "$fam would not start" } else { "$fam usage limit" })
                    if (-not (Test-Parked $fam)) { $limitUntil[$fam] = $(if (Test-ToolMissing $atext) { (Get-Date).AddMinutes(30) } else { Get-LimitReset $atext }); Save-RunState }
                    Write-Decision $name "$why while planning: planning again on the next free model"
                    $row.Note += "$why while planning at $((Get-Date).ToString('HH:mm')); planning again on the next free model. "
                    if ($r.Action -eq 'advance') { $advances[$name] = [int]$advances[$name] - 1 }   # that one never ran
                    Start-Advance $r.Q $r.Action $r.Why
                }
                elseif ($r.Action -ne 'advance' -and -not (Test-Path "$dir\scripts\verify.ps1")) { $row.Note += "$($r.Action) could not make it overnight-ready on $($r.Spec) (see $name.advance.txt). "; Start-Backfill $row $r.Q.Harness $name }
                elseif ($r.Action -ne 'advance') { $row.Note += "$($r.Action) made no commit on $($r.Spec); building on the current target. "; [void]$pending.Add($r.Q) }
                else {
                    if ((Test-Built $dir) -and (Move-ProjectLine $name 'active')) { $row.Note += "built: only owner steps left; moved to Active. "; [void]$pipelineMoves.Add("$((Get-Date).ToString('HH:mm')) $name to Active (built)") }
                    else { $row.Note += "its planner made no new slice on $($r.Spec) (see $name.advance.txt). "; Move-Stalled $name $row }
                    Start-Backfill $row $r.Q.Harness $name
                }
                continue
            }
            $row.Minutes += [int]((Get-Date) - $r.Start).TotalMinutes
            $text = Complete-Run $r.Q $row
            if ($row.TimedOut) { continue }
            $t = ("$text" -replace '\s+$', ''); $tails[$name] = @{ At = (Get-Date).ToString('HH:mm'); Text = $t.Substring([Math]::Max(0, $t.Length - 1500)) }
            # A Hermes fallback for a project not cloned on FirstSpark: no more Hermes fallbacks for it; it waits for a reset.
            if ($r.Q.Home -and $r.Q.Harness -eq 'hermes' -and "$text" -match 'SPARK_MISSING') { $noSpark[$name] = $true; [void]$pending.Add($own); continue }
            # Stopped early with real progress and time left: start it again; it resumes from PROGRESS.md's next open item.
            # Builder sessions in a row with no real work (only REPORT/PROGRESS/DECISIONS): from the second one on, nothing but a
            # real usage limit starts another builder session; the target is done, so QA and planning follow (2026-10-25:
            # personalized-adhd ran 16 two-minute sessions that only re-recorded a passing verify).
            $progress = Test-Progress $dir $r.Head
            # FirstSpark still had a session in this repo (one a stopped run left behind): nothing ran, so it is neither work
            # nor an empty session; try again in 5 minutes (2026-10-25: four of these handed personal-study-curriculum's lane away).
            $sparkBusy = -not $progress -and "$text" -match '(?m)^SPARK_BUSY'
            $idle[$name] = $(if ($progress) { 0 } elseif ($sparkBusy) { [int]$idle[$name] } else { 1 + [int]$idle[$name] })
            $quiet = [int]$idle[$name] -ge 2
            if ($progress) { $advances[$name] = 0; [void]$pending.Add($own); Write-Decision $name 'real work committed: next builder session' }   # real work resets the advance count
            elseif ($sparkBusy) { $notBefore[$name] = (Get-Date).AddMinutes(5); [void]$pending.Add($own); Write-Decision $name 'FirstSpark still busy in this repo: tried again in 5 minutes' }
            elseif ($r.Q.Harness -ne 'hermes' -and (Test-LimitHit $text)) { [void]$pending.Add($own); Write-Decision $name "usage limit: waits for $($r.Q.Harness)'s reset or another harness" }
            elseif ($r.Q.Harness -ne 'hermes' -and (Test-ToolMissing $text)) { $limitUntil[$r.Q.Harness] = (Get-Date).AddMinutes(30); Save-RunState; [void]$pending.Add($own); $row.Note += "$($r.Q.Harness) would not start at $((Get-Date).ToString('HH:mm')); parked 30 min, its sessions run on the fallback. "; Write-Decision $name "$($r.Q.Harness) would not start: parked 30 min, next session on the fallback" }
            elseif (-not $quiet -and (Test-NetError $text)) {
                $waitNet[$name] = $true; if ("$text" -match 'SPARK_BUSY') { $notBefore[$name] = (Get-Date).AddMinutes(5) }
                $row.Note += "connection lost at $((Get-Date).ToString('HH:mm')), retried when back. "; [void]$pending.Add($own); Write-Decision $name 'connection lost: retried when back'
            }
            elseif (-not $quiet -and $r.Hung -and [int]$hangs[$name] -lt 2) { $hangs[$name] = 1 + [int]$hangs[$name]; [void]$pending.Add($own); Write-Decision $name 'hung: fresh session' }   # hung, not done: a fresh session
            # Not gated on $quiet: a dirty checkout is never "target done" (2026-10-28: finance-signals-dashboard's planner refused
            # its uncommitted Slice 5p and the Codex lane idled 02:24-06:00). $leftovers bounds the restarts.
            elseif ([int]$leftovers[$name] -lt 3 -and (Test-Leftover $dir $r.Q.Harness $text)) {
                $leftovers[$name] = 1 + [int]$leftovers[$name]
                $row.Note += "session ended mid-work at $((Get-Date).ToString('HH:mm')) (uncommitted changes left); fresh session started to finish it. "; [void]$pending.Add($own); Write-Decision $name 'ended mid-work: fresh session'
            }
            # No new work: tonight's target is done. Advance it to its next slices; after two advances in a row with no
            # real work between them, the lane moves to the next overnight-ready project.
            elseif ([int]$advances[$name] -lt 2 -and (Start-SliceQa $own)) { Write-Decision $name 'target done: QA of the slice, then planning' }
            elseif ([int]$advances[$name] -lt 2) { Write-Decision $name 'target done: planning the next slices'; Start-Advance $own }
            else { $row.Note += "two advances in a row brought no real work. "; Write-Decision $name 'two advances brought no real work: lane goes to the next project'; Move-Stalled $name $row; Start-Backfill $row $own.Harness $name }
        }
    }
}
foreach ($name in @($sessions.Keys)) { if ($sessions[$name] -gt 1) { $rows[$name].Note = "$($sessions[$name]) sessions. " + $rows[$name].Note } }

# ---- QA pass: after a project's builder sessions, one session on the lane's QA harness (another model family) ----
# It runs verify, exercises the changed screens, checks every task marked done tonight for evidence, and writes findings
# (agent-rules/qa-prompt.md). Skipped with a reason when there is no real commit, QA is off (qa=off or roles.json), or its
# harness is parked on a usage limit. QA may change only the files in $qaAllowed; the runner checks the commits it made.
# The result goes to .run-state.json (live) and under the report table, and the Agents board shows it as a badge.
# The run's report. Written once when the lanes stop, so the morning has it at the end time, then again with QA and
# the runner's own verify (which take another hour or so).
function Write-RunReport([switch]$final) {
    $md = @("# $(if ($Kind -eq 'morning') { 'Morning' } else { 'Overnight' }) Report", "",
            "Run started $($started.ToString('yyyy-MM-dd HH:mm')), $(if ($final) { 'finished' } else { 'lanes stopped' }) $((Get-Date).ToString('HH:mm'))$(if ($DryRun) { ' (dry run)' })$(if (-not $final) { '; QA and the runner''s own verify are still running and fill in this report when they finish' }), $Kind run, $(if ($PerHarness -gt 0) { "up to $PerHarness per harness" } else { 'every project at once' }). Logs: ``$logDir``", "",
            ($(if ($prepWork -and -not $DryRun -and -not $NoPrep) { "Prep before the lanes: $($prepWork.Count) top-10 upkeep item(s); see ``Nightly Runs/Prep Report.md`` and ``$logDir\_prep.log``. " } else { '' }) +
            "Verify is re-run by the runner on the desktop after each agent finishes (for @hermes, after pulling its pushed commits). Each project's ``REPORT.md`` has details and open questions."), "",
            "| Project | Harness | Verify | Git (desktop) | Commits tonight | Note |", "|---|---|---|---|---|---|")
    $md += $queue | ForEach-Object { $r = $rows[$_.Name]; "| $($r.Project) | $($r.Harness) | $($r.Verify) | $($r.Git) | $($r.Commits) | $($r.Note) |" }
    if (-not $queue) { $md += '| (Tonight list is empty) | | | | | |' }
    $ranges = @($queue | Where-Object { $rows[$_.Name].Heads } | ForEach-Object { "- ``$($_.Name)``: $($rows[$_.Name].Heads)" })
    if ($ranges) { $md += @('', 'HEAD before..after each project''s lanes (the Agents board Review tab lists exactly these commits):') + $ranges }
    if ($pipelineMoves.Count) { $md += @('', 'Moved in Project Priorities.md by the runner (lanes follow the priority order):') + @($pipelineMoves | ForEach-Object { "- $_" }) }
    $qaLines = @($queue | Where-Object { $qaResults[$_.Name] } | ForEach-Object { "- ``$($_.Name)``: QA $(Format-Qa $qaResults[$_.Name])" })
    if ($qaLines) { $md += @('', 'QA after the builder sessions (the Agents board shows these as badges):') + $qaLines }
    New-Item -ItemType Directory -Force $runLogDir | Out-Null   # Morning Runs/Logs on the first morning run
    Set-Content -Path $reportMd -Value $md -Encoding UTF8
    if ($final -and -not $DryRun) { Set-Content -Path (Join-Path $runLogDir "$stamp.md") -Value $md -Encoding UTF8 }
}
$runPhase = 'wrapup'; if (-not $DryRun) { Save-RunState }
if (-not $DryRun -and -not $QaOnly) {
    foreach ($q in $queue) { if ($heads[$q.Name]) { $d = Join-Path $projects $q.Name; $h = git -C $d rev-parse HEAD 2>$null; $rows[$q.Name].Heads = "$($heads[$q.Name])..$h"; $rows[$q.Name].Commits = [int](git -C $d rev-list --count $rows[$q.Name].Heads 2>$null) } }
    Write-RunReport
}
$qaQueue = New-Object System.Collections.ArrayList
foreach ($q in $queue) {
    $name = $q.Name; $dir = Join-Path $projects $name
    if ($DryRun) {
        if ($checks[$name].Blockers) { continue }
        $plan = Get-QaPlan $q $roles
        $rows[$name].Note += $(if ($plan.Skip) { "dry run: QA skipped ($($plan.Skip)). " } else { "dry run: QA would run on $($plan.Spec) after builder sessions with a real commit. " })
        continue
    }
    if (-not $QaOnly -and -not $sessions[$name]) { continue }   # QA-only explicitly reviews the supplied earlier range
    if ($QaOnly -and $checks[$name].Blockers) { Set-Qa $name 'skipped' ('preflight: ' + ($checks[$name].Blockers -join '; ')); continue }
    if ($resumedQa[$name]) { continue }   # a resumed run already finished this one
    Update-Choices $q
    $from = $(if ($qaFrom[$name]) { $qaFrom[$name] } else { $heads[$name] })
    if (-not (Test-Progress $dir $from)) { if (-not $qaResults[$name] -or $qaResults[$name].state -eq 'running') { Set-Qa $name 'skipped' 'no real commit tonight' }; continue }   # slice QA covered it all
    $plan = Get-QaPlan $q $roles
    if ($plan.Skip) { Set-Qa $name 'skipped' $plan.Skip; continue }
    if (-not $qaPromptText) { Set-Qa $name 'skipped' 'agent-rules/qa-prompt.md is missing'; continue }
    if (-not $cliOk[$plan.Family] -or (Test-Parked $plan.Family)) {
        $why = $(if (-not $cliOk[$plan.Family]) { "$($plan.Family) CLI not found" } else { "$($plan.Family) is parked on its usage limit until $($limitUntil[$plan.Family].ToString('HH:mm'))" })
        $fallback = Get-QaPlan $q $roles -Fallback
        if ($fallback.Skip -or -not $cliOk[$fallback.Family] -or (Test-Parked $fallback.Family)) { Set-Qa $name 'skipped' "$why; no available fallback QA"; continue }
        $rows[$name].Note += "Primary QA $($plan.Spec) unavailable ($why); using fallback $($fallback.Spec). "
        $plan = $fallback
    }
    [void]$qaQueue.Add(@{ Q = $q; Plan = $plan; From = $from })
}
$qaRunning = @{}
$localQaReady = $false
if (@($qaQueue | Where-Object { $_.Plan.Family -eq 'hermes' -or (Get-QaPlan $_.Q $roles -Fallback).Family -eq 'hermes' }).Count) {
    # Install this checkout's reviewed launcher, not an independently edited copy on the Spark.
    $encoded = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'local-agent.py')))
    $encoded | & $ssh -o BatchMode=yes -o ConnectTimeout=10 FirstSpark 'umask 077; mkdir -p ~/.agents-board; base64 --decode --ignore-garbage > ~/.agents-board/local-agent.py.tmp && mv ~/.agents-board/local-agent.py.tmp ~/.agents-board/local-agent.py'
    $localQaReady = $LASTEXITCODE -eq 0
    if (-not $localQaReady) {
        foreach ($item in @($qaQueue | Where-Object { $_.Plan.Family -eq 'hermes' })) {
            $qaQueue.Remove($item); Set-Qa $item.Q.Name 'failed' 'could not deploy the local QA launcher to FirstSpark'
        }
    }
}
while ($qaQueue.Count -or $qaRunning.Count) {
    foreach ($item in @($qaQueue)) {
        $name = $item.Q.Name; $fam = $item.Plan.Family; $dir = Join-Path $projects $name
        if ($item.NotBefore -and (Get-Date) -lt $item.NotBefore) { continue }
        if (Test-Parked $fam) {
            $fallback = Get-QaPlan $item.Q $roles -Fallback
            if (-not $item.Plan.FallbackUsed -and -not $fallback.Skip -and -not (Test-Parked $fallback.Family) -and $cliOk[$fallback.Family]) {
                $rows[$name].Note += "Primary QA $($item.Plan.Spec) parked; using fallback $($fallback.Spec). "
                $item.Plan = $fallback; $fam = $fallback.Family
            } else { $qaQueue.Remove($item); Set-Qa $name 'skipped' "$fam hit its usage limit; no available fallback QA"; continue }
        }
        if ($fam -eq 'hermes' -and -not $localQaReady) { $qaQueue.Remove($item); Set-Qa $name 'failed' 'local QA launcher deployment failed'; continue }
        # The shared Qwen: one review at a time. GLM: three at once. Claude and Codex: -PerHarness (0 = no limit).
        $qwen = Test-SharedQwen $item.Plan
        $qaLimit = $(if ($qwen) { 1 } elseif ($fam -eq 'hermes') { 3 } else { $PerHarness })
        if ($qaLimit -gt 0 -and @($qaRunning.Values | Where-Object { $_.Plan.Family -eq $fam -and (Test-SharedQwen $_.Plan) -eq $qwen }).Count -ge $qaLimit) { continue }
        $qaQueue.Remove($item)
        $rec = Start-QaJob $item.Q $item.Plan $item.From
        $rec.Busy = [int]$item.Busy; $qaRunning[$rec.Job.Id] = $rec
    }
    if (-not $qaRunning.Count) { if ($qaQueue.Count) { Start-Sleep -Seconds 30; continue }; break }
    Wait-Job -Job @($qaRunning.Values | ForEach-Object { $_.Job }) -Any -Timeout 60 | Out-Null
    foreach ($id in @($qaRunning.Keys)) {
        $r = $qaRunning[$id]; $name = $r.Q.Name; $dir = Join-Path $projects $name; $fam = $r.Plan.Family
        $timedOut = $false
        if ($r.Job.State -eq 'Running' -and (Get-Date) -ge $r.Start.AddMinutes($QaMinutes + 5)) {
            $jobPid = Get-Content "$($r.Log).pid" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($jobPid) { & taskkill.exe /PID $jobPid /T /F *> $null }
            Stop-Job $r.Job; $timedOut = $true
        }
        if ($r.Job.State -eq 'Running') { continue }
        Remove-Job $r.Job -Force; $qaRunning.Remove($id)
        $retry = Complete-QaJob $r $timedOut
        # The lane's last Hermes session is still finishing on FirstSpark: the same QA again in 5 minutes, up to 30 minutes
        # (2026-10-28: expert-lens-skill's final QA was skipped at 06:06 for it).
        if ($qaResults[$name].reason -like '*still running*' -and $r.Busy -lt 6) {
            [void]$qaQueue.Add(@{ Q = $r.Q; Plan = $r.Plan; From = $r.From; NotBefore = (Get-Date).AddMinutes(5); Busy = 1 + $r.Busy })
            Set-Qa $name 'running'; continue
        }
        # Retry infrastructure/limit failures once on the configured fallback.
        if ($retry) {
            $fallback = Get-QaPlan $r.Q $roles -Fallback
            if (-not $fallback.Skip -and $fallback.Spec -ne $r.Plan.Spec -and $cliOk[$fallback.Family] -and -not (Test-Parked $fallback.Family)) {
                $rows[$name].Note += "Retrying QA on fallback $($fallback.Spec). "
                [void]$qaQueue.Add(@{ Q = $r.Q; Plan = $fallback; From = $r.From })
                Set-Qa $name 'running'
            }
        }
    }
}

# Independent gate: the runner's own verify and git check, not the agent's claim. The verify runs go three at a time
# (it took 40 min one by one on 2026-10-25); a FAIL is run again alone before it counts, so two projects' verify runs
# can never fail each other.
# Active projects with a preview that no recent run verified get one verify here, so the board can give them their
# Dashboard Command Center tab (it reads the newest of the last 40 runs' <name>.verify.txt; 2026-10-29: four built
# projects had no tab because nothing ever verified them after they reached Active).
function Get-UnverifiedActive {
    $runs = @(foreach ($r in 'overnight-logs', 'morning-logs') { Get-ChildItem (Join-Path $projects ".$r") -Directory -ErrorAction SilentlyContinue }) | Sort-Object Name -Descending | Select-Object -First 40
    $st = Read-Pipeline
    @($st.Where.Keys | Where-Object { $st.Where[$_] -eq 'active' } | Sort-Object | Where-Object {
        $n = $_; (Test-Path (Join-Path $projects "$n\scripts\preview.ps1")) -and (Test-Path (Join-Path $projects "$n\scripts\verify.ps1")) -and
            -not @($runs | Where-Object { Test-Path (Join-Path $_.FullName "$n.verify.txt") }).Count })
}
$gateList = @($queue | Where-Object { Test-Path (Join-Path $projects "$($_.Name)\scripts\verify.ps1") })
if (-not $DryRun -and -not $QaOnly) { $gateList += @(Get-UnverifiedActive | Where-Object { $_ -notin @($queue | ForEach-Object Name) } | ForEach-Object { [pscustomobject]@{ Name = $_ } }) }
$gateDirty = @{}; $gateCode = @{}; $gateJobs = @{}
foreach ($q in $gateList) { $gateDirty[$q.Name] = @(git -C (Join-Path $projects $q.Name) status --porcelain 2>$null) }
foreach ($q in $gateList) {
    while (@($gateJobs.Values | Where-Object { $_.State -eq 'Running' }).Count -ge 3) { Start-Sleep -Seconds 5 }
    $gateJobs[$q.Name] = Start-Job -ScriptBlock { param($at, $v, $out) Set-Location $at; $env:TEMP = $env:TMP = (New-Item -ItemType Directory -Force (Join-Path ([IO.Path]::GetTempPath()) "ov$PID")).FullName; & powershell -NoProfile -ExecutionPolicy Bypass -File $v *> $out; $LASTEXITCODE } -ArgumentList (Get-Location).Path, (Join-Path $projects "$($q.Name)\scripts\verify.ps1"), (Join-Path $logDir "$($q.Name).verify.txt")
}
foreach ($n in @($gateJobs.Keys)) { $out = @(Receive-Job -Job $gateJobs[$n] -Wait 2>$null); $gateCode[$n] = $(if ($out.Count) { [int]$out[-1] } else { 1 }); Remove-Job $gateJobs[$n] -Force }
foreach ($n in @($gateCode.Keys | Where-Object { $gateCode[$_] -ne 0 })) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $projects "$n\scripts\verify.ps1") *> (Join-Path $logDir "$n.verify.txt"); $gateCode[$n] = $LASTEXITCODE
}
# The Active projects verified only for their tab: put back what their verify re-took (tracked screenshots), nothing else.
foreach ($q in @($gateList | Where-Object { $_.Name -notin @($queue | ForEach-Object Name) })) {
    $dir = Join-Path $projects $q.Name
    $byVerify = @(git -C $dir status --porcelain 2>$null | Where-Object { $_ -notin $gateDirty[$q.Name] -and $_ -match '^ M ' } | ForEach-Object { $_.Substring(3) })
    if ($byVerify) { git -C $dir checkout -- $byVerify 2>$null }
}
foreach ($q in $queue) {
    $dir = Join-Path $projects $q.Name; $row = $rows[$q.Name]
    if (-not (Test-Path "$dir\scripts\verify.ps1")) { continue }
    $dirtyBefore = $gateDirty[$q.Name]
    $row.Verify = $(if ($gateCode[$q.Name] -eq 0) { 'PASS' } else { 'FAIL' })
    # This verify re-takes tracked screenshots (a few pixels differ each time). Put back only what it changed, so the
    # project starts the next run clean instead of being skipped for "uncommitted changes"; the agent's own work is untouched.
    $byVerify = @(git -C $dir status --porcelain 2>$null | Where-Object { $_ -notin $dirtyBefore -and $_ -match '^ M ' } | ForEach-Object { $_.Substring(3) })
    if ($byVerify) { git -C $dir checkout -- $byVerify 2>$null }
    if ($integrity[$q.Name]) {
        $after = Get-Integrity $dir; $row.TestsAfter = $after.Tests
        $issues = @(Compare-Integrity $integrity[$q.Name] $after)
        if ($issues) { $row.Verify = "SUSPECT ($($row.Verify))"; $row.Note = "SUSPECT: $($issues -join '; '). Check the diff before trusting this result. " + $row.Note }
    }
    $dirty = git -C $dir status --porcelain 2>$null
    $ahead = git -C $dir rev-list --count '@{u}..HEAD' 2>$null
    $row.Git = $(if ($dirty) { 'uncommitted changes' } elseif ([int]$ahead -gt 0) { "$ahead unpushed" } else { 'clean, pushed' })
    if (-not $dirty -and -not $DryRun) { $verifyCache[$q.Name] = @{ head = "$(git -C $dir rev-parse HEAD 2>$null)"; verify = $row.Verify; at = (Get-Date).ToString('yyyy-MM-dd HH:mm') } }
    $row.Commits = @(git -C $dir log --since=$($started.ToString('s')) --oneline 2>$null).Count
    if ($heads[$q.Name]) { $headAfter = git -C $dir rev-parse HEAD 2>$null; $row.Heads = "$($heads[$q.Name])..$headAfter"; $row.Commits = [int](git -C $dir rev-list --count $row.Heads 2>$null) }
}

Write-RunReport -final
if (-not $DryRun -and $verifyCache.Count) { $verifyCache | ConvertTo-Json -Depth 4 | Set-Content -Path $verifyCacheFile -Encoding UTF8 }
if (-not $DryRun) { Remove-Item $stateFile -ErrorAction SilentlyContinue }   # finished: nothing for -Resume to continue
# Projects that now have a preview (scripts/preview.ps1) appear as tabs in Dashboard Command Center's Projects group.
if (-not $DryRun -and -not $env:OVERNIGHT_VAULT) {   # a fixture run (test-qa-run.ps1) must not touch the real board
    try { $dcc = Invoke-RestMethod -Method Post -Uri 'http://127.0.0.1:8768/api/dcc' -ContentType 'application/json' -Body '{}' -TimeoutSec 60; Write-Output "dcc: registered $(@($dcc.registered) -join ', ')" }
    catch { Write-Output "dcc: could not reach the Agents board to register previews ($($_.Exception.Message))" }
}

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
