# frozen_string_literal: true

class TestManager
  def initialize(fastlane:)
    @fastlane = fastlane
  end

  def build(scheme:)
    @fastlane.scan(scheme: scheme, build_for_testing: true, should_zip_build_products: true, clean: true)
  end

  def test(scheme:, target:)
    @fastlane.scan(scheme: scheme, test_without_building: true, only_testing: [target])
  end
end
