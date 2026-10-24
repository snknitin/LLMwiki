# Real GLM prep through the runner's own prep code ($prepAgent), for one project and action given here, from the
# desktop Projects root: FirstSpark pulls/clones, Hermes agents-board-prep (GLM 5.3 Flash) preps and pushes there,
# the desktop pulls. Then prints what git shows. Usage:
#   powershell -File test-prep-glm.ps1 -Project motto-agent-council -Action 'build-tree + structure + mvp' -Why '...'
param([Parameter(Mandatory)][string]$Project, [Parameter(Mandatory)][string]$Action, [string]$Why = 'qualification', [int]$Minutes = 90)
$ErrorActionPreference = 'Continue'
$projects = 'E:\GIT_ROOT\Projects'; $vault = 'F:\Vaults\LLMWiki'
$ast = [Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'overnight-run.ps1'), [ref]$null, [ref]$null)
$assign = $ast.Find({ param($n) $n -is [Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -eq '$prepAgent' }, $true)
$prepAgent = $assign.Right.Expression.Value
if (-not $prepAgent) { throw 'Could not read $prepAgent from overnight-run.ps1' }
$dir = Join-Path $projects $Project
$before = "$(git -C $dir rev-parse HEAD)"
$log = Join-Path $env:TEMP "prep-glm-$Project-$(Get-Date -Format yyyyMMdd-HHmmss).log"
$text = (Get-Content (Join-Path $vault 'Nightly Runs\agent-rules\prep-prompt.md') -Raw -Encoding UTF8) + "`n- ${Project}: $Action ($Why)`n"
$started = Get-Date
$job = Start-Job -ScriptBlock { param($agent, $a) & ([scriptblock]::Create($agent)) @a } -ArgumentList $prepAgent, @('hermes:glm53-flash', $projects, $text, $log, '', ($Minutes * 60))
if (-not (Wait-Job $job -Timeout ($Minutes * 60 + 300))) { Stop-Job $job; Write-Output 'TIMED OUT' }
Receive-Job $job -ErrorAction Continue; Remove-Job $job -Force
$new = @(git -C $dir log --format='%h %s' "$before..HEAD")
$ahead = "$(git -C $dir rev-list --count '@{u}..HEAD')"
Write-Output "GLM prep of $Project took $([int]((Get-Date) - $started).TotalMinutes) min. Log: $log"
Write-Output "git: $(if ($new) { "$($new.Count) new commit(s): $($new -join '; ')" } else { 'no new commit' }); $(if ($ahead -ne '0') { "$ahead NOT pushed" } else { 'desktop in sync with origin' }); $(@(git -C $dir status --porcelain).Count) uncommitted"
