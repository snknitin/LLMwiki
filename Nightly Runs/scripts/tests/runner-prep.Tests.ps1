param([string]$Runner = (Join-Path $PSScriptRoot '../overnight-run.ps1'))
$ErrorActionPreference = 'Stop'
$text = Get-Content -LiteralPath $Runner -Raw -Encoding UTF8
$tokens=$null; $errors=$null
$ast=[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $Runner),[ref]$tokens,[ref]$errors)
if($errors.Count){throw ($errors|Out-String)}
$function=$ast.Find({param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Test-TargetDone'},$true)
Invoke-Expression $function.Extent.Text
$block=[regex]::Match($text.Substring($text.IndexOf('# advance now')), '(?ms)^if \(\$PrepOnly\) \{.*?^}')
if(-not $block.Success){throw 'Prep loop not found'}
$projects=Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force (Join-Path $projects 'done'),(Join-Path $projects 'unfinished')|Out-Null
Set-Content (Join-Path $projects 'done/PROGRESS.md') "# Progress`n## Now`nNode: target done; next: advance.`n## Checklist`n"
Set-Content (Join-Path $projects 'unfinished/PROGRESS.md') "# Progress`n## Now`nTarget not done; failed verifier.`n## Checklist`n"
function Test-CachedPass($name,$dir){return $false}
$queue=@([pscustomobject]@{Name='done'},[pscustomobject]@{Name='unfinished'})
$prepWork=@();$verifyCache=@{};$PrepOnly=$true
Invoke-Expression $block.Value
if($prepWork.Count -ne 1 -or $prepWork[0].Project -ne 'done'){throw 'Uncached finished target must reach prep; unfinished target must not advance'}
if($prepWork[0].Why -notmatch 'verify fresh first|canonical verify fresh' -or $prepWork[0].Why -notmatch 'only if it passes'){throw 'Uncached handoff must require fresh verification before advance'}
Write-Output 'PRE-RUN ADVANCE REGRESSION OK'
