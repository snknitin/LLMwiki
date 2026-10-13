# Run as administrator after changing any setting below. Registers the boot task that runs desktop Qwen
# (S4U: starts at boot without a login) and restarts it. Daily on/off: the Qwen ON / Qwen OFF shortcuts.
# The task runs llama-server directly (no wrapper) so Stop-ScheduledTask - and so Qwen OFF - really stops it.
# bin\ is a copy of Ollama 0.40.3's lib\ollama with cuda_v13\* flattened beside the exe; models\ are hard links
# to Ollama blobs or copied GGUFs, so Ollama updates and `ollama rm` can't break this.
param([string]$User = "$env:USERDOMAIN\$env:USERNAME")
$root  = 'D:\LocalLLama\desktop-qwen'
# Model in use. Fallback: Qwen3.8-27B-Q4_K_M.gguf (faster, ~5 GB less VRAM).
$model = "$root\models\Qwen3.8-27B-UD-Q5_K_XL.gguf"
$serverArgs = @(
    '--model', $model, '--mmproj', "$root\models\Qwen3.8-27B-mmproj.gguf",
    '--alias', 'qwen3.8-27b-desktop', '--host', '127.0.0.1', '--port', '11435',
    '--ctx-size', '524288', '--parallel', '2', '--no-kv-unified',
    '--cache-type-k', 'q8_0', '--cache-type-v', 'q8_0', '--flash-attn', 'on', '--gpu-layers', 'all',
    '--jinja', '--reasoning-format', 'deepseek',
    '--temp', '1.0', '--top-p', '0.95', '--top-k', '20', '--min-p', '0',
    '--spec-type', 'draft-mtp', '--spec-draft-n-max', '3',
    '--metrics', '--timeout', '1800', '--device', 'CUDA0', '--log-file', "$root\logs\server.log", '--log-colors', 'off'
)
$t = 'Desktop Qwen - llama-server'
New-Item -ItemType Directory -Force "$root\logs" | Out-Null

# Stop whatever runs now. Task processes live in session 0; Ollama's own runners are in the desktop session.
Stop-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue
Get-Process llama-server -ErrorAction SilentlyContinue | Where-Object SessionId -eq 0 | Stop-Process -Force
Start-Sleep 3

$action    = New-ScheduledTaskAction -Execute "$root\bin\llama-server.exe" -Argument ($serverArgs -join ' ') -WorkingDirectory "$root\bin"
$principal = New-ScheduledTaskPrincipal -UserId $User -LogonType S4U -RunLevel Limited
$settings  = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
             -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -MultipleInstances IgnoreNew
Register-ScheduledTask -TaskName $t -Action $action -Principal $principal -Trigger (New-ScheduledTaskTrigger -AtStartup) -Settings $settings `
    -Description 'Desktop Qwen 3.8 27B, 2 x 262K on port 11435. Settings: Local_Setup\scripts\desktop-qwen-apply.ps1' -Force | Out-Null

Start-ScheduledTask -TaskName $t
$ok = $false
for ($i = 0; $i -lt 90 -and -not $ok; $i++) { Start-Sleep 2; try { $ok = (Invoke-RestMethod http://127.0.0.1:11435/health -TimeoutSec 2).status -eq 'ok' } catch {} }
$used = nvidia-smi --query-gpu=memory.used --format=csv,noheader
"ready=$ok model=$(Split-Path $model -Leaf) gpu=$used" | Tee-Object -FilePath "$root\logs\apply-result.txt"
Start-Sleep 5
