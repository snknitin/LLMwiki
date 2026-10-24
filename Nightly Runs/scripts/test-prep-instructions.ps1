# Real desktop-Qwen check, on a throwaway repo: prep can rewrite CLAUDE.md's target line, commit and push unattended
# (2026-10-23: Hermes' instruction-file guard and git's credential picker blocked both). About 2-5 minutes.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File test-prep-instructions.ps1
$ErrorActionPreference = 'Stop'
$root = Join-Path $env:TEMP ("agents-board-prep-instructions-" + (Get-Date -Format yyyyMMdd-HHmmss))
$d = Join-Path $root 'fixture'; New-Item -ItemType Directory -Force $d | Out-Null
Set-Content (Join-Path $d 'CLAUDE.md') "# Fixture`n`nOvernight MVP target = **Slice 1 = tasks T1**`n`nRules: never touch anything outside this folder."
git -C $d init -q -b main; git -C $d config user.name 'Prep fixture'; git -C $d config user.email fixture@localhost
git -C $d add CLAUDE.md; git -C $d commit -qm 'Seed fixture contract'
git init -q --bare (Join-Path $root 'remote.git'); git -C $d remote add origin (Join-Path $root 'remote.git'); git -C $d push -q -u origin main 2>$null
$prompt = @"
This is a bounded qualification of the prep route on a throwaway repo, not a portfolio prep. Only touch $d.
In $d\CLAUDE.md change the target line to exactly: Overnight MVP target = **Slice 2 = tasks T2, T3**
Keep the Rules line unchanged. Commit only CLAUDE.md with message "Advance fixture to Slice 2", then git push.
Finish with PREP INSTRUCTIONS OK and the commit hash from git log -1.
"@
$started = Get-Date
$ErrorActionPreference = 'Continue'   # Hermes writes progress to stderr; the checks below decide the result
$prompt | & python -I (Join-Path $PSScriptRoot 'local-agent.py') --base-url http://127.0.0.1:11435/v1 --model qwen3.8-27b-desktop --workdir $d --budget 600 *> (Join-Path $root 'agent.log')
$ErrorActionPreference = 'Stop'
$fails = @()
$text = (Get-Content (Join-Path $d 'CLAUDE.md') -Raw)
if ($text -notmatch [regex]::Escape('Overnight MVP target = **Slice 2 = tasks T2, T3**')) { $fails += 'target line not rewritten' }
if ($text -notmatch 'Rules: never touch anything outside this folder') { $fails += 'rules line changed' }
if ((git -C $d log -1 --format=%s) -ne 'Advance fixture to Slice 2') { $fails += 'no commit' }
if ((git -C $d rev-parse HEAD) -ne (git -C (Join-Path $root 'remote.git') rev-parse main)) { $fails += 'not pushed' }
$log = (Get-Content (Join-Path $root 'agent.log') -Raw) -replace "`0", ''
if ($log -match 'Approval: <write to CLAUDE.md>|/dev/tty') { $fails += 'an approval or credential prompt appeared' }
if ($fails) { throw "$($fails -join '; '). Evidence: $root" }
Write-Output "PREP INSTRUCTIONS OK in $([int]((Get-Date) - $started).TotalSeconds)s: target rewritten, rules kept, committed and pushed, no prompt. Evidence: $root"
