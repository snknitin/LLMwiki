#!/usr/bin/env bash
# Run only on FirstSpark. Builds the pinned official runtime; never loads a model.
set -euo pipefail
umask 022

revision=d81235049384534c167caea52b85a694f6103d14
tag=b11429
runtime_root="${HOME}/.local/opt/llama.cpp-${tag}"
source_dir="${runtime_root}/source"
build_dir="${runtime_root}/build"
cuda_root=/usr/local/cuda-13.0
jobs="${QWEN_BUILD_JOBS:-4}"

[[ "$(uname -s)" == Linux && "$(uname -m)" == aarch64 ]] || {
  echo 'STOP: this installer is for Linux ARM64 FirstSpark.' >&2; exit 1;
}
[[ "$jobs" =~ ^[1-4]$ ]] || { echo 'STOP: QWEN_BUILD_JOBS must be 1-4.' >&2; exit 1; }
for command in git cmake g++ nvidia-smi; do command -v "$command" >/dev/null; done
[[ -x "${cuda_root}/bin/nvcc" ]] || { echo 'STOP: expected CUDA 13.0 toolkit is missing.' >&2; exit 1; }
[[ "$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader | head -n 1)" == 12.1 ]] || {
  echo 'STOP: expected compute capability 12.1 is absent.' >&2; exit 1;
}
mkdir -p "$runtime_root"
if [[ ! -e "$source_dir" ]]; then
  git init "$source_dir"
  git -C "$source_dir" remote add origin https://github.com/ggml-org/llama.cpp.git
fi
[[ -d "${source_dir}/.git" ]] || { echo 'STOP: existing source path is not this Git checkout.' >&2; exit 1; }
[[ "$(git -C "$source_dir" remote get-url origin)" == https://github.com/ggml-org/llama.cpp.git ]] || {
  echo 'STOP: unexpected source origin.' >&2; exit 1;
}
[[ -z "$(git -C "$source_dir" status --porcelain)" ]] || { echo 'STOP: source has local changes.' >&2; exit 1; }
git -C "$source_dir" fetch --depth 1 origin "$revision"
git -C "$source_dir" checkout --detach "$revision"
[[ "$(git -C "$source_dir" rev-parse HEAD)" == "$revision" ]]

# Build for this Spark using its existing toolkit. No apt, sudo, or driver changes.
cmake -S "$source_dir" -B "$build_dir" \
  -DCMAKE_BUILD_TYPE=Release \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_COMPILER="${cuda_root}/bin/nvcc" \
  -DCMAKE_CUDA_ARCHITECTURES=121 \
  '-DGGML_CUDA_FA_QUANTS=q8_0-q8_0;q4_0-q4_0;q8_0-q4_0' \
  -DLLAMA_BUILD_TESTS=OFF
cmake --build "$build_dir" --config Release --parallel "$jobs" --target llama-server

"${build_dir}/bin/llama-server" --version
"${build_dir}/bin/llama-server" --list-devices
"${build_dir}/bin/llama-server" --help > "${runtime_root}/llama-server-help.txt"
for flag in --ctx-size --parallel --no-kv-unified --kv-unified-per-slot --cache-type-k --cache-type-v --ctx-checkpoints --cache-ram --spec-type; do
  grep -F -- "$flag" "${runtime_root}/llama-server-help.txt" >/dev/null || {
    printf 'STOP: missing required flag: %s\n' "$flag" >&2; exit 1;
  }
done
printf '\nBuilt only; no model or service started. Runtime: %s\n' "${build_dir}/bin/llama-server"
printf 'Source revision: %s\n' "$revision"
