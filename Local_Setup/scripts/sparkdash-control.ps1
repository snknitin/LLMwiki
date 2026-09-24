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

function Test-SparkDashLocal {
    try {
        $response = Invoke-RestMethod -Uri $HealthUrl -TimeoutSec 4
        return ($response.ok -eq $true)
    }
    catch {
        return $false
    }
}

function Test-SparkDashTunnel {
    return $null -ne (Get-NetTCPConnection `
        -LocalAddress '127.0.0.1' `
        -LocalPort 5555 `
        -State Listen `
        -ErrorAction SilentlyContinue)
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
        if (Test-SparkDashTunnel) {
            Write-Output 'The persistent Windows sparkDash tunnel is already listening on 127.0.0.1:5555.'
            exit 0
        }

        Enable-ScheduledTask -TaskName $TaskName | Out-Null
        Start-ScheduledTask -TaskName $TaskName
        $deadline = (Get-Date).AddSeconds(45)
        do {
            Start-Sleep -Seconds 1
            if (Test-SparkDashTunnel) {
                Write-Output 'The persistent Windows sparkDash tunnel is listening on 127.0.0.1:5555.'
                exit 0
            }
        } while ((Get-Date) -lt $deadline)

        $info = Get-ScheduledTaskInfo -TaskName $TaskName
        Write-Error "The sparkDash tunnel did not start within 45 seconds. LastTaskResult=$($info.LastTaskResult)"
        exit 1
    }

    'Stop' {
        Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        Disable-ScheduledTask -TaskName $TaskName | Out-Null
        Write-Output 'The Windows sparkDash tunnel is stopped and disabled. The remote monitoring container was left intact.'
    }

    'Status' {
        $task = Get-ScheduledTask -TaskName $TaskName
        $info = Get-ScheduledTaskInfo -TaskName $TaskName
        $tunnelReady = Test-SparkDashTunnel
        $localReady = Test-SparkDashLocal
        $remoteResult = Invoke-FirstSpark -Command 'curl -fsS --max-time 4 http://127.0.0.1:5555/api/health >/dev/null'

        [pscustomobject]@{
            TaskState = $task.State
            TaskEnabled = $task.Settings.Enabled
            Tunnel = if ($tunnelReady) { 'listening' } else { 'unavailable' }
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
