# Real FirstSpark Qwen qualification. Synthetic CLI repo with a seeded regression, local bare remote,
# actual verify, actual model review, QA commit/push/pull and the production runner's result parser.
# Never invokes Claude/Codex, changes Tonight, or reads private project data. Keeps evidence on both hosts.
param([switch]$Fallback)
$ErrorActionPreference = 'Stop'
$ssh = "$env:WINDIR\System32\OpenSSH\ssh.exe"
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$remoteRoot = "/home/snknitin/.agents-board/qualification-$stamp"
$root = Join-Path $env:TEMP "agents-board-local-qa-$stamp"
$projects = Join-Path $root 'projects'; $vault = Join-Path $root 'vault'
New-Item -ItemType Directory -Force $projects, (Join-Path $vault 'Nightly Runs\agent-rules'), (Join-Path $vault 'Morning Runs') | Out-Null
$setup = @'
import pathlib,subprocess,sys
r=pathlib.Path(sys.argv[1]); d=r/'projects'/'local-qa-fixture'; d.mkdir(parents=True)
def git(*args): return subprocess.check_output(['git','-C',str(d),*args],stderr=subprocess.STDOUT,text=True).strip()
git('init','-q','-b','main'); git('config','user.name','QA fixture'); git('config','user.email','fixture@localhost')
files={
 'AGENTS.md': 'Read BUILD_SPEC.md and DECISIONS.md. QA may edit only REPORT.md, FEEDBACK.md, BUILD_SPEC.md and PROGRESS.md. Never fix source or tests during QA. Run scripts/verify.sh. Commit and push QA documentation.\n',
 'BUILD_SPEC.md': '# Timer CLI\nUI: none\nT1: minutes_to_seconds converts whole minutes to seconds.\n',
 'DECISIONS.md': '# Decisions\nSynthetic qualification only. No private data.\n',
 'PROGRESS.md': '# Progress\n- [ ] T1 conversion\n',
 'REPORT.md': '# Report\n', 'FEEDBACK.md': '# Feedback\n',
 'timer.py': 'def minutes_to_seconds(minutes):\n    return minutes * 60\n',
 'test_timer.py': 'from timer import minutes_to_seconds\nassert minutes_to_seconds(2) == 120, "two minutes must be 120 seconds"\nprint("T1 conversion OK")\n',
 'scripts/verify.sh': '#!/bin/sh\nset -eu\ncd "$(dirname "$0")/.."\npython3 test_timer.py\necho VERIFY_OK\n',
 'scripts/verify.ps1': '$ErrorActionPreference="Stop"\nSet-Location (Split-Path $PSScriptRoot)\npython test_timer.py\nexit $LASTEXITCODE\n',
 '.gitignore': '__pycache__/\n'
}
for name,text in files.items():
 p=d/name; p.parent.mkdir(parents=True,exist_ok=True); p.write_text(text)
