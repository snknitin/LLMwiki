[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$sshConfig = Join-Path $env:LOCALAPPDATA 'NVIDIA Corporation\Sync\config\ssh_config'
$store = 'D:\LocalLLama\models\ollama'
$manifestPath = Join-Path $store 'manifests\registry.ollama.ai\library\qwen3.8\27b-q4_k_m'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$target = '/home/snknitin/.lmstudio/models/local/Qwen3.8-27B-Ollama'
$items = @(
    @{ Type='application/vnd.ollama.image.model'; Name='Qwen3.8-27B-Q4_K_M.gguf' },
    @{ Type='application/vnd.ollama.image.projector'; Name='mmproj-Qwen3.8-27B-BF16.gguf' }
)
foreach ($item in $items) {
    $layers = @($manifest.layers | Where-Object mediaType -eq $item.Type)
    if ($layers.Count -ne 1) { throw "Expected exactly one $($item.Type) layer" }
    $layer = $layers[0]
    if ($layer.digest -notmatch '^sha256:([a-f0-9]{64})$') { throw 'Invalid digest' }
    $digest = $Matches[1]
    $source = Join-Path $store ('blobs\sha256-' + $digest)
    $file = Get-Item -LiteralPath $source
    if ($file.Length -ne $layer.size) { throw 'Source size mismatch' }
    $stream = [IO.File]::OpenRead($source)
    try { $magic = New-Object byte[] 4; [void]$stream.Read($magic,0,4) } finally { $stream.Dispose() }
    if ([Text.Encoding]::ASCII.GetString($magic) -ne 'GGUF') { throw 'Source is not GGUF' }
    Write-Host "Verifying source checksum: $($item.Name)"
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -ne $digest) {
        throw 'Source checksum differs from Ollama manifest'
    }
    & ssh -F $sshConfig -o BatchMode=yes FirstSpark "mkdir -p '$target'"
    if ($LASTEXITCODE -ne 0) { throw 'Cannot create Spark model directory' }
    # Never overwrite a different existing final file. A matching file needs no transfer.
    $checkCode = @"
from pathlib import Path
import hashlib,sys
p=Path('$target/$($item.Name)')
if not p.exists(): sys.exit(3)
h=hashlib.file_digest(p.open('rb'),'sha256').hexdigest()
sys.exit(0 if h=='$digest' else 4)
"@
    $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($checkCode))
    & ssh -F $sshConfig -o BatchMode=yes FirstSpark "python3 -c `"import base64;exec(base64.b64decode('$encoded'))`""
    $checkResult = $LASTEXITCODE
    if ($checkResult -eq 0) { Write-Host "Already verified on Spark: $($item.Name)"; continue }
    if ($checkResult -ne 3) { throw 'Existing destination differs or check failed; inspect before continuing' }
    Write-Host "Copying $($item.Name) to Spark; source stays intact."
    & scp -F $sshConfig $source "FirstSpark:$target/$($item.Name).incoming"
    if ($LASTEXITCODE -ne 0) { throw 'Transfer failed. Partial .incoming retained; rerun copies this file again.' }
    $verifyCode = @"
from pathlib import Path
import hashlib,os
p=Path('$target/$($item.Name).incoming')
assert p.stat().st_size==$($layer.size), 'Size mismatch'
assert hashlib.file_digest(p.open('rb'),'sha256').hexdigest()=='$digest', 'Hash mismatch'
out=p.with_name('$($item.Name)')
assert not out.exists(), 'Final file appeared during transfer; inspect manually'
os.rename(p,out)
print('Verified:',out.name)
"@
    $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($verifyCode))
    & ssh -F $sshConfig -o BatchMode=yes FirstSpark "python3 -c `"import base64;exec(base64.b64decode('$encoded'))`""
    if ($LASTEXITCODE -ne 0) { throw 'Remote verification failed; model not ready' }
}
Write-Host 'Copy verified. No model loaded and no Ollama files removed. Continue with lms ls on FirstSpark.'
