#!/usr/bin/env bash
# Swap the SecondSpark+ThirdSpark pair between its lanes; it holds one big model at a time.
# DeepSeek V4.1 Flash 1017 serves on :8890, GLM 5.3 Flash on :8888, Qwen 3.8 Flash Next on :8889 (PORT in each
# recipe's scripts/local.sh), so an alias never reaches the wrong model. Run on SecondSpark (deployed as
# ~/src/frontier/pair-swap.sh):
#   pair-swap.sh deepseek|glm|qwen   stop the other lanes, start that one; if it fails to start, bring back the
#                                    default lane, and GLM if the default fails too (exit 1 either way)
#   pair-swap.sh default             start the default lane (the boot unit runs this)
#   pair-swap.sh status              "live: <lane>" (or "live: none"), then what each port answers
set -euo pipefail
test "$(hostname)" = spark-7047 || { echo 'STOP: run on SecondSpark'; exit 1; }
cd ~/src/frontier
DEFAULT=glm
declare -A dir=([deepseek]=deepseek41-1017-tf [glm]=glm53-tf [qwen]=qwen38-dual-tf)
declare -A ctr=([deepseek]=dsv41-1017-exl3-tf [glm]=glm53-flash-tf [qwen]=qwen38-fn-tf)
declare -A args=([glm]='--thinking-budget 16384')
export PATH=$HOME/.local/bin:$PATH   # the recipes call hf, which a non-interactive ssh shell does not find otherwise
start_lane() {  # $1 with every other lane stopped; on failure stop it again
  local l
  for l in "${!dir[@]}"; do [[ $l == "$1" ]] || (cd "${dir[$l]}" && ./stop.sh); done
  (cd "${dir[$1]}" && ./start.sh ${args[$1]:-}) && return
  echo "$1 failed to start"; (cd "${dir[$1]}" && ./stop.sh) || true; return 1
}
case ${1:-status} in
  deepseek|glm|qwen|default)
    want=$1; [[ $want == default ]] && want=$DEFAULT
    tried=' '
    for l in "$want" "$DEFAULT" glm; do
      [[ $tried == *" $l "* ]] && continue; tried+="$l "
      [[ $l == "$want" ]] || echo "restoring $l"
      if start_lane "$l"; then [[ $l == "$want" ]] && exit 0; exit 1; fi
    done
    exit 1 ;;
  status)
    live=none; running=$(docker ps --format '{{.Names}}')
    for l in "${!ctr[@]}"; do grep -qx "${ctr[$l]}" <<<"$running" && live=$l; done
    echo "live: $live"
    for port in 8890 8888 8889; do curl -s -m 5 http://127.0.0.1:$port/v1/models && echo || true; done ;;
  *) echo "usage: $0 deepseek|glm|qwen|default|status"; exit 2 ;;
esac
