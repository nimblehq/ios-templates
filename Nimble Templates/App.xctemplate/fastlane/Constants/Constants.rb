# frozen_string_literal: true

class Constants
  #################
  #### PROJECT ####
  #################

  # a project path
  def self.PROJECT_PATH
    './___PACKAGENAME___.xcodeproj'
  end

  # an output path for generated APN
  def self.APN_OUTPUT_PATH
    './apn'
  end

  #################
  #### TESTING ####
  #################

  # a device name
  def self.DEVICE
    'iPhone 11 Pro'
  end

  # a scheme name for all tests target
  def self.SCHEME_NAME_TEST_SUITE
    '___PACKAGENAME___ Staging'
  end

  # a scheme name for unit testing
  def self.SCHEME_NAME_UNIT_TESTS
    'UnitTests'
  end

  # a scheme name for ui testing
  def self.SCHEME_NAME_UI_TESTS
    'UITests'
  end

  # a scheme name for ui testing
  def self.CLEAN_BUILD_TESTING
    'true'
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
  ### ARCHIVING ###
  #################

  # a developer portal team id
  def self.DEV_PORTAL_TEAM_ID
    ''
  end

  # an Staging environment scheme name
  def self.SCHEME_NAME_STAGING
    '___PACKAGENAME___ Staging'
  end

  # a Production environment scheme name
  def self.SCHEME_NAME_PRODUCTION
    '___PACKAGENAME___'
  end

  # an Staging product name
  def self.SCHEME_NAME_UAT
    '___PACKAGENAME___ UAT'
  end

  # a Production product name
  def self.PRODUCT_NAME_PRODUCTION
    '___PACKAGENAME___'
  end

  # a main target name
  def self.MAIN_TARGET_NAME
    '___PACKAGENAME___'
  end

  #################
  ### CODE SIGN ###
  #################

  # a keychain name
  def self.KEYCHAIN_NAME
    ''
  end

  # a keychain password ( It uses by CI machine )
  def self.DEFAULT_KEYCHAIN_PASSWORD
    ''
  end

  # a code signin repository url
  def self.CODE_SIGNING_URL
    ''
  end

  #################
  ### BUNDLE ID ###
  #################

  # an STAGING bundle identifier
  def self.BUNDLE_ID_STAGING
    '___VARIABLE_bundleIdentifierPrefix:bundleIdentifier___.___PACKAGENAMEASRFC1034IDENTIFIER___.staging'
  end

  # an UAT bundle identifier
  def self.BUNDLE_ID_UAT
    '___VARIABLE_bundleIdentifierPrefix:bundleIdentifier___.___PACKAGENAMEASRFC1034IDENTIFIER___.uat'
  end

  # a Production bundle identifier
  def self.BUNDLE_ID_PRODUCTION
    '___VARIABLE_bundleIdentifierPrefix:bundleIdentifier___.___PACKAGENAMEASRFC1034IDENTIFIER___'
  end

  ##################
  ### DEV PORTAL ###
  ##################

  def self.DEV_PORTAL_APPLE_ID
    ''
  end

end
