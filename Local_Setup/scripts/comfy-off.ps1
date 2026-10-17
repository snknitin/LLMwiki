# Stop ComfyUI completely (whether the desktop icon or Command Center started it) to free the RTX.
$procs = Get-CimInstance Win32_Process -Filter "Name='python.exe'" | Where-Object { $_.CommandLine -like '*ComfyUI*main.py*' }
$procs | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
Start-Sleep 2
$used = nvidia-smi --query-gpu=memory.used --format=csv,noheader
if ($procs) { Write-Host "ComfyUI is OFF. GPU memory in use: $used" } else { Write-Host "ComfyUI was not running. GPU memory in use: $used" }
Start-Sleep 4
