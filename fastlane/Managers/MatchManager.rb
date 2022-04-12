# frozen_string_literal: true

class MatchManager
  def initialize(
      fastlane:,
      keychain_name:,
      keychain_password:,
      is_ci:
  )
    @fastlane = fastlane
    @keychain_name = keychain_name
    @keychain_password = keychain_password
    @is_ci = is_ci
  end

  def sync_development_signing(app_identifier:, force: false)
    if @is_ci
      create_ci_keychain
      @fastlane.match(
        type: 'development',
        keychain_name: @keychain_name,
        keychain_password: @keychain_password,
        app_identifier: app_identifier,
        readonly: !force,
        force: force
      )
    else
      @fastlane.match(type: 'development', app_identifier: app_identifier, readonly: !force, force: force)
    end
  end

  def sync_adhoc_signing(app_identifier:, force: false)
    if @is_ci
      create_ci_keychain
      @fastlane.match(
        type: 'adhoc',
        keychain_name: @keychain_name,
        keychain_password: @keychain_password,
        app_identifier: app_identifier,
        readonly: !force,
        force: force
      )
    else
      @fastlane.match(type: 'adhoc', app_identifier: app_identifier, readonly: !force, force: force)
    end
  end

  def sync_app_store_signing(app_identifier:)
    if @is_ci
      create_ci_keychain
      @fastlane.match(
        type: 'appstore',
        keychain_name: @keychain_name,
        keychain_password: @keychain_password,
        app_identifier: app_identifier,
        readonly: true
      )
    else
      @fastlane.match(type: 'appstore', app_identifier: app_identifier, readonly: true)
    end
  end

  def create_ci_keychain
    @fastlane.create_keychain(
        name: @keychain_name,
        password: @keychain_password,
        default_keychain: true,
        unlock: true,
        timeout: 3600,
        lock_when_sleeps: false
    )
  end
end
