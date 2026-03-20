#!/usr/bin/env bash

set -euo pipefail

workflow_file=".asc/workflow.json"
workflow_name="${ASC_WORKFLOW_NAME:-appstore_release}"

case "$workflow_name" in
  appstore_build_only)
    resolved_step="build_only_resolve_release_inputs"
    dsym_step="build_only_package_dsym"
    publish_step=""
    ;;
  appstore_upload_only)
    resolved_step="upload_only_resolve_release_inputs"
    dsym_step="upload_only_package_dsym"
    publish_step="upload_only_publish"
    ;;
  appstore_release)
    resolved_step="release_resolve_release_inputs"
    dsym_step="release_package_dsym"
    publish_step="publish"
    ;;
  *)
    printf 'Unsupported ASC workflow: %s\n' "$workflow_name" >&2
    exit 1
    ;;
esac

if ! validate_json="$(asc workflow validate --file "$workflow_file")"; then
  printf '%s\n' "$validate_json"
  exit 1
fi

VALIDATE_JSON="$validate_json" python3 - <<'PY'
import json
import os
import sys

payload = json.loads(os.environ["VALIDATE_JSON"])
if not payload.get("valid", False):
    print(json.dumps(payload, indent=2), file=sys.stderr)
    raise SystemExit(1)
PY

run_args=(workflow run --file "$workflow_file" "$workflow_name")
for arg in "$@"; do
  run_args+=("$arg")
done

if ! run_json="$(asc "${run_args[@]}")"; then
  printf '%s\n' "$run_json"
  exit 1
fi

printf '%s\n' "$run_json"

if [[ -z "${GITHUB_ENV:-}" ]]; then
  exit 0
fi

RUN_JSON="$run_json" \
GITHUB_ENV_PATH="$GITHUB_ENV" \
RESOLVED_STEP="$resolved_step" \
DSYM_STEP="$dsym_step" \
PUBLISH_STEP="$publish_step" \
python3 - <<'PY'
import json
import os

result = json.loads(os.environ["RUN_JSON"])
outputs = result.get("outputs", {})
resolved = outputs.get(os.environ["RESOLVED_STEP"], {})
dsym = outputs.get(os.environ["DSYM_STEP"], {})
publish_step = os.environ.get("PUBLISH_STEP", "")
publish = outputs.get(publish_step, {}) if publish_step else {}

env_lines = {
    "VERSION_NUMBER": resolved.get("VERSION", ""),
    "BUILD_NUMBER": resolved.get("BUILD_NUMBER", ""),
    "IPA_OUTPUT_PATH": resolved.get("IPA_PATH", ""),
    "DSYM_OUTPUT_PATH": dsym.get("DSYM_PATH", ""),
    "ASC_BUILD_ID": publish.get("BUILD_ID", ""),
    "ASC_VERSION_ID": publish.get("VERSION_ID", ""),
    "ASC_SUBMISSION_ID": publish.get("SUBMISSION_ID", ""),
    "ASC_WORKFLOW_RUN_ID": result.get("run_id", ""),
}

with open(os.environ["GITHUB_ENV_PATH"], "a", encoding="utf-8") as handle:
    for key, value in env_lines.items():
        handle.write(f"{key}={value}\n")
PY
