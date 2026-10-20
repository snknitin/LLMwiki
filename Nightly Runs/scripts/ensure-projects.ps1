# Makes sure every repo that runs on Hermes tonight has a Hermes project on FirstSpark, so its sessions group under it.
# Runs before every nightly or morning run (overnight-run.ps1 calls it) and from the Agents board's "Create projects".
# Only Hermes repos: the "### Hermes" lane under "## Tonight", or a line tagged @hermes. Claude and Codex repos get no
# Hermes project. A repo already in any Hermes project (matched by folder, whatever it is called) is left alone; missing
# ones are created with `hermes project create`, in the default profile that overnight runs use.
# Claude Code groups sessions by folder on its own; Codex app projects are added in the Codex app.
# Usage: ensure-projects.ps1 [-Projects a,b] [-DryRun]   -Projects narrows the list (non-Hermes names are ignored).
# Prints one line per project: exists | created | would create | skipped.
param([string[]]$Projects, [switch]$DryRun)
$ErrorActionPreference = 'Stop'
$prioFile = 'F:\Vaults\LLMWiki\Nightly Runs\Project Priorities.md'
$sparkProjects = '/home/snknitin/Workspace/GIT_ROOT/Projects'
$ssh = "$env:WINDIR\System32\OpenSSH\ssh.exe"

# Same rule as the runner: under "## Tonight", the "### <tool>" lane picks the tool and an @tool tag overrides it.
$hermes = @(); $inTonight = $false; $lane = 'claude'
foreach ($line in Get-Content $prioFile -Encoding UTF8) {
    if ($line -match '^##\s') { $inTonight = $line -match '^##\s+Tonight'; $lane = 'claude'; continue }
    if ($inTonight -and $line -match '^###\s+(\w+)') { $lane = $Matches[1].ToLower(); continue }
    if ($inTonight -and $line -match '^\s*-\s+([A-Za-z0-9._-]+)(?:\s+@(\w+))?') {
        if ($(if ($Matches[2]) { $Matches[2].ToLower() } else { $lane }) -eq 'hermes') { $hermes += $Matches[1] }
    }
}
$Projects = @($Projects | ForEach-Object { $_ -split ',' } | Where-Object { $_ })   # "-Projects a,b" via -File arrives as one string
$Projects = @($(if ($Projects) { $Projects | Where-Object { $hermes -contains $_ } } else { $hermes }))
$Projects = @($Projects | Where-Object { $_ -match '^[A-Za-z0-9._-]+$' } | Select-Object -Unique)
if (-not $Projects) { Write-Output 'no Hermes projects in tonight''s lanes'; exit 0 }

# "net-worth-command-center" -> "Net Worth Command Center"
$pairs = $Projects | ForEach-Object { "$_|" + ((($_ -split '-') | ForEach-Object { if ($_) { $_.Substring(0, 1).ToUpper() + $_.Substring(1) } }) -join ' ') }
$dry = $(if ($DryRun) { '1' } else { '0' })
$remote = @"
set -u
H=~/.local/bin/hermes
known=`$(python3 -c 'import sqlite3,os; c=sqlite3.connect("file:"+os.path.expanduser("~/.hermes/projects.db")+"?mode=ro",uri=True); print("\n".join(r[0].rstrip("/") for r in c.execute("select f.path from project_folders f join projects p on p.id=f.project_id where p.archived=0")))' 2>/dev/null)
"@
# Build the per-project lines separately (names contain spaces, so they are passed quoted).
$body = foreach ($pair in $pairs) {
    $slug, $name = $pair -split '\|', 2
    @"
d='$sparkProjects/$slug'
if [ ! -d "`$d" ]; then echo "skipped $slug (not cloned on FirstSpark)"
elif printf '%s\n' "`$known" | grep -qxF "`$d"; then echo "exists $slug"
elif [ $dry = 1 ]; then echo "would create $slug"
elif `$H project create '$name' "`$d" --slug '$slug' --description 'Overnight build project (Agents board)' >/dev/null 2>&1; then echo "created $slug"
else echo "failed $slug (hermes project create)"; fi
"@
}
$script = $remote + "`n" + ($body -join "`n")
$out = $script | & $ssh -o BatchMode=yes -o ConnectTimeout=8 FirstSpark 'tr -d ''\r'' | bash -s' 2>&1   # single quotes: PowerShell 5.1 drops inner double quotes when calling ssh
if ($LASTEXITCODE -ne 0) { Write-Output "FirstSpark unreachable: $out"; exit 1 }
$out | Where-Object { $_ -match '^(exists|created|would create|skipped|failed) ' } | ForEach-Object { Write-Output $_ }
