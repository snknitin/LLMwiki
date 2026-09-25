[CmdletBinding()]
param(
    [ValidateSet('Run', 'Start', 'Stop', 'Status', 'Recover')]
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

function Invoke-FirstSparkCaptured {
    param([Parameter(Mandatory)][string]$Command)

    $output = & $SshExe `
        -F $SshConfig `
        -o BatchMode=yes `
        -o StrictHostKeyChecking=yes `
        -o ConnectTimeout=15 `
        FirstSpark $Command 2>&1

    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Output = (($output | Out-String).Trim())
    }
}

function Write-RecoveryResult {
    param(
        [Parameter(Mandatory)][bool]$Success,
        [Parameter(Mandatory)][string]$Boundary,
        [Parameter(Mandatory)][string]$Detail,
        [bool]$RemoteStarted = $false,
        [bool]$TunnelRestarted = $false,
        [bool]$ListenerReady = $false,
        [bool]$LocalHealth = $false,
        [Parameter(Mandatory)][System.Diagnostics.Stopwatch]$Stopwatch
    )

    [pscustomobject]@{
        Success = $Success
        Boundary = $Boundary
        Detail = $Detail
        RemoteStarted = $RemoteStarted
        TunnelRestarted = $TunnelRestarted
        ListenerReady = $ListenerReady
        LocalHealth = $LocalHealth
        DurationMs = [int]$Stopwatch.ElapsedMilliseconds
    } | ConvertTo-Json -Compress
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

    'Recover' {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $remoteStarted = $false
        $tunnelRestarted = $false

        if (Test-SparkDashLocal) {
            Write-RecoveryResult -Success $true -Boundary 'none' -Detail 'Spark Dash was already healthy.' -ListenerReady (Test-SparkDashTunnel) -LocalHealth $true -Stopwatch $stopwatch
            exit 0
        }

        if (-not (Test-Path -LiteralPath $SshExe) -or -not (Test-Path -LiteralPath $SshConfig)) {
            Write-RecoveryResult -Success $false -Boundary 'SSH connection' -Detail 'The NVIDIA Sync SSH configuration or Windows OpenSSH client is missing.' -Stopwatch $stopwatch
            exit 1
        }

        $sshCheck = Invoke-FirstSparkCaptured -Command 'true'
        if ($sshCheck.ExitCode -ne 0) {
            $detail = if ($sshCheck.Output) { $sshCheck.Output } else { "SSH exited with code $($sshCheck.ExitCode)." }
            Write-RecoveryResult -Success $false -Boundary 'SSH connection' -Detail $detail -Stopwatch $stopwatch
            exit 1
        }

        $remoteCommand = '~/.local/bin/aux-services start sparkdash >/tmp/dcc-sparkdash-recover.log 2>&1 || { cat /tmp/dcc-sparkdash-recover.log; exit 20; }; i=0; until curl -fsS --max-time 4 http://127.0.0.1:5555/api/health >/dev/null; do i=$((i+1)); if [ "$i" -ge 30 ]; then cat /tmp/dcc-sparkdash-recover.log; exit 21; fi; sleep 2; done'
        $remoteStart = Invoke-FirstSparkCaptured -Command $remoteCommand
        if ($remoteStart.ExitCode -ne 0) {
            $detail = if ($remoteStart.Output) { $remoteStart.Output } else { "FirstSpark service did not become healthy; SSH exit code $($remoteStart.ExitCode)." }
            Write-RecoveryResult -Success $false -Boundary 'FirstSpark service' -Detail $detail -Stopwatch $stopwatch
            exit 1
        }
        $remoteStarted = $true

        try {
            Enable-ScheduledTask -TaskName $TaskName | Out-Null
            $task = Get-ScheduledTask -TaskName $TaskName
            if (-not (Test-SparkDashTunnel)) {
                if ($task.State -eq 'Running') {
                    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
                    $tunnelRestarted = $true
                    $stopDeadline = (Get-Date).AddSeconds(10)
                    do {
                        Start-Sleep -Milliseconds 250
                        $task = Get-ScheduledTask -TaskName $TaskName
                    } while ($task.State -eq 'Running' -and (Get-Date) -lt $stopDeadline)
                }
                Start-ScheduledTask -TaskName $TaskName
            }
        }
        catch {
            Write-RecoveryResult -Success $false -Boundary 'Windows tunnel' -Detail $_.Exception.Message -RemoteStarted $remoteStarted -TunnelRestarted $tunnelRestarted -Stopwatch $stopwatch
            exit 1
        }

        $listenerDeadline = (Get-Date).AddSeconds(45)
        do {
            if (Test-SparkDashTunnel) { break }
            Start-Sleep -Seconds 1
        } while ((Get-Date) -lt $listenerDeadline)

        if (-not (Test-SparkDashTunnel)) {
            $taskInfo = Get-ScheduledTaskInfo -TaskName $TaskName
            Write-RecoveryResult -Success $false -Boundary 'Windows tunnel' -Detail "No listener appeared on 127.0.0.1:5555 within 45 seconds. LastTaskResult=$($taskInfo.LastTaskResult)" -RemoteStarted $remoteStarted -TunnelRestarted $tunnelRestarted -Stopwatch $stopwatch
            exit 1
        }

        $healthDeadline = (Get-Date).AddSeconds(30)
        do {
            if (Test-SparkDashLocal) {
                Write-RecoveryResult -Success $true -Boundary 'none' -Detail 'FirstSpark Spark Dash and the Windows SSH tunnel are healthy.' -RemoteStarted $remoteStarted -TunnelRestarted $tunnelRestarted -ListenerReady $true -LocalHealth $true -Stopwatch $stopwatch
                exit 0
            }
            Start-Sleep -Seconds 1
        } while ((Get-Date) -lt $healthDeadline)

        Write-RecoveryResult -Success $false -Boundary 'local health' -Detail 'The listener exists, but http://127.0.0.1:5555/api/health did not pass within 30 seconds.' -RemoteStarted $remoteStarted -TunnelRestarted $tunnelRestarted -ListenerReady $true -Stopwatch $stopwatch
        exit 1
    }
}
