#!/usr/bin/env bash

set -euo pipefail

project_path="${PROJECT_PATH:-}"
if [[ -z "$project_path" ]]; then
  project_path="$(find . -maxdepth 1 -type d -name '*.xcodeproj' | sort | head -n 1)"
fi

if [[ -z "$project_path" ]]; then
  echo "No .xcodeproj found at the repository root. Set PROJECT_PATH explicitly." >&2
  exit 1
fi

scheme="${SCHEME:-$(basename "$project_path" .xcodeproj)}"
configuration="${CONFIGURATION:-Release Production}"
artifacts_dir="${ARTIFACTS_DIR:-Output/asc}"
initial_build_number="${INITIAL_BUILD_NUMBER:-1}"
app_id="${ASC_APP_ID:-${APP_ID:-}}"

mkdir -p "$artifacts_dir"

build_settings_json="$(
  xcodebuild \
    -project "$project_path" \
    -scheme "$scheme" \
    -configuration "$configuration" \
    -destination "generic/platform=iOS" \
    -showBuildSettings \
    -json
)"

resolved_build_settings_json_file="$(mktemp)"
BUILD_SETTINGS_JSON="$build_settings_json" \
PROJECT_PATH="$project_path" \
SCHEME="$scheme" \
python3 - <<'PY' > "$resolved_build_settings_json_file"
import json
import os
import pathlib
import plistlib
import re


def normalize(value: object) -> str:
    if value is None:
        return ""
    return str(value).strip()


def read_plist_value(plist_path: pathlib.Path, key: str) -> str:
    if not plist_path.exists():
        return ""

    try:
        with plist_path.open("rb") as handle:
            payload = plistlib.load(handle)
    except Exception:
        return ""

    value = normalize(payload.get(key))
    if value.startswith("$("):
        return ""

    return value


entries = json.loads(os.environ["BUILD_SETTINGS_JSON"])
if isinstance(entries, dict):
    entries = [entries]

scheme = os.environ["SCHEME"]
project_path = pathlib.Path(os.environ["PROJECT_PATH"])


def score(entry: dict[str, object]) -> tuple[int, int]:
    build_settings = entry.get("buildSettings", {}) or {}
    full_product_name = normalize(build_settings.get("FULL_PRODUCT_NAME"))
    target = normalize(entry.get("target"))
    return (
        1 if full_product_name.endswith(".app") else 0,
        1 if target == scheme else 0,
    )


selected = max(entries, key=score, default={})
build_settings = selected.get("buildSettings", {}) or {}
srcroot = pathlib.Path(normalize(build_settings.get("SRCROOT")) or project_path.parent)

marketing_version = normalize(build_settings.get("MARKETING_VERSION"))
current_project_version = normalize(build_settings.get("CURRENT_PROJECT_VERSION"))
bundle_identifier = normalize(build_settings.get("PRODUCT_BUNDLE_IDENTIFIER"))
full_product_name = normalize(build_settings.get("FULL_PRODUCT_NAME"))
info_plist_file = normalize(build_settings.get("INFOPLIST_FILE"))

info_plist_path = pathlib.Path()
if info_plist_file:
    info_plist_path = pathlib.Path(info_plist_file)
    if not info_plist_path.is_absolute():
        info_plist_path = srcroot / info_plist_path

if not marketing_version and info_plist_path:
    marketing_version = read_plist_value(info_plist_path, "CFBundleShortVersionString")

if not current_project_version and info_plist_path:
    current_project_version = read_plist_value(info_plist_path, "CFBundleVersion")

pbxproj_path = project_path / "project.pbxproj"
pbxproj = ""
if pbxproj_path.exists():
    try:
        pbxproj = pbxproj_path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        pbxproj = pbxproj_path.read_text(encoding="utf-8", errors="ignore")

if not marketing_version and pbxproj:
    match = re.search(r"\bMARKETING_VERSION\s*=\s*([^;]+);", pbxproj)
    if match:
        candidate = normalize(match.group(1)).strip('"')
        if not candidate.startswith("$("):
            marketing_version = candidate

if not current_project_version and pbxproj:
    match = re.search(r"\bCURRENT_PROJECT_VERSION\s*=\s*([^;]+);", pbxproj)
    if match:
        candidate = normalize(match.group(1)).strip('"')
        if not candidate.startswith("$("):
            current_project_version = candidate

print(
    json.dumps(
        {
            "development_team": normalize(build_settings.get("DEVELOPMENT_TEAM")),
            "marketing_version": marketing_version,
            "current_project_version": current_project_version,
            "bundle_identifier": bundle_identifier,
            "full_product_name": full_product_name,
        }
    )
)
PY
resolved_build_settings_json="$(cat "$resolved_build_settings_json_file")"
rm -f "$resolved_build_settings_json_file"

