# Run by the Command Center when the World Monitor tab opens: starts Docker Desktop if needed, then the World Monitor compose stack (127.0.0.1:8096, LLM = Desktop Qwen on :11435).
# No ErrorActionPreference=Stop: Windows PowerShell turns docker's stderr into a terminating error, so the engine probe would abort the script.
$dir = 'E:\GIT_ROOT\External\worldmonitor'
docker info *> $null
if ($LASTEXITCODE -ne 0) {
  Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
  $deadline = (Get-Date).AddMinutes(5)
  do { Start-Sleep 5; docker info *> $null } until ($LASTEXITCODE -eq 0 -or (Get-Date) -gt $deadline)
  if ($LASTEXITCODE -ne 0) { throw 'Docker engine did not start within 5 minutes' }
}
docker compose --project-directory $dir up -d --wait --wait-timeout 120
exit $LASTEXITCODE
