# Start desktop Qwen again (2 x 262K sessions on port 11435) and wait until it answers.
Start-ScheduledTask -TaskName 'Desktop Qwen - llama-server'
for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep 2
    try { if ((Invoke-RestMethod http://127.0.0.1:11435/health -TimeoutSec 2).status -eq 'ok') { break } } catch {}
}
try { Invoke-RestMethod http://127.0.0.1:11435/health -TimeoutSec 2 | Out-Null; Write-Host 'Desktop Qwen is ON and ready.' }
catch { Write-Host "Desktop Qwen did not come up. Log: D:\LocalLLama\desktop-qwen\logs\server.log" }
Start-Sleep 4