marketing_version="$(printf '%s' "$resolved_build_settings_json" | python3 -c 'import json, sys; print(json.load(sys.stdin)["marketing_version"])')"
bundle_identifier="$(printf '%s' "$resolved_build_settings_json" | python3 -c 'import json, sys; print(json.load(sys.stdin)["bundle_identifier"])')"
full_product_name="$(printf '%s' "$resolved_build_settings_json" | python3 -c 'import json, sys; print(json.load(sys.stdin)["full_product_name"])')"
development_team="$(printf '%s' "$resolved_build_settings_json" | python3 -c 'import json, sys; print(json.load(sys.stdin)["development_team"])')"
product_name="${full_product_name%.app}"
if [[ -z "$product_name" ]]; then
  product_name="$scheme"
fi

version="${VERSION:-$marketing_version}"
if [[ -z "$bundle_identifier" ]]; then
  echo "Unable to resolve PRODUCT_BUNDLE_IDENTIFIER from build settings." >&2
  exit 1
fi

if [[ -z "$app_id" ]]; then
  app_lookup_json="$(asc apps list --bundle-id "$bundle_identifier" --output json)"
  app_id="$(printf '%s' "$app_lookup_json" | python3 -c 'import json, sys; data = json.load(sys.stdin).get("data", []); print(data[0]["id"] if data else "")')"
fi

if [[ -z "$version" ]]; then
  echo "Unable to resolve MARKETING_VERSION. Set VERSION explicitly." >&2
  exit 1
fi

build_number="${BUILD_NUMBER:-}"
if [[ -z "$build_number" ]]; then
  if [[ -z "$app_id" ]]; then
    echo "Unable to resolve the App Store Connect app ID from ASC_APP_ID or bundle ID $bundle_identifier." >&2
    exit 1
  fi

  build_number_json="$(asc builds latest --app "$app_id" --version "$version" --platform IOS --next --initial-build-number "$initial_build_number" --output json)"
  build_number="$(printf '%s' "$build_number_json" | python3 -c 'import json, sys; print(json.load(sys.stdin)["nextBuildNumber"])')"
fi

safe_product_name="$(printf '%s' "$product_name" | tr ' /' '--' | tr -cd '[:alnum:]._-')"
archive_path="$artifacts_dir/${safe_product_name}-${version}-${build_number}.xcarchive"
ipa_path="$artifacts_dir/${safe_product_name}-${version}-${build_number}.ipa"
dsym_path="$artifacts_dir/${safe_product_name}-${version}-${build_number}.app.dSYM.zip"
export_options_path="$artifacts_dir/export-options-app-store.plist"

if [[ -z "$development_team" ]]; then
  development_team="${TEAM_ID:-}"
fi

if [[ -z "$development_team" ]]; then
  echo "Unable to resolve DEVELOPMENT_TEAM from build settings or TEAM_ID." >&2
  exit 1
fi

TEAM_ID="$development_team" \
BUNDLE_IDENTIFIER="$bundle_identifier" \
EXPORT_OPTIONS_PATH="$export_options_path" \
python3 - <<'PY'
import os
import plistlib
from pathlib import Path

payload = {
    "method": "app-store-connect",
    "signingStyle": "manual",
    "teamID": os.environ["TEAM_ID"],
    "provisioningProfiles": {
        os.environ["BUNDLE_IDENTIFIER"]: f"match AppStore {os.environ['BUNDLE_IDENTIFIER']}"
    },
    "uploadSymbols": True,
}

with Path(os.environ["EXPORT_OPTIONS_PATH"]).open("wb") as handle:
    plistlib.dump(payload, handle, sort_keys=False)
PY

PROJECT_PATH="$project_path" \
SCHEME="$scheme" \
VERSION="$version" \
BUILD_NUMBER="$build_number" \
APP_ID="$app_id" \
PRODUCT_BUNDLE_IDENTIFIER="$bundle_identifier" \
PRODUCT_NAME="$product_name" \
ARCHIVE_PATH="$archive_path" \
IPA_PATH="$ipa_path" \
DSYM_PATH="$dsym_path" \
EXPORT_OPTIONS_PATH="$export_options_path" \
python3 - <<'PY'
import json
import os

print(
    json.dumps(
        {
            "project_path": os.environ["PROJECT_PATH"],
            "scheme": os.environ["SCHEME"],
            "version": os.environ["VERSION"],
            "build_number": os.environ["BUILD_NUMBER"],
            "app_id": os.environ["APP_ID"],
            "bundle_identifier": os.environ["PRODUCT_BUNDLE_IDENTIFIER"],
            "product_name": os.environ["PRODUCT_NAME"],
            "archive_path": os.environ["ARCHIVE_PATH"],
            "ipa_path": os.environ["IPA_PATH"],
            "dsym_path": os.environ["DSYM_PATH"],
            "export_options_path": os.environ["EXPORT_OPTIONS_PATH"],
        }
    )
)
PY
