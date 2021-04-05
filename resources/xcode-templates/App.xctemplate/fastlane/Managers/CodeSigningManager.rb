# frozen_string_literal: true

class CodeSigningManager
  def initialize(
    fastlane:,
    keychain_name:,
    keychain_password:,
    bundle_id_staging:,
    bundle_id_uat:,
    bundle_id_production:,
    dev_portal_apple_id:,
    dev_portal_team_id:
  )
    @fastlane = fastlane
    @keychain_name = keychain_name
    @keychain_password = keychain_password
    @bundle_id_staging = bundle_id_staging
    @bundle_id_uat = bundle_id_uat
    @bundle_id_production = bundle_id_production
    @dev_portal_apple_id = dev_portal_apple_id
    @dev_portal_team_id = dev_portal_team_id
  end

  def sync_code_sign(update_development:, update_adhoc:, update_appstore:)
    create_keychain_if_needed(
      keychain_name: @keychain_name,
      keychain_password: @keychain_password
    )

    match_development(update: update_development)
    match_adhoc(update: update_adhoc)
  end

  def create_keychain_if_needed(keychain_name:, keychain_password:)
    keychain_password = @fastlane.is_ci ? keychain_password : @fastlane.prompt(
      text: "\n\n 🔐 Creating '#{keychain_name}' keychain ... \n\n 🔑 Please fill in '#{keychain_name}' keychain's password: ",
      secure_text: true
    )
    @fastlane.create_keychain(
      name: keychain_name,
      default_keychain: false,
      unlock: true,
      timeout: @fastlane.is_ci? ? false : 300,
      password: keychain_password
    )
  end

  def match_development(update: false)
    @fastlane.match(
      type: 'development',
      app_identifier: [@bundle_id_production, @bundle_id_staging, @bundle_id_uat],
      keychain_name: @keychain_name,
      force_for_new_devices: update,
      force: update,
      readonly: !update,
      username: @dev_portal_apple_id,
      team_id: @dev_portal_team_id
    )
  end

  def match_adhoc(update: false)
    @fastlane.match(
      type: 'adhoc',
      app_identifier: [@bundle_id_staging, @bundle_id_uat],
      keychain_name: @keychain_name,
      force_for_new_devices: update,
      force: update,
      readonly: !update,
      username: @dev_portal_apple_id,
      team_id: @dev_portal_team_id
    )
  end
end
