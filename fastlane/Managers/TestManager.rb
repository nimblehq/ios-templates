# frozen_string_literal: true

class TestManager
  def initialize(fastlane:, device:, output_directory:)
    @fastlane = fastlane
    @device = device
    @output_directory = output_directory
  end

  def build_and_test(scheme:, targets:)
    @fastlane.scan(
      scheme: scheme,
      device: @device,
      output_directory: @output_directory,
      code_coverage: true,
      result_bundle: true,
      only_testing: targets,
      fail_build: false
    )
  end
end
