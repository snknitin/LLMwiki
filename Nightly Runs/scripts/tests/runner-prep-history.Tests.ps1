param([string]$Runner=(Join-Path $PSScriptRoot '../overnight-run.ps1'))
$ErrorActionPreference='Stop'
$tokens=$null;$errors=$null
$ast=[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $Runner),[ref]$tokens,[ref]$errors)
if($errors.Count){throw ($errors|Out-String)}
$fn=$ast.Find({param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Save-PrepReceipt'},$true)
Invoke-Expression $fn.Extent.Text
$recheck=$ast.Find({param($n) $n -is [System.Management.Automation.Language.IfStatementAst] -and $n.Extent.Text.StartsWith('if ($PrepOnly -and -not $prepWork.Count -and $oldReceipt')},$true)
$folder=Join-Path ([IO.Path]::GetTempPath()) ('prep-history-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $folder|Out-Null
$prepStatusFile=Join-Path $folder 'receipt.json'
$now=Get-Date;$cycleStart=$now.Date.AddHours(6.5);if($now -lt $cycleStart){$cycleStart=$cycleStart.AddDays(-1)}
$oldReceipt=@{state='attention';started=$now.AddMinutes(-90).ToString('o');ended=$now.AddMinutes(-30).ToString('o');prioritiesHash='old'}
$PrepOnly=$true
foreach($hasWork in $false,$true){
    $prepWork=@();if($hasWork){$prepWork=@('new actual preparation')}
    $prepReceipt=@{started=$now.ToString('o');prioritiesHash='current';heads=@{alpha='new-head'}}
    $preservePrepHistory=$false
    if($recheck){Invoke-Expression $recheck.Extent.Text}
    Save-PrepReceipt 'ready' @() @() 'Current queue checked'
    $saved=Get-Content $prepStatusFile -Raw|ConvertFrom-Json
    if(-not $hasWork -and ($saved.started -ne $oldReceipt.started -or $saved.ended -ne $oldReceipt.ended)){throw 'A no-work readiness recheck erased the real prep execution times'}
    if($hasWork -and $saved.started -ne $now.ToString('o')){throw 'Real new preparation must have its own start'}
    if($saved.prioritiesHash -ne 'current' -or $saved.heads.alpha -ne 'new-head'){throw 'Recheck must validate the current queue, not reuse its old qualification'}
    if(-not $saved.checked -or [datetime]$saved.checked -lt $now){throw 'Fresh check time must be recorded separately'}
}
Write-Output 'PREP EXECUTION HISTORY REGRESSIONS OK'
$Preflight=$true;$PrepOnly=$true;$NoPrep=$true;$DryRun=$false;$QaOnly=$false
foreach($name in 'recheckOnly','recordPrep'){
    $assignment=$ast.Find({param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -eq ('$'+$name)},$true)
    if($assignment){Invoke-Expression $assignment.Extent.Text}
}
if(-not $recordPrep){throw 'An explicit no-agent preflight recheck must refresh the readiness receipt'}
Write-Output 'NO-AGENT READINESS RECHECK OK'
