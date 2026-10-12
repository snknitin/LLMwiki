#!/usr/bin/env bash
set -euo pipefail
export HF_HUB_DISABLE_IMPLICIT_TOKEN=1
export HF_XET_NUM_CONCURRENT_RANGE_GETS=4
export HF_XET_CACHE=/home/snknitin/ai/stores/models/.qwen38-xet-cache
model_dir=/home/snknitin/ai/stores/models/unsloth-Qwen3.8-27B-UD-Q5_K_XL
mkdir -p "$model_dir"
/home/snknitin/.local/bin/hf download unsloth/Qwen3.8-27B-GGUF \
  Qwen3.8-27B-UD-Q5_K_XL.gguf MTP/mtp-Qwen3.8-27B-Q4_0.gguf \
  --revision 4ca720788d1e01f1bff70c033e0d0028fd02e502 \
  --local-dir "$model_dir" --max-workers 1
cd "$model_dir"
printf '%s\n' \
  '8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276  Qwen3.8-27B-UD-Q5_K_XL.gguf' \
  '50d9ce5a6da381bbcfb31061cf73df94a90e6faf8efeddee379a9cb8f1501c6e  MTP/mtp-Qwen3.8-27B-Q4_0.gguf' | sha256sum -c -
python3 - <<'PY'
import json
from pathlib import Path
Path('verified-sha256.json').write_text(json.dumps({
    'Qwen3.8-27B-UD-Q5_K_XL.gguf': '8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276',
    'MTP/mtp-Qwen3.8-27B-Q4_0.gguf': '50d9ce5a6da381bbcfb31061cf73df94a90e6faf8efeddee379a9cb8f1501c6e'
}, indent=2) + '\n')
PY
printf '%s\n' 'Verified pinned Q5 target and MTP companion; no inference started.'
