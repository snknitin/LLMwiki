# Exercise receipt serialization without starting a runner, model or real project.
$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'overnight-run.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | Out-String) }
$function = $ast.Find({ param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Save-PrepReceipt' }, $true)
if (-not $function) { throw 'Missing receipt writer' }
Invoke-Expression $function.Extent.Text
$prepStatusFile = Join-Path ([IO.Path]::GetTempPath()) ("prep-receipt-$([guid]::NewGuid()).json")
try {
    $script:prepReceipt = @{ state = 'running'; started = (Get-Date).ToString('o'); prioritiesHash = 'initial-queue' }
    Save-PrepReceipt 'ready' @() @() 'Verified'
    $receipt = Get-Content -LiteralPath $prepStatusFile -Raw | ConvertFrom-Json
    if ($receipt.state -ne 'ready' -or -not $receipt.ended -or @($receipt.remaining).Count -or @($receipt.blockers).Count) { throw 'Invalid ready receipt' }
    Save-PrepReceipt 'attention' @(@{ Project = 'fixture'; Action = 'advance' }) @() 'Target unchanged'
    $receipt = Get-Content -LiteralPath $prepStatusFile -Raw | ConvertFrom-Json
    if ($receipt.remaining[0].Project -ne 'fixture' -or $receipt.state -ne 'attention') { throw 'Outstanding work lost' }
    Save-PrepReceipt 'failed' @('fixture') @('verify failed') 'Failed'
    $receipt = Get-Content -LiteralPath $prepStatusFile -Raw | ConvertFrom-Json
    if ($receipt.state -ne 'failed' -or $receipt.blockers[0] -ne 'verify failed') { throw 'Failure lost' }
    if ($receipt.prioritiesHash -ne 'initial-queue') { throw 'Receipt must retain the queue hash captured at start' }
    if (Test-Path -LiteralPath "$prepStatusFile.$PID.tmp") { throw 'Atomic write left temporary output' }
    'PREP RECEIPT OK'
} finally {
    Remove-Item -LiteralPath $prepStatusFile -ErrorAction SilentlyContinue
}
