param([string]$Runner = (Join-Path $PSScriptRoot '../overnight-run.ps1'))
$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $Runner), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | Out-String) }
foreach ($name in @('Test-Leftover', 'Test-SparkGitPublished')) {
    $fn = $ast.Find({param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name}, $true)
    if ($fn) { Invoke-Expression $fn.Extent.Text }
}
if (-not (Test-Leftover '' hermes 'SPARK_GIT dirty=0 unpushed=2')) { throw 'Unpublished Creator commits must resume, not advance' }
if (-not (Test-Leftover '' hermes 'SPARK_GIT dirty=3 unpushed=0')) { throw 'Dirty work must resume' }
if (Test-Leftover '' hermes 'SPARK_GIT dirty=0 unpushed=0') { throw 'Published clean work is not leftover' }
foreach ($state in @('SPARK_BUSY', 'SPARK_IDLE', 'SPARK_IDLE dirty=0 unpushed=2', 'SPARK_IDLE dirty=2 unpushed=0')) {
    if (Test-SparkGitPublished $state) { throw "Unsafe QA baseline accepted: $state" }
}
if (-not (Test-SparkGitPublished 'SPARK_IDLE dirty=0 unpushed=0')) { throw 'Published idle baseline should pass' }
Write-Output 'RUNNER PUBLICATION REGRESSIONS OK'
