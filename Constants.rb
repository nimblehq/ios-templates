# frozen_string_literal: true

class Constants
  #################
  #### PROJECT ####
  #################

  # Workspace path
  def self.WORKSPACE_PATH
    './SurveyTests.xcworkspace'
  end

  # Project path
  def self.PROJECT_PATH
    './SurveyTests.xcodeproj'
  end

  # bundle ID for Staging app
  def self.BUNDLE_ID_STAGING
    'co.nimblehq.david.ic-survey.staging'
  end

  # bundle ID for Production app
  def self.BUNDLE_ID_PRODUCTION
    'co.nimblehq.david.ic-survey'
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
    'SurveyTests Staging'
  end

  # a target name for tests
  def self.TESTS_TARGET
    'SurveyTestsTests'
  end

  # a target name for UI tests
  def self.UI_TESTS_TARGET
    'SurveyTestsUITests'
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
    'SurveyTests Staging'
  end

  # a Production environment scheme name
  def self.SCHEME_NAME_PRODUCTION
    'SurveyTests'
  end

  # an staging product name
  def self.PRODUCT_NAME_STAGING
    'SurveyTests Staging'
  end

  # a staging TestFlight product name
  def self.PRODUCT_NAME_STAGING_TEST_FLIGHT
    'SurveyTests TestFlight'
  end

  # a Production product name
  def self.PRODUCT_NAME_PRODUCTION
    'SurveyTests'
  end

  # a main target name
  def self.MAIN_TARGET_NAME
    'SurveyTests'
  end

end
