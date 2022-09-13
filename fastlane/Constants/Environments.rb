class Environments

  def self.FIREBASE_CLI_TOKEN
    ENV['FIREBASE_CLI_TOKEN']
  end

  def self.KEYCHAIN_PASSWORD
    ENV['KEYCHAIN_PASSWORD']
  end

  def self.CI
    ENV['CI']
  end

  def self.APPSTORE_CONNECT_API_KEY
    ENV['APPSTORE_CONNECT_API_KEY']
  end

  def self.MANUAL_VERSION
    ENV['MANUAL_VERSION']
  end

  def self.SKIP_FIREBASE_DSYM
    ENV['SKIP_FIREBASE_DSYM']
  end

  def self.BUMP_APP_STORE_BUILD_NUMBER
    ENV['BUMP_APP_STORE_BUILD_NUMBER']
  end
end
