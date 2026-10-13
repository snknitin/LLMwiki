# Free the RTX for ComfyUI/video work. Hermes falls back to Spark Qwen; Fresh Brief fails until qwen-on.
# Stop the task first so it can't restart the server, then end the server itself (it outlives its parent).
Stop-ScheduledTask -TaskName 'Desktop Qwen - llama-server'
Get-CimInstance Win32_Process -Filter "Name='llama-server.exe'" |
    Where-Object CommandLine -match '--port 11435' |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
Start-Sleep 3
$used = nvidia-smi --query-gpu=memory.used --format=csv,noheader
Write-Host "Desktop Qwen is OFF. GPU memory in use: $used"
Start-Sleep 4
