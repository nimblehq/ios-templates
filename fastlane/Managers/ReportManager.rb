# frozen_string_literal: true

class ReportManager
  def initialize(fastlane:, output_directory:)
    @fastlane = fastlane
    @output_directory = output_directory
  end

  def produce_report(scheme:, workspace:, test_output_directory:)
    xccov_file_direct_path = "#{test_output_directory}/#{scheme}.xcresult"
    @fastlane.xcov(
      scheme: scheme,
      workspace: workspace,
      output_directory: @output_directory,
      xccov_file_direct_path: xccov_file_direct_path,
      only_project_targets: true,
      markdown_report: true,
      html_report: false
    )
  end
end
