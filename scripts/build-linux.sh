#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
source_dir="$repo_root/vendor/ramulator2"
expected_commit=be93be78055d922aa1d4d33e15bcc8f2b0c61a9d

if [ ! -d "$source_dir/.git" ]; then
  mkdir -p "$repo_root/vendor"
  git clone --depth 1 --branch legacy/v2.0a \
    https://github.com/CMU-SAFARI/ramulator2.git "$source_dir"
fi

actual_commit=$(git -C "$source_dir" rev-parse HEAD)
if [ "$actual_commit" != "$expected_commit" ]; then
  echo "Ramulator source changed: expected $expected_commit, got $actual_commit" >&2
  exit 1
fi

# The pinned 2.0a source needs this dependent-template spelling with newer compilers.
python3 - "$source_dir/src/base/param.h" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
data = path.read_bytes()
old = b"_config[_name].as<T>()"
new = b"_config[_name].template as<T>()"
if old in data:
    path.write_bytes(data.replace(old, new))
elif new not in data:
    raise SystemExit("Expected Ramulator compatibility edit site was not found")
PY

cmake -S "$source_dir" -B "$source_dir/build" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build "$source_dir/build" -j 4
echo "Built $source_dir/build/ramulator2"
