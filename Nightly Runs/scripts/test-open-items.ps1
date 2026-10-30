$ErrorActionPreference = 'Stop'
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'overnight-run.ps1'), [ref]$null, [ref]$null)
$ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Get-OpenItems' }, $true) | ForEach-Object { . ([scriptblock]::Create($_.Extent.Text)) }
$file = Join-Path $env:TEMP "open-items-$PID.md"
try {
    Set-Content -Encoding UTF8 $file "## Open questions`n### Q1 (text): Where is the model list?`nDefault: none`n### Resolved target line`nAlready applied; no approval pending.`n"
    $items = @(Get-OpenItems $file)
    if ($items.Count -ne 1 -or $items[0] -notlike 'Q1*') { throw "Resolved subsection became an approval: $items" }
    Set-Content -Encoding UTF8 $file "## Open questions`n- Which port? -- resolved by the owner`n- Quote the path? -- fixed`n- Which credential?`n"
    $items = @(Get-OpenItems $file)
    if ($items.Count -ne 1 -or $items[0] -ne 'Which credential?') { throw "Settled bullets became approvals: $items" }
    Set-Content -Encoding UTF8 $file "## Open questions`n### Q2: Which local library?`n- [ ] SQLite (recommended)`n- [ ] JSON`nAuto-decided by Agents board: SQLite`n"
    if (@(Get-OpenItems $file).Count) { throw 'Automatic decision receipt became a repeated approval' }
    Set-Content -Encoding UTF8 $file "## Resolved open questions`n- Which old port?`n"
    if (@(Get-OpenItems $file).Count) { throw 'Resolved parent section became approvals' }
    'OPEN ITEMS OK'
} finally { Remove-Item -LiteralPath $file -ErrorAction SilentlyContinue }
