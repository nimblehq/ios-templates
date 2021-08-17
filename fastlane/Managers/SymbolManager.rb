# frozen_string_literal: true

class SymbolManager
  def initialize(fastlane:, version:, build_number:, build_path:, gsp_directory:, binary_path:)
    @fastlane = fastlane
    @version = version
    @build_number = build_number
    @build_path = build_path
    @gsp_directory = gsp_directory
    @binary_path = binary_path
  end

  def download_processed_dsym_then_upload_to_firebase(bundle_identifier:, gsp_name:)
    @fastlane.download_dsyms(
      app_identifier: bundle_identifier,
      version: @version,
      build_number: @build_number,
      wait_for_dsym_processing: true
    )
    @fastlane.upload_symbols_to_crashlytics(
      gsp_path: "#{@gsp_directory}/#{gsp_name}"
    )
  end

  def upload_built_symbol_to_firebase(product_name:, gsp_name:)
    @fastlane.upload_symbols_to_crashlytics(
      dsym_path: "#{@build_path}/#{product_name}.app.dSYM.zip",
      gsp_path: "#{@gsp_directory}/#{gsp_name}",
      binary_path: "#{@binary_path}"
    )
  end
end
