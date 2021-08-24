# frozen_string_literal: true

class Constants
  #################
  #### PROJECT ####
  #################
  
  # Project path
  def self.PROJECT_PATH
    './{PROJECT_NAME}.xcodeproj'
  end

  def self.BUNDLE_ID_STAGING
    '{BUNDLE_ID_STAGING}'
  end

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

  # a scheme name for unit testing
  def self.UNIT_TESTS_SCHEME
    '{PROJECT_NAME} Staging'
  end

  ##################
  #### FIREBASE ####
  ##################

  # a gsp files directory
  def self.GSP_DIRECTORY
    './'
  end

  # a gsp file name for staging
  def self.GSP_STAGING
    './GoogleService-Info.plist'
  end

  # a gsp file name for production
  def self.GSP_PRODUCTION
    './GoogleService-Info.plist'
  end

  # The path to the upload-symbols file of the Fabric app
  def self.BINARY_PATH
    './Pods/FirebaseCrashlytics/upload-symbols'
  end

  # a firebase app ID for Staging
  def self.FIREBASE_APP_ID_STAGING
    '{PROJECT_FIREBASE_APP_ID}'
  end

  # a firebase app ID for Production
  def self.FIREBASE_APP_ID_PRODUCTION
    '{PROJECT_FIREBASE_APP_ID}'
  end

  def self.FIREBASE_TESTER_GROUPS
    "nimble-dev"
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

   # a developer portal team id
  def self.DEV_PORTAL_TEAM_ID
    '{PROJECT_TEAM_ID}'
  end

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

  ##################
  ### DEV PORTAL ###
  ##################

  def self.DEV_PORTAL_APPLE_ID
    '{dev@example.com}'
  end

  #####################
  ### App Store API ###
  #####################

  # App Store Connect API Key ID
  def self.APP_STORE_KEY_ID
    '{API_KEY_ID}'
  end

  # App Store Connect API Issuer ID
  def self.APP_STORE_ISSUER_ID
    '{ISSUER_ID}'
  end

end
