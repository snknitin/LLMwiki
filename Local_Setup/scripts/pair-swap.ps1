# Desktop shortcuts "Pair -> Qwen 3.8 Flash" / "Pair -> GLM 5.3 Flash": swap the SecondSpark+ThirdSpark pair's model.
# Runs ~/src/frontier/pair-swap.sh on SecondSpark (about 2 minutes). In Hermes pick glm53-flash or qwen38-flash-pair;
# only the one loaded answers. GLM is the resident default: swap back when done with Qwen.
param([Parameter(Mandatory)][ValidateSet('qwen', 'glm')][string]$To, [switch]$NoPause)
$cfg = "$env:LOCALAPPDATA\NVIDIA Corporation\Sync\config\ssh_config"
$name = @{ qwen = 'Qwen 3.8 Flash Next (Hermes model: qwen38-flash-pair)'; glm = 'GLM 5.3 Flash (Hermes model: glm53-flash)' }[$To]
Write-Host "Swapping the Second+Third Spark pair to $name ... about 2 minutes, keep this window open."
$log = "~/src/frontier/pair-swap-last.log"
ssh -F $cfg SecondSpark "~/src/frontier/pair-swap.sh $To > $log 2>&1; rc=`$?; grep -a 'LIVE\|failed\|restoring\|ERROR' $log | tail -3; exit `$rc"
$rc = $LASTEXITCODE
Write-Host ''
ssh -F $cfg SecondSpark '~/src/frontier/pair-swap.sh status' | Select-Object -First 1
if ($rc -eq 0) { Write-Host "DONE: the pair now serves $name." -ForegroundColor Green }
else { Write-Host "FAILED (exit $rc). Full log on SecondSpark: $log" -ForegroundColor Red }
if (-not $NoPause) { Read-Host 'Press Enter to close' | Out-Null }
