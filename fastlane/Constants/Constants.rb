# frozen_string_literal: true

class Constants
  #################
  #### PROJECT ####
  #################

  # Workspace path
  def self.WORKSPACE_PATH
    './{PROJECT_NAME}.xcworkspace'
  end

  # Project path
  def self.PROJECT_PATH
    './{PROJECT_NAME}.xcodeproj'
  end

  # bundle ID for Staging app
  def self.BUNDLE_ID_STAGING
    '{BUNDLE_ID_STAGING}'
  end

  # bundle ID for Production app
  def self.BUNDLE_ID_PRODUCTION
    '{BUNDLE_ID_PRODUCTION}'
  end

  #################
  #### BUILDING ###
  #################

  # a derived data path
  def self.DERIVED_DATA_PATH
    './DerivedData'
  end

  # a build path
  def self.BUILD_PATH
    './Build'
  end

  #################
  #### TESTING ####
  #################

  # a device name
  def self.DEVICE
    ENV.fetch('DEVICE', 'iPhone 12 Pro Max')
  end

  # a scheme name for testing
  def self.TESTS_SCHEME
    '{PROJECT_NAME} Staging'
  end

  # a target name for tests
  def self.TESTS_TARGET
    '{PROJECT_NAME}Tests'
  end

  # a target name for UI tests
  def self.UI_TESTS_TARGET
    '{PROJECT_NAME}UITests'
  end

  # xcov output directory path
  def self.XCOV_OUTPUT_DIRECTORY_PATH
    './fastlane/xcov_output'
  end

  # test output directory path
  def self.TEST_OUTPUT_DIRECTORY_PATH
    './fastlane/test_output'
  end

  #################
  #### KEYCHAIN ####
  #################

  # Keychain name
  def self.KEYCHAIN_NAME
    'github_action_keychain'
  end

  # a scheme name for unit testing
  def self.KEYCHAIN_PASSWORD
    'password'
  end

  #################
  ### ARCHIVING ###
  #################

  # an staging environment scheme name
  def self.SCHEME_NAME_STAGING
    '{PROJECT_NAME} Staging'
  end

  # a Production environment scheme name
  def self.SCHEME_NAME_PRODUCTION
    '{PROJECT_NAME}'
  end

  # an staging product name
  def self.PRODUCT_NAME_STAGING
    '{PROJECT_NAME} Staging'
  end

  # a staging TestFlight product name
  def self.PRODUCT_NAME_STAGING_TEST_FLIGHT
    '{PROJECT_NAME} TestFlight'
  end

  # a Production product name
  def self.PRODUCT_NAME_PRODUCTION
    '{PROJECT_NAME}'
  end

  # a main target name
  def self.MAIN_TARGET_NAME
    '{PROJECT_NAME}'
  end

end
