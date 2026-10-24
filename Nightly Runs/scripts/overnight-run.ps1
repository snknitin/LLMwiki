# Overnight runner: works the "## Tonight" list in Nightly Runs/Project Priorities.md, every project at once (or up to -PerHarness per harness)
# (default 3 Claude + 3 Codex + 3 Hermes = 9 in parallel).
# @claude and @codex run here on the desktop; @hermes runs on FirstSpark over SSH. After each agent finishes,
# the runner re-runs that project's scripts/verify.ps1 itself and writes a report plus a dated copy per real run (never overwritten):
#   nightly: Nightly Runs/Overnight Report.md, Nightly Runs/Logs/<yyyy-MM-dd_HHmm>.md, agent logs in E:/GIT_ROOT/Projects/.overnight-logs
#   morning: Morning Runs/Morning Report.md,   Morning Runs/Logs/<yyyy-MM-dd_HHmm>.md, agent logs in E:/GIT_ROOT/Projects/.morning-logs
# Every run starts with a preflight: projects with blockers are skipped, and Nightly Runs/Preflight.md lists what needs you.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File overnight-run.ps1 [-Kind nightly|morning] [-Preflight | -DryRun] [-PerHarness N (default 0 = no limit)] [-Until 06:30] [-HoursPerProject 3]
#   -Kind       where results go (above); the scheduled task passes nightly. Default: morning if started 05:00-16:59, else nightly
#   -Until      a nightly run keeps its lanes working until this time (default 06:30): an agent that stops early with real
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
param([ValidateSet('nightly', 'morning')][string]$Kind, [switch]$Preflight, [switch]$DryRun, [int]$PerHarness = 0, [double]$HoursPerProject = 3, [string]$Until = '06:30', [switch]$NoPrep, [int]$PrepMinutes = 90, [switch]$PrepOnly, [switch]$Resume, [switch]$Scheduled, [int]$QaMinutes = 30,
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
function Get-OtherRuns { @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe' OR Name='pwsh.exe'" | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -like '*-File*overnight-run.ps1*' -and $_.CommandLine -notlike '*-Preflight*' }) }
$others = Get-OtherRuns
# A -Resume check with nothing to continue exits within seconds: wait that out, so a 23:00 start never loses to it.
if (-not $Preflight -and $others -and -not @($others | Where-Object { $_.CommandLine -notlike '*-Resume*' })) {
    $waitUntil = (Get-Date).AddSeconds(60)   # not $until: PowerShell names ignore case, so that would overwrite -Until
    while (@(Get-OtherRuns | Where-Object { $_.CommandLine -like '*-Resume*' }) -and (Get-Date) -lt $waitUntil) { Start-Sleep -Seconds 5 }
    $others = Get-OtherRuns
}
if (-not $Preflight -and -not $PrepOnly -and $others -and -not @($others | Where-Object { $_.CommandLine -notlike '*-PrepOnly*' -and $_.CommandLine -notlike '*-FixOnly*' })) {
    $waitUntil = (Get-Date).AddMinutes($PrepMinutes + 5)
    while ((Get-OtherRuns) -and (Get-Date) -lt $waitUntil) { Start-Sleep -Seconds 30 }
    $others = Get-OtherRuns
}
# A fix session ignores -Resume checks that have no cut-off run to continue: they only wait (for preps and fixes too),
# so counting them would deadlock the two.
if ($FixOnly -and -not (Test-Path (Join-Path $(if ($env:OVERNIGHT_VAULT) { $env:OVERNIGHT_VAULT } else { 'F:\Vaults\LLMWiki' }) 'Nightly Runs\.run-state.json'))) {
    $others = @($others | Where-Object { $_.CommandLine -notlike '*-Resume*' })
}
if (-not $Preflight -and $others) { Write-Output "Another run is going (pid $($others.ProcessId -join ', ')); not starting a second one."; exit 0 }
$vault         = $(if ($env:OVERNIGHT_VAULT) { $env:OVERNIGHT_VAULT } else { 'F:\Vaults\LLMWiki' })   # the env overrides are for test-qa.ps1's fixture
$projects      = $(if ($env:OVERNIGHT_PROJECTS) { $env:OVERNIGHT_PROJECTS } else { 'E:\GIT_ROOT\Projects' })
$sparkProjects = $(if ($env:OVERNIGHT_SPARK_PROJECTS) { $env:OVERNIGHT_SPARK_PROJECTS } else { '/home/snknitin/Workspace/GIT_ROOT/Projects' })
if ($sparkProjects -notmatch '^/[A-Za-z0-9/._-]+$') { throw 'Invalid Spark project root' }
$ssh           = "$env:WINDIR\System32\OpenSSH\ssh.exe"
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
    if (-not $model) { $model = 'glm53-flash' }
    $model = ($model -split '/')[-1].ToLower()
    if ($model -match 'qwen|spark-fast') { return 'qwen' }
    if ($model -match 'glm') { return 'glm' }
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
function Set-BuilderModels($queue) {
    foreach ($q in $queue) { if (-not $q.Model -and $roles[$q.Harness] -and $roles[$q.Harness].builder -match $specPattern -and $Matches[1] -eq $q.Harness -and $Matches[2]) { $q.Model = $Matches[2] } }
    return $queue
}
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
    # shortcut: a "Preview scripts deferred" heading in DECISIONS.md silences preview.* until the agent adds them (the shared rule tells it when); drop the heading to be nagged again
    $deferred = [bool](Select-String -Path (Join-Path $dir 'DECISIONS.md') -Pattern '^#+ .*preview scripts deferred' -Quiet -ErrorAction SilentlyContinue)
    foreach ($f in 'AGENTS.md', 'CLAUDE.md', 'scripts\verify.sh', 'scripts\stop-gate.ps1', 'scripts\preview.ps1', 'scripts\preview.sh', 'PROGRESS.md', 'FEEDBACK.md', 'DECISIONS.md') {
        if ($f -like 'scripts\preview.*' -and $deferred) { continue }
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
function Get-Upkeep($queue, [switch]$CheckVerify) {
    $order = @(); $section = ''; $parked = @{}
    foreach ($line in Get-Content $prioFile -Encoding UTF8) {
        if ($line -match '^##\s+(.*)$') { $section = $Matches[1]; continue }
        if ($section -match '^Priority order' -and $line -match '^\s*\d+\.\s+([A-Za-z0-9._-]+)') { $order += $Matches[1] }
        if ($section -match '^(Active|Archived)' -and $line -match '^\s*-\s+([A-Za-z0-9._-]+)') { $parked[$Matches[1]] = $true }
    }
    $top = @(@($order | Where-Object { -not $parked[$_] } | Select-Object -Unique -First 10) + @($queue | ForEach-Object { $_.Name }) | Select-Object -Unique)
    $items = @()
    foreach ($name in $top) {
        $dir = Join-Path $projects $name
        if (-not (Test-Path "$dir\BUILD_SPEC.md")) { $items += [pscustomobject]@{ Project = $name; Action = 'owner'; Why = 'no BUILD_SPEC.md yet, so it cannot be made overnight-ready' }; continue }
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
# Who preps (Nightly Runs/prep.json, picked on the board): Desktop Qwen through local-agent.py, or Claude / Codex.
$prepModel = 'hermes:qwen3.8-27b-desktop'
try { $m = (Get-Content (Join-Path $vault 'Nightly Runs\prep.json') -Raw -ErrorAction Stop | ConvertFrom-Json).model } catch { $m = $null }
if ($m -match '^(hermes:qwen3\.8-27b-desktop|hermes:glm53-flash|hermes:qwen3\.6-35b-a3b|claude:[a-z0-9][\w.-]{0,40}|codex(:[a-z0-9][\w.-]{0,60})?)$') { $prepModel = $m }
# Runs inside the prep and slice-advance jobs (jobs see no functions), from the Projects root so no project's deny rules apply.
$prepAgent = @'
param($spec, $dir, $text, $log, $helper, $budget)
$OutputEncoding = New-Object System.Text.UTF8Encoding $false
Set-Location $dir
$model = ($spec -split ':', 2)[1]
if ($spec -in 'hermes:glm53-flash', 'hermes:qwen3.6-35b-a3b') {
    # GLM 5.3 Flash and Qwen 3.6 35B are reachable only from FirstSpark (key-protected loopback LiteLLM), so prep runs there through Hermes'
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
    $remote = "cd $spark && $pulls; timeout $([int]$budget + 120) ~/.local/bin/hermes -p agents-board-prep chat -m $model --query-file - -Q --yolo --in $spark --max-turns 400 --run-budget $budget"
    $sparkText | & "$env:WINDIR\System32\OpenSSH\ssh.exe" -o BatchMode=yes FirstSpark $remote *>> $log
    $code = $LASTEXITCODE
    foreach ($p in $items) { git -C (Join-Path $dir $p) pull --rebase -q *>> $log }   # bring FirstSpark's prep commits to the desktop
    $global:LASTEXITCODE = $code
} elseif ($spec -like 'hermes:*') {
    $text | & python $helper --base-url http://127.0.0.1:11435/v1 --model qwen3.8-27b-desktop --workdir $dir --budget $budget *>> $log
} elseif ($spec -like 'codex*') {
    $a = @('exec', '--dangerously-bypass-approvals-and-sandbox')
    if ($model -and (Test-Path (Join-Path $HOME ".codex\$model.config.toml"))) { $a += @('-p', $model) } elseif ($model) { $a += @('-m', $model) }
    $text | & codex @a - *>> $log
} else {
    $effort = 'high'
    if ($model -match '^(.+)-(low|medium|high|xhigh|max)$') { $model = $Matches[1]; $effort = $Matches[2] }
    $text | & claude -p -n 'Prep' --model $model --effort $effort --permission-mode bypassPermissions *>> $log
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
$upkeep = @(Get-Upkeep $queue -CheckVerify:(-not $Preflight -and -not $QaOnly -and -not $prepDone))
$prepWork = @($upkeep | Where-Object { $_.Action -ne 'owner' })
$prepHeads = @{}
foreach ($item in $prepWork) { $prepHeads[$item.Project] = "$(git -C (Join-Path $projects $item.Project) rev-parse HEAD 2>$null)" }
if ($recordPrep) { $prepReceipt.projects = @(@($queue | ForEach-Object Name) + @($upkeep | ForEach-Object Project) | Select-Object -Unique); Save-PrepReceipt 'running' $upkeep @() "Preparing the current queue with $prepModel" }
if ($prepWork -and -not $Preflight -and -not $DryRun -and -not $NoPrep) {
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
# ---- Handoff: leftover edits never block a run ----
# Uncommitted work in a tonight project (desktop or FirstSpark clone) is committed on its own pushed wip/handoff-* branch,
# the checkout goes back to clean, and PROGRESS.md gets a HANDOFF entry so tonight's agent reviews and continues it.
# Left alone (and still blocking, with the reason): files edited in the last 10 minutes, a Hermes session still going,
# and anything that looks like a secret.
$handoff = @{}; $leftAlone = @{}
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
    if ($paths | Where-Object { $f = Join-Path $dir $_; (Test-Path $f) -and (Get-Item $f).LastWriteTime -gt (Get-Date).AddMinutes(-10) }) { $leftAlone[$name] = 'uncommitted changes on the desktop edited in the last 10 minutes (someone may be working); left alone'; return }
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
if (-not $Preflight -and -not $DryRun -and -not $PrepOnly -and -not $QaOnly) {
    foreach ($q in $queue) { $d = Join-Path $projects $q.Name; if (Test-Path "$d\.git") { Save-DesktopHandoff $q.Name $d } }
    $sparkNames = @($queue | Where-Object { $_.Harness -eq 'hermes' } | ForEach-Object { $_.Name })
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
            switch ($f[1]) {
                'saved' { git -C $d fetch -q 2>$null; Add-HandoffNote $d 'FirstSpark' $sb $f[2] ($f[3] -eq '1'); $handoff[$n] += "FirstSpark edits handed off on $sb ($($f[2])). " }
                'busy' { $leftAlone[$n] = 'a Hermes session is still running on FirstSpark; its uncommitted changes were left alone' }
                'secret' { $leftAlone[$n] = 'uncommitted changes on FirstSpark include a file that looks like a secret; commit or remove it yourself' }
                'recent' { $leftAlone[$n] = 'uncommitted changes on FirstSpark edited in the last 10 minutes; left alone' }
                default { $leftAlone[$n] = "uncommitted changes on FirstSpark; could not create $sb" }
            }
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
        if ($leftAlone[$q.Name]) { $b += $leftAlone[$q.Name] }   # the handoff above saved everything else
        elseif (git -C $dir status --porcelain 2>$null) { $w += 'uncommitted changes on the desktop: saved on a wip/handoff branch and handed to tonight''s agent when the run starts' }
        if ($q.Harness -eq 'hermes') {
            $st = "$($sparkState[$q.Name])"
            if ($st -eq 'unreachable') { $b += 'FirstSpark unreachable over SSH' }
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
    $pf += '', '## Top 10 upkeep', '', "Before the lanes start, the prep agent does the PREP items (make-overnight-ready, build-tree, structure, mvp, advance; never moves lanes): at the next real run, or right away when the Agents board runs -PrepOnly. OWNER items need you. Advance is checked at run time.", '',
        '| Project | Action | Who | Why |', '|---|---|---|---|'
    $pf += $upkeep | ForEach-Object { "| $($_.Project) | $($_.Action) | $(if ($_.Action -eq 'owner') { 'OWNER' } else { 'PREP' }) | $($_.Why) |" }
}
Set-Content -Path $preflightMd -Value $pf -Encoding UTF8
if ($recordPrep) {
    $remaining = @($upkeep)
    # A commit is required when a passing target needed advancement. Process exit alone is not readiness.
    foreach ($item in @($prepWork | Where-Object { $_.Action -match 'advance' })) {
        $headNow = "$(git -C (Join-Path $projects $item.Project) rev-parse HEAD 2>$null)"
        if ($headNow -eq $prepHeads[$item.Project]) { $remaining += @{ Project = $item.Project; Action = 'advance'; Why = 'Passing target was not advanced to a committed next scope; review its owner gates or completion decision' } }
    }
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
    param($dir, $harness, $model, $prompt, $log, $budget, $ssh, $sparkDir, $sessionName, $isQa, $reviewHead)
    Set-Content -Path "$log.pid" -Value $PID   # so the runner can end this job's whole process tree at the end time
    $OutputEncoding = New-Object System.Text.UTF8Encoding $false
    Set-Location $dir
    if (-not $isQa) { $env:OVERNIGHT_RUN = '1' }   # turns on the project's Stop-hook verify gate (Claude); QA must be free to end on a failing verify
    switch ($harness) {
        'codex' {
            # @codex:<name> is a profile when ~/.codex/<name>.config.toml exists (model + reasoning effort), else a model id.
            $a = @('exec', '--dangerously-bypass-approvals-and-sandbox')
            if ($model -and (Test-Path (Join-Path $HOME ".codex\$model.config.toml"))) { $a += @('-p', $model) } elseif ($model) { $a += @('-m', $model) }
            $prompt | & codex @a - *>> $log
        }
        'hermes' {
            if (-not $model) { $model = 'glm53-flash' }   # best local coding model (SecondSpark + ThirdSpark)
            $m = "--provider custom:local-models --base-url http://127.0.0.1:4000/v1 -m $model"
            # .git/overnight-hermes.pid: a session cut off from this side (dropped SSH) can still be running on FirstSpark;
            # never start a second one in the same repo (SPARK_BUSY makes the runner wait and try again).
            if ($isQa -and $model -in 'qwen3.6-35b-a3b', 'spark-fast') {
                # Dedicated local profile: no subscription plugins, inherited keys, or cloud fallback.
                $m = 'python3 ~/.agents-board/local-agent.py --base-url http://127.0.0.1:8000/v1 --model spark-fast --workdir {0} --budget {1}' -f $sparkDir, $budget
                if ($isQa) { $m += ' --qa-result' }
            } else { $m = '~/.local/bin/hermes chat --query-file - -Q --yolo --in {0} --run-budget {1} {2}' -f $sparkDir, $budget, $m }
            $headCheck = $(if ($isQa) { '[ $(git rev-parse HEAD) = {0} ] || {{ echo SPARK_HEAD_MISMATCH; exit 6; }}; ' -f $reviewHead } else { '' })
            $remote = 'test -d {0} || {{ echo SPARK_MISSING; exit 3; }}; cd {0} || exit 3; p=.git/overnight-hermes.pid; if [ -f $p ] && kill -0 $(cat $p) 2>/dev/null; then echo SPARK_BUSY; exit 4; fi; echo $$ > $p; trap ''rm -f $p'' EXIT; git pull --rebase -q || exit 5; {2}{1}; rc=$?; echo SPARK_GIT dirty=$(git status --porcelain | wc -l) unpushed=$(git rev-list --count @{{u}}..HEAD); exit $rc' -f $sparkDir, $m, $headCheck
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
    $text = ($text -split '(?m)^=== session \d+ ')[-1]   # only this session's output; earlier sessions were already read
    $text = $text -replace "`0", ''   # *>> appends UTF-16 to a UTF-8 file: drop the NULs so the checks below can match
    if ($q.Harness -ne 'hermes' -and $text -match $limitHit) {
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
    param($agent, $spec, $root, $text, $log, $helper)
    Set-Content -Path "$log.pid" -Value $PID
    & ([scriptblock]::Create($agent)) $spec $root $text $log $helper 1800
}
function Start-Advance($q) {
    $name = $q.Name; $dir = Join-Path $projects $name
    $issues = @(Compare-Integrity $integrity[$name] (Get-Integrity $dir))   # checked before the advance re-baselines it
    if ($issues) { $rows[$name].Note += "not advanced: SUSPECT ($($issues -join '; ')). "; return }
    $now = Get-Date
    $advances[$name] = 1 + [int]$advances[$name]
    $text = (Get-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') -Raw -Encoding UTF8) +
        "`n- ${name}: advance (tonight's target passed during the run and the lanes are already going: do only this item, quickly)`n"
    $log = Join-Path $logDir "$name.advance.txt"; Remove-Item "$log.pid" -ErrorAction SilentlyContinue
    $job = Start-Job -ScriptBlock $advanceWorker -ArgumentList $prepAgent, $prepModel, $projects, $text, $log, (Join-Path $PSScriptRoot 'local-agent.py')
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

# Each project's HEAD as the lanes start: the run's commits are exactly <before>..<after>, so the Agents board's Review tab
# never has to guess from times (Hermes's commits reach the desktop when its session ends, after the gate's pull).
$heads = [ordered]@{}
foreach ($q in $pending) { $h = git -C (Join-Path $projects $q.Name) rev-parse HEAD 2>$null; if ($h) { $heads[$q.Name] = "$h" } }
if ($QaOnly) { $heads[$Project] = "$qaBase"; $pending.Clear() }
$qaResults = [ordered]@{}   # QA per project: @{ state = running|pass|findings|skipped|failed; findings; reason }, read by the Agents board
$running = @{}; $limitUntil = @{}; $advances = @{}; $sessions = @{}; $waitNet = @{}; $netRetries = @{}; $nextNetCheck = @{}; $noSpark = @{}
# A resumed run keeps the usage limits the cut-off run had hit.
if ($Resume -and $state.qa) { foreach ($p in $state.qa.PSObject.Properties) { $qaResults[$p.Name] = @{ state = "$($p.Value.state)"; findings = [int]$p.Value.findings; reason = "$($p.Value.reason)" } } }
if ($Resume -and $state.limitUntil) { foreach ($p in $state.limitUntil.PSObject.Properties) { $limitUntil[$p.Name] = [datetime]::Parse($p.Value) } }
# limitUntil (harnesses parked on a usage limit, as ISO strings) is also read by the Agents board's Usage limits panel.
function Save-RunState {
    $parked = @{}; foreach ($k in @($limitUntil.Keys)) { $parked[$k] = $limitUntil[$k].ToString('o') }
    @{ kind = $Kind; started = $started.ToString('o'); until = $deadline.ToString('o'); heads = $heads; limitUntil = $parked; qa = $qaResults } | ConvertTo-Json -Depth 5 | Set-Content -Path $stateFile -Encoding UTF8
}
function Test-Parked($tool) { return [bool]($limitUntil[$tool] -and (Get-Date) -lt $limitUntil[$tool]) }
# The harness a project's next session runs on. A Claude project whose harness is parked on its usage limit runs on Codex,
# or on Hermes (local, no quota) when Codex is parked too, instead of idling until the reset; its next session goes back
# to Claude once that has reset. Codex and Hermes projects wait for their own reset. Never another account of the same tool.
# $null = wait. (test-fallback.ps1 checks this.)
function Get-SessionHarness($q) {
    if (-not (Test-Parked $q.Harness)) { return $q.Harness }
    if ($q.Harness -ne 'claude') { return $null }
    return @('codex', 'hermes') | Where-Object { -not (Test-Parked $_) -and -not ($_ -eq 'hermes' -and $noSpark[$q.Name]) } | Select-Object -First 1
}
if ($pending.Count) { Save-RunState }
while ($pending.Count -or $running.Count) {
    # Start every pending project whose harness has a free slot, in list order (first sessions before relaunches).
    foreach ($q in @($pending)) {
        $left = [int]($deadline - (Get-Date)).TotalSeconds
        if ($left -lt $minSession) { if (-not $sessions[$q.Name]) { $rows[$q.Name].Note = "not run: less than 30 min left before $($deadline.ToString('HH:mm'))" }; $pending.Remove($q); continue }
        $use = Get-SessionHarness $q
        if (-not $use) { continue }   # waits for a usage-limit reset
        if ($waitNet[$q.Name]) {   # checked at most once a minute per tool
            if ($nextNetCheck[$use] -and (Get-Date) -lt $nextNetCheck[$use]) { continue }
            if (-not (Test-Online $use)) { $nextNetCheck[$use] = (Get-Date).AddMinutes(1); continue }
            $waitNet.Remove($q.Name)
        }
        if ($PerHarness -gt 0 -and @($running.Values | Where-Object { $_.Q.Harness -eq $use }).Count -ge $PerHarness) { continue }   # 0 = no limit: every project in the lane at once
        $pending.Remove($q)
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
        $job = Start-Job -ScriptBlock $worker -ArgumentList $dir, $run.Harness, $run.Model, $prompt, $log, $left, $ssh, "$sparkProjects/$($q.Name)", $sessionName, $false
        $running[$job.Id] = @{ Job = $job; Q = $run; Start = Get-Date; Head = (git -C $dir rev-parse HEAD 2>$null); PidFile = "$log.pid" }
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
            $own = $(if ($r.Q.Home) { $r.Q.Home } else { $r.Q })   # a fallback session's project goes back to its own lane
            if ($r.Advance) {
                $integrity[$name] = Get-Integrity $dir   # the advance legitimately extends verify.ps1: that is the new baseline
                if (-not $row.TimedOut -and (Test-Progress $dir $r.Head)) { $row.Note += "advanced to its next slices at $((Get-Date).ToString('HH:mm')). "; [void]$pending.Add($r.Q) }
                elseif (-not $row.TimedOut) { $row.Note += "not advanced: the next work waits on an owner gate, or the project is built (see Prep Report). " }
                continue
            }
            $row.Minutes += [int]((Get-Date) - $r.Start).TotalMinutes
            $text = Complete-Run $r.Q $row
            if ($row.TimedOut) { continue }
            # A Hermes fallback for a project not cloned on FirstSpark: no more Hermes fallbacks for it; it waits for a reset.
            if ($r.Q.Home -and $r.Q.Harness -eq 'hermes' -and "$text" -match 'SPARK_MISSING') { $noSpark[$name] = $true; [void]$pending.Add($own); continue }
            # Stopped early with real progress and time left: start it again; it resumes from PROGRESS.md's next open item.
            if ($sessions[$name] -lt $maxSessions -and (Test-Progress $dir $r.Head)) { [void]$pending.Add($own) }
            elseif ($r.Q.Harness -ne 'hermes' -and "$text" -match $limitHit) { [void]$pending.Add($own) }   # on another harness, or after the reset
            elseif ("$text" -match $netError -and [int]$netRetries[$name] -lt 6) {
                $netRetries[$name] = 1 + [int]$netRetries[$name]; $waitNet[$name] = $true
                $row.Note += "connection lost at $((Get-Date).ToString('HH:mm')), retried when back. "; [void]$pending.Add($own)
            }
            # No new work: tonight's target is probably done. Advance it (at most twice a run) while an hour is left.
            elseif ([int]$advances[$name] -lt 2 -and ($deadline - (Get-Date)).TotalMinutes -gt 60) { Start-Advance $own }
        }
    }
}
foreach ($name in @($sessions.Keys)) { if ($sessions[$name] -gt 1) { $rows[$name].Note = "$($sessions[$name]) sessions. " + $rows[$name].Note } }

# ---- QA pass: after a project's builder sessions, one session on the lane's QA harness (another model family) ----
# It runs verify, exercises the changed screens, checks every task marked done tonight for evidence, and writes findings
# (agent-rules/qa-prompt.md). Skipped with a reason when there is no real commit, QA is off (qa=off or roles.json), or its
# harness is parked on a usage limit. QA may change only the files in $qaAllowed; the runner checks the commits it made.
# The result goes to .run-state.json (live) and under the report table, and the Agents board shows it as a badge.
$qaPromptFile = Join-Path $vault 'Nightly Runs\agent-rules\qa-prompt.md'
$qaAllowed = 'REPORT.md', 'FEEDBACK.md', 'BUILD_SPEC.md', 'PROGRESS.md'   # BUILD_SPEC/PROGRESS only to revert a "done" mark that has no evidence
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
    if ($qaResults[$name] -and $qaResults[$name].state -ne 'running') { continue }   # a resumed run already finished this one
    if (-not (Test-Progress $dir $heads[$name])) { Set-Qa $name 'skipped' 'no real commit tonight'; continue }
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
    [void]$qaQueue.Add(@{ Q = $q; Plan = $plan })
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
        if (Test-Parked $fam) {
            $fallback = Get-QaPlan $item.Q $roles -Fallback
            if (-not $item.Plan.FallbackUsed -and -not $fallback.Skip -and -not (Test-Parked $fallback.Family) -and $cliOk[$fallback.Family]) {
                $rows[$name].Note += "Primary QA $($item.Plan.Spec) parked; using fallback $($fallback.Spec). "
                $item.Plan = $fallback; $fam = $fallback.Family
            } else { $qaQueue.Remove($item); Set-Qa $name 'skipped' "$fam hit its usage limit; no available fallback QA"; continue }
        }
        if ($fam -eq 'hermes' -and -not $localQaReady) { $qaQueue.Remove($item); Set-Qa $name 'failed' 'local QA launcher deployment failed'; continue }
        # FirstSpark Qwen is shared with apps. One complete local review at a time.
        $qaLimit = $(if ($fam -eq 'hermes') { 1 } else { $PerHarness })
        if ($qaLimit -gt 0 -and @($qaRunning.Values | Where-Object { $_.Plan.Family -eq $fam }).Count -ge $qaLimit) { continue }
        $qaQueue.Remove($item)
        $suffix = $(if ($item.Plan.FallbackUsed) { 'qa-fallback' } else { 'qa' })
        $log = Join-Path $logDir "$name.$suffix.txt"   # separate attempt logs: never accept a stale primary result
        Remove-Item "$log.pid" -ErrorAction SilentlyContinue
        $head = "$(git -C $dir rev-parse HEAD 2>$null)"
        $shots = $(if ($fam -eq 'hermes') { "/home/snknitin/.agents-board/qa/$stamp/$name" } else { Join-Path $logDir "_qa\$name" })
        $platform = $(if ($fam -eq 'hermes') { 'You are on Linux: use scripts/verify.sh and scripts/preview.sh when present. If absent, reproduce verify.ps1 steps with the available Linux commands; do not invoke a Windows path or claim unavailable checks passed.' } else { '' })
        $text = $qaPromptText + "`n---`nThis QA session: project folder $name, date for the REPORT.md section $($started.ToString('yyyy-MM-dd')), the builder's commits tonight are $($heads[$name])..$head (git log -p that range), put screenshots in $shots (outside the repo, never commit them). $platform`n"
        $sessionName = "$name $([char]0x00B7) QA of $($started.ToString('MMM d', [Globalization.CultureInfo]::InvariantCulture))"
        $job = Start-Job -ScriptBlock $worker -ArgumentList $dir, $fam, $item.Plan.Model, $text, $log, ($QaMinutes * 60), $ssh, "$sparkProjects/$name", $sessionName, $true, $head
        $qaRunning[$job.Id] = @{ Job = $job; Q = $item.Q; Plan = $item.Plan; Start = Get-Date; Head = $head; Dirty = @(git -C $dir status --porcelain 2>$null); Log = $log }
        Set-Qa $name 'running'
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
        $text = "$(Get-Content $r.Log -Raw -Encoding UTF8 -ErrorAction SilentlyContinue)" -replace "`0", ''
        if ($fam -eq 'hermes') { git -C $dir pull --rebase --autostash -q 2>$null }   # its commits reach the desktop only now
        # Put back what QA's verify run re-took (tracked screenshots), then look at what QA itself committed.
        $byVerify = @(git -C $dir status --porcelain 2>$null | Where-Object { $_ -notin $r.Dirty -and $_ -match '^ M ' } | ForEach-Object { $_.Substring(3) } | Where-Object { $_ -notin $qaAllowed })
        if ($byVerify) { git -C $dir checkout -- $byVerify 2>$null }
        $foreign = @(git -C $dir diff --name-only $r.Head HEAD 2>$null | Where-Object { $_ -notin $qaAllowed })
        $hit = [regex]::Matches($text, '(?m)^\s*QA RESULT:\s*(pass|findings\s*=\s*(\d+))\s*$')
        $by = $r.Plan.Spec
        $rows[$name].Note = "$($rows[$name].Note.TrimEnd()) QA log: $($r.Log)."
        if ($timedOut) { Set-Qa $name 'failed' "timed out after $QaMinutes min" 0 $by }
        elseif ($foreign) { Set-Qa $name 'failed' "QA changed files it may not: $($foreign -join ', '); see git log $($r.Head)..HEAD" 0 $by }
        elseif ($hit.Count) {
            $n = $(if ($hit[$hit.Count - 1].Groups[2].Success) { [int]$hit[$hit.Count - 1].Groups[2].Value } else { 0 })
            if ($n -gt 0) { Set-Qa $name 'findings' '' $n $by } else { Set-Qa $name 'pass' '' 0 $by }
        }
        elseif ($fam -ne 'hermes' -and $text -match $limitHit) { $limitUntil[$fam] = Get-LimitReset $text; Set-Qa $name 'skipped' "$fam hit its usage limit during QA; resets $($limitUntil[$fam].ToString('HH:mm'))" 0 $by }
        elseif ($text -match 'SPARK_MISSING') { Set-Qa $name 'skipped' "not cloned on FirstSpark at $sparkProjects" 0 $by }
        elseif ($text -match 'SPARK_BUSY') { Set-Qa $name 'skipped' 'a Hermes session is still running in that repo on FirstSpark' 0 $by }
        elseif ($text -match 'SPARK_HEAD_MISMATCH') { Set-Qa $name 'failed' 'FirstSpark HEAD differs from the desktop commit being reviewed' 0 $by }
        else { Set-Qa $name 'failed' 'the QA session ended without a "QA RESULT:" line' 0 $by }
        # Retry infrastructure/limit failures once on the configured fallback. Findings are a completed review,
        # and forbidden edits are an integrity failure: neither is replaced by a second judge's opinion.
        if (-not $r.Plan.FallbackUsed -and -not $foreign -and $qaResults[$name].state -in 'failed', 'skipped') {
            $fallback = Get-QaPlan $r.Q $roles -Fallback
            if (-not $fallback.Skip -and $fallback.Spec -ne $r.Plan.Spec -and $cliOk[$fallback.Family] -and -not (Test-Parked $fallback.Family)) {
                $rows[$name].Note += "Retrying QA on fallback $($fallback.Spec). "
                [void]$qaQueue.Add(@{ Q = $r.Q; Plan = $fallback })
                Set-Qa $name 'running'
            }
        }
    }
}

# Independent gate: the runner's own verify and git check, not the agent's claim.
foreach ($q in $queue) {
    $dir = Join-Path $projects $q.Name; $row = $rows[$q.Name]
    if (-not (Test-Path "$dir\scripts\verify.ps1")) { continue }
    $dirtyBefore = @(git -C $dir status --porcelain 2>$null)
    & powershell -NoProfile -ExecutionPolicy Bypass -File "$dir\scripts\verify.ps1" *> (Join-Path $logDir "$($q.Name).verify.txt")
    $row.Verify = $(if ($LASTEXITCODE -eq 0) { 'PASS' } else { 'FAIL' })
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
    $row.Commits = @(git -C $dir log --since=$($started.ToString('s')) --oneline 2>$null).Count
    if ($heads[$q.Name]) { $headAfter = git -C $dir rev-parse HEAD 2>$null; $row.Heads = "$($heads[$q.Name])..$headAfter"; $row.Commits = [int](git -C $dir rev-list --count $row.Heads 2>$null) }
}

$md = @("# $(if ($Kind -eq 'morning') { 'Morning' } else { 'Overnight' }) Report", "",
        "Run started $($started.ToString('yyyy-MM-dd HH:mm')), finished $((Get-Date).ToString('HH:mm'))$(if ($DryRun) { ' (dry run)' }), $Kind run, $(if ($PerHarness -gt 0) { "up to $PerHarness per harness" } else { 'every project at once' }). Logs: ``$logDir``", "",
        ($(if ($prepWork -and -not $DryRun -and -not $NoPrep) { "Prep before the lanes: $($prepWork.Count) top-10 upkeep item(s); see ``Nightly Runs/Prep Report.md`` and ``$logDir\_prep.log``. " } else { '' }) +
        "Verify is re-run by the runner on the desktop after each agent finishes (for @hermes, after pulling its pushed commits). Each project's ``REPORT.md`` has details and open questions."), "",
        "| Project | Harness | Verify | Git (desktop) | Commits tonight | Note |", "|---|---|---|---|---|---|")
$md += $queue | ForEach-Object { $r = $rows[$_.Name]; "| $($r.Project) | $($r.Harness) | $($r.Verify) | $($r.Git) | $($r.Commits) | $($r.Note) |" }
if (-not $queue) { $md += '| (Tonight list is empty) | | | | | |' }
$ranges = @($queue | Where-Object { $rows[$_.Name].Heads } | ForEach-Object { "- ``$($_.Name)``: $($rows[$_.Name].Heads)" })
if ($ranges) { $md += @('', 'HEAD before..after each project''s lanes (the Agents board Review tab lists exactly these commits):') + $ranges }
$qaLines = @($queue | Where-Object { $qaResults[$_.Name] } | ForEach-Object { "- ``$($_.Name)``: QA $(Format-Qa $qaResults[$_.Name])" })
if ($qaLines) { $md += @('', 'QA after the builder sessions (the Agents board shows these as badges):') + $qaLines }
New-Item -ItemType Directory -Force $runLogDir | Out-Null   # Morning Runs/Logs on the first morning run
Set-Content -Path $reportMd -Value $md -Encoding UTF8
if (-not $DryRun) { Set-Content -Path (Join-Path $runLogDir "$stamp.md") -Value $md -Encoding UTF8 }
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
