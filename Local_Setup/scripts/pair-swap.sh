#!/usr/bin/env bash
# Swap the SecondSpark+ThirdSpark pair between its two lanes; it holds one big model at a time, both on port 8888.
# GLM 5.3 Flash is the resident default. Run on SecondSpark (deployed as ~/src/frontier/pair-swap.sh):
#   pair-swap.sh qwen     stop GLM, start Qwen 3.8 Flash Next NVFP4 (falls back to GLM if Qwen fails to start)
#   pair-swap.sh glm      stop Qwen, start GLM
#   pair-swap.sh status   which lane answers
set -euo pipefail
test "$(hostname)" = spark-7047 || { echo 'STOP: run on SecondSpark'; exit 1; }
cd ~/src/frontier
glm_up() { (cd glm53-tf && ./start.sh --thinking-budget 16384); }
case ${1:-status} in
  qwen)
    (cd glm53-tf && ./stop.sh)
    (cd qwen38-dual-tf && ./start.sh) || {
      echo 'Qwen failed to start: restoring GLM'
      (cd qwen38-dual-tf && ./stop.sh) || true
      glm_up; exit 1; } ;;
  glm)
    (cd qwen38-dual-tf && ./stop.sh)
    glm_up ;;
  status)
    docker ps --format '{{.Names}} {{.Status}}' | grep -E 'glm53-flash-tf|qwen38-fn-tf' || echo 'no lane running'
    curl -s -m 5 http://127.0.0.1:8888/v1/models; echo ;;
  *) echo "usage: $0 qwen|glm|status"; exit 2 ;;
esac
