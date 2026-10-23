#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
binary=${1:-"$repo_root/vendor/ramulator2/build/ramulator2"}
case "$binary" in
  /*) ;;
  *) binary="$repo_root/$binary" ;;
esac

if [ ! -x "$binary" ]; then
  echo "Ramulator binary not found: $binary" >&2
  echo "Run scripts/build-linux.sh or pass an executable path." >&2
  exit 1
fi

mkdir -p "$repo_root/results/latest"
cd "$repo_root/experiments"
"$binary" -f baseline.yaml > "$repo_root/results/latest/baseline.log" 2>&1
"$binary" -f blockhammer.yaml > "$repo_root/results/latest/blockhammer.log" 2>&1
echo "Results: $repo_root/results/latest/"
