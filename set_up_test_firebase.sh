echo "import('./Tests/Fastfile')" | cat - fastlane/Fastfile | tee fastlane/Fastfile &> /dev/null

readonly CONSTANT_TEAM_ID="<#teamId#>"
readonly CONSTANT_STAGING_FIREBASE_APP_ID="<#stagingFirebaseAppId#>"
readonly CONSTANT_FIREBASE_TESTER_GROUPS="<#group1#>, <#group2#>"
readonly CONSTANT_MATCH_REPO="git@github.com:{organization}\/{repo}.git"

readonly WORKING_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
MATCH_REPO_ESCAPED=$(echo "${MATCH_REPO//\//\\\/}")

LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_TEAM_ID/4TWS7E2EPE/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_STAGING_FIREBASE_APP_ID/$STAGING_FIREBASE_APP_ID/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_FIREBASE_TESTER_GROUPS/nimble/g" {} +
LC_ALL=C find $WORKING_DIR -type f -exec sed -i "" "s/$CONSTANT_MATCH_REPO/$MATCH_REPO_ESCAPED/g" {} +
