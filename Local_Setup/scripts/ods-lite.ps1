# On-demand slim ODS: Open WebUI (:3000) + Perplexica (:3004) + SearXNG. Usage: ods-lite.ps1 [on|off]
# Only these three run; the rest of ODS (dashboard, n8n, langfuse, qdrant, whisper, comfyui...) stays down.
param([ValidateSet('on', 'off')][string]$Action = 'on')
$ods = 'D:\LocalLLama\ods'
$flags = (Get-Content "$ods\.compose-flags" -Raw).Trim() -split '\s+'

if ($Action -eq 'off') {
    Push-Location $ods; docker compose @flags down; Pop-Location
    Stop-Process -Name 'Docker Desktop' -ErrorAction SilentlyContinue
    wsl --shutdown  # frees the WSL VM's RAM
    Write-Host 'ODS lite is OFF.'; Start-Sleep 3; return
}

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
    for ($i = 0; $i -lt 90; $i++) { Start-Sleep 2; docker info *> $null; if ($LASTEXITCODE -eq 0) { break } }
    if ($LASTEXITCODE -ne 0) { Write-Host 'Docker did not start.'; Start-Sleep 5; exit 1 }
}
Push-Location $ods
# A full ODS start (e.g. via the dashboard) brings everything back; stop anything outside the slim set.
docker compose @flags down --remove-orphans 2>$null
docker compose @flags up -d --no-deps open-webui searxng perplexica
Pop-Location
if (-not (Get-NetTCPConnection -LocalPort 11435 -State Listen -ErrorAction SilentlyContinue)) {
    Write-Host 'Note: Desktop Qwen (:11435) is off, so chats have no model until qwen-on.ps1.'
}
Start-Process 'http://127.0.0.1:3000'
Write-Host 'ODS lite is ON: Open WebUI http://127.0.0.1:3000  Perplexica http://127.0.0.1:3004'
Start-Sleep 4
