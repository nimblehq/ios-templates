#!/bin/sh
set -e

# Script inspired by https://gist.github.com/szeidner/613fe4652fc86f083cefa21879d5522b

readonly PROGNAME=$(basename $0)
readonly WORKING_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

die() {
    echo "$PROGNAME: $*" >&2
    exit 1
}

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME --bundle-id [BUNDLE_ID_PRODUCTION] --bundle-id-staging [BUNDLE_ID_STAGING] --project-name [PROJECT_NAME]
Set up an iOS app from tuist template.
Options:
-h, --help                                   display this usage message and exit
-b, --bundle-id [BUNDLE_ID_PRODUCTION]       the production id (i.e. com.example.package)
-s, --bundle-id-staging [BUNDLE_ID_STAGING]  the staging id (i.e. com.example.package.staging)
-n, --project-name [PROJECT_NAME]            the project name (i.e. MyApp)
-i, --interface [INTERFACE]                  the user interface frameword (SwiftUI or UIKit)
EOF
    exit 1
}

bundle_id_production=""
bundle_id_staging=""
project_name=""
minimum_version=""
interface=""

readonly CONSTANT_PROJECT_NAME="{PROJECT_NAME}"
readonly CONSTANT_BUNDLE_PRODUCTION="{BUNDLE_ID_PRODUCTION}"
readonly CONSTANT_BUNDLE_STAGING="{BUNDLE_ID_STAGING}"
readonly CONSTANT_MINIMUM_VERSION="{TARGET_VERSION}"

while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -b|--bundle-id)
        bundle_id_production="$2"
        shift
        ;;
    -s|--bundle-id-staging)
        bundle_id_staging="$2"
        shift
        ;;
    -n|--project-name)
        project_name="$2"
        shift
        ;;
    -i|--interface)
        interface="$2"
        shift
        ;;
    -*)
        usage "Unknown option '$1'"
        ;;
    *)
        usage "Too many arguments"
      ;;
    esac
    shift
done

cat Scripts/Swift/SetUpiOSProject.swift Scripts/Swift/SetUpCICDService.swift Scripts/Swift/SetUpDeliveryConstants.swift Scripts/Swift/SetUpInterface.swift Scripts/Swift/Extensions/FileManager+Utils.swift Scripts/Swift/Extensions/String+Utils.swift Scripts/Swift/Helpers/SafeShell.swift > t.swift && swift t.swift $bundle_id_production $bundle_id_staging $project_name "$minimum_version" $interface && rm -rf 't.swift'
