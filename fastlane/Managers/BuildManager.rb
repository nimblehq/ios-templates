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
          bundle_identifier => "match AdHoc #{bundle_identifier}"
        }
      },
      output_name: product_name,
      disable_xcpretty: true
    )
  end

  def build_app_store(scheme, product_name, bundle_identifier)
    @fastlane.gym(
      scheme: scheme,
      export_method: 'app-store',
      export_options: {
        provisioningProfiles: {
          bundle_identifier => "match AppStore #{bundle_identifier}"
        }
      },
      output_name: product_name
    )
  end
end
