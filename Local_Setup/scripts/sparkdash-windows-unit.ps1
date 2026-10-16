#Requires -RunAsAdministrator
# One-time setup so FirstSpark's sparkDash can monitor this workstation over OpenSSH.
# sparkDash rejects SSH user names with spaces, so it gets its own non-admin account.
# Key logins (S4U tokens) are denied Win32_Processor / Win32_OperatingSystem, so sparkDash
# logs in with a random password that this script hands straight to sparkDash's encrypted store.
# Needs Dashboard Command Center open on Spark Dash (the 127.0.0.1:5555 tunnel).
$ErrorActionPreference = 'Stop'

$User = 'sparkdash'
$UnitUrl = 'http://127.0.0.1:5555/api/sparks/workstation'
$PublicKey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAHkGneZAUg86UmTxstaM2UUVt2a/p0zB4l1aDOf/bd shared-cluster-key'
$KeyFile = "$env:ProgramData\ssh\sparkdash_authorized_keys"
$SshdConfig = "$env:ProgramData\ssh\sshd_config"

Invoke-RestMethod -Uri $UnitUrl.Replace('/api/sparks/workstation', '/api/health') -TimeoutSec 5 | Out-Null

$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$plainPassword = [Convert]::ToBase64String($bytes)
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
if (Get-LocalUser -Name $User -ErrorAction SilentlyContinue) {
    Set-LocalUser -Name $User -Password $password -PasswordNeverExpires $true -Description 'sparkDash monitoring over SSH'
}
else {
    New-LocalUser -Name $User -Password $password -PasswordNeverExpires -UserMayNotChangePassword -Description 'sparkDash monitoring over SSH' | Out-Null
}
$body = @{ ssh = @{ auth = 'pass'; password = $plainPassword } } | ConvertTo-Json -Compress
Invoke-RestMethod -Method Patch -Uri $UnitUrl -ContentType 'application/json' -Body $body -TimeoutSec 15 | Out-Null
Remove-Variable plainPassword, body

# SSH logons count as remote to WMI, so CIM queries need Remote Management Users;
# Performance Monitor Users covers the GPU engine counters. Win32_Processor and
# Win32_OperatingSystem (CPU, RAM) stay denied to any non-admin SSH login, hence Administrators.
foreach ($group in 'Users', 'Remote Management Users', 'Performance Monitor Users', 'Administrators') {
    try { Add-LocalGroupMember -Group $group -Member $User }
    catch [Microsoft.PowerShell.Commands.MemberExistsException] { }
}

# Windows 11 still denies those groups over SSH, so grant the account itself
# Enable Account + Remote Enable (read-only; no method execution or writes).
$sid = (Get-LocalUser -Name $User).SID.Value
foreach ($namespace in 'root/cimv2', 'root/StandardCimv2') {
    $security = Get-CimInstance -Namespace $namespace -ClassName __SystemSecurity
    $descriptor = (Invoke-CimMethod -InputObject $security -MethodName GetSecurityDescriptor).Descriptor
    if ($descriptor.DACL | Where-Object { $_.Trustee.SIDString -eq $sid }) { continue }
    $trustee = New-CimInstance -ClassName Win32_Trustee -ClientOnly -Property @{ SIDString = $sid }
    $ace = New-CimInstance -ClassName Win32_ACE -ClientOnly -Property @{ AccessMask = [uint32]0x21; AceFlags = [uint32]0; AceType = [uint32]0; Trustee = $trustee }
    $descriptor.DACL = @($descriptor.DACL) + $ace
    $result = Invoke-CimMethod -InputObject $security -MethodName SetSecurityDescriptor -Arguments @{ Descriptor = $descriptor }
    if ($result.ReturnValue -ne 0) { throw "Setting WMI access on $namespace failed: $($result.ReturnValue)" }
}

# A ProgramData key file works before the account ever has a profile folder.
Set-Content -LiteralPath $KeyFile -Value $PublicKey -Encoding ascii
icacls.exe $KeyFile /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F' | Out-Null

if (-not (Select-String -LiteralPath $SshdConfig -Pattern '^\s*Match User sparkdash\s*$' -Quiet)) {
    Add-Content -LiteralPath $SshdConfig -Encoding ascii -Value "`r`nMatch User sparkdash`r`n       AuthorizedKeysFile __PROGRAMDATA__/ssh/sparkdash_authorized_keys"
}
& "$env:WINDIR\System32\OpenSSH\sshd.exe" -t
if ($LASTEXITCODE -ne 0) { throw 'sshd_config failed validation; sshd was not restarted.' }
Restart-Service sshd

Write-Output "Done. sparkDash can now log in as '$User' with its password (and the shared cluster key)."
