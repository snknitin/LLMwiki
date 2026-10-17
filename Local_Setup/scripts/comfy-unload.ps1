# Unload every ComfyUI model from the RTX but keep ComfyUI open (it reloads models on the next run).
try {
    Invoke-RestMethod -Method Post http://127.0.0.1:8188/free -ContentType 'application/json' -Body '{"unload_models":true,"free_memory":true}' -TimeoutSec 10 | Out-Null
    Start-Sleep 3
    $used = nvidia-smi --query-gpu=memory.used --format=csv,noheader
    Write-Host "ComfyUI models unloaded. GPU memory in use: $used"
}
catch { Write-Host 'ComfyUI is not running on port 8188, nothing to unload.' }
Start-Sleep 4
