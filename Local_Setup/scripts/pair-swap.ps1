# Desktop shortcut "Spark Pair - Switch Model": shows which model the SecondSpark+ThirdSpark pair is running and swaps it
# to the one you pick (about 2 minutes). Runs ~/src/frontier/pair-swap.sh on SecondSpark. In Hermes pick the matching
# model (deepseek41-flash-pair, glm53-flash or qwen38-flash-pair); only the one loaded answers.
#   pair-swap.ps1                 menu
#   pair-swap.ps1 -To deepseek    swap straight away (deepseek | glm | qwen)
param([ValidateSet('deepseek', 'glm', 'qwen')][string]$To, [switch]$NoPause)
$cfg = "$env:LOCALAPPDATA\NVIDIA Corporation\Sync\config\ssh_config"
$lanes = [ordered]@{
    deepseek = 'DeepSeek V4.1 Flash 1017 (Hermes model: deepseek41-flash-pair)'
    glm      = 'GLM 5.3 Flash (Hermes model: glm53-flash)'
    qwen     = 'Qwen 3.8 Flash Next (Hermes model: qwen38-flash-pair)'
}
function Done($code) { if (-not $NoPause) { Read-Host 'Press Enter to close' | Out-Null }; exit $code }
if (-not $To) {
    $status = ssh -n -F $cfg -o ConnectTimeout=10 SecondSpark '~/src/frontier/pair-swap.sh status' 2>$null | Select-String '^live: (\w+)'
    $live = $(if ($status) { $status.Matches[0].Groups[1].Value } else { 'unknown' })
    Write-Host "The Second+Third Spark pair is running: $(if ($lanes.Contains($live)) { $lanes[$live] } elseif ($live -eq 'none') { 'nothing' } else { 'unknown (SecondSpark did not answer)' })"
    Write-Host ''
    $keys = @($lanes.Keys)
    for ($i = 0; $i -lt $keys.Count; $i++) {
        $mark = $(if ($keys[$i] -eq $live) { '   <- live now' } else { '' })
        Write-Host "  $($i + 1)  $($lanes[$keys[$i]])$mark"
    }
    Write-Host ''
    # a plain string: from redirected input Read-Host can return a non-string that slips past the check below as index -1 (Qwen)
    $pick = "$(Read-Host 'Switch to (1-3, Enter to leave it as it is)')".Trim()
    if ($pick -notmatch '^[1-3]$') { exit 0 }
    $To = $keys[[int]$pick - 1]
    if ($To -eq $live) { Write-Host "$($lanes[$To]) is already live."; Done 0 }
}
$name = $lanes[$To]
Write-Host "Swapping the Second+Third Spark pair to $name ... about 2 minutes, keep this window open."
$log = "~/src/frontier/pair-swap-last.log"
ssh -F $cfg SecondSpark "~/src/frontier/pair-swap.sh $To > $log 2>&1; rc=`$?; grep -a 'LIVE\|failed\|restoring\|ERROR' $log | tail -3; exit `$rc"
$rc = $LASTEXITCODE
Write-Host ''
ssh -F $cfg SecondSpark '~/src/frontier/pair-swap.sh status' | Select-Object -First 1
if ($rc -eq 0) { Write-Host "DONE: the pair now serves $name." -ForegroundColor Green }
else { Write-Host "FAILED (exit $rc). Full log on SecondSpark: $log" -ForegroundColor Red }
Done $rc
