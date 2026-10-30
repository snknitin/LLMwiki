param([string]$Runner = (Join-Path $PSScriptRoot '../overnight-run.ps1'))
$ErrorActionPreference = 'Stop'
$text = Get-Content -LiteralPath $Runner -Raw -Encoding UTF8
$tokens=$null; $errors=$null
$ast=[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $Runner),[ref]$tokens,[ref]$errors)
if($errors.Count){throw ($errors|Out-String)}
$fn=$ast.Find({param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Save-DesktopHandoff'},$true)
Invoke-Expression $fn.Extent.Text
$dir=Join-Path ([IO.Path]::GetTempPath()) ('runner-dirty-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $dir|Out-Null
$file=Join-Path $dir 'unfinished.txt'
[IO.File]::WriteAllText($file,'unfinished owner work')
(Get-Item $file).LastWriteTime=(Get-Date).AddHours(-1)
$script:calls=@();$handoff=@{};$leftAlone=@{};$secretPattern='(^|/)(\.env[^/]*|[^/]*\.(pem|key)|[^/]*secret[^/]*)$';$handoffBranch='wip/forbidden';$Kind='test'
function git {
    $script:calls+=($args -join ' ')
    if($args -contains 'status') { ' M unfinished.txt' }
    elseif($args -contains '--show-current') { 'main' }
    elseif($args -contains 'rev-parse') { 'abc1234' }
    $global:LASTEXITCODE=0
}
function Add-HandoffNote { throw 'Must not mutate or commit PROGRESS on behalf of an unknown editor' }
Save-DesktopHandoff 'example' $dir
if([IO.File]::ReadAllText($file) -ne 'unfinished owner work'){throw 'Dirty work changed'}
if($script:calls | Where-Object { $_ -match ' (add|commit|switch|push|pull) ' }){throw ('Runner mutated unknown work: '+($script:calls -join '; '))}
if(-not $handoff.example -or $leftAlone.example){throw 'Old unfinished work should be handed to the builder, not owner-blocked'}
if($text -match 'git add -A'){throw 'Runner must never auto-stage unverified or unrelated files'}
Write-Output 'DIRTY WORK PRESERVATION REGRESSIONS OK'
