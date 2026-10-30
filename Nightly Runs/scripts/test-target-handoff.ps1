$ErrorActionPreference = 'Stop'
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'overnight-run.ps1'), [ref]$null, [ref]$null)
$fn = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Test-TargetDone' }, $true)
$branch = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.IfStatementAst] -and $n.Clauses[0].Item2.Extent.Text -like '*real work committed: next builder session*' }, $true) | Sort-Object { $_.Extent.Text.Length } | Select-Object -First 1
$progress = $true; $targetDone = $true
if (& ([scriptblock]::Create($branch.Clauses[0].Item1.Extent.Text))) { throw 'Completed target was sent back to the same builder instead of QA/advance' }
if (-not $fn) { throw 'Missing current-target parser' }
. ([scriptblock]::Create($fn.Extent.Text))
$tmp = Join-Path $env:TEMP "target-handoff-$PID"
New-Item -ItemType Directory -Force $tmp | Out-Null
try {
    Set-Content "$tmp/PROGRESS.md" "## Now`ntarget done; next: advance`n## History`nunfinished"
    if (-not (Test-TargetDone $tmp)) { throw 'Explicit current completion was missed' }
    Set-Content "$tmp/PROGRESS.md" "## Now`nNative acceptance incomplete`n## History`ntarget done; next: advance"
    if (Test-TargetDone $tmp) { throw 'Historical completion overrode current incomplete target' }
    $targetDone = $false
    if (-not (& ([scriptblock]::Create($branch.Clauses[0].Item1.Extent.Text)))) { throw 'Unfinished real work no longer continues' }
    'TARGET HANDOFF OK'
} finally { Remove-Item -LiteralPath "$tmp/PROGRESS.md"; Remove-Item -LiteralPath $tmp }
