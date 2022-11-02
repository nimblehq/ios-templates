# frozen_string_literal: true

class EnvironmentManager
  def initialize(fastlane:, is_github_actions:, is_bitrise:, build_path:)
    @fastlane = fastlane
    @is_github_actions = is_github_actions
    @is_bitrise = is_bitrise
    @build_path = build_path
  end

  def save_build_context_to_ci(version_number:)
    ipa_path =  Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH]
    dsym_path = Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH]
    build_number = Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]

    if @is_github_actions
      @fastlane.sh("echo IPA_OUTPUT_PATH=#{ipa_path} >> $GITHUB_ENV")
      @fastlane.sh("echo DSYM_OUTPUT_PATH=#{dsym_path} >> $GITHUB_ENV")
      @fastlane.sh("echo BUILD_NUMBER=#{build_number} >> $GITHUB_ENV")
      @fastlane.sh("echo VERSION_NUMBER=#{version_number} >> $GITHUB_ENV")
    end
    if @is_bitrise
      @fastlane.sh("envman add --key BUILD_PATH --value '#{@build_path}'")
    end
  end
end
