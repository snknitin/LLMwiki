# Desktop Qwen 3.8 27B: two 262K sessions on the RTX PRO 5000 (Ollama can only serve this model one request at a time).
# Runs from its own copy in D:\LocalLLama\desktop-qwen so Ollama updates, quits or `ollama rm` can't break it:
# bin\ is a copy of Ollama 0.40.3's lib\ollama (llama-server + CUDA 13); models\ are hard links to the Ollama blobs.
$root = 'D:\LocalLLama\desktop-qwen'
$bin  = "$root\bin\llama-server.exe"
$cuda = "$root\bin\cuda_v13"
New-Item -ItemType Directory -Force "$root\logs" | Out-Null
# Without the CUDA folder on PATH and as the working directory the server silently falls back to CPU.
$env:PATH = "$cuda;$root\bin;$env:PATH"
Set-Location $cuda

$serverArgs = @(
    '--model',  "$root\models\Qwen3.8-27B-Q4_K_M.gguf",
    '--mmproj', "$root\models\Qwen3.8-27B-mmproj.gguf",
    '--alias', 'qwen3.8:27b-q4_k_m', '--host', '127.0.0.1', '--port', '11435',
    '--ctx-size', '524288', '--parallel', '2', '--no-kv-unified',
    '--cache-type-k', 'q8_0', '--cache-type-v', 'q8_0', '--flash-attn', 'on', '--gpu-layers', 'all',
    '--jinja', '--reasoning-format', 'deepseek',
    '--temp', '1.0', '--top-p', '0.95', '--top-k', '20', '--min-p', '0',
    '--spec-type', 'draft-mtp', '--spec-draft-n-max', '3',
    '--metrics', '--timeout', '1800', '--device', 'CUDA0'
)
& $bin @serverArgs *>> "$root\logs\server.log"
