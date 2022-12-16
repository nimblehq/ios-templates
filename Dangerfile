# frozen_string_literal: true

require './fastlane/Constants/Constants'

# Warn when there is a big PR
warn("This pull request is quite big (#{git.lines_of_code} lines changed), please consider splitting it into multiple pull requests.") if git.lines_of_code > 500

# Warn to encourage that labels should have been used on the PR
warn("This pull request doesn't have any labels, please consider to add labels to this pull request.") if github.pr_labels.empty?

# SwiftFormat
swiftformat.binary_path = './Pods/SwiftFormat/CommandLineTool/swiftformat'
swiftformat.exclude = %w(Pods/**  **/*generated.swift)
swiftformat.check_format

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
changed_files = (git.modified_files - git.deleted_files) + git.added_files
xcode_summary.ignored_results { |result|
  if result.location
    not changed_files.include?(result.location.file_path)
  else
    true
  end
}
xcode_summary.ignored_files = 'Pods/**'
xcode_summary.inline_mode = true
xcode_summary.report xcresultPath

# Xcov
xcov.report(
  scheme: Constants.TESTS_SCHEME,
  workspace: Constants.WORKSPACE_PATH,
  output_directory: Constants.XCOV_OUTPUT_DIRECTORY_PATH,
  xccov_file_direct_path: xcresultPath,
  only_project_targets: true,
  markdown_report: true,
  html_report: false
)
