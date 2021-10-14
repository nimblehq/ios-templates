# frozen_string_literal: true

class TestManager
  def initialize(fastlane:, device:, output_directory:)
    @fastlane = fastlane
    @device = device
    @output_directory = output_directory
  end

  def build(scheme:)
    @fastlane.scan(
      scheme: scheme,
      device: @device,
      output_directory: @output_directory,
      code_coverage: true,
      result_bundle: true,
      build_for_testing: true,
      should_zip_build_products: true,
      clean: true,
      fail_build: false
    )
  end

  def test(scheme:, targets:)
    @fastlane.scan(
      scheme: scheme,
      device: @device,
      output_directory: @output_directory,
      code_coverage: true,
      result_bundle: true,
      test_without_building: true, 
      only_testing: targets,
      fail_build: false
    )
  end
end
