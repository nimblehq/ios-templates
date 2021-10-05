#!/bin/sh
set -e

# Script inspired by https://gist.github.com/szeidner/613fe4652fc86f083cefa21879d5522b

PROGNAME=$(basename $0)
WORKING_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

die() {
    echo "$PROGNAME: $*" >&2
    exit 1
}

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME --bundle-id [BUNDLE_ID_PRODUCTION] --bundle-id-staging [BUNDLE_ID_STAGING] --app-name [PROJECT_NAME]
Set up an iOS app from tuist template.
Options:
-h, --help                         display this usage message and exit
-b, --bundle-id [BUNDLE_ID_PRODUCTION]  new production id (i.e. com.example.package)
-s, --bundle-id-staging [BUNDLE_ID_STAGING]  new staging id (i.e. com.example.package.staging)
-n, --app-name [PROJECT_NAME]          new app name (i.e. MyApp, "My App")
EOF

    exit 1
}

bundleidproduction=""
bundleidstaging=""
appname=""
while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -b|--bundle-id)
        bundleidproduction="$2"
        shift
        ;;
    -s|--bundle-id-staging)
        bundleidstaging="$2"
        shift
        ;;
    -n|--app-name)
        appname="$2"
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

OLD_APPNAME="ProjectName"
OLD_BUNDLE_PRODUCTION="co.nimblehq.projectname"
OLD_BUNDLE_STAGING="co.nimblehq.projectname.staging"
CONSTANT_APPNAME="{PROJECT_NAME}"
CONSTANT_BUNDLE_PRODUCTION="{BUNDLE_ID_PRODUCTION}"
CONSTANT_BUNDLE_STAGING="{BUNDLE_ID_STAGING}"

# Path segments
FIRST_PACKAGE_SEGMENT="co"
SECOND_PACKAGE_SEGMENT="nimblehq"
THIRD_PACKAGE_SEGMENT=""

if [ -z "$bundleidproduction" ] ; then
    read -p "BUNDLE ID PRODUCTION:" bundleidproduction
fi

if [ -z "$bundleidstaging" ] ; then
    read -p "BUNDLE ID STAGING:" bundleidstaging
fi

if [ -z "$appname" ] ; then
    read -p "APP NAME:" appname
fi

if [ -z "$bundleidproduction" ] || [ -z "$bundleidstaging" ] || [ -z "$appname" ] ; then
    usage "Input cannot be blank."
fi

# Enforce package name
regex='^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+[0-9a-z_]$'
if ! [[ $bundleidproduction =~ $regex ]]; then
    die "Invalid Package Name: $bundleidproduction (needs to follow standard pattern {com.example.package})"
fi

echo "=> 🐢 Staring init $appname ..."

# Trim spaces in APP_NAME
NAME_NO_SPACES=$(echo "$appname" | sed "s/ //g")

# Rename files structure
echo "=> 🔎 Replacing files structure..."

# Rename test folder structure
DIR="${OLD_APPNAME}Tests"
NEW_DIR="${NAME_NO_SPACES}Tests"
if [ -d "$DIR" ]
then
    mv ${DIR} ${NEW_DIR}
fi

# Rename UI Test folder structure
DIR="${OLD_APPNAME}UITests"
NEW_DIR="${NAME_NO_SPACES}UITests"
if [ -d "$DIR" ]
then
    mv ${DIR} ${NEW_DIR}
fi

# Rename app folder structure
DIR="${OLD_APPNAME}"
NEW_DIR="${NAME_NO_SPACES}"
if [ -d "$DIR" ]
then
    mv ${DIR} ${NEW_DIR}
fi

echo "✅  Completed"

# Search and replace in files
echo "=> 🔎 Replacing package and package name within files..."
BUNDLE_ID_PRODUCTION_ESCAPED="${bundleidproduction//./\.}"
OLD_BUNDLE_ID_PRODUCTION_ESCAPED="${OLD_BUNDLE_PRODUCTION//./\.}"
BUNDLE_ID_STAGING_ESCAPED="${bundleidstaging//./\.}"
OLD_BUNDLE_ID_STAGING_ESCAPED="${OLD_BUNDLE_STAGING//./\.}"
echo "${OLD_APPNAME}"
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$OLD_BUNDLE_ID_PRODUCTION_ESCAPED/$BUNDLE_ID_PRODUCTION_ESCAPED/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$OLD_BUNDLE_ID_STAGING_ESCAPED/$BUNDLE_ID_STAGING_ESCAPED/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_BUNDLE_PRODUCTION/$BUNDLE_ID_PRODUCTION_ESCAPED/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_BUNDLE_STAGING/$BUNDLE_ID_STAGING_ESCAPED/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_APPNAME/$NAME_NO_SPACES/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$OLD_APPNAME/$NAME_NO_SPACES/g" {} +
echo "✅  Completed"

# check for tuist and install
if ! command -v tuist &> /dev/null
then
    echo "tuist could not be found"
    echo "Installing tuist"
    curl -Ls https://install.tuist.io | bash
fi

# Generate with tuist
echo "tuist found"
tuist generate
echo "✅  Completed"

# remove Tuist files
# rm -rf tuist
# rm -rf Project.swift
# rm -rf make.sh

# Done!
echo "=> 🚀 Done! App is ready to be tested 🙌"