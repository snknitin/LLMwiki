[CmdletBinding()]
param(
    [ValidateSet('Run', 'Start', 'Stop', 'Status')]
    [string]$Mode = 'Status'
)

$ErrorActionPreference = 'Stop'

$TaskName = 'DGX Spark sparkDash Tunnel'
$SshExe = "$env:WINDIR\System32\OpenSSH\ssh.exe"
$SshConfig = "$env:LOCALAPPDATA\NVIDIA Corporation\Sync\config\ssh_config"
$HealthUrl = 'http://127.0.0.1:5555/api/health'
$RemoteStart = 'cd "$HOME/src/frontier/sparkDash" && docker compose -f docker-compose.yml -f docker-compose.local.yml up -d >/dev/null && curl -fsS --retry 12 --retry-all-errors --retry-delay 1 --max-time 4 http://127.0.0.1:5555/api/health >/dev/null'

function Test-SparkDashLocal {
    try {
        $response = Invoke-RestMethod -Uri $HealthUrl -TimeoutSec 4
        return ($response.ok -eq $true)
    }
    catch {
        return $false
    }
}

function Invoke-FirstSpark {
    param([Parameter(Mandatory)][string]$Command)

    & $SshExe `
        -F $SshConfig `
        -o BatchMode=yes `
        -o StrictHostKeyChecking=yes `
        -o ConnectTimeout=15 `
        FirstSpark $Command

    return $LASTEXITCODE
}

switch ($Mode) {
    'Run' {
        $remoteResult = Invoke-FirstSpark -Command $RemoteStart
        if ($remoteResult -ne 0) {
            Write-Error "FirstSpark sparkDash failed to become healthy (SSH exit $remoteResult)."
            exit $remoteResult
        }

        & $SshExe `
            -F $SshConfig `
            -N `
            -T `
            -o BatchMode=yes `
            -o StrictHostKeyChecking=yes `
            -o ExitOnForwardFailure=yes `
            -o ConnectTimeout=15 `
            -o ServerAliveInterval=30 `
            -o ServerAliveCountMax=3 `
            -L '127.0.0.1:5555:127.0.0.1:5555' `
            FirstSpark

        # Any tunnel exit is unexpected. A nonzero result lets Task Scheduler's
        # bounded RestartOnFailure policy reconnect it.
        exit 1
    }

    'Start' {
        if (Test-SparkDashLocal) {
            Write-Output 'sparkDash is already ready at http://127.0.0.1:5555/'
            exit 0
        }

        $remoteResult = Invoke-FirstSpark -Command $RemoteStart
        if ($remoteResult -ne 0) {
            Write-Error "FirstSpark sparkDash failed to become healthy (SSH exit $remoteResult)."
            exit $remoteResult
        }

        Start-ScheduledTask -TaskName $TaskName
        $deadline = (Get-Date).AddSeconds(45)
        do {
            Start-Sleep -Seconds 1
            if (Test-SparkDashLocal) {
                Write-Output 'sparkDash is ready at http://127.0.0.1:5555/'
                exit 0
            }
        } while ((Get-Date) -lt $deadline)

        $info = Get-ScheduledTaskInfo -TaskName $TaskName
        Write-Error "sparkDash did not become ready within 45 seconds. LastTaskResult=$($info.LastTaskResult)"
        exit 1
    }

    'Stop' {
        Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        Write-Output 'The Windows sparkDash tunnel is stopped. The remote monitoring container was left intact.'
    }

    'Status' {
        $task = Get-ScheduledTask -TaskName $TaskName
        $info = Get-ScheduledTaskInfo -TaskName $TaskName
        $localReady = Test-SparkDashLocal
        $remoteResult = Invoke-FirstSpark -Command 'curl -fsS --max-time 4 http://127.0.0.1:5555/api/health >/dev/null'

        [pscustomobject]@{
            TaskState = $task.State
            LocalHealth = if ($localReady) { 'healthy' } else { 'unavailable' }
            RemoteHealth = if ($remoteResult -eq 0) { 'healthy' } else { 'unavailable' }
            LastRunTime = $info.LastRunTime
            LastTaskResult = $info.LastTaskResult
            Url = 'http://127.0.0.1:5555/'
        } | Format-List

        if (-not $localReady -or $remoteResult -ne 0) {
            exit 1
        }
    }
}
