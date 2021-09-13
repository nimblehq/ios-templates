# frozen_string_literal: true

class BuildManager
  def initialize(fastlane:)
    @fastlane = fastlane
  end

  def build_ad_hoc(scheme, product_name, bundle_identifier)
    @fastlane.gym(
      scheme: scheme,
      export_method: 'ad-hoc',
      export_options: {
        provisioningProfiles: {
          @bundle_identifier.to_s => "match AdHoc #{bundle_identifier}"
        }
      },
      include_bitcode: false,
      output_name: product_name,
      disable_xcpretty: true
    )
  end

  def build_app_store(scheme, product_name, bundle_identifier, include_bitcode)
    @fastlane.gym(
      scheme: scheme,
      export_method: 'app-store',
      export_options: {
        provisioningProfiles: {
          @bundle_identifier_staging.to_s => "match AppStore #{bundle_identifier}"
        }
      },
      include_bitcode: include_bitcode,
      output_name: product_name
    )
  end
end
