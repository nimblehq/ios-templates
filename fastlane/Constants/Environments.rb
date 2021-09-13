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
end
