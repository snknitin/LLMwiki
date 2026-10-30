$ErrorActionPreference = 'Stop'
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'overnight-run.ps1'), [ref]$null, [ref]$null)
$workerAst = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and "$($n.Left)" -eq '$worker' }, $true)
$worker = & ([scriptblock]::Create($workerAst.Right.Extent.Text))
$tmp = Join-Path $env:TEMP "remote-boundary-$PID"
New-Item -ItemType Directory -Force $tmp | Out-Null
$oldLocation = Get-Location; $oldTemp = $env:TEMP; $oldTmp = $env:TMP; $oldJava = $env:JAVA_TOOL_OPTIONS
try {
    $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Set-JavaTemp' }, $true) | ForEach-Object { . ([scriptblock]::Create($_.Extent.Text)) }
    $env:JAVA_TOOL_OPTIONS = '-Dfixture.keep=true'
    Set-JavaTemp $tmp
    if ($env:JAVA_TOOL_OPTIONS -notmatch '-Dfixture.keep=true.*-Djdk.net.unixdomain.tmpdir=') { throw 'Java correction dropped existing options' }
    $configured = $env:JAVA_TOOL_OPTIONS
    Set-JavaTemp $tmp
    if ($env:JAVA_TOOL_OPTIONS -ne $configured) { throw 'Java correction overwrote a configured path' }
    $prep = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and "$($n.Left)" -eq '$prepAgent' }, $true)
    if ($prep.Extent.Text -notmatch 'timeout --signal=TERM --kill-after=15s') { throw 'Remote prep/advance child lacks a hard deadline' }
    $shim = Join-Path $tmp 'ssh.ps1'
    Set-Content $shim 'Write-Output ($args -join " ")'
    $log = Join-Path $tmp 'job.log'
    & $worker $tmp hermes '' 'fixture prompt' $log 123 $shim /tmp/fixture 'fixture' $false ''
    $cmd = Get-Content $log -Raw
    if ($cmd -notmatch 'timeout --signal=TERM --kill-after=15s 123s .*hermes chat') { throw 'Remote process tree lacks a hard deadline' }
    if ($cmd -notmatch '--query-file - -Q --yolo' -or $cmd -notmatch 'deepseek41-flash-pair') { throw 'Unattended provider configuration changed' }
    if ($env:JAVA_TOOL_OPTIONS -notmatch '-Djdk.net.unixdomain.tmpdir=') { throw 'Worker lacks qualified Java UDS temp correction' }
    $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Start-QaJob' }, $true) | ForEach-Object { . ([scriptblock]::Create($_.Extent.Text)) }
    function Test-SparkWriterIdle { return $false }
    function Write-Decision { }
    function Start-Job { throw 'QA started while the remote builder was still running' }
    $projects = $tmp; $logDir = $tmp; $hermesBuilt = @{}
    $rec = Start-QaJob ([pscustomobject]@{ Name = 'fixture'; Harness = 'hermes' }) ([pscustomobject]@{ Family = 'codex'; Spec = 'codex'; FallbackUsed = $false }) 'before'
    if ($rec) { throw 'Busy remote builder produced a QA record' }
    'REMOTE BOUNDARY OK'
} finally {
    Set-Location $oldLocation; $env:TEMP = $oldTemp; $env:TMP = $oldTmp; $env:JAVA_TOOL_OPTIONS = $oldJava
    # Leave the tiny test logs for diagnosis; no recursive filesystem cleanup here.
}
