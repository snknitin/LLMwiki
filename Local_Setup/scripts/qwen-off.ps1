# Free the RTX for ComfyUI/video work. Hermes falls back to Spark Qwen; Fresh Brief fails until Qwen ON.
# The boot task runs llama-server directly, so stopping the task stops the server.
Stop-ScheduledTask -TaskName 'Desktop Qwen - llama-server'
for ($i = 0; $i -lt 15 -and (Get-NetTCPConnection -LocalPort 11435 -State Listen -ErrorAction SilentlyContinue); $i++) { Start-Sleep 1 }
Start-Sleep 2
$used = nvidia-smi --query-gpu=memory.used --format=csv,noheader
if (Get-NetTCPConnection -LocalPort 11435 -State Listen -ErrorAction SilentlyContinue) { Write-Host "Desktop Qwen is STILL RUNNING. GPU memory in use: $used" }
else { Write-Host "Desktop Qwen is OFF. GPU memory in use: $used" }
Start-Sleep 4
