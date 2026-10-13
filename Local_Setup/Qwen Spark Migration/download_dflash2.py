"""Download only the pinned matching DFlash2 assistant; reuse range/resume checks."""
from pathlib import Path
import download_native_parallel as transfer

transfer.REPO = 'ggml-org/Qwen3.8-27B-GGUF'
transfer.REV = '71bc7b627595dc8a91039addd9c791ae548d6747'
transfer.ROOT = Path('/home/snknitin/ai/stores/models/ggml-org-Qwen3.8-27B-DFlash2')
transfer.FILES = [('dflash-Qwen3.8-27B-Q4_0.gguf', 1094346080,
                   '0a994382adf17c720c9e5d4292f57344f3b445f058d3e9d5b0f601ae7d6ca3c4')]

if __name__ == '__main__':
    raise SystemExit(transfer.main())
