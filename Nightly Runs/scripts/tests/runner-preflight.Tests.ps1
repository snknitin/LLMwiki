param([string]$Runner = (Join-Path $PSScriptRoot '../overnight-run.ps1'))
$ErrorActionPreference='Stop'
$text=Get-Content -LiteralPath $Runner -Raw -Encoding UTF8
$start=$text.IndexOf('$checks = @{}')
$end=$text.IndexOf('$pf = @(', $start)
if($start -lt 0 -or $end -lt 0){throw 'Preflight checks not found'}
$projects=Join-Path ([IO.Path]::GetTempPath()) ('runner-preflight-'+[guid]::NewGuid().ToString('N'))
$dir=Join-Path $projects 'example'
New-Item -ItemType Directory -Force (Join-Path $dir 'scripts'),(Join-Path $dir '.claude')|Out-Null
foreach($f in 'scripts/verify.ps1','BUILD_SPEC.md','AGENTS.md'){Set-Content (Join-Path $dir $f) 'fixture'}
Set-Content (Join-Path $dir '.claude/stop-retries') '1'
$queue=@([pscustomobject]@{Name='example';Harness='codex'})
$cliOk=@{codex=$true};$leftAlone=@{};$recheck=@{};$waitPattern='last 10 minutes|still running'
function git { $global:LASTEXITCODE=0 }
function Get-OpenItems { @() }
Invoke-Expression $text.Substring($start,$end-$start)
if($checks.example.Blockers -or $checks.example.Warnings){throw ('One failed stop check is not a retry cap or owner question: '+($checks.example.Warnings -join '; '))}
if((Get-Content (Join-Path $dir '.claude/stop-retries')) -ne '1'){throw 'Diagnostics must preserve the stop counter'}
Write-Output 'PREFLIGHT RETRY STATUS REGRESSION OK'
