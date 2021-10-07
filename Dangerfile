# frozen_string_literal: true

require './fastlane/Constants/Constants'

# Warn when there is a big PR
warn("This pull request is quite big (#{git.lines_of_code} lines changed), please consider splitting it into multiple pull requests.") if git.lines_of_code > 500

# Warn to encourage that labels should have been used on the PR
warn("This pull request doesn't have any labels, please consider to add labels to this pull request.") if github.pr_labels.empty?

# Swiftlint
swiftlint.binary_path = './Pods/SwiftLint/swiftlint'
swiftlint.config_file = '.swiftlint.yml'
swiftlint.max_num_violations = 20
swiftlint.lint_files(
  inline_mode: true, 
  fail_on_error: true, 
  additional_swiftlint_args: '--strict'
)

xcresultPath = "#{Constants.TEST_OUTPUT_DIRECTORY_PATH}/#{Constants.TESTS_SCHEME}.xcresult"

# Xcode summary
xcode_summary.ignored_files = 'Pods/**'
xcode_summary.inline_mode = true
xcode_summary.report xcresultPath

# Upload the report of the code coverage of the files changed in a pull request
markdown File.read("#{Constants.XCOV_OUTPUT_DIRECTORY_PATH}/report.md")
