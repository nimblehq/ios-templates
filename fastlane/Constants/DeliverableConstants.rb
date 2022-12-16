# frozen_string_literal: true

class DeliverableConstants

  ##################
  #### FIREBASE ####
  ##################

  # a gsp files directory
  def self.GSP_DIRECTORY
    './'
  end

  # a gsp file name for staging
  def self.GSP_STAGING
    './{PROJECT_NAME}/Configurations/Plists/GoogleService/Staging/GoogleService-Info.plist'
  end

  # a gsp file name for production
  def self.GSP_PRODUCTION
    './{PROJECT_NAME}/Configurations/Plists/GoogleService/Production/GoogleService-Info.plist'
  end

  # The path to the upload-symbols file of the Fabric app
  def self.BINARY_PATH
    './Pods/FirebaseCrashlytics/upload-symbols'
  end

  # a firebase app ID for Staging
  def self.FIREBASE_APP_ID_STAGING
    '<#PROJECT_FIREBASE_APP_ID#>'
  end

  # a firebase app ID for Production
  def self.FIREBASE_APP_ID_PRODUCTION
    '<#PROJECT_FIREBASE_APP_ID#>'
  end

  # Firebase Tester group name, seperate by comma(,) string
  def self.FIREBASE_TESTER_GROUPS
    "nimble-dev"
  end

  ##################
  ### DEV PORTAL ###
  ##################

  # Apple ID for Apple Developer Portal
  def self.DEV_PORTAL_APPLE_ID
    '<#dev@example.com#>'
  end

  #####################
  ### App Store API ###
  #####################

  # App Store Connect API Key ID
  def self.APP_STORE_KEY_ID
    '<#API_KEY_ID#>'
  end

  # App Store Connect API Issuer ID
  def self.APP_STORE_ISSUER_ID
    '<#ISSUER_ID#>'
  end

end
