# Overnight runner: works the "## Tonight" list in Nightly Runs/Project Priorities.md, up to -PerHarness projects per harness at once
# (default 3 Claude + 3 Codex + 3 Hermes = 9 in parallel).
# @claude and @codex run here on the desktop; @hermes runs on FirstSpark over SSH. After each agent finishes,
# the runner re-runs that project's scripts/verify.ps1 itself and writes a report plus a dated copy per real run (never overwritten):
#   nightly: Nightly Runs/Overnight Report.md, Nightly Runs/Logs/<yyyy-MM-dd_HHmm>.md, agent logs in E:/GIT_ROOT/Projects/.overnight-logs
#   morning: Morning Runs/Morning Report.md,   Morning Runs/Logs/<yyyy-MM-dd_HHmm>.md, agent logs in E:/GIT_ROOT/Projects/.morning-logs
# Every run starts with a preflight: projects with blockers are skipped, and Nightly Runs/Preflight.md lists what needs you.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File overnight-run.ps1 [-Kind nightly|morning] [-Preflight | -DryRun] [-PerHarness 3] [-HoursPerProject 3]
#   -Kind       where results go (above); the scheduled task passes nightly. Default: morning if started 05:00-16:59, else nightly
#   -Preflight  only check (run it in the evening, fix what it lists, then let 23:00 run); exit code = number of blocked projects
param([ValidateSet('nightly', 'morning')][string]$Kind, [switch]$Preflight, [switch]$DryRun, [int]$PerHarness = 3, [double]$HoursPerProject = 3)
$ErrorActionPreference = 'Continue'
# One run at a time, however it was started (board button, scheduled "Agents Run HHMM" task, by hand): a second one exits.
$others = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe' OR Name='pwsh.exe'" | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -like '*-File*overnight-run.ps1*' -and $_.CommandLine -notlike '*-Preflight*' })
if (-not $Preflight -and $others) { Write-Output "Another run is going (pid $($others.ProcessId -join ', ')); not starting a second one."; exit 0 }
$vault         = 'F:\Vaults\LLMWiki'
$projects      = 'E:\GIT_ROOT\Projects'
$sparkProjects = '/home/snknitin/Workspace/GIT_ROOT/Projects'
$ssh           = "$env:WINDIR\System32\OpenSSH\ssh.exe"
$prioFile      = Join-Path $vault 'Nightly Runs\Project Priorities.md'
$preflightMd   = Join-Path $vault 'Nightly Runs\Preflight.md'
$prompt        = Get-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') -Raw -Encoding UTF8
$started       = Get-Date
if (-not $Kind) { $Kind = $(if ($started.Hour -ge 5 -and $started.Hour -lt 17) { 'morning' } else { 'nightly' }) }
$runsDir       = Join-Path $vault $(if ($Kind -eq 'morning') { 'Morning Runs' } else { 'Nightly Runs' })
$reportMd      = Join-Path $runsDir $(if ($Kind -eq 'morning') { 'Morning Report.md' } else { 'Overnight Report.md' })
$runLogDir     = Join-Path $runsDir 'Logs'   # dated copy of each real run's report, kept for history
$stamp         = $started.ToString('yyyy-MM-dd_HHmm')   # names this run's dated report and agent-log folder
$budget        = [int]($HoursPerProject * 3600)
$logDir        = Join-Path $projects ($(if ($Kind -eq 'morning') { '.morning-logs\' } else { '.overnight-logs\' }) + $stamp)
New-Item -ItemType Directory -Force $logDir | Out-Null

# Parse "- <folder> [@<harness>[:<model>]] - note" lines under "## Tonight". The "### Claude/Codex/Hermes" lane a line
# sits in picks its harness; an explicit @tag overrides the lane. First occurrence of a folder wins.
$queue = @(); $seen = @{}; $inTonight = $false; $lane = 'claude'
foreach ($line in Get-Content $prioFile -Encoding UTF8) {
    if ($line -match '^##\s') { $inTonight = $line -match '^##\s+Tonight'; $lane = 'claude'; continue }
    if ($inTonight -and $line -match '^###\s+(\w+)') { $lane = $Matches[1].ToLower(); continue }
    if ($inTonight -and $line -match '^\s*-\s+([A-Za-z0-9._-]+)(?:\s+@(\w+)(?::([\w./-]+))?)?' -and -not $seen[$Matches[1]]) {
        $seen[$Matches[1]] = $true
        $queue += [pscustomobject]@{ Name = $Matches[1]; Harness = $(if ($Matches[2]) { $Matches[2].ToLower() } else { $lane }); Model = $Matches[3] }
    }
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
Set-Content -Path $preflightMd -Value $pf -Encoding UTF8
if ($Preflight) { Write-Output ($pf -join "`n"); exit @($checks.Values | Where-Object { $_.Blockers }).Count }

# One agent run, inside a background job. Output goes to $log.
$worker = {
    param($dir, $harness, $model, $prompt, $log, $budget, $ssh, $sparkDir)
    $OutputEncoding = New-Object System.Text.UTF8Encoding $false
    Set-Location $dir
    $env:OVERNIGHT_RUN = '1'   # turns on the project's Stop-hook verify gate (Claude)
    switch ($harness) {
        'codex' {
            # @codex:<name> is a profile when ~/.codex/<name>.config.toml exists (model + reasoning effort), else a model id.
            $a = @('exec', '--dangerously-bypass-approvals-and-sandbox')
            if ($model -and (Test-Path (Join-Path $HOME ".codex\$model.config.toml"))) { $a += @('-p', $model) } elseif ($model) { $a += @('-m', $model) }
            $prompt | & codex @a - *> $log
        }
        'hermes' {
            if (-not $model) { $model = 'glm53-flash' }   # best local coding model (SecondSpark + ThirdSpark)
            $m = "-m $model"
            $remote = 'test -d {0} || {{ echo SPARK_MISSING; exit 3; }}; cd {0} && git pull --rebase -q; ~/.local/bin/hermes chat --query-file - -Q --yolo --in {0} --run-budget {1} {2}; echo SPARK_GIT dirty=$(git status --porcelain | wc -l) unpushed=$(git rev-list --count @{{u}}..HEAD)' -f $sparkDir, $budget, $m
            $prompt | & $ssh -o BatchMode=yes FirstSpark $remote *> $log
        }
        default {
            if (-not $model) { $model = 'opus' }   # coordinator; the builder subagent runs on sonnet
            $prompt | & claude -p --model $model --permission-mode bypassPermissions *> $log
        }
    }
}

$rows = @{}; $pending = New-Object System.Collections.ArrayList
foreach ($q in $queue) {
    $dir = Join-Path $projects $q.Name
    $rows[$q.Name] = [ordered]@{ Project = $q.Name; Harness = "$($q.Harness)$(if ($q.Model) { ':' + $q.Model })"; Verify = '-'; Git = '-'; Commits = 0; Note = '' }
    if ($checks[$q.Name].Blockers) { $rows[$q.Name].Note = 'skipped by preflight: ' + ($checks[$q.Name].Blockers -join '; ') }
    elseif ($DryRun) { $rows[$q.Name].Note = 'dry run: would run now' }
    else { [void]$pending.Add($q) }
}

function Complete-Run($q, $row) {
    $dir = Join-Path $projects $q.Name
    $log = Join-Path $logDir "$($q.Name).log"
    $text = $(if (Test-Path $log) { Get-Content $log -Raw -Encoding UTF8 } else { '' })
    if ($q.Harness -ne 'hermes' -and $text -match 'usage limit|limit reached|rate.limit|hit your limit') {
        $script:limited[$q.Harness] = $true; $row.Note += 'usage limit hit. '
    }
    if ($q.Harness -eq 'hermes') {
        if ($text -match 'SPARK_MISSING') { $row.Note += "not cloned on FirstSpark at $sparkProjects. " }
        if ($text -match 'SPARK_GIT dirty=(\d+) unpushed=(\d+)') { $row.Note += "FirstSpark: $($Matches[1]) uncommitted, $($Matches[2]) unpushed. " }
        git -C $dir pull --rebase --autostash -q 2>$null   # bring Hermes's pushed commits here for the gate
    }
    $row.Note += "log: $log"
}

$running = @{}; $limited = @{}
while ($pending.Count -or $running.Count) {
    # Start every pending project whose harness has a free slot, in list order.
    foreach ($q in @($pending)) {
        if ($limited[$q.Harness]) { $rows[$q.Name].Note = "not run: $($q.Harness) usage limit hit earlier tonight"; $pending.Remove($q); continue }
        if (@($running.Values | Where-Object { $_.Q.Harness -eq $q.Harness }).Count -ge $PerHarness) { continue }
        $pending.Remove($q)
        $job = Start-Job -ScriptBlock $worker -ArgumentList (Join-Path $projects $q.Name), $q.Harness, $q.Model, $prompt,
            (Join-Path $logDir "$($q.Name).log"), $budget, $ssh, "$sparkProjects/$($q.Name)"
        $running[$job.Id] = @{ Job = $job; Q = $q; Start = Get-Date }
    }
    if (-not $running.Count) { break }
    Wait-Job -Job @($running.Values | ForEach-Object { $_.Job }) -Any -Timeout 60 | Out-Null
    foreach ($id in @($running.Keys)) {
        $r = $running[$id]
        if ($r.Job.State -eq 'Running' -and ((Get-Date) - $r.Start).TotalSeconds -ge $budget + 300) {
            # shortcut: Stop-Job ends the job host, but a child claude/codex/ssh process can outlive it; kill it by hand if a timeout is reported.
            Stop-Job $r.Job; $rows[$r.Q.Name].Note += "timed out after $HoursPerProject h. "
        }
        if ($r.Job.State -ne 'Running') {
            Remove-Job $r.Job -Force; $running.Remove($id)
            Complete-Run $r.Q $rows[$r.Q.Name]
        }
    }
}

# Independent gate: the runner's own verify and git check, not the agent's claim.
foreach ($q in $queue) {
    $dir = Join-Path $projects $q.Name; $row = $rows[$q.Name]
    if (-not (Test-Path "$dir\scripts\verify.ps1")) { continue }
    & powershell -NoProfile -ExecutionPolicy Bypass -File "$dir\scripts\verify.ps1" *> (Join-Path $logDir "$($q.Name).verify.txt")
    $row.Verify = $(if ($LASTEXITCODE -eq 0) { 'PASS' } else { 'FAIL' })
    $dirty = git -C $dir status --porcelain 2>$null
    $ahead = git -C $dir rev-list --count '@{u}..HEAD' 2>$null
    $row.Git = $(if ($dirty) { 'uncommitted changes' } elseif ([int]$ahead -gt 0) { "$ahead unpushed" } else { 'clean, pushed' })
    $row.Commits = @(git -C $dir log --since=$($started.ToString('s')) --oneline 2>$null).Count
}

$md = @("# $(if ($Kind -eq 'morning') { 'Morning' } else { 'Overnight' }) Report", "",
        "Run started $($started.ToString('yyyy-MM-dd HH:mm')), finished $((Get-Date).ToString('HH:mm'))$(if ($DryRun) { ' (dry run)' }), $Kind run, up to $PerHarness per harness at once. Logs: ``$logDir``", "",
        "Verify is re-run by the runner on the desktop after each agent finishes (for @hermes, after pulling its pushed commits). Each project's ``REPORT.md`` has details and open questions.", "",
        "| Project | Harness | Verify | Git (desktop) | Commits tonight | Note |", "|---|---|---|---|---|---|")
$md += $queue | ForEach-Object { $r = $rows[$_.Name]; "| $($r.Project) | $($r.Harness) | $($r.Verify) | $($r.Git) | $($r.Commits) | $($r.Note) |" }
if (-not $queue) { $md += '| (Tonight list is empty) | | | | | |' }
New-Item -ItemType Directory -Force $runLogDir | Out-Null   # Morning Runs/Logs on the first morning run
Set-Content -Path $reportMd -Value $md -Encoding UTF8
if (-not $DryRun) { Set-Content -Path (Join-Path $runLogDir "$stamp.md") -Value $md -Encoding UTF8 }
Write-Output ($md -join "`n")
