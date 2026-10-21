# Self-check for overnight-run.ps1's usage-limit fallback and the limitUntil it saves to .run-state.json.
# Loads only those functions from the runner (nothing runs). Exit 0 = all checks pass.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-fallback.ps1
$ErrorActionPreference = 'Stop'
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'overnight-run.ps1'), [ref]$null, [ref]$null)
$ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -in 'Test-Parked', 'Get-SessionHarness', 'Save-RunState' }, $true) |
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

if ($failed) { exit 1 }