git('add',*files); git('commit','-qm','Add correct timer conversion and gate')
base=git('rev-parse','HEAD')
(d/'timer.py').write_text('def minutes_to_seconds(minutes):\n    return minutes * 30\n')
(d/'PROGRESS.md').write_text('# Progress\n- [x] T1 conversion done, verified\n')
git('add','timer.py','PROGRESS.md'); git('commit','-qm','Introduce seeded conversion regression and false done mark')
subprocess.run(['git','init','-q','--bare',str(r/'origin.git')],check=True)
git('remote','add','origin',str(r/'origin.git')); git('push','-qu','origin','main')
print(base)
'@
$base = ($setup | & $ssh -o BatchMode=yes FirstSpark "python3 - $remoteRoot" | Select-Object -Last 1).Trim()
if ($LASTEXITCODE -or $base -notmatch '^[0-9a-f]{40}$') { throw 'Could not seed FirstSpark QA fixture' }
$saved = @{}; foreach ($k in 'OVERNIGHT_VAULT','OVERNIGHT_PROJECTS','OVERNIGHT_SPARK_PROJECTS','GIT_SSH_COMMAND','PATH') { $saved[$k] = [Environment]::GetEnvironmentVariable($k) }
try {
    $env:GIT_SSH_COMMAND = 'C:/Windows/System32/OpenSSH/ssh.exe -o BatchMode=yes'
    git clone -q -b main "FirstSpark:$remoteRoot/origin.git" (Join-Path $projects 'local-qa-fixture')
    if ($LASTEXITCODE) { throw 'Could not clone QA fixture on desktop' }
    $d = Join-Path $projects 'local-qa-fixture'
    $head = git -C $d rev-parse HEAD
    Set-Content (Join-Path $vault 'Nightly Runs\Project Priorities.md') "## Tonight`n### Hermes`n- local-qa-fixture @hermes:glm53-flash"
    Set-Content (Join-Path $vault 'Nightly Runs\agent-rules\overnight-prompt.md') 'QA-only qualification: no builder starts.'
    $primary = $(if ($Fallback) { 'claude:sonnet' } else { 'hermes:qwen3.6-35b-a3b' })
    $secondary = $(if ($Fallback) { 'hermes:qwen3.6-35b-a3b' } else { 'off' })
    @{ claude = @{ builder='claude:opus'; qa='hermes:qwen3.6-35b-a3b'; fallbackQa='off' }; codex = @{ builder='codex'; qa='hermes:qwen3.6-35b-a3b'; fallbackQa='off' }; hermes = @{ builder='hermes:glm53-flash'; qa=$primary; fallbackQa=$secondary } } | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $vault 'Nightly Runs\roles.json')
    if ($Fallback) {
        $shims = Join-Path $root 'shims'; New-Item -ItemType Directory $shims | Out-Null
        Set-Content (Join-Path $shims 'claude.cmd') "@echo off`necho usage limit reached - qualification shim, no subscription call`nexit /b 1" -Encoding Ascii
        $env:PATH = "$shims;$env:PATH"
    }
    Copy-Item (Join-Path $PSScriptRoot '..\agent-rules\qa-prompt.md') (Join-Path $vault 'Nightly Runs\agent-rules\qa-prompt.md')
    $env:OVERNIGHT_VAULT = $vault; $env:OVERNIGHT_PROJECTS = $projects; $env:OVERNIGHT_SPARK_PROJECTS = "$remoteRoot/projects"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'overnight-run.ps1') -Kind morning -QaOnly -Project local-qa-fixture -QaFrom $base -QaMinutes 10
    if ($LASTEXITCODE) { throw 'QA-only runner failed' }
    $report = Get-Content (Join-Path $vault 'Morning Runs\Morning Report.md') -Raw
    if ($report -notmatch 'QA [1-9]\d* findings') { throw "QA did not report the seeded defect: $report" }
    if ($Fallback -and $report -notmatch 'Retrying QA on fallback hermes:qwen3.6-35b-a3b') { throw 'Runner did not exercise the fallback' }
    $changed = @(git -C $d diff --name-only $head HEAD)
    if ($changed | Where-Object { $_ -notin 'REPORT.md','FEEDBACK.md','BUILD_SPEC.md','PROGRESS.md' }) { throw 'QA changed forbidden files' }
    if (-not ($changed -contains 'REPORT.md') -or -not ($changed -contains 'FEEDBACK.md')) { throw 'QA did not commit its report and feedback' }
    if ((Get-Content (Join-Path $d 'PROGRESS.md') -Raw) -match '\[x\] T1') { throw 'QA left the false done mark' }
    if ((git -C $d rev-list --count '@{u}..HEAD') -ne '0') { throw 'QA commit was not pushed and pulled' }
    $qaLog = Get-ChildItem $projects -Recurse -Filter $(if ($Fallback) { '*.qa-fallback.txt' } else { '*.qa.txt' }) | Select-Object -First 1
    $log = (Get-Content $qaLog.FullName -Raw) -replace "`0", ''
    if ($log -notmatch 'LOCAL ROUTE: spark-fast at http://127.0.0.1:8000/v1' -or $log -match 'Claude Subscription DirectSDK') { throw 'Unexpected QA routing' }
    if ($log -notmatch 'profiles/agents-board-qa') { throw 'QA did not reuse the stable service profile' }
    Write-Output "LOCAL QA FLOW OK: seeded defect found, false done mark reverted, only QA docs committed/pushed/pulled. Evidence: $root; Spark: $remoteRoot"
} finally {
    foreach ($k in $saved.Keys) { [Environment]::SetEnvironmentVariable($k, $saved[$k]) }
}
