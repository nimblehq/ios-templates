echo "import('./Tests/Fastfile')" | cat - fastlane/Fastfile | tee fastlane/Fastfile &> /dev/null

readonly CONSTANT_API_KEY_ID="<#API_KEY_ID#>"
readonly CONSTANT_ISSUER_ID="<#ISSUER_ID#>"
readonly CONSTANT_MATCH_REPO="git@github.com:{organization}\/{repo}.git"

readonly WORKING_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
MATCH_REPO_ESCAPED=$(echo "${MATCH_REPO//\//\\\/}")

LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_API_KEY_ID/$API_KEY_ID/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_ISSUER_ID/$ISSUER_ID/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_MATCH_REPO/$MATCH_REPO_ESCAPED/g" {} +
