#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: scripts/ci/asc_zip_dsym.sh <archive-path> <output-zip>" >&2
  exit 1
fi

archive_path="$1"
output_zip="$2"
dsym_dir="$(find "$archive_path/dSYMs" -maxdepth 1 -type d -name '*.app.dSYM' | sort | head -n 1)"

if [[ -z "$dsym_dir" ]]; then
  echo "No app dSYM found in $archive_path/dSYMs" >&2
  exit 1
fi

mkdir -p "$(dirname "$output_zip")"
rm -f "$output_zip"
ditto -c -k --sequesterRsrc --keepParent "$dsym_dir" "$output_zip"

DSYM_PATH="$output_zip" python3 - <<'PY'
import json
import os

print(json.dumps({"dsym_path": os.environ["DSYM_PATH"]}))
PY
