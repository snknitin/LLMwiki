# Overnight runner: works the "## Tonight" list in Nightly Runs/Project Priorities.md, up to -PerHarness projects per harness at once
# (default 3 Claude + 3 Codex + 3 Hermes = 9 in parallel).
# @claude and @codex run here on the desktop; @hermes runs on FirstSpark over SSH. After each agent finishes,
# the runner re-runs that project's scripts/verify.ps1 itself and writes Nightly Runs/Overnight Report.md (plus a dated copy in Nightly Runs/Logs).
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File overnight-run.ps1 [-DryRun] [-PerHarness 3] [-HoursPerProject 3]
param([switch]$DryRun, [int]$PerHarness = 3, [double]$HoursPerProject = 3)
$ErrorActionPreference = 'Continue'
$vault         = 'F:\Vaults\LLMWiki'
$projects      = 'E:\GIT_ROOT\Projects'
$sparkProjects = '/home/snknitin/Workspace/GIT_ROOT/Projects'
$ssh           = "$env:WINDIR\System32\OpenSSH\ssh.exe"
$prioFile      = Join-Path $vault 'Nightly Runs\Project Priorities.md'
$reportMd      = Join-Path $vault 'Nightly Runs\Overnight Report.md'
$runLogDir     = Join-Path $vault 'Nightly Runs\Logs'   # dated copy of each real run's report, kept for history
$prompt        = Get-Content (Join-Path $vault 'Local_Setup\agent-rules\overnight-prompt.md') -Raw -Encoding UTF8
$started       = Get-Date
$budget        = [int]($HoursPerProject * 3600)
$logDir        = Join-Path $projects (".overnight-logs\" + $started.ToString('yyyy-MM-dd_HHmm'))
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

# One agent run, inside a background job. Output goes to $log.
$worker = {
    param($dir, $harness, $model, $prompt, $log, $budget, $ssh, $sparkDir)
    $OutputEncoding = New-Object System.Text.UTF8Encoding $false
    Set-Location $dir
    $env:OVERNIGHT_RUN = '1'   # turns on the project's Stop-hook verify gate (Claude)
    switch ($harness) {
        'codex' {
            $a = @('exec', '--dangerously-bypass-approvals-and-sandbox'); if ($model) { $a += @('-m', $model) }
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
    if (-not (Test-Path "$dir\scripts\verify.ps1"))  { $rows[$q.Name].Note = 'skipped: no scripts/verify.ps1 (not overnight-ready)' }
    elseif ($q.Harness -notin 'claude', 'codex', 'hermes') { $rows[$q.Name].Note = "skipped: unknown harness @$($q.Harness)" }
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

$md = @("# Overnight Report", "",
        "Run started $($started.ToString('yyyy-MM-dd HH:mm')), finished $((Get-Date).ToString('HH:mm'))$(if ($DryRun) { ' (dry run)' }), up to $PerHarness per harness at once. Logs: ``$logDir``", "",
        "Verify is re-run by the runner on the desktop after each agent finishes (for @hermes, after pulling its pushed commits). Each project's ``REPORT.md`` has details and open questions.", "",
        "| Project | Harness | Verify | Git (desktop) | Commits tonight | Note |", "|---|---|---|---|---|---|")
$md += $queue | ForEach-Object { $r = $rows[$_.Name]; "| $($r.Project) | $($r.Harness) | $($r.Verify) | $($r.Git) | $($r.Commits) | $($r.Note) |" }
if (-not $queue) { $md += '| (Tonight list is empty) | | | | | |' }
Set-Content -Path $reportMd -Value $md -Encoding UTF8
if (-not $DryRun) { Set-Content -Path (Join-Path $runLogDir "$($started.ToString('yyyy-MM-dd_HHmm')) Overnight Report.md") -Value $md -Encoding UTF8 }
Write-Output ($md -join "`n")
