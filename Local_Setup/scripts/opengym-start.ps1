# Run by the Command Center when the openGym tab opens: starts Docker Desktop if needed, then the openGym compose stack (127.0.0.1:8095).
$ErrorActionPreference = 'Stop'
$dir = 'E:\GIT_ROOT\External\openGym'
docker info *> $null
if ($LASTEXITCODE -ne 0) {
  Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
  $deadline = (Get-Date).AddMinutes(5)
  do { Start-Sleep 5; docker info *> $null } until ($LASTEXITCODE -eq 0 -or (Get-Date) -gt $deadline)
  if ($LASTEXITCODE -ne 0) { throw 'Docker engine did not start within 5 minutes' }
}
docker compose --project-directory $dir up -d
